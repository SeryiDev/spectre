"""Extract the 1.32 originals of the files in <work>/list.txt.

usage: extract_132.py <work dir> <1.32 game folder>

The 1.32 folder needs content/content*/bundles/blob.bundle, content/patch1/bundles/patch.bundle
and DLC/*/content/bundles/blob.bundle (see README.md). Those bundles use 320-byte index
entries (sizes at 276, offset at 284, compression at 316) and Doboz compression (3).
patch.bundle is read last, so its copies win. Writes <work>/v132/<path> and <work>/missing132.txt.
"""
import sys, pathlib, struct, zlib
sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import doboz
import lz4.block


def read_entries(data):
    index_size = struct.unpack_from('<I', data, 16)[0]
    out = []
    for pos in range(32, 32 + index_size - 320 + 1, 320):
        name = data[pos:pos + 256].split(bytes(1))[0].decode('ascii', 'replace')
        u, z, off = struct.unpack_from('<III', data, pos + 276)
        comp = struct.unpack_from('<I', data, pos + 316)[0]
        out.append({'name': name, 'u': u, 'z': z, 'off': off, 'comp': comp})
    return out


def unpack(data, e):
    raw = data[e['off']:e['off'] + e['z']]
    if e['comp'] == 0:
        d = raw
    elif e['comp'] == 1:
        d = zlib.decompress(raw)
    elif e['comp'] == 3:
        d = doboz.decompress(raw)
    elif e['comp'] in (4, 5):
        d = lz4.block.decompress(raw, uncompressed_size=e['u'])
    else:
        raise ValueError('compression %d: %s' % (e['comp'], e['name']))
    if len(d) != e['u']:
        raise ValueError('size: ' + e['name'])
    return d


out, game = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
want = set(l.strip() for l in open(out / 'list.txt', encoding='utf-8') if l.strip())
found = set()
bundles = sorted(list(game.rglob('blob.bundle')) + list(game.rglob('patch.bundle')),
                 key=lambda p: (1 if p.name == 'patch.bundle' else 0, str(p).lower()))
for b in bundles:
    data = b.read_bytes()
    n = 0
    for e in read_entries(data):
        name = e['name'].replace(chr(92), '/').lower()
        if name in want:
            p = out / 'v132' / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_bytes(unpack(data, e))
            found.add(name)
            n += 1
    if n:
        print(b.relative_to(game), n)
print('found', len(found), 'of', len(want))
(out / 'missing132.txt').write_text('\n'.join(sorted(want - found)) + '\n', encoding='utf-8', newline='\n')
