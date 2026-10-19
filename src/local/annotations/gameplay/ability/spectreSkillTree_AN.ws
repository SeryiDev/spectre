// Spectre: the skill tree in use, kept apart from the rest of the ability manager.
//
// The option "Use Spectre's skill tree" (spectreSkillTreeOptions / spectreUseSpectreTree, default on)
// picks the tree:
//   On   Spectre's skills, as Spectre made them. They take the cells of the 5.01 skills listed in
//        SpectreTreePairs.
//   Off  the 5.01 skills, 100% as in 5.01: definitions (cells, links, ranks, names, texts) from the
//        SpectreVanillaTree definition in geralt_skills.xml, values from the spectre_vanilla_* abilities,
//        and the 5.01 code wherever Spectre changed it (spectreVanillaSkills()).
//
// Changing the tree never resets it. A skill that leaves the tree passes its ranks to the skill that takes
// its cell, up to that skill's maximum, and the ranks above it come back as unspent points. The tree is
// applied when a save loads (ApplySpectreSkillLayout) and when the game menu closes after the option
// changed (spectreWatcher).

// Tree the save is in: 0 for a save from before the option (Spectre's tree), 1 Spectre's tree, 2 the 5.01 tree.
@addField(W3PlayerAbilityManager)
private saved var spectreSkillTreeState : int;

// Alchemy branch of Spectre's tree: 0 or 1 Spectre's alchemy skills, 2 the 5.01 ones. The alchemy 5.01 variant
// of the bundle (spectreAlchemy501) puts the 5.01 alchemy skills in Spectre's tree; the 5.01 tree always has them.
@addField(W3PlayerAbilityManager)
private saved var spectreAlchemyBranchState : int;

// While the tree changes, skill effects are off (SpectreSuspendSkillEffects) and ranks change silently.
@addField(W3PlayerAbilityManager)
private var spectreSkillEffectsSuspended : bool;
@addField(W3PlayerAbilityManager)
private var spectreSuspendedSlots : array<int>;
@addField(W3PlayerAbilityManager)
private var spectreSuspendedSkills : array<ESkill>;

// Whether the skills in use are the 5.01 ones. Every script that does something different for the two
// trees asks this.
function spectreVanillaSkills() : bool
{
	var witcher : W3PlayerWitcher;
	var mgr : W3PlayerAbilityManager;

	witcher = GetWitcherPlayer();
	if (witcher)
		mgr = (W3PlayerAbilityManager)witcher.abilityManager;
	if (mgr)
		return mgr.SpectreUsesVanillaSkills();
	return !spectre_Settings_Main_Bool('spectreSkillTreeOptions', 'spectreUseSpectreTree', true);
}

// Whether the alchemy skills in use are the 5.01 ones: the 5.01 tree, or Spectre's tree with the alchemy 5.01
// variant. Every script that does something different for the two kinds of alchemy skills asks this.
function spectreVanillaAlchemySkills() : bool
{
	var witcher : W3PlayerWitcher;
	var mgr : W3PlayerAbilityManager;

	witcher = GetWitcherPlayer();
	if (witcher)
		mgr = (W3PlayerAbilityManager)witcher.abilityManager;
	if (mgr)
		return mgr.SpectreUsesVanillaAlchemySkills();
	return spectreVanillaSkills() || spectreAlchemy501();
}

@addMethod(W3PlayerAbilityManager) function SpectreUsesVanillaAlchemySkills() : bool
{
	return spectreSkillTreeState == 2 || spectreAlchemyBranchState == 2;
}

@addMethod(W3PlayerAbilityManager) function SpectreUseSpectreTree() : bool
{
	return spectre_Settings_Main_Bool('spectreSkillTreeOptions', 'spectreUseSpectreTree', true);
}

// The tree the skills are in now. It only changes when SpectreApplySkillTree applies the option.
@addMethod(W3PlayerAbilityManager) function SpectreUsesVanillaSkills() : bool
{
	return spectreSkillTreeState == 2;
}

// The only list of what changes between the two trees: each Spectre skill and the 5.01 skill whose cell
// it takes. "different" lists the 5.01 skills that do something else than the Spectre skill in their
// cell: their ranks are refunded instead of passed on.
@addMethod(W3PlayerAbilityManager) function SpectreTreePairs(out spectreSkills : array<ESkill>, out vanillaSkills : array<ESkill>, out different : array<ESkill>)
{
	spectreSkills.Clear();
	vanillaSkills.Clear();
	different.Clear();

	spectreSkills.PushBack(S_Sword_s01);	vanillaSkills.PushBack(S_Sword_s35);	// Whirl
	spectreSkills.PushBack(S_Sword_s10);	vanillaSkills.PushBack(S_Sword_s33);	// Arrow Deflection
	spectreSkills.PushBack(S_Sword_s21);	vanillaSkills.PushBack(S_Sword_s22);	// Muscle Memory
	spectreSkills.PushBack(S_Sword_s17);	vanillaSkills.PushBack(S_Sword_s24);	// Precise Blows
	spectreSkills.PushBack(S_Sword_s04);	vanillaSkills.PushBack(S_Sword_s23);	// Strength Training
	spectreSkills.PushBack(S_Sword_s08);	vanillaSkills.PushBack(S_Sword_s25);	// Crushing Blows
	spectreSkills.PushBack(S_Sword_s06);	vanillaSkills.PushBack(S_Sword_s28);	// Sunder Armor
	spectreSkills.PushBack(S_Sword_s05);	vanillaSkills.PushBack(S_Sword_s29);	// Crippling Strikes
	spectreSkills.PushBack(S_Sword_s09);	vanillaSkills.PushBack(S_Sword_s36);	// Fleet Footed
	spectreSkills.PushBack(S_Sword_s11);	vanillaSkills.PushBack(S_Sword_s31);	// Counterattack
	spectreSkills.PushBack(S_Sword_s03);	vanillaSkills.PushBack(S_Sword_s30);	// Deadly Precision
	spectreSkills.PushBack(S_Sword_s13);	vanillaSkills.PushBack(S_Sword_s32);	// Lightning Reflexes
	spectreSkills.PushBack(S_Sword_s07);	vanillaSkills.PushBack(S_Sword_s26);	// Anatomical Knowledge
	spectreSkills.PushBack(S_Sword_s12);	vanillaSkills.PushBack(S_Sword_s27);	// Crippling Shot
	spectreSkills.PushBack(S_Sword_s15);	vanillaSkills.PushBack(S_Sword_s34);	// Cold Blood
	spectreSkills.PushBack(S_Magic_s02);	vanillaSkills.PushBack(S_Magic_s28);	// Firestream
	spectreSkills.PushBack(S_Magic_s05);	vanillaSkills.PushBack(S_Magic_s31);	// Puppet
	spectreSkills.PushBack(S_Magic_s06);	vanillaSkills.PushBack(S_Magic_s33);	// Shock Wave
	spectreSkills.PushBack(S_Magic_s10);	vanillaSkills.PushBack(S_Magic_s42);	// Sustained Glyphs
	spectreSkills.PushBack(S_Alchemy_s07);	vanillaSkills.PushBack(S_Alchemy_s27);	// Hunter Instinct
	spectreSkills.PushBack(S_Alchemy_s01);	vanillaSkills.PushBack(S_Alchemy_s24);
	spectreSkills.PushBack(S_Alchemy_s17);	vanillaSkills.PushBack(S_Alchemy_s22);
	spectreSkills.PushBack(S_Alchemy_s06);	vanillaSkills.PushBack(S_Alchemy_s25);	// Fixative
	spectreSkills.PushBack(S_Perk_05);		vanillaSkills.PushBack(S_Perk_23);		// Cat School Techniques
	spectreSkills.PushBack(S_Perk_06);		vanillaSkills.PushBack(S_Perk_24);		// Griffin School Techniques
	spectreSkills.PushBack(S_Perk_07);		vanillaSkills.PushBack(S_Perk_25);		// Bear School Techniques
	spectreSkills.PushBack(S_Perk_01);		vanillaSkills.PushBack(S_Perk_38);		// Sun and Stars
	spectreSkills.PushBack(S_Perk_04);		vanillaSkills.PushBack(S_Perk_30);
	spectreSkills.PushBack(S_Perk_09);		vanillaSkills.PushBack(S_Perk_34);
	spectreSkills.PushBack(S_Perk_10);		vanillaSkills.PushBack(S_Perk_42);
	spectreSkills.PushBack(S_Perk_12);		vanillaSkills.PushBack(S_Perk_33);
	spectreSkills.PushBack(S_Perk_13);		vanillaSkills.PushBack(S_Perk_32);
	spectreSkills.PushBack(S_Perk_15);		vanillaSkills.PushBack(S_Perk_41);
	spectreSkills.PushBack(S_Perk_18);		vanillaSkills.PushBack(S_Perk_39);
	spectreSkills.PushBack(S_Perk_19);		vanillaSkills.PushBack(S_Perk_40);
	spectreSkills.PushBack(S_Perk_21);		vanillaSkills.PushBack(S_Perk_31);
	spectreSkills.PushBack(S_Perk_22);		vanillaSkills.PushBack(S_Perk_35);
	spectreSkills.PushBack(S_Perk_14);		vanillaSkills.PushBack(S_Perk_44);		different.PushBack(S_Perk_44);
}

// The skill in the other tree's cell, or the skill itself when both trees have it.
@addMethod(W3PlayerAbilityManager) function SpectreTreeCounterpart(skill : ESkill) : ESkill
{
	var spectreSkills, vanillaSkills, different : array<ESkill>;
	var i : int;

	SpectreTreePairs(spectreSkills, vanillaSkills, different);
	i = spectreSkills.FindFirst(skill);
	if (i >= 0)
		return vanillaSkills[i];
	i = vanillaSkills.FindFirst(skill);
	if (i >= 0)
		return spectreSkills[i];
	return skill;
}

@addMethod(W3PlayerAbilityManager) function SpectreSkillTreeChanged() : bool
{
	if (SpectreUsesVanillaSkills() == SpectreUseSpectreTree())
		return true;
	// Spectre's tree, and the alchemy 5.01 variant was installed or removed.
	return SpectreUseSpectreTree() && (spectreAlchemyBranchState == 2) != spectreAlchemy501();
}

// Puts the skills in the cells of the tree picked by the option and moves the ranks of the skills that
// left it. The GeraltSkills definitions are already in place (ApplySpectreSkillLayout). The tree in use
// changes at the end, so everything before runs as in the old tree.
@addMethod(W3PlayerAbilityManager) function SpectreApplySkillTree()
{
	var useSpectre : bool;

	useSpectre = SpectreUseSpectreTree();
	if (useSpectre)
	{
		SpectrePlaceSpectreSkills();
		if (spectreAlchemy501())
			SpectrePlaceVanillaAlchemySkills();
	}
	else
		SpectrePlaceVanillaSkills();
	SpectreMoveRanksToTree(useSpectre);

	if (useSpectre)
		spectreSkillTreeState = 1;
	else
		spectreSkillTreeState = 2;
	spectreAlchemyBranchState = 1;
	if (useSpectre && spectreAlchemy501())
		spectreAlchemyBranchState = 2;
}

// Takes every skill out of its slot and turns off the effects of the ones that work without a slot, as
// the tree in use does it. SpectreResumeSkillEffects puts them back as the new tree does.
@addMethod(W3PlayerAbilityManager) function SpectreSuspendSkillEffects()
{
	var i : int;
	var skill : ESkill;

	spectreSuspendedSlots.Clear();
	spectreSuspendedSkills.Clear();
	for (i = 0; i < skillSlots.Size(); i += 1)
	{
		skill = skillSlots[i].socketedSkill;
		if (skill == S_SUndefined)
			continue;
		spectreSuspendedSlots.PushBack(skillSlots[i].id);
		spectreSuspendedSkills.PushBack(skill);
		SpectreUnequipAnySlot(skillSlots[i].id);
	}

	SpectreFillActiveSkills();
	for (i = 0; i < spectreActiveSkills.Size(); i += 1)
	{
		skill = spectreActiveSkills[i];
		if (skills[skill].level > 0 && !SpectreIsModSkill(skill))
			OnSkillUnequip(skill);
		if (!SpectreIsModSkill(skill))
			SpectreDropSkillAbilities(skill);
	}
	spectreSkillEffectsSuspended = true;
}

@addMethod(W3PlayerAbilityManager) function SpectreResumeSkillEffects()
{
	var i : int;
	var skill : ESkill;

	spectreSkillEffectsSuspended = false;
	SpectreFillActiveSkills();
	// The General skills get their effects here as the option says, so SpectreApplyGeneralSlotOption has nothing to change.
	spectreGeneralsUnslottedState = 2;
	if (SpectreGeneralSkillsUnslotted())
		spectreGeneralsUnslottedState = 1;
	for (i = 0; i < spectreActiveSkills.Size(); i += 1)
	{
		skill = spectreActiveSkills[i];
		if (skills[skill].level > 0 && !SpectreIsModSkill(skill))
			OnSkillEquip(skill);
	}

	for (i = 0; i < spectreSuspendedSlots.Size(); i += 1)
	{
		skill = spectreSuspendedSkills[i];
		if (skills[skill].level <= 0)
			skill = SpectreTreeCounterpart(skill);
		if (skills[skill].level > 0 && SpectreIsOnSkillTree(skill))
			EquipSkill(skill, spectreSuspendedSlots[i]);
	}
	spectreSuspendedSlots.Clear();
	spectreSuspendedSkills.Clear();
}

// Unequips a slot even if it is locked now.
@addMethod(W3PlayerAbilityManager) function SpectreUnequipAnySlot(slotID : int)
{
	var idx : int;
	var wasUnlocked : bool;

	idx = GetSkillSlotIndex(slotID, false);
	if (idx < 0)
		return;
	wasUnlocked = skillSlots[idx].unlocked;
	skillSlots[idx].unlocked = true;
	UnequipSkill(slotID);
	skillSlots[idx].unlocked = wasUnlocked;
}

// Skills whose effects spectreAbilityManager applies itself (Spectre's own alchemy skills).
@addMethod(W3PlayerAbilityManager) function SpectreIsModSkill(skill : ESkill) : bool
{
	var mgr : spectreAbilityManager;

	mgr = (spectreAbilityManager)this;
	if (mgr)
		return mgr.SpectreUsesSkill(skill);
	return false;
}

// Each Spectre skill takes the cell of its 5.01 skill: position, links, icon. The 5.01 skill leaves the tree,
// and the links that named it name the Spectre skill.
@addMethod(W3PlayerAbilityManager) function SpectrePlaceSpectreSkills()
{
	var spectreSkills, vanillaSkills, different : array<ESkill>;
	var s, v : ESkill;
	var i, j, k : int;

	SpectreTreePairs(spectreSkills, vanillaSkills, different);
	for (i = 0; i < spectreSkills.Size(); i += 1)
	{
		s = spectreSkills[i];
		v = vanillaSkills[i];
		skills[s].requiredSkills = skills[v].requiredSkills;
		skills[s].requiredSkillsIsAlternative = skills[v].requiredSkillsIsAlternative;
		skills[s].requiredPointsSpent = skills[v].requiredPointsSpent;
		skills[s].gridRow = skills[v].gridRow;
		skills[s].gridColumn = skills[v].gridColumn;
		if (!different.Contains(v))
		{
			skills[s].iconPath = skills[v].iconPath;
			skills[s].iconPathTest = skills[v].iconPath;
		}
		skills[s].isReworked = false;
		skills[s].isUnchangedLegacy = true;
		skills[v].skillSubPath = ESSP_Core;
	}

	for (j = 0; j < skills.Size(); j += 1)
	{
		for (k = 0; k < skills[j].requiredSkills.Size(); k += 1)
		{
			i = vanillaSkills.FindFirst(skills[j].requiredSkills[k]);
			if (i >= 0)
				skills[j].requiredSkills[k] = spectreSkills[i];
		}
	}

	skills[S_Perk_14].iconPath = "icons\Perks\icon_perk_focused_power.png";
	skills[S_Perk_14].iconPathTest = skills[S_Perk_14].iconPath;
}

// Every skill as 5.01 defines it. Only what the save keeps (rank, temporary, new, blocked time) stays.
// Skills whose values Spectre changed use the 5.01 copy of their ability (spectre_vanilla_<ability>).
@addMethod(W3PlayerAbilityManager) function SpectrePlaceVanillaSkills()
{
	var tree : array<SSkill>;
	var kept : SSkill;
	var copy : name;
	var s : ESkill;
	var i : int;

	CacheSkills('SpectreVanillaTree', tree);
	for (i = 0; i < tree.Size(); i += 1)
	{
		s = tree[i].skillType;
		if (s == S_SUndefined)
			continue;
		kept = skills[s];
		skills[s] = tree[i];
		skills[s].level = kept.level;
		skills[s].isTemporary = kept.isTemporary;
		skills[s].isNew = kept.isNew;
		skills[s].remainingBlockedTime = kept.remainingBlockedTime;
		skills[s].wasEquippedOnUIEnter = kept.wasEquippedOnUIEnter;
		skills[s].precachedModifierSkills = kept.precachedModifierSkills;

		copy = SpectreVanillaAbilityName(skills[s].abilityName);
		if (IsNameValid(copy))
			skills[s].abilityName = copy;
	}
}

// Spectre's tree with the alchemy 5.01 variant: the alchemy branch as 5.01 defines it, as SpectrePlaceVanillaSkills
// does for the whole tree.
@addMethod(W3PlayerAbilityManager) function SpectrePlaceVanillaAlchemySkills()
{
	var tree : array<SSkill>;
	var kept : SSkill;
	var copy : name;
	var s : ESkill;
	var i : int;

	CacheSkills('SpectreVanillaTree', tree);
	for (i = 0; i < tree.Size(); i += 1)
	{
		s = tree[i].skillType;
		if (s == S_SUndefined || tree[i].skillPath != ESP_Alchemy)
			continue;
		kept = skills[s];
		skills[s] = tree[i];
		skills[s].level = kept.level;
		skills[s].isTemporary = kept.isTemporary;
		skills[s].isNew = kept.isNew;
		skills[s].remainingBlockedTime = kept.remainingBlockedTime;
		skills[s].wasEquippedOnUIEnter = kept.wasEquippedOnUIEnter;
		skills[s].precachedModifierSkills = kept.precachedModifierSkills;

		copy = SpectreVanillaAbilityName(skills[s].abilityName);
		if (IsNameValid(copy))
			skills[s].abilityName = copy;
	}
}

// The ability that holds a skill's values for the tree in use. With the 5.01 tree, the 5.01 copy of the
// abilities Spectre changed: a skill ability (sword_s16) or a per-rank bonus (sword_adrenalinegain,
// magic_staminaregen, alchemy_potionduration). Everything else keeps its name.
@addMethod(W3PlayerAbilityManager) function SpectreSkillAbility(ability : name) : name
{
	var skill : ESkill;
	var copy : name;

	// The alchemy abilities follow the alchemy skills in use (Spectre's tree with the alchemy 5.01 variant).
	if (!SpectreUsesVanillaSkills() && !(SpectreUsesVanillaAlchemySkills() && StrBeginsWith(NameToString(ability), "alchemy")))
		return ability;
	skill = SkillNameToEnum(ability);
	if (skill != S_SUndefined && skills[skill].abilityName != ability)
		return skills[skill].abilityName;
	copy = SpectreVanillaAbilityName(ability);
	if (IsNameValid(copy))
		return copy;
	return ability;
}

function spectreSkillAbility(ability : name) : name
{
	var witcher : W3PlayerWitcher;
	var mgr : W3PlayerAbilityManager;

	witcher = GetWitcherPlayer();
	if (witcher)
		mgr = (W3PlayerAbilityManager)witcher.abilityManager;
	if (mgr)
		return mgr.SpectreSkillAbility(ability);
	return ability;
}

// Name of the 5.01 copy of an ability Spectre changed (the spectre_vanilla_* abilities in the bundle XML),
// or '' when Spectre did not change it.
@addMethod(W3PlayerAbilityManager) function SpectreVanillaAbilityName(ability : name) : name
{
	switch (ability)
	{
		case 'alchemy_potionduration':	return 'spectre_vanilla_alchemy_potionduration';
		case 'alchemy_s1':	return 'spectre_vanilla_alchemy_s1';
		case 'alchemy_s2':	return 'spectre_vanilla_alchemy_s2';
		case 'alchemy_s3':	return 'spectre_vanilla_alchemy_s3';
		case 'alchemy_s4':	return 'spectre_vanilla_alchemy_s4';
		case 'alchemy_s5':	return 'spectre_vanilla_alchemy_s5';
		case 'alchemy_s6':	return 'spectre_vanilla_alchemy_s6';
		case 'alchemy_s7':	return 'spectre_vanilla_alchemy_s7';
		case 'alchemy_s9':	return 'spectre_vanilla_alchemy_s9';
		case 'alchemy_s10':	return 'spectre_vanilla_alchemy_s10';
		case 'alchemy_s11':	return 'spectre_vanilla_alchemy_s11';
		case 'alchemy_s12':	return 'spectre_vanilla_alchemy_s12';
		case 'alchemy_s13':	return 'spectre_vanilla_alchemy_s13';
		case 'alchemy_s14':	return 'spectre_vanilla_alchemy_s14';
		case 'alchemy_s15':	return 'spectre_vanilla_alchemy_s15';
		case 'alchemy_s16':	return 'spectre_vanilla_alchemy_s16';
		case 'alchemy_s17':	return 'spectre_vanilla_alchemy_s17';
		case 'alchemy_s18':	return 'spectre_vanilla_alchemy_s18';
		case 'alchemy_s19':	return 'spectre_vanilla_alchemy_s19';
		case 'alchemy_s23':	return 'spectre_vanilla_alchemy_s23';
		case 'alchemy_s26':	return 'spectre_vanilla_alchemy_s26';
		case 'magic_s1':	return 'spectre_vanilla_magic_s1';
		case 'magic_s2':	return 'spectre_vanilla_magic_s2';
		case 'magic_s3':	return 'spectre_vanilla_magic_s3';
		case 'magic_s4':	return 'spectre_vanilla_magic_s4';
		case 'magic_s5':	return 'spectre_vanilla_magic_s5';
		case 'magic_s6':	return 'spectre_vanilla_magic_s6';
		case 'magic_s7':	return 'spectre_vanilla_magic_s7';
		case 'magic_s8':	return 'spectre_vanilla_magic_s8';
		case 'magic_s9':	return 'spectre_vanilla_magic_s9';
		case 'magic_s10':	return 'spectre_vanilla_magic_s10';
		case 'magic_s11':	return 'spectre_vanilla_magic_s11';
		case 'magic_s12':	return 'spectre_vanilla_magic_s12';
		case 'magic_s13':	return 'spectre_vanilla_magic_s13';
		case 'magic_s14':	return 'spectre_vanilla_magic_s14';
		case 'magic_s15':	return 'spectre_vanilla_magic_s15';
		case 'magic_s16':	return 'spectre_vanilla_magic_s16';
		case 'magic_s17':	return 'spectre_vanilla_magic_s17';
		case 'magic_s18':	return 'spectre_vanilla_magic_s18';
		case 'magic_s19':	return 'spectre_vanilla_magic_s19';
		case 'magic_s20':	return 'spectre_vanilla_magic_s20';
		case 'magic_s35':	return 'spectre_vanilla_magic_s35';
		case 'magic_s36':	return 'spectre_vanilla_magic_s36';
		case 'magic_s38':	return 'spectre_vanilla_magic_s38';
		case 'magic_s39':	return 'spectre_vanilla_magic_s39';
		case 'magic_s40':	return 'spectre_vanilla_magic_s40';
		case 'magic_s41':	return 'spectre_vanilla_magic_s41';
		case 'magic_staminaregen':	return 'spectre_vanilla_magic_staminaregen';
		case 'perk_1':	return 'spectre_vanilla_perk_1';
		case 'perk_2':	return 'spectre_vanilla_perk_2';
		case 'perk_4':	return 'spectre_vanilla_perk_4';
		case 'perk_5':	return 'spectre_vanilla_perk_5';
		case 'perk_6':	return 'spectre_vanilla_perk_6';
		case 'perk_7':	return 'spectre_vanilla_perk_7';
		case 'perk_10':	return 'spectre_vanilla_perk_10';
		case 'perk_11':	return 'spectre_vanilla_perk_11';
		case 'perk_12':	return 'spectre_vanilla_perk_12';
		case 'perk_15':	return 'spectre_vanilla_perk_15';
		case 'perk_19':	return 'spectre_vanilla_perk_19';
		case 'perk_20':	return 'spectre_vanilla_perk_20';
		case 'perk_21':	return 'spectre_vanilla_perk_21';
		case 'perk_22':	return 'spectre_vanilla_perk_22';
		case 'perk_26':	return 'spectre_vanilla_perk_26';
		case 'perk_27':	return 'spectre_vanilla_perk_27';
		case 'perk_28':	return 'spectre_vanilla_perk_28';
		case 'perk_37':	return 'spectre_vanilla_perk_37';
		case 'perk_43':	return 'spectre_vanilla_perk_43';
		case 'sword_adrenalinegain':	return 'spectre_vanilla_sword_adrenalinegain';
		case 'sword_s1':	return 'spectre_vanilla_sword_s1';
		case 'sword_s2':	return 'spectre_vanilla_sword_s2';
		case 'sword_s3':	return 'spectre_vanilla_sword_s3';
		case 'sword_s4':	return 'spectre_vanilla_sword_s4';
		case 'sword_s5':	return 'spectre_vanilla_sword_s5';
		case 'sword_s6':	return 'spectre_vanilla_sword_s6';
		case 'sword_s7':	return 'spectre_vanilla_sword_s7';
		case 'sword_s8':	return 'spectre_vanilla_sword_s8';
		case 'sword_s9':	return 'spectre_vanilla_sword_s9';
		case 'sword_s10':	return 'spectre_vanilla_sword_s10';
		case 'sword_s11':	return 'spectre_vanilla_sword_s11';
		case 'sword_s12':	return 'spectre_vanilla_sword_s12';
		case 'sword_s13':	return 'spectre_vanilla_sword_s13';
		case 'sword_s15':	return 'spectre_vanilla_sword_s15';
		case 'sword_s16':	return 'spectre_vanilla_sword_s16';
		case 'sword_s17':	return 'spectre_vanilla_sword_s17';
		case 'sword_s18':	return 'spectre_vanilla_sword_s18';
		case 'sword_s19':	return 'spectre_vanilla_sword_s19';
		case 'sword_s20':	return 'spectre_vanilla_sword_s20';
		case 'sword_s21':	return 'spectre_vanilla_sword_s21';
		default:	return '';
	}
}

// Ranks of the skills that are off the tree go to the skill in their cell. Also cuts any skill above its
// maximum (Wolf, Manticore and Viper School went from 3 ranks to 1).
@addMethod(W3PlayerAbilityManager) function SpectreMoveRanksToTree(useSpectre : bool)
{
	var spectreSkills, vanillaSkills, different : array<ESkill>;
	var from, to : ESkill;
	var i : int;

	SpectreTreePairs(spectreSkills, vanillaSkills, different);
	for (i = 0; i < spectreSkills.Size(); i += 1)
	{
		// Spectre's tree with the alchemy 5.01 variant: the alchemy pairs go to the 5.01 skill.
		if (useSpectre && !(spectreAlchemy501() && skills[vanillaSkills[i]].skillPath == ESP_Alchemy))
		{
			from = vanillaSkills[i];
			to = spectreSkills[i];
		}
		else
		{
			from = spectreSkills[i];
			to = vanillaSkills[i];
		}
		if (skills[from].level <= 0)
			continue;
		if (different.Contains(vanillaSkills[i]))
			SpectreMoveSkillRanks(from, S_SUndefined);
		else
			SpectreMoveSkillRanks(from, to);
	}

	for (i = 0; i < skills.Size(); i += 1)
	{
		if (skills[i].level > skills[i].maxLevel && skills[i].maxLevel > 0 && !skills[i].isCoreSkill && !skills[i].isTemporary)
			SpectreMoveSkillRanks(skills[i].skillType, skills[i].skillType);
	}
}

// Holding Z on a skill in the skill menu (SpectreResetSkillRanks): gives back the points of its paid ranks and takes
// it out of its slot. A free starter rank stays. The skills linked after it that would lose their links are reset
// too, last ones first (in a line 1 to 5, resetting 3 resets 5, 4 and 3); one still linked through another bought
// skill stays. Returns how many skills were reset, 0 when the skill has no paid rank.
@addMethod(W3PlayerAbilityManager) function SpectreResetSkill(skill : ESkill) : int
{
	var mgr : spectreAbilityManager;
	var chain : array<ESkill>;
	var kept : array<int>;
	var other : ESkill;
	var i, j : int;
	var changed, linked : bool;

	if (skill == S_SUndefined || skills[skill].isCoreSkill)
		return 0;
	if (skills[skill].level - SpectreFreeRank(skill) <= 0)
		return 0;

	// Find the chain with every skill in it set to its free rank, then put the ranks back.
	chain.PushBack(skill);
	kept.PushBack(skills[skill].level);
	skills[skill].level = SpectreFreeRank(skill);
	changed = true;
	while (changed)
	{
		changed = false;
		for (j = 0; j < skills.Size(); j += 1)
		{
			other = skills[j].skillType;
			if (other == S_SUndefined || chain.Contains(other) || skills[j].isCoreSkill)
				continue;
			if (skills[j].level - SpectreFreeRank(other) <= 0)
				continue;
			if (!skills[j].isReworked && !skills[j].isUnchangedLegacy)
				continue;
			// Only skills linked to one in the chain: a skill whose links were already missing (older saves) stays.
			linked = false;
			for (i = 0; i < skills[j].requiredSkills.Size() && !linked; i += 1)
				linked = chain.Contains(skills[j].requiredSkills[i]);
			if (!linked)
				continue;
			if (SpectreLinksSatisfied(other, SpectreLinkDepth()))
				continue;
			chain.PushBack(other);
			kept.PushBack(skills[j].level);
			skills[j].level = SpectreFreeRank(other);
			changed = true;
		}
	}
	for (i = 0; i < chain.Size(); i += 1)
		skills[chain[i]].level = kept[i];

	for (i = chain.Size() - 1; i >= 0; i -= 1)
		SpectreResetOneSkill(chain[i]);

	mgr = (spectreAbilityManager)this;
	if (mgr)
		mgr.SpectreRefreshSkillEffects();
	return chain.Size();
}

@addMethod(W3PlayerAbilityManager) function SpectreResetOneSkill(skill : ESkill)
{
	var free, paid, slot : int;

	free = SpectreFreeRank(skill);
	paid = skills[skill].level - free;
	if (paid <= 0)
		return;
	slot = GetSkillSlotID(skill);
	if (slot >= 0)
		SpectreUnequipAnySlot(slot);
	SpectreSetSkillLevel(skill, free);
	pathPointsSpent[skills[skill].skillPath] -= paid;
	GetWitcherPlayer().levelManager.UnspendPoints(ESkillPoint, paid);
}

// Moves the ranks of one skill to another, up to its maximum, and keeps its slot. Paid ranks that do not fit
// come back as unspent points; a free first rank (starter skills) moves with them. With "to" undefined,
// every paid rank comes back. With "to" the same skill, only what is above the maximum comes back.
@addMethod(W3PlayerAbilityManager) function SpectreMoveSkillRanks(from : ESkill, to : ESkill)
{
	var fromSlot, toSlot, free, paid, kept, level, refund : int;

	fromSlot = GetSkillSlotID(from);
	if (fromSlot >= 0)
		UnequipSkill(fromSlot);
	toSlot = -1;
	if (to != S_SUndefined && to != from)
	{
		toSlot = GetSkillSlotID(to);
		if (toSlot >= 0)
			UnequipSkill(toSlot);
	}

	free = SpectreFreeRank(from);
	paid = skills[from].level - free;
	spectreFreeRankSkills.Remove(from);
	SpectreSetSkillLevel(from, 0);

	refund = paid;
	if (to != S_SUndefined)
	{
		level = skills[to].level + paid;
		if (free > 0 && SpectreFreeRank(to) == 0)
		{
			level += 1;
			if (!spectreFreeRankSkills.Contains(to))
				spectreFreeRankSkills.PushBack(to);
		}
		refund = Max(0, level - skills[to].maxLevel);
		level -= refund;
		kept = paid - refund;
		SpectreSetSkillLevel(to, level);
		pathPointsSpent[skills[to].skillPath] += kept;
	}
	pathPointsSpent[skills[from].skillPath] -= paid;
	if (refund > 0)
		GetWitcherPlayer().levelManager.UnspendPoints(ESkillPoint, refund);

	if (to == S_SUndefined || skills[to].level <= 0)
		return;
	if (toSlot >= 0)
		EquipSkill(to, toSlot);
	else if (fromSlot >= 0)
		EquipSkill(to, fromSlot);
}

// Sets the rank of a skill that is not in a slot, and keeps the effects of the skills that work without one
// in step. Spectre's own alchemy skills get their effects from spectreAbilityManager instead. While the tree
// changes, effects are suspended and only the rank changes.
@addMethod(W3PlayerAbilityManager) function SpectreSetSkillLevel(skill : ESkill, level : int)
{
	var unslotted : bool;

	if (spectreSkillEffectsSuspended)
	{
		skills[skill].level = level;
		return;
	}
	unslotted = spectreActiveSkills.Contains(skill) && !SpectreIsModSkill(skill);
	if (unslotted && skills[skill].level > 0)
		OnSkillUnequip(skill);
	if (!SpectreIsModSkill(skill))
		SpectreDropSkillAbilities(skill);
	skills[skill].level = level;
	if (unslotted && level > 0)
		OnSkillEquip(skill);
}
