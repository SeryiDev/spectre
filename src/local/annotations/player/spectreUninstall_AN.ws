// Spectre: removing Spectre from a save, before the mod is uninstalled.
//
// The save keeps Geralt's ability manager as a spectreAbilityManager. Without Spectre that class does not exist,
// the manager is lost on load and Geralt has no skills, mutations or stats (the maximum weight shows garbage).
// The option "Remove Spectre from this save" (spectreUninstallOptions / spectreUninstall) runs SpectreUninstall
// when the game menu closes:
//   - takes off the skills, mutations and skill mutagens, sets every skill to rank 0 and gives each skill its
//     5.01 definition (SpectreVanillaTree), with the 5.01 ability names;
//   - takes off Spectre's effects and abilities, and puts back ConGeralt;
//   - turns Spectre's dominance potions (Nigredo, Albedo, Rubedo) into the base potion, removes the items and
//     recipes only Spectre defines, Spectre's facts and the data Spectre keeps in the save;
//   - puts a W3PlayerAbilityManager in place of the spectreAbilityManager, with the same data;
//   - removes the fact RemasterSkillResetAndRefund, so the base game resets the skills from its own definitions
//     and gives back the skill points when the save loads without Spectre;
//   - makes a new manual save.
// Loading that save with Spectre still installed brings Spectre back: it builds its manager and its tree
// again and gives back the points (RebuildSkillTree).
// The option is greyed out in the main menu and while playing as Ciri.

@addMethod(CR4IngameMenu) function spectreUpdateUninstallOptionMenu()
{
	var dataObject : CScriptedFlashObject;
	var dataArray : CScriptedFlashArray;

	dataArray = m_flashValueStorage.CreateTempFlashArray();
	dataObject = m_flashValueStorage.CreateTempFlashObject();
	dataObject.SetMemberFlashUInt("tag", NameToFlashUInt('spectreUninstall'));
	dataObject.SetMemberFlashBool("disabled", isMainMenu || !spectreCanUninstallHere());
	dataArray.PushBackFlashObject(dataObject);
	m_flashValueStorage.SetFlashArray("options.update_disabled", dataArray);
	theGame.GetGuiManager().ForceProcessFlashStorage();
}

// Inside a loaded game, as Geralt, with Spectre's ability manager in place.
function spectreCanUninstallHere() : bool
{
	var witcher : W3PlayerWitcher;
	var mgr : spectreAbilityManager;

	witcher = GetWitcherPlayer();
	if (!witcher || thePlayer != witcher)
		return false;
	mgr = (spectreAbilityManager)witcher.abilityManager;
	if (!mgr)
		return false;
	return true;
}

function spectreUninstallRequested() : bool
{
	return spectre_Settings_Main_Bool('spectreUninstallOptions', 'spectreUninstall', false);
}

// The option is a one-shot switch: it never stays on, in the settings file or in another save.
function spectreClearUninstallOption()
{
	if (!spectreUninstallRequested())
		return;
	theGame.GetInGameConfigWrapper().SetVarValue('spectreUninstallOptions', 'spectreUninstall', "false");
	theGame.SaveUserSettings();
}

@addMethod(W3PlayerWitcher) function SpectreUninstall()
{
	var mgr : spectreAbilityManager;
	var vanillaMgr : W3PlayerAbilityManager;
	var alchexts : SpectreAlchemyExtensions;
	var horseManager : W3HorseManager;

	spectreClearUninstallOption();

	mgr = (spectreAbilityManager)abilityManager;
	if (!mgr || !spectreCanUninstallHere())
		return;
	if (IsInCombat() || theGame.AreSavesLocked())
	{
		theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("spectre_uninstall_blocked"));
		return;
	}

	RemoveTimer('spectreWatcher');

	SpectreUninstallEffects();
	UnequipItemFromSlot(EES_SkillMutagen1);
	UnequipItemFromSlot(EES_SkillMutagen2);
	UnequipItemFromSlot(EES_SkillMutagen3);
	UnequipItemFromSlot(EES_SkillMutagen4);
	mgr.SpectreUninstallSkills();
	SpectreUninstallAbilities();
	SpectreUninstallItems(inv);
	horseManager = GetHorseManager();
	if (horseManager)
		SpectreUninstallItems(horseManager.GetInventoryComponent());
	SpectreUninstallSavedData();

	vanillaMgr = new W3PlayerAbilityManager in this;
	vanillaMgr.SpectreCopyStateFrom(mgr);
	abilityManager = vanillaMgr;
	alchexts = theGame.alchexts;
	if (alchexts)
		alchexts.abltymgr = NULL;

	FactsRemove("RemasterSkillResetAndRefund");

	theGame.SaveGame(SGT_Manual, -1);
	theGame.GetGuiManager().ShowUserDialogAdv(0, "spectre_uninstall_done_title", "spectre_uninstall_done_text", true, UDB_Ok);
}

// Potions, toxicity and the effects only Spectre defines.
@addMethod(W3PlayerWitcher) function SpectreUninstallEffects()
{
	var types : array<EEffectType>;
	var i : int;

	RemoveAllPotionEffects();
	ForceSetStat(BCS_Toxicity, 0);

	types.PushBack(EET_Toxicity);
	types.PushBack(EET_UndyingSkillImmortal);
	types.PushBack(EET_UndyingSkillCooldown);
	types.PushBack(EET_WhirlCooldown);
	types.PushBack(EET_RendCooldown);
	types.PushBack(EET_AardCooldown);
	types.PushBack(EET_IgniCooldown);
	types.PushBack(EET_YrdenCooldown);
	types.PushBack(EET_QuenCooldown);
	types.PushBack(EET_AxiiCooldown);
	types.PushBack(EET_DimeritiumEffect);
	types.PushBack(EET_Perk13Effect);
	types.PushBack(EET_KaerMorhenSetBonus);
	types.PushBack(EET_MeltArmorDebuff);
	types.PushBack(EET_MeltArmorTimer);
	types.PushBack(EET_PhantomWeapon);
	types.PushBack(EET_Runeword4);
	types.PushBack(EET_Runeword11);
	types.PushBack(EET_MutationTrigger);
	types.PushBack(EET_AlbedoDominance);
	types.PushBack(EET_RubedoDominance);
	types.PushBack(EET_NigredoDominance);
	types.PushBack(EET_PotionDigestion);
	for (i = 0; i < types.Size(); i += 1)
		RemoveAllBuffsOfType(types[i]);
}

// ConGeralt back in place of its 5.01 copy, and every ability only Spectre defines taken off.
@addMethod(W3PlayerWitcher) function SpectreUninstallAbilities()
{
	var stats : CCharacterStats;
	var abilities, others : array<name>;
	var focus, stamina, vitality : float;
	var i : int;

	stats = GetCharacterStats();
	focus = GetStat(BCS_Focus);
	stamina = GetStat(BCS_Stamina);
	vitality = GetStat(BCS_Vitality);
	if (!stats.HasAbility('ConGeralt'))
		stats.AddAbility('ConGeralt', false);

	others.PushBack('ArmorTypeHeavySetBonusAbility');
	others.PushBack('ArmorTypeMediumSetBonusAbility');
	others.PushBack('ArmorTypeLightSetBonusAbility');
	others.PushBack('SetBonusAbilityWolf_2');
	others.PushBack('setBonusAbilityRedWolf_1');
	others.PushBack('setBonusAbilityViper_1');
	others.PushBack('Mitogenesis');
	others.PushBack('Metastasis');
	others.PushBack('Angiogenesis');
	others.PushBack('DimeritiumEffect_Level1');
	others.PushBack('DimeritiumEffect_Level2');
	others.PushBack('DimeritiumEffect_Level3');

	stats.GetAbilities(abilities, false);
	for (i = 0; i < abilities.Size(); i += 1)
	{
		if (StrBeginsWith(NameToString(abilities[i]), "spectre") || others.Contains(abilities[i]))
			stats.RemoveAbilityAll(abilities[i]);
	}

	ForceSetStat(BCS_Focus, MinF(focus, GetStatMax(BCS_Focus)));
	ForceSetStat(BCS_Stamina, MinF(stamina, GetStatMax(BCS_Stamina)));
	ForceSetStat(BCS_Vitality, MinF(vitality, GetStatMax(BCS_Vitality)));
}

// Items only Spectre defines, in Geralt's inventory or in the stash (the horse inventory). A dominance potion
// becomes the potion it was made from, with the same quantity.
@addMethod(W3PlayerWitcher) function SpectreUninstallItems(inventory : CInventoryComponent)
{
	var items : array<SItemUniqueId>;
	var bases, removed : array<name>;
	var suffixes : array<string>;
	var itemName : name;
	var itemString : string;
	var quantity, i, j, k : int;
	var converted : bool;

	if (!inventory)
		return;
	// The potions Spectre has Nigredo, Albedo and Rubedo versions of (dlc_spectre alchemy_items.xml).
	bases.PushBack('Black Blood 1');
	bases.PushBack('Black Blood 2');
	bases.PushBack('Black Blood 3');
	bases.PushBack('Blizzard 1');
	bases.PushBack('Blizzard 2');
	bases.PushBack('Blizzard 3');
	bases.PushBack('Cat 1');
	bases.PushBack('Cat 2');
	bases.PushBack('Cat 3');
	bases.PushBack('Full Moon 1');
	bases.PushBack('Full Moon 2');
	bases.PushBack('Full Moon 3');
	bases.PushBack('Golden Oriole 1');
	bases.PushBack('Golden Oriole 2');
	bases.PushBack('Golden Oriole 3');
	bases.PushBack('Killer Whale 1');
	bases.PushBack('Maribor Forest 1');
	bases.PushBack('Maribor Forest 2');
	bases.PushBack('Maribor Forest 3');
	bases.PushBack('Petri Philtre 1');
	bases.PushBack('Petri Philtre 2');
	bases.PushBack('Petri Philtre 3');
	bases.PushBack('Swallow 1');
	bases.PushBack('Swallow 2');
	bases.PushBack('Swallow 3');
	bases.PushBack('Tawny Owl 1');
	bases.PushBack('Tawny Owl 2');
	bases.PushBack('Tawny Owl 3');
	bases.PushBack('Thunderbolt 1');
	bases.PushBack('Thunderbolt 2');
	bases.PushBack('Thunderbolt 3');
	bases.PushBack('White Gull 1');
	bases.PushBack('White Raffards Decoction 1');
	bases.PushBack('White Raffards Decoction 2');
	bases.PushBack('White Raffards Decoction 3');
	suffixes.PushBack(" Nigredo");
	suffixes.PushBack(" Albedo");
	suffixes.PushBack(" Rubedo");
	removed.PushBack('Mutation Trigger');
	removed.PushBack('Recipe for Mutation Trigger');

	inventory.GetAllItems(items);
	for (i = items.Size() - 1; i >= 0; i -= 1)
	{
		itemName = inventory.GetItemName(items[i]);
		quantity = inventory.GetItemQuantity(items[i]);
		if (removed.Contains(itemName))
		{
			inventory.RemoveItem(items[i], quantity);
			continue;
		}
		itemString = NameToString(itemName);
		converted = false;
		for (j = 0; j < bases.Size() && !converted; j += 1)
		{
			for (k = 0; k < suffixes.Size() && !converted; k += 1)
			{
				if (itemString != NameToString(bases[j]) + suffixes[k])
					continue;
				inventory.RemoveItem(items[i], quantity);
				inventory.AddAnItem(bases[j], quantity, true, true);
				converted = true;
			}
		}
	}

	RemoveAlchemyRecipe('Recipe for Mutation Trigger');
}

// Spectre's facts and the data Spectre keeps in the save. Without Spectre the game would not read the data, but
// this way the save carries none of it.
@addMethod(W3PlayerWitcher) function SpectreUninstallSavedData()
{
	FactsRemove("spectre_initialized");
	FactsRemove("spectre_version");
	FactsRemove("spectre_version_control_toggle");
	FactsRemove("spectre_starting_gear_ok");
	FactsRemove("modSpectreRecipesAdded");
	FactsRemove("modSpectreKMSetSchematicsAdded");

	reusables.Clear();
	enemiesKilledByType.Clear();
	theGame.SpectreClearSavedData();
}

@addMethod(CR4Game) function SpectreClearSavedData()
{
	spawnareas.Clear();
}

// Every skill out of its slot and at rank 0, its abilities and the mutagen bonuses taken off, the mutations
// unequipped, and every skill with its 5.01 definition. The skill points are not given back here: the base game
// does it when the save loads without Spectre, and Spectre does it when it loads with Spectre.
@addMethod(W3PlayerAbilityManager) function SpectreUninstallSkills()
{
	var mgr : spectreAbilityManager;
	var defs, tree : array<SSkill>;
	var skillDefs : array<name>;
	var i : int;

	while (spectreEquippedMutations.Size() > 0)
	{
		if (!spectreSetEquippedMutation(spectreEquippedMutations[spectreEquippedMutations.Size() - 1], true))
			spectreEquippedMutations.EraseFast(spectreEquippedMutations.Size() - 1);
	}
	equippedMutation = EPMT_None;

	SpectreSuspendSkillEffects();
	mgr = (spectreAbilityManager)this;
	if (mgr)
		mgr.ClearSocketedSkills();
	ResetCharacterDev();
	for (i = 0; i < skills.Size(); i += 1)
	{
		if (skills[i].skillType == S_SUndefined || skills[i].isCoreSkill)
			continue;
		skills[i].level = 0;
		SpectreDropSkillAbilities(skills[i].skillType);
		owner.RemoveAbilityAll(SkillEnumToName(skills[i].skillType));
	}
	for (i = 0; i < pathPointsSpent.Size(); i += 1)
		pathPointsSpent[i] = 0;
	for (i = 0; i < mutagenBonuses.Size(); i += 1)
	{
		if (IsNameValid(mutagenBonuses[i].abilityName) && mutagenBonuses[i].count > 0)
			owner.RemoveAbilityMultiple(mutagenBonuses[i].abilityName, mutagenBonuses[i].count);
		mutagenBonuses[i].abilityName = '';
		mutagenBonuses[i].count = 0;
	}
	tempSkills.Clear();
	temporaryTutorialSkills.Clear();
	spectreFreeRankSkills.Clear();

	charStats.GetAbilitiesWithTag('SkillDefinitionName', skillDefs);
	for (i = 0; i < skillDefs.Size(); i += 1)
		CacheSkills(skillDefs[i], defs);
	SpectreTakeSkillDefinitions(defs);
	CacheSkills('SpectreVanillaTree', tree);
	SpectreTakeSkillDefinitions(tree);
}

// Every skill in the list takes its definition from it. Only the rank and the state the save keeps stay.
@addMethod(W3PlayerAbilityManager) function SpectreTakeSkillDefinitions(defs : array<SSkill>)
{
	var kept : SSkill;
	var s : ESkill;
	var i : int;

	for (i = 0; i < defs.Size(); i += 1)
	{
		s = defs[i].skillType;
		if (s == S_SUndefined)
			continue;
		kept = skills[s];
		skills[s] = defs[i];
		skills[s].level = kept.level;
		skills[s].isTemporary = kept.isTemporary;
		skills[s].isNew = kept.isNew;
		skills[s].remainingBlockedTime = kept.remainingBlockedTime;
		skills[s].wasEquippedOnUIEnter = kept.wasEquippedOnUIEnter;
		skills[s].precachedModifierSkills = kept.precachedModifierSkills;
	}
}

// Everything the save keeps of an ability manager, as spectreAbilityManager.Construct copies it the other way.
@addMethod(W3PlayerAbilityManager) function SpectreCopyStateFrom(abm : W3PlayerAbilityManager)
{
	owner = abm.owner;
	charStats = abm.charStats;
	usedHealthType = abm.usedHealthType;
	usedDifficultyMode = abm.usedDifficultyMode;
	difficultyAbilities = abm.difficultyAbilities;
	ignoresDifficultySettings = abm.ignoresDifficultySettings;
	blockedAbilities = abm.blockedAbilities;

	skills = abm.skills;
	resistStatsItems = abm.resistStatsItems;
	toxicityOffset = abm.toxicityOffset;
	pathPointsSpent = abm.pathPointsSpent;
	skillSlots = abm.skillSlots;
	skillAbilities = abm.skillAbilities;
	totalSkillSlotsCount = abm.totalSkillSlotsCount;
	tempSkills = abm.tempSkills;
	mutagenSlots = abm.mutagenSlots;
	temporaryTutorialSkills = abm.temporaryTutorialSkills;
	ep1SkillsInitialized = abm.ep1SkillsInitialized;
	ep2SkillsInitialized = abm.ep2SkillsInitialized;
	baseGamePerksGUIPosUpdated = abm.baseGamePerksGUIPosUpdated;
	remasterSkillsNeedInit = abm.remasterSkillsNeedInit;
	mutagenBonuses = abm.mutagenBonuses;
	alchemy19OptimizationDone = abm.alchemy19OptimizationDone;
	isMutationSystemEnabled = abm.isMutationSystemEnabled;
	equippedMutation = EPMT_None;
	mutations = abm.mutations;
	mutationUnlockedSlotsIndexes = abm.mutationUnlockedSlotsIndexes;
	mutationSkillSlotsInitialized = abm.mutationSkillSlotsInitialized;

	isInitialized = abm.isInitialized;
}
