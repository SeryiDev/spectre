# Spectre 0.94 on The Witcher 3 5.01

Spectre v0.93 (for 4.04) brought to The Witcher 3 5.01 (next-gen). The in-game version is 0.94.

What stays: Spectre's combat, signs, alchemy, enemy scaling, looting and its 10-rank skills. What is new: the 5.01 skills and effects Spectre never had, a choice between Spectre's skill tree and the 5.01 one, several menu options to turn Spectre's systems off one by one, a skill rebalance so every rank counts, and the fixes found while playtesting on 5.01.

Numbers for skills are given for ranks 1 / 5 / 10. "Before" means Spectre v0.93, unless it says 5.01.

## Highlights

- **Two skill trees.** "Use Spectre's skill tree" picks Spectre's 10-rank skills or the 5.01 tree exactly as in the base game. Switching moves your ranks over and never resets the tree.
- **Turn Spectre's systems off one at a time.** New menu sections for Equipment and Combat, "Off" presets for Skills, Equipment, Combat, Gameplay, Looting and Scaling.
- **Skill rebalance.** Every rank of every 10-rank skill adds something, no skill reaches its cap before rank 10, and no bonus turns negative like before.
- **General Spectre skills work without a slot**, as Spectre intended, and the school techniques count the armor you wear.
- **Better character stats**: the real toxicity decrease rate, potion duration and bomb damage bonuses, and Sign Intensity per sign with decimals.
- **Spectre can be uninstalled from a save.** Before, it could not: a save loaded without Spectre lost Geralt's skill tree, skills, mutations and stats, with no way back. The new option "Remove Spectre from this save" prepares the save, and loaded without Spectre it plays as the base game (see Fixes).
- **Spanish translation** added.
- **5.01 fixes**: dismounting, gear loading, starter skills charging points, enemy scaling options that were ignored, and more (see Fixes).

## Options you can change

All of these are in the game menu under Spectre. Each option shows what it does when hovered, in the left-side popup Eternal Hunt also uses (the old text at the bottom of the menu is gone). Every group with presets starts with "Recommended".

### Skills

- **Use Spectre's skill tree** (on). Off: the 5.01 skill tree, 100% as in the base game (see Skill tree).
- **Starter skills: free first rank** (on). Whirl, Rend, Arrow Deflection, Cold Blood, Razor Focus, Delusion, the five alternate sign modes and the first skill of each sign start at rank 1 for free, as in Spectre v0.93.
- **Starter skills: work without a slot** (on). Those skills work without being equipped.
- **Use Spectre's skill progression** (off). On: all 16 skill slots open from the start, as in Spectre v0.93. Off: slots open as in 5.01.
- Presets: Recommended, and "Off" (all four off: the 5.01 tree as in the base game).
- Setting the version to 0 also resets this group.

### Equipment (new)

- **Equip gear of any level** (on, as in Spectre v0.93). Off: gear above Geralt's level cannot be equipped, as in the base game, and its tooltip shows the level it needs. Turning it off unequips the gear above his level.
- **Gear rises to your level** (on, as in Spectre v0.93). Off: equipped weapons and armor keep their own level; gear that already rose keeps it. Crossbows never rise, as in the base game and v0.93.
- Presets: Recommended, and "Off" (both off: level requirements and fixed levels, as in the base game).

### Combat (new)

- **Use Spectre's combat system** (on). Off, as in the base game:
  - Geralt's base stamina values come from 5.01: attacks, parries, dodges, rolls and items cost no stamina, sprint and jump cost 12.5, stamina regenerates 10% per second.
  - Hits take Adrenaline, and poison and bleeding resistance are, as in 5.01.
  - Armor and overloading no longer change stamina costs; armor slows stamina regeneration again.
  - Whirl, Rend and the signs have no cooldown, and Rend released early costs no extra stamina.
  - Quick sign casting is off.
  - The other Combat options do nothing and are greyed out.
  - Switching keeps your current Adrenaline, stamina and vitality.
  - Dodging, counterattacks and parries keep Spectre's rules either way.
- Quick sign casting, the armor stamina regeneration penalty, stamina and vitality regeneration in and out of combat, the sprint, melee and sign stamina costs, the stamina delay, and the Whirl/Rend, sign and alternate sign cooldowns. These moved here from Gameplay. Players coming from v0.93 get the recommended values for them.
- Presets: Recommended, Old version, and "Off" (also turns off "Use Spectre's combat system").

### Gameplay

- Keeps the boat sinking when overloaded, its threshold, and the item weight reduction.
- Presets: Recommended, and "Off" (the boat never sinks, items keep their weight).

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
  - Off: every skill is the 5.01 one, as in the base game: cells, links, ranks, names, texts, values (5.01 copies of the abilities Spectre changed, `spectre_vanilla_*`) and effects. Spectre's own alchemy skills give way to the 5.01 skills with the same ids. Only the starter skills work without a slot, if their option is on; every other skill needs one, as in 5.01. Spectre's combat, sign and alchemy systems stay; each 5.01 skill applies its 5.01 rule inside them.
- **Switching does not reset the tree.** Each skill passes its ranks and its slot to the skill that takes its cell, up to that skill's maximum; ranks above it come back as unspent points (a shared skill at rank 10 keeps 3). A starter skill's free rank goes with it. The tree is kept in the save, so changing the option with the game closed moves the ranks on the next load. Before, the old option reset the tree and refunded every point, so it worked as a free respec. A character made without Spectre still gets its tree rebuilt once, with every point refunded.
- **The 5.01 tree shows correctly**: every branch with its skills and links, no flickering, and the skills Spectre had changed can be bought. Its tooltips end with the 5.01 per-rank bonus (Adrenaline gain, stamina regeneration, potion duration and bomb damage, vitality) instead of +0.
- **5.01 per-rank bonuses** go to the skills that count as equipped, as in 5.01 (slotted skills, plus the starter skills without a slot while their option is on). They are counted again from scratch whenever the skill options apply, so loading a save never stacks them. Each alchemy rank raises bomb damage again, as in 5.01; Spectre's damage code had dropped it.

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
- Loading a save no longer buys the starter skills with skill points. v0.93 bought them at rank 1 on every load and charged a point for each when there were free points.

### Slots

- Skill slots open as in 5.01. The 12 slots linked to mutagens open with total skill points, mutation points included (0, 2, 4, 6, 8, 10, 12, 15, 18, 22, 26, 30). The 4 middle slots open with researched mutations (1, 2, 3 and 4 in Spectre; 2, 4, 8 and 12 in 5.01) and only while a mutation is equipped. Spectre v0.93 opened all 16 from the start and counted 12 extra researched mutations; "Use Spectre's skill progression" brings that back. On an older save, and when the option changes, skills left in slots that are now locked are unequipped.
- A skill in a slot that gets locked is taken out of it. Spectre's unequip only looked at open slots.
- A skill that works without a slot keeps its effect when it is taken out of a slot. Before, unslotting a General skill turned it off until the save was loaded again.
- Mutations take the same skill colors as in the base game. Spectre's `geralt_mutations.xml` added yellow (General skills) to the mutations of two or more colors; the remaster menu repeated the previous color's name in the tooltip and never let a General skill into the middle slots, so it is removed. Equipping checks the colors too, since the classic menu's border art would still let a General skill in. The classic menu's three-color border finds its art (`RedgreenBlueYellow`; it asked for `RedGreenBlueYellow`, which does not exist).

### Menu

- In the remaster tree, each bought skill shows its rank as a white number on a dark square in the bottom right corner of its cell, as in Spectre v0.93 on 4.04, instead of one pip per rank (with 10 ranks the pips ran over the next cells). The tooltip still shows the rank and the maximum (3/10).
- In the remaster tree, holding R on a skill buys every rank your points and its links allow. The hint "R [Hold] Acquire up to max rank" shows next to the E one, with keyboard and mouse.
- The top line of every skill tooltip says whether the skill is passive (works without a slot) or needs to be equipped. Before, only Half-Life said it was passive.
- With Spectre's tree, 5.01 tooltips no longer end with "Adrenaline point gain: +0%", "Stamina regeneration: +0/s" or "Vitality gain +1%": Spectre does not give those bonuses per skill.
- In the remaster menu, the 5.01 alchemy skills (Heightened Tolerance, Toxic Shock, Volatile Concoction, Debilitating Poison) show their numbers instead of $I$ and $F$. Skills past Spectre's range use the 5.01 text in both menus.
- A new Blood and Wine or Hearts of Stone standalone game gets the remaster skill reset and refund, and Spectre's tree is applied without the notice.

## Skill rebalance

Spectre's skills go to 10 ranks on purpose: with Eternal Hunt, skill points can be farmed without limit. Every rank now adds something, the cap is reached at rank 10 and not before, no reduction goes below zero, and the tooltip shows the real value.

### General rules

- Combat and sign skills need a slot to work, as in the base game, except the starter skills while their option is on. A loaded save drops the effects of the others that are bought but not slotted.
- Spectre's alchemy skills that help in combat need a slot: Catalysis, Equilibrium, Mitogenesis, Metastasis, Frenzy, Angiogenesis, Adaptation and Autophagy. Before, all eleven worked without one, so maximum vitality and toxicity bonuses came for free. Half-Life, Alembic and Proficiency, which do nothing in combat, still work without a slot.
- General skills work without a slot, all of them.
- Sign Intensity curve. Wherever Spectre turns Sign Intensity into a bonus with a curve (Axii duration, Quen shield absorption, Yrden slowdown, Aard knockdown, sign critical hits, Melt Armor), it counts one to one up to +100% and gives less for each extra +50% after that. Damage still scales one to one.
  | Sign Intensity  | Bonus now | Spectre v0.93 |
  | --------------- | --------- | ------------- |
  | +50%            | +50%      | +40%          |
  | +100%           | +100%     | +75%          |
  | +150%           | +130%     | +105%         |
  | +200%           | +155%     | +130%         |
  | +300%           | +190%     | +165%         |
  | +500% and above | +225%     | +220%         |
- The first skill of each sign (Aard: Far-Reaching, Igni: Melt Armor, Yrden: Sustained Glyphs, Quen: Exploding Shield, Axii: Delusion) adds 2.5% Sign Intensity to its own sign per rank, 25% at rank 10, while slotted. 4.04 gave each sign an intensity skill of 5 ranks of 5%; these skills have their own effect on top, so they end at the same 25%. In English and Spanish their names start with the sign. The five sign intensity skills are off the tree and get no free rank.
- Descriptions that scale with Sign Intensity end with "Damage scales with Sign Intensity (current damage: N)". The "Sign Intensity: +N%" line of the first skill of each sign is always last, with one decimal when it has one.

### Combat

- **Whirl**: spinning attack that hits everyone around and drains Stamina and Adrenaline. Cost: 100% / 60% / 10% (10% less per rank after the first). Before: 15% less per rank, free and then negative from rank 8.
- **Rend**: charged heavy attack that goes through blocks, armor and shields. Critical chance: 10% / 50% / 100% (+10% per rank). Before: +20% per rank, 100% at rank 5. Its description was reordered: the extra damage it lists only applies to Rend itself, and the shock wave radius is given in meters in Spanish.
- **Crippling Strikes**: chance to make an enemy bleed on a fast attack: 2.5% / 12.5% / 25%. Before: 5% per rank, 50% at rank 10. The damage bonus is unchanged.
- **Deadly Precision**: a melee hit on an enemy you just countered can kill it outright, with 0.5% / 2.5% / 5% chance per Adrenaline Point (15% at rank 10 with 3 points). Enemies immune to instant kills, and special attacks such as Whirl and Rend, are excluded. Before: 1% per rank and point, 30% at rank 10.
- **Counterattack**: the attack after a counter gets 15% / 75% / 150% more attack power and 25% / 58% / 100% more critical chance (25% plus 8.33% per rank after the first). Before: +33.4% attack power per rank (+334% at rank 10), and 35% critical chance per rank, over 100% from rank 4. Rank 10 still counters on its own while guarding.
- **Arrow Deflection**: parries block 55% / 75% / 100% of the damage (50% plus 5% per rank). Reflected arrows deal x1 / x3 / x5.5 (+50% per rank after the first) on both arrow types. Before: 100% blocked at rank 5 and a negative number in the tooltip after it; reflected arrows dealt x(2 x rank + 0.5), and the other arrow type only got its bonus at exactly rank 3.
- **Fleet Footed**: damage from hits that land during a dodge is reduced by 9% / 45% / 90%. Before: 10% per rank, and rank 10 hit the game's 95% cap.
- **Resolve**: Adrenaline lost to hits is reduced by 9% / 45% / 90%. Before: 20% per rank, and from rank 6 hits gave Adrenaline.
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
- **Focus** (from 5.01, now 10 ranks): each Adrenaline Point raises Sign Intensity by 3% / 15% / 30%. Before: 3 ranks of 10%. Spectre's General Focus skill stays off the tree, since this one does the same.
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
  - **Synergy** (from 5.01, now 10 ranks): mutagens in mutagen slots give 5% / 25% / 50% more bonus, and each rank applies at once. Before: 3 ranks of 10%, it needed a slot, and buying or slotting it did not apply the bonus until a mutagen was equipped again. Each rank adds a mutagen's synergy bonus, which is now 5% of the mutagen's bonus instead of 10%. Spectre's alchemy Synergy stays off the remaster tree, as in 5.01.
  - **Gorged on Power** takes the Element of Surprise cell. It had no cell before, since 5.01 removed its own. Points spent on Element of Surprise are refunded. It shows its own icon, the monolith; before, the cell was empty.
  - Off the tree: Spectre's General Cold Blood, Trick Shot, In Combat's Fires, Heavy Artillery and Focus; 5.01's Element of Surprise.
- **Cat, Griffin and Bear School Techniques** count light, medium and heavy pieces, as before.
- **Metabolism Boost** works without a slot: potions digest 33% faster and last 33% less, and toxicity falls 33% faster, as soon as it is bought. Before: only while slotted.
- **Metabolic Control** works without a slot and adds 15 maximum Toxicity, as its tooltip says, as a base value: percent bonuses such as Metastasis apply on top of it (100 + 15, then +10%). Before: it needed a slot, added 30, percent bonuses did not count it, learning a recipe took the bonus away, and unequipping it kept it. A save that had it bought gets the new bonus on load.

## Other gameplay and interface changes

- **Merchants keep what you sell them**, as in the base game, so you can buy it back. Spectre v0.93 deleted sold items once the shop closed, except weapons and armor of quality 4 or higher.
- **Character stats**:
  - Toxicity shows the real decrease rate: the base game drain plus Spectre's (Toxicity menu settings, potions working off their toxicity, Metabolism Boost, Autophagy, meditation). Before, only the base game drain, so Spectre's settings and skills never changed it.
  - "Others" shows how much longer potions last (Potions menu multiplier, Half-Life, Equilibrium, Metabolism Boost, and the 5.01 alchemy ranks) and how much more damage bombs deal (Heavy Artillery, Manticore School, the toxicity bomb skill, and the 5.01 alchemy ranks).
  - The two sign sections are titled "Aard, Igni, Quen" and "Yrden, Axii". Before, both showed the general Sign Intensity outside, which leaves out what raises only one sign; each sign's own intensity is inside. Sign Intensity shows one decimal when it has one (22.5%, not 22%).
  - Stamina comes before the signs.
- The sign stat panel includes Conjunction on Aard, Igni and Yrden, and Melt Armor on Igni's burn chance.
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
- Toxic Shock, Catalyst, Conjunction, Resonance, Element of Surprise, the bomb perks, crippling strike and the new oil bonuses run inside Spectre's damage pass. Bomb bonuses add into Spectre's single damage multiplier; 5.01 multiplies each one on its own, so several together give a bit less than 5.01.
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

- The focus perk reduces potion toxicity before the drink check. White Honey and mutation 12 are unchanged. Food that is not alcohol can apply the Cat perk.
- Minor places of power respect the new cap and the extra duration.
- Mutagen synergy uses the higher of the alchemy skill and the perk.
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
- A whetstone opens the sharpen action. Selling is blocked when the inventory sets that flag.
- Dropping a stack refreshes the buttons and closes the popup if the drop is rejected.
- The loot window follows the mouse, closes merged containers, and take-all empties them.
- The free-bomb perk can skip ammo use.

### AI

- A player Aard only knocks down on the first damage-reduction tier.
- NPCs with additive hits use them. An instant dodge is available before the usual air and counter checks.
- Confusion no longer clears attitude while Axii's guard is still up.

## Strings

- Spanish (Spain) translation. `strings/es.csv` is the source, compiled into `es.w3strings`.
- Ukrainian (`ua.w3strings`) with the English text. Without it, a game in Ukrainian showed the raw string keys for Spectre's lines.
- The other languages keep the v0.93 text, plus the English text of the lines added in this port.
- The skill tree notice reads "Skill tree updated." in every language. The other languages had no line for it, so the script showed a hard-coded Spanish text.

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

### XML

- The 20 changed gameplay XML files are rebased onto 5.01 inside `blob0.bundle`. The readable copies sit in `bundle/xml`, together with `geralt_mutations.xml` (Spectre's v0.93 file without the yellow mutation color) and `geralt_stats.xml` (which adds `spectre_vanilla_ConGeralt`, the 5.01 base stats used with Spectre's combat system off).
- Spectre's skill layout and max levels stay. New 5.01 skills, effects and monster abilities are added beside them.
- Whirl keeps Spectre's stamina cost. Wolf dodge and the rewritten monster stats stay Spectre's.
- Quen discharge stays on Spectre's Active Shield. The 5.01 discharge number is not copied onto Quen Impulse.
- Melt Armor keeps the 5.01 burn chance.
- `dlc5_items.xml` is listed in the bundle index with its UTF-8 size. The index still had the old UTF-16 size.

### Building

- `bundle/build_bundle.py` builds the bundle from the v0.93 release and the files in `bundle`.
- `pack-release.ps1` builds `Spectre.-.Release.-.vX.zip` with `bin`, `mods` and `dlc`. `-Base` rebuilds the bundle from the v0.93 release; `-Bundle` takes the published bundle and checks it against `bundle/bundle.sha256`. It builds the `.w3strings` from `strings/en.csv` and `strings/es.csv` first (`strings/build_w3strings.py`), so a text changed in a `.csv` always ships; the other languages get the English text of new or changed lines and keep their own translations.
- `install-release.ps1` builds the zip and installs it. It first moves the old Spectre install to `build\old-install-<time>`, then checks every installed file against the zip.

### Left as Spectre

- Perk 10 and perk 42 do not grant focus when a sign starts. Spectre removed that.
- A skill needs at least rank 1 to count as usable, as in 4.04. 5.01 also lets core skills work at rank 0; Spectre's check does not.
- Color-link bonuses still refresh when a skill or mutagen is equipped or removed.
- Temporary sign skills still use Spectre's Flood of Anger path.
- Mutation 11 does not play the 5.01 haptic.
- Friendly Axii damage stays on Spectre's health-percent formula. Puppet's attack-power multiplier is added on top.

