"""Build Spectre's gameplay bundle for The Witcher 3 5.01.

    python bundle/build_bundle.py

Every file of the bundle is in this folder. Neither the game nor an older Spectre
release is needed.

  bundle/xml/        Every XML of the bundle.
  bundle/files/      Every other file: entities, scenes, quest files, journals,
                     CSV, menus and Flash panels.
  bundle/metadata.store
                     Index the game reads to find each file. It already lists
                     every file above. The build only rewrites sizes and offsets.

Output (default build/mod000Spectre/content):
  blob0.bundle, metadata.store

--alchemy501 builds the variant that turns Spectre's alchemy off,
by default in build/mod000Spectre-alchemy501/content. bundle/alchemy501/xml has the 5.01 copies
of the alchemy XML; each one gets every element only Spectre's copy in bundle/xml has (Mutation
Trigger, its mutagens, the lesser mutagen and alcohol recipes), so saves keep those items.
bundle/alchemy501/files replace Spectre's copy: the 5.01 alchemy panel, and r4alchemy.menu
pointing at CR4VanillaAlchemyMenu. effects_potions.xml also gets the marker ability
spectre_alchemy_501. The file list is the same, so the same metadata.store serves both.

Every XML in the bundle is written as UTF-8 with CRLF line ends, the comment
fixes 5.01 needs are applied, and each payload sits on a 4096-byte boundary.
5.01 hangs on a bundle packed without that alignment.

A new file needs a record in bundle/metadata.store first.
Regenerate the store with w3edit (tools/w3edit) from a bundle that has the file.

Requires: pip install lz4
"""
import argparse
import re
import struct
import sys
import zlib
from pathlib import Path
from xml.etree import ElementTree as ET

import lz4.block

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
XML_DIR = HERE / "xml"
FILES_DIR = HERE / "files"
ALCHEMY501_XML = HERE / "alchemy501" / "xml"
ALCHEMY501_FILES = HERE / "alchemy501" / "files"
META_TEMPLATE = HERE / "metadata.store"
DEFAULT_OUT = ROOT / "build" / "mod000Spectre" / "content"
DEFAULT_OUT_501 = ROOT / "build" / "mod000Spectre-alchemy501" / "content"

# Marks the alchemy 5.01 variant; the scripts look for it with IsAbilityDefined.
ALCHEMY_MARKER = '<ability name="spectre_alchemy_501" />'

# Elements the variant takes from Spectre although 5.01 has them too. WolfHourEffect: Spectre's
# Wolf Hour gives stats; the 5.01 ability has none, and Spectre's effect turns off without them.
SPECTRE_KEEPS = {("ability", "WolfHourEffect")}

# Bundle header: magic, bundle size (offset 8) and index size (offset 16), both written by the
# build. The other fields are the ones of the bundle Spectre has always shipped.
HEADER = bytes.fromhex("504f5441544f3730000000000000000000000000030001000013131313131313")

ENTRY = 320
NAME_LEN = 276
ALIGN = 4096
LZ4 = 4
LZ4HC = 5

# Bundle entries the metadata index does not list. Spectre has always shipped
# this file without a record.
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


def build(alchemy501: bool = False):
    xmls = tree(XML_DIR)
    files = tree(FILES_DIR)
    wrong = [n for n in xmls if not n.endswith(".xml")] + [n for n in files if n.endswith(".xml")]
    if wrong:
        raise SystemExit(f"XML go in bundle/xml, every other file in bundle/files: {wrong}")
    alchemy, alchemy_other = {}, {}
    if alchemy501:
        alchemy = tree(ALCHEMY501_XML)
        alchemy_other = tree(ALCHEMY501_FILES)
        unknown = [n for n in alchemy if n not in xmls] + [n for n in alchemy_other if n not in files]
        if unknown:
            raise SystemExit(f"bundle/alchemy501 has files the bundle does not ship: {unknown}")

    items = []  # (name, payload)
    for key, path in xmls.items():
        name = path.relative_to(XML_DIR).as_posix()
        text = decode(path.read_bytes())
        if key in alchemy:
            text = alchemy501_xml(decode(alchemy[key].read_bytes()), text, name)
        items.append((name, xml_payload(text, name, crlf=True)))
    for key, path in files.items():
        name = path.relative_to(FILES_DIR).as_posix()
        items.append((name, alchemy_other.get(key, path).read_bytes()))

    index_size = len(items) * ENTRY
    out = bytearray(align(32 + index_size))
    out[:len(HEADER)] = HEADER
    struct.pack_into("<I", out, 16, index_size)
    placed = {}
    for i, (name, payload) in enumerate(items):
        comp = lz4.block.compress(payload, store_size=False)
        if lz4.block.decompress(comp, uncompressed_size=len(payload)) != payload:
            raise SystemExit(f"lz4 roundtrip failed {name}")
        at = 32 + i * ENTRY
        off = len(out)
        out[at:at + ENTRY] = new_entry(name)
        struct.pack_into("<II", out, at + NAME_LEN, len(payload), len(comp))
        struct.pack_into("<Q", out, at + NAME_LEN + 8, off)
        struct.pack_into("<II", out, at + 312, zlib.crc32(payload) & 0xFFFFFFFF, LZ4)
        out.extend(comp)
        out.extend(b"\x00" * (align(len(out)) - len(out)))
        placed[name] = {"off": off, "z": len(comp), "u": len(payload), "comp": LZ4}
    struct.pack_into("<I", out, 8, len(out))

    meta = Meta(META_TEMPLATE.read_bytes())
    unindexed = meta.patch(placed, 32 + index_size, len(out))
    extra_unindexed = [n for n in unindexed if n not in UNINDEXED_OK]
    if extra_unindexed:
        raise SystemExit(f"no metadata record for {extra_unindexed}. Regenerate bundle/metadata.store with w3edit.")
    return bytes(out), bytes(meta.m), len(xmls), len(files), len(alchemy) + len(alchemy_other)


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
    ap.add_argument("--out", type=Path, help=f"output folder (default {DEFAULT_OUT}, or {DEFAULT_OUT_501})")
    ap.add_argument("--alchemy501", action="store_true",
                    help="the variant with the 5.01 alchemy data (bundle/alchemy501) instead of Spectre's")
    args = ap.parse_args()
    if args.out is None:
        args.out = DEFAULT_OUT_501 if args.alchemy501 else DEFAULT_OUT

    blob, meta, n_xml, n_files, n_alch = build(args.alchemy501)
    count = verify(blob, meta)
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "blob0.bundle").write_bytes(blob)
    (args.out / "metadata.store").write_bytes(meta)
    print(f"Wrote {args.out}")
    print(f"{count} files, {len(blob) / 1e6:.1f} MB. {n_xml} XML from bundle/xml, {n_files} from bundle/files."
          + (f" Alchemy 5.01 variant: {n_alch} files from bundle/alchemy501." if n_alch else ""))


if __name__ == "__main__":
    sys.exit(main())
