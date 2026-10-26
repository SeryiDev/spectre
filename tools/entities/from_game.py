"""Write the game-derived files of the bundle from The Witcher 3 5.01.

usage: from_game.py <The Witcher 3 5.01 folder>

entities501.json: each file is read from the game (checked by SHA-256), gets Spectre's
value patches and then the structural edits (cr2w_ops.py), is checked by SHA-256 again
and written to bundle/files.
alchemy501.json: "files" are the 5.01 alchemy XML, written as they are to
bundle/alchemy501/xml; "other" get their ops and go to bundle/alchemy501/files.

Only needed after a game patch or after changing entities501.json / alchemy501.json.
The bundle build itself does not read the game.
"""
import hashlib
import json
import sys
import zlib
from pathlib import Path

import lz4.block

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import cr2w_ops  # noqa: E402
import game501  # noqa: E402

BUNDLE = HERE.parent.parent / "bundle"


def read_game(game: Path, want: dict, listed_in: str) -> dict:
    """The files of want ({name: sha256}) from the 5.01 game bundles, checked by SHA-256."""
    found = {}
    for b in sorted((game / "content").rglob("*.bundle")):
        hits = [e for e in game501.entries(b) if e[0] in want and e[0] not in found]
        if not hits:
            continue
        with open(b, "rb") as f:
            for name, off, u, z, comp in hits:
                f.seek(off)
                raw = f.read(z)
                data = raw if comp == 0 else zlib.decompress(raw) if comp == 1 else \
                    lz4.block.decompress(raw, uncompressed_size=u)
                if hashlib.sha256(data).hexdigest() == want[name]:
                    found[name] = data
    missing = sorted(set(want) - set(found))
    if missing:
        raise SystemExit(f"{len(missing)} files of {listed_in} are not in the 5.01 game at {game} "
                         f"(or are a different version), first: {missing[0]}")
    return found


def write(path: Path, data: bytes):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    game = Path(sys.argv[1])

    want = json.loads((HERE / "entities501.json").read_text(encoding="utf-8"))["files"]
    found = read_game(game, {n: w["sha256"] for n, w in want.items()}, "entities501.json")
    for name, data in found.items():
        buf = bytearray(data)
        for off, old, new, note in want[name]["patches"]:
            old, new = bytes.fromhex(old), bytes.fromhex(new)
            if buf[off:off + len(old)] != old or len(old) != len(new):
                raise SystemExit(f"patch does not fit {name} at {off} ({note})")
            buf[off:off + len(new)] = new
        data = bytes(buf)
        if "ops" in want[name]:
            data = cr2w_ops.replay(data, want[name]["ops"])
            if hashlib.sha256(data).hexdigest() != want[name]["sha256_out"]:
                raise SystemExit(f"structural edits of {name} do not give the expected file")
        write(BUNDLE / "files" / name, data)

    spec = json.loads((HERE / "alchemy501.json").read_text(encoding="utf-8"))
    xml = read_game(game, spec["files"], "alchemy501.json")
    for name, data in xml.items():
        write(BUNDLE / "alchemy501" / "xml" / name, data)
    other = spec["other"]
    found = read_game(game, {n: o["sha256"] for n, o in other.items()}, "alchemy501.json")
    for name, o in other.items():
        data = cr2w_ops.replay(found[name], o["ops"]) if "ops" in o else found[name]
        write(BUNDLE / "alchemy501" / "files" / name, data)
    print(f"Wrote {len(want)} files to bundle/files and {len(xml) + len(other)} to bundle/alchemy501.")


if __name__ == "__main__":
    main()
