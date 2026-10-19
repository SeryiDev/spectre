"""Read and write every CR2W file (and its flatCompiledData) of <work>/<folder>; prints how many come out byte-identical.

usage: test_roundtrip.py <work dir> vanilla501|spectre
"""
import sys,pathlib,cr2wedit,collections
A=pathlib.Path(sys.argv[1])
ok=bad=0; nok=nbad=0; reasons=collections.Counter()
for p in sorted((A/sys.argv[2]).rglob('*')):
    if not p.is_file(): continue
    d=p.read_bytes()
    try:
        f=cr2wedit.CR2W(d); w=f.write()
    except Exception as e:
        bad+=1; reasons[str(e)[:60]]+=1; continue
    if w==d: ok+=1
    else:
        bad+=1; i=next((i for i in range(min(len(w),len(d))) if w[i]!=d[i]),-1); reasons['diff at %d len %d/%d'%(i,len(w),len(d))]+=1
    for c in f.chunks:
        for pr in c.props:
            if f.names[pr.name]=='flatCompiledData' and pr.value[4:8]==b'CR2W':
                blob=pr.value[4:]
                try:
                    g=cr2wedit.CR2W(blob); w2=g.write()
                    if w2==blob: nok+=1
                    else: nbad+=1; i=next((i for i in range(min(len(w2),len(blob))) if w2[i]!=blob[i]),-1); reasons['nested diff at %d'%i]+=1
                except Exception as e:
                    nbad+=1; reasons['nested '+str(e)[:50]]+=1
print(sys.argv[2],'roundtrip ok',ok,'bad',bad,'nested ok',nok,'bad',nbad); print(reasons.most_common(6))
