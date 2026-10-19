# Spectre 1.0 for The Witcher 3 5.01

Spectre now runs on The Witcher 3 Remastered 5.01. Combat, signs, alchemy, area loot and enemy scaling work as before, with the fixes and additions below.

The full technical list (every value, script and file) is in `CHANGELOG-FOR-AUTHOR.md`.

## New

- You can choose between Spectre's skill tree and the 5.01 one ("Use Spectre's skill tree"). Switching keeps your ranks, it does not reset the tree.
- Every part of Spectre can be turned off on its own. The menu has new Equipment and Combat sections, and every section has a "Recommended" and an "Off" preset.
- Alchemy menu: each potion, oil and bomb shows once per level it can be brewed at (Swallow, Enhanced Swallow, Superior Swallow), and each only takes the ingredients that give its level. Choosing another ingredient lists every one that fits, also the ones you do not have, in red with 0. The filters above the list now show or hide each level (Normal, Enhanced, Superior), and the bottom bar shows the key to change an ingredient.
- Hold R on a skill to buy every rank you can afford.
- Hold Z on a skill to reset it and get its points back. The skills that depended on it are reset too.
- Keep holding E (gamepad X) on a skill to keep buying ranks, each one faster.
- With a gamepad, hold R3 on a skill to reset it.
- A skill's rank shows as a number on its cell.
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
