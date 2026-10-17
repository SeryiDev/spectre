# Spectre 5.01 playtest

Original Spectre behavior only. Things the base game already does are not on this list.

Status is `Pass`, `Fail` or `Not tested`. A pass matches the behavior described on that line.

## Herbs

- **Pass.** Harvest yield is 3 to 6. Gathering one normal plant gives that many of its herb.
- **Pass.** A normal gather does not take a second plant. With the herb scan range at 64, two plants standing together still require two gathers. The range applies only when a loot window opens.
- **Not tested.** Empty plant spots can return after a wait between the spawn minimum and maximum. Recommended, that wait is 10 to 20 seconds, and about one spot in three returns, at the 30% chance.
- **Not tested.** Ignore herb spawns. On, an empty plant spot stays empty.
- **Not tested.** Mod alchemy icons show on herbs and alchemy items.

## Meditation and brewing

- **Pass.** L enters the meditation pose. Holding L also builds a fire. L again opens the alchemy menu. Holding L stands up. Space passes time.
- **Pass.** With "Alchemy Requires" set to no fire, the alchemy button in the menu opens a screen that can brew. With a fire required, that button stays closed and brewing stays on the meditation pose.
- **Pass.** Any interactive fire accepts a forge. The campfire-only option does not accept that forge.
- **Not tested.** Brewing near a lit campfire, including indoors. Casual alchemy is off, so brewing from the road is refused.
- **Not tested.** Building a campfire is allowed. Holding L in the meditation pose spends 3 timber and lights a fire. With campfires off, that hold does not light one.
- **Not tested.** Interior campfires are allowed, so that fire can be built indoors. Off, it cannot.
- **Not tested.** Casual alchemy. On, brewing works from the road, without the meditation pose. Off, brewing stays on the pose, a table, or a valid fire.
- **Not tested.** One brew takes about 10 minutes of game time. One distillation takes about 20. Turning time-based alchemy off finishes them without moving the clock.
- **Not tested.** During a brew, or while time is passing, the camera turns at the rotation speed. At 1 it turns. At 0 it stays still. Leaving the alchemy screen restores the camera. It does not keep spinning.
- **Not tested.** One brew produces 1 item at the recommended yield.
- **Not tested.** Alcohol lasts 2 uses. An empty bottle comes back when a potion is drunk.
- **Not tested.** Primary-substance recipes share Spectre's ingredient list. Albedo, Rubedo, and Nigredo keep their own recipes.
- **Not tested.** Mod mutagens. On, mutagen recipes use Spectre's ingredient list. Off, they keep the base recipes.

## Potions and toxicity

- **Pass.** After drinking, the potion metabolizes for about 30 seconds. Its real effect starts when that digestion ends.
- **Pass.** Added duration. With the override at 0 and 240 seconds added, Swallow's timer reads 4:30 (its own duration plus 4 minutes).
- **Pass.** Swallow's timer stays still while vitality is full, and is meant to run again once vitality is missing. Confirmed while standing at full health. Not rechecked after taking a hit.
- **Not tested.** Tawny Owl pauses the same way at full vitality, and also pauses at night on the superior version.
- **Not tested.** Potion, bomb, and oil stack limits. At 0, each item keeps its own stack size. A higher number replaces that size.
- **Not tested.** Potion duration override. At 0, the potion keeps its own duration and the added seconds apply. Any other value replaces the duration, and the added seconds are ignored.
- **Not tested.** Potion duration multiplier. At 0 the duration is unchanged. At 2 it is doubled, after the override and the added seconds. Decoctions follow the same three rules. Their recommended override, added seconds, and multiplier are all 0.
- **Not tested.** Potion toxicity is multiplied by 1.25, plus 0.5 at level 2 and plus 1 at level 3.
- **Not tested.** Toxicity falls on its own outside combat and does not drain vitality during a fight. The recommended clear rate is 0.24 under the threshold. Above 72% of the bar, the clear rate is 0.16.
- **Not tested.** Combat degeneration is off, so a fight uses the same clear rate as standing still. On, a fight uses the combat rate.
- **Not tested.** After the potion effect has ended, toxicity keeps falling at the residual rate, 0.05 of the bar. It does not fall during the 30 seconds of digestion.

## Area loot

Opening one container can pull others of the same kind into that loot window. A normal herb gather does not. Ranges are in meters.

- **Pass.** Clutter range at 0. Four chests standing together do not share one window. Each open shows only that chest.
- **Pass.** Clutter range above 0. Open one sack, chest, or barrel and a second one in sight, inside the range, is in the same window. Taking everything empties the second one too.
- **Pass.** Remains range. Looting one corpse includes another corpse in sight inside the range.
- **Not tested.** Global range. Used for containers that are not plants, corpses, or sacks and chests. In practice, beehives.
- **Pass.** Line of sight. A container behind a wall is left out. With the option off, distance alone decides.
- **Not tested.** Allow theft. On includes containers the world already marked as stealing, such as a merchant's stock. Off leaves those out of the area scan. Locked, quest, and clue containers never join.
- **Not tested.** Disable Guard reactions. Off, the recommended value, means a nearby guard can notice the theft. On suppresses the notice when the container opens and when an item is taken.
- **Pass.** Container limit. Set to 2 with a long clutter range, four chests, the window includes two: the one opened and one other of the nearest. The search starts from Geralt and always keeps the chest that was opened.
- **NOT pass.** Opening a container no longer flashes red squares with the quest icon. The window stays hidden until the item list is filled, and each slot is marked as a quest item only when the item has that tag.

## Enemies and experience

- **Pass.** None leaves the starting dogs at level 1.
- **Pass.** Enemies already in the world keep the level they had. A new setting applies when they appear again.
- **Pass.** Scale. Enemies below Geralt's level are raised to his level. An enemy already above him stays above him.
- **Pass.** Match sets every enemy to Geralt's level. At level 32, an enemy that would be 35 becomes 32, and an enemy that would be 1 becomes 32.
- **Pass.** Random bounds. At level 32, a lower offset of -4 and an upper offset of +4 roll from 28 to 36. If the upper offset is below the lower one, every enemy is set to Geralt's level.
- **Not tested.** Soft Scaling. An enemy more than 6 levels below Geralt is raised to 6 below him. One already within 6 levels, or already above him, keeps its level.
- **Not tested.** Random, no downscale. The roll uses the same bounds as Random, and the result never goes below the enemy's own level.
- **Not tested.** No animal upscaling. Off, animals and beasts follow the scaling mode. On, they are not raised to Geralt. One already above half his level is set to half his level.
- **Not tested.** Extra levels on guards. Guards are set to Geralt's level with the option on and with it off.
- **Pass.** Health and damage multipliers. Lowered from 1, enemies die sooner and deal less damage. Raised, they last longer and deal more damage.
- **Not tested.** Nonlinear leveling is on. With a level step of 10 and an ability step of 5, higher levels add more bonuses per level than the first stretch. Off, bonuses grow by one per level.
- **Not tested.** No quest levels. On, a quest pays its base experience. It is not cut for being under the quest's level, and it is not raised for being over it.
- **Not tested.** Fixed experience. On, a weak enemy and a strong enemy of the same kind pay the same base experience. Off, an enemy above Geralt pays more and one below him pays less.
- **Not tested.** Quest experience. At 0 the reward is unchanged. At 1 it is doubled. At -0.5 it is cut in half. Monster experience uses the same scale on a kill.

## Alchemy skills

- **Pass.** Mitogenesis adds 4% attack power and spell power per rank, Metastasis adds 10% maximum toxicity per rank, and Angiogenesis adds 5% vitality per rank. The tooltip and the character stats match, also after saving and loading.
- **Pass.** Catalysis, Equilibrium, Mitogenesis, Metastasis, Frenzy, Angiogenesis and Adaptation only work while slotted: bought but unslotted, maximum vitality, toxicity and the other bonuses stay at their base value; slotting one applies it at once, unslotting removes it. On an older save, unslotted ones stop working after loading.

## Skill tree and slots

- **Pass.** New game: one skill slot open; the others open at 2, 4, 6... total skill points. The 4 middle slots stay locked until a mutation is equipped and enough are researched. An older save with skills in locked slots loads with them unequipped.
- **Pass.** Option "Use Spectre's skill progression": on, all 16 slots open at once; off again, they close by skill points. With one slot open before, turning it off keeps that slot and its skill, and the skills in the three slots that close are unequipped.
- **Pass.** New game with the default options: Whirl, Rend, Arrow Deflection, Cold Blood, Razor Focus, Axii: Delusion, the five alternate sign modes, Aard: Far-Reaching, Igni: Melt Armor, Yrden: Sustained Glyphs and Quen: Exploding Shield are at rank 1, every skill point is still free, and they work without a slot (tooltip says Passive).
- **Not tested.** Reset the tree (Potion of Clearance): the starter skills stay at rank 1 and only the paid ranks come back. Same with the unequip refund in the classic menu.
- **Pass.** Muscle Memory at rank 5 in a slot. Turn "Use Spectre's skill tree" off and close the menu: "Skill tree updated." shows, the combat tree is the 5.01 one, the 5.01 Muscle Memory is at rank 3 in the same slot, and 2 points come back as unspent. Turn it on again: Spectre's Muscle Memory is at rank 3 (not 5) in that slot, and no point comes back.
- **Pass.** Same switch with the free starter skills on: the 5.01 Whirl, Arrow Deflection, Cold Blood, Firestream, Puppet and Sustained Glyphs get the free rank instead, and back. Total skill points (spent + unspent) never change.
- **Pass.** 5.01 tree: the remaster tree does not flicker, every branch shows its skills and links (Combat, Signs, Alchemy, General), and skills Spectre had changed (Whirl, Quen, Synergy...) can be bought when their links allow it. Same in the classic tree.
- **Pass.** 5.01 tree: with a rank 3 alchemy skill slotted, Character > Toxicity shows "Potion duration bonus +6 %" and "Bomb damage bonus +6 %", potions last 6% longer and bombs deal 6% more. With Spectre's tree the two lines show Spectre's own bonuses: Half-Life raises the potion duration line and Metabolism Boost lowers it by 33%; Heavy Artillery and the Manticore School set raise the bomb line.
- **Pass.** 5.01 tree with "Starter skills: work without a slot" on: the starter skills give their per-rank bonus without a slot (Whirl at rank 1 raises Adrenaline gain by 0.01), and saving and loading twice does not raise it again. Other skills give it only while slotted, as in 5.01.
- **Pass.** 5.01 tree: the last tooltip line of each Combat, Signs and Alchemy skill shows the 5.01 per-rank bonus, not +0: Adrenaline gain +1% per rank, stamina regeneration +0.5 per rank, potion duration +2% per rank.
- **Pass.** 5.01 tree: the General tree shows the 5.01 Cat, Griffin and Bear schools, Sun and Stars and the other 5.01 General skills in their cells; points in Spectre's General skills move to them. Gorged on Power gives its points back, as Element of Surprise is a different skill.
- **Pass.** 5.01 tree: save, load, and the tree is still the 5.01 one with the same ranks. Change the option with the game closed and load: the ranks move as when switching in game.
- **Pass.** 5.01 tree: every skill has its 5.01 maximum (3, or 1 to 2), name and text, and its tooltip numbers match the base game. Resolve, Undying, Rend, Aard Sweep, Delusion, Catalyst, Tissue Transmutation, Synergy and Wolf School are the 5.01 ones; Resolve at rank 10 becomes 3 and 7 points come back.
- **Pass.** 5.01 tree, effects: Arrow Deflection reflects arrows when parrying; Undying heals with Battle Trance; Crippling Strikes bleeds on a critical light attack; Crippling Shot blocks a monster skill; Supercharged Glyphs drains health inside Yrden; Frenzy slows time when an enemy counterattacks with toxicity above 0; hitting a puppet frees it below Puppet rank 3.
- **Pass.** 5.01 tree: Spectre's alchemy skills (Half-Life, Catalysis...) do not apply; the 5.01 alchemy skills do (Acquired Tolerance, Side Effects, Tissue Transmutation). General skills need a slot, except the starter skills.
- **Pass.** Whirl bought at rank 1 with a point, option off. Turn "Starter skills: free first rank" on: Whirl goes to rank 2 and no point comes back. Off again: rank 1. Repeat a few times: it stays at 1 off and 2 on.
- **Pass.** Whirl at rank 10, option off. Turn it on: one point comes back and Whirl stays at 10. Off: rank 9. On and off again: 10 and 9, never lower.
- **Pass.** Buy Resolve through the free Arrow Deflection without spending any other point, then turn "Starter skills: free first rank" off: Arrow Deflection goes to 0, Resolve is refunded and unequipped, and so is anything bought only through Resolve.
- **Pass.** Turn "Starter skills: free first rank" off and close the menu: a starter skill at rank 1 goes to 0 and is unequipped; one at rank 3 goes to 2 with no points back. Turn it on again: rank 1 comes back for free.
- **Pass.** Turn "Starter skills: work without a slot" off: an unslotted Rend stops working and its tooltip says it needs to be equipped. On again: it works without a slot.
- **Pass.** Take a General skill or a starter skill out of its slot: it keeps working.
- **Pass.** Combat tree, new game: Whirl, Rend, Arrow Deflection, Cold Blood and Razor Focus look bought (not red). Buying their rank 2 is refused until a linked skill is bought. Their neighbors stay locked until the starter skill is reachable through its own links. In the sign trees, the free first skills open the next row as before.
- **Pass.** Remaster tree: the rank pips are replaced by the rank as a white number on a dark square in the bottom right corner of each bought skill, as in 4.04, so nothing overlaps the next cells. Unbought skills show nothing. The tooltip title shows rank/max.
- **Pass.** Holding R on a skill in the remaster tree buys every rank it can at once. It never spends more points or buys more ranks than allowed.
- **Pass.** The top line of each skill tooltip says "Passive (does not need to be equipped)" for Half-Life, Alembic, Proficiency and the General skills, and "Needs to be equipped" for the rest (including Metabolic Control and Metabolism Boost). Core skills show neither.
- **Pass.** With Metamorphosis equipped (`muteq(12)`), its tooltip lists Combat, Signs and Alchemy, each once and in its color. General skills cannot go in the middle slots, as in the base game.
- **Pass.** General tree: links and cell positions match vanilla (`tools/_menu_images_vanilla/general.PNG`). Buying a skill lights its links and unlocks the next skills without changing tab.
- **Pass.** General tree: every cell holds one skill and Gorged on Power has an icon. Gorged on Power sits where Element of Surprise was; Synergy, Elemental Attunement, Wolf, Manticore and Viper keep their 5.01 cells.
- **Pass.** Autophagy needs a slot (tooltip says "Needs to be equipped"): bought and not slotted, the toxicity decrease rate in the character stats does not change; slotted, it rises.

## Skills with 10 ranks

Check the tooltip and the effect at ranks 1, 5, and 10.

- **Pass.** Razor Focus at rank 10 starts combat with 1.5 Adrenaline Points, and the tooltip says 1.5.
- **Not tested.** Aard: Far-Reaching, Igni: Melt Armor, Yrden: Sustained Glyphs, Quen: Exploding Shield and Axii: Delusion raise only their own sign's intensity by 5% per rank while slotted, and the tooltip shows the Sign Intensity line.
- **Pass.** Whirl at rank 10 costs 10% (about 5 Stamina per second). That is close to stamina regeneration, so it can be held for about a minute. Accepted: better than the free or negative cost before.
- **Not tested.** Firestream at rank 10 costs 10 Stamina per second and deals 265 damage per second before Sign Intensity; the tooltip shows both.
- **Not tested.** Counterattack at rank 10 shows +150% attack power, and the hit after a counter deals that much more.
- **Not tested.** Active Shield's cost at rank 10, and the cost per second shown in the three tooltips.
- **Pass** Active Shield at rank 10 heals about the damage it absorbs: a hit that takes about 25% of vitality gives about 25% back when blocked.
- **Not tested.** Rend and Counterattack show 100% critical chance at rank 10, and not before.
- **Not tested.** Arrow Deflection: a parried hit deals 0% at rank 10. A reflected arrow at rank 5 deals about 3 times its damage.
- **Not tested.** Fleet Footed at rank 10: a hit that lands during a dodge deals 10% of its damage, and the tooltip says 90%.
- **Not tested.** Resolve at rank 10: a hit takes 10% of the adrenaline it normally would and gives none back, and the tooltip says 90%.
- **Not tested.** Lightning Reflexes and Steady Aim slow aiming a little more at every rank.
- **Not tested.** Delusion: a failed Axii staggers at rank 3 and at rank 10. Dialogue Axii always works at rank 10, not at rank 4.
- **Not tested.** Sustained Glyphs: one standard trap at rank 4, two at rank 5. At rank 10 a trap lasts three times as long and is 25% larger. The tooltip and the character stats show the same numbers.
- **Not tested.** Puppet at rank 10 lasts about 30 s without Sign Intensity bonuses, and a puppet's hit takes about 12-24% of an enemy's health.
- **Not tested.** Fixative at rank 10: a level 3 oil lasts 180 hits and keeps counting down, and a third oil can be added to the blade. At rank 4 a second oil replaces the first.
- **Not tested.** Fortified Signs makes Yrden traps, Quen and Axii last longer, and the tooltips and stats show it. Exploding Shield returns part of the absorbed damage to the attacker.
- **Not tested.** Domination at rank 10 has no penalty with two targets and does not last longer than normal. Ranks 1 to 9 say the duration is X% shorter with two targets; rank 10 says there is no penalty.
- **Not tested.** Catalysis, Adaptation, Equilibrium, and Proficiency show the new numbers. With Adaptation 10 and the Manticore set, toxicity does no damage and heals nothing.
- **Not tested.** Aard Sweep and Domination say the penalty is gone only at rank 10. Active Shield always shows its Stamina cost. Hunter Instinct shows two numbers in the remaster menu: 33.3% per point and 100% maximum at rank 10, even with more than 3 Adrenaline Points. Check a save started before this change too.

## General skills

- **Pass.** Wolf, Manticore and Viper School are 1 rank and work without a slot, and their description says "each piece of Medium Armor". With 4 medium pieces (Kaer Morhen, for example), Wolf gives +20% weapon damage and +20% Sign Intensity; with light or heavy armor, nothing. Changing a piece updates it. On an older save, ranks above 1 are refunded. With the 5.01 tree, the three show the 5.01 description and Viper its 5.01 values.
- **Pass.** Character > Signs shows Sign Intensity with one decimal when it has one: a set's 20% plus a sign opener at rank 1 (2.5%) shows 22.5%, in the main line and in each sign.
- **Pass.** Character stats: the two sign sections are titled "Aard, Igni, Quen" and "Yrden, Axii" with no number outside; each sign's intensity is inside.
- **Pass.** General Synergy goes to rank 10, works without a slot (tooltip says Passive), and its tooltip says 50% at rank 10. Each rank raises the mutagen bonus at once, without re-equipping the mutagen; on an older save it applies after loading. A greater green mutagen with no matching skills gives 150 Vitality plus 7.5 per Synergy rank (75 at rank 10). Points spent on Element of Surprise come back.

## Body, signs, the horse, and the boat

- **Pass.** "Use Spectre's combat system" off: light and heavy attacks, dodges, rolls and parries cost no stamina; sprinting drains it as in the base game; it recovers faster with no long pause; Whirl, Rend and the signs can be used again at once. On again: Spectre's costs and cooldowns are back. Both survive saving and loading.
- **Pass.** Switching "Use Spectre's combat system" keeps the current Adrenaline, stamina and vitality.
- **Pass.** Options menu: Gameplay shows only the boat, sinking threshold and item weight options, with one preset, Recommended. Combat shows "Use Spectre's combat system" and below it quick sign casting, armor regen penalty, the regeneration and stamina cost sliders, stamina delay and the three cooldowns. Each Combat preset (Recommended, Old version, Turn off) sets them all.
- **Pass.** Combat with "Use Spectre's combat system" off: in the menu the options below it turn grey at once and cannot be changed, also after leaving and opening Combat again and with the Turn off preset; on again, they can be changed at once. With it off, a melee stamina cost of 1 does not double the cost, a sign cooldown of 10 does not apply, a sign key does not cast at once, and heavy armor slows stamina regeneration.
- **Pass.** Metabolism Boost works without a slot (tooltip says Passive): bought and not slotted, a potion digests 33% faster and lasts 33% less.
- **Pass.** Metabolism Boost without a slot makes toxicity fall faster, and the character stats show the real decrease rate: out of combat, with no potion in effect and 115 maximum toxicity, 1.12/s without it and 1.31/s with it.
- **Pass.** Every option of Alchemy > Toxicity shows its description when hovered.
- **Pass.** Metabolic Control works without a slot (tooltip says Passive) and raises maximum Toxicity from 100 to 115. With Metastasis rank 1 it is 126 or 127 ((100 + 15) x 1.1). Learning a recipe keeps it. On a save that had it slotted, after loading it is 115, not 130.
- **Pass.** Elemental Attunement has 1 rank, its tooltip says 10%, and Igni or Aard deal 10% more. On a save with it at rank 3, after loading it is rank 1 and 2 points come back. In the 5.01 tree it keeps 3 ranks of 3%.
- **Pass.** Presets: every group starts with "Recommended", and Equipment, Gameplay and Looting also have "Off". Looting off: line of sight scan off, and opening a container loots only that one. Equipment off: closing the menu unequips gear above your level.
- **Pass.** Skills preset "Turn off": the four skill options turn off, and closing the menu changes the tree to 5.01 and takes back the free starter ranks.
- **Pass.** Sell a potion and a common sword to a merchant, close the shop, walk away and come back: both are still for sale.
- **Pass.** "Equip gear of any level" off: at level 20, a level 33 sword cannot be equipped and its tooltip shows the required level. On: it equips and the tooltip shows no level.
- **Pass.** "Equip gear of any level" off with gear above your level already equipped: closing the menu unequips it.
- **Pass.** "Gear rises to your level" on: equipped swords and armor rise to your level when you level up (crossbows do not, as in the base game and Spectre v0.93). Off: they keep their level.
- **Pass.** Tapping a sign key starts the cast. The button does not have to stay held for a normal cast.
- **Pass.** Sign cooldown and alternate-sign cooldown. Changing the seconds changes how long that sign, and its alternate mode, must wait before they can be used again. Recommended values are 5 seconds and 7.5 seconds.
- **Pass.** Whirl and Rend cooldown. Changing the seconds changes how long those moves must wait before they can be used again. The recommended value is 7.5 seconds.
- **Not tested.** A boat sinks after encumbrance passes 20% over the carry limit. Under that, extra weight still floats.
- **Not tested.** The armor stamina-regeneration penalty is ignored. A heavy set does not slow stamina recovery.
- **Not tested.** Carry weight. At 0, items keep their weight. A higher value makes them lighter. At 100 they weigh nothing.
- **Not tested.** Stamina recovery in combat, and stamina recovery out of combat. At 0 both stay as they are.
- **Not tested.** Vitality recovery in combat, and vitality recovery out of combat. At 0 both stay as they are.
- **Not tested.** Sprint, melee, and sign stamina costs. At 0 each cost stays as it is.
- **Not tested.** Stamina delay. At 0, the pause before stamina returns is unchanged. A positive value waits longer. A negative value shortens it, and the pause never goes below 0.
- **Pass.** On horseback with keyboard and mouse: a short press of E next to a container loots it without dismounting; holding E dismounts.

## Uninstalling

Spectre v0.93 cannot be uninstalled from a save: loaded without Spectre, Geralt has no ability manager. These lines check the option that prepares the save.

- **Pass.** A save played with Spectre, loaded without Spectre (with Eternal Hunt): the skill tree is broken and the stats are wrong. 0 damage per second with both swords, 0 armor, 0% to every resistance, toxicity -1, vitality regeneration -1/s, stamina -1/s, Aard intensity -7%, Quen intensity 2147483648, -100% bonus experience, -100 herbs, maximum weight 80/69 (91/2352372742 in another save). This is the old bug. The same save loads normally with Spectre installed again.
- **Pass.** In the main menu, "Remove Spectre from this save" is greyed out and cannot be turned on. Hovering it shows that it only works inside a save.
- **Pass.** In combat, turning it on and closing the menu shows a notification and changes nothing. The option is off again.
- **Pass.** Out of combat, turning it on and closing the menu makes a new manual save and shows the message (close the game, uninstall Spectre, load that save).
- **Pass.** After using it, the option is off again, also after loading another save.
- **Pass.** That save loaded without Spectre (with Eternal Hunt): the 5.01 skill tree is there with every skill at rank 0, the base game message says the skills were reset, all the skill points are free, and the stats and maximum weight are right.
- **Pass.** That save loaded with Spectre and Eternal Hunt installed: Spectre's tree comes back with every skill point free.
- **Pass.** Spectre and Eternal Hunt installed together: a save played with Spectre loads with Spectre's tree and the right stats.
- **Pass.** With a Nigredo, Albedo or Rubedo potion in the inventory or the stash, using the option turns it into the base potion. Potions are single items with charges in the base game, so the save loaded without Spectre has one: Swallow 2 Rubedo x3 becomes one Swallow 2.
- **Pass.** Using the option removes the Mutation Trigger from the inventory, and its recipe is no longer known.
