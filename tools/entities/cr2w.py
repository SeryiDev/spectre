"""Minimal CR2W (v163/v164) property dumper, to compare two versions of a Witcher 3 resource.

usage: cr2w.py file [file2]   -> prints a flat "path = value" listing; with two files prints only differences.
Values are decoded for common types; everything else is shown as hex. Embedded CR2W blobs
(flatCompiledData) are parsed recursively.
"""
import struct, sys, difflib

PRIMS = {
    'Bool': ('<B', 1), 'Uint8': ('<B', 1), 'Int8': ('<b', 1), 'Uint16': ('<H', 2), 'Int16': ('<h', 2),
    'Uint32': ('<I', 4), 'Int32': ('<i', 4), 'Uint64': ('<Q', 8), 'Int64': ('<q', 8),
    'Float': ('<f', 4), 'Double': ('<d', 8),
}


class R:
    def __init__(self, data):
        self.d = data

    def u8(self, p): return self.d[p]
    def u16(self, p): return struct.unpack_from('<H', self.d, p)[0]
    def u32(self, p): return struct.unpack_from('<I', self.d, p)[0]


def vlq(d, p):
    b = d[p]; p += 1
    neg = b & 0x80
    val = b & 0x3F
    shift = 6
    cont = b & 0x40
    while cont:
        b = d[p]; p += 1
        val |= (b & 0x7F) << shift
        shift += 7
        cont = b & 0x80
    return (-val if neg else val), p


class CR2W:
    def __init__(self, data):
        self.d = data
        assert data[:4] == b'CR2W', 'not CR2W'
        self.version = struct.unpack_from('<I', data, 4)[0]
        t = [struct.unpack_from('<III', data, 40 + i * 12) for i in range(10)]
        soff, ssize = t[0][0], t[0][1]
        self.strings = data[soff:soff + ssize]
        noff, ncount = t[1][0], t[1][1]
        self.names = []
        for i in range(ncount):
            so = struct.unpack_from('<I', data, noff + i * 8)[0]
            self.names.append(self.cstr(so))
        ioff, icount = t[2][0], t[2][1]
        self.imports = []
        for i in range(icount):
            so, cls, fl = struct.unpack_from('<IHH', data, ioff + i * 8)
            self.imports.append(self.cstr(so))
        coff, ccount = t[4][0], t[4][1]
        self.chunks = []
        for i in range(ccount):
            cls, flags, parent, size, off, tmpl, crc = struct.unpack_from('<HHIIIII', data, coff + i * 24)
            self.chunks.append((self.names[cls], parent, off, size))

    def cstr(self, so):
        e = self.strings.index(b'\0', so)
        return self.strings[so:e].decode('utf-8', 'replace')

    def name(self, i):
        return self.names[i] if 0 <= i < len(self.names) else '?%d' % i

    # ---- values
    def value(self, typ, p, end, path, out):
        d = self.d
        if typ in PRIMS:
            fmt, n = PRIMS[typ]
            v = struct.unpack_from(fmt, d, p)[0]
            if typ == 'Float':
                v = round(v, 4)
            out.append((path, str(v)))
            return p + n
        if typ == 'CName':
            out.append((path, self.name(struct.unpack_from('<H', d, p)[0])))
            return p + 2
        if typ in ('String', 'StringAnsi'):
            n, q = vlq(d, p)
            if typ == 'String' and n > 0:
                s = d[q:q + n * 2].decode('utf-16-le', 'replace'); q += n * 2
            else:
                n = abs(n)
                s = d[q:q + n].decode('utf-8', 'replace'); q += n
            out.append((path, repr(s)))
            return q
        if typ.startswith('handle:') or typ.startswith('ptr:'):
            idx = struct.unpack_from('<i', d, p)[0]
            if idx > 0 and idx - 1 < len(self.chunks):
                out.append((path, '-> ' + self.chunks[idx - 1][0]))
            elif idx < 0:
                out.append((path, '-> import ' + (self.imports[-idx - 1] if -idx - 1 < len(self.imports) else '?')))
            else:
                out.append((path, 'null'))
            return p + 4
        if typ.startswith('soft:'):
            idx = struct.unpack_from('<H', d, p)[0]
            out.append((path, 'soft ' + (self.imports[idx - 1] if 0 < idx <= len(self.imports) else str(idx))))
            return p + 2
        if typ.startswith('array:'):
            et = typ.split(',', 2)[2]
            cnt = struct.unpack_from('<I', d, p)[0]
            p += 4
            if et == 'Uint8' and path.endswith('flatCompiledData'):
                blob = d[p:p + cnt]
                try:
                    sub = CR2W(blob)
                    sub.dump(path + '/', out)
                except Exception as ex:
                    out.append((path, 'blob %d bytes (%s)' % (cnt, ex)))
                return p + cnt
            if et in PRIMS and PRIMS[et][1] == 1 and cnt > 64:
                out.append((path, 'bytes[%d] %08x' % (cnt, hash(d[p:p + cnt]) & 0xffffffff)))
                return p + cnt
            if cnt > end - p:
                return None
            for i in range(cnt):
                q = self.value(et, p, end, '%s[%d]' % (path, i), out)
                if q is None or q <= p or q > end:
                    return None
                p = q
            return p
        # struct: property list
        return self.props(p, end, path, out)

    def props(self, p, end, path, out):
        d = self.d
        while p + 2 <= end:
            n = struct.unpack_from('<H', d, p)[0]
            if n == 0:
                return p + 2
            t, size = struct.unpack_from('<HI', d, p + 2)
            pname, ptype = self.name(n), self.name(t)
            vstart = p + 8
            vend = p + 4 + size
            sub = []
            try:
                q = self.value(ptype, vstart, vend, path + '.' + pname, sub)
            except Exception:
                q = None
            if q is None or q > vend:
                out.append((path + '.' + pname, '%s raw %s' % (ptype, d[vstart:vend][:32].hex())))
            else:
                out.extend(sub)
            p = vend
        return p

    def dump(self, prefix, out):
        seen = {}
        for i, (cls, parent, off, size) in enumerate(self.chunks):
            k = seen.get(cls, 0); seen[cls] = k + 1
            path = '%s%s#%d' % (prefix, cls, k)
            self.props(off + 1, off + size, path, out)

    def chunk_index_label(self, i):
        # index among chunks of the same class, so paths stay stable when other chunks are added
        cls = self.chunks[i][0]
        return sum(1 for j in range(i) if self.chunks[j][0] == cls)


def listing(fn):
    c = CR2W(open(fn, 'rb').read())
    out = []
    c.dump('', out)
    return ['%s = %s' % kv for kv in out]


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    a = listing(sys.argv[1])
    if len(sys.argv) == 2:
        print('\n'.join(a))
    else:
        b = listing(sys.argv[2])
        for l in difflib.unified_diff(a, b, 'spectre', '5.01', n=0, lineterm=''):
            if not l.startswith('@@'):
                print(l)
