"""Read, edit and write CR2W files (v162-v164) without buffers or embedded files.

Layout: 160-byte header (40 + 10 tables of offset/count/crc), then the tables
(strings, names, imports, properties, chunks) and the chunk data, all contiguous.
Checks the format uses, reproduced on write:
  table crc  = crc32 of the table bytes
  name hash  = FNV-1a 32 of the name plus its trailing zero
  chunk crc  = crc32 of the chunk data
  header crc = crc32 of the 160 header bytes with the crc field set to 0xDEADBEEF
Chunk data: one zero byte, properties (name u16, type u16, size u32 counting
itself, value), a u16 zero, then whatever the class serializes after that.
"""
import struct, zlib

ELEM = [1, 8, 8, 16, 24, 24, 24, 0, 0, 0]


def fnv1a(b):
    h = 0x811c9dc5
    for c in b:
        h = ((h ^ c) * 0x01000193) & 0xffffffff
    return h


class Prop:
    __slots__ = ('name', 'type', 'value')

    def __init__(self, name, type_, value):
        self.name, self.type, self.value = name, type_, value


class Chunk:
    def __init__(self, cls, flags, parent, template, data):
        self.cls, self.flags, self.parent, self.template = cls, flags, parent, template
        self.lead, self.props, self.tail = self._split(data)

    @staticmethod
    def _split(data):
        lead = data[:1]
        props = []
        p = 1
        while True:
            if p + 2 > len(data):
                raise ValueError('chunk without property terminator')
            n = struct.unpack_from('<H', data, p)[0]
            if n == 0:
                p += 2
                break
            t, size = struct.unpack_from('<HI', data, p + 2)
            props.append(Prop(n, t, data[p + 8:p + 4 + size]))
            p += 4 + size
        return lead, props, data[p:]

    def data(self):
        out = bytearray(self.lead)
        for pr in self.props:
            out += struct.pack('<HHI', pr.name, pr.type, len(pr.value) + 4) + pr.value
        out += b'\0\0' + self.tail
        return bytes(out)


class CR2W:
    def __init__(self, data):
        self.raw = data
        assert data[:4] == b'CR2W'
        (self.version, self.flags, self.timestamp, self.build,
         fsize, bsize, crc, nch) = struct.unpack_from('<IIQIIIII', data, 4)
        t = [struct.unpack_from('<III', data, 40 + i * 12) for i in range(10)]
        # buffers and embedded files: readable (chunks still parse), but such a file cannot be written
        self.readonly = any(t[i][1] for i in range(5, 10))
        self.strings = bytearray(data[t[0][0]:t[0][0] + t[0][1]])
        self.names = []
        self.name_offs = []
        for i in range(t[1][1]):
            so, h = struct.unpack_from('<II', data, t[1][0] + i * 8)
            self.names.append(self.cstr(so))
            self.name_offs.append((so, h))
        self.nchunks_field = nch
        self.imports = [list(struct.unpack_from('<IHH', data, t[2][0] + i * 8)) for i in range(t[2][1])]
        self.proptable = data[t[3][0]:t[3][0] + t[3][1] * 16]
        self.nprop = t[3][1]
        self.chunks = []
        for i in range(t[4][1]):
            cls, fl, parent, size, off, tmpl, ccrc = struct.unpack_from('<HHIIIII', data, t[4][0] + i * 24)
            self.chunks.append(Chunk(cls, fl, parent, tmpl, data[off:off + size]))
        self._string_index = None

    def cstr(self, so):
        e = self.strings.index(b'\0', so)
        return self.strings[so:e].decode('utf-8')

    # ---- names / strings
    def name_index(self, s, add=True):
        try:
            return self.names.index(s)
        except ValueError:
            if not add:
                raise
            self.names.append(s)
            return len(self.names) - 1

    def string_offset(self, s):
        b = s.encode('utf-8') + b'\0'
        i = self.strings.find(b)
        while i > 0 and self.strings[i - 1] != 0:
            i = self.strings.find(b, i + 1)
        if i >= 0:
            return i
        i = len(self.strings)
        self.strings += b
        return i

    def import_index(self, path, cls_name, flags):
        """1-based import index for a soft/handle reference, adding it if missing."""
        for i, (so, ci, fl) in enumerate(self.imports):
            if self.cstr(so) == path and self.names[ci] == cls_name:
                return i + 1
        self.imports.append([self.string_offset(path), self.name_index(cls_name), flags])
        return len(self.imports)

    # ---- write
    def write(self):
        if self.readonly:
            raise ValueError('writing files with buffers or embedded files is not supported')
        # existing names keep their string and hash; new ones get FNV-1a of name + NUL
        entries = self.name_offs + [(self.string_offset(n), fnv1a(n.encode('utf-8') + b'\0'))
                                    for n in self.names[len(self.name_offs):]]
        strings = bytes(self.strings)
        names = b''.join(struct.pack('<II', so, h) for so, h in entries)
        imports = b''.join(struct.pack('<IHH', *im) for im in self.imports)
        datas = [c.data() for c in self.chunks]
        off = 160
        tables = []
        for blob, count in ((strings, len(strings)), (names, len(self.names)), (imports, len(self.imports)),
                            (self.proptable, self.nprop)):
            tables.append((off, count, zlib.crc32(blob) if count else 0, blob))
            off += len(blob)
        chunk_off = off
        data_off = chunk_off + 24 * len(self.chunks)
        ctable = bytearray()
        pos = data_off
        for c, d in zip(self.chunks, datas):
            ctable += struct.pack('<HHIIIII', c.cls, c.flags, c.parent, len(d), pos, c.template, zlib.crc32(d))
            pos += len(d)
        tables.append((chunk_off, len(self.chunks), zlib.crc32(bytes(ctable)) if self.chunks else 0, bytes(ctable)))
        total = pos
        head = bytearray(160)
        head[:4] = b'CR2W'
        struct.pack_into('<IIQIIIII', head, 4, self.version, self.flags, self.timestamp, self.build,
                         total, total, 0xDEADBEEF, self.nchunks_field)
        for i, (o, cnt, crc, _) in enumerate(tables):
            struct.pack_into('<III', head, 40 + i * 12, o if cnt else 0, cnt, crc)
        struct.pack_into('<I', head, 32, zlib.crc32(bytes(head)))
        return bytes(head) + b''.join(t[3] for t in tables) + b''.join(datas)
