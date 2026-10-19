# Flash panels

`patch_panel.py` replaces ActionScript classes inside a `.redswf` and writes it back in the same space.

Needs FFDec (`ffdec-cli.exe`, default `C:\Program Files (x86)\FFDec\ffdec-cli.exe`) and `pip install zopfli`. The patched movie is compressed with zopfli to fit; there is about 15 KB of room.

## 5.01 skill menu

`bundle/files/gameplay/gui_new/swf/character/panel_character_dupe.redswf` is the 5.01 panel with these classes changed (in `as/`, with the folder layout FFDec exports):

- `SlotPointIndicator`: the rank as a number in the bottom right corner of the cell.
- `CharacterSkillsGridModule`: cell positions and links (`skill.tree.pos.override`, `skill.tree.line.override`).
- `SlotSkillGrid`: hold R (buy every rank) and hold Z / gamepad R3 (reset), with the fill animation. Holding E / gamepad X keeps buying ranks, each hold shorter.
- `MenuCharacterDupe`: sends `OnUpgradeSkill` with the skill id + 1000 (R) or + 2000 (Z), which `characterMenu_AN.ws` reads. The reset is sent with 0 free points too (5.01's `callUpgradeSkill` drops every call without points).
- `CharacterTabbedListModuleDupe`: the key hints, in E, R, Z order.
- `MutationsPanel`: the "Active mutations: 3/3" counter left of the mutation tree (`setSpectreCounter`), which `MenuCharacterDupe` gets through the binding `spectre.mutations.counter`; the hints E "Activate/Deactivate mutation" and R / gamepad X "Use as main", which makes the selected active mutation the main one.
- `MutationItemRenderer`: the main mutation's ring and icon background in bright gold, with a gold glow (`spectreShown`).
- `MasterMutationItemRenderer`: with more than one mutation active, the skill tab's center describes the main mutation (`spectreCenterDescription`) instead of its own effect.

```
python tools\panel\patch_panel.py patch                  # import as\ into the panel
python tools\panel\patch_panel.py export --out DIR       # export every class of the current panel
```

`patch` copies the old file to `tools\panel\backup` first and reads the result back to check it.

## Skill tooltip

`bundle/files/gameplay/gui_new/swf/common/componentslib.redswf` is the 5.01 shared component library (from `content/content0/bundles/r4gui.bundle`). `complib_as/.../TooltipSkill.as` aligns the two skill descriptions left instead of centered.

```
python tools\panel\patch_panel.py patch --redswf bundle\files\gameplay\gui_new\swf\common\componentslib.redswf --scripts tools\panel\complib_as
```

## Loot window

`bundle/files/gameplay/gui_new/swf/popups/popup_loot.redswf` is Spectre v0.93's loot window (from 4.04, with weight, price and stock columns). `loot_as/LootPopupMenu.as` has the 5.01 fix: the window is created hidden (`visible = false` in the constructor), shows itself when `LootItemList` arrives (`resetVisibility`), and `SetWindowScale` no longer shows it. Before, one frame showed the panel's sample rows.

```
python tools\panel\patch_panel.py patch --redswf bundle\files\gameplay\gui_new\swf\popups\popup_loot.redswf --scripts tools\panel\loot_as
```

After patching either panel, rebuild the bundle (`pack-release.ps1 -Version 1.0 -Base <v0.93 release>`) and update `bundle\bundle.sha256` with the hashes of `build\mod000Spectre\content`.
