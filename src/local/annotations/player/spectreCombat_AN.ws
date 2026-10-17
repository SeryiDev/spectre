// Spectre: the option "Use Spectre's combat system" (group spectreCombatOptions, "Combat"; default on).
//
// Off, these parts of combat are as in the base game:
//   - Geralt's base stats in ConGeralt: stamina costs and delays of attacks, dodges, rolls, parries and items,
//     stamina regeneration, Adrenaline lost when hit, base poison and bleeding resistance. The 5.01 values are in
//     spectre_vanilla_ConGeralt (geralt_stats.xml); the two abilities swap on the character.
//   - Armor and overloading change stamina costs (CalcStaminaArmorPenalty, CalcSignCastingArmorPenalty,
//     CalcStaminaOverEncumbrancePenalty).
//   - Cooldowns of Whirl, Rend and the signs (spectreCombatCooldown).
//   - The extra stamina Rend costs when released early (combatSword.ws).
//   - The other options of the group do nothing, and the menu greys them out: no stamina, regeneration or delay
//     adjustments, armor slows stamina regeneration, no quick sign casting.

function spectreUseSpectreCombat() : bool
{
	return spectre_Settings_Main_Bool('spectreCombatOptions', 'spectreUseSpectreCombat', true);
}

// A number option of the group, or 0 (no change) while Spectre's combat system is off.
function spectreCombatFloat(optionName : name, defaultValue : float) : float
{
	if (!spectreUseSpectreCombat())
		return 0;
	return spectre_Settings_Main_Float('spectreCombatOptions', optionName, defaultValue);
}

// Seconds of a Spectre cooldown option, or 0 (no cooldown) while Spectre's combat system is off.
function spectreCombatCooldown(optionName : name, defaultSeconds : float) : float
{
	return spectreCombatFloat(optionName, defaultSeconds);
}

// The base game always slows stamina regeneration with armor.
function spectreArmorRegenPenaltyOn() : bool
{
	if (!spectreUseSpectreCombat())
		return true;
	return spectre_Settings_Main_Bool('spectreCombatOptions', 'spectreArmorRegenPenalty', false);
}

function spectreSignInstantCastOn() : bool
{
	if (!spectreUseSpectreCombat())
		return false;
	return spectre_Settings_Main_Bool('spectreCombatOptions', 'spectreSignInstantCast', true);
}

// Greys out the options under "Use Spectre's combat system" while it is off, so they cannot be changed. Runs when
// the Combat page opens, when the option changes and when a Combat preset is applied.
@addMethod(CR4IngameMenu) function spectreUpdateCombatOptionsMenu(useSpectre : bool)
{
	var conf : CInGameConfigWrapper;
	var dataObject : CScriptedFlashObject;
	var dataArray : CScriptedFlashArray;
	var optionName : name;
	var i : int;

	conf = theGame.GetInGameConfigWrapper();
	dataArray = m_flashValueStorage.CreateTempFlashArray();
	for (i = 0; i < conf.GetVarsNumByGroupName('spectreCombatOptions'); i += 1)
	{
		optionName = conf.GetVarNameByGroupName('spectreCombatOptions', i);
		if (optionName == 'spectreUseSpectreCombat')
			continue;
		dataObject = m_flashValueStorage.CreateTempFlashObject();
		dataObject.SetMemberFlashUInt("tag", NameToFlashUInt(optionName));
		dataObject.SetMemberFlashBool("disabled", !useSpectre);
		dataArray.PushBackFlashObject(dataObject);
	}
	m_flashValueStorage.SetFlashArray("options.update_disabled", dataArray);
	theGame.GetGuiManager().ForceProcessFlashStorage();
}

@addField(CR4Player)
var spectreCombatOptionApplied : bool;
@addField(CR4Player)
var spectreAppliedSpectreCombat : bool;

@addMethod(CR4Player) function SpectreCombatOptionChanged() : bool
{
	return !spectreCombatOptionApplied || spectreAppliedSpectreCombat != spectreUseSpectreCombat();
}

// Puts on Geralt the ConGeralt of the system in use. Runs on load and when the game menu closes.
@addMethod(CR4Player) function SpectreApplyCombatOption()
{
	var stats : CCharacterStats;
	var witcher : W3PlayerWitcher;
	var useSpectre : bool;
	var wanted, other : name;
	var focus, stamina, vitality : float;

	spectreCombatOptionApplied = true;
	useSpectre = spectreUseSpectreCombat();
	spectreAppliedSpectreCombat = useSpectre;
	witcher = (W3PlayerWitcher)this;
	if (!witcher)
		return;

	if (useSpectre)
	{
		wanted = 'ConGeralt';
		other = 'spectre_vanilla_ConGeralt';
	}
	else
	{
		wanted = 'spectre_vanilla_ConGeralt';
		other = 'ConGeralt';
	}

	stats = GetCharacterStats();
	if (!stats.HasAbility(other) && stats.HasAbility(wanted))
		return;

	// Both abilities hold the stat maximums, so swapping them refills Adrenaline: keep the current values.
	focus = witcher.GetStat(BCS_Focus);
	stamina = witcher.GetStat(BCS_Stamina);
	vitality = witcher.GetStat(BCS_Vitality);
	if (!stats.HasAbility(wanted))
		stats.AddAbility(wanted, false);
	stats.RemoveAbility(other);
	witcher.ForceSetStat(BCS_Focus, MinF(focus, witcher.GetStatMax(BCS_Focus)));
	witcher.ForceSetStat(BCS_Stamina, MinF(stamina, witcher.GetStatMax(BCS_Stamina)));
	witcher.ForceSetStat(BCS_Vitality, MinF(vitality, witcher.GetStatMax(BCS_Vitality)));
	spectreUpdateRegenEffects();
}
