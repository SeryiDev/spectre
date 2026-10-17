"""Build Spectre's gameplay bundle for The Witcher 3 5.01.

    python bundle/build_bundle.py --base "<Spectre v0.93 release folder or zip>"

Inputs:
  base               blob0.bundle from the published Spectre v0.93 release
                     (mods/mod000Spectre/content). Checked by SHA-256.
  bundle/xml/        XML that replace the v0.93 copies (rebased onto 5.01).
  bundle/files/      Files that v0.93 does not have. They are added at the end.
  bundle/metadata.store
                     Index the game reads to find each file. It already lists
                     every file above. The build only rewrites sizes and offsets.

Output (default build/mod000Spectre/content):
  blob0.bundle, metadata.store

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
import struct
import sys
import zipfile
import zlib
from pathlib import Path
from xml.etree import ElementTree as ET

import lz4.block

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
XML_DIR = HERE / "xml"
FILES_DIR = HERE / "files"
META_TEMPLATE = HERE / "metadata.store"
DEFAULT_OUT = ROOT / "build" / "mod000Spectre" / "content"

BASE_SHA256 = "69c899d9bc9f1e4057bd5e82a38fe403e6509474ad931476ab0c7fd762dab01e"
BASE_IN_ZIP = "mods/mod000Spectre/content/blob0.bundle"

ENTRY = 320
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


def tree(root: Path) -> dict:
    if not root.is_dir():
        return {}
    return {p.relative_to(root).as_posix().lower(): p for p in sorted(root.rglob("*")) if p.is_file()}


def build(base: bytes):
    entries = read_entries(base)
    names = {e["name"].lower() for e in entries}
    overrides = tree(XML_DIR)
    extras = tree(FILES_DIR)
    unknown = [n for n in overrides if n not in names]
    if unknown:
        raise SystemExit(f"bundle/xml has files v0.93 does not ship (put new files in bundle/files): {unknown}")
    clash = [n for n in extras if n in names]
    if clash:
        raise SystemExit(f"bundle/files has files v0.93 already ships (put XML edits in bundle/xml): {clash}")

    items = []  # (entry bytes, payload, u, crc, comp, name)
    for e in entries:
        key = e["name"].lower()
        if key.endswith(".xml"):
            if key in overrides:
                text = decode(overrides[key].read_bytes())
                payload = xml_payload(text, e["name"], crlf=True)
            else:
                payload = xml_payload(decode(unpack(base, e)), e["name"], crlf=False)
            comp = lz4.block.compress(payload, store_size=False)
            if lz4.block.decompress(comp, uncompressed_size=len(payload)) != payload:
                raise SystemExit(f"lz4 roundtrip failed {e['name']}")
            items.append((e["entry"], comp, len(payload), zlib.crc32(payload) & 0xFFFFFFFF, e["comp"], e["name"]))
        else:
            items.append((e["entry"], base[e["off"]:e["off"] + e["z"]], e["u"], e["crc"], e["comp"], e["name"]))
    for key, path in extras.items():
        payload = path.read_bytes()
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
    return bytes(out), bytes(meta.m), len(overrides), len(extras)


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
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT, help=f"output folder (default {DEFAULT_OUT})")
    args = ap.parse_args()

    blob, meta, n_xml, n_files = build(load_base(args.base))
    count = verify(blob, meta)
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "blob0.bundle").write_bytes(blob)
    (args.out / "metadata.store").write_bytes(meta)
    print(f"Wrote {args.out}")
    print(f"{count} files, {len(blob) / 1e6:.1f} MB. {n_xml} XML from bundle/xml, {n_files} added from bundle/files.")


if __name__ == "__main__":
    sys.exit(main())
