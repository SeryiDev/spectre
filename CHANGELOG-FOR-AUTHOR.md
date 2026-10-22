# Spectre 1.0 on The Witcher 3 5.01: changes for the author

Everything this port changed from Spectre v0.93 (for 4.04), for the author: logic, rebalance, new options, fixes, the bundle and how it is built. The player-facing summary is `CHANGELOG.md`. The in-game version is 1.0.

What stays: Spectre's combat, signs, alchemy, enemy scaling, looting and its 10-rank skills. What is new: the 5.01 skills and effects Spectre never had, a choice between Spectre's skill tree and the 5.01 one, several menu options to turn Spectre's systems off one by one, a skill rebalance so every rank counts, and the fixes found while playtesting on 5.01.

Numbers for skills are given for ranks 1 / 5 / 10. "Before" means Spectre v0.93, unless it says 5.01.

## To do

- **Vanilla alchemy package: items lost when switching.** Going from the package back to Spectre's alchemy loses some inventory items and the equipped gear (see Vanilla alchemy package). Next step: a temporary notification at load with the content of every slot, before `spectreRepairAppearance`, to tell whether the game already brings them empty or something in Spectre empties them.
- **Recoloring skills with greater mutagens, in the 5.01 menu** (see Not in the 5.01 menu). The code that saves and applies the colors is still there (`spectre_recolorManager`, `GetSkillColor`, `SetSkillColor`, `ResetSkillColor`). As it was, it let all 12 slots take the color of their mutagen and always give the highest bonus, and greater mutagens are plentiful by mid-game. Proposal:
  - At most one recolored skill per mutagen group (4 in total).
  - Resetting the skill (Z) gives back its original color, so it is not permanent (the Clearing Potion that undid it no longer exists).
  - It still costs a greater mutagen and asks for confirmation.
  - Work: in the 5.01 menu's Flash (`tools/panel`), dropping a mutagen from the mutagen tab onto a skill, the confirmation window and the skill's color border. In script, the equivalent of `spectreHandleRecolorRequest` / `spectreHandleRecolorSkillConfirmation` for `CR4CharacterDupeMenu`, and the per-group limit. The master mutation colors (`spectreSetMasterMutationColors`, visual only) would go in the same Flash work.
- **5.01 mutations with the 5.01 tree.** Mutations are always Spectre's, with either tree: mutation 11 is Life Leech (triggered by the Mutation Trigger potion), not Second Life. With the 5.01 tree, an option "Use the 5.01 mutations", available only with that tree, would make sense. What Spectre changes:
  - Scripts: Life Leech (`mutation11Buff.ws`, `OnMutation11Triggered`, `MutationTrigger.ws`) and the trigger on death removed from `ReduceDamage`. The other mutations in `playerWitcher_AN.ws`, `PlayerAbilityManager_AN.ws` and the damage code need checking.
  - Data: `geralt_mutations.xml` (abilities and abilities_plus) has 10 Spectre changes (mutations 2, 4, 5, 7, 8, 9 and 12; 7 and 8 redone). XML cannot change during play, as with the alchemy package: the 5.01 values would have to be read from script under other ability names, or come from a separate package.
  - Texts: Spectre's mutation descriptions replace the 5.01 ones; both would be needed, picked by the option.

## Highlights

- **Two skill trees.** "Use Spectre's skill tree" picks Spectre's 10-rank skills or the 5.01 tree exactly as in the base game. Switching moves your ranks over and never resets the tree.
- **Turn Spectre's systems off one at a time.** New menu sections for Equipment and Combat, "Off" presets for Skills, Equipment, Combat, Gameplay, Looting and Scaling.
- **Skill rebalance.** Every rank of every 10-rank skill adds something, no skill reaches its cap before rank 10, and no bonus turns negative like before.
- **General skills need a slot by default**, except five passive ones; an option makes all of them work without one, as in Spectre v0.93. The school techniques count the armor you wear.
- **Better character stats**: the real toxicity decrease rate, potion duration and bomb damage bonuses, and Sign Intensity per sign with decimals.
- **Spectre can be uninstalled from a save.** Before, it could not: a save loaded without Spectre lost Geralt's skill tree, skills, mutations and stats, with no way back. The new option "Remove Spectre from this save" prepares the save, and loaded without Spectre it plays as the base game (see Fixes).
- **5.01 fixes**: dismounting, gear loading, starter skills charging points, enemy scaling options that were ignored, and more (see Fixes).

## Options you can change

All of these are in the game menu under Spectre. Each option shows what it does when hovered, in the left-side popup Eternal Hunt also uses (the old text at the bottom of the menu is gone). Every group with presets starts with "Recommended".

### Skills

- **Use Spectre's skill tree** (on). Off: the 5.01 skill tree, 100% as in the base game (see Skill tree).
- **Starter skills: free first rank** (on). Whirl, Rend, Arrow Deflection, Cold Blood, Razor Focus, Delusion, the five alternate sign modes and the first skill of each sign start at rank 1 for free, as in Spectre v0.93.
- **Starter skills: work without a slot** (on). Those skills work without being equipped.
- **General skills: work without a slot** (off). On, every General skill works without being equipped, as in Spectre v0.93, on either tree. Off, they need a slot like the other skills, as in 5.01: all of them working at once is too strong (Wolf, Manticore and Viper alone gave +60% Attack Power for three points). Sun and Stars, Metabolic Control, Attack is the Best Defense, Strong Back and Wolf School Techniques work without a slot either way, like Alembic: they do little in a fight, and Wolf is Geralt's school. Turning it off or on takes the effects off the learned General skills that are not slotted or puts them back, as taking a skill out of a slot or putting it in does; the save remembers the last state, so a change made with the game closed is applied on the next load.
- **Use Spectre's skill progression** (off). On, as in Spectre v0.93: every skill, mutagen and mutation slot is open from the start, and the master mutation is complete. Off: slots open as in 5.01.
- **Mutations from the start** (new, off). On, as in Spectre v0.93: the mutation system is open from the start. Off: it opens with the Blood and Wine quest Turn and Face the Strange (mq7023), as in the base game. Turning it off before that quest closes it; the equipped mutations come off and the research stays.
- **Several mutations at once** (new, off). On, as in Spectre v0.93: every researched mutation is active at the same time (see Slots). Off: one mutation at a time, as in 5.01. Its tooltip warns that it is unbalanced.
- **Maximum mutations** (new, 2 to 12, default and Recommended 3). Only with "Several mutations at once" (greyed out otherwise): how many can be active. Equipping one more is refused with a message (`spectre_max_mutations_reached`). Lowering it below the active mutations takes all of them off when the menu closes (`SpectreSyncMutations`). Turning the option on, or researching, activates mutations only up to the maximum.
- Presets: Recommended, and "Off" (all six off: the 5.01 tree as in the base game).
- Setting the version to 0 also resets this group.

### Equipment (new)

- **Equip gear of any level** (on, as in Spectre v0.93). Off: gear above Geralt's level cannot be equipped, as in the base game, and its tooltip shows the level it needs. Turning it off unequips the gear above his level.
- **Gear rises to your level** (on, as in Spectre v0.93). Off: equipped weapons and armor keep their own level; gear that already rose keeps it. Crossbows never rise, as in the base game and v0.93.
- Presets: Recommended, and "Off" (both off: level requirements and fixed levels, as in the base game).

### Combat (new)

- **Use Spectre's combat system** (on). Off, as in the base game:
  - Geralt's base stamina values come from 5.01: attacks, parries, dodges, rolls and items cost no stamina, sprint and jump cost 12.5, stamina regenerates 10% per second.
  - Poison and bleeding resistance are as in 5.01.
  - Armor and overloading no longer change stamina costs; armor slows stamina regeneration again.
  - Whirl, Rend and the signs have no cooldown, and Rend released early costs no extra stamina.
  - Quick sign casting is off.
  - The other Combat options do nothing and are greyed out.
  - Switching keeps your current Adrenaline, stamina and vitality.
  - Dodging, counterattacks and parries keep Spectre's rules either way.
- Quick sign casting, the armor stamina regeneration penalty, stamina and vitality regeneration in and out of combat, the sprint, melee and sign stamina costs, the stamina delay, and the Whirl/Rend, sign and alternate sign cooldowns. These moved here from Gameplay. Players coming from v0.93 get the recommended values for them.
- Presets: Recommended, Old version, and "Off" (also turns off "Use Spectre's combat system").

### Gameplay

- Keeps the boat sinking when overloaded, its threshold, and the item weight reduction. The threshold is greyed out while sinking is off (`spectreUpdateSinkBoatMenu`). The item weight reduction defaults to 0 in the script too, as in the Recommended preset; the script used 20 when the option had no value.
- **Merchants get rid of what you sell**. Once the shop is closed, a merchant gets rid of what you sold, so it cannot be bought back. Relic and witcher weapons and armor (quality 4 and 5) stay for sale. Off: sold items stay for sale, as in the base game.
- Presets: Recommended, and "Off" (the boat never sinks, items keep their weight, merchants keep what you sell).

### Looting

- Presets: Recommended, and "Off": no area looting (only the container you open), no line of sight scan, no theft, guards react.

### Alchemy

- Every option of Alchemy > Toxicity has a short description. The potion toxicity one gives an example for each potion level.

### Experience and Scaling

- Experience's preset is called "Recommended" (it said "Default").

### Uninstall (new)

- "Remove Spectre from this save" prepares the save for playing without Spectre. Turned on, when the menu closes it resets the skills, unequips the mutations and skill mutagens, takes off Spectre's effects and abilities, puts back the base game ability manager and makes a new manual save. Loaded without Spectre, that save gives back the skill points (the base game's own skill reset). Loaded with Spectre still installed, Spectre comes back and gives back the points.
- It only works in a loaded game, as Geralt, out of combat and where the game can be saved. In the main menu and as Ciri it is greyed out.

## Skill tree

### Spectre's tree or the 5.01 tree

- **"Use Spectre's skill tree"** replaces "Update vanilla character skill tree".
  - On: Spectre's skills take the cells of the 5.01 skills they replace.
  - Off: every skill is the 5.01 one, as in the base game: cells, links, ranks, names, texts, values (5.01 copies of the abilities Spectre changed, `spectre_vanilla_*`) and effects. Spectre's own alchemy skills give way to the 5.01 skills with the same ids. Only the starter skills and the General skills work without a slot, if their options are on; every other skill needs one, as in 5.01. Spectre's combat, sign and alchemy systems stay; each 5.01 skill applies its 5.01 rule inside them.
- **Switching does not reset the tree.** Each skill passes its ranks and its slot to the skill that takes its cell, up to that skill's maximum; ranks above it come back as unspent points (a shared skill at rank 10 keeps 3). A starter skill's free rank goes with it. The tree is kept in the save, so changing the option with the game closed moves the ranks on the next load. Before, the old option reset the tree and refunded every point, so it worked as a free respec. A character made without Spectre still gets its tree rebuilt once, with every point refunded.
- **The 5.01 tree shows correctly**: every branch with its skills and links, no flickering, and the skills Spectre had changed can be bought. Its tooltips end with the 5.01 per-rank bonus (Adrenaline gain, stamina regeneration, potion duration and bomb damage, vitality) instead of +0.
- **5.01 per-rank bonuses** go to the skills that count as equipped, as in 5.01 (slotted skills, plus the skills that work without a slot: the starter skills and the General skills while their options are on, and the five General skills that always do). They are counted again from scratch whenever the skill options apply, so loading a save never stacks them. Each alchemy rank raises bomb damage again, as in 5.01; Spectre's damage code had dropped it.
- **Flood of Anger** follows the tree. With Spectre's tree it is Spectre's, as in v0.93: see the next point (`W3SignEntity.InitFoA`). With the 5.01 tree it is the 5.01 one: `CastSign` calls `AddTemporarySkills` before creating the sign, so it drains all Adrenaline, raises the 13 sign skills of 5.01 and supercharges the sign (`IsSuperchargedSign`: Yrden drains, Rage Management casts without Adrenaline, Magic Sensibilities' sign crit), and `RemoveTemporarySkills` runs the 5.01 code, which waits for the sign to end and clears the supercharge. Spectre's Quen reads Exploding Shield when it is cast, so the shield keeps the maxed discharge and impulse. Before, both trees used Spectre's, and the 5.0 Aard finisher (`CastSignSpecific`) ran it twice and lost the list of temporary skills, so the sign skills could stay at their maximum until the game was reloaded.
- **Spectre's Flood of Anger** (Spectre's tree) works like the 5.01 one, with Spectre's ranks: any sign, normal or alternate, cast with 3 or more Adrenaline Points takes 3 points and is cast with every Signs skill at its maximum and +25% Sign Intensity per rank (`sword_s19`, +250% at rank 10). The skills stay while the sign is held (`spectreRemoveTempSkillsDelay` waits while `IsCastingSign`), so a channeled sign such as Igni's stream keeps them for the whole channel. With Rage Management the 3 points replace the usual point, also when a channel starts, and the channel then costs the usual Adrenaline per second, and Stamina when it runs out. Alternate Quen pays the usual Adrenaline per hit. Before: +50% per rank (+500% at rank 10); the skills dropped after 1 s, so a channeled sign was stronger only for its first second; with Rage Management a channel took no points at the start and then 3 times the Adrenaline per second for the whole channel, from a per-second cost cached while the skills were at rank 10 (at rank 1 it lasted about as long as without Flood of Anger, at rank 10 it drained faster), and alternate Quen took 3 times the Adrenaline per hit. With every Signs skill already at its maximum, it gave the intensity for free (`AddTemporarySkills_Public` returned the number of skills raised). The 5.01 tree keeps +50% per rank (`spectre_vanilla_sword_s19`; the 5.01 code adds `sword_s19` by name, so it is added twice per rank).
- **Flood of Anger's description** (Spectre's tree) says what it does: with 3 Adrenaline Points (the maximum), a sign spends them and is cast at its highest level with more Sign Intensity; with Rage Management it costs no Stamina, except while an alternate sign is held. Before, it said the points were "not consumed immediately" and the cost "tripled", without saying of what.

### Layout and links

- The tree has the same links as vanilla. A skill unlocks when any one of the skills it links to is bought.
- Spectre's skills take the cells the 5.01 reworks had taken, so the skill bought is Spectre's 10-rank one and not the 3-rank 5.01 version: Whirl, Arrow Deflection, Muscle Memory, Precise Blows, Strength Training, Crushing Blows, Sunder Armor, Crippling Strikes, Fleet Footed, Counterattack, Deadly Precision, Lightning Reflexes, Anatomical Knowledge, Crippling Shot, Cold Blood, Firestream, Puppet, Shock Wave, Sustained Glyphs, Hunter Instinct, and the perks 1, 5, 6 and 7. Points spent on the 5.01 version move to Spectre's skill; any above its maximum are refunded. Skills that 5.01 added and Spectre never had stay on the tree.
- A Spectre skill placed in a 5.01 cell also takes that cell's links and required points. Before, it kept its own v0.93 links, so Fixative, Half-Life, Autophagy and others asked for the wrong skills.
- Flood of Anger is on the remaster tree again, in the Battle Trance column, unlocked by Crippling Strikes or Counterattack. It keeps +50% Sign Intensity per rank, since it spends 3 Adrenaline Points.
- Half-Life, Autophagy, Fixative, Survival Instinct, Rage Management, Adrenaline Burst, Metabolic Control, Metabolism Boost, Gorged on Power, Gourmet, Advanced Pyrotechnics, Battle Frenzy, Attack is the Best Defense and Strong Back were missing from the remaster tree. Each one is back in the cell of its 5.01 version.
- In the General tree, the six cells between the columns sit half a row higher and their links leave from the middle of a side, as in 5.01. Buying a General skill lights its links and unlocks the next skills at once; before, a cell with no icon stopped the tree from refreshing until you changed tab.

### Starter skills

- Whirl, Rend, Arrow Deflection, Cold Blood, Razor Focus, Delusion, the five alternate sign modes and the first skill of each sign (which replace the five sign intensity skills, now off the tree) start at rank 1 for free and work without a slot, as in Spectre v0.93. Both options are on by default.
- Resets and the unequip refund return every paid rank and keep the free one.
- Turning "free first rank" on gives an already bought starter skill the free rank on top of its paid ranks (at rank 10 one point comes back instead). Turning it off removes that rank, so switching it on and off never loses paid ranks, and refunds the skills that could only be reached through it (an old save's skills that had no link before are left alone).
- A starter skill with its free rank looks bought in the tree, never locked. Going past rank 1 needs its links, like any skill, and the free rank only opens the skills linked to it once the starter skill is reachable through its own links, so a free skill in the middle of the combat tree is not a shortcut. The normal purchase in the remaster menu checks the links too; before, only the panel did, and only for skills at rank 0.
- A rank refused only because of its links (buying it, or holding R) shows "Unlock the skills before this one first." Before, only the denied sound played.
- Loading a save no longer buys the starter skills with skill points. v0.93 bought them at rank 1 on every load and charged a point for each when there were free points.

### Slots

- Skill slots open as in 5.01. The 12 slots linked to mutagens open with total skill points, mutation points included (0, 2, 4, 6, 8, 10, 12, 15, 18, 22, 26, 30). The 4 middle slots open with 2, 4, 8 and 12 researched mutations, as in 5.01, and only while a mutation is equipped; the master mutation's stages use the same numbers. "Use Spectre's skill progression" opens all 16 from the start, with or without a mutation, and the master mutation is complete, as in Spectre v0.93 (which counted 12 extra researched mutations; now the option asks for none). On an older save, and when the option changes, skills left in slots that are now locked are unequipped.
- A skill in a slot that gets locked is taken out of it. Spectre's unequip only looked at open slots.
- The 4 mutagen slots open at 2, 9, 16 and 28 skill points, as in 5.01; Spectre v0.93 opened them from the start, which "Use Spectre's skill progression" brings back. On an older save, a mutagen in a slot that is now locked goes back to the inventory.
- 16 skill slots, as in 5.01. Spectre v0.93 shipped 26 and extra mutation-slot numbers for Vladimir UI, which 5.01's menu never showed; an older save drops the extra slots on load.
- Mutations:
  - By default, one at a time, as in 5.01: equipping one takes off the one before, and unequipping takes it off. A save with several equipped keeps only the last one. Before, in the 5.01 menu, unequipping did nothing and every mutation equipped stayed on without showing.
  - With "Several mutations at once", every researched mutation is active at once, as in Spectre v0.93: all of them when the option is turned on, and each new one when it is researched. The 5.01 menu shows one: equipping a mutation there makes it the shown one, whose colors the middle slots take, and unequipping turns off only the shown one, which stays off (also after loading) until it is equipped again. Turning the option off keeps only the shown one.
  - Mutation 7 (Adrenaline Rush) is the only one with a drawback: when its attack power bonus ends during combat, it becomes a penalty.
- A skill that works without a slot keeps its effect when it is taken out of a slot. Before, unslotting a General skill turned it off until the save was loaded again.
- Mutations take the same skill colors as in the base game. Spectre's `geralt_mutations.xml` added yellow (General skills) to the mutations of two or more colors; the remaster menu repeated the previous color's name in the tooltip and never let a General skill into the middle slots, so it is removed. Equipping checks the colors too, since the classic menu's border art would still let a General skill in. The classic menu's three-color border finds its art (`RedgreenBlueYellow`; it asked for `RedGreenBlueYellow`, which does not exist).

### Menu

- In the remaster tree, each bought skill shows its rank as a white number on a dark square in the bottom right corner of its cell, as in Spectre v0.93 on 4.04, instead of one pip per rank (with 10 ranks the pips ran over the next cells). The tooltip still shows the rank and the maximum (3/10).
- In the remaster tree, holding R on a skill buys every rank your points and its links allow. The hint "R [Hold] Acquire up to max rank" shows next to the E one, with keyboard and mouse.
- Holding Z on a learned skill resets it: its paid ranks come back as points and it leaves its slot (a free starter rank stays). The skills linked after it that would lose their links are reset too (in a line of five, resetting the third resets the fifth, fourth and third); one still linked through another bought skill stays. The hint "Z [Hold] Reset skill" shows with keyboard and mouse; with a gamepad it is R3 (pressing R3 did nothing in this menu: the "jump sections" hint is the right stick, which jumps when tilted). This replaces Spectre's reset toggle (press Z, then unequip a slotted skill): it only worked on slotted skills, only the classic menu said how to use it (a notice each time it opened, now gone), and it did nothing in the 5.01 skill menu.
- The top line of every skill tooltip says whether the skill is passive (works without a slot) or needs to be equipped. Before, only Half-Life said it was passive.
- With Spectre's tree, 5.01 tooltips no longer end with "Adrenaline point gain: +0%", "Stamina regeneration: +0/s" or "Vitality gain +1%": Spectre does not give those bonuses per skill.
- In the remaster menu, the 5.01 alchemy skills (Heightened Tolerance, Toxic Shock, Volatile Concoction, Debilitating Poison) show their numbers instead of $I$ and $F$. Skills past Spectre's range use the 5.01 text in both menus.
- A new Blood and Wine or Hearts of Stone standalone game gets the remaster skill reset and refund, and Spectre's tree is applied without the notice.

### Not in the 5.01 menu

Spectre v0.93 added these to the 4.04 skill menu. 5.01 replaced that menu and hides the old one (`UseLegacySkillTree`), so they are gone. They can come back, but they need work in the 5.01 menu's Flash panel.

- **Recoloring skills**: dragging a greater mutagen onto a slotted skill changed its color (it cost the mutagen and was permanent), so it counted for the mutagen bonus of its group. A save that has recolored skills keeps their colors.
- **Master mutation colors**: the middle of the tree took the colors of the equipped mutation. Visual only.
- **Several mutations at once in the classic menu**: with "Several mutations at once" every researched mutation is active, but the 5.01 menu only shows one (see Slots).

## Skill rebalance

Spectre's skills go to 10 ranks on purpose: with Eternal Hunt, skill points can be farmed without limit. Every rank now adds something, the cap is reached at rank 10 and not before, no reduction goes below zero, and the tooltip shows the real value.

### General rules

- Combat and sign skills need a slot to work, as in the base game, except the starter skills while their option is on. A loaded save drops the effects of the others that are bought but not slotted.
- Spectre's alchemy skills that help in combat need a slot: Half-Life (it lengthens the potions used in combat), Catalysis, Equilibrium, Mitogenesis, Metastasis, Frenzy, Angiogenesis, Adaptation and Autophagy. Before, all eleven worked without one, so maximum vitality and toxicity bonuses came for free. Alembic and Proficiency, which do nothing in combat, still work without a slot.
- General skills need a slot, except Sun and Stars, Metabolic Control, Attack is the Best Defense, Strong Back and Wolf School Techniques, which always work without one. "General skills: work without a slot" (off by default) makes all of them work without one. With the 5.01 tree, the same rule with its General skills.
- Sign Intensity curve. Wherever Spectre turns Sign Intensity into a bonus with a curve (Axii duration, Quen shield absorption, Yrden slowdown, Aard knockdown, sign critical hits, Melt Armor), it counts one to one up to +100% and gives less for each extra +50% after that. Damage still scales one to one.
  | Sign Intensity  | Bonus now | Spectre v0.93 |
  | --------------- | --------- | ------------- |
  | +50%            | +50%      | +40%          |
  | +100%           | +100%     | +75%          |
  | +150%           | +130%     | +105%         |
  | +200%           | +155%     | +130%         |
  | +300%           | +190%     | +165%         |
  | +500% and above | +225%     | +220%         |
- The first skill of each sign (Aard: Far-Reaching, Igni: Melt Armor, Yrden: Sustained Glyphs, Quen: Exploding Shield, Axii: Delusion) adds 2.5% Sign Intensity to its own sign per rank, 25% at rank 10, while slotted. 4.04 gave each sign an intensity skill of 5 ranks of 5%; these skills have their own effect on top, so they end at the same 25%. In English their names start with the sign. The five sign intensity skills are off the tree and get no free rank.
- Descriptions that scale with Sign Intensity end with "Damage scales with Sign Intensity (current damage: N)". The "Sign Intensity: +N%" line of the first skill of each sign is always last, with one decimal when it has one.

### Combat

- **Whirl**: spinning attack that hits everyone around and drains Stamina and Adrenaline. Cost: 100% / 60% / 10% (10% less per rank after the first). Before: 15% less per rank, free and then negative from rank 8.
- **Rend**: charged heavy attack that goes through blocks, armor and shields. Critical chance: 10% / 50% / 100% (+10% per rank). Before: +20% per rank, 100% at rank 5. Its description was reordered: the extra damage it lists only applies to Rend itself, and the shock wave radius is given in meters.
- **Crippling Strikes**: chance to make an enemy bleed on a fast attack: 2.5% / 12.5% / 25%. Before: 5% per rank, 50% at rank 10. The damage bonus is unchanged.
- **Deadly Precision**: a melee hit on an enemy you just countered can kill it outright, with 0.5% / 2.5% / 5% chance per Adrenaline Point (15% at rank 10 with 3 points). Enemies immune to instant kills, and special attacks such as Whirl and Rend, are excluded. Before: 1% per rank and point, 30% at rank 10.
- **Counterattack**: the attack after a counter gets 15% / 75% / 150% more attack power and 25% / 58% / 100% more critical chance (25% plus 8.33% per rank after the first). Before: +33.4% attack power per rank (+334% at rank 10), and 35% critical chance per rank, over 100% from rank 4. Rank 10 still counters on its own while guarding.
- **Arrow Deflection**: parries block 55% / 75% / 100% of the damage (50% plus 5% per rank). Reflected arrows deal x1 / x3 / x5.5 (+50% per rank after the first) on both arrow types. Before: 100% blocked at rank 5 and a negative number in the tooltip after it; reflected arrows dealt x(2 x rank + 0.5), and the other arrow type only got its bonus at exactly rank 3.
- **Fleet Footed**: damage from hits that land during a dodge is reduced by 9% / 45% / 90%. Before: 10% per rank, and rank 10 hit the game's 95% cap.
- **Resolve**: Adrenaline lost to hits is reduced by 9% / 45% / 90%. Before: 20% per rank, and from rank 6 hits gave Adrenaline.
- **Adrenaline lost to hits** is the 5.01 amount, with or without Spectre's combat system: 0.05 for a light attack, 0.1 for a heavy one, 0.3 for a super heavy one. Before: as much as the share of health the hit took (a hit for 20% of health took 0.2, up to 1 point), and Spectre's base stats had 0.1 / 0.2 / 0.5, which nothing read. Spectre's Bear School set still takes 0.035 per piece off each hit, so with the whole set light hits give Adrenaline.
- **Lightning Reflexes**: aiming the crossbow slows time to 0.55 / 0.35 / 0.10 (5% more per rank). Before: 15% per rank, at the 0.1 floor from rank 4.
- **Razor Focus**: you enter combat with at least 0.15 / 0.75 / 1.5 Adrenaline Points, and Adrenaline gain grows by 2.5% / 12.5% / 25%. Before: 0.25 points per rank (2.5 at rank 10) and +5% gain per rank.

### Signs

- **Aard: Far-Reaching**: longer Aard range, as before, and +2.5% Aard Sign Intensity per rank.
- **Aard Sweep**: alternate Aard that hits everyone around. Sign Intensity penalty: 40% / 22% / 0% (4.44% less per rank after the first); the object push grows up to rank 10. Before: the penalty was gone at rank 3 and ranks 4 to 10 did nothing. The "no longer lowered" text only shows at rank 10.
- **Igni: Melt Armor**: Igni lowers armor and resistances, as before, and +2.5% Igni Sign Intensity per rank.
- **Firestream**: deals 40 / 140 / 265 damage per second before Sign Intensity (+25 per rank after the first) and costs 30 / 21 / 10 Stamina per second (7.4% less per rank after the first). Before: +30 damage per rank (310 at rank 10), and 16.7% less cost per rank, free and then negative from rank 7.
- **Catalyst** (from 5.01, now 10 ranks): against enemies inside Yrden, Aard and Igni deal 10% / 50% / 100% more damage, and Igni's burn chance grows by 3% / 15% / 30%. Before: 3 ranks, +30% damage and +10% burn chance per rank.
- **Yrden: Sustained Glyphs**: standard traps last 20% / 100% / 200% longer and are 2.5% / 12.5% / 25% larger; a second trap from rank 5; +2.5% Yrden Sign Intensity per rank. Before: +33.3% duration per rank, +30% size from rank 2, a second trap from rank 3 (the character stats said rank 2).
- **Fortified Signs** (from 5.01, now 10 ranks): Yrden, Quen and Axii last 5% / 25% / 50% longer. Before: 3 ranks of 20%, and it never worked for Quen and Yrden because its percentage was read as zero. It now also works for Axii, as its text says.
- **Quen: Exploding Shield**: Quen absorbs damage until its absorption runs out and then breaks; when it breaks, it pushes enemies and explodes, as before. It now includes Quen Discharge: Quen returns 5% / 25% / 50% of the melee damage it absorbs to an attacker within about 3.5 m. +2.5% Quen Sign Intensity per rank.
- **Active Shield**: costs 100% / 60% / 10% to maintain (10% less per rank after the first) and heals 10% / 50% / 100% of the damage it absorbs. Before: free from rank 3 and giving Stamina back after it; healing reached 334% at rank 10. The tooltip always shows the cost.
- **Axii: Delusion**: critical chance against confused enemies 10% / 50% / 100%; Axii slow-motion 0.91 / 0.55 / 0.10; a failed Axii staggers from rank 3 on; dialogues always succeed at rank 10; haggling +10% per rank; +2.5% Axii Sign Intensity per rank. Before: +25% critical chance per rank (100% at rank 4), slow-motion at its floor from rank 6 and shown at half, the stagger only at exactly rank 3, dialogues always won from rank 4, haggling rank x rank / 10 in whole numbers.
- **Puppet**: lasts 10 / 19 / 30 s (2.22 s per rank after the first) before Sign Intensity. A puppet's hit on an enemy deals 6-12% of the enemy's maximum health, x1.1 / x1.5 / x2. Before: 55 s at rank 10, and hits for 2-4% at rank 1 up to 20-40% at rank 10.
- **Domination**: two enemies under Axii at once, with 50% / 28% / 0% shorter duration. Before: the penalty was gone at rank 3 and ranks 4 to 10 made Axii last longer. The text says the duration is shorter, and at rank 10 that it is not reduced.
- **Focus** (from 5.01, now 10 ranks): each Adrenaline Point raises Sign Intensity by 3% / 15% / 30%, and using signs gives Adrenaline, like Spectre's General Focus: 0.1 per sign, as a sword hit, with +5% / 25% / 50% Adrenaline gain from signs (added to the other Adrenaline gain bonuses, as Muscle Memory does for light attacks). Before: 3 ranks of 10%, and with Spectre's General Focus off the tree no skill made signs give Adrenaline. Spectre's General Focus stays off the tree, since this one now does the same. With the 5.01 tree it is the 5.01 skill (signs give Adrenaline through Adrenaline Burst).
- **Convergence** (from 5.01, now 10 ranks): casting a sign raises the intensity of the next different sign by 2% / 10% / 20% per stack, up to 5 stacks (100% at rank 10). Before: 3 ranks, 5% / 10% / 15% per stack.
- **Avoidance** (from 5.01, now 10 ranks): after a dodge or roll, the next sign costs 6% / 30% / 60% less Stamina. Before: 3 ranks of 20%.
- **Overload** (from 5.01, now 10 ranks): casting a sign deals 10 / 50 / 100 magic damage to every enemy within 3 m, multiplied by half the Sign Intensity. Before: 3 ranks of 15 (45 at rank 3).
- **Resonance** (from 5.01, now 10 ranks): after casting a sign, the next 3 melee hits deal extra damage equal to 5% / 25% / 50% of Sign Intensity. Before: 3 ranks of 10%.

### Alchemy

- **Half-Life**: potions last 10% / 50% / 100% longer. Before: 33% per rank plus a small extra per rank, about +350% at rank 10.
- **Catalysis**: potions start working 9% / 45% / 90% sooner. Before: 25% per rank, at its 10% floor from rank 4.
- **Equilibrium**: potions are 9% / 45% / 90% less toxic and last 5% / 25% / 50% less. Before: 10% less toxicity per rank, so potions had no toxicity at rank 10, and 25% less duration per rank, at its floor from rank 4.
- **Adaptation**: toxicity damage is 10% / 50% / 100% lower, never below zero. Before: 18% per rank and negative from rank 6.
- **Proficiency**: a monster mutagen can be used 2 / 10 / 20 times in alchemy. Before: 2 to the power of the rank, 1024 uses at rank 10. A partly used mutagen keeps the right number of uses when the skill ranks up.
- **Autophagy**: toxicity drains 10% / 50% / 100% faster, while slotted. Before: 50% per rank, 500% at rank 10, and it worked without a slot. Adaptation lowers the damage toxicity deals; Autophagy lowers how long toxicity stays.
- **Mitogenesis, Metastasis, Angiogenesis**: +4% attack and spell power, +10% maximum toxicity, and +5% vitality per rank. Before: their abilities were never defined, so they did nothing.
- **Toxic Shock** (from 5.01, now 10 ranks): a heavy attack on a poisoned enemy consumes the poison and deals poison damage equal to 20% / 100% / 200% of the attack. Before: 3 ranks, 25% / 50% / 75%.
- **Wyvern Sting** (from 5.01, now 10 ranks): poisoned weapons deal 2.5% / 12.5% / 25% more damage, or 5% / 25% / 50% against enemies immune to poison. Before: 3 ranks, +5% and +10% per rank.
- **Fixative**: oils last 20% / 100% / 200% more hits (a level 3 oil: 72 / 120 / 180 hits). A blade holds 2 different oils at once from rank 5 and 3 at rank 10; without the skill, or below rank 5, a new oil replaces the old one. Before: +33.4% hits per rank, oils never wore off from rank 3, and a blade held as many oils as the rank.
- **Hunter Instinct**: with an oil on the blade that matches the enemy, critical hits deal 3.3% / 17% / 33% more damage per Adrenaline Point, counting up to 3 points (+10% / +50% / +100% with 3). Before: 6.68% per rank and point with no cap on points, so +200% at rank 10 with 3 points and more with a raised Adrenaline cap. The remaster menu shows its numbers instead of $S$.

### General

- The General tree keeps its 20 remaster cells. Spectre's skills take 14 of them, as listed above. The other six:
  - **Wolf, Manticore and Viper School Techniques** (from 5.01, reworked): 1 rank, and each counts the pieces of medium armor worn, as in 5.01 (5.01 gives 3 ranks). Per piece: Wolf +5% weapon damage and +5% Sign Intensity; Manticore +5% sword damage and +10% bomb damage; Viper +10% poison damage and +5% Fast Attack damage. The bonus comes only from the pieces worn, not from owning the skill; before, the port gave the bonus of every rank with any armor. Their descriptions say "each piece of Medium Armor" and have their own text; Spectre's lines used the 5.01 keys, so the 5.01 tree showed them too (with the wrong values for Viper), and it shows the 5.01 text again.
  - **Elemental Attunement** (from 5.01): 1 rank of +10% non-physical damage. Before: 3 ranks of 3%. Ranks above 1 on an older save come back as unspent points.
  - **Synergy** (from 5.01, now 10 ranks): mutagens in mutagen slots give 5% / 25% / 50% more bonus, and each rank applies at once. Before: 3 ranks of 10%, and buying or slotting it did not apply the bonus until a mutagen was equipped again. Each rank adds a mutagen's synergy bonus, which is now 5% of the mutagen's bonus instead of 10%. Spectre's alchemy Synergy stays off the remaster tree, as in 5.01.
  - **Gorged on Power** takes the Element of Surprise cell. It had no cell before, since 5.01 removed its own. Points spent on Element of Surprise are refunded. It shows its own icon, the monolith; before, the cell was empty.
  - Off the tree: Spectre's General Cold Blood, Trick Shot, In Combat's Fires, Heavy Artillery and Focus; 5.01's Element of Surprise.
- **Cat, Griffin and Bear School Techniques** count light, medium and heavy pieces, as before.
- **Strong Back** (Spectre's tree): +80 carry weight. Before: +40. The 5.01 one gives +60.
- **Battle Frenzy** (Spectre's tree): each Adrenaline Point gives +5% critical hit chance on top of Battle Trance's +10% Attack Power. Before: +10% critical hit chance instead of the Attack Power, so it lowered damage. Its text is Spectre's own (`spectre_skill_desc_perk_19`); the Hearts of Stone text said "instead of". With the 5.01 tree it is the 5.01 skill, which replaces the Attack Power without saying so, as in 5.01.
- **Rage Management** (Spectre's tree): a channeled sign paid with Adrenaline goes on with Stamina when Adrenaline runs out, as it would have without the skill, and stops only when Stamina runs out too (`W3SignEntity` state `Channeling`, `Update`). Alternate Quen does the same when a hit empties the Adrenaline (`W3QuenEntity` `OnTargetHit`). Before, the sign stopped at 0 Adrenaline even with full Stamina.
- **Metabolism Boost** works without a slot when "General skills: work without a slot" is on: potions digest 33% faster and last 33% less, and toxicity falls 33% faster, as soon as it is bought. Before: only while slotted.
- **Metabolic Control** works without a slot and adds 15 maximum Toxicity, as its tooltip says, as a base value: percent bonuses such as Metastasis apply on top of it (100 + 15, then +10%). Before: it needed a slot, added 30, percent bonuses did not count it, learning a recipe took the bonus away, and unequipping it kept it. A save that had it bought gets the new bonus on load.

## Vanilla alchemy package

An optional variant of Spectre's bundle (`spectre_vanilla_alchemy_vX.zip`: `blob0.bundle` and `metadata.store`, copied over `mods/mod000Spectre/content`) turns Spectre's alchemy off.

- **Data**: `bundle/build_bundle.py --alchemy501` takes the 32 alchemy XML listed in `bundle/alchemy501.json` from the 5.01 game (by SHA-256): potions, oils, bombs, decoctions, their recipes (level 2 and 3 back), the dye recipes and the potion and mutagen effects, Blood and Wine and Hearts of Stone included. It adds what only Spectre has, in the same container, so saves keep those items: Mutation Trigger (item, stats, recipe, effect), the Katakan, Troll and 23 mutagen effects, the lesser mutagen recipes, Mandrake cordial and Mahakam spirit. Ingredients, food, cooking, repair kits and loot stay Spectre's: every ingredient Spectre's recipes use is also used by 5.01 recipes. A separate mod cannot do this: an expansion XML in a second mod hides Spectre's copy but is not loaded (tested).
- **Menu**: the normal bundle now ships the unchanged 5.01 `gameplay/gui_new/guirsrc/r4alchemy.menu`; the variant points it at `CR4VanillaAlchemyMenu` (the 5.01 class, kept by the port) and ships the 5.01 `panel_alchemy.redswf`.
- **Marker**: the variant's `effects_potions.xml` defines the ability `spectre_alchemy_501`; `spectreAlchemy501()` asks `IsAbilityDefined`.
- **With the variant**: brewing, drinking, toxicity (`spectreToxicityEffect` runs only the 5.01 code), potion duration, charges and refills (5.01 code; charges above the 5.01 maximum are kept, and potions Spectre hid at 0 show again once refilled), the alchemy key (no fire needed), herbs (no respawn, 5.01 yield), recipe changes at load, potion and ingredient tooltips and the alchemy error texts are the 5.01 ones. Potions, decoctions, oils and bombs weigh nothing, as in 5.01. Spectre's Mutation 12 still lets decoctions be drunk without toxicity.
- **Recipes**: the known recipes are one list for both alchemies, so switching keeps them; a recipe only the other package has stays hidden until it comes back (Spectre has no level 2 and 3 recipes). The first time a save loads with the package, it gets the eight recipes a new 5.01 game starts with (Swallow, Cat, White Honey, Samum, Grapeshot, Specter Oil, Necrophage Oil, Alcohest), once (fact `spectre_vanilla_alchemy_recipes`); known ones are skipped and none is removed. A character started with Spectre in a standalone expansion start lacks the enhanced oil recipes that start gives: they did not exist in Spectre's data.
- **Alchemy skills**: with Spectre's tree, the alchemy branch takes the 5.01 definitions (`SpectrePlaceVanillaAlchemySkills`, state kept in `spectreAlchemyBranchState`). The alchemy pairs pass their ranks to the 5.01 skill and ranks above the 5.01 maximum come back as points; removing the variant puts Spectre's alchemy skills back. Every check of a 5.01 alchemy skill asks `spectreVanillaAlchemySkills()` instead of the tree, and the equipped alchemy skills give the 5.01 per-rank potion duration and bomb damage bonus.
- **Experimental, known problem (not fixed)**: going from the variant back to Spectre's bundle, some inventory items are gone when the save loads. Seen so far: potions, bombs and oils (Swallow, Grapeshot), Wolf Hour, bread, bottled water and the torch, several of them in the quick slots. The equipped gear also comes back empty, so `spectreRepairAppearance` equips the starting gear again (the "received items" notification and a moment of Geralt without a body). Tested: the potions are already missing at the start of `W3PlayerWitcher.OnSpawned`, before any Spectre script, and the item definitions are identical in both bundles, so the game itself drops them while reading the save. Ingredients and recipes stay. Comparing the two saves (name table and item records) confirms the list. The other direction (Spectre to the variant) has not been checked. The option's description marks the package as experimental and warns that items can disappear.
- **Texts**: a notification when the variant is installed or removed since the last load (shown by `spectreWatcher` once the interface is up), and a blue note under every Alchemy tab option while it is installed. A new first Alchemy tab, General, has "Vanilla alchemy package": it only shows the state, and goes back to it whenever the menu closes.

## Other gameplay and interface changes

- **Alchemy menu by level** (Spectre's menu): a level 1 recipe brews the normal, enhanced or superior item depending on the ingredients (`GetResultingPotencyLevel`), and the list showed one entry with "(Level N)" for whatever the chosen ingredients gave, so nothing said which ingredients make which level. Each potion, oil and bomb now shows once per level it can reach, named after the item of that level (`ExpandRecipeLevels`), identified by `SAlchemyRecipe.spectreKey` (that item) with `spectreLevel`. Each entry starts with the ingredients of its level, the ones in the inventory first (`SetLevelIngredients`), and only takes those (`spectreIngredientManager.IsAllowedForLevel`): superior, a top base and primary substances; enhanced, a high base and primary or rich substances; normal, no top or high base. Entries no ingredient set can reach are left out. The standard, primary and composite ingredient filters are gone; the panel's three filters now show or hide the normal, enhanced and superior entries of potions, oils and bombs (`RecipeLevelShown`), and everything else always shows. They are kept in the save (facts `spectre_alchemy_hide_normal`, `_enhanced`, `_superior`). Pinning keeps the recipe name. The bottom bar shows "Change ingredient" (right click, gamepad Y: `IngredientChangeRequest`), which nothing showed before.
- **Alchemy ingredient selection** (Spectre's menu): the popup listed only the ingredients of the slot's category in the inventory, so an ingredient used up or never owned could not be picked again, and nothing showed what else fits. It lists the whole category now (`spectreIngredientManager.GetIngredientsOfCategory`): each missing ingredient is added while the popup is open, tagged `spectreIngredientPreview`, shown with quantity 0 and `cantEquip` (red), and removed when it closes (`RemovePreviewIngredients`, from `OnIngredientChanged`, and on load for safety). The game is paused while the popup is open. Picking one sets the slot; the recipe then shows it as missing.
- **Character stats**:
  - Toxicity shows the real decrease rate: the base game drain plus Spectre's (Toxicity menu settings, potions working off their toxicity, Metabolism Boost, Autophagy, meditation). Before, only the base game drain, so Spectre's settings and skills never changed it.
  - "Others" shows how much longer potions last (Potions menu multiplier, Half-Life, Equilibrium, Metabolism Boost, and the 5.01 alchemy ranks) and how much more damage bombs deal (Heavy Artillery, Manticore School, the toxicity bomb skill, and the 5.01 alchemy ranks).
  - The two sign sections are titled "Aard, Igni, Quen" and "Yrden, Axii". Before, both showed the general Sign Intensity outside, which leaves out what raises only one sign; each sign's own intensity is inside. Sign Intensity shows one decimal when it has one (22.5%, not 22%).
  - Stamina comes before the signs.
- The sign stat panel includes Conjunction on Aard, Igni and Yrden, and Melt Armor on Igni's burn chance.
- **Enemies, NPCs and quest files are the 5.01 ones, with Spectre's edits.** v0.93 shipped about 650 of them copied from old game versions (1.32 and earlier), so they lacked what 4.0 and 5.0 added: finisher dismemberment, newer immunities, short attack ranges, loot containers, dialogue animations, grass and wetness effects. Spectre's levels, loot, abilities, damage and prices are kept (see Bundle).
- The horse dismounts on the first dismount event, as in 5.01. With the default keys the dismount key is held for 0.3 s, so a short press loots and opens things from horseback. Spectre v0.93 asked for a double tap, which made dismounting impossible with a held key.

## Fixes

### Uninstalling Spectre broke the save

This bug came from Spectre v0.93 (and the Alchemy mod it is based on), not from 5.01 or other mods.

- Spectre gives Geralt its own ability manager (`spectreAbilityManager`), and the save keeps it with that class. Without Spectre the class does not exist, so the game drops the manager on load, and the base game only makes a new one for a new game. Geralt was left with no skill tree, skills, slots or mutations, and every stat read the base game's error value: 0 damage per second, 0 armor and resistances, -1 toxicity, -1/s vitality and stamina regeneration, -100% experience and herbs, a huge Quen intensity and a broken maximum weight.
- Saves made that way cannot be fixed without Spectre. With Spectre installed again they load as before.
- New option Spectre > Uninstall > "Remove Spectre from this save". Turn it on in a loaded save, as Geralt and out of combat, and close the menu. It unequips skills, mutations and skill mutagens, sets every skill to rank 0 with its 5.01 definition, removes Spectre's effects and abilities, turns the Nigredo, Albedo and Rubedo potions into the base potion (one, with charges, as in the base game), removes the Mutation Trigger and its recipe, clears Spectre's facts and saved data, puts back ConGeralt and the base game ability manager, and makes a new manual save. Then close the game, remove Spectre and load that save: the base game resets the skills itself and gives back every skill point.
- The option turns itself off after use and on every load. It is greyed out in the main menu and as Ciri, and the hover text says it only works inside a save. In combat, or where the game cannot save, it shows a notification and does nothing.
- Loading the prepared save with Spectre still installed brings Spectre back: its tree, with every skill point free.

### Found while playtesting on 5.01

- Gear definitions load. The item XML in the bundle is stored as UTF-8 at the positions the bundle index gives; the old slots still held UTF-16 data.
- Loading a checkpoint during combat no longer crashes. A scaling change no longer rebuilds enemies that are in the fight.
- The random scaling bounds and the boss health and damage sliders are read. Their option names were wrong, so they were ignored.
- A negative random level bound is honored, so enemies can roll below your level. A range whose upper bound is below the lower one puts every enemy at your level.
- Fortified Signs, Mitogenesis, Metastasis, Angiogenesis and the school techniques work (see Skill rebalance).
- A new game started after loading a save, without closing the game, no longer inherits that save's ability manager. Spectre's `SetAbilityManager` reused `theGame.alchexts.abltymgr`, which stays in memory from the loaded save, so the new character kept its researched mutations, and their skill points opened skill slots at level 1. It is only reused now when its owner is this player (`ConstructModAbManager`, its intended use).
- Opening a container no longer flashes the loot window for a moment with sample items (red, with the quest icon). Spectre's loot window (from 4.04, with weight, price and stock columns) showed itself before the item list arrived; it now waits for the list, as the 5.01 window does.
- Far-Reaching Aard shows its whole burst. It played an upgrade effect while the sign only waited for the base one, so the effect was cut after 0.1 s.

### Combat

- Deadly Precision arms on a hit and can instant-kill a heavy attack. An immune target refunds focus instead.
- Counterattack adds crit chance and attack power after a counter or a dodge. The light counter swing is excluded. The flags clear after the hit lands.
- Rend keeps its own crit chance (5.01 removed that bonus), reads `adrenaline_damage_bonus` and falls back to `adrenaline_final_damage_bonus`, then multiplies by skill level. The character menu line does the same.
- The alternate Whirl counts as a light attack. It spends stamina, then focus.
- Sunder Armor lowers armor on heavy physical hits on its own. It no longer requires the old heavy-armor skill.
- Armor percent below zero reduces armor points instead of being clamped away.
- Deflected arrows and bolt headshots add instant-kill chance. Headshot damage is increased on the hit and again on attack power, matching 5.01.
- Anatomical Knowledge adds the silver sword's silver damage to bolts.
- Hunter Instinct adds crit damage at full focus against a monster the oil matches.
- Debilitating Poison adds defense while the attacker is poisoned.
- Toxic Shock, Catalyst, Conjunction, Resonance, Element of Surprise, the bomb perks, crippling strike and the new oil bonuses run inside Spectre's damage pass. Each bomb bonus (Heavy Artillery, Manticore School, the toxicity bomb skill, the 5.01 alchemy ranks) multiplies the damage on its own, as in 5.01; before, they were added into Spectre's single damage multiplier, so several together gave less. The character menu's bomb damage line multiplies them the same way.
- Confusion stays up when an NPC is hit. Knockdown and heavy knockdown still clear it.
- Automatic finishers no longer start only because the target is about to fall unconscious.
- A parry also sends `ParryingAttack` to the actor who parried.
- The wolf-head stamina empty and recharge cues no longer vibrate the controller.

### Signs

- Aard deals Spectre's force damage when that skill is known, otherwise the new direct damage. The two do not stack. The character stat uses the same choice. Aard spell power uses `AARD_SPELL_POWER_MULT`.
- Repeated Aard hits shorten the reaction: long stagger, stagger, then no reaction.
- Channeling can spend focus through the adrenaline perk when stamina is short. Alternate Yrden and Axii still ignore an empty stamina bar and still stop when the button is released. Puppet can abort.
- Overload and Resonance apply when a sign is thrown. Convergence tracks the last sign and shows on the buff bar.
- Yrden range, duration and trap count pick up the new sign skills. Igni burn picks up Melt Armor, and Catalyst if the target is inside a Yrden. Quen discharge prefers Exploding Shield, then Active Shield. Bear-set Quen plays for both.
- Axii's channeled form includes Puppet. Igni's includes the new channeled skill.
- The adrenaline-burst perk still pays for a sign whenever at least one focus is available (5.01 only does that when stamina is short). The newer perk covers the shortfall after that. Gryphon's free sign and Glyphword 22 stay.
- Avoidance lowers the stamina cost of a sign.
- Gamepad alt-signs follow the None, Comfort and Dynamic schemes. On PC, alt-cast is still Spectre's hold check. The focus toggle accessibility option is read; on Comfort, focus plus sign casts Yrden. Alt Quen only fires on None and Comfort. A sign cast is refused when non-pattern alternatives are disallowed.

### Alchemy, skills and shrines

- Standalone Hearts of Stone and Blood and Wine starts: the kit (`StandaloneEp1_1`, `StandaloneEp2_1`) gives potions, bombs and oils whose recipe it does not teach (Thunderbolt, Dragon's Dream, Silver Dust Bomb, Devil's Puffball, Black Blood, Blizzard, Full Moon; in Blood and Wine also Cat, Golden Oriole, Killer Whale, Maribor Forest, White Honey and White Raffard's Decoction). 4.04 and 5.01 refill them at meditation without a recipe; Spectre does not, and v0.93 kept the 4.04 kit as it was, so they were gone after use. The kit also teaches the enhanced oil recipes (level 2), which Spectre's data does not have. `spectreLearnKitRecipes` teaches the level 1 recipe of every potion, bomb and oil in the inventory at the end of the kit (Spectre brews the better levels from it). Not with the vanilla alchemy package, which refills them.
- The focus perk reduces potion toxicity before the drink check. White Honey and mutation 12 are unchanged. Food that is not alcohol can apply the Cat perk.
- Minor places of power respect the new cap and the extra duration.
- Mutagen synergy uses the higher of the alchemy skill and the perk.
- The skill link bonus code is gone: the `LinkUpdate` calls when a skill or mutagen is equipped, removed or swapped, and the `SkillLinkBonus_*` abilities in `geralt_skills.xml`. The base game turned those bonuses off years ago (`UpdateLinkBonus` returns at once in 4.04 and 5.01, and 5.01 dropped the abilities), so nothing changes in play. `LinkUpdate` is private again, as in 5.01.
- A new game sets the remaster skill-refund fact. A save whose skill list is the wrong length fills in the missing skills.
- Undying's cooldown only removes the Undying buff.
- Low-health auto-heal from the accessibility menu feeds vitality regeneration.
- Heightened Tolerance's crit bonus is included.

### Meditation

- Leaving alchemy brewing restores the camera timeout that 5.01 meditation saves on enter.
- The alchemy panel button opens the menu when the fire setting does not require one. Before, it still asked for the meditation pose.

### Inventory and UI

- Weightless items apply only when that option is `"true"`.
- Runeword 13 and 14 show on the tooltip. Runeword 14 reads the Runeword 13 duration, as 5.01 does.
- Learning a recipe honors the no-notification flag. Giving an item passes the GUI flag through.
- Tooltips hide a weight of zero and show the transmog name and icon.
- Wolf Hour showed 240 seconds: the item has no `duration`, so the tooltip got only Spectre's added potion time. `CalculatePotionDuration` returns the `WolfHourEffect` duration (3600) for it. The vanilla alchemy package keeps Spectre's `WolfHourEffect` (with its stats); the 5.01 one has none, and Spectre's effect turns off without them.
- A whetstone opens the sharpen action. Selling is blocked when the inventory sets that flag.
- Dropping a stack refreshes the buttons and closes the popup if the drop is rejected.
- The loot window follows the mouse, closes merged containers, and take-all empties them.
- The free-bomb perk can skip ammo use.

### AI

- A player Aard only knocks down on the first damage-reduction tier.
- NPCs with additive hits use them. An instant dodge is available before the usual air and counter checks.
- Confusion no longer clears attitude while Axii's guard is still up.

## Strings

- `es.w3strings` uses the English text, with the Spanish language id. Without that file, a game set to Spanish showed the raw string keys.
- Ukrainian (`ua.w3strings`) with the English text. Without it, a game in Ukrainian showed the raw string keys for Spectre's lines.
- The other languages keep the v0.93 text, plus the English text of the lines added in this port.
- The skill tree notice reads "Skill tree updated." in every language. The other languages had no line for it, so the script showed a hard-coded Spanish text.
- Option hovers are shorter. A side remark goes on its own line, in blue, starting with "Note:"; a risk goes on its own line, in red, starting with "Warning:" (`<font color>` in the string). Rewritten: Version (only "Slide to 0 to reset Spectre to its recommended settings."), Use Spectre's skill tree, Starter skills: free first rank, General skills: work without a slot, Use Spectre's skill progression, Several mutations at once, Maximum mutations, Merchants get rid of what you sell.
- Skill texts no longer name Battle Trance, which the 5.01 menu never shows: Adrenaline Burst says each Adrenaline Point lowers the Stamina cost of melee actions; Battle Frenzy has its own text (`spectre_skill_desc_perk_19`).

## Bundle

What changed in `mod000Spectre/content/blob0.bundle` from v0.93. The bundle has 988 files, as before.

### Container

- Every XML is stored as UTF-8 with CRLF line ends, and every payload starts on a 4096-byte boundary: 5.01 hangs on a bundle packed without that alignment. v0.93 stored XML as UTF-16.
- `metadata.store` lists each file with its new size and offset. `dlc5_items.xml` had its old UTF-16 size there.
- It is built in one pass from the v0.93 release, the files in `bundle/` and the 5.01 game, and checked against `bundle/bundle.sha256` (see Building).

### XML

- The 20 XML files that 5.0 changed are rebased onto 5.01: Spectre's values stay, and what 5.0 added goes in beside them. Without this, the 5.0 abilities, effects and `gameplay.xml` entries disappeared while Spectre was loaded, and 5.01 scripts that read them failed. The files: `geralt_skills.xml`, `effects.xml`, `monster_base_abl.xml`, `monster_base_abl_new.xml` (each in `abilities` and `abilities_plus`), `gameplay.xml`, `def_item_quest.xml`, `def_item_ingredients.xml` (`items` and `items_plus`), `def_item_hairs.xml`, `monster_bob_base_abl.xml`, `geralt_skills_ep2.xml` (both folders), and from Hearts of Stone `geralt_skills_ep1.xml` (both folders), `monster_base_abl.xml` and `opp_base_abl.xml`.
- `geralt_skills.xml` (both folders):
  - The `SpectreVanillaTree` skill definition and the `spectre_vanilla_*` abilities hold the 5.01 tree and its values, for "Use Spectre's skill tree" off.
  - Spectre's skills get the numbers of the Skill rebalance.
  - 16 skill slots, as in 5.01. v0.93 had slots 17 to 26 and a backup block of the vanilla slots, both for Vladimir UI; they are removed.
  - The mutagen slots open at 2, 9, 16 and 28 skill points (`unlockedAtLevel`), as in 5.01. v0.93 had them open from the start.
  - A duplicated line in skill group 4 of `abilities_plus` is removed.
- `geralt_mutations.xml` (Blood and Wine, both folders): mutation slots 1 to 4 open with 2, 4, 8 and 12 researched mutations, as in 5.01. Slots 5 to 8, which only Vladimir UI used, are removed, and so is the yellow (General) color that v0.93 added to mutations of two or more colors.
- `geralt_stats.xml` (both folders): adds `spectre_vanilla_ConGeralt`, Geralt's 5.01 base stats, used with "Use Spectre's combat system" off.

### Flash

- `gameplay/gui_new/swf/character/panel_character_dupe.redswf` (new): the 5.01 skill menu, patched in eight classes.
  - `SlotPointIndicator`: rank as a number in the bottom right corner of the cell. In 5.01 the cell draws one diamond per rank and fills each one in as that rank is bought. Spectre's skills go to 10, so a bought-out cell filled with diamonds. The diamonds are not drawn. The number is the rank.
  - `CharacterSkillsGridModule`: cell positions and links (`skill.tree.pos.override`, `skill.tree.line.override`), so the tree has the vanilla links and the General cells sit as in 5.01.
  - `SlotSkillGrid`: hold R to buy every rank and hold Z (gamepad R3) to reset, with a fill animation. Holding E / gamepad X past the first rank (1 s, as in 5.01) keeps buying: the next rank starts when the cell gets its new data, each hold 0.6 times the last, down to 0.2 s. It stops at the maximum rank, without points, when another cell is selected or when the key is released; a refused rank (links) sends no new data, so it stops there too.
  - `MenuCharacterDupe`: sends `OnUpgradeSkill` with the skill id + 1000 (R) or + 2000 (Z); `characterMenu_AN.ws` reads that.
  - `CharacterTabbedListModuleDupe`: the key hints in E, R, Z order; the reset hint also shows with a gamepad, as R3.
  - `MutationsPanel`: a text field left of the mutation tree with "Active mutations: N/M" while "Several mutations at once" is on. The script sends it through the binding `spectre.mutations.counter` (wrap of `CR4CharacterDupeMenu.UpdateAllMutationsData`); `MenuCharacterDupe` keeps it until the panel exists. Hints in order: E "Activate/Deactivate mutation" (the base game only showed it in the tooltip), then R (gamepad X) "Use as main", which sends `OnEquipMutation` for the selected active mutation that is not the main one (`spectreCanBeMain`), which makes it the main one.
  - `MutationsPanel` also cuts the panel's background (`mcMutationBackground`, dark clouds in the corners) above the bottom bar, which it covered: with the mutation hints, the first ones were hidden.
  - `MutationItemRenderer`: the main mutation (`spectreShown`) has its ring and icon background tinted bright gold, with a gold glow around the ring.
  - `MasterMutationItemRenderer`: with more than one mutation active, the skill tab's center shows, under the main one's name, what the main mutation does (`spectreCenterDescription`) instead of its description, which read as if only that one worked and ran past its space.
  - With several mutations marked equipped, `MenuCharacterDupe.setMutationDataList` takes the one the script marks `spectreShown` (the last equipped, whose colors the middle slots use) for the center; before, it took the first in the list.
- `gameplay/gui_new/swf/popups/popup_loot.redswf`: Spectre's 4.04 loot window (weight, price and stock columns), with `LootPopupMenu` fixed. It is created hidden (`visible = false` in the constructor), shows itself when `LootItemList` arrives (`resetVisibility`), and `SetWindowScale` no longer shows it. Before, one frame showed the panel's sample rows.
- `gameplay/gui_new/swf/common/componentslib.redswf` (new): the 5.01 shared component library, with `TooltipSkill` aligning the skill descriptions (current and next rank) left instead of centered, as the game already does right for Arabic. Every menu's skill tooltip comes from this file, so another mod that ships it conflicts with Spectre.
- Unchanged from v0.93: `panel_alchemy.redswf` (Spectre's alchemy menu, works on 5.01) and `panel_character.redswf` (the classic skill menu, which 5.01 hides).

### Entities, scenes and quest files

v0.93 carries 653 CR2W files (`.w2ent`, `.w2scene`, `.w2phase`, `.journal`, `.w2behtree`, `.w2comm`, `.w2l`). 649 exist in 5.01, and 627 of those differ from it, although only 22 are on the list of files 5.0 changed. They were not made from 4.04:

- About 220 are CR2W version 162, saved by game versions before 1.32. About 380 were saved by a mod tool (build 0 or an editor build), from 1.32 or older files. None has the size of its 4.0 version; 175 have exactly their 1.32 size.
- So they lacked what 4.0 and 5.0 added: finisher dismemberment physics (408 files), `man_dialog_customs` and `mq1060_man_quest_customs` animations (258), immunities 60 and 61 (124), the `rangeShort` attack (136), loot containers (71), grass colliders (37), wetness (48), high-resolution shadows (29), `NPCDoNotGainBoost` on bosses.

How it was redone:

- The 1.32 originals come from the Steam `classic` branch, which is 1.32. A three-way comparison per object and property separates Spectre's edits (1.32 to Spectre) from CDPR's (1.32 to 5.01). A Spectre edit goes on the 5.01 file only where 5.01 kept the 1.32 value.
- In version 162 files, what they add or lack against 1.32 is old game content, not Spectre's work. From those, only levels and additions to lists are taken.

Result: 641 files are the 5.01 ones with Spectre's edits, 12 stay as in v0.93.

- **Value edits** (333 files):
  | Edit | Files |
  |---|---|
  | `level` (Spectre's enemy levels) | 235 |
  | `levelFakeAddon` set to 0 where Spectre sets the level (`npc_AN.ws` sets it to 0 anyway, so the level would be 0) | 51 |
  | `usedContainersMin`/`Max` 3 to 5 | 39 |
  | Attack range `rangeMax` (e.g. the elemental dao, 2.0 to 3.0) | 22 |
  | `monsterCategory` | 19 |
  | Contract monster and rat levels | 7 |
  | Prices: Ofieri enchanter 3000/6000/9000 instead of 5000/10000/15000, Vimme Vivaldi | 3 |
  | Projectiles and hazards: damage, `destroyQuen`, `ignoreArmor`, `dealDamageEvenIfDodging`, debuff duration (sorceress and lynx rock witch stones, dracolizard fireball, sprigan root, quicksand, toad acid pool and mortar) | 13 |
  | Explosive bolt range, inventory quantities | 2 |
- **Structural edits** (190 files):
  | Edit | Files |
  |---|---|
  | `CCharacterStatsParam.abilities` merged three ways, so Spectre's additions and removals sit on the 5.01 list: `NPCDoNotGainBoost`/`NoAdaptBalance` on rats, mice and doppelgangers, `ConHumanoidMonster`, and others | 119 |
  | `level` added where only Spectre had it (Dettlaff, Regis, Olgierd, fist-fight opponents, the Hearts of Stone toads, the sq204 wolves, rats, Dettlaff's columns, the tree heart, and others), with `levelFakeAddon` 0 | 38 |
  | Recommended oils and bombs (`itemsUsedAgainstCreature`), e.g. Insectoid Oil on the Blood and Wine spiders | 12 |
  | Renamed loot (`itemName`): Wild Hunt swords 3 and 4, greater mutagens | 12 |
  | Immunities (Gregoire, the q604 caretaker) | 4 |
  | Damage type of the water mage's sand coil (`sand_coil_proj_bob`) | 1 |
  | Objects added: `CR4LootParam` on the golems and the mq2052 troll, `CInventoryDefinition` and entries on the mq2052 monsters and q601, Eskel's loot in q401, the bump, presence and rain reactions of the q202 trolls | 12 |

  The new names, imports and objects go in the file's tables. Both the entity template and its `flatCompiledData` copy, the one the game spawns from, are edited.
- **Kept as in v0.93**:
  - 5 files that 5.01 did not change from 1.32, edited by Spectre on 1.32: two bestiary entries, the enchanter's scene and quest (`mq6005_painite_enabled`, 3000 crowns) and the mq6003 journal block. Objects and values are compared decoded (names, references, imports); a value that cannot be decoded counts as changed, so a file stays Spectre's only when nothing at all changed.
  - 3 bestiary entries to which Spectre only adds (mh303, djinn, succubus).
  - 4 files the 5.01 bundles do not have (three enchanter scene copies, and a Kaer Morhen layer, `spire_path.w2l`, whose 5.01 copy sits in a world bundle that is not compared).

Left as 5.01:

- What version 162 files lack against 1.32: `rangeShort` (137), the 2 loot containers (71), the lesser blue mutagen of the vampires, `PersistentCameraLock` and other abilities.
- What version 162 files add: Fergus's and the master blacksmith's combat AI (5.01 makes them flee), three blacksmith and quartermaster voicesets, the focus sound of two boars, and `NPCDoNotGainBoost` taken off Dettlaff, Regis and Olgierd. That ability only stops the New Game+ level boost.
- `monster_bies_logic.w2behtree` (the fiend's AI, with the 5.01 dodges). The 1.32 download has no copy, so Spectre's edits there cannot be told apart.
- The fiend and czart charge probe (`ObstacleProbe`): the same doubt.
- Four damage values 5.01 also changed:
  - Dettlaff's swarm: 30 (1.32: 1000, Spectre: 600). The swarm does not stop on collision, and `W3AdvancedProjectile.OnProjectileCollision` adds 2.5% per Geralt level on every collision, so at 600 it could kill in one hit; 30 is the vanilla value since 4.0.
  - Echinops acid: 500 (Spectre: 350).
  - The Hearts of Stone toad's spit: 500 (Spectre: 200), and its tongue: 400 (Spectre: 300).

Brothers in Arms ships about 45 of these same files. As with v0.93, the mod that loads first wins for them.

## For modders: the port to 5.01

### Scripts

- Renamed the `set` parameter to `itemSet`; the 5.01 compiler treats `set` as a keyword.
- Areas are names. `EAreaName` and the `AN_*` enum values are gone.
- `EActorImmortalityChanel` is `EActorImmortalityChannel`. `AIC_IsAttackableByPlayer` is `AIC_Cheat`. `AIC_UndyingSkill` stays.
- `CastSign`, `HasFreeToxicityToDrinkPotion` and `GetItemTooltipAttributes` use the 5.01 signatures.
- The 21 full script overrides are merged with vanilla 5.01 and keep the Spectre blocks.
- The new 5.01 effect names are registered, including Catalyst, Convergence, Resonance, Overload cooldown, Avoidance, Undying and Element of Surprise.
- The 5.01 tree lives in `src/local/annotations/gameplay/ability/spectreSkillTree_AN.ws`: `SpectreTreePairs` is the only list of which Spectre skill takes which 5.01 cell, and `spectreVanillaSkills()` is what every script asks to tell the trees apart. The 5.01 skill definitions are in the `SpectreVanillaTree` definition of `geralt_skills.xml`, and the 5.01 values in the `spectre_vanilla_*` abilities. The menus get each skill by its skill name, since the 5.01 tree's skills use those copies as their ability.
- The Equipment and Combat options live in `src/local/annotations/player/spectreEquipment_AN.ws` and `spectreCombat_AN.ws`.
- Uninstall: `src/local/annotations/player/spectreUninstall_AN.ws`. `SpectreUninstall` runs the skill, ability, item and saved-data cleanups, builds a `W3PlayerAbilityManager` that takes the state of `spectreAbilityManager` (`SpectreCopyStateFrom`), clears `alchexts.abltymgr`, removes the `RemasterSkillResetAndRefund` fact so the base game refunds on load, and saves.
- Skill menu keys: the panel sends `OnUpgradeSkill` with the id + 1000 (hold R, `SpectreBuyAllRanks`) or + 2000 (hold Z, `SpectreResetSkill` in `spectreSkillTree_AN.ws`). The reset collects the learned skills linked after the chosen one that would lose every link (`SpectreLinksSatisfied`), resets them last to first, then calls `RefreshSkillsEffects`. The old reset flag (`spectreResetSkill`), its branches in `UnequipSkill` and the Z toggle (`commonMenu_AN.ws`) are gone.
- Mutations: `SetEquippedMutation` is replaced. By default the list holds one mutation (cleared, then pushed, then `MutationsEnable`, in that order so the slots unlock); with "Several mutations at once" (`SpectreMultipleMutations`, `spectreMultipleMutations` in the Skills group), an inactive mutation is added first, so the main one (the last) stays, and equipping an active one moves it to the end (the main one), and `EPMT_None` takes off only the last. `SpectreSyncMutations` (on load and when the skill options apply) adds every researched mutation once when that option is on (saved flag `spectreAllMutationsActive`) or trims to one (`SpectreKeepOneMutation`) when it is off; `OnMutationFullyResearched` adds each new one. With "Use Spectre's skill progression", `GetMutationsRequiredForMasterStage` returns 0 and `UpdateMutationSkillSlotsLocks` opens the middle slots without a mutation. `GetResearchedMutationsCount` no longer adds 12.
- 5.01 mutation menu with "Several mutations at once": wraps of `CR4CharacterDupeMenu.CreateMutationFlashDataObj` mark every active mutation `isEquipped` (the panel's `MutationItemRenderer` draws the white ring for each), `OnMutationSelected` keeps the selected one, and `OnUnequipMutation` takes off that one (`SpectreDeactivateMutation`) instead of the last.
- Maximum mutations: `SpectreMaxMutations` / `SpectreCanActivateMutation` limit `SetEquippedMutation`, `SpectreSyncMutations` and `OnMutationFullyResearched`; a wrap of `CR4CharacterDupeMenu.OnEquipMutation` shows the message. `spectreUpdateMaxMutationsMenu` greys the slider out (page open, option change, preset).
- Mutation system: `Init` opens it only with "Mutations from the start" (`SpectreMutationsFromStart`). `SpectreApplyMutationSystemOption` runs with the skill options: with the option off, the system stays open only if the quest opened it (`SpectreMutationQuestDone`: the fact `mq7023_done`, set when mq7023 ends, or `spectre_mutation_system_by_quest`, set by a wrap of `W3PlayerWitcher.MutationSystemEnable`, which mq7023 calls in Regis's lab). Otherwise it closes and the equipped mutations come off.
- Slots: `SpectreDropExtraSlots` removes save slots the XML no longer has; `SpectreRefreshMutagenSlots` rereads `unlockedAtLevel` (0 with Spectre's progression) and unequips mutagens from locked slots. Both run from `SpectreApplySlotOption`.
- Merchants: `SellItem` marks the sold quantity on the item the shop gets (`spectreSoldQuantity` modifier), and the inventory menu's `OnClosingMenu` takes that quantity out of the shop's inventory (`spectreClearSoldItems`), also on `OnSpawned` of `W3MerchantNPC`. Most 5.01 merchants are not `W3MerchantNPC`, so v0.93's loop on that class did not reach them.

### XML

- The 20 changed gameplay XML files are rebased onto 5.01 inside `blob0.bundle`. The readable copies sit in `bundle/xml`, together with `geralt_mutations.xml` (Spectre's v0.93 file without the yellow mutation color) and `geralt_stats.xml` (which adds `spectre_vanilla_ConGeralt`, the 5.01 base stats used with Spectre's combat system off).
- Spectre's skill layout and max levels stay. New 5.01 skills, effects and monster abilities are added beside them.
- Whirl keeps Spectre's stamina cost. Wolf dodge and the rewritten monster stats stay Spectre's.
- Quen discharge stays on Spectre's Active Shield. The 5.01 discharge number is not copied onto Quen Impulse.
- Melt Armor keeps the 5.01 burn chance.
- `dlc5_items.xml` is listed in the bundle index with its UTF-8 size. The index still had the old UTF-16 size.

### Building

- `bundle/build_bundle.py` builds the bundle from the v0.93 release and the files in `bundle`.
- `bundle/entities501.json` takes 641 entities, scenes and quest files from the 5.01 game, checked by SHA-256. Spectre's edits go back in two steps: value patches in place, then structural edits replayed by `bundle/cr2w_ops.py` (list merges, new names, added properties and objects), with the result checked by SHA-256. Each edit was found by comparing Spectre's file with the 1.32 original, and is applied only where 5.01 kept the 1.32 value. Additions and removals in files saved by game versions before 1.32 (CR2W 162) are old content, so those keep the 5.01 version, except for levels. `build_bundle.py` and `pack-release.ps1` need the 5.01 game folder for it (`--game` / `-Game`; `pack-release` finds it in the Steam libraries).
- `pack-release.ps1` builds `spectre_release_vX.zip` with `bin`, `mods` and `dlc`. `-Base` rebuilds the bundle from the v0.93 release; `-Bundle` takes the published bundle and checks it against `bundle/bundle.sha256`. It builds the `.w3strings` from `strings/en.csv` first (`strings/build_w3strings.py`), so a text changed there always ships. `es.w3strings` gets that English text. The other languages get the English text of new or changed lines and keep their own translations.
- The release no longer ships `mod_EH_Shared_Imports`. Its engine files were the 4.04 ones, and Spectre does not need them on 5.01.
