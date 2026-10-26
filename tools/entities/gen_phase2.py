"""Phase 2: Spectre edits that change the structure of the 5.01 file.

usage: gen_phase2.py <all dir> <entities501.json> <report.txt>

Starts from the 5.01 file with the phase-1 patches, compares Spectre with 1.32 per object,
and records "ops" in entities501.json that from_game.py replays:
  - lists merged three ways (abilities, immunities, recommended oils/bombs),
  - names the 5.01 file does not have (renamed loot, damage type),
  - properties Spectre adds (levels, loot settings...),
  - objects Spectre adds (loot and inventory params, inventory entries, monster reactions).
Additions and removals in files saved by old game versions (CR2W 162) are old content, not
Spectre edits, so only levels and list additions are taken from those.
"""
import sys, json, hashlib, pathlib, collections, struct
sys.path.insert(0, str(pathlib.Path(__file__).parent))
import cr2wedit, cr2wval

root = pathlib.Path(sys.argv[1])
jpath = pathlib.Path(sys.argv[2])
report = open(sys.argv[3], 'w', encoding='utf-8')

LISTS = {('CCharacterStatsParam', 'abilities'), ('CBuffImmunityParam', 'immunityTo'),
         ('CCreatureDataComponent', 'itemsUsedAgainstCreature'), ('CJournalCreature', 'itemsUsedAgainstCreature')}
SCALARS = {('CInventoryInitializerUniform', 'itemName'), ('DebuffProjectile', 'damageTypeName'),
           ('CConeAttackRange', 'rangeMax'), ('CConeAttackRange', 'height'), ('CConeAttackRange', 'rangeAngle'),
           ('CBoxAttackRange', 'rangeMax'), ('CBoxAttackRange', 'height'), ('CBoxAttackRange', 'rangeWidth')}
LEVEL_ADDS = {('CNewNPC', 'level'), ('W3Rat', 'level'), ('CHeartMiniboss', 'level'), ('CDettlaffColumn', 'level'),
              ('W3MonsterHuntNPC', 'level')}
PROP_ADDS = {('CNewNPC', 'isMonsterType_Group'), ('CInventoryDefinitionEntry', 'isLootable'),
             ('CR4LootParam', 'usedContainersMin'), ('CR4LootParam', 'usedContainersMax'),
             ('CR4LootParam', 'overrideInherited')}
ARRAYS = {('CEntityTemplate', 'templateParams'), ('CInventoryDefinition', 'entries'),
          ('CAIMonsterReactionsTreeParams', 'reactions')}
ROOTS = {'CR4LootParam', 'CInventoryDefinition', 'CInventoryDefinitionEntry',
         'CAIActionMonsterBumpTree', 'CAIActionMonsterPlayerPresence', 'CAIActionMonsterRain'}


class Ops:
    """Edits applied to one CR2W and recorded for replay."""
    def __init__(self, f):
        self.f = f
        self.n0 = len(f.names)
        self.i0 = len(f.imports)
        self.c0 = len(f.chunks)
        self.sets = []

    def set(self, ci, pname, ptype, value):
        f = self.f
        ch = f.chunks[ci]
        ni, ti = f.name_index(pname), f.name_index(ptype)
        for pr in ch.props:
            if pr.name == ni:
                pr.type, pr.value = ti, value
                break
        else:
            ch.props.append(cr2wedit.Prop(ni, ti, value))
        self.sets.append([ci, pname, ptype, value.hex()])

    def record(self):
        f = self.f
        if len(f.names) == self.n0 and len(f.imports) == self.i0 and len(f.chunks) == self.c0 and not self.sets:
            return None
        return {'names': f.names[self.n0:],
                'imports': [[f.cstr(so), f.names[ci], fl] for so, ci, fl in f.imports[self.i0:]],
                'chunks': [[f.names[c.cls], c.flags, c.parent, c.template, c.data().hex()] for c in f.chunks[self.c0:]],
                'sets': self.sets}


def decoded(f):
    out = []
    for c in f.chunks:
        d = {}
        for pr in c.props:
            try:
                d[f.names[pr.name]] = (f.names[pr.type], cr2wval.decode_prop(f, pr))
            except cr2wval.Unknown:
                d[f.names[pr.name]] = (f.names[pr.type], None)
        out.append(d)
    return out


def keys(f, dec):
    """Stable key per chunk: class, own name if any, ordinal among equal keys."""
    seen = collections.Counter()
    out = []
    for c, d in zip(f.chunks, dec):
        nm = d.get('name', (None, None))[1]
        k = (f.names[c.cls], repr(nm))
        out.append(k + (seen[k],))
        seen[k] += 1
    return out


def norm(v, f, kmap):
    """Comparable form: handles become the key of the object they point to."""
    if v is None:
        return None
    k = v[0]
    if k == 'h':
        if v[1] > 0:
            return ('h', kmap[v[1] - 1])
        if v[1] < 0:
            so, ci, fl = f.imports[-v[1] - 1]
            return ('hi', f.cstr(so))
        return ('h', None)
    if k == 's':
        if v[1] == 0:
            return ('s', None)
        so, ci, fl = f.imports[v[1] - 1]
        return ('s', f.cstr(so))
    if k == 'a':
        return ('a', tuple(norm(x, f, kmap) for x in v[1]))
    if k in ('t', 'T'):
        return (k, tuple((n, t, norm(x, f, kmap)) for n, t, x in v[1]))
    if k == 'p':
        return ('p', bytes(v[1]))
    return v


def transplant(fs, sdec, skeys, si, ops, vindex, report_lines):
    """Copy chunk si (and the objects it owns) from Spectre into the 5.01 file. Returns the new 1-based handle."""
    fv = ops.f
    todo = [si]
    order = []
    while todo:
        i = todo.pop()
        if i in order:
            continue
        if skeys[i] in vindex and i != si:
            continue  # already in 5.01: point at it
        if any(v is None for _, v in sdec[i].values()):
            raise cr2wval.Unknown('undecodable property in %s' % fs.names[fs.chunks[i].cls])
        if fs.chunks[i].tail or fs.chunks[i].template:
            raise cr2wval.Unknown('chunk with tail data')
        order.append(i)
        for _, v in sdec[i].values():
            for h in cr2wval.refs(v, []):
                todo.append(h - 1)
    base = len(fv.chunks)
    newidx = {i: base + n for n, i in enumerate(order)}

    def handle(h):
        if h > 0:
            i = h - 1
            if i in newidx:
                return newidx[i] + 1
            return vindex[skeys[i]] + 1
        if h < 0:
            so, ci, fl = fs.imports[-h - 1]
            return -fv.import_index(fs.cstr(so), fs.names[ci], fl)
        return 0

    def soft(s):
        if s == 0:
            return 0
        so, ci, fl = fs.imports[s - 1]
        return fv.import_index(fs.cstr(so), fs.names[ci], fl)

    for i in order:
        c = fs.chunks[i]
        props = []
        for pr in c.props:
            pname, ptype = fs.names[pr.name], fs.names[pr.type]
            val = cr2wval.write(fv, ptype, sdec[i][pname][1], handle, soft)
            props.append(cr2wedit.Prop(fv.name_index(pname), fv.name_index(ptype), val))
        parent = 0 if c.parent == 0 else handle(c.parent)
        nc = cr2wedit.Chunk.__new__(cr2wedit.Chunk)
        nc.cls, nc.flags, nc.parent, nc.template = fv.name_index(fs.names[c.cls]), c.flags, parent, 0
        nc.lead, nc.props, nc.tail = c.lead, props, b''
        fv.chunks.append(nc)
        report_lines.append('      + %s' % fs.names[c.cls])
    return newidx[si] + 1


def merge_level(fs, fb, fv, old, lines):
    ops = Ops(fv)
    sdec, bdec, vdec = decoded(fs), decoded(fb), decoded(fv)
    sk, bk, vk = keys(fs, sdec), keys(fb, bdec), keys(fv, vdec)
    bindex = {k: i for i, k in enumerate(bk)}
    vindex = {k: i for i, k in enumerate(vk)}
    for si, k in enumerate(sk):
        if k not in bindex or k not in vindex:
            continue
        bi, vi = bindex[k], vindex[k]
        cls = k[0]
        S, B, V = sdec[si], bdec[bi], vdec[vi]
        for pname, (ptype, sv) in list(S.items()):
            key = (cls, pname)
            bt, bv = B.get(pname, (None, None))
            vt, vv = V.get(pname, (None, None))
            ns, nb, nv = norm(sv, fs, sk), norm(bv, fb, bk), norm(vv, fv, vk)
            if pname in B and ns == nb:
                continue
            if key in LISTS and sv and bv and vv and sv[0] == 'a':
                sl, bl, vl = list(ns[1]), list(nb[1]), list(nv[1])
                removed = [] if old else [x for x in bl if x not in sl]
                added = [x for x in sl if x not in bl]
                res = [x for x in vl if x not in removed] + [x for x in added if x not in vl]
                if res == vl:
                    continue
                # values are names or plain numbers; rebuild from the normalized form
                vals = [('n', x[1]) if x[0] in ('n', 'e') else ('p', x[1]) for x in res]
                if any(x[0] not in ('n', 'e', 'p') for x in res):
                    lines.append('   skip list with references %s.%s' % key)
                    continue
                kind = vv[1][0][0] if vv[1] else (sv[1][0][0] if sv[1] else 'n')
                vals = [(kind, x[1]) for x in res]
                ops.set(vi, pname, vt, cr2wval.write(fv, vt, ('a', vals)))
                lines.append('   %s.%s: %s' % (cls, pname, ', '.join(str(x[1]) for x in res)))
            elif key in SCALARS and sv and bv and vv and nv == nb and sv[0] in ('n', 'e', 'p') and vt == ptype:
                ops.set(vi, pname, vt, cr2wval.write(fv, vt, sv))
                lines.append('   %s.%s: %s -> %s' % (cls, pname, bv[1], sv[1]))
            elif pname not in B and pname not in V and sv and not cr2wval.refs(sv, []) and \
                    (key in LEVEL_ADDS or (key in PROP_ADDS and not old)):
                ops.set(vi, pname, ptype, cr2wval.write(fv, ptype, sv))
                lines.append('   + %s.%s = %s' % (cls, pname, struct.unpack('<i', sv[1])[0] if ptype == 'Int32' else sv[1]))
                if key in LEVEL_ADDS and 'levelFakeAddon' in V and 'levelFakeAddon' not in S:
                    ops.set(vi, 'levelFakeAddon', V['levelFakeAddon'][0], struct.pack('<i', 0))
                    lines.append('   %s.levelFakeAddon -> 0' % cls)
            elif key in ARRAYS and sv and vv and not old:
                added = [h for h in cr2wval.refs(sv, []) if sk[h - 1] not in bindex and sk[h - 1][0] in ROOTS]
                if not added:
                    continue
                elems = list(vv[1])
                for h in added:
                    try:
                        nh = transplant(fs, sdec, sk, h - 1, ops, vindex, lines)
                    except cr2wval.Unknown as e:
                        lines.append('   skip %s: %s' % (sk[h - 1][0], e))
                        continue
                    elems.append(('h', nh))
                    lines.append('   %s.%s += %s' % (cls, pname, sk[h - 1][0]))
                ops.set(vi, pname, vt, cr2wval.write(fv, vt, ('a', elems)))
    return ops


def nested(f):
    for ci, c in enumerate(f.chunks):
        for pr in c.props:
            if f.names[pr.name] == 'flatCompiledData' and pr.value[4:8] == b'CR2W':
                return ci, pr
    return None, None


js = json.loads(jpath.read_text(encoding='utf-8'))
files = js['files']
stats = collections.Counter()
for n in sorted(files):
    bp = root / 'v132' / n
    if not bp.exists():
        continue
    entry = files[n]
    vdata = bytearray((root / 'vanilla501' / n).read_bytes())
    for off, old_hex, new_hex, note in entry['patches']:
        vdata[off:off + len(old_hex) // 2] = bytes.fromhex(new_hex)
    sdata = (root / 'spectre' / n).read_bytes()
    try:
        fs, fb, fv = cr2wedit.CR2W(sdata), cr2wedit.CR2W(bp.read_bytes()), cr2wedit.CR2W(bytes(vdata))
    except ValueError as e:
        report.write('== %s: cannot read (%s)\n' % (n, e))
        continue
    old = fs.version == 162
    lines = []
    outer = merge_level(fs, fb, fv, old, lines)
    rec = {}
    sci, spr = nested(fs)
    bci, bpr = nested(fb)
    vci, vpr = nested(fv)
    if spr and bpr and vpr:
        gs, gb, gv = cr2wedit.CR2W(spr.value[4:]), cr2wedit.CR2W(bpr.value[4:]), cr2wedit.CR2W(vpr.value[4:])
        lines.append('  compiled:')
        inner = merge_level(gs, gb, gv, old, lines)
        r = inner.record()
        if r:
            rec['nested'] = r
            blob = gv.write()
            vpr.value = struct.pack('<I', len(blob)) + blob
        else:
            lines.pop()
    else:
        if lines and lines[-1] == '  compiled:':
            lines.pop()
    r = outer.record()
    if r:
        rec['outer'] = r
    if rec:
        out = fv.write()
        entry['ops'] = rec
        entry['sha256_out'] = hashlib.sha256(out).hexdigest()
        (root / 'phase2').joinpath(n).parent.mkdir(parents=True, exist_ok=True)
        (root / 'phase2' / n).write_bytes(out)
        stats['files'] += 1
        report.write('== %s%s\n' % (n, ' (old CR2W 162)' if old else ''))
        report.write('\n'.join(lines) + '\n')
    else:
        entry.pop('ops', None)
        entry.pop('sha256_out', None)
print(dict(stats))
with open(jpath, 'w', encoding='utf-8', newline='\n') as f:
    f.write('{\n "files": {\n')
    items = sorted(files.items())
    for i, (k, v) in enumerate(items):
        f.write('  %s: {"sha256": "%s", "patches": [' % (json.dumps(k), v['sha256']))
        if v['patches']:
            f.write('\n' + ',\n'.join('   ' + json.dumps(p, ensure_ascii=False) for p in v['patches']) + '\n  ')
        f.write(']')
        if 'ops' in v:
            f.write(',\n   "sha256_out": "%s",\n   "ops": %s' % (v['sha256_out'], json.dumps(v['ops'], ensure_ascii=False)))
        f.write('}' + (',' if i < len(items) - 1 else '') + '\n')
    f.write(' }\n}\n')
