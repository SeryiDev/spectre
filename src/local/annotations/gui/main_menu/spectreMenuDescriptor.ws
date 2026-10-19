// Same menu hint Eternal Hunt uses: a tutorial popup on the left, closed by CloseTutorialPopup.

struct SpectreMenuDescriptor_OptionDescription
{
	var option_id : name;
	var description : string;
	var description_loc_key : string;
	var dynamic_description : bool;
}

class SpectreMenuDescriptor
{
	private var option_hover_listeners : array<SpectreMenuDescriptor_OptionDescription>;
	private var menu_scope : string;
	private var message_fallback : string;

	public function Main()
	{
		this.onHover('spectreVersionControl',, "spectre_tip_version");
		this.onHover('spectreUseSpectreTree',, "spectre_tip_spectre_tree");
		this.onHover('spectreFreeStarterSkills',, "spectre_tip_free_starter_skills");
		this.onHover('spectreStarterSkillsUnslotted',, "spectre_tip_starter_skills_unslotted");
		this.onHover('spectreGeneralSkillsUnslotted',, "spectre_tip_general_skills_unslotted");
		this.onHover('spectreAllSlotsUnlocked',, "spectre_tip_all_slots_unlocked");
		this.onHover('spectreMutationsFromStart',, "spectre_tip_mutations_from_start");
		this.onHover('spectreMultipleMutations',, "spectre_tip_multiple_mutations");
		this.onHover('spectreMaxMutations',, "spectre_tip_max_mutations");
		this.onHover('spectreEquipAnyLevel',, "spectre_tip_equip_any_level");
		this.onHover('spectreLevelUpEquipped',, "spectre_tip_level_up_equipped");
		this.onHover('spectreUseSpectreCombat',, "spectre_tip_spectre_combat");
		// Greyed out outside a loaded game as Geralt (spectreUpdateUninstallOptionMenu): say why first.
		if (!spectreCanUninstallHere())
			this.onHover('spectreUninstall',, "spectre_tip_uninstall_unavailable");
		this.onHover('spectreUninstall',, "spectre_tip_uninstall");
		this.onHover('Virtual_spectreScaling',, "spectre_tip_scaling");
		this.onHover('spectreRandomScalingMinLevel',, "spectre_tip_scaling_min");
		this.onHover('spectreRandomScalingMaxLevel',, "spectre_tip_scaling_max");
		this.onHover('spectreNonlinearLevelup',, "spectre_tip_nonlinear");
		this.onHover('spectreNonlinearLevelDelta',, "spectre_tip_nonlinear_level");
		this.onHover('spectreNonlinearAbilitiesDelta',, "spectre_tip_nonlinear_abilities");
		this.onHover('spectreNoAddLevelsGuards',, "spectre_tip_no_guard_levels");
		this.onHover('spectreNoAnimalUpscaling',, "spectre_tip_no_animal_upscale");
		this.onHover('spectreMonsterHealthMultiplier',, "spectre_tip_monster_health");
		this.onHover('spectreHumanHealthMultiplier',, "spectre_tip_human_health");
		this.onHover('spectreAnimalHealthMultiplier',, "spectre_tip_animal_health");
		this.onHover('spectreDamageMultiplier',, "spectre_tip_damage");
		this.onHover('spectreBossHealthMultiplier',, "spectre_tip_boss_health");
		this.onHover('spectreBossDamageMultiplier',, "spectre_tip_boss_damage");
		this.onHover('spectreNoQuestLevels',, "spectre_tip_quest_levels");
		this.onHover('spectreUseXMLExp',, "spectre_tip_fixed_exp");
		this.onHover('spectreQuestExpModifier',, "spectre_tip_quest_exp");
		this.onHover('spectreSignInstantCast',, "spectre_tip_instant_sign");
		this.onHover('spectreSinkBoat',, "spectre_tip_boat");
		this.onHover('spectreSinkBoatOverEnc',, "spectre_tip_boat_threshold");
		this.onHover('spectreEncumbranceMultiplier',, "spectre_tip_encumbrance");
		this.onHover('spectreMerchantsRemoveSold',, "spectre_tip_merchants_remove_sold");
		this.onHover('spectreArmorRegenPenalty',, "spectre_tip_armor_regen");
		this.onHover('spectreCombatStaminaRegen',, "spectre_tip_stamina_regen");
		this.onHover('spectreOutOfCombatStaminaRegen',, "spectre_tip_stamina_regen_idle");
		this.onHover('spectreCombatVitalityRegen',, "spectre_tip_vitality_combat");
		this.onHover('spectreOutOfCombatVitalityRegen',, "spectre_tip_vitality_idle");
		this.onHover('spectreAgilityStaminaCostMultiplier',, "spectre_tip_agility_cost");
		this.onHover('spectreMeleeStaminaCostMultiplier',, "spectre_tip_melee_cost");
		this.onHover('spectreSignStaminaCostMultiplier',, "spectre_tip_sign_cost");
		this.onHover('spectreStaminaDelay',, "spectre_tip_stamina_delay");
		this.onHover('spectreMeleeSpecialCooldown',, "spectre_tip_special_cd");
		this.onHover('spectreSignCooldown',, "spectre_tip_sign_cd");
		this.onHover('spectreAltSignCooldown',, "spectre_tip_alt_sign_cd");
		this.onHover('spectreLootLos',, "spectre_tip_loot_los");
		this.onHover('spectreLootTheft',, "spectre_tip_loot_theft");
		this.onHover('spectreLootReactions',, "spectre_tip_loot_reactions");
		this.onHover('spectreLootGlobalRange',, "spectre_tip_loot_global");
		this.onHover('spectreLootPlantRange',, "spectre_tip_loot_plants");
		this.onHover('spectreLootClutterRange',, "spectre_tip_loot_clutter");
		this.onHover('spectreLootRemainsRange',, "spectre_tip_loot_remains");
		this.onHover('spectreLootMaxResults',, "spectre_tip_loot_limit");
		this.onHover('spectreAlchemy501Installed',, "spectre_tip_alchemy_501_installed");
		this.onHover('spectreTimeBasedAlchemy',, "spectre_tip_alchemy_time");
		this.onHover('spectreCasualAlchemy',, "spectre_tip_casual");
		this.onHover('spectrePrimarySubstances',, "spectre_tip_substances");
		this.onHover('spectrePotionDuration',, "spectre_tip_potion_override");
		this.onHover('spectrePotionDurationAdded',, "spectre_tip_potion_added");
		this.onHover('spectrePotionDurationMult',, "spectre_tip_potion_mult");
		this.onHover('spectreDigestionTime',, "spectre_tip_digestion");
		this.onHover('spectreToxicityMultiplier',, "spectre_tip_toxicity");
		this.onHover('spectreDegenerationRate',, "spectre_tip_degen");
		this.onHover('spectreAltDegenRate',, "spectre_tip_alt_degen");
		this.onHover('spectreAltDegenThreshold',, "spectre_tip_degen_threshold");
		this.onHover('spectreCombatDegeneration',, "spectre_tip_combat_degen");
		this.onHover('spectreCombatDegenRate',, "spectre_tip_combat_degen_rate");
		this.onHover('spectreResidualDegenRate',, "spectre_tip_residual_degen");
		this.onHover('spectreHerbsSpawnChance',, "spectre_tip_herbs");
		this.onHover('spectreCookedQuantity',, "spectre_tip_yield");
	}

	public final function enteredAt(menu : string)
	{
		this.menu_scope = menu;
		this.option_hover_listeners.Clear();
	}

	public final function didEnterAt(menu : string) : bool
	{
		return this.menu_scope == menu;
	}

	public final function onOptionHovered(menu : string, option : name) : string
	{
		var output : string;
		var piece : string;
		var i : int;

		for (i = 0; i < this.option_hover_listeners.Size(); i += 1)
		{
			if (this.option_hover_listeners[i].option_id != option)
				continue;

			piece = "";
			if (this.option_hover_listeners[i].description_loc_key != "")
				piece = GetLocStringByKeyExt(this.option_hover_listeners[i].description_loc_key);
			if (piece == "" || piece == this.option_hover_listeners[i].description_loc_key)
				piece = this.option_hover_listeners[i].description;
			output += piece;
		}

		// Alchemy 5.01 package: Spectre's alchemy options do nothing.
		if (output != "" && spectreAlchemy501() && spectreIsAlchemyOption(option))
			output += "<br/><font color=\"#3C8DC5\">" + GetLocStringByKeyExt("spectre_alchemy_501_option") + "</font>";

		return output;
	}

	public final function getMessageFallback() : string
	{
		return this.message_fallback;
	}

	protected final function onHover(option_id : name, optional description : string, optional description_loc_key : string)
	{
		this.option_hover_listeners.PushBack(SpectreMenuDescriptor_OptionDescription(option_id, description, description_loc_key, false));
	}
}

@addField(CR4IngameMenu)
var spectre_menu_descriptors : array<SpectreMenuDescriptor>;

@addField(CR4IngameMenu)
var spectre_menu_stack : array<string>;

@addField(CR4IngameMenu)
var spectre_menu_message_cache : string;

@addField(CR4IngameMenu)
var spectre_menu_message_fallback_cache : string;

@addField(CR4IngameMenu)
var spectre_menu_hovered_option : name;

@addField(CR4IngameMenu)
var spectre_menu_hovered_out_count : int;

@addMethod(CR4IngameMenu)
function Spectre_displayMessage(message : string, optional current_menu : string, optional optionName : name)
{
	var duration : float;
	var msg : W3TutorialPopupData;
	var title : string;

	duration = -1;

	if (message == "")
	{
		if (this.spectre_menu_message_fallback_cache != "")
			message = this.spectre_menu_message_fallback_cache;
	}

	if (message == this.spectre_menu_message_cache)
		return;

	this.spectre_menu_message_cache = message;

	if (message == "")
		duration = 0;

	msg = new W3TutorialPopupData in theGame;
	msg.managerRef = theGame.GetTutorialSystem();
	msg.canBeShownInMenus = true;
	msg.scriptTag = 'Spectre';
	msg.messageTitle = GetLocStringByKeyExt("panel_" + current_menu);
	msg.duration = duration;
	msg.posX = 0;
	msg.posY = 0;

	title = GetLocStringByKeyExt("option_" + NameToString(optionName));
	if (title != "")
		msg.messageText = "<p align=\"center\">" + "<b><u><mark>" + title + "</mark></u></b>" + "<br/><br/>" + message + "</p>";
	else
		msg.messageText = "<p align=\"center\">" + message + "</p>";

	theGame.GetTutorialSystem().ShowTutorialHint(msg);

	if (message == "")
		msg.CloseTutorialPopup();
}

@addMethod(CR4IngameMenu)
function Spectre_onMenuEntered(menu : string, out descriptors : array<SpectreMenuDescriptor>)
{
	if (menu == "spectre_main_options"
	|| menu == "spectre_skill_tree"
	|| menu == "spectre_equipment"
	|| menu == "spectre_combat"
	|| menu == "spectre_scaling_options"
	|| menu == "spectre_exp_options"
	|| menu == "spectre_gameplay_options"
	|| menu == "spectre_looting_options"
	|| menu == "spectre_alchemy_general"
	|| menu == "spectre_alchemy_brewing"
	|| menu == "spectre_potions_and_oils"
	|| menu == "spectre_toxicity_settings"
	|| menu == "spectre_alchemy_miscellaneous_settings"
	|| menu == "spectre_uninstall")
	{
		descriptors.PushBack(new SpectreMenuDescriptor in this);
	}
}

// Alchemy > General > "Vanilla alchemy package" shows whether the package is installed, also in the main menu.
@wrapMethod(CR4IngameMenu)
function showOptionsPanel() : void
{
	spectreShowAlchemy501Option();
	wrappedMethod();
}

@wrapMethod(CR4IngameMenu)
function OnShowOptionSubmenu(actionType : int, menuTag : int, id : string)
{
	var descriptor : SpectreMenuDescriptor;
	var message_fallback : string;
	var previous_size : int;

	previous_size = this.spectre_menu_descriptors.Size();
	this.Spectre_onMenuEntered(id, this.spectre_menu_descriptors);

	for (previous_size; previous_size < this.spectre_menu_descriptors.Size(); previous_size += 1)
	{
		descriptor = this.spectre_menu_descriptors[previous_size];
		if (descriptor)
		{
			descriptor.enteredAt(id);
			descriptor.Main();
		}
	}

	this.spectre_menu_stack.PushBack(id);

	for (previous_size = 0; previous_size < this.spectre_menu_descriptors.Size(); previous_size += 1)
	{
		descriptor = this.spectre_menu_descriptors[previous_size];
		if (descriptor)
			message_fallback += descriptor.getMessageFallback();
	}

	this.spectre_menu_message_fallback_cache = message_fallback;
	this.Spectre_displayMessage(message_fallback);

	wrappedMethod(actionType, menuTag, id);
	if (id == "spectre_combat")
		spectreUpdateCombatOptionsMenu(spectreUseSpectreCombat());
	if (id == "spectre_uninstall")
		spectreUpdateUninstallOptionMenu();
	if (id == "spectre_skill_tree")
		spectreUpdateMaxMutationsMenu(spectre_Settings_Main_Bool('spectreSkillTreeOptions', 'spectreMultipleMutations', false));
	if (id == "spectre_gameplay_options")
		spectreUpdateSinkBoatMenu(spectre_Settings_Main_Bool('spectreGameplayOptions', 'spectreSinkBoat', true));
}

@wrapMethod(CR4IngameMenu)
function OnOptionPanelNavigateBack()
{
	var descriptor : SpectreMenuDescriptor;
	var should_remove : bool;
	var menu_left : string;
	var i : int;

	this.spectre_menu_hovered_out_count = 0;
	this.spectre_menu_hovered_option = '';
	this.spectre_menu_message_fallback_cache = "";
	this.Spectre_displayMessage("");

	if (this.spectre_menu_stack.Size() > 0)
		menu_left = this.spectre_menu_stack.PopBack();

	for (i = 0; i < this.spectre_menu_descriptors.Size(); i += 1)
	{
		descriptor = this.spectre_menu_descriptors[i];
		should_remove = true;
		if (descriptor)
			should_remove = descriptor.didEnterAt(menu_left);

		if (should_remove)
		{
			this.spectre_menu_descriptors.Erase(i);
			i -= 1;
		}
	}

	return wrappedMethod();
}

@wrapMethod(CR4IngameMenu)
function OnOptionSelectionChanged(optionName : name, value : bool)
{
	var descriptor : SpectreMenuDescriptor;
	var current_menu : string;
	var message : string;
	var result : bool;
	var i : int;

	result = wrappedMethod(optionName, value);

	if (!value)
	{
		if (optionName == this.spectre_menu_hovered_option || this.spectre_menu_hovered_out_count > 15)
		{
			this.Spectre_displayMessage("");
			return result;
		}

		this.spectre_menu_hovered_out_count += 1;
		optionName = this.spectre_menu_hovered_option;
		value = true;
	}
	else
	{
		this.spectre_menu_hovered_out_count = 0;
		this.spectre_menu_hovered_option = optionName;
	}

	if (this.spectre_menu_stack.Size() > 0)
		current_menu = this.spectre_menu_stack.Last();

	for (i = 0; i < this.spectre_menu_descriptors.Size(); i += 1)
	{
		descriptor = this.spectre_menu_descriptors[i];
		if (descriptor)
			message += descriptor.onOptionHovered(current_menu, optionName);
	}

	this.Spectre_displayMessage(message, current_menu, optionName);

	return result;
}

// The options of the Alchemy tab (groups spectreAlchemy* in 000Spectre.xml).
function spectreIsAlchemyOption(option : name) : bool
{
	switch (option)
	{
		case 'spectreCookedQuantity':
		case 'spectreAlcoholUses':
		case 'spectreBottleRecycling':
		case 'spectreMutagens':
		case 'spectrePrimarySubstances':
		case 'spectreFireType':
		case 'spectreCampfire':
		case 'spectreCampfiresInterior':
		case 'spectreRequiredKindling':
		case 'spectreTimeBasedAlchemy':
		case 'spectreAlchemyTimeCost':
		case 'spectreDistillationTime':
		case 'spectreCasualAlchemy':
		case 'spectreDigestionTime':
		case 'spectreMaxPotions':
		case 'spectreMaxBombs':
		case 'spectreMaxOils':
		case 'spectrePotionDuration':
		case 'spectrePotionDurationAdded':
		case 'spectreDecoctionDuration':
		case 'spectreDecoctionDurationAdded':
		case 'spectrePotionDurationMult':
		case 'spectreDecoctionDurationMult':
		case 'spectreDegenerationRate':
		case 'spectreAltDegenRate':
		case 'spectreAltDegenThreshold':
		case 'spectreCombatDegeneration':
		case 'spectreCombatDegenRate':
		case 'spectreResidualDegenRate':
		case 'spectreToxicityMultiplier':
		case 'spectreModIcons':
		case 'spectreCameraRotationSpeed':
		case 'spectreHerbsSpawnMin':
		case 'spectreHerbsSpawnMax':
		case 'spectreHerbsHarvestMin':
		case 'spectreHerbsHarvestMax':
		case 'spectreHerbsSpawnChance':
		case 'spectreIgnoreHerbSpawns':
			return true;
	}
	return false;
}
