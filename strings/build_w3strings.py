"""Builds strings/*.w3strings from strings/en.csv and strings/es.csv.

pack-release.ps1 runs it before packing, so a text edited in a .csv always reaches the game.

  en.w3strings  every row of en.csv.
  es.w3strings  every row of es.csv.
  the others    the rows of en.csv they already have, plus rows that are new in en.csv, in English. A text that
                differs from the previous English one is a translation and is kept.

A row is "id|hex key|text key|text": the hex key (old Spectre rows) or the hash of the text key gives the lookup
key; a hex key of 00000000 means no key. Each file keeps its own header and its language magic, which is read from the file itself.

Usage: python build_w3strings.py [--check]   (--check only reports what would change)
"""
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
# A row every Spectre string file has, used to find each file's language magic.
KNOWN_KEY, KNOWN_ID = 'spectre_skill_passive', 2119657861


def read_bit6(data, pos):
    result, shift, i = 0, 0, 1
    while True:
        b = data[pos]
        pos += 1
        s, mask = 6, 255
        if b > 127:
            mask, s = 127, 7
        elif b > 63 and i == 1:
            mask = 63
        if shift < 32:
            result |= (b & mask) << shift
        shift += s
        if b < 64 or (i >= 3 and b < 128):
            break
        i += 1
    return result, pos


def write_bit6(c):
    if c == 0:
        return bytes([128])
    parts, left, i = [], c, 0
    while left > 0:
        if i == 0:
            parts.append(left & 63)
            left >>= 6
        else:
            parts.append(left & 255)
            left >>= 7
        i += 1
    out = bytearray()
    for i, val in enumerate(parts):
        if i != len(parts) - 1:
            if len(parts) - 1 - i >= 1 and i >= 1:
                val |= 128
            elif val < 64:
                val |= 64
            else:
                val |= 128
        out.append(val & 255)
    return bytes(out)


def crypt(raw, magic):
    key = (magic >> 8) & 0xFFFF
    out = bytearray()
    for b in raw:
        out.append(b ^ (((len(raw) + 1) * key) & 0xFF))
        key = ((key << 1) | (key >> 15)) & 0xFFFF
    return bytes(out)


def key_hash(key):
    h = 0
    for c in key.lower().encode('utf-8'):
        h = (h * 31 + c) & 0xFFFFFFFF
    return h


def find_magic(data):
    pos = 10
    count, pos = read_bit6(data, pos)
    pos += 12 * count
    count2, pos = read_bit6(data, pos)
    wanted = key_hash(KNOWN_KEY)
    for i in range(count2):
        k, hashed = struct.unpack_from('<II', data, pos + 8 * i)
        if k == wanted:
            return hashed ^ KNOWN_ID
    raise SystemExit('no %s row: cannot find the language magic' % KNOWN_KEY)


def load(path):
    data = path.read_bytes()
    if data[:4] != b'RTSW':
        raise SystemExit('%s is not a w3strings file' % path)
    magic = find_magic(data)
    version, key1 = struct.unpack_from('<IH', data, 4)
    key2 = struct.unpack_from('<H', data, len(data) - 2)[0]
    pos = 10
    count, pos = read_bit6(data, pos)
    entries = []
    for _ in range(count):
        hashed, offset, strlen = struct.unpack_from('<III', data, pos)
        pos += 12
        entries.append((hashed ^ magic, offset, strlen))
    count2, pos = read_bit6(data, pos)
    keys = {}
    for _ in range(count2):
        k, hashed = struct.unpack_from('<II', data, pos)
        pos += 8
        keys[hashed ^ magic] = k
    _, pos = read_bit6(data, pos)
    texts = {}
    for sid, offset, strlen in entries:
        raw = data[pos + offset:pos + offset + strlen]
        texts[sid] = crypt(raw, magic).decode('utf-8')
    return {'magic': magic, 'version': version, 'key1': key1, 'key2': key2, 'texts': texts, 'keys': keys}


def save(path, doc, rows):
    """rows: {id: (key or None, text)}"""
    magic = doc['magic']
    ids = sorted(rows, key=lambda i: (i ^ magic) & 0xFFFFFFFF)
    buf = bytearray()
    table = bytearray()
    for sid in ids:
        raw = rows[sid][1].encode('utf-8')
        table += struct.pack('<III', sid ^ magic, len(buf), len(raw))
        buf += crypt(raw, magic) + b'\x00'
    keyed = sorted((rows[i][0], i) for i in ids if rows[i][0] is not None)
    out = bytearray(b'RTSW')
    out += struct.pack('<IH', doc['version'], doc['key1'])
    out += write_bit6(len(ids)) + table
    out += write_bit6(len(keyed))
    for k, sid in keyed:
        out += struct.pack('<II', k, sid ^ magic)
    out += write_bit6(len(buf)) + buf
    out += struct.pack('<H', doc['key2'])
    path.write_bytes(bytes(out))


def read_csv(path):
    rows = {}
    for line in path.read_text(encoding='utf-8').splitlines():
        if not line or line.startswith(';'):
            continue
        parts = line.split('|', 3)
        if len(parts) < 4 or not parts[0].strip().isdigit():
            continue
        sid, hexkey, textkey, text = int(parts[0]), parts[1].strip(), parts[2].strip(), parts[3]
        if hexkey and int(hexkey, 16) != 0:
            key = int(hexkey, 16)
        elif textkey:
            key = key_hash(textkey)
        else:
            key = None
        rows[sid] = (key, text)
    return rows


def main():
    check = '--check' in sys.argv
    en_rows = read_csv(HERE / 'en.csv')
    es_rows = read_csv(HERE / 'es.csv')
    old_en = load(HERE / 'en.w3strings')['texts']
    changed = 0
    for path in sorted(HERE.glob('*.w3strings')):
        lang = path.stem
        doc = load(path)
        if lang == 'en':
            rows = dict(en_rows)
        elif lang == 'es':
            rows = dict(es_rows)
        else:
            rows = {}
            for sid, (key, text) in en_rows.items():
                if sid in doc['texts']:
                    current = doc['texts'][sid]
                    translated = sid in old_en and current != old_en[sid]
                    rows[sid] = (key, current if translated else text)
                elif sid not in old_en:
                    rows[sid] = (key, text)
        before = {sid: (doc['keys'].get(sid), doc['texts'][sid]) for sid in doc['texts']}
        if before != rows:
            changed += 1
            diff = sorted(set(before) ^ set(rows) | {i for i in rows if i in before and before[i] != rows[i]})
            print('%s: %d rows change (%s%s)' % (path.name, len(diff), ', '.join(map(str, diff[:5])), '...' if len(diff) > 5 else ''))
            if not check:
                save(path, doc, rows)
    print('%d string files %s.' % (changed, 'would change' if check else 'updated'))


if __name__ == '__main__':
    main()
