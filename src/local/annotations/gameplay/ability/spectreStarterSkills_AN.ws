// Spectre: starter skills, kept apart from the rest of the ability manager.
//
// As Spectre's author describes, some skills start at rank 1 for free and work without a slot: Whirl,
// Rend, Arrow Deflection, Cold Blood, Razor Focus, Delusion, the five alternate sign modes, and the first
// skill of each sign (in place of the five sign intensity skills, which are off the remaster tree).
//
// Two options control it (group spectreSkillTreeOptions):
//   spectreFreeStarterSkills       the free first rank (default on)
//   spectreStarterSkillsUnslotted  working without a slot (default on)
//
// Nothing here assumes Spectre's skill tree. Some starter skills have a 5.01 counterpart (SpectreTreePairs
// in spectreSkillTree_AN.ws), and the one that sits on the tree in use is the one that gets the free rank
// (SpectreStarterSkills). With the 5.01 tree, the same options give the 5.01 versions.
//
// Link rules for the remaster tree (SpectreLinksSatisfied):
//   - A skill with any rank looks bought in the menu, never locked (SpectreUnlockedByDependency).
//   - Going past rank 1 needs the links, as for any skill (CanLearnSkill).
//   - A free rank only opens the skills linked to it once the skill itself is reachable through its own
//     links. A starter skill in the middle of the combat tree works from the start, but it is not a
//     shortcut into the tree.

// First ranks of the starter skills that were given for free (not paid with a skill point).
@addField(W3PlayerAbilityManager)
private saved var spectreFreeRankSkills : array<ESkill>;

// Option values last applied by SpectreApplySkillOptions.
@addField(W3PlayerAbilityManager)
private var spectreSkillOptionsApplied : bool;
@addField(W3PlayerAbilityManager)
private var spectreAppliedFreeStarters : bool;
@addField(W3PlayerAbilityManager)
private var spectreAppliedStartersUnslotted : bool;
@addField(W3PlayerAbilityManager)
private var spectreAppliedGeneralsUnslotted : bool;

// Whether the General skills worked without a slot when the options were last applied: 0 on a save from
// before the option (they all did), 1 yes, 2 no. The ones in SpectreGeneralAlwaysUnslotted always do. Kept in the save, so a change made with the game closed is
// applied on the next load.
@addField(W3PlayerAbilityManager)
private saved var spectreGeneralsUnslottedState : int;
@addField(W3PlayerAbilityManager)
private var spectreAppliedAllSlots : bool;
@addField(W3PlayerAbilityManager)
private var spectreAppliedMultipleMutations : bool;
@addField(W3PlayerAbilityManager)
private var spectreAppliedMutationsFromStart : bool;
@addField(W3PlayerAbilityManager)
private var spectreAppliedMaxMutations : int;

// How deep the link check follows free ranks. The remaster trees are 6 to 8 rows deep.
@addMethod(W3PlayerAbilityManager) function SpectreLinkDepth() : int
{
	return 10;
}

@addMethod(W3PlayerAbilityManager) function SpectreFreeStarterSkills() : bool
{
	return spectre_Settings_Main_Bool('spectreSkillTreeOptions', 'spectreFreeStarterSkills', true);
}

@addMethod(W3PlayerAbilityManager) function SpectreStarterSkillsUnslotted() : bool
{
	return spectre_Settings_Main_Bool('spectreSkillTreeOptions', 'spectreStarterSkillsUnslotted', true);
}

@addMethod(W3PlayerAbilityManager) function SpectreGeneralSkillsUnslotted() : bool
{
	return spectre_Settings_Main_Bool('spectreSkillTreeOptions', 'spectreGeneralSkillsUnslotted', false);
}

// "General skills: work without a slot" changed: each learned General skill that is not slotted loses or gets its
// effects, the same way as leaving or entering a slot, on the tree in use. Changing the tree applies the effects
// itself (SpectreSuspendSkillEffects, SpectreResumeSkillEffects).
@addMethod(W3PlayerAbilityManager) function SpectreApplyGeneralSlotOption()
{
	var generals : array<ESkill>;
	var skill : ESkill;
	var i, wanted, was : int;

	wanted = 2;
	if (SpectreGeneralSkillsUnslotted())
		wanted = 1;
	was = spectreGeneralsUnslottedState;
	if (was == 0)
		was = 1;
	spectreGeneralsUnslottedState = wanted;
	if (was == wanted)
		return;

	generals = SpectreGeneralSkills();
	for (i = 0; i < generals.Size(); i += 1)
	{
		skill = generals[i];
		if (skills[skill].level <= 0 || GetSkillSlotID(skill) >= 0 || SpectreGeneralAlwaysUnslotted(skill))
			continue;
		if (wanted == 2)
			OnSkillUnequip(skill);
		SpectreDropSkillAbilities(skill);
		if (wanted == 1)
			OnSkillEquip(skill);
	}
}

// The starter skills on the tree in use. Each entry is Spectre's skill; when it is not on the tree, its
// 5.01 counterpart is used instead.
@addMethod(W3PlayerAbilityManager) function SpectreStarterSkills() : array<ESkill>
{
	var spectreSkills, result : array<ESkill>;
	var i : int;

	spectreSkills.PushBack(S_Sword_s01);	// Whirl
	spectreSkills.PushBack(S_Sword_s02);	// Rend
	spectreSkills.PushBack(S_Sword_s10);	// Arrow Deflection
	spectreSkills.PushBack(S_Sword_s15);	// Cold Blood
	spectreSkills.PushBack(S_Sword_s20);	// Razor Focus
	spectreSkills.PushBack(S_Magic_s01);	// Aard Sweep
	spectreSkills.PushBack(S_Magic_s02);	// Firestream
	spectreSkills.PushBack(S_Magic_s03);	// Magic Trap
	spectreSkills.PushBack(S_Magic_s04);	// Active Shield
	spectreSkills.PushBack(S_Magic_s05);	// Puppet
	spectreSkills.PushBack(S_Magic_s17);	// Axii: Delusion
	spectreSkills.PushBack(S_Magic_s20);	// Aard: Far-Reaching
	spectreSkills.PushBack(S_Magic_s08);	// Igni: Melt Armor
	spectreSkills.PushBack(S_Magic_s10);	// Yrden: Sustained Glyphs
	spectreSkills.PushBack(S_Magic_s13);	// Quen: Exploding Shield

	for (i = 0; i < spectreSkills.Size(); i += 1)
	{
		if (SpectreIsOnSkillTree(spectreSkills[i]) || !SpectreIsOnSkillTree(SpectreTreeCounterpart(spectreSkills[i])))
			result.PushBack(spectreSkills[i]);
		else
			result.PushBack(SpectreTreeCounterpart(spectreSkills[i]));
	}
	return result;
}

// Whether the remaster skill tree shows the skill (the same filter its menu uses).
@addMethod(W3PlayerAbilityManager) function SpectreIsOnSkillTree(skill : ESkill) : bool
{
	return skills[skill].skillSubPath != ESSP_NotSet && skills[skill].skillSubPath != ESSP_Core
		&& (skills[skill].isReworked || skills[skill].isUnchangedLegacy);
}

// 1 when the skill's first rank was given for free, so refunds and resets leave it.
@addMethod(W3PlayerAbilityManager) function SpectreFreeRank(skill : ESkill) : int
{
	if (spectreFreeRankSkills.Contains(skill) && skills[skill].level > 0)
		return 1;
	return 0;
}

@addMethod(W3PlayerAbilityManager) function SpectreDropSkillAbilities(skill : ESkill)
{
	var ability : name;
	var j : int;

	ability = skills[skill].abilityName;
	for (j = skillAbilities.Size() - 1; j >= 0; j -= 1)
	{
		if (skillAbilities[j] == ability)
			skillAbilities.Erase(j);
	}
	owner.RemoveAbilityAll(ability);
}

// Gives or takes back the free first rank of the starter skills, and reapplies the effects of the ones
// that are not slotted so they match the "work without a slot" option. Runs when a save loads, after a
// reset and when one of the options changes.
@addMethod(W3PlayerAbilityManager) function SpectreApplySkillOptions()
{
	var starters, reachable : array<ESkill>;
	var skill : ESkill;
	var i, slot, freeRanks : int;
	var free : bool;

	free = SpectreFreeStarterSkills();
	freeRanks = spectreFreeRankSkills.Size();
	reachable = SpectreReachableSkills();
	spectreAppliedFreeStarters = free;
	spectreAppliedStartersUnslotted = SpectreStarterSkillsUnslotted();
	spectreAppliedGeneralsUnslotted = SpectreGeneralSkillsUnslotted();
	spectreAppliedAllSlots = SpectreAllSlotsUnlocked();
	spectreAppliedMultipleMutations = SpectreMultipleMutations();
	spectreAppliedMutationsFromStart = SpectreMutationsFromStart();
	spectreAppliedMaxMutations = SpectreMaxMutations();
	spectreSkillOptionsApplied = true;

	SpectreFillActiveSkills();
	SpectreApplyGeneralSlotOption();
	starters = SpectreStarterSkills();

	// A free rank given to a skill that is no longer a starter (the tree changed) goes back too.
	for (i = spectreFreeRankSkills.Size() - 1; i >= 0; i -= 1)
	{
		if (!starters.Contains(spectreFreeRankSkills[i]))
			SpectreTakeFreeRank(spectreFreeRankSkills[i]);
	}

	for (i = 0; i < starters.Size(); i += 1)
	{
		skill = starters[i];
		if (free)
		{
			if (skills[skill].level == 0)
			{
				skills[skill].level = 1;
				if (!spectreFreeRankSkills.Contains(skill))
					spectreFreeRankSkills.PushBack(skill);
			}
			else if (!spectreFreeRankSkills.Contains(skill))
			{
				// Already bought with points: the free rank goes on top of them, so turning the option off
				// later brings back exactly the paid ranks. At the maximum rank there is no room, so one
				// paid rank becomes the free one and its point comes back.
				spectreFreeRankSkills.PushBack(skill);
				if (skills[skill].level < skills[skill].maxLevel)
				{
					slot = GetSkillSlotID(skill);
					if (slot >= 0)
					{
						OnSkillUnequip(skill);
						SpectreDropSkillAbilities(skill);
					}
					skills[skill].level += 1;
					if (slot >= 0)
						OnSkillEquip(skill);
				}
				else
				{
					pathPointsSpent[skills[skill].skillPath] -= 1;
					GetWitcherPlayer().levelManager.UnspendPoints(ESkillPoint, 1);
				}
			}
		}
		else if (spectreFreeRankSkills.Contains(skill))
			SpectreTakeFreeRank(skill);

		if (GetSkillSlotID(skill) < 0)
		{
			SpectreDropSkillAbilities(skill);
			if (skills[skill].level > 0 && spectreActiveSkills.Contains(skill))
				OnSkillEquip(skill);
		}
	}

	// Skills bought through a free rank that is gone now have no link left: refund them.
	if (spectreFreeRankSkills.Size() < freeRanks)
		SpectreRefundUnreachableSkills(reachable);

	// Metabolic Control used to add 30 Acquired Tolerance abilities while slotted. It now works without a slot
	// through its own ability: put that ability back on saves that bought it, as buying it does, and drop the
	// old ones.
	if (!SpectreUsesVanillaSkills() && skills[S_Perk_12].level > 0
		&& (spectreActiveSkills.Contains(S_Perk_12) || GetSkillSlotID(S_Perk_12) >= 0))
	{
		SpectreDropSkillAbilities(S_Perk_12);
		OnSkillEquip(S_Perk_12);
	}
	SpectreApplyMutationSystemOption();
	SpectreSyncMutations();
	if (GetWitcherPlayer())
		GetWitcherPlayer().RecalcAlchemy18Abilities();

	SpectreApplySlotOption();

	// 5.01 tree: the per-rank bonus of each tree (Adrenaline gain, stamina regeneration, potion duration,
	// vitality) goes to the skills that count as equipped, the starter skills without a slot included. The
	// calls above give it again to the unslotted ones, so count it from scratch. Spectre's tree gives none.
	if (SpectreUsesVanillaSkills())
		AddSkillPassiveBonusesForEquipped();
	else
	{
		owner.RemoveAbilityAll('sword_adrenalinegain');
		owner.RemoveAbilityAll(SpectreVanillaAbilityName('sword_adrenalinegain'));
		owner.RemoveAbilityAll('magic_staminaregen');
		owner.RemoveAbilityAll(SpectreVanillaAbilityName('magic_staminaregen'));
		owner.RemoveAbilityAll('alchemy_potionduration');
		owner.RemoveAbilityAll(SpectreVanillaAbilityName('alchemy_potionduration'));
		owner.RemoveAbilityAll('survival_vitality');
		// Alchemy 5.01 variant: the 5.01 alchemy skills give their per-rank bonus, as in 5.01.
		if (SpectreUsesVanillaAlchemySkills())
			SpectreAddAlchemyRankBonuses();
	}

	// School techniques keep a copy per matching piece. Recount on load, so an old save drops the copy it
	// had just for owning the skill.
	SpectreRefreshArmorPieceSkills();
}

// Potion duration (and bomb damage) per rank of each equipped alchemy skill, as AddSkillPassiveBonusesForEquipped
// gives it in 5.01.
@addMethod(W3PlayerAbilityManager) function SpectreAddAlchemyRankBonuses()
{
	var i : int;

	for (i = 0; i < skills.Size(); i += 1)
	{
		if (skills[i].skillPath == ESP_Alchemy && IsSkillEquipped(skills[i].skillType) && !IsCoreSkill(skills[i].skillType)
			&& (skills[i].isReworked || skills[i].isUnchangedLegacy))
			owner.AddAbilityMultiple(SpectreSkillAbility('alchemy_potionduration'), skills[i].level);
	}
}

// The bought skills on the tree whose links are satisfied right now.
@addMethod(W3PlayerAbilityManager) function SpectreReachableSkills() : array<ESkill>
{
	var result : array<ESkill>;
	var i : int;

	for (i = 0; i < skills.Size(); i += 1)
	{
		if (skills[i].level > 0 && SpectreIsOnSkillTree(skills[i].skillType)
			&& SpectreLinksSatisfied(skills[i].skillType, SpectreLinkDepth()))
			result.PushBack(skills[i].skillType);
	}
	return result;
}

// Refunds every skill that was reachable before and is not any more, again and again, since each
// refund can cut the links of the next skill. Skills that had no link before (bought on the classic tree
// of an old save) are left alone.
@addMethod(W3PlayerAbilityManager) function SpectreRefundUnreachableSkills(wasReachable : array<ESkill>)
{
	var skill : ESkill;
	var i, slot, paid : int;
	var changed : bool;

	changed = true;
	while (changed)
	{
		changed = false;
		for (i = 0; i < wasReachable.Size(); i += 1)
		{
			skill = wasReachable[i];
			paid = skills[skill].level - SpectreFreeRank(skill);
			if (paid <= 0 || SpectreLinksSatisfied(skill, SpectreLinkDepth()))
				continue;

			slot = GetSkillSlotID(skill);
			if (slot >= 0)
				UnequipSkill(slot);
			SpectreDropSkillAbilities(skill);

			pathPointsSpent[skills[skill].skillPath] -= paid;
			GetWitcherPlayer().levelManager.UnspendPoints(ESkillPoint, paid);
			skills[skill].level = SpectreFreeRank(skill);
			if (skills[skill].level > 0 && slot < 0 && spectreActiveSkills.Contains(skill))
				OnSkillEquip(skill);
			changed = true;
		}
	}
}

// Removes the free first rank: a skill left at rank 0 is unequipped, a higher one keeps its paid ranks.
@addMethod(W3PlayerAbilityManager) function SpectreTakeFreeRank(skill : ESkill)
{
	var slot : int;

	spectreFreeRankSkills.Remove(skill);
	if (skills[skill].level <= 0)
		return;

	slot = GetSkillSlotID(skill);
	if (skills[skill].level == 1 && slot >= 0)
	{
		UnequipSkill(slot);
		slot = -1;
	}
	else if (slot >= 0)
		OnSkillUnequip(skill);
	SpectreDropSkillAbilities(skill);
	skills[skill].level -= 1;
	if (slot >= 0 && skills[skill].level > 0)
		OnSkillEquip(skill);
}

@addMethod(W3PlayerAbilityManager) function SpectreSkillOptionsChanged() : bool
{
	if (!spectreSkillOptionsApplied)
		return false;
	return spectreAppliedFreeStarters != SpectreFreeStarterSkills()
		|| spectreAppliedStartersUnslotted != SpectreStarterSkillsUnslotted()
		|| spectreAppliedGeneralsUnslotted != SpectreGeneralSkillsUnslotted()
		|| spectreAppliedAllSlots != SpectreAllSlotsUnlocked()
		|| spectreAppliedMultipleMutations != SpectreMultipleMutations()
		|| spectreAppliedMutationsFromStart != SpectreMutationsFromStart()
		|| spectreAppliedMaxMutations != SpectreMaxMutations();
}

// The next rank of the skill is refused only because of its links (not its maximum rank or the free points).
// The menu tells the player to unlock the skills before it.
@addMethod(W3PlayerAbilityManager) function SpectreSkillBlockedByLinks(skill : ESkill) : bool
{
	if (skills[skill].level >= skills[skill].maxLevel)
		return false;
	if (!skills[skill].isReworked && !skills[skill].isUnchangedLegacy)
		return false;
	return !SpectreLinksSatisfied(skill, SpectreLinkDepth());
}

// Whether the skill's links let it be bought. Same rule as the base game, except that a linked skill
// whose only rank is the free one counts only when it is reachable itself.
@addMethod(W3PlayerAbilityManager) function SpectreLinksSatisfied(skill : ESkill, depth : int) : bool
{
	var j : int;
	var anyCounts : bool;

	if (skills[skill].requiredSkills.Size() == 0)
		return true;

	for (j = 0; j < skills[skill].requiredSkills.Size(); j += 1)
	{
		if (SpectreCountsForLinks(skills[skill].requiredSkills[j], depth - 1))
		{
			if (skills[skill].requiredSkillsIsAlternative)
				return true;
			anyCounts = true;
		}
		else if (!skills[skill].requiredSkillsIsAlternative)
			return false;
	}

	return !skills[skill].requiredSkillsIsAlternative && anyCounts;
}

// Whether a skill counts as learned when another skill checks its links.
@addMethod(W3PlayerAbilityManager) function SpectreCountsForLinks(skill : ESkill, depth : int) : bool
{
	if (skills[skill].level - SpectreFreeRank(skill) > 0)
		return true;
	if (SpectreFreeRank(skill) == 0 || depth <= 0)
		return false;
	return SpectreLinksSatisfied(skill, depth);
}

// What the remaster menu shows as "unlocked by its links": every skill with a rank looks bought.
@addMethod(W3PlayerAbilityManager) function SpectreUnlockedByDependency(skill : ESkill) : bool
{
	if (skills[skill].level > 0)
		return true;
	return SpectreLinksSatisfied(skill, SpectreLinkDepth());
}
