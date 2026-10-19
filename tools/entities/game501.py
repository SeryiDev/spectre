"""Read files out of the 5.01 game bundles (304-byte entries)."""
import struct, zlib, pathlib, collections
import lz4.block

def entries(path):
    with open(path, 'rb') as f:
        head = f.read(32)
        if head[:8] != b'POTATO70':
            return []
        off0 = struct.unpack_from('<I', head, 16)[0]
        idx = head + f.read(off0)
    out = []
    pos = 32
    while pos + 304 <= 32 + off0:
        e = idx[pos:pos + 304]
        name = e[:256].split(bytes(1))[0].decode('ascii', 'replace').replace(chr(92), '/').lower()
        off = struct.unpack_from('<Q', e, 272)[0]
        size, zsize = struct.unpack_from('<II', e, 280)
        comp = struct.unpack_from('<I', e, 292)[0]
        out.append((name, off, size, zsize, comp))
        pos += 304
    return out

def read(path, off, size, zsize, comp):
    with open(path, 'rb') as f:
        f.seek(off)
        raw = f.read(zsize)
    if comp == 0:
        return raw
    if comp == 1:
        return zlib.decompress(raw)
    return lz4.block.decompress(raw, uncompressed_size=size)

def collect(game, want):
    """name -> list of (bundle path, data) for every copy in the game bundles."""
    game = pathlib.Path(game)
    res = collections.defaultdict(list)
    for b in sorted((game / 'content').rglob('*.bundle')):
        if b.name.startswith('world_') or b.name == 'movies.bundle':
            continue  # level data and videos: not compared, Spectre's copy stays
        for name, off, size, zsize, comp in entries(b):
            if name in want:
                res[name].append((b, read(b, off, size, zsize, comp)))
    return res
