"""Typed property values for cr2wedit: decode to a file-independent form and encode back.

Value forms:
  ('p', bytes)         number, bool, string or other value without indices
  ('n', str)           CName
  ('e', str)           enum stored as a name
  ('h', int)           handle/ptr: >0 chunk index + 1, <0 import, 0 null
  ('s', int)           soft reference: import index, 0 none
  ('a', [values])      array
  ('t', [(name, type, value)])  struct ('T': the same, written after a zero byte)
"""
import struct

PRIM = {'Bool': 1, 'Uint8': 1, 'Int8': 1, 'Uint16': 2, 'Int16': 2, 'Uint32': 4, 'Int32': 4,
        'Uint64': 8, 'Int64': 8, 'Float': 4, 'Double': 8, 'EngineTime': 4, 'Color': 4}


class Unknown(Exception):
    pass


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


def read(f, typ, d, p, end):
    if typ in PRIM:
        n = PRIM[typ]
        if p + n > len(d):
            raise Unknown(typ)
        return ('p', d[p:p + n]), p + n
    if typ == 'CName':
        return ('n', f.names[struct.unpack_from('<H', d, p)[0]]), p + 2
    if typ in ('String', 'StringAnsi'):
        n, q = vlq(d, p)
        if typ == 'String' and n > 0:
            q += n * 2
        else:
            q += abs(n)
        return ('p', d[p:q]), q
    if typ.startswith('handle:') or typ.startswith('ptr:'):
        return ('h', struct.unpack_from('<i', d, p)[0]), p + 4
    if typ.startswith('soft:'):
        return ('s', struct.unpack_from('<H', d, p)[0]), p + 2
    if typ.startswith('array:'):
        et = typ.split(',', 2)[2]
        cnt = struct.unpack_from('<I', d, p)[0]
        p += 4
        if et == 'Uint8':
            return ('p', d[p - 4:p + cnt]), p + cnt
        out = []
        for _ in range(cnt):
            v, p = read(f, et, d, p, end)
            out.append(v)
        return ('a', out), p
    if typ.startswith('E') and end - p == 2:
        i = struct.unpack_from('<H', d, p)[0]
        if i < len(f.names):
            return ('e', f.names[i]), p + 2
    # struct; inside arrays a struct can start with a zero byte, like a chunk
    try:
        return read_struct(f, typ, d, p, end, 't')
    except (Unknown, struct.error, IndexError):
        if p < len(d) and d[p] == 0:
            v, q = read_struct(f, typ, d, p + 1, end, 'T')
            return v, q
        raise Unknown(typ)


def read_struct(f, typ, d, p, end, kind):
    props = []
    q = p
    while True:
        if q + 2 > end:
            raise Unknown(typ)
        n = struct.unpack_from('<H', d, q)[0]
        if n == 0:
            q += 2
            break
        if n >= len(f.names) or q + 8 > end:
            raise Unknown(typ)
        t, size = struct.unpack_from('<HI', d, q + 2)
        if t >= len(f.names) or q + 4 + size > end:
            raise Unknown(typ)
        v, r = read(f, f.names[t], d, q + 8, q + 4 + size)
        if r != q + 4 + size:
            raise Unknown(f.names[t])
        props.append((f.names[n], f.names[t], v))
        q += 4 + size
    return (kind, props), q


def decode_prop(f, prop):
    typ = f.names[prop.type]
    try:
        v, end = read(f, typ, prop.value, 0, len(prop.value))
    except (struct.error, IndexError):
        raise Unknown(typ)
    if end != len(prop.value):
        raise Unknown(typ)
    return v


def write(f, typ, v, handle=lambda h: h, soft=lambda s: s):
    k = v[0]
    if k == 'p':
        return v[1]
    if k in ('n', 'e'):
        return struct.pack('<H', f.name_index(v[1]))
    if k == 'h':
        return struct.pack('<i', handle(v[1]))
    if k == 's':
        return struct.pack('<H', soft(v[1]))
    if k == 'a':
        et = typ.split(',', 2)[2]
        return struct.pack('<I', len(v[1])) + b''.join(write(f, et, x, handle, soft) for x in v[1])
    if k in ('t', 'T'):
        out = bytearray(bytes(1) if k == 'T' else b'')
        for name, t, x in v[1]:
            b = write(f, t, x, handle, soft)
            out += struct.pack('<HHI', f.name_index(name), f.name_index(t), len(b) + 4) + b
        return bytes(out) + b'\0\0'
    raise ValueError(k)


def refs(v, out):
    """Collect handle values (>0) inside a value."""
    k = v[0]
    if k == 'h' and v[1] > 0:
        out.append(v[1])
    elif k == 'a':
        for x in v[1]:
            refs(x, out)
    elif k in ('t', 'T'):
        for _, _, x in v[1]:
            refs(x, out)
    return out
