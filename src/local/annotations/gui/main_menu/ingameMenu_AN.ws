@addField(CR4IngameMenu)
protected var spectreHasChangedScalingOption : bool;
@addField(CR4IngameMenu)
protected var spectreHasChangedQuestLevelsOption : bool;
@addField(CR4IngameMenu)
protected var spectreHasChangedGameplayOption : bool;

@wrapMethod(CR4IngameMenu) function OnPresetApplied(groupId:name, targetPresetIndex:int)
{
	var result : bool;

	result = wrappedMethod(groupId, targetPresetIndex);

	if (groupId == 'spectreScalingOptions')
		spectreHasChangedScalingOption = true;
	if (groupId == 'spectreExpOptions')
		spectreHasChangedQuestLevelsOption = true;
	if (groupId == 'spectreGameplayOptions' || groupId == 'spectreCombatOptions')
		spectreHasChangedGameplayOption = true;
	if (groupId == 'spectreCombatOptions')
		spectreUpdateCombatOptionsMenu(spectreUseSpectreCombat());
	if (groupId == 'spectreSkillTreeOptions')
		spectreUpdateMaxMutationsMenu(spectre_Settings_Main_Bool('spectreSkillTreeOptions', 'spectreMultipleMutations', false));
	if (groupId == 'spectreGameplayOptions')
		spectreUpdateSinkBoatMenu(spectre_Settings_Main_Bool('spectreGameplayOptions', 'spectreSinkBoat', true));

	return result;
}

@wrapMethod(CR4IngameMenu) function OnOptionValueChanged(groupId:int, optionName:name, optionValue:string)
{
	var result : bool;

	result = wrappedMethod(groupId, optionName, optionValue);

	if (groupId == NameToFlashUInt('spectreScalingOptions'))
		spectreHasChangedScalingOption = true;
	if (spectreIsScalingOption(optionName))
		spectreHasChangedScalingOption = true;
	if (optionName == 'spectreNoQuestLevels')
		spectreHasChangedQuestLevelsOption = true;
	if (spectreIsGameplayOption(optionName))
		spectreHasChangedGameplayOption = true;
	if (optionName == 'spectreUseSpectreCombat')
	{
		spectreHasChangedGameplayOption = true;
		spectreUpdateCombatOptionsMenu(optionValue == "true");
	}
	if (optionName == 'spectreMultipleMutations')
		spectreUpdateMaxMutationsMenu(optionValue == "true");
	if (optionName == 'spectreSinkBoat')
		spectreUpdateSinkBoatMenu(optionValue == "true");

	return result;
}

@addMethod(CR4IngameMenu) function spectreUserSettings()
{
	if(spectreHasChangedScalingOption)
	{
		spectreHasChangedScalingOption = false;
		theGame.spectreUserSettingsScaling();
	}
	if(spectreHasChangedQuestLevelsOption)
	{
		spectreHasChangedQuestLevelsOption = false;
		theGame.spectreUserSettingsQuestLevels();
	}
	if(spectreHasChangedGameplayOption)
	{
		spectreHasChangedGameplayOption = false;
		spectreUpdateRegenEffects();
	}
}

@wrapMethod(CR4IngameMenu) function SaveChangedSettings()
{
	wrappedMethod();

	if (hasChangedOption)
	{
		spectreUserSettings();	  
	}
}

@wrapMethod(CR4IngameMenu) function SaveChangedSettings()
{
	theGame.alchexts.ReadMenuSettings(hasChangedOption);
	
	wrappedMethod();
}

// "Maximum mutations" can only be changed while "Several mutations at once" is on.
// "Sink threshold" only matters with "Sink Boat If Over Encumbered" on: grey it out while that is off.
@addMethod(CR4IngameMenu) function spectreUpdateSinkBoatMenu(sinkBoat : bool)
{
	var dataObject : CScriptedFlashObject;
	var dataArray : CScriptedFlashArray;

	dataArray = m_flashValueStorage.CreateTempFlashArray();
	dataObject = m_flashValueStorage.CreateTempFlashObject();
	dataObject.SetMemberFlashUInt("tag", NameToFlashUInt('spectreSinkBoatOverEnc'));
	dataObject.SetMemberFlashBool("disabled", !sinkBoat);
	dataArray.PushBackFlashObject(dataObject);
	m_flashValueStorage.SetFlashArray("options.update_disabled", dataArray);
	theGame.GetGuiManager().ForceProcessFlashStorage();
}

@addMethod(CR4IngameMenu) function spectreUpdateMaxMutationsMenu(multiple : bool)
{
	var dataObject : CScriptedFlashObject;
	var dataArray : CScriptedFlashArray;

	dataArray = m_flashValueStorage.CreateTempFlashArray();
	dataObject = m_flashValueStorage.CreateTempFlashObject();
	dataObject.SetMemberFlashUInt("tag", NameToFlashUInt('spectreMaxMutations'));
	dataObject.SetMemberFlashBool("disabled", !multiple);
	dataArray.PushBackFlashObject(dataObject);
	m_flashValueStorage.SetFlashArray("options.update_disabled", dataArray);
	theGame.GetGuiManager().ForceProcessFlashStorage();
}
