"""Build Spectre's gameplay bundle for The Witcher 3 5.01.

    python bundle/build_bundle.py --base "<Spectre v0.93 release folder or zip>" --game "<The Witcher 3 folder>"

Inputs:
  base               blob0.bundle from the published Spectre v0.93 release
                     (mods/mod000Spectre/content). Checked by SHA-256.
  game               The Witcher 3 5.01 install. The entities, scenes and quest files
                     of v0.93 were made from old game versions; the ones listed in
                     bundle/entities501.json are taken from the 5.01 game instead
                     (checked by SHA-256) with Spectre's edits put back: value patches in
                     place, then added abilities, objects and properties (cr2w_ops.py).
  bundle/xml/        XML that replace the v0.93 copies (rebased onto 5.01).
  bundle/files/      Files that v0.93 does not have (added at the end), and non-XML
                     files that replace the v0.93 copy (popup_loot.redswf).
  bundle/metadata.store
                     Index the game reads to find each file. It already lists
                     every file above. The build only rewrites sizes and offsets.

Output (default build/mod000Spectre/content):
  blob0.bundle, metadata.store

--alchemy501 builds the variant that turns Spectre's alchemy off,
by default in build/mod000Spectre-alchemy501/content. The alchemy XML listed in bundle/alchemy501.json
come from the 5.01 game (checked by SHA-256), plus every element only Spectre's copy has (Mutation
Trigger, its mutagens, the lesser mutagen and alcohol recipes), so saves keep those items.
The files under "other" replace Spectre's copy: the 5.01 alchemy panel, and r4alchemy.menu
pointing at CR4VanillaAlchemyMenu (the normal bundle ships the unchanged 5.01 copy).
effects_potions.xml also gets the marker ability spectre_alchemy_501. The file list is the same, so
the same metadata.store serves both.

Every XML in the bundle is written as UTF-8 with CRLF line ends, the comment
fixes 5.01 needs are applied, and each payload sits on a 4096-byte boundary.
5.01 hangs on a bundle packed without that alignment.

A new file in bundle/files/ needs a record in bundle/metadata.store first.
Regenerate the store with w3edit (tools/w3edit) from a bundle that has the file.

Requires: pip install lz4
"""
import argparse
import hashlib
import io
import json
import re
import struct
import sys
import zipfile
import zlib
from pathlib import Path
from xml.etree import ElementTree as ET

import lz4.block

import cr2w_ops

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
XML_DIR = HERE / "xml"
FILES_DIR = HERE / "files"
META_TEMPLATE = HERE / "metadata.store"
ENTITIES = HERE / "entities501.json"
ALCHEMY501 = HERE / "alchemy501.json"
DEFAULT_OUT = ROOT / "build" / "mod000Spectre" / "content"
DEFAULT_OUT_501 = ROOT / "build" / "mod000Spectre-alchemy501" / "content"

# Marks the alchemy 5.01 variant; the scripts look for it with IsAbilityDefined.
ALCHEMY_MARKER = '<ability name="spectre_alchemy_501" />'

# Elements the variant takes from Spectre although 5.01 has them too. WolfHourEffect: Spectre's
# Wolf Hour gives stats; the 5.01 ability has none, and Spectre's effect turns off without them.
SPECTRE_KEEPS = {("ability", "WolfHourEffect")}

BASE_SHA256 = "69c899d9bc9f1e4057bd5e82a38fe403e6509474ad931476ab0c7fd762dab01e"
BASE_IN_ZIP = "mods/mod000Spectre/content/blob0.bundle"

ENTRY = 320
GAME_ENTRY = 304  # index entry size in the 5.01 game bundles
NAME_LEN = 276
ALIGN = 4096
LZ4 = 4
LZ4HC = 5

# Bundle entries the metadata index does not list. Spectre v0.93 ships this
# file without a record too.
UNINDEXED_OK = {"characters/npc_entities/crowd_npc/succubus/succubus_censored.w2ent"}


# ---------------------------------------------------------------- bundle ---

def read_entries(blob: bytes):
    out = []
    pos = 32
    while pos + ENTRY <= len(blob):
        raw = blob[pos:pos + NAME_LEN].split(b"\x00", 1)[0]
        if not raw or any(c < 32 or c > 126 for c in raw):
            break
        name = raw.decode("ascii")
        if "/" not in name and "\\" not in name:
            break
        u, z = struct.unpack_from("<II", blob, pos + NAME_LEN)
        off = struct.unpack_from("<Q", blob, pos + NAME_LEN + 8)[0]
        crc, comp = struct.unpack_from("<II", blob, pos + 312)
        out.append({"name": name.replace("\\", "/"), "raw_name": raw, "entry": blob[pos:pos + ENTRY],
                    "u": u, "z": z, "off": off, "crc": crc, "comp": comp})
        pos += ENTRY
    return out


def unpack(blob: bytes, e) -> bytes:
    chunk = blob[e["off"]:e["off"] + e["z"]]
    if e["comp"] in (LZ4, LZ4HC):
        return lz4.block.decompress(chunk, uncompressed_size=e["u"])
    if e["comp"] == 0:
        return chunk
    raise SystemExit(f"compression {e['comp']} not supported: {e['name']}")


def new_entry(name: str) -> bytes:
    raw = name.replace("/", "\\").encode("ascii")
    if len(raw) >= NAME_LEN:
        raise SystemExit(f"path too long for a bundle entry: {name}")
    return raw + b"\x00" * (ENTRY - len(raw))


# ------------------------------------------------------------------- xml ---

def clean_xml(text: str) -> str:
    """5.01 stops reading a file at an illegal comment. Longer patterns first."""
    text = text.replace("<!-- ---modWBC--- ADDED CONTENT -->", "<!-- modWBC end added -->")
    text = text.replace("<!-- +++modWBC+++ ADDED CONTENT -->", "<!-- modWBC start added -->")
    text = text.replace("<!-- ---modWBC--- -->", "<!-- modWBC end -->")
    text = text.replace("<!-- +++modWBC+++ -->", "<!-- modWBC start -->")
    text = text.replace("</item>--->", "</item>-->")
    text = text.replace(
        ' player_level_min="0" player_level_max="100" player_level_min="0" player_level_max="0"',
        ' player_level_min="0" player_level_max="100"',
    )
    return fix_comment_dashes(text)


def fix_comment_dashes(text: str) -> str:
    out = []
    i = 0
    while True:
        start = text.find("<!--", i)
        if start < 0:
            out.append(text[i:])
            break
        end = text.find("-->", start + 4)
        if end < 0:
            out.append(text[i:])
            break
        body = text[start + 4:end]
        while "--" in body:
            body = body.replace("--", "-")
        out.append(text[i:start + 4])
        out.append(body)
        out.append("-->")
        i = end + 3
    return "".join(out)


def decode(raw: bytes) -> str:
    if raw[:2] in (b"\xff\xfe", b"\xfe\xff"):
        return raw.decode("utf-16")
    return raw.decode("utf-8-sig")


def xml_payload(text: str, name: str, crlf: bool) -> bytes:
    for q in ('"', "'"):
        for enc in ("UTF-16", "utf-16"):
            text = text.replace(f"encoding={q}{enc}{q}", 'encoding="UTF-8"')
    if crlf:
        text = text.replace("\r\n", "\n").replace("\r", "\n").replace("\n", "\r\n")
    text = clean_xml(text)
    if "<<<<<<<" in text or ">>>>>>>" in text:
        raise SystemExit(f"merge conflict marker in {name}")
    body = text.lstrip("﻿")
    check = body
    if check.lstrip().startswith("<?xml"):
        check = check[check.find("?>") + 2:]
    try:
        ET.fromstring(check.encode("utf-8"))
    except ET.ParseError as exc:
        raise SystemExit(f"xml will not parse {name}: {exc}")
    return b"\xef\xbb\xbf" + body.encode("utf-8")


# -------------------------------------------------------------- metadata ---

def vlq(buf, p):
    x = buf[p]
    v = x & 0x3F
    shift = 6
    p += 1
    if x & 0x40:
        while True:
            x = buf[p]
            p += 1
            v |= (x & 0x7F) << shift
            shift += 7
            if not x & 0x80:
                break
    return v, p


class Meta:
    """metadata.store version 6: header, strings, files (32 bytes), entries (20 bytes), bundles (24 bytes)."""

    def __init__(self, data: bytes):
        self.m = bytearray(data)
        magic, version = struct.unpack_from("<4sI", self.m, 0)
        if magic != b"\x03VTM" or version != 6:
            raise SystemExit("bundle/metadata.store is not a version 6 metadata store")
        n, p = vlq(self.m, 16)
        self.strings = bytes(self.m[p:p + n])
        p += n
        self.file_count, self.files_at = vlq(self.m, p)
        self.entry_count, self.entries_at = vlq(self.m, self.files_at + 32 * self.file_count)
        end = self.entries_at + 20 * self.entry_count
        bundles, p = vlq(self.m, end)
        if bundles != 2:
            raise SystemExit(f"expected one bundle in the metadata, found {bundles - 1}")
        self.bundle_at = p + 24

    def string_at(self, off: int) -> str:
        a = self.strings.rfind(b"\x00", 0, off) + 1
        b = self.strings.find(b"\x00", off)
        return self.strings[a:b].decode("ascii").replace("\\", "/")

    def files(self):
        for k in range(1, self.file_count):
            at = self.files_at + 32 * k
            name_off, _, z, u, entry_id, comp = struct.unpack_from("<6I", self.m, at)
            yield k, at, self.string_at(name_off), entry_id

    def patch(self, placed: dict, index_size: int, bundle_len: int) -> list:
        seen = set()
        for k, at, name, entry_id in self.files():
            if name not in placed:
                raise SystemExit(f"metadata lists {name}, the bundle does not have it")
            p = placed[name]
            struct.pack_into("<II", self.m, at + 8, p["z"], p["u"])
            struct.pack_into("<I", self.m, at + 20, p["comp"])
            row = self.entries_at + 20 * entry_id
            file_id, bundle_id = struct.unpack_from("<II", self.m, row)
            if file_id != k or bundle_id != 1:
                raise SystemExit(f"metadata entry row for {name} does not point back at it")
            struct.pack_into("<II", self.m, row + 8, p["off"], p["z"])
            seen.add(name)
        struct.pack_into("<II", self.m, 8,
                         max(p["z"] for p in placed.values()),
                         max(p["u"] for p in placed.values()))
        struct.pack_into("<II", self.m, self.bundle_at + 12,
                         align(bundle_len) - index_size, index_size)
        return sorted(set(placed) - seen)


# ----------------------------------------------------------------- build ---

def align(n: int) -> int:
    return (n + ALIGN - 1) & ~(ALIGN - 1)


def load_base(path: Path) -> bytes:
    if path.is_file() and path.suffix.lower() == ".zip":
        with zipfile.ZipFile(path) as zf:
            names = {n.replace("\\", "/").lower(): n for n in zf.namelist()}
            hit = [n for k, n in names.items() if k.endswith(BASE_IN_ZIP.lower())]
            if not hit:
                raise SystemExit(f"{path} has no {BASE_IN_ZIP}")
            data = zf.read(hit[0])
    else:
        candidates = [path / BASE_IN_ZIP, path / "content" / "blob0.bundle", path / "blob0.bundle", path]
        found = next((c for c in candidates if c.is_file()), None)
        if not found:
            raise SystemExit(f"no Spectre v0.93 blob0.bundle under {path}")
        data = found.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if digest != BASE_SHA256:
        raise SystemExit(f"base bundle is not the Spectre v0.93 release (sha256 {digest})")
    return data


def read_game(game: Path, want: dict, listed_in: str) -> dict:
    """Read the files of want ({name: sha256}) from the 5.01 game bundles, checked by SHA-256."""
    found = {}
    for b in sorted((game / "content").rglob("*.bundle")):
        with open(b, "rb") as f:
            head = f.read(32)
            if head[:8] != b"POTATO70":
                continue
            index_size = struct.unpack_from("<I", head, 16)[0]
            index = head + f.read(index_size)
            for pos in range(32, 32 + index_size - GAME_ENTRY + 1, GAME_ENTRY):
                name = index[pos:pos + 256].split(b"\x00", 1)[0].decode("ascii", "replace")
                name = name.replace("\\", "/").lower()
                if name not in want or name in found:
                    continue
                off = struct.unpack_from("<Q", index, pos + 272)[0]
                u, z = struct.unpack_from("<II", index, pos + 280)
                comp = struct.unpack_from("<I", index, pos + 292)[0]
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


def game_files(game: Path, want: dict) -> dict:
    """Read the 5.01 copies of the files in entities501.json from the game bundles,
    check them by SHA-256, apply Spectre's value patches, then the structural edits
    ("ops", see cr2w_ops.py) and check the result by SHA-256."""
    found = read_game(game, {n: w["sha256"] for n, w in want.items()}, "entities501.json")
    out = {}
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
        out[name] = data
    return out


def tree(root: Path) -> dict:
    if not root.is_dir():
        return {}
    return {p.relative_to(root).as_posix().lower(): p for p in sorted(root.rglob("*")) if p.is_file()}


# ------------------------------------------------------------- alchemy 501 ---

COMMENT = re.compile(r"<!--.*?-->", re.S)


def masked(text: str) -> str:
    """The text with its comments blanked out, so offsets stay the same."""
    return COMMENT.sub(lambda m: " " * len(m.group(0)), text)


def xml_keys(text: str) -> list:
    """(containers, tag, name) of every named element, as ElementTree reads the file."""
    body = masked(text).lstrip("﻿")
    if body.lstrip().startswith("<?xml"):
        body = body[body.find("?>") + 2:]
    keys = []

    def walk(node, chain):
        for child in node:
            name = child.get("name") or child.get("name_name")
            if name and chain:
                keys.append((tuple(chain), child.tag, name))
            else:
                walk(child, chain + [child.tag])

    walk(ET.fromstring(body.encode("utf-8")), [])
    return keys


def container(text: str, tag: str, file: str) -> tuple:
    """Start and end of the inside of the only <tag> container of the file."""
    plain = masked(text)
    opens = list(re.finditer(r"<%s(\s[^>]*)?>" % tag, plain))
    closes = list(re.finditer(r"</%s\s*>" % tag, plain))
    if len(opens) != 1 or len(closes) != 1:
        raise SystemExit(f"{file}: <{tag}> is not a single container")
    return opens[0].end(), closes[0].start()


def add_to_container(text: str, tag: str, block: str, file: str) -> str:
    end = container(text, tag, file)[1]
    return text[:end] + "\t" + block + "\r\n" + text[end:]


def alchemy501_xml(text501: str, spectre: str, file: str) -> str:
    """The 5.01 file plus every element that only Spectre's copy has, in the same container,
    so a save keeps Spectre's items (Mutation Trigger, its mutagens and recipes)."""
    def element(tag, name):
        return re.compile(r'<%s\b(?=[^>]*\bname(?:_name)?\s*=\s*"%s")[^>]*?(?:/>|>.*?</%s\s*>)'
                          % (tag, re.escape(name), tag), re.S)

    for tag, name in SPECTRE_KEEPS:
        hits = list(element(tag, name).finditer(masked(text501)))
        if len(hits) == 1:
            text501 = text501[:hits[0].start()] + text501[hits[0].end():]
    have = set(xml_keys(text501))
    plain = masked(spectre)
    for chain, tag, name in xml_keys(spectre):
        if (chain, tag, name) in have:
            continue
        start, end = container(spectre, chain[-1], file)
        hits = [m for m in element(tag, name).finditer(plain, start, end)]
        if len(hits) != 1:
            raise SystemExit(f"{file}: {len(hits)} copies of <{tag}> {name} in Spectre's file")
        text501 = add_to_container(text501, chain[-1], spectre[hits[0].start():hits[0].end()], file)
    if file.lower().endswith("/effects_potions.xml"):
        text501 = add_to_container(text501, "abilities", ALCHEMY_MARKER, file)
    return text501


def build(base: bytes, game: Path, alchemy501: bool = False):
    entries = read_entries(base)
    names = {e["name"].lower() for e in entries}
    overrides = tree(XML_DIR)
    extras = tree(FILES_DIR)
    want = json.loads(ENTITIES.read_text(encoding="utf-8"))["files"]
    unknown = [n for n in want if n not in names]
    if unknown:
        raise SystemExit(f"entities501.json has files v0.93 does not ship: {unknown}")
    entities = game_files(game, want)
    alchemy, alchemy_other = {}, {}
    if alchemy501:
        spec501 = json.loads(ALCHEMY501.read_text(encoding="utf-8"))
        want501 = spec501["files"]
        unknown = [n for n in want501 if n not in names or n in overrides]
        if unknown:
            raise SystemExit(f"alchemy501.json has files v0.93 does not ship, or that bundle/xml replaces: {unknown}")
        alchemy = read_game(game, want501, "alchemy501.json")
        other = spec501["other"]
        shipped = names | set(tree(FILES_DIR))
        unknown = [n for n in other if n not in shipped]
        if unknown:
            raise SystemExit(f"alchemy501.json other has files the bundle does not ship: {unknown}")
        found = read_game(game, {n: o["sha256"] for n, o in other.items()}, "alchemy501.json")
        alchemy_other = {n: cr2w_ops.replay(found[n], o["ops"]) if "ops" in o else found[n] for n, o in other.items()}
    unknown = [n for n in overrides if n not in names]
    if unknown:
        raise SystemExit(f"bundle/xml has files v0.93 does not ship (put new files in bundle/files): {unknown}")
    clash = [n for n in extras if n in names and n.endswith(".xml")]
    if clash:
        raise SystemExit(f"bundle/files has XML that v0.93 already ships (put XML edits in bundle/xml): {clash}")
    replaced = {n for n in extras if n in names}

    items = []  # (entry bytes, payload, u, crc, comp, name)
    for e in entries:
        key = e["name"].lower()
        if key.endswith(".xml"):
            if key in overrides:
                text = decode(overrides[key].read_bytes())
                payload = xml_payload(text, e["name"], crlf=True)
            elif key in alchemy:
                text = alchemy501_xml(decode(alchemy[key]), decode(unpack(base, e)), e["name"])
                payload = xml_payload(text, e["name"], crlf=True)
            else:
                payload = xml_payload(decode(unpack(base, e)), e["name"], crlf=False)
            comp = lz4.block.compress(payload, store_size=False)
            if lz4.block.decompress(comp, uncompressed_size=len(payload)) != payload:
                raise SystemExit(f"lz4 roundtrip failed {e['name']}")
            items.append((e["entry"], comp, len(payload), zlib.crc32(payload) & 0xFFFFFFFF, e["comp"], e["name"]))
        elif key in replaced or key in entities or key in alchemy_other:
            payload = alchemy_other[key] if key in alchemy_other else                 extras[key].read_bytes() if key in replaced else entities[key]
            comp = lz4.block.compress(payload, store_size=False)
            items.append((e["entry"], comp, len(payload), zlib.crc32(payload) & 0xFFFFFFFF, LZ4, e["name"]))
        else:
            items.append((e["entry"], base[e["off"]:e["off"] + e["z"]], e["u"], e["crc"], e["comp"], e["name"]))
    for key, path in extras.items():
        if key in replaced:
            continue
        payload = alchemy_other[key] if key in alchemy_other else path.read_bytes()
        comp = lz4.block.compress(payload, store_size=False)
        name = path.relative_to(FILES_DIR).as_posix()
        items.append((new_entry(name), comp, len(payload), zlib.crc32(payload) & 0xFFFFFFFF, LZ4, name))

    index_size = len(items) * ENTRY
    out = bytearray(align(32 + index_size))
    out[:32] = base[:32]
    struct.pack_into("<I", out, 16, index_size)
    placed = {}
    for i, (entry, comp, u, crc, ctype, name) in enumerate(items):
        at = 32 + i * ENTRY
        off = len(out)
        out[at:at + ENTRY] = entry
        struct.pack_into("<II", out, at + NAME_LEN, u, len(comp))
        struct.pack_into("<Q", out, at + NAME_LEN + 8, off)
        struct.pack_into("<II", out, at + 312, crc, ctype)
        out.extend(comp)
        out.extend(b"\x00" * (align(len(out)) - len(out)))
        placed[name] = {"off": off, "z": len(comp), "u": u, "comp": ctype}
    struct.pack_into("<I", out, 8, len(out))

    meta = Meta(META_TEMPLATE.read_bytes())
    unindexed = meta.patch(placed, 32 + index_size, len(out))
    extra_unindexed = [n for n in unindexed if n not in UNINDEXED_OK]
    if extra_unindexed:
        raise SystemExit(f"no metadata record for {extra_unindexed}. Regenerate bundle/metadata.store with w3edit.")
    return bytes(out), bytes(meta.m), len(overrides), len(extras), len(entities), len(alchemy) + len(alchemy_other)


def verify(blob: bytes, meta_bytes: bytes) -> int:
    entries = read_entries(blob)
    if struct.unpack_from("<I", blob, 8)[0] != len(blob):
        raise SystemExit("header size does not match the file")
    by_name = {}
    for e in entries:
        if e["off"] % ALIGN:
            raise SystemExit(f"unaligned payload {e['name']}")
        data = unpack(blob, e)
        if len(data) != e["u"] or zlib.crc32(data) & 0xFFFFFFFF != e["crc"]:
            raise SystemExit(f"payload check failed {e['name']}")
        if e["name"].endswith(".xml") and not data.startswith(b"\xef\xbb\xbf"):
            raise SystemExit(f"xml is not UTF-8 {e['name']}")
        by_name[e["name"]] = e
    meta = Meta(meta_bytes)
    for k, at, name, entry_id in meta.files():
        e = by_name[name]
        z, u = struct.unpack_from("<II", meta.m, at + 8)
        off, z2 = struct.unpack_from("<II", meta.m, meta.entries_at + 20 * entry_id + 8)
        if (z, u, off, z2) != (e["z"], e["u"], e["off"], e["z"]):
            raise SystemExit(f"metadata does not match the bundle for {name}")
    return len(entries)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--base", required=True, type=Path,
                    help="Spectre v0.93 release: the zip, the extracted folder, or its blob0.bundle")
    ap.add_argument("--game", required=True, type=Path,
                    help="The Witcher 3 5.01 install folder (the one with content\\content0)")
    ap.add_argument("--out", type=Path, help=f"output folder (default {DEFAULT_OUT}, or {DEFAULT_OUT_501})")
    ap.add_argument("--alchemy501", action="store_true",
                    help="the variant with the 5.01 alchemy data (alchemy501.json) instead of Spectre's")
    args = ap.parse_args()
    if args.out is None:
        args.out = DEFAULT_OUT_501 if args.alchemy501 else DEFAULT_OUT

    blob, meta, n_xml, n_files, n_ent, n_alch = build(load_base(args.base), args.game, args.alchemy501)
    count = verify(blob, meta)
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "blob0.bundle").write_bytes(blob)
    (args.out / "metadata.store").write_bytes(meta)
    print(f"Wrote {args.out}")
    print(f"{count} files, {len(blob) / 1e6:.1f} MB. {n_xml} XML from bundle/xml, {n_files} from bundle/files, "
          f"{n_ent} from the 5.01 game." + (f" Alchemy 5.01 variant: {n_alch} files from the game." if n_alch else ""))


if __name__ == "__main__":
    sys.exit(main())
