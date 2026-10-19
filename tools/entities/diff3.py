"""Three-way diff: 1.32 (base) -> Spectre edits, against 5.01.
Writes diff3.txt (per file) and prints a summary per property."""
import sys, pathlib, importlib.util, collections, re
sys.stdout.reconfigure(encoding='utf-8')
spec = importlib.util.spec_from_file_location("pairs_kv", str(pathlib.Path(__file__).parent / 'cr2w.py'))
cr = importlib.util.module_from_spec(spec); spec.loader.exec_module(cr)
root = pathlib.Path(sys.argv[1])
SKIP = ('cachedConnections', 'guid', 'GUID', 'idTag', 'IdTag')

def kv(fn):
    c = cr.CR2W(open(fn, 'rb').read())
    out = []
    c.dump('', out)
    d = collections.OrderedDict()
    for k, v in out:
        if any(s in k for s in SKIP) or ' raw ' in v:
            continue
        d[k] = v.replace('\\x00', '')
    return d

def prop(k):
    k = re.sub(r'\[\d+\]', '[]', k)
    k = re.sub(r'#\d+', '', k)
    return k.split('/')[-1]

names = [l.strip() for l in open(root / 'list.txt', encoding='utf-8') if l.strip()]
stats = collections.defaultdict(lambda: collections.Counter())
examples = collections.defaultdict(list)
files_with_edits = 0
untouched = []
with open(root / 'diff3.txt', 'w', encoding='utf-8') as f:
    for n in names:
        bp = root / 'v132' / n
        if not bp.exists():
            f.write('===== %s NO-1.32-BASE\n' % n)
            continue
        s, b, v = kv(root / 'spectre' / n), kv(bp), kv(root / 'vanilla501' / n)
        rows = []
        for k in list(s.keys()) + [k for k in b if k not in s]:
            vs, vb = s.get(k), b.get(k)
            if vs == vb:
                continue
            vv = v.get(k)
            if vv == vb:
                st = 'clean'      # 5.01 kept the 1.32 value: Spectre edit applies as is
            elif vv == vs:
                st = 'same'       # 5.01 already has Spectre's value
            else:
                st = 'conflict'   # CDPR changed it too
            rows.append((st, k, vb, vs, vv))
        if not rows:
            untouched.append(n)
        else:
            files_with_edits += 1
        f.write('===== %s %d\n' % (n, len(rows)))
        for st, k, vb, vs, vv in rows:
            f.write('  [%s] %s | 1.32: %s | Spectre: %s | 5.01: %s\n' % (st, k, vb or '(no)', vs or '(no)', vv or '(no)'))
            p = prop(k)
            stats[p][st] += 1
            stats[p]['files:' + n] = 1
            if len(examples[p]) < 4:
                examples[p].append('%s: %s -> %s (5.01 %s)' % (n.rsplit('/', 1)[-1], vb or '(no)', vs or '(no)', vv or '(no)'))
print('files with Spectre edits:', files_with_edits, ' untouched (identical props):', len(untouched))
for p, c in sorted(stats.items(), key=lambda x: -sum(v for k, v in x[1].items() if not k.startswith('files:'))):
    nf = sum(1 for k in c if k.startswith('files:'))
    print('%-60s files %4d  clean %4d same %4d conflict %4d' % (p[:60], nf, c['clean'], c['same'], c['conflict']))
    for e in examples[p][:2]:
        print('      ', e[:170])
