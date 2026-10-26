"""Patch the ActionScript of the 5.01 skill menu (panel_character_dupe.redswf).

The panel is a GFX movie inside a .redswf: a CFX block (zlib) followed by zero padding, then the rest of the
file. The patched movie must fit in that same space, so it is compressed with zopfli (5 iterations), which
leaves about 14 KB free; Python's plain zlib does not fit.

    python tools\\panel\\patch_panel.py export   [--out DIR]   export every script of the current panel
    python tools\\panel\\patch_panel.py patch    [--scripts DIR] import the scripts in DIR and write the panel

--scripts defaults to tools\\panel\\as: a folder with the layout FFDec exports (scripts\\red\\game\\...\\X.as).
Only the classes in it are replaced. tools\\panel\\as holds every class Spectre changed, so patching with it
again gives the same panel.
--redswf defaults to bundle\\files\\gameplay\\gui_new\\swf\\character\\panel_character_dupe.redswf.
Before writing, the old file is copied to tools\\panel\\backup. After writing, the movie is read back and
compared. Rebuild the bundle afterwards (pack-release.ps1 -Rebuild) and update bundle\\bundle.sha256.

Needs FFDec (ffdec-cli.exe) and the zopfli Python module (pip install zopfli).
"""
import argparse, datetime, pathlib, shutil, struct, subprocess, sys, tempfile, zlib

ROOT = pathlib.Path(__file__).resolve().parents[2]
DEFAULT_REDSWF = ROOT / 'bundle/files/gameplay/gui_new/swf/character/panel_character_dupe.redswf'
DEFAULT_SCRIPTS = ROOT / 'tools/panel/as'
DEFAULT_FFDEC = pathlib.Path(r'C:\Program Files (x86)\FFDec\ffdec-cli.exe')


def find_movie(data):
    """Start of the CFX block, its version byte, the movie body, and the room up to the next data."""
    start = data.find(b'CFX')
    if start < 0:
        raise SystemExit('no CFX block in the .redswf')
    version = data[start + 3:start + 4]
    length = struct.unpack_from('<I', data, start + 4)[0]
    z = zlib.decompressobj()
    body = z.decompress(data[start + 8:])
    if len(body) + 8 != length:
        print('note: the CFX header says %d bytes, the movie has %d' % (length, len(body) + 8))
    end = len(data) - len(z.unused_data)
    nxt = end
    while nxt < len(data) and data[nxt] == 0:
        nxt += 1
    return start, version, body, nxt - start


def write_gfx(path, version, body):
    path.write_bytes(b'GFX' + version + struct.pack('<I', len(body) + 8) + body)


def ffdec(exe, *args):
    r = subprocess.run([str(exe), *args], capture_output=True, text=True)
    out = (r.stdout or '') + (r.stderr or '')
    if r.returncode != 0:
        print(out)
        raise SystemExit('FFDec failed')
    return out


def cmd_export(a):
    data = pathlib.Path(a.redswf).read_bytes()
    _, version, body, _ = find_movie(data)
    with tempfile.TemporaryDirectory() as tmp:
        gfx = pathlib.Path(tmp) / 'panel.gfx'
        write_gfx(gfx, version, body)
        ffdec(a.ffdec, '-export', 'script', str(a.out), str(gfx))
    print('exported to', a.out)


def cmd_patch(a):
    import zopfli.zlib
    redswf = pathlib.Path(a.redswf)
    scripts = pathlib.Path(a.scripts)
    if not (scripts / 'scripts').is_dir():
        raise SystemExit('%s has no scripts folder (FFDec layout)' % scripts)
    data = bytearray(redswf.read_bytes())
    start, version, body, room = find_movie(bytes(data))
    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)
        src, dst = tmp / 'in.gfx', tmp / 'out.gfx'
        write_gfx(src, version, body)
        print(ffdec(a.ffdec, '-importScript', str(src), str(dst), str(scripts)).strip())
        if not dst.exists():
            raise SystemExit('FFDec wrote no movie')
        g = dst.read_bytes()
    new_body = g[8:]
    comp = zopfli.zlib.compress(new_body, numiterations=5)
    if zlib.decompress(comp) != new_body:
        raise SystemExit('zopfli round trip failed')
    block = b'CFX' + version + struct.pack('<I', len(new_body) + 8) + comp
    if len(block) > room:
        raise SystemExit('the patched movie does not fit: %d bytes, %d of room' % (len(block), room))
    backup = ROOT / 'tools/panel/backup'
    backup.mkdir(parents=True, exist_ok=True)
    shutil.copy2(redswf, backup / ('%s.%s' % (redswf.name, datetime.datetime.now().strftime('%Y%m%d-%H%M%S'))))
    data[start:start + room] = block + b'\x00' * (room - len(block))
    redswf.write_bytes(bytes(data))
    _, _, check, _ = find_movie(redswf.read_bytes())
    if check != new_body:
        raise SystemExit('read back failed')
    print('patched %s: %d bytes used of %d (%d free)' % (redswf.name, len(block), room, room - len(block)))


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('command', choices=['export', 'patch'])
    p.add_argument('--redswf', default=str(DEFAULT_REDSWF))
    p.add_argument('--scripts', default=str(DEFAULT_SCRIPTS))
    p.add_argument('--out', default=str(ROOT / 'tools/panel/export'))
    p.add_argument('--ffdec', default=str(DEFAULT_FFDEC))
    a = p.parse_args()
    {'export': cmd_export, 'patch': cmd_patch}[a.command](a)


if __name__ == '__main__':
    main()
