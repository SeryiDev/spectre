"""Replay the structural edits of tools/entities/entities501.json ("ops") on a 5.01 CR2W file.

A CR2W file without buffers or embedded files is: a 160-byte header (40 bytes plus
10 tables of offset/count/crc), the tables (strings, names, imports, properties,
chunks) and the chunk data, all contiguous. On write:
  table crc  = crc32 of the table bytes
  name hash  = FNV-1a 32 of the name plus its trailing zero (existing names keep theirs)
  chunk crc  = crc32 of the chunk data
  header crc = crc32 of the 160 header bytes with the crc field set to 0xDEADBEEF
Chunk data: one zero byte, properties (name u16, type u16, size u32 counting itself,
value), a u16 zero, then whatever the class serializes after that.

ops, per CR2W ("outer" file, "nested" = the entity template's flatCompiledData):
  names    names appended to the name table, in order
  imports  [path, class, flags] appended to the import table
  chunks   [class, flags, parent, template, data hex] appended to the chunk table
  sets     [chunk index, property, type, value hex]: replace the property, or add it
"""
import struct
import zlib


def fnv1a(b: bytes) -> int:
    h = 0x811c9dc5
    for c in b:
        h = ((h ^ c) * 0x01000193) & 0xffffffff
    return h


class Prop:
    __slots__ = ("name", "type", "value")

    def __init__(self, name, type_, value):
        self.name, self.type, self.value = name, type_, value


class Chunk:
    def __init__(self, cls, flags, parent, template, data):
        self.cls, self.flags, self.parent, self.template = cls, flags, parent, template
        self.lead = data[:1]
        self.props = []
        p = 1
        while True:
            n = struct.unpack_from("<H", data, p)[0]
            if n == 0:
                p += 2
                break
            t, size = struct.unpack_from("<HI", data, p + 2)
            self.props.append(Prop(n, t, data[p + 8:p + 4 + size]))
            p += 4 + size
        self.tail = data[p:]

    def data(self) -> bytes:
        out = bytearray(self.lead)
        for pr in self.props:
            out += struct.pack("<HHI", pr.name, pr.type, len(pr.value) + 4) + pr.value
        out += b"\0\0" + self.tail
        return bytes(out)


class CR2W:
    def __init__(self, data: bytes):
        if data[:4] != b"CR2W":
            raise ValueError("not a CR2W file")
        (self.version, self.flags, self.timestamp, self.build,
         _fsize, _bsize, _crc, self.nchunks_field) = struct.unpack_from("<IIQIIIII", data, 4)
        t = [struct.unpack_from("<III", data, 40 + i * 12) for i in range(10)]
        if any(t[i][1] for i in range(5, 10)):
            raise ValueError("CR2W with buffers or embedded files")
        self.strings = bytearray(data[t[0][0]:t[0][0] + t[0][1]])
        self.names, self.name_entries = [], []
        for i in range(t[1][1]):
            so, h = struct.unpack_from("<II", data, t[1][0] + i * 8)
            self.names.append(self.cstr(so))
            self.name_entries.append((so, h))
        self.imports = [list(struct.unpack_from("<IHH", data, t[2][0] + i * 8)) for i in range(t[2][1])]
        self.proptable = data[t[3][0]:t[3][0] + t[3][1] * 16]
        self.nprop = t[3][1]
        self.chunks = []
        for i in range(t[4][1]):
            cls, fl, parent, size, off, tmpl, _ = struct.unpack_from("<HHIIIII", data, t[4][0] + i * 24)
            self.chunks.append(Chunk(cls, fl, parent, tmpl, data[off:off + size]))

    def cstr(self, so: int) -> str:
        return self.strings[so:self.strings.index(b"\0", so)].decode("utf-8")

    def string_offset(self, s: str) -> int:
        b = s.encode("utf-8") + b"\0"
        i = self.strings.find(b)
        while i > 0 and self.strings[i - 1] != 0:
            i = self.strings.find(b, i + 1)
        if i >= 0:
            return i
        i = len(self.strings)
        self.strings += b
        return i

    def write(self) -> bytes:
        entries = self.name_entries + [(self.string_offset(n), fnv1a(n.encode("utf-8") + b"\0"))
                                       for n in self.names[len(self.name_entries):]]
        strings = bytes(self.strings)
        names = b"".join(struct.pack("<II", so, h) for so, h in entries)
        imports = b"".join(struct.pack("<IHH", *im) for im in self.imports)
        datas = [c.data() for c in self.chunks]
        off = 160
        tables = []
        for blob, count in ((strings, len(strings)), (names, len(self.names)),
                            (imports, len(self.imports)), (self.proptable, self.nprop)):
            tables.append((off, count, zlib.crc32(blob) if count else 0, blob))
            off += len(blob)
        chunk_off = off
        pos = chunk_off + 24 * len(self.chunks)
        ctable = bytearray()
        for c, d in zip(self.chunks, datas):
            ctable += struct.pack("<HHIIIII", c.cls, c.flags, c.parent, len(d), pos, c.template, zlib.crc32(d))
            pos += len(d)
        tables.append((chunk_off, len(self.chunks), zlib.crc32(bytes(ctable)) if self.chunks else 0, bytes(ctable)))
        head = bytearray(160)
        head[:4] = b"CR2W"
        struct.pack_into("<IIQIIIII", head, 4, self.version, self.flags, self.timestamp, self.build,
                         pos, pos, 0xDEADBEEF, self.nchunks_field)
        for i, (o, cnt, crc, _) in enumerate(tables):
            struct.pack_into("<III", head, 40 + i * 12, o if cnt else 0, cnt, crc)
        struct.pack_into("<I", head, 32, zlib.crc32(bytes(head)))
        return bytes(head) + b"".join(t[3] for t in tables) + b"".join(datas)

    def apply(self, ops: dict):
        self.names.extend(ops["names"])
        for path, cls, flags in ops["imports"]:
            self.imports.append([self.string_offset(path), self.names.index(cls), flags])
        for cls, flags, parent, template, data in ops["chunks"]:
            self.chunks.append(Chunk(self.names.index(cls), flags, parent, template, bytes.fromhex(data)))
        for ci, pname, ptype, value in ops["sets"]:
            ni, ti, value = self.names.index(pname), self.names.index(ptype), bytes.fromhex(value)
            for pr in self.chunks[ci].props:
                if pr.name == ni:
                    pr.type, pr.value = ti, value
                    break
            else:
                self.chunks[ci].props.append(Prop(ni, ti, value))


def replay(data: bytes, ops: dict) -> bytes:
    f = CR2W(data)
    if "nested" in ops:
        prop = next(pr for c in f.chunks for pr in c.props
                    if f.names[pr.name] == "flatCompiledData" and pr.value[4:8] == b"CR2W")
        g = CR2W(prop.value[4:])
        g.apply(ops["nested"])
        blob = g.write()
        prop.value = struct.pack("<I", len(blob)) + blob
    if "outer" in ops:
        f.apply(ops["outer"])
    return f.write()
