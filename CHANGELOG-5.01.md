# Spectre CHANGELOG for The Witcher 3 5.01

# 1.07

## Fixes
- A burning enemy reacts to hits again once half the burn has passed.
- Yrden's trap shows the extra effects and the center rune.
- Aard with the sixth mutation puts out lights, freezes swarms and breaks destructible objects.
- Focus updates Battle Trance as soon as it is equipped or removed. Synergy updates as soon as its rank changes.
- A basic attack or a basic sign still works if that skill is at rank 0.
- An arrow that hits you no longer counts as a dodge. With the 5.01 skill tree, Crippling Shot ends when a bolt hits a shield or bounces.
- A crossbow bolt aims at the body part you are aiming at.
- With alternate focus on and a controller, pressing a sign while focus is on casts the sign.
- Enemies set to always dodge do dodge.
- In the character menu, a rare mutagen's left and right bonuses go to the right stats.
- A transmogged item's tooltip shows the appearance icon.
- A whetstone shows a Use hint. The compare hint shows that the button is held.
- Equipping a crossbow handles its bolts, and the bolt tutorial, as in the base game. Equipping an item ends the forced alchemy tutorial once that tutorial is over.
- Quest item rewards are announced once.
- The giant centipede in Blood and Wine can be dismembered on the killing blow.
- Holding a sign no longer vibrates the controller on every moment. Critical effects use the base game's vibration.
- The one-time Flood of Anger fix now covers every Signs skill, so it no longer refunds points for skills it left in place.

# 1.06

## Fixes
- After "Remove Spectre from this save", the message also reminds you to remove Spectre's lines from input.settings.
- True Aerondight Uncapped no longer stops the scripts from compiling. Its uncapped damage bonus still does nothing: Spectre's Aerondight has no permanent damage bonus. Spectre's Aerondight is unchanged.

# 1.05

## Fixes
- With "Alchemy Requires" set to "No Fire Whatsoever", brewing needs meditation again, unless "Disable Meditation Requirements" is on.
- Minor Set Bonus no longer stops the scripts from compiling. Its set bonuses don't work with Spectre, which has its own.
- Well Hydrated: a weaker drink no longer replaces the effect of a better one. An equal or better drink adds to it, as in the base game.
- Better Buffs no longer stops the scripts from compiling. Its charges for the grindstone and workbench overlap with Spectre's own.

# 1.04

## Fixes
- Sort Everything compiles with Spectre. Spectre's alchemy menu works as before and keeps its own order.
- Other mods can change the item selection list again (for example, Sort Everything's sorting when picking a quick slot item).

# 1.03

## Fixes
- Options added in 5.01 apply as soon as you change them in the menu again: combat style, target lock, camera, jump and landing, weightless items, auto-heal, accessibility, mods on or off, path tracing and frame generation, among others.
- Other mods' options react in the menu again (presets, live previews), whatever their load order.
- Sword FX Remaster compiles with Spectre.

# 1.02

## Fixes
- Make Spectre's alchemy menu wrappable by other mods
- Living Economy now compiles with Spectre. In Spectre's alchemy menu, buying a missing ingredient uses Living Economy's price; the ingredient's tooltip doesn't show it, and Spectre's vanilla alchemy package doesn't use Living Economy's prices.

# 1.01

## Fixes
- After "Remove Spectre from this save", the save loaded without Spectre has every skill at rank 0. The free starter skills kept a rank before.
- A new game no longer hands Geralt the starting swords and armor during the intro, so he does not wear his swords in the bath scene. The prologue dresses him, as in the base game.
- Switching between Spectre's alchemy and the vanilla alchemy package no longer removes items from the inventory.

# 1.0

## New

- You can choose between Spectre's skill tree and the 5.01 one ("Use Spectre's skill tree"). Switching keeps your ranks, it does not reset the tree.
- Every part of Spectre can be turned off on its own. The menu has new Equipment and Combat sections, and every section has a "Recommended" and an "Off" preset.
- Alchemy menu: each potion, oil and bomb shows once per level it can be brewed at (Swallow, Enhanced Swallow, Superior Swallow), and each only takes the ingredients that give its level. Choosing another ingredient lists every one that fits, also the ones you do not have, in red with 0. The filters above the list now show or hide each level (Normal, Enhanced, Superior), and the bottom bar shows the key to change an ingredient.
- Hold R on a skill to buy every rank you can afford.
- Hold Z on a skill to reset it and get its points back. The skills that depended on it are reset too.
- Keep holding E (gamepad X) on a skill to keep buying ranks, each one faster.
- With a gamepad, hold R3 on a skill to reset it.
- A skill's rank shows as a number on its cell. In 5.01 the tree draws one diamond per rank and fills it in as you buy that rank. At 10 ranks the cell was full of diamonds, so the diamonds are removed and the number is shown instead.
- "Remove Spectre from this save": use it before uninstalling Spectre, and the save keeps working without the mod.
- Optional package "Vanilla alchemy" (experimental): install it over Spectre to play with the base game alchemy (recipes, potions, toxicity, herbs and the alchemy menu) and keep the rest of Spectre. The alchemy branch of Spectre's tree then has the 5.01 alchemy skills. Reinstall Spectre to go back. Switching between the two alchemies can make some inventory items disappear.

## Skills

- Skills still go up to rank 10, and now every rank adds something. No skill reaches its limit early or turns negative (Whirl was free from rank 8 and Active Shield gave stamina back, for example).
- You start with 1 free rank in Whirl, Rend, Arrow Deflection, Cold Blood, Razor Focus, Delusion, the alternate signs and the first skill of each sign. These work without being equipped.
- The General skills (yellow tree) need a slot, except Sun and Stars, Metabolic Control, Attack is the Best Defense, Strong Back and Wolf School Techniques. An option lets all of them work without a slot, as before.
- Strong Back adds 80 to the carry weight instead of 40.
- Other combat and sign skills need a slot, as in the base game. So do the alchemy skills that help in combat: Half-Life, Catalysis, Equilibrium, Mitogenesis, Metastasis, Frenzy, Angiogenesis, Adaptation and Autophagy.
- The first skill of each sign gives that sign +2.5% Sign Intensity per rank. It replaces the separate sign intensity skills.
- The skills 5.01 added (Catalyst, Focus, Convergence, Overload, Resonance, Avoidance, Fortified Signs, Toxic Shock and others) are in the tree, with 10 ranks.
- Focus also makes signs give Adrenaline, as swords do, and more with each rank.
- Mitogenesis, Metastasis and Angiogenesis now work. Before, they did nothing.
- Battle Frenzy adds critical hit chance (+5% per Adrenaline Point) without taking away the Attack Power that Adrenaline gives.
- Rage Management: a held sign that runs out of Adrenaline goes on with Stamina instead of stopping.
- Flood of Anger costs 3 Adrenaline Points and now also works on alternate signs for as long as they are held. It gives +25% Sign Intensity per rank instead of +50%.
- Each skill's tooltip says whether it works without being equipped.
- Trying to rank up a skill whose previous skills you have not bought says so: "Unlock the skills before this one first."

## Slots and mutations

- Skill, mutagen and mutation slots open as in 5.01, and one mutation is active at a time.
- Turn on "Use Spectre's skill progression" to have every slot open from the start, as in Spectre v0.93. This makes the start of the game much easier.
- The mutations menu opens as in the base game, during Blood and Wine. Turn on "Mutations from the start" to have it from the beginning, as before; the base game's mutations tutorial shows when it opens.
- Turn on "Several mutations at once" (off by default) to have every mutation you research active at the same time, as in Spectre v0.93. In the mutation menu every active mutation shows its white ring, the main one a gold ring, and a counter shows how many are active (3/3). The main one is the one in the middle, and the middle slots take its colors: press R on another active mutation to make it the main one; activating a new one keeps the main one. Unequipping turns off the one selected. It is unbalanced: Geralt gets much stronger. "Maximum mutations" (2 to 12, 3 by default) limits how many can be active; to equip another, unequip one first. Lowering it below the active ones takes them all off.
- 16 skill slots, as in 5.01. The extra slots for Vladimir UI are gone.

## Equipment

- All equipment can be equipped at any level, and it levels up to you when you equip it, as before. Both can be turned off.

## Combat

- "Use Spectre's combat system" can be turned off to play with the base game's stamina and adrenaline.
- Cooldowns, stamina costs and regeneration now sit in the Combat section of the menu.
- Bomb damage bonuses multiply each other, as in the base game, so several together hit harder.
- Getting hit takes the base game's amount of Adrenaline. Big hits no longer empty it.

## Enemies

- Enemies, NPCs and quest characters are the 5.01 versions, so they get what 5.01 added: finisher dismemberment, new immunities, short-range attacks and loot. Spectre's levels, loot, abilities and prices stay.
- The random scaling range and the boss health and damage sliders work. Before, they were ignored.

## Character menu

- Skill tooltips are aligned left instead of centered.
- Toxicity shows how fast it really drops, with Spectre's settings and skills.
- You can see how much longer your potions last and how much more damage your bombs deal.
- Sign Intensity shows per sign.

## Horse

- To dismount, hold the dismount key, as in 5.01. A short press loots from horseback. The double tap is gone.

## No longer in the game

These belonged to the old 4.04 skill menu, which 5.01 replaced. They could come back later.

- Recoloring skills with greater mutagens.
- The master mutation colors in the middle of the tree.
- Seeing every active mutation at once in the mutation menu: it only shows one.

## Fixes

- Removing Spectre no longer ruins the save, if you use "Remove Spectre from this save" first. Before, a save loaded without Spectre lost the skill tree, the skills and the stats.

- Opening a container no longer flashes the loot window with sample items.
- Starting directly in Hearts of Stone or Blood and Wine teaches the recipe of every potion, bomb and oil the starting kit gives (Thunderbolt, Black Blood, Full Moon and others). Spectre does not refill potions at meditation, so they could not be made again.
- A new game started after loading another save no longer inherits that save's mutations (and the skill slots they opened).
- Far-Reaching Aard shows its whole effect.
- The Wolf Hour tooltip shows its real duration (1 hour), not 240 seconds.
- Living Economy compiles with Spectre. Buying a missing ingredient in the alchemy menu pays its price.
