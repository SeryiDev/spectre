"""Decode and re-encode every property of <work>/<folder> with cr2wval; prints mismatches and the types it cannot decode.

usage: test_values.py <work dir> vanilla501|spectre
"""
import sys,pathlib,cr2wedit,cr2wval,collections
A=pathlib.Path(sys.argv[1])
ok=0; mism=collections.Counter(); unk=collections.Counter()
def test(f):
    global ok
    for c in f.chunks:
        for pr in c.props:
            typ=f.names[pr.type]
            try: v=cr2wval.decode_prop(f,pr)
            except cr2wval.Unknown as e: unk[(f.names[c.cls],f.names[pr.name],typ)]+=1; continue
            n0=len(f.names)
            w=cr2wval.write(f,typ,v)
            assert len(f.names)==n0
            if w==pr.value: ok+=1
            else: mism[typ]+=1
            if f.names[pr.name]=='flatCompiledData' and pr.value[4:8]==b'CR2W':
                test(cr2wedit.CR2W(pr.value[4:]))
for p in sorted((A/sys.argv[2]).rglob('*')):
    if p.is_file():
        try: f=cr2wedit.CR2W(p.read_bytes())
        except ValueError: continue
        test(f)
print('ok',ok,'mismatch',sum(mism.values()),mism.most_common(5))
print('unknown',sum(unk.values())); [print('  ',k,v) for k,v in unk.most_common(25)]
