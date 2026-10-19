"""Check the phase-2 outputs: they parse, only the intended things change, new objects equal Spectre's.

usage: check_phase2.py <work dir> <entities501.json>
Values the dumper only shows raw are left out of the last check (their name indices differ per file).
"""
import sys, json, pathlib, collections, re, importlib.util
sys.stdout.reconfigure(encoding='utf-8')
HERE = pathlib.Path(__file__).parent
spec = importlib.util.spec_from_file_location('cr2w', str(HERE / 'cr2w.py'))
cr = importlib.util.module_from_spec(spec); spec.loader.exec_module(cr)
root = pathlib.Path(sys.argv[1])
files = json.loads(pathlib.Path(sys.argv[2]).read_text(encoding='utf-8'))['files']
SKIP = ('cachedConnections', 'guid', 'GUID', 'idTag', 'IdTag')
OK_CLASSES = {'CCharacterStatsParam', 'CNewNPC', 'CCreatureDataComponent', 'CInventoryInitializerUniform',
              'CEntityTemplate', 'CAIMonsterReactionsTreeParams', 'CDettlaffColumn', 'W3Rat', 'CBuffImmunityParam',
              'DebuffProjectile', 'CJournalCreature', 'CHeartMiniboss', 'CR4LootParam', 'CInventoryDefinitionEntry',
              'CInventoryDefinition', 'CRainActionPointSelector', 'CAINpcReactionStopAndComment', 'CAINpcReactionRain',
              'CAINpcReactionBump', 'CAIActionMonsterRain', 'CAIActionMonsterPlayerPresence', 'CAIActionMonsterBumpTree',
              'CConeAttackRange', 'CBoxAttackRange', 'W3MonsterHuntNPC'}


def kv(data):
    c = cr.CR2W(data)
    out = []
    c.dump('', out)
    return {k: v for k, v in out if not any(s in k for s in SKIP)}


def cls_of(k):
    return re.sub(r'#\d+$', '', k.split('/')[-1].split('.')[0])


bad = 0
changed = collections.Counter()
for n, e in sorted(files.items()):
    if 'ops' not in e:
        continue
    v = bytearray((root / 'vanilla501' / n).read_bytes())
    for off, o, nw, note in e['patches']:
        v[off:off + len(o) // 2] = bytes.fromhex(nw)
    p2 = (root / 'phase2' / n).read_bytes()
    try:
        a, b = kv(bytes(v)), kv(p2)
    except Exception as ex:
        print('PARSE FAIL', n, ex); bad += 1; continue
    if any(' raw ' in x for x in b.values()) and not any(' raw ' in x for x in a.values()):
        print('RAW in output', n); bad += 1
    for k in set(a) | set(b):
        if a.get(k) != b.get(k):
            c = cls_of(k)
            if c not in OK_CLASSES:
                print('UNEXPECTED', n, k, a.get(k), '->', b.get(k)); bad += 1
            changed[c] += 1
    # every object class added must appear with the same values in Spectre
    s = kv((root / 'spectre' / n).read_bytes())
    def multiset(d, classes):
        return collections.Counter(re.sub(r'#\d+', '', k) + '=' + (x if '->' not in x else x.split()[0] + ' ' + x.split()[-1])
                                   for k, x in d.items() if cls_of(k) in classes and '/' not in k and ' raw ' not in x)
    new_classes = {cls_of(k) for k in b if k not in a} & {'CR4LootParam', 'CInventoryDefinitionEntry', 'CInventoryInitializerUniform',
                                                          'CAIActionMonsterBumpTree', 'CAINpcReactionBump', 'CRainActionPointSelector'}
    for c in new_classes:
        ms, mb = multiset(s, {c}), multiset(b, {c})
        if ms - mb:
            print('MISSING vs Spectre', n, c, list((ms - mb).items())[:3]); bad += 1
print('changed by class:', dict(changed))
print('problems:', bad)
