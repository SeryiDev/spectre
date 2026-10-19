"""Build the list of in-place patches that put Spectre's simple value edits onto the 5.01 files.

usage: gen_patches.py <all dir> <out json>
all dir has spectre/, v132/, vanilla501/ and list.txt.
A Spectre edit is a value that differs between 1.32 and Spectre. It is applied when:
  - the property exists in 5.01 with the 1.32 value (CDPR did not change it),
  - it is a fixed-size value (number, bool, CName that the 5.01 file already names),
  - its property is in the approved list,
  - the object it belongs to is the same one in the three files (same 'name', same array).
Files with no 1.32 copy use 5.01 as the base for the comparison.
Files left out, so the bundle keeps Spectre's copy: those 5.01 did not change from 1.32 when
Spectre's file is not CR2W 162, and those with no 1.32 copy where Spectre only adds to 5.01.
"""
import sys, json, re, hashlib, pathlib, collections, importlib.util, struct
sys.stdout.reconfigure(encoding='utf-8')
HERE = pathlib.Path(__file__).parent
sys.path.insert(0, str(HERE))
import sem
spec = importlib.util.spec_from_file_location('cr2wloc', str(HERE / 'cr2wloc.py'))
cr = importlib.util.module_from_spec(spec); spec.loader.exec_module(cr)

root = pathlib.Path(sys.argv[1])
out_json = pathlib.Path(sys.argv[2])

ANY_CLASS = {'level', 'currentLevel', 'levelFakeAddon', 'monsterCategory', 'usedContainersMin', 'usedContainersMax',
             'projDMG', 'projSilverDMG', 'destroyQuen', 'ignoreArmor', 'dealDamageEvenIfDodging',
             'damageTypeName', 'damageValue', 'debuffDuration', 'damageVal', 'money', 'explosionRange'}
BY_CLASS = {
    'CInventoryInitializerUniform': {'itemName'},
    'CInventoryDefinitionEntry': {'quantityMin', 'quantityMax'},
    'W3QuestCond_IsItemQuantityMet': {'count'},
    'CQCItemQuantity': {'quantity'},
    'CConeAttackRange': {'rangeMax', 'height', 'rangeAngle'},
    'CBoxAttackRange': {'rangeMax', 'height', 'rangeWidth'},
    'CCreatureDataComponent': {'itemsUsedAgainstCreature'},
    'CJournalCreature': {'itemsUsedAgainstCreature'},
}
SKIP = ('cachedConnections', 'guid', 'GUID', 'idTag', 'IdTag')


def load(fn):
    c = cr.CR2W(fn.read_bytes())
    out = []
    c.dump('', out)
    d = {}
    for k, v in out:
        if any(s in k for s in SKIP) or ' raw ' in v:
            continue
        d[k] = v.replace('\\x00', '')
    return d, c.locs


def split(k):
    """'a/b/CNewNPC#0.level' -> ('a/b/CNewNPC#0', 'CNewNPC', 'level', index or None)"""
    obj, _, prop = k.rpartition('.')
    cls = re.sub(r'#\d+$', '', obj.rsplit('/', 1)[-1])
    m = re.match(r'(\w+)(\[\d+\])*$', prop)
    base = m.group(1) if m else prop
    return obj, cls, base, ('[' in prop)


def approved(cls, prop):
    return prop in ANY_CLASS or prop in BY_CLASS.get(cls, ())


def same_object(obj, s, b, v):
    """The object's own name, if it has one, must agree in the three files."""
    key = obj + '.name'
    return s.get(key) == b.get(key) == v.get(key)


def same_array(k, b, v):
    """For an array element, the rest of the array must be the same in 1.32 and 5.01."""
    pre = k[:k.rindex('[')]
    eb = sorted((x, y) for x, y in b.items() if x.startswith(pre + '['))
    ev = sorted((x, y) for x, y in v.items() if x.startswith(pre + '['))
    return eb == ev


names = [l.strip() for l in open(root / 'list.txt', encoding='utf-8') if l.strip()]
result = {}
skipped = collections.Counter()
skipped_rows = []
applied = collections.Counter()
keep_spectre = []
for n in names:
    sp, bp, vp = root / 'spectre' / n, root / 'v132' / n, root / 'vanilla501' / n
    s, sl = load(sp)
    v, vl = load(vp)
    if bp.exists():
        b, _ = load(bp)
        # CDPR did not change it from 1.32, and Spectre edited the 1.32 file: Spectre's copy is right as it is
        if sp.read_bytes()[4] != 162 and sem.same(bp.read_bytes(), vp.read_bytes()):
            keep_spectre.append(n)
            continue
    else:
        b = v
        # no 1.32 copy: if Spectre only adds to 5.01 (nothing of 5.01 is missing or different), keep Spectre's file
        if all(s.get(k) == val for k, val in v.items()):
            keep_spectre.append(n)
            continue
    vdata = vp.read_bytes()
    sdata = sp.read_bytes()
    patches = []
    pending_fake = []
    levels_ok = set()
    for k, vs in s.items():
        vb = b.get(k)
        if vb is None or vs == vb:
            continue
        obj, cls, prop, is_arr = split(k)
        if not approved(cls, prop):
            continue
        vv = v.get(k)
        why = None
        if vv is None:
            why = 'not in 5.01'
        elif vv != vb:
            why = 'conflict' if vv != vs else 'already'
        elif not same_object(obj, s, b, v):
            why = 'object moved'
        elif is_arr and not same_array(k, b, v):
            why = 'array changed'
        elif k not in sl or k not in vl:
            why = 'no location'
        if why == 'already':
            continue
        if why:
            skipped[(cls + '.' + prop, why)] += 1
            skipped_rows.append((n, k, vb, vs, vv, why))
            continue
        voff, vsize, vtyp, vobj = vl[k]
        soff, ssize, styp, sobj = sl[k]
        if vtyp != styp or vsize != ssize:
            skipped[(cls + '.' + prop, 'type differs')] += 1
            continue
        if vtyp == 'CName':
            try:
                idx = vobj.names.index(vs)
            except ValueError:
                skipped[(cls + '.' + prop, 'name not in 5.01 file')] += 1
                skipped_rows.append((n, k, vb, vs, vv, 'name not in 5.01 file'))
                continue
            new = struct.pack('<H', idx)
        else:
            new = sdata[soff:soff + ssize]
        old = vdata[voff:voff + vsize]
        p = [voff, old.hex(), new.hex(), '%s: %s -> %s' % (k, vb, vs)]
        if prop == 'levelFakeAddon':
            pending_fake.append((obj, p))
            continue
        if prop == 'level':
            levels_ok.add(obj)
        patches.append(p)
        applied[cls + '.' + prop] += 1
    # levelFakeAddon -> 0 only where Spectre's level is set as well (patched now, or already equal)
    for obj, p in pending_fake:
        lv = obj + '.level'
        if obj in levels_ok or (lv in s and s.get(lv) == v.get(lv)):
            patches.append(p)
            applied['levelFakeAddon'] += 1
        else:
            skipped[('levelFakeAddon', 'level not set')] += 1
    patches.sort()
    result[n] = {'sha256': hashlib.sha256(vdata).hexdigest(), 'patches': patches}

json.dump({'files': result, 'keep_spectre': keep_spectre}, open(out_json, 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
with open(out_json.with_suffix('.skipped.txt'), 'w', encoding='utf-8') as f:
    for r in skipped_rows:
        f.write('%s | %s | 1.32 %s | Spectre %s | 5.01 %s | %s\n' % r)
print('files from 5.01:', len(result), ' with patches:', sum(1 for x in result.values() if x['patches']), ' kept from Spectre:', keep_spectre)
print('applied:')
for k, c in applied.most_common():
    print('  %5d %s' % (c, k))
print('skipped:')
for k, c in skipped.most_common():
    print('  %5d %s' % (c, k))
