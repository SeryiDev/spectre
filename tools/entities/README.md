# Entities, scenes and quest files

These scripts make `bundle/entities501.json`: the list of CR2W files (`.w2ent`, `.w2scene`, `.w2phase`, `.journal`...) that the bundle takes from the 5.01 game instead of Spectre v0.93, with Spectre's edits put back. The build (`bundle/build_bundle.py` with `bundle/cr2w_ops.py`) only replays that file, so these are needed only to make it again:

- after a game patch that changes one of the files (the build stops: "N files of entities501.json are not in the 5.01 game ... or are a different version"),
- to change or add a Spectre edit.

Requires Python 3 and `pip install lz4`.

## Why

v0.93's files came from game versions up to 1.32, so they lacked what 4.0 and 5.0 added. To tell Spectre's edits from CDPR's, each file is compared three ways: 1.32 (the base), Spectre (1.32 plus Spectre's edits), 5.01 (1.32 plus CDPR's changes). A Spectre edit goes on the 5.01 file only where 5.01 kept the 1.32 value. Files saved by versions before 1.32 (CR2W 162) also differ from 1.32 by old content, so from those only levels and additions to lists are taken.

## Steps

1. **Get 1.32.** Steam keeps it as the `classic` branch. With [DepotDownloader](https://github.com/SteamRE/DepotDownloader), only the bundles are needed (about 2.8 GB). `files.txt`:

   ```
   regex:.*[\\/]bundles[\\/]blob\.bundle$
   regex:(?i).*patch[^\\/]*[\\/]bundles[\\/][^\\/]*\.bundle$
   ```

   ```
   DepotDownloader -app 292030 -beta classic -username <user> -filelist files.txt -dir <1.32 folder>
   ```

2. **Extract** Spectre's files and their 5.01 and 1.32 copies into a work folder:

   ```
   python tools\entities\extract.py <work> <Spectre v0.93 release> <The Witcher 3 5.01 folder>
   python tools\entities\extract_132.py <work> <1.32 folder>
   ```

3. **Value edits** (same-size values patched in place: levels, loot containers, damage, prices...):

   ```
   python tools\entities\gen_patches.py <work> <work>\entities501.json
   ```

   It also leaves out the files whose copy should stay Spectre's (5.01 did not change them from 1.32). `<work>\entities501.skipped.txt` lists the edits it could not apply and why.

4. **Structural edits** (lists merged three ways, new names, added properties and objects), written as "ops" into the same JSON:

   ```
   python tools\entities\gen_phase2.py <work> <work>\entities501.json <work>\phase2-report.txt
   python tools\entities\check_phase2.py <work> <work>\entities501.json
   ```

   The report lists every change per file. The check reads every result back and must end with `problems: 0`.

5. Copy `<work>\entities501.json` to `bundle\`, rebuild with `pack-release.ps1 -Version 1.0 -Base <v0.93 release>` and update `bundle\bundle.sha256`.

Which classes and properties count as Spectre edits is set at the top of `gen_patches.py` (value edits) and `gen_phase2.py` (structural edits).

## Files

- `cr2w.py`: CR2W dumper (path = value). `cr2wloc.py`: the same, plus the file offset of each value. `diff3.py`: three-way listing of a work folder.
- `cr2wedit.py`: reads and writes CR2W files without buffers or embedded files, byte-identical on the 649 game files. `cr2wval.py`: decodes and encodes property values (names, handles, imports, structs). `sem.py`: compares the same file across versions by object and value.
- `doboz.py`: Doboz decompressor (1.32 bundles). `game501.py`: reads the 5.01 game bundles.
- `test_roundtrip.py`, `test_values.py`: check `cr2wedit` and `cr2wval` on a work folder.
