"""Extract Spectre's CR2W files and their 5.01 copies.

usage: extract.py <work dir> <Spectre v0.93 release folder or zip> <The Witcher 3 5.01 folder>

Writes <work>/spectre/<path>, <work>/vanilla501/<path>, <work>/list.txt (files 5.01 also has)
and <work>/new.txt (files only Spectre has).
"""
import sys, pathlib, importlib.util
sys.stdout.reconfigure(encoding='utf-8')
HERE = pathlib.Path(__file__).resolve().parent
BUNDLE = HERE.parent.parent / 'bundle'
sys.path.insert(0, str(BUNDLE))
spec = importlib.util.spec_from_file_location('build_bundle', str(BUNDLE / 'build_bundle.py'))
bb = importlib.util.module_from_spec(spec); spec.loader.exec_module(bb)
sys.path.insert(0, str(HERE))
import game501

KINDS = ('w2ent', 'w2scene', 'journal', 'w2phase', 'w2l', 'w2comm', 'w2behtree')

out, base, game = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])
blob = bb.load_base(base)
want = {e['name'].lower(): e for e in bb.read_entries(blob) if e['name'].rsplit('.', 1)[-1] in KINDS}
for n, e in want.items():
    p = out / 'spectre' / n
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(bb.unpack(blob, e))
found = game501.collect(game, set(want))
for n, copies in found.items():
    p = out / 'vanilla501' / n
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(copies[0][1])
print('Spectre', len(want), 'in 5.01', len(found))
(out / 'list.txt').write_text('\n'.join(sorted(found)) + '\n', encoding='utf-8', newline='\n')
(out / 'new.txt').write_text('\n'.join(sorted(set(want) - set(found))) + '\n', encoding='utf-8', newline='\n')
