"""File-independent view of CR2W objects, to compare the same resource across game versions.

Objects are matched by a key (class, own name, ordinal among equal keys). Values are decoded
with cr2wval: names become strings, handles become the key of the object they point to,
imports become their path. A value that cannot be decoded is compared as raw bytes, which can
only make two files look different, never the same.
"""
import collections, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import cr2wedit, cr2wval


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
    seen = collections.Counter()
    out = []
    for c, d in zip(f.chunks, dec):
        nm = d.get('name', (None, None))[1]
        k = (f.names[c.cls], repr(nm))
        out.append(k + (seen[k],))
        seen[k] += 1
    return out


def norm(v, f, kmap):
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


SKIP = {'guid', 'idTag', 'cachedConnections'}


def view(f):
    """{object key: {property: comparable value}}, with flatCompiledData compared as its own view."""
    dec = decoded(f)
    ks = keys(f, dec)
    out = {}
    for ci, (k, d) in enumerate(zip(ks, dec)):
        props = {}
        for pr in f.chunks[ci].props:
            pname = f.names[pr.name]
            if pname in SKIP:
                continue
            if pname == 'flatCompiledData' and pr.value[4:8] == b'CR2W':
                props[pname] = ('nested', view(cr2wedit.CR2W(pr.value[4:])))
                continue
            t, v = d[pname]
            props[pname] = (t, norm(v, f, ks)) if v is not None else (t, ('raw', bytes(pr.value)))
        out[k] = props
    return out


def same(a: bytes, b: bytes) -> bool:
    return view(cr2wedit.CR2W(a)) == view(cr2wedit.CR2W(b))
