"""Doboz decompressor (compression type 3 in Witcher 3 1.32 bundles)."""
import struct

LUT = [
    (0xff, 2, 0, 0, 1),
    (0xffff, 2, 0, 0, 2),
    (0xffff, 6, 15, 2, 2),
    (0xffffff, 8, 31, 3, 3),
    (0xff, 2, 0, 0, 1),
    (0xffff, 2, 0, 0, 2),
    (0xffff, 6, 15, 2, 2),
    (0xffffffff, 11, 255, 3, 4),
]


def decompress(src: bytes) -> bytes:
    attr = src[0]
    if attr & 7:
        raise ValueError('doboz version %d' % (attr & 7))
    n = ((attr >> 3) & 7) + 1
    usize = int.from_bytes(src[1:1 + n], 'little')
    csize = int.from_bytes(src[1 + n:1 + 2 * n], 'little')
    p = 1 + 2 * n
    if attr & 128:
        return bytes(src[p:p + usize])
    s = bytes(src) + b'\0' * 8
    out = bytearray()
    cw = 1
    while len(out) < usize:
        if cw == 1:
            cw = struct.unpack_from('<I', s, p)[0]; p += 4
        if cw & 1 == 0:
            out.append(s[p]); p += 1
            cw >>= 1
        else:
            w = struct.unpack_from('<I', s, p)[0]
            mask, osh, lmask, lsh, size = LUT[w & 7]
            off = (w & mask) >> osh
            ln = ((w >> lsh) & lmask) + 3
            p += size
            start = len(out) - off
            if off <= 0 or start < 0:
                raise ValueError('bad match offset')
            if off >= ln:
                out += out[start:start + ln]
            else:
                for i in range(ln):
                    out.append(out[start + i])
            cw >>= 1
    return bytes(out[:usize])
