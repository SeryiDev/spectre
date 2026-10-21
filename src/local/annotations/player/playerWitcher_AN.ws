@addField(W3PlayerWitcher)
private saved var enemiesKilledByType				: array<int>;

@wrapMethod(W3PlayerWitcher) function OnSpawned( spawnData : SEntitySpawnData )
{
	var i 				: int;
	var items 			: array<SItemUniqueId>;
	var items2 			: array<SItemUniqueId>;
	var horseTemplate 	: CEntityTemplate;
	var horseManager 	: W3HorseManager;
	var exceptions 		: array<CBaseGameplayEffect>;
	var wolf 			: CBaseGameplayEffect;
	var bankMutation6	: string;
	
	if(false) 
	{
		wrappedMethod(spawnData);
	}
	
	AddAnimEventCallback( 'ActionBlend', 			'OnAnimEvent_ActionBlend' );
	AddAnimEventCallback('cast_begin',				'OnAnimEvent_Sign');
	AddAnimEventCallback('cast_throw',				'OnAnimEvent_Sign');
	AddAnimEventCallback('cast_end',				'OnAnimEvent_Sign');
	AddAnimEventCallback('cast_friendly_begin',		'OnAnimEvent_Sign');
	AddAnimEventCallback('cast_friendly_throw',		'OnAnimEvent_Sign');
	AddAnimEventCallback('axii_ready',				'OnAnimEvent_Sign');
	AddAnimEventCallback('axii_alternate_ready',	'OnAnimEvent_Sign');
	AddAnimEventCallback('yrden_draw_ready',		'OnAnimEvent_Sign');
	AddAnimEventCallback('aard_finisher',		'OnAnimEvent_SignFinisher');
	AddAnimEventCallback( 'ProjectileThrow',	'OnAnimEvent_Throwable'	);
	AddAnimEventCallback( 'OnWeaponReload',		'OnAnimEvent_Throwable'	);
	AddAnimEventCallback( 'ProjectileAttach',	'OnAnimEvent_Throwable' );
	AddAnimEventCallback( 'Mutation11AnimEnd',	'OnAnimEvent_Mutation11AnimEnd' );
	AddAnimEventCallback( 'Mutation11ShockWave', 'OnAnimEvent_Mutation11ShockWave' );

	amountOfSetPiecesEquipped.Resize( EnumGetMax( 'EItemSetType' ) + 1 );
	
	runewordInfusionType = ST_None;
			
	inv = GetInventory();

	inv.GetAllItems(items);
	for(i=0; i<items.Size(); i+=1)
	{
		UnlockAppearance(inv.GetItemName(items[i]));
	}

	signOwner = new W3SignOwnerPlayer in this;
	signOwner.Init( this );
	
	itemSlots.Resize( EnumGetMax('EEquipmentSlots')+1 );

	if( FactsQuerySum("modSpectreRecipesAdded") < 1 )
	{
		AddAlchemyRecipe('Recipe for Tawny Owl 1', true, true);
		AddCraftingSchematic('Meteorite plate schematic', true, true);
		FactsAdd("modSpectreRecipesAdded");
	}
	
	FactsRemove("player_had_quen");

	if( FactsQuerySum("modSpectreKMSetSchematicsAdded") < 1 )
	{
		AddCraftingSchematic('Kaer Morhen Armor 1 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Armor 2 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Armor 3 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Pants schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Pants 1 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Pants 2 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Pants 3 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Boots schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Boots 1 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Boots 2 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Boots 3 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Gloves schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Gloves 1 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Gloves 2 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Gloves 3 schematic',true, true);
		FactsAdd("modSpectreKMSetSchematicsAdded");
	}
	
	if(!spawnData.restored)
	{
		levelManager = new W3LevelManager in this;			
		levelManager.Initialize();
		
		
		inv.GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if(inv.IsItemMounted(items[i]) && ( !inv.IsItemBody(items[i]) || inv.GetItemCategory(items[i]) == 'hair' ) )
				EquipItem(items[i]);
		}
		
		
		
		
		
		AddAlchemyRecipe('Recipe for Swallow 1',true,true);
		AddAlchemyRecipe('Recipe for Cat 1',true,true);
		AddAlchemyRecipe('Recipe for White Honey 1',true,true);
		
		AddAlchemyRecipe('Recipe for Samum 1',true,true);
		AddAlchemyRecipe('Recipe for Grapeshot 1',true,true);
		
		AddAlchemyRecipe('Recipe for Specter Oil 1',true,true);
		AddAlchemyRecipe('Recipe for Necrophage Oil 1',true,true);
		AddAlchemyRecipe('Recipe for Alcohest 1',true,true);
	}
	else
	{
		AddTimer('DelayedOnItemMount', 0.1, true);
		
		AddTimer('spectreDelayedLevelUpEquipped', 0.1, false);

		if (theGame.GetDLCManager().IsDLCAvailable('dlc_eh') 
		&& theGame.GetDLCManager().IsDLCEnabled('dlc_eh') 
		)
		{
			AddTimer('spectreCooldownBuffCheck', 0.1, true);
		}

		CheckHairItem();
	}
	
	
	AddStartingSchematics();

	super.OnSpawned( spawnData );

	theGame.alchexts.OnPlayerSpawned(this);
	
	
	AddAlchemyRecipe('Recipe for Mutagen red',true,true);
	AddAlchemyRecipe('Recipe for Mutagen green',true,true);
	AddAlchemyRecipe('Recipe for Mutagen blue',true,true);
	AddAlchemyRecipe('Recipe for Greater mutagen red',true,true);
	AddAlchemyRecipe('Recipe for Greater mutagen green',true,true);
	AddAlchemyRecipe('Recipe for Greater mutagen blue',true,true);
	
	AddCraftingSchematic('Starting Armor Upgrade schematic 1',true,true);
	
	
	if( inputHandler )
	{
		inputHandler.BlockAllActions( 'being_ciri', false );
	}
	SetBehaviorVariable( 'test_ciri_replacer', 0.0f);
	
	if(!spawnData.restored)
	{
		
		abilityManager.GainStat(BCS_Toxicity, 0);		
	}		
	
	levelManager.PostInit(this, spawnData.restored, true);
	
	SetBIsCombatActionAllowed( true );		
	SetBIsInputAllowed( true, 'OnSpawned' );				
	
	
	if ( !reputationManager )
	{
		reputationManager = new W3Reputation in this;
		reputationManager.Initialize();
	}
	
	theSound.SoundParameter( "focus_aim", 1.0f, 1.0f );
	theSound.SoundParameter( "focus_distance", 0.0f, 1.0f );
	
	currentlyCastSign = ST_None;
	
	if(!spawnData.restored)
	{
		horseTemplate = (CEntityTemplate)LoadResource("horse_manager");
		horseManager = (W3HorseManager)theGame.CreateEntity(horseTemplate, GetWorldPosition(),,,,,PM_Persist);
		horseManager.CreateAttachment(this);
		horseManager.OnCreated();
		EntityHandleSet( horseManagerHandle, horseManager );
	}
	else
	{
		AddTimer('DelayedHorseUpdate', 0.01, true);
	}
	
	
	RemoveAbility('Ciri_CombatRegen');
	RemoveAbility('Ciri_Rage');
	RemoveAbility('CiriBlink');
	RemoveAbility('CiriCharge');
	RemoveAbility('Ciri_Q205');
	RemoveAbility('Ciri_Q305');
	RemoveAbility('Ciri_Q403');
	RemoveAbility('Ciri_Q111');
	RemoveAbility('Ciri_Q501');
	RemoveAbility('SkillCiri');
	
	RemoveAbilityAll('sword_adrenalinegain');
	RemoveAbilityAll('magic_staminaregen');
	RemoveAbilityAll('alchemy_potionduration');
	
	savedQuenHealth = 0.f;
	savedQuenDuration = 0.f;
	
	if(spawnData.restored)
	{
		ApplyPatchFixes();
	}
	else
	{
		FactsAdd( "new_game_started_in_1_20" );
		FactsAdd( "new_game_started_with_GM_40" );						
	}
	
	if ( spawnData.restored )
	{
		FixEquippedMutagens();
	}
	
	if ( FactsQuerySum("NewGamePlus") > 0 )
	{
		NewGamePlusAdjustDLC1TemerianSet(inv);
		NewGamePlusAdjustDLC5NilfgardianSet(inv);
		NewGamePlusAdjustDLC10WolfSet(inv);
		NewGamePlusAdjustDLC14SkelligeSet(inv);
		
		if(horseManager)
		{
			NewGamePlusAdjustDLC1TemerianSet(horseManager.GetInventoryComponent());
			NewGamePlusAdjustDLC5NilfgardianSet(horseManager.GetInventoryComponent());
			NewGamePlusAdjustDLC10WolfSet(horseManager.GetInventoryComponent());
			NewGamePlusAdjustDLC14SkelligeSet(horseManager.GetInventoryComponent());	
		}
	}

	LoadCurrentSetBonusSoundbank();
	if(IsMutationResearched(EPMT_Mutation11) /*|| IsMutationResearched(EPMT_Mutation12)*/)
	{
		if(!alchemyRecipes.Contains('Recipe for Mutation Trigger'))
			AddAlchemyRecipe('Recipe for Mutation Trigger', true, true);
	}

	ResumeStaminaRegen('WhirlSkill');
	ResumeStaminaRegen('RendSkill'); 
	ResumeStaminaRegen('IsPerformingFinisher'); 		

	ResumeHPRegenEffects('FistFightMinigame');		
	
	if(HasRunewordActive('Runeword 4 _Stats'))
		StartVitalityRegen();
	
	if(HasAbility('sword_s19'))
	{
		AddTimer('spectreRemoveTempSkillsDelay', 1, false);
	}
	
	if( enemiesKilledByType.Size() == 0 )
	{
		enemiesKilledByType.Resize(EENT_MAX_TYPES);
	}
	
	
	if( HasBuff( EET_GryphonSetBonusYrden ) )
	{
		RemoveBuff( EET_GryphonSetBonusYrden, false, "GryphonSetBonusYrden" );
	}
	
	if( HasBuff( EET_GryphonSetBonus ) ) 
	{
		RemoveBuff( EET_GryphonSetBonus );
	}
	
	if( HasBuff(EET_KaerMorhenSetBonus) ) 
	{
		RemoveBuff(EET_KaerMorhenSetBonus);
	}
	
	if( HasBuff( EET_Aerondight ) )
		RemoveBuff( EET_Aerondight );
		
	if( HasBuff( EET_PhantomWeapon ) )
		RemoveBuff( EET_PhantomWeapon );
		
	RemoveBuff(EET_Runeword4);
	RemoveBuff(EET_Runeword11);
	RemoveAbilityAll('Glyphword 14 _Stats');
	RemoveAbilityAll('Glyphword 10 _Stats');

	if( FactsQuerySum("standalone_ep1") > 0 && FactsQuerySum("standalone_ep1_inv") < 1 )
	{
		spectreFreshStandaloneStart = true;
		FactsAdd("RemasterSkillResetAndRefund");
		AddTimer('GiveStandAloneEP1Items', 0.00001, true, , , true);
	}

	if( FactsQuerySum("standalone_ep2") > 0 && FactsQuerySum("standalone_ep2_inv") < 1 )
	{
		spectreFreshStandaloneStart = true;
		FactsAdd("RemasterSkillResetAndRefund");
		AddTimer('GiveStandAloneEP2Items', 0.00001, true, , , true);
	}
	
	
	if( spawnData.restored )
	{
		UpdateEncumbrance();
		
		
		RemoveBuff( EET_Mutation11Immortal );
		RemoveBuff( EET_Mutation11Buff );
		RemoveBuff( EET_UndyingSkillImmortal );
	}
	
	
	theGame.GameplayFactsAdd( "PlayerIsGeralt" );
	
	isInitialized = true;
	
	
	if(IsMutationActive( EPMT_Mutation6 ))
		if(( (W3PlayerAbilityManager)abilityManager).GetMutationSoundBank(( EPMT_Mutation6 )) != "" ) 
			theSound.SoundLoadBank(((W3PlayerAbilityManager)abilityManager).GetMutationSoundBank(( EPMT_Mutation6 )), true );
	
	
	
	if( FactsQuerySum("NGE_SkillPointsCheck") < 1 )
	{
		
		ForceSetStat(BCS_Toxicity, 0);
			
		RemoveAllPotionEffects();
		

		AddTimer('NGE_FixSkillPoints',1.0f,false);
	}		
	
	
	
	ManageSetBonusesSoundbanks(EIST_Lynx);
	ManageSetBonusesSoundbanks(EIST_Gryphon);
	ManageSetBonusesSoundbanks(EIST_Bear);
	

	m_quenHitFxTTL = 0;
	m_TriggerEffectDisablePending = false;
	m_TriggerEffectDisabled = false;
	ApplyGamepadTriggerEffect( equippedSign );
	AddTimer( 'UpdateGamepadTriggerEffect', 0.1, true );

	AddTimer('CheckRemasterSkillResetAndRefund', 1.5f, false);
	AddTimer('spectreRestoreSkillText', 2.5f, false);
	AddTimer('spectreRepairAppearance', 0.25f, true);

	skillComboData[S_Sword_s22].Resize(1);
	skillComboData[S_Sword_s23].Resize(1);
	skillComboData[S_Sword_s24].Resize(2);
	skillComboData[S_Sword_s25].Resize(1);


	if (theGame.GetDLCManager().IsDLCAvailable('dlcvhud') 
	&& theGame.GetDLCManager().IsDLCEnabled('dlcvhud') 
	)
	{
		if( FactsQuerySum( "spectre_vlad_init" ) <= 0 )
		{
			AddTimer('spectreResetSkillsForVlad', 0.1, false);

			FactsAdd( "spectre_vlad_init", 1, -1 );
		}
	}
}

@addField(W3PlayerWitcher)
private var spectreGearTries : int;

@addMethod(W3PlayerWitcher) function spectreMountBodyParts()
{
	var i : int;
	var ids : array<SItemUniqueId>;
	var bodyNames : array<name>;

	if(!inv)
		return;

	CheckHairItem();

	bodyNames.PushBack('Body underwear 01');
	bodyNames.PushBack('Body torso medalion');
	bodyNames.PushBack('Body palms 01');
	bodyNames.PushBack('Body feet 01');
	for(i = 0; i < bodyNames.Size(); i += 1)
	{
		ids = inv.GetItemsByName(bodyNames[i]);
		if(ids.Size() == 0 || !inv.IsIdValid(ids[0]))
			ids = inv.AddAnItem(bodyNames[i], 1);
		if(ids.Size() > 0 && inv.IsIdValid(ids[0]) && !inv.IsItemMounted(ids[0]))
			inv.MountItem(ids[0], false);
	}
}

@addMethod(W3PlayerWitcher) function spectreSlotHasRealGear(slot : EEquipmentSlots, allowShirt : bool, out equipped : SItemUniqueId) : bool
{
	var itemName : name;

	if(!GetItemEquippedOnSlot(slot, equipped))
		return false;
	if(!inv.IsIdValid(equipped) || inv.IsItemBody(equipped))
		return false;

	itemName = inv.GetItemName(equipped);
	if(!allowShirt && itemName == 'Geralt Shirt')
		return false;

	return true;
}

@addMethod(W3PlayerWitcher) function spectreEnsureGearSlot(slot : EEquipmentSlots, category : name, itemName : name) : bool
{
	var i : int;
	var equipped, picked : SItemUniqueId;
	var found : array<SItemUniqueId>;
	var current : name;
	var hadGear : bool;

	hadGear = FactsQuerySum("spectre_starting_gear_ok") > 0;
	if(spectreSlotHasRealGear(slot, hadGear, equipped))
		return true;
	// A new game starts with Geralt naked in the bath and the prologue dresses him: only a character
	// that has worn its gear gets it back.
	if(!hadGear)
		return false;

	found = inv.GetItemsByCategory(category);
	for(i = 0; i < found.Size(); i += 1)
	{
		if(!inv.IsIdValid(found[i]) || inv.IsItemBody(found[i]))
			continue;
		current = inv.GetItemName(found[i]);
		if(current == 'Geralt Shirt')
			continue;
		picked = found[i];
		if(EquipItemInGivenSlot(picked, slot, false))
			return true;
	}

	found = inv.AddAnItem(itemName, 1);
	if(found.Size() == 0 || !inv.IsIdValid(found[0]))
		return false;

	picked = found[0];
	if(EquipItemInGivenSlot(picked, slot, false))
		return true;

	inv.MountItem(picked, false);
	if(GetItemEquippedOnSlot(slot, equipped) && equipped == picked)
		return true;
	return false;
}

@addMethod(W3PlayerWitcher) timer function spectreRestoreSkillText(dt : float, id : int)
{
	var mgr : spectreAbilityManager;

	mgr = (spectreAbilityManager)abilityManager;
	if (mgr)
		mgr.RestoreSpectreSkillLocKeys();
}

@addMethod(W3PlayerWitcher) timer function spectreRepairAppearance(dt : float, id : int)
{
	var ready : bool;
	var steelName, silverName, armorName, bootsName, pantsName, glovesName : name;

	spectreGearTries += 1;
	if(!inv)
	{
		if(spectreGearTries > 16)
			RemoveTimer('spectreRepairAppearance');
		return;
	}

	spectreMountBodyParts();

	if(FactsQuerySum("standalone_ep2") > 0)
	{
		steelName = 'EP2 Standalone Starting Steel Sword';
		silverName = 'EP2 Standalone Starting Silver Sword';
		armorName = 'EP2 Standalone Starting Armor';
		bootsName = 'EP2 Standalone Starting Boots';
		pantsName = 'EP2 Standalone Starting Pants';
		glovesName = 'EP2 Standalone Starting Gloves';
	}
	else if(FactsQuerySum("standalone_ep1") > 0 || FactsQuerySum("StandAloneEP1") > 0)
	{
		steelName = 'EP1 Standalone Starting Steel Sword';
		silverName = 'EP1 Standalone Starting Silver Sword';
		armorName = 'EP1 Standalone Starting Armor';
		bootsName = 'EP1 Standalone Starting Boots';
		pantsName = 'EP1 Standalone Starting Pants';
		glovesName = 'EP1 Standalone Starting Gloves';
	}
	else
	{
		steelName = 'Long Steel Sword';
		silverName = 'Witcher Silver Sword';
		armorName = 'Starting Armor';
		bootsName = 'Starting Boots';
		pantsName = 'Starting Pants';
		glovesName = 'Starting Gloves';
	}

	ready = true;
	if(!spectreEnsureGearSlot(EES_SteelSword, 'steelsword', steelName))
		ready = false;
	if(!spectreEnsureGearSlot(EES_SilverSword, 'silversword', silverName))
		ready = false;
	if(!spectreEnsureGearSlot(EES_Armor, 'armor', armorName))
		ready = false;
	if(!spectreEnsureGearSlot(EES_Boots, 'boots', bootsName))
		ready = false;
	if(!spectreEnsureGearSlot(EES_Pants, 'pants', pantsName))
		ready = false;
	if(!spectreEnsureGearSlot(EES_Gloves, 'gloves', glovesName))
		ready = false;

	if(ready && FactsQuerySum("spectre_starting_gear_ok") < 1)
		FactsAdd("spectre_starting_gear_ok", 1);

	if(spectreGearTries > 16 || (ready && spectreGearTries > 8))
		RemoveTimer('spectreRepairAppearance');
}

@addMethod(W3PlayerWitcher) timer function spectreResetSkillsForVlad(dt : float, timerId : int)
{
	var template : CEntityTemplate;
	var entity : CEntity;
	var invTesting : CInventoryComponent;
	var i, totalExp, currentLevel, totalSkillPoints : int;
	var items : array<SItemUniqueId>;
	var abs : array<name>;
	var isMutationSystemEnabled : bool;
	var weaponId : SItemUniqueId;	
	var lm : W3PlayerWitcher;
	var j,exp : int;

	
	ForceSetStat(BCS_Toxicity, 0);

	if(GetItemEquippedOnSlot(EES_SilverSword, weaponId))
	{
		if(inv.CanItemHaveOil(weaponId))
		{
			inv.RemoveAllOilsFromItem(weaponId);
			inv.RemoveAllOilAbilitiesFromItem(weaponId);
		}
	}
	
	if(GetItemEquippedOnSlot(EES_SteelSword, weaponId))
	{
		if(inv.CanItemHaveOil(weaponId))
		{
			inv.RemoveAllOilsFromItem(weaponId);
			inv.RemoveAllOilAbilitiesFromItem(weaponId);
		}
	}
	
	currentLevel = levelManager.GetLevel();
	totalExp = levelManager.GetPointsTotal(EExperiencePoint);
	totalSkillPoints = levelManager.GetPointsTotal(ESkillPoint);
	isMutationSystemEnabled = ((W3PlayerAbilityManager)abilityManager).IsMutationSystemEnabled();
	
	spectreDebug_RestoreMutagensSpent();
	
	GetCharacterStats().GetAbilities(abs, false);
	for(i=0; i<abs.Size(); i+=1)
		RemoveAbility(abs[i]);
	abs.Clear();
	GetCharacterStatsParam(abs);		
	for(i=0; i<abs.Size(); i+=1)
		AddAbility(abs[i]);
				
	delete abilityManager;
	SetAbilityManager();
	abilityManager.Init(this, GetCharacterStats(), false, theGame.GetDifficultyMode());
	
	delete effectManager;
	SetEffectManager();
	
	abilityManager.PostInit();
	((W3PlayerAbilityManager)abilityManager).MutationSystemEnable(isMutationSystemEnabled);


	lm = GetWitcherPlayer();

	for(j=0; j<1; j+=1)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false );
	}
}

@addMethod(W3PlayerWitcher) function IncKills( et : EEnemyType )
{
	enemiesKilledByType[et] += 1;
}

@addMethod(W3PlayerWitcher) function GetKills( et : EEnemyType ) : int
{
	return enemiesKilledByType[et];
}

@addMethod(W3PlayerWitcher) function GetExpModifierByEnemyType( et : EEnemyType ) : float
{
	switch(et)
	{
		case EENT_BOSS:
			return 1;
		case EENT_GENERIC:
		case EENT_ANIMAL:
			return 0;
		default:
			return 1 - MinF(100.0f, (float)GetKills(et))/100.0f;
	}
}

@wrapMethod(W3PlayerWitcher) function OnAbilityAdded( abilityName : name)
{
	if(false) 
	{
		wrappedMethod(abilityName);
	}

	super.OnAbilityAdded(abilityName);
	
	if( HasRunewordActive('Runeword 4 _Stats') )
	{
		StartVitalityRegen();
	}
		
	if ( abilityName == 'Runeword 8 _Stats' && GetStat(BCS_Focus, true) >= GetStatMax(BCS_Focus) && !HasBuff(EET_Runeword8) )
	{
		AddEffectDefault(EET_Runeword8, this, "equipped item");
	}

}

@wrapMethod(W3PlayerWitcher) function ApplyPatchFixes()
{
	var cnt, transmutationCount, mutagenCount, i, slot : int;
	var transmutationAbility, itemName : name;
	var pam : W3PlayerAbilityManager;
	var slotId : int;
	var offset : float;
	var buffs : array<CBaseGameplayEffect>;
	var mutagen : W3Mutagen_Effect;
	var skill : SSimpleSkill;
	var spentSkillPoints, swordSkillPointsSpent, alchemySkillPointsSpent, perkSkillPointsSpent, pointsToAdd : int;
	var mutagens : array< W3Mutagen_Effect >;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(FactsQuerySum("DontShowRecipePinTut") < 1)
	{
		FactsAdd( "DontShowRecipePinTut" );
		TutorialScript('alchemyRecipePin', '');
		TutorialScript('craftingRecipePin', '');
	}
	
	if(FactsQuerySum("LevelReqPotGiven") < 1)
	{
		FactsAdd("LevelReqPotGiven");
		inv.AddAnItem('Wolf Hour', 1, false, false, true);
	}
	
	if(!HasBuff(EET_AutoStaminaRegen))
	{
		AddEffectDefault(EET_AutoStaminaRegen, this, 'autobuff', false);
	}
	
	buffs = GetBuffs();
	offset = 0;
	mutagenCount = 0;
	for(i=0; i<buffs.Size(); i+=1)
	{
		mutagen = (W3Mutagen_Effect)buffs[i];
		if(mutagen)
		{
			offset += mutagen.GetToxicityOffset();
			mutagenCount += 1;
		}
	}
	
	if(offset != (GetStat(BCS_Toxicity) - GetStat(BCS_Toxicity, true)))
		SetToxicityOffset(offset);
		
	RecalcTransmutationAbilities();
	
	if(theGame.GetDLCManager().IsEP1Available())
	{
		theGame.GetJournalManager().ActivateEntryByScriptTag('TutorialJournalEnchanting', JS_Active);
	}

	if(HasAbility('sword_s19') && FactsQuerySum("Patch_Sword_s19") < 1)
	{
		pam = (W3PlayerAbilityManager)abilityManager;

		skill.level = 0;
		for(i = S_Magic_s01; i <= S_Magic_s42; i+=1)
		{
			skill.skillType = i;				
			pam.RemoveTemporarySkill(skill);
		}
		
		spentSkillPoints = levelManager.GetPointsUsed(ESkillPoint);
		swordSkillPointsSpent = pam.GetPathPointsSpent(ESP_Sword);
		alchemySkillPointsSpent = pam.GetPathPointsSpent(ESP_Alchemy);
		perkSkillPointsSpent = pam.GetPathPointsSpent(ESP_Perks);
		
		pointsToAdd = spentSkillPoints - swordSkillPointsSpent - alchemySkillPointsSpent - perkSkillPointsSpent;
		if(pointsToAdd > 0)
			levelManager.UnspendPoints(ESkillPoint, pointsToAdd);
		
		
		RemoveAbilityAll('sword_s19');
		
		
		FactsAdd("Patch_Sword_s19");
	}
	
	if( HasAbility( 'sword_s19' ) )
	{
		RemoveAbilityAll( 'sword_s19' );
	}
	
	if( FactsQuerySum( "Patch_Decoction_Buff_Icons" ) < 1 )
	{
		mutagens = GetMutagenBuffs();
		for( i=0; i<mutagens.Size(); i+=1 )
		{
			itemName = DecoctionEffectTypeToItemName( mutagens[i].GetEffectType() );				
			mutagens[i].OverrideIcon( itemName );
		}
		
		FactsAdd( "Patch_Decoction_Buff_Icons" );
	}
	
	if( FactsQuerySum( "Patch_Mutagen_Ing_Stacking" ) < 1 )
	{
		Patch_MutagenStacking();		
		FactsAdd( "Patch_Mutagen_Ing_Stacking" );
	}

	if(FactsQuerySum("new_game_started_with_GM_40") < 1 )
	{
		if( FactsQuerySum( "modSpectre_ArmorTypeSetsIntroduced" ) < 1 )
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			pam.ManageSetArmorTypeBonus();
			SpectreRecalcSetItemsEquipped();
			FactsAdd( "modSpectre_ArmorTypeSetsIntroduced" );
		}
		if( FactsQuerySum( "modSpectre_KMArmorTypeSetIntroduced" ) < 1 )
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			pam.ManageSetArmorTypeBonus();
			SpectreRecalcSetItemsEquipped();
			FactsAdd( "modSpectre_KMArmorTypeSetIntroduced" );
		}
	}
}

@wrapMethod(W3PlayerWitcher) function RestoreQuen( quenHealth : float, quenDuration : float, optional alternate : bool ) : bool
{
	var restoredQuen 	: W3QuenEntity;
	
	if(false) 
	{
		wrappedMethod(quenHealth, quenDuration, alternate);
	}
	
	if(quenHealth > 0.f && quenDuration >= 3.f)
	{
		restoredQuen = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
		restoredQuen.Init( signOwner, signs[ST_Quen].entity, true );
		
		if( alternate )
		{
			restoredQuen.SetAlternateCast( S_Magic_s04 );
		}
		
		restoredQuen.freeCast = true;
		restoredQuen.OnStarted();
		restoredQuen.OnThrowing();
		
		if( !alternate )
		{
			restoredQuen.OnEnded();
		}
		
		restoredQuen.SetDataFromRestore(quenHealth, quenDuration);
		
		return true;
	}
	
	return false;
}

@wrapMethod(W3PlayerWitcher) function NewGamePlusInitialize()
{
	var questItems : array<name>;
	var horseManager : W3HorseManager;
	var horseInventory : CInventoryComponent;
	var i, missingLevels, expDiff : int;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	super.NewGamePlusInitialize();
	
	
	horseManager = (W3HorseManager)EntityHandleGet(horseManagerHandle);
	if(horseManager)
		horseInventory = horseManager.GetInventoryComponent();
	
	
	theGame.params.SetNewGamePlusLevel(GetLevel());
	
	
	if (theGame.GetDLCManager().IsDLCAvailable('ep1'))
		missingLevels = theGame.params.NEW_GAME_PLUS_EP1_MIN_LEVEL - GetLevel();
	else
		missingLevels = theGame.params.NEW_GAME_PLUS_MIN_LEVEL - GetLevel();
		
	for(i=0; i<missingLevels; i+=1)
	{
		
		expDiff = levelManager.GetTotalExpForNextLevel() - levelManager.GetPointsTotal(EExperiencePoint);
		expDiff = CeilF( ((float)expDiff) / 2 );
		AddPoints(EExperiencePoint, expDiff, false);
	}
	
	inv.RemoveItemByTag('Quest', -1);
	horseInventory.RemoveItemByTag('Quest', -1);

	questItems = theGame.GetDefinitionsManager().GetItemsWithTag('Quest');
	for(i=0; i<questItems.Size(); i+=1)
	{
		inv.RemoveItemByName(questItems[i], -1);
		horseInventory.RemoveItemByName(questItems[i], -1);
	}
	
	inv.RemoveItemByName('mq1002_artifact_3', -1);
	horseInventory.RemoveItemByName('mq1002_artifact_3', -1);
	
	
	inv.RemoveItemByTag('NotTransferableToNGP', -1);
	horseInventory.RemoveItemByTag('NotTransferableToNGP', -1);
	
	
	inv.RemoveItemByTag('NoticeBoardNote', -1);
	horseInventory.RemoveItemByTag('NoticeBoardNote', -1);
	
	RemoveAllNonAutoBuffs();
	
	RemoveAlchemyRecipe('Recipe for Trial Potion Kit');
	RemoveAlchemyRecipe('Recipe for Pops Antidote');
	RemoveAlchemyRecipe('Recipe for Czart Lure');
	RemoveAlchemyRecipe('q603_diarrhea_potion_recipe');

	inv.RemoveItemByTag('Trophy', -1);
	horseInventory.RemoveItemByTag('Trophy', -1);
	
	
	inv.RemoveItemByCategory('usable', -1);
	horseInventory.RemoveItemByCategory('usable', -1);
	
	
	RemoveAbility('StaminaTutorialProlog');
	RemoveAbility('TutorialStaminaRegenHack');
	RemoveAbility('area_novigrad');
	RemoveAbility('NoRegenEffect');
	RemoveAbility('HeavySwimmingStaminaDrain');
	RemoveAbility('AirBoost');
	RemoveAbility('area_nml');
	RemoveAbility('area_skellige');
	
	inv.RemoveItemByTag('GwintCard', -1);
	horseInventory.RemoveItemByTag('GwintCard', -1);
			
	inv.RemoveItemByTag('ReadableItem', -1);
	horseInventory.RemoveItemByTag('ReadableItem', -1);

	abilityManager.RestoreStats();
	
	
	((W3PlayerAbilityManager)abilityManager).RemoveToxicityOffset(10000);
	
	
	GetInventory().SingletonItemsRefillAmmo();
	
	
	craftingSchematics.Clear();
	AddStartingSchematics();
	
	
	for( i=0; i<amountOfSetPiecesEquipped.Size(); i+=1 )
	{
		amountOfSetPiecesEquipped[i] = 0;
	}

	
	inv.AddAnItem('Clearing Potion', 1, true, false, false);
	
	
	inv.RemoveItemByName('q203_broken_eyeofloki', -1);
	horseInventory.RemoveItemByName('q203_broken_eyeofloki', -1);
	
	if( FactsQuerySum("modSpectreKMSetSchematicsAdded") < 1 )
	{
		AddCraftingSchematic('Kaer Morhen Armor 1 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Armor 2 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Armor 3 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Pants schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Pants 1 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Pants 2 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Pants 3 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Boots schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Boots 1 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Boots 2 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Boots 3 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Gloves schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Gloves 1 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Gloves 2 schematic',true, true);
		AddCraftingSchematic('Kaer Morhen Gloves 3 schematic',true, true);
		FactsAdd("modSpectreKMSetSchematicsAdded");
	}
	NewGamePlusReplaceViperSet(inv);
	NewGamePlusReplaceViperSet(horseInventory);
	NewGamePlusReplaceKaerMorhenSet(inv);
	NewGamePlusReplaceKaerMorhenSet(horseInventory);
	NewGamePlusReplaceLynxSet(inv);
	NewGamePlusReplaceLynxSet(horseInventory);
	NewGamePlusReplaceGryphonSet(inv);
	NewGamePlusReplaceGryphonSet(horseInventory);
	NewGamePlusReplaceBearSet(inv);
	NewGamePlusReplaceBearSet(horseInventory);
	NewGamePlusReplaceEP1(inv);
	NewGamePlusReplaceEP1(horseInventory);
	NewGamePlusReplaceEP2WitcherSets(inv);
	NewGamePlusReplaceEP2WitcherSets(horseInventory);
	NewGamePlusReplaceEP2Items(inv);
	NewGamePlusReplaceEP2Items(horseInventory);
	NewGamePlusMarkItemsToNotAdjust(inv);
	NewGamePlusMarkItemsToNotAdjust(horseInventory);
	
	NewGamePlusReplaceNetflixSet(inv);
	NewGamePlusReplaceNetflixSet(horseInventory);
	
	NewGamePlusReplaceDolBlathannaSet(inv);
	NewGamePlusReplaceDolBlathannaSet(horseInventory);
	
	NewGamePlusReplaceWhiteTigerSet(inv);
	NewGamePlusReplaceWhiteTigerSet(horseInventory);
	
	
	inputHandler.ClearLocksForNGP();
	
	
	buffImmunities.Clear();
	buffRemovedImmunities.Clear();
	
	newGamePlusInitialized = true;
	
	
	m_quenReappliedCount = 1;
	
	
	
	
	tiedWalk = false;
	proudWalk = false;
	injuredWalk = false;
	SetBehaviorVariable( 'alternateWalk', 0.0f );
	SetBehaviorVariable( 'proudWalk', 0.0f );
	if( GetHorseManager().GetHorseMode() == EHM_Unicorn )
		GetHorseManager().SetHorseMode( EHM_Normal );
	
}

@addMethod(W3PlayerWitcher) function NewGamePlusReplaceKaerMorhenSet(out inv : CInventoryComponent)
{
	NewGamePlusReplaceItem('Kaer Morhen Armor','NGP Kaer Morhen Armor', inv);
	NewGamePlusReplaceItem('Kaer Morhen Armor 1','NGP Kaer Morhen Armor 1', inv);
	NewGamePlusReplaceItem('Kaer Morhen Armor 2','NGP Kaer Morhen Armor 2', inv);
	NewGamePlusReplaceItem('Kaer Morhen Armor 3','NGP Kaer Morhen Armor 3', inv);
	NewGamePlusReplaceItem('Kaer Morhen Pants','NGP Kaer Morhen Pants', inv);
	NewGamePlusReplaceItem('Kaer Morhen Pants 1','NGP Kaer Morhen Pants 1', inv);
	NewGamePlusReplaceItem('Kaer Morhen Pants 2','NGP Kaer Morhen Pants 2', inv);
	NewGamePlusReplaceItem('Kaer Morhen Pants 3','NGP Kaer Morhen Pants 3', inv);
	NewGamePlusReplaceItem('Kaer Morhen Boots','NGP Kaer Morhen Boots', inv);
	NewGamePlusReplaceItem('Kaer Morhen Boots 1','NGP Kaer Morhen Boots 1', inv);
	NewGamePlusReplaceItem('Kaer Morhen Boots 2','NGP Kaer Morhen Boots 2', inv);
	NewGamePlusReplaceItem('Kaer Morhen Boots 3','NGP Kaer Morhen Boots 3', inv);
	NewGamePlusReplaceItem('Kaer Morhen Gloves','NGP Kaer Morhen Gloves', inv);
	NewGamePlusReplaceItem('Kaer Morhen Gloves 1','NGP Kaer Morhen Gloves 1', inv);
	NewGamePlusReplaceItem('Kaer Morhen Gloves 2','NGP Kaer Morhen Gloves 2', inv);
	NewGamePlusReplaceItem('Kaer Morhen Gloves 3','NGP Kaer Morhen Gloves 3', inv);
}

@wrapMethod(W3PlayerWitcher) function RepairItem (  rapairKitId : SItemUniqueId, usedOnItem : SItemUniqueId )
{
	var itemMaxDurablity 		: float;
	var itemCurrDurablity 		: float;
	var baseRepairValue		  	: float;
	var reapirValue				: float;
	var itemAttribute			: SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(rapairKitId, usedOnItem);
	}
	
	itemMaxDurablity = inv.GetItemMaxDurability(usedOnItem);
	itemCurrDurablity = inv.GetItemDurability(usedOnItem);
	itemAttribute = inv.GetItemAttributeValue ( rapairKitId, 'repairValue' );
	
	if ( inv.IsItemAnyArmor ( usedOnItem )|| inv.IsItemWeapon( usedOnItem ) )
	{			
		if( inv.ItemHasTag( rapairKitId, 'ArmorReapairKit_Master' ) || inv.ItemHasTag( rapairKitId, 'WeaponReapairKit_Master' ) )
		{
			inv.AddItemLevelAbility( usedOnItem );
		}
		
		baseRepairValue = itemMaxDurablity * itemAttribute.valueMultiplicative;					
		reapirValue = MinF( itemCurrDurablity + baseRepairValue, itemMaxDurablity );
		
		inv.SetItemDurabilityScript ( usedOnItem, MinF ( reapirValue, itemMaxDurablity ));
	}
	
	inv.RemoveItem ( rapairKitId, 1 );
}

@replaceMethod(W3PlayerWitcher) function IsItemRepairAble ( item : SItemUniqueId ) : bool
{
	return inv.HasItemDurability(item);
}

@addMethod(W3PlayerWitcher) function DodgeDamage(out damageData : W3DamageAction)
{
	var actorAttacker : CActor;
	var attackRange : CAIAttackRange;
	var safeAngleDist, angleDist, distToAttacker, damageReduction : float;
	var attackName : name;
	var isDodging, isIceGiantSpecial : bool;
	
	super.DodgeDamage(damageData);
	
	actorAttacker = (CActor)damageData.attacker;

	isDodging = IsCurrentlyDodging() || IsInCombatAction() && ((int)GetBehaviorVariable( 'combatActionType' ) == CAT_Dodge || (int)GetBehaviorVariable( 'combatActionType' ) == CAT_Roll);

	if( FactsQuerySum( "modSpectre_debug_reduce_damage" ) > 0 )
	{
		theGame.witcherLog.AddMessage("Is in combat action: " + (int)IsInCombatAction());
		theGame.witcherLog.AddMessage("Player action: " + GetBehaviorVariable( 'combatActionType' ));
		theGame.witcherLog.AddMessage("Player is dodging: " + isDodging);
	}
	
	if(actorAttacker && isDodging && !(damageData.IsActionEnvironment() || damageData.IsDoTDamage()))
	{
		attackName = actorAttacker.GetLastAttackRangeName();
		angleDist = AbsF(AngleDistance(evadeHeading, actorAttacker.GetHeading()));
		attackRange = theGame.GetAttackRangeForEntity(actorAttacker, attackName);
		distToAttacker = VecDistance(this.GetWorldPosition(), damageData.attacker.GetWorldPosition());
		isIceGiantSpecial = ( attackName == 'stomp' || attackName == 'anchor_special_far' || attackName == 'anchor_far' );

		if( CanUseSkill(S_Sword_s09) )
			damageReduction = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s09, 's9_damage_reduction', false, true)) * GetSkillLevel(S_Sword_s09);
		else if( CanUseSkill(S_Sword_s36) )
			damageReduction = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s36, 'damage_reduction', false, true)) * GetSkillLevel(S_Sword_s36);
		else
			damageReduction = 0;

		// 5.01 tree: Fleet Footed at its maximum rank avoids all the damage while dodging, as in 5.01.
		if( spectreVanillaSkills() && CanUseSkill(S_Sword_s36) && GetSkillLevel(S_Sword_s36) >= GetSkillMaxLevel(S_Sword_s36) )
			damageReduction = 1;

		if( damageData.CanBeDodged() )
		{
			safeAngleDist = 120;
			if( HasAbility('ArmorTypeLightSetBonusAbility') )
				safeAngleDist += CalculateAttributeValue(GetAbilityAttributeValue('ArmorTypeLightSetBonusAbility', 'dodge_safe_ange_dist_deg'));
			safeAngleDist = ClampF( safeAngleDist, 0, 180 );

			if( angleDist <= safeAngleDist && !isIceGiantSpecial || isIceGiantSpecial && distToAttacker > attackRange.rangeMax * 0.75 )
			{
				if( theGame.CanLog() )
				{
					LogDMHits("W3PlayerWitcher.DodgeDamage: Attack dodged by player - no damage done", damageData);
				}
				damageData.SetWasDodged();
			}
		}

		if( !damageData.WasDodged() && damageReduction > 0 )
		{
			if( theGame.CanLog() )
			{
				LogDMHits("W3PlayerWitcher.DodgeDamage: reduced damage while dodging an attack", damageData );
			}
			damageData.SetGrazeDamageReduction(damageReduction);
		}

		if( FactsQuerySum( "modSpectre_debug_reduce_damage" ) > 0 )
		{
			theGame.witcherLog.AddMessage("Fleet Footed damage reduction: " + damageReduction);
			theGame.witcherLog.AddMessage("Attack name: " + attackName);
			theGame.witcherLog.AddMessage("Attack can be dodged: " + damageData.CanBeDodged());
			theGame.witcherLog.AddMessage("Safe angle distance: " + safeAngleDist);
			theGame.witcherLog.AddMessage("Attacker and evade angle distance: " + angleDist);
			theGame.witcherLog.AddMessage("Attack range: " + attackRange.rangeMax);
			theGame.witcherLog.AddMessage("Distance to attacker: " + distToAttacker);
			theGame.witcherLog.AddMessage("Damage was dodged completely: " + damageData.WasDodged());
		}
	}
}

@wrapMethod(W3PlayerWitcher) function ReduceDamage(out damageData : W3DamageAction)
{
	var quen : W3QuenEntity;
	var min, max : SAbilityAttributeValue;
	var chance : float;
	var whirlDmgReduction : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(damageData);
	}
	
	super.ReduceDamage(damageData);

	if(HasBuff(EET_Mutagen27) && !(damageData.IsActionEnvironment() || damageData.IsDoTDamage()))
	{
		((W3Mutagen27_Effect)GetBuff(EET_Mutagen27)).ReduceDamage(damageData);
	}

	if(!damageData.DealsAnyDamage())
		return;

	if(damageData.IsGrazeDamage())
	{
		damageData.processedDmg.vitalityDamage *= ClampF( 1 - damageData.GetGrazeDamageReduction(), 0.05, 1 );

		if( FactsQuerySum( "modSpectre_debug_reduce_damage" ) > 0 )
		{
			theGame.witcherLog.AddMessage("Is graze damage: " + damageData.IsGrazeDamage());
			theGame.witcherLog.AddMessage("Graze damage reduction: " + damageData.GetGrazeDamageReduction());
		}
	}
	
	quen = (W3QuenEntity)signs[ST_Quen].entity;

	if( !spectreVanillaAlchemySkills() && !damageData.IsDoTDamage() && CanUseSkill(S_Alchemy_s05) )
	{
		damageData.processedDmg.vitalityDamage *= ClampF(1 - GetOilProtectionAgainstMonster(damageData), 0.f, 1.f);

		if( FactsQuerySum( "modSpectre_debug_reduce_damage" ) > 0 )
		{
			theGame.witcherLog.AddMessage("Oil protection against monster: " + GetOilProtectionAgainstMonster(damageData));
		}
	}
	
	// Spectre's Whirl lowers the damage taken while spinning. 5.01's Whirl does not.
	if( !spectreVanillaSkills() && !damageData.IsDoTDamage() && GetStat(BCS_Focus) > 0 && IsDoingSpecialAttack(false) )
	{
		whirlDmgReduction = GetSkillAttributeValue(S_Sword_s01, 'whirl_dmg_reduction', false, true)
			+ GetSkillAttributeValue(S_Sword_s01, 'whirl_dmg_reduction_bonus_after_1', false, true) * (GetSkillLevel(S_Sword_s01) - 1);
		damageData.processedDmg.vitalityDamage *= ClampF(1 - whirlDmgReduction.valueMultiplicative, 0.f, 1.f);
	}

	if((!quen || !quen.IsAnyQuenActive()) && damageData.IsActionRanged() && !damageData.IsActionWitcherSign() && !damageData.IsDoTDamage() && !damageData.WasDodged())
	{
		chance = CalculateAttributeValue(GetAttributeValue('quen_chance_on_projectile'));
		if(chance > 0)
		{
			chance = ClampF(chance, 0, 1);
			
			if(RandF() < chance)
			{
				if(!quen)
				{
					quen = (W3QuenEntity)theGame.CreateEntity(signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
				}
				quen.Init(signOwner, signs[ST_Quen].entity, true );
				quen.freeCast = true;
				quen.OnStarted();
				quen.OnThrowing();
				quen.OnEnded();
				if ( theGame.CanLog() )
				{		
					LogDMHits("W3PlayerWitcher.ReduceDamage: Processing Quen On Projectile armor ability...", damageData);
				}

				quen.ShowHitFX();
				damageData.SetAllProcessedDamageAs(0);
				damageData.SetEndsQuen(true);
			}
		}
	}
}

@addMethod(W3PlayerWitcher) function GetOilProtectionAgainstMonster(damageData : W3DamageAction) : float
{
	var i : int;
	var heldWeapons : array< SItemUniqueId >;
	var weapon : SItemUniqueId;
	var resist : float;
	var attackerMonsterCategory : EMonsterCategory;
	var tmpName : name;
	var tmpBool	: bool;
	
	if( !((CActor)damageData.attacker) )
		return 0;
	
	resist = 0;
	heldWeapons = inv.GetHeldWeapons();
	
	for( i = 0; i < heldWeapons.Size(); i += 1 )
	{
		if( !inv.IsItemFists( heldWeapons[ i ] ) )
		{
			weapon = heldWeapons[ i ];
			break;
		}
	}
	
	if( !inv.IsIdValid( weapon ) )
		return 0;
	
	theGame.GetMonsterParamsForActor((CActor)damageData.attacker, attackerMonsterCategory, tmpName, tmpBool, tmpBool, tmpBool);

	resist = inv.GetOilProtectionAgainstMonster(weapon, attackerMonsterCategory);
	
	return resist;
}

@wrapMethod(W3PlayerWitcher) function UndyingSkillCooldown(dt : float, id : int)
{
	if(false) 
	{
		wrappedMethod(dt, id);
	}

	thePlayer.RemoveBuff( EET_Undying, false, "UndyingEffect" );
}

@addMethod(W3PlayerWitcher) function CastFreeQuen()
{
	var quen : W3QuenEntity;
	
	quen = (W3QuenEntity)signs[ST_Quen].entity;

	if(!quen)
		quen = (W3QuenEntity)theGame.CreateEntity(signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation());
	
	PlayEffect( 'acs_quen_lasting_shield_back' );
	
	quen.Init(signOwner, signs[ST_Quen].entity, true);
	quen.freeCast = true;
	quen.OnStarted();
	quen.OnThrowing();
	quen.OnEnded();
}

@wrapMethod(W3PlayerWitcher) function OnTakeDamage( action : W3DamageAction)
{
	var currVitality, rgnVitality, hpTriggerTreshold : float;
	var abilityName : name;
	var abilityCount, maxStack, itemDurability : float;
	var addAbility : bool;
	var min, max : SAbilityAttributeValue;
	var equipped : array<SItemUniqueId>;
	var i : int;
	var killSourceName : string;
	var aerondight	: W3Effect_Aerondight;
	var phantomWeapon	: W3Effect_PhantomWeapon;
	var mutation5CustomEffect : SCustomEffectParams;
	var healingFactor, healingBase : float;

	if(false)
	{
		wrappedMethod(action);
	}

	currVitality = GetStat(BCS_Vitality);
	killSourceName = action.GetBuffSourceName();
	
	
	if(action.processedDmg.vitalityDamage >= currVitality)
	{

		if( killSourceName != "Quest" && killSourceName != "Kill Trigger" && killSourceName != "Trap" && killSourceName != "FallingDamage" )
		{			
			if( spectreVanillaSkills() && !cannotUseUndyingSkill && FloorF(GetStat(BCS_Focus)) >= 1 && CanUseSkill(S_Sword_s18) && HasBuff(EET_BattleTrance) )
			{
				// 5.01 tree: Undying as in 5.01.
				healingFactor = CalculateAttributeValue( GetSkillAttributeValue(S_Sword_s18, 'healing_factor', false, true) );
				healingFactor *= GetStat(BCS_Focus);
				healingBase = CalculateAttributeValue( GetSkillAttributeValue(S_Sword_s18, 'healing_bonus', false, true) ) * (GetSkillLevel(S_Sword_s18) - 1);
				healingBase = ( healingBase + healingFactor ) * GetStatMax(BCS_Vitality);
				ForceSetStat(BCS_Vitality, healingBase);
				action.processedDmg.vitalityDamage = 0;
				DrainFocus(GetStat(BCS_Focus));
				RemoveBuff(EET_BattleTrance);
				cannotUseUndyingSkill = true;
				thePlayer.AddEffectDefault( EET_Undying, NULL, "UndyingEffect" );
				AddTimer('UndyingSkillCooldown', CalculateAttributeValue( GetSkillAttributeValue(S_Sword_s18, 'trigger_delay', false, true) ), false, , , true);
			}
			else if( !spectreVanillaSkills() && !HasBuff( EET_UndyingSkillImmortal ) && !HasBuff( EET_UndyingSkillCooldown ) && GetStat(BCS_Focus) >= 1 && CanUseSkill(S_Sword_s18) )
			{
				action.SetAllProcessedDamageAs( 0 );
				ForceSetStat(BCS_Vitality, 1);
				AddEffectDefault( EET_UndyingSkillImmortal, NULL, "UndyingSkill" );
			}
			else
			{
				
				equipped = GetEquippedItems();
				
				for(i=0; i<equipped.Size(); i+=1)
				{
					if ( !inv.IsIdValid( equipped[i] ) )
					{
						continue;
					}
					itemDurability = inv.GetItemDurability(equipped[i]);
					if(inv.ItemHasAbility(equipped[i], 'MA_Reinforced') && itemDurability > 0)
					{
						
						inv.SetItemDurabilityScript(equipped[i], MaxF(0, itemDurability - action.processedDmg.vitalityDamage) );
						
						
						action.processedDmg.vitalityDamage = 0;
						ForceSetStat(BCS_Vitality, 1);
						
						break;
					}
				}
			}
		}
	}

	if(IsMutationActive(EPMT_Mutation5) && !action.IsDoTDamage() && action.processedDmg.vitalityDamage > 0.0 && GetStat(BCS_Focus) >= 1.0)
	{
		if(action.processedDmg.vitalityDamage < currVitality || killSourceName != "Quest" && killSourceName != "Kill Trigger" && killSourceName != "Trap" && killSourceName != "FallingDamage")
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation5', 'mut5_duration_per_point', min, max);
			mutation5CustomEffect.effectType = EET_Mutation5;
			mutation5CustomEffect.creator = this;
			mutation5CustomEffect.sourceName = "mutation5";
			mutation5CustomEffect.duration = min.valueAdditive * GetStat(BCS_Focus);
			mutation5CustomEffect.effectValue.valueAdditive = action.processedDmg.vitalityDamage / mutation5CustomEffect.duration;
			AddEffectCustom(mutation5CustomEffect);
			action.SetMutation5Triggered();
		}
	}
	
	if(HasBuff(EET_Trap) && !action.IsDoTDamage() && action.attacker.HasAbility( 'mon_dettlaff_monster_base' ))
	{
		action.AddEffectInfo(EET_Knockdown);
		RemoveBuff(EET_Trap, true);
	}		
	
	super.OnTakeDamage(action);

	if( !action.WasDodged() && action.DealtDamage() && !action.IsDoTDamage() && !( (W3Effect_Toxicity) action.causer ) )
	{
		if( inv.ItemHasTag( inv.GetCurrentlyHeldSword(), 'Aerondight' ) )
		{
			aerondight = (W3Effect_Aerondight)GetBuff( EET_Aerondight );
			if( aerondight )
			{
				aerondight.ResetCharges();
			}
		}
		if( inv.ItemHasTag( inv.GetCurrentlyHeldSword(), 'PhantomWeapon' ) )
		{
			phantomWeapon = (W3Effect_PhantomWeapon)GetBuff( EET_PhantomWeapon );
			if( phantomWeapon )
				phantomWeapon.ResetCharges();
		}
	}

	if(HasBuff(EET_Mutation3))
		((W3Effect_Mutation3)GetBuff(EET_Mutation3)).ManageMutation3Bonus(action);
	if(HasBuff(EET_Mutagen02) && !action.WasDodged() && action.DealtDamage() && action.IsActionMelee())
		((W3Mutagen02_Effect)GetBuff(EET_Mutagen02)).AddDebuffToEnemy((CActor)action.attacker);
	if(HasBuff(EET_Mutagen05))
		((W3Mutagen05_Effect)GetBuff(EET_Mutagen05)).ManageMutagen05Bonus(action);
	if(HasBuff(EET_Mutagen15))
		((W3Mutagen15_Effect)GetBuff(EET_Mutagen15)).ManageMutagen15Bonus(action);
	if(HasBuff(EET_Mutagen22))
		((W3Mutagen22_Effect)GetBuff(EET_Mutagen22)).RemoveMutagen22Abilities(action);
	if(HasBuff(EET_Mutagen27) && !action.WasDodged() && action.DealtDamage() && !(action.IsActionEnvironment() || action.IsDoTDamage()))
		((W3Mutagen27_Effect)GetBuff(EET_Mutagen27)).AccumulateHits();
}

@wrapMethod(W3PlayerWitcher) function GetCriticalHitDamageBonus(weaponId : SItemUniqueId, victimMonsterCategory : EMonsterCategory, isStrikeAtBack : bool) : SAbilityAttributeValue
{
	var min, max, bonus, null, oilBonus : SAbilityAttributeValue;
	var mutagen : CBaseGameplayEffect;
	var monsterBonusType : name;
	
	if(false) 
	{
		wrappedMethod(weaponId, victimMonsterCategory, isStrikeAtBack);
	}
	
	bonus = super.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, isStrikeAtBack);
	
	if( inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) && GetStat( BCS_Focus ) >= 1 && CanUseSkill( S_Alchemy_s07 ) )
	{
		monsterBonusType = MonsterCategoryToAttackPowerBonus( victimMonsterCategory );
		oilBonus = inv.GetItemAttributeValue( weaponId, monsterBonusType );
		if(oilBonus != null)	
		{
			bonus += GetSkillAttributeValue(S_Alchemy_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, false) * GetSkillLevel(S_Alchemy_s07) * MinF(3, FloorF(GetStat(BCS_Focus)));
		}
	}
	
	if (isStrikeAtBack && HasBuff(EET_Mutagen11))
	{
		mutagen = GetBuff(EET_Mutagen11);
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(mutagen.GetAbilityName(), 'damageIncrease', min, max);
		bonus += GetAttributeRandomizedValue(min, max);
	}

	AccumulateHeightenedToleranceCritBonus(bonus);
		
	return bonus;		
}

@wrapMethod(W3PlayerWitcher) function OnProcessActionPost(action : W3DamageAction)
{
	var attackAction : W3Action_Attack;
	var rendLoad, focusVal, stamCost, rendTimeRatio : float; 
	var value : SAbilityAttributeValue;
	var actorVictim : CActor;
	var weaponId : SItemUniqueId;
	var usesSteel, usesSilver, usesVitality, usesEssence : bool;
	var abs : array<name>;
	var i : int;
	var dm : CDefinitionsManagerAccessor;
	var items : array<SItemUniqueId>;
	var weaponEnt : CEntity;
	var lynxSetBuff : W3Effect_LynxSetBonus;
	var min, max, nullBonus, oilBonus : SAbilityAttributeValue; 
	var victimMonsterCategory : EMonsterCategory; 
	var monsterBonusType : name; 
	var tmpName : name; 
	var tmpBool	: bool; 
	var splitCount : int;
	var crippleDuration : float; 
	
	if(false) 
	{
		wrappedMethod(action);
	}
	
	super.OnProcessActionPost(action);
	
	attackAction = (W3Action_Attack)action;
	actorVictim = (CActor)action.victim;
	
	if(attackAction)
	{
		if(attackAction.IsActionMelee())
		{
			
			if(SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
			{
				RendAoE(attackAction);
				
				rendTimeRatio = GetSpecialAttackTimeRatio();
				
				rendLoad = GetStat(BCS_Focus);

				DrainFocus(rendLoad);
				
				OnSpecialAttackHeavyActionProcess();
			}
			else if(actorVictim && IsRequiredAttitudeBetween(this, actorVictim, true)
					&& attackAction.DealsAnyDamage() && !attackAction.WasDodged() && !attackAction.IsParried() && !attackAction.IsCountered()) 
			{
				
				
				value = GetAttributeValue('focus_gain');
				
				if( FactsQuerySum("debug_fact_focus_boy") > 0 )
				{
					Debug_FocusBoyFocusGain();
				}
				
				
				if ( CanUseSkill(S_Sword_s20) )
				{
					value += GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * GetSkillLevel(S_Sword_s20);
				}

				if( CanUseSkill(S_Sword_s21) && attackAction && attackAction.IsActionMelee() && 
					IsLightAttack(attackAction.GetAttackName()) && !inv.IsItemFists(attackAction.GetWeaponId()) )
				{
					value += GetSkillAttributeValue(S_Sword_s21, 'light_focus_gain', false, true) * GetSkillLevel(S_Sword_s21);
				}
				if( CanUseSkill(S_Sword_s04) && attackAction && attackAction.IsActionMelee() && 
					IsHeavyAttack(attackAction.GetAttackName()) && !inv.IsItemFists(attackAction.GetWeaponId()) )
				{
					value += GetSkillAttributeValue(S_Sword_s04, 'heavy_focus_gain', false, true) * GetSkillLevel(S_Sword_s04);
				}

				focusVal = 0.1f * (1 + CalculateAttributeValue(value));
				
				if(!inv.IsItemFists(attackAction.GetWeaponId()))
				{
					if( attackAction.IsCriticalHit() && IsSetBonusActive( EISB_Lynx_2 ) )
					{
						focusVal *= 2;
					}
					
					focusVal += CalculateAttributeValue(GetAttributeValue('bonus_focus_gain'));
				}
				
				if(HasBuff(EET_Mutation7Buff))
					focusVal *= 2;
				else if(HasBuff(EET_Mutation7Debuff))
					focusVal /= 2;
				
				GainStat(BCS_Focus, focusVal);
			}

			if(IsSetBonusActive(EISB_Bear_2) && attackAction.DealsAnyDamage() && !attackAction.WasDodged() && !attackAction.IsParried() && !attackAction.IsCountered())
			{
				if(SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
					stamCost = rendTimeRatio * GetStatMax(BCS_Stamina);
				else if(IsHeavyAttack(attackAction.GetAttackName()))
					stamCost = GetStaminaActionCost(ESAT_HeavyAttack);
				if(stamCost > 0)
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetSetBonusAbility(EISB_Bear_2), 'stamina_attack', min, max);
					GainStat(BCS_Stamina, stamCost * min.valueAdditive);
				}
			}
			
			weaponId = attackAction.GetWeaponId();
			if(actorVictim && (ShouldProcessTutorial('TutorialWrongSwordSteel') || ShouldProcessTutorial('TutorialWrongSwordSilver')) && GetAttitudeBetween(actorVictim, this) == AIA_Hostile)
			{
				usesSteel = inv.IsItemSteelSwordUsableByPlayer(weaponId);
				usesSilver = inv.IsItemSilverSwordUsableByPlayer(weaponId);
				usesVitality = actorVictim.UsesVitality();
				usesEssence = actorVictim.UsesEssence();
				
				if(usesSilver && usesVitality)
				{
					FactsAdd('tut_wrong_sword_silver',1);
				}
				else if(usesSteel && usesEssence)
				{
					FactsAdd('tut_wrong_sword_steel',1);
				}
				else if(FactsQuerySum('tut_wrong_sword_steel') && usesSilver && usesEssence)
				{
					FactsAdd('tut_proper_sword_silver',1);
					FactsRemove('tut_wrong_sword_steel');
				}
				else if(FactsQuerySum('tut_wrong_sword_silver') && usesSteel && usesVitality)
				{
					FactsAdd('tut_proper_sword_steel',1);
					FactsRemove('tut_wrong_sword_silver');
				}
			}
			
			
			if(!action.WasDodged() && HasRunewordActive('Runeword 1 _Stats'))
			{
				if(runewordInfusionType == ST_Axii)
				{
					actorVictim.SoundEvent('sign_axii_release');
				}
				else if(runewordInfusionType == ST_Igni)
				{
					actorVictim.SoundEvent('sign_igni_charge_begin');
				}
				else if(runewordInfusionType == ST_Quen)
				{
					value = GetAttributeValue('runeword1_quen_heal');
					Heal( action.GetDamageDealt() * value.valueMultiplicative );
					PlayEffectSingle('drain_energy_caretaker_shovel');
				}
				else if(runewordInfusionType == ST_Yrden)
				{
					actorVictim.SoundEvent('sign_yrden_shock_activate');
				}
				runewordInfusionType = ST_None;
				
				
				items = inv.GetHeldWeapons();
				weaponEnt = inv.GetItemEntityUnsafe(items[0]);
				weaponEnt.StopEffect('runeword_aard');
				weaponEnt.StopEffect('runeword_axii');
				weaponEnt.StopEffect('runeword_igni');
				weaponEnt.StopEffect('runeword_quen');
				weaponEnt.StopEffect('runeword_yrden');
			}

			if(HasBuff(EET_Runeword4) && (action.IsActionMelee() || action.IsActionWitcherSign() && IsMutationActive(EPMT_Mutation1)) && action.DealsAnyDamage() && !action.IsDoTDamage())
			{
				RemoveBuff(EET_Runeword4);
				actorVictim.CreateFXEntityAtPelvis( 'runeword_4', true );
			}
			
			if(ShouldProcessTutorial('TutorialLightAttacks') || ShouldProcessTutorial('TutorialHeavyAttacks'))
			{
				if(IsLightAttack(attackAction.GetAttackName()))
				{
					theGame.GetTutorialSystem().IncreaseGeraltsLightAttacksCount(action.victim.GetTags());
				}
				else if(IsHeavyAttack(attackAction.GetAttackName()))
				{
					theGame.GetTutorialSystem().IncreaseGeraltsHeavyAttacksCount(action.victim.GetTags());
				}
			}
		}
		else if(attackAction.IsActionRanged())
		{
			
			if(CanUseSkill(S_Perk_02) && !attackAction.IsDoTDamage() && attackAction.DealsAnyDamage() && !attackAction.WasDodged() && !attackAction.IsParried() && !attackAction.IsCountered())
			{				
				value = GetAttributeValue('focus_gain');
				
				if( FactsQuerySum("debug_fact_focus_boy") > 0 )
				{
					Debug_FocusBoyFocusGain();
				}
				
				if ( CanUseSkill(S_Sword_s20) )
				{
					value += GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * GetSkillLevel(S_Sword_s20);
				}
				
				focusVal = 0.1f * (1 + CalculateAttributeValue(value));

				if(HasBuff(EET_Mutation7Buff))
					focusVal *= 2;
				else if(HasBuff(EET_Mutation7Debuff))
					focusVal /= 2;

				splitCount = (int)CalculateAttributeValue(inv.GetItemAttributeValue(attackAction.GetWeaponId(), 'split_count'));
				if(splitCount > 0)
					focusVal /= splitCount;
				
				GainStat(BCS_Focus, focusVal);
			}
			
			
			if(CanUseSkill(S_Sword_s12) && attackAction.IsCriticalHit() && actorVictim)
			{
				
				actorVictim.GetCharacterStats().GetAbilities(abs, false);
				dm = theGame.GetDefinitionsManager();
				for(i=abs.Size()-1; i>=0; i-=1)
				{
					if(!dm.AbilityHasTag(abs[i], theGame.params.TAG_MONSTER_SKILL) || actorVictim.IsAbilityBlocked(abs[i]))
					{
						abs.EraseFast(i);
					}
				}
				
				
				if(abs.Size() > 0)
				{
					value = GetSkillAttributeValue(S_Sword_s12, 'duration', true, true) * GetSkillLevel(S_Sword_s12);
					actorVictim.BlockAbility(abs[ RandRange(abs.Size()) ], true, CalculateAttributeValue(value));
				}
			}

			// 5.01 tree: Cold Blood and Crippling Shot as in 5.01.
			if(spectreVanillaSkills())
			{
				if(CanUseSkill(S_Sword_s34))
				{
					switch( GetSkillLevel(S_Sword_s34) )
					{
						case 3:
							tmpName = 'focus_gain_lvl3';
							break;
						case 2:
							tmpName = 'focus_gain_lvl2';
							break;
						default:
							tmpName = 'focus_gain_lvl1';
					}
					value = GetSkillAttributeValue(S_Sword_s34, tmpName, false, true);
					GainStat(BCS_Focus, CalculateAttributeValue(value) );
				}

				if(CanUseSkill(S_Sword_s27) && IsCripplingShotEnabled() && actorVictim)
				{
					actorVictim.GetCharacterStats().GetAbilities(abs, false);
					dm = theGame.GetDefinitionsManager();
					value = GetSkillAttributeValue(S_Sword_s27, 'duration', true, true) * GetSkillLevel(S_Sword_s27);
					crippleDuration = CalculateAttributeValue(value);
					i = 0;
					while(i<abs.Size())
					{
						if(dm.AbilityHasTag(abs[i], theGame.params.TAG_MONSTER_SKILL) && !actorVictim.IsAbilityBlocked(abs[i]))
							i+=1;
						else
							abs.EraseFast(i);
					}
					if(abs.Size() > 0)
						actorVictim.BlockAbility(abs[ RandRange(0, abs.Size()) ], true, crippleDuration);
					ResetCripplingShot();
				}
			}
		}
	}
	
	// 5.01 tree: a critical hit readies Crippling Shot, as in 5.01.
	if(spectreVanillaSkills() && CanUseSkill(S_Sword_s27) && attackAction && attackAction.IsCriticalHit())
	{
		EnableCripplingShot();
	}

	if( IsMutationActive( EPMT_Mutation10 ) && HasBuff( EET_Mutation10 ) && ( action.IsActionMelee() ) )
	{
		PlayEffect( 'mutation_10_energy' );
	}
	
	
	if(CanUseSkill(S_Perk_18) && ((W3Petard)action.causer) && action.DealsAnyDamage() && !action.IsDoTDamage())
	{
		value = GetSkillAttributeValue(S_Perk_18, 'focus_gain', false, true);

		focusVal = CalculateAttributeValue(value);
		if(HasBuff(EET_Mutation7Buff))
			focusVal *= 2;
		else if(HasBuff(EET_Mutation7Debuff))
			focusVal /= 2;

		if(!spectreVanillaAlchemySkills() && CanUseSkill(S_Alchemy_s11))
		{
			splitCount = GetSkillLevel(S_Alchemy_s11) + 1;
			if(splitCount > 0)
				focusVal /= splitCount;
		}
		
		GainStat(BCS_Focus, focusVal);
	}

	if(HasBuff(EET_Mutagen01) && attackAction)
	{
		((W3Mutagen01_Effect)GetBuff(EET_Mutagen01)).ManageMutagen01Bonus(attackAction);
	}

	if(HasBuff(EET_Mutagen05))
	{
		((W3Mutagen05_Effect)GetBuff(EET_Mutagen05)).ManageMutagen05Bonus(action);
	}

	if(HasBuff(EET_Mutagen10) && attackAction)
	{
		((W3Mutagen10_Effect)GetBuff(EET_Mutagen10)).ManageMutagen10Bonus(attackAction);
	}

	if(HasBuff(EET_Mutagen15))
	{
		((W3Mutagen15_Effect)GetBuff(EET_Mutagen15)).ManageMutagen15Bonus(action);
	}

	if(HasBuff(EET_Mutagen17) && attackAction)
	{
		((W3Mutagen17_Effect)GetBuff(EET_Mutagen17)).ManageMutagen17Bonus(attackAction);
	}

	if( IsSetBonusActive( EISB_Lynx_1 ) && attackAction && attackAction.IsActionMelee() && !attackAction.WasDodged() )
	{
		if( !HasBuff( EET_LynxSetBonus ) )
		{
			AddEffectDefault( EET_LynxSetBonus, NULL, "LynxSetBuff" );
			SoundEvent( "ep2_setskill_lynx_activate" );
		}
		lynxSetBuff = (W3Effect_LynxSetBonus)GetBuff( EET_LynxSetBonus );
		lynxSetBuff.ManageLynxBonus( IsHeavyAttack( attackAction.GetAttackName() ) );
	}

	if(CanUseSkill(S_Sword_s30) && attackAction)
		EnableDeadlyPrecision(CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s30, 'duration', false, true)));
}

@addMethod(W3PlayerWitcher) function RendAoE(attackAction : W3Action_Attack)
{
	var dmgTypes			: array< name >;
	var dmgValues			: array< float >;
	var ents				: array<CGameplayEntity>;
	var rendAoEAction		: W3DamageAction;
	var i, j				: int;
	
	if(GetStat(BCS_Focus) < 3)
		return;
	
	inv.GetWeaponDTNames(attackAction.GetWeaponId(), dmgTypes);
	for(i = 0; i < dmgTypes.Size(); i += 1)
		dmgValues.PushBack(GetTotalWeaponDamage(attackAction.GetWeaponId(), dmgTypes[i], GetInvalidUniqueId()));
	
	FindGameplayEntitiesInCylinder(ents, attackAction.victim.GetWorldPosition(), 3, 10, 100, , FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile, this);
	
	for(i = 0; i < ents.Size(); i += 1)
	{
		if(ents[i] == attackAction.victim)
			continue;
		rendAoEAction = new W3DamageAction in theGame;
		rendAoEAction.Initialize(attackAction.attacker, ents[i], attackAction.causer, "RendAoE", EHRT_Heavy, CPS_AttackPower, false, false, false, false);
		rendAoEAction.SetCannotReturnDamage(true);
		rendAoEAction.SetProcessBuffsIfNoDamage(true);
		for(j = 0; j < dmgTypes.Size(); j += 1)
			rendAoEAction.AddDamage(dmgTypes[j], dmgValues[j]);
		rendAoEAction.AddEffectInfo(EET_KnockdownTypeApplicator);
		theGame.damageMgr.ProcessAction(rendAoEAction);
		ents[i].PlayEffect('yrden_shock');
		delete rendAoEAction;
	}
}

@wrapMethod(W3PlayerWitcher) function OnCombatStart()
{
	var quenEntity : W3QuenEntity;
	var focus, stamina, focusMax : float;
	var glowTargets, moTargets, actors : array< CActor >;
	var delays : array< float >;
	var rand, i : int;
	var isHostile, isAlive, isUnconscious : bool;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	super.OnCombatStart();
	
	if ( IsInCombatActionFriendly() )
	{
		SetBIsCombatActionAllowed(true);
		SetBIsInputAllowed(true, 'OnCombatActionStart' );
	}
	
	
	if(HasBuff(EET_Mutagen14))
	{
		AddTimer('Mutagen14Timer', 2, true);
	}

	if(HasBuff(EET_Mutagen24))
		((W3Mutagen24_Effect)GetBuff(EET_Mutagen24)).ManageMutagen24Bonus();

	if( IsSetBonusActive(EISB_KaerMorhen) && !HasBuff(EET_KaerMorhenSetBonus) )
	{
		AddEffectDefault(EET_KaerMorhenSetBonus, this, "KaerMorhenSetBonus");
	}
	
	ManageAerondightBuff( true );
	ManageIrisBuff( true );
	
	
	mutation12IsOnCooldown = false;
	
	
	quenEntity = (W3QuenEntity)signs[ST_Quen].entity;		
	
	
	if(quenEntity)
	{
		usedQuenInCombat = quenEntity.IsAnyQuenActive();
	}
	else
	{
		usedQuenInCombat = false;
	}
	
	if(usedQuenInCombat || HasPotionBuff() || IsEquippedSwordUpgradedWithOil(true) || IsEquippedSwordUpgradedWithOil(false))
	{
		SetFailedFundamentalsFirstAchievementCondition(true);
	}
	else
	{
		if(IsAnyItemEquippedOnSlot(EES_PotionMutagen1) || IsAnyItemEquippedOnSlot(EES_PotionMutagen2) || IsAnyItemEquippedOnSlot(EES_PotionMutagen3) || IsAnyItemEquippedOnSlot(EES_PotionMutagen4))
			SetFailedFundamentalsFirstAchievementCondition(true);
		else
			SetFailedFundamentalsFirstAchievementCondition(false);
	}
	
	if(CanUseSkill(S_Sword_s20) && IsThreatened())
	{
		focus = GetStat(BCS_Focus);

		// 5.01 tree: Razor Focus fills up to 1 Adrenaline Point, as in 5.01.
		if (spectreVanillaSkills())
			focusMax = 1;
		else
			focusMax = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s20, 'focus_add', false, true)) * GetSkillLevel(S_Sword_s20);
		if(focus < focusMax)
		{
			GainStat(BCS_Focus, focusMax - focus);
		}
	}

	if ( HasGlyphwordActive('Glyphword 17 _Stats') && (!quenEntity || !quenEntity.IsAnyQuenActive()) ) 
	{
		if(!quenEntity)
		{
			quenEntity = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
		}
		quenEntity.glyphword17Cast = true; 
		quenEntity.Init( signOwner, signs[ST_Quen].entity, true );
		quenEntity.freeCast = true; 
		quenEntity.OnStarted();
		quenEntity.OnThrowing();
		quenEntity.OnEnded();
	}
	
	MeditationForceAbort(true);
	
	if( IsMutationActive( EPMT_Mutation3 ) )
	{
		AddEffectDefault( EET_Mutation3, this, "", false );
	}

	if( IsMutationActive( EPMT_Mutation4 ) )
	{
		AddEffectDefault( EET_Mutation4, this, "combat start", false );
	}
	
	if( IsMutationActive( EPMT_Mutation7 ) )
	{
		AddEffectDefault( EET_Mutation7Buff, this, "Mutation 7 buff phase" );
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}

	if( IsMutationActive( EPMT_Mutation8 ) )
	{
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}
	
	if( IsMutationActive( EPMT_Mutation10 ) )
	{
		if( GetStat( BCS_Toxicity ) != 0 )
		{
			AddEffectDefault( EET_Mutation10, NULL, "Mutation 10" );
		}
	}
}

@wrapMethod(W3PlayerWitcher) function Mutation7CombatStartHackFix( dt : float, id : int )
{
	if(false) 
	{
		wrappedMethod(dt, id);
	}
}

@wrapMethod(W3PlayerWitcher) function Mutation7CombatStartHackFixGo( dt : float, id : int )
{
	if(false) 
	{
		wrappedMethod(dt, id);
	}
}

@wrapMethod(W3PlayerWitcher) function OnCombatFinished()
{
	var inGameConfigWrapper : CInGameConfigWrapper;
	var disableAutoSheathe : bool;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	super.OnCombatFinished();

	if(HasBuff(EET_Mutagen01))
		((W3Mutagen01_Effect)GetBuff(EET_Mutagen01)).RemoveMutagen01Abilities();
	if(HasBuff(EET_Mutagen05))
		((W3Mutagen05_Effect)GetBuff(EET_Mutagen05)).RemoveMutagen05AbilitiesAll();
	if(HasBuff(EET_Mutagen10))
		((W3Mutagen10_Effect)GetBuff(EET_Mutagen10)).RemoveMutagen10Abilities();
	if(HasBuff(EET_Mutagen12))
		((W3Mutagen12_Effect)GetBuff(EET_Mutagen12)).ManageAdditionalBonus();
	if(HasBuff(EET_Mutagen13))
		((W3Mutagen13_Effect)GetBuff(EET_Mutagen13)).ManageMutagen13Bonus();
	if(HasBuff(EET_Mutagen15))
		((W3Mutagen15_Effect)GetBuff(EET_Mutagen15)).RemoveMutagen15AbilitiesAll();
	if(HasBuff(EET_Mutagen17))
		((W3Mutagen17_Effect)GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
	if(HasBuff(EET_Mutagen18))
		((W3Mutagen18_Effect)GetBuff(EET_Mutagen18)).ManageMutagen18Bonus();
	if(HasBuff(EET_Mutagen22))
		((W3Mutagen22_Effect)GetBuff(EET_Mutagen22)).RemoveMutagen22AbilitiesAll();
	if(HasBuff(EET_Mutagen24))
		((W3Mutagen24_Effect)GetBuff(EET_Mutagen24)).ResetMutagen24Bonus();

	RemoveBuff( EET_Mutation3 );
	RemoveBuff( EET_Mutation4 );
	RemoveBuff( EET_Mutation7Buff );
	RemoveBuff( EET_Mutation7Debuff );

	if( IsMutationActive( EPMT_Mutation7 ) )
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
	}

	if( IsMutationActive( EPMT_Mutation8 ) )
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
	}

	RemoveBuff( EET_Mutation10 );

	RemoveBuff( EET_LynxSetBonus );
	RemoveBuff( EET_KaerMorhenSetBonus );
	
	if( HasBuff( EET_Aerondight ) )
		RemoveBuff( EET_Aerondight );
	
	if( HasBuff( EET_PhantomWeapon ) )
		RemoveBuff( EET_PhantomWeapon );
	
	RemoveAbilityAll('Runeword 10 Buff');
	RemoveBuff(EET_Runeword4);
	runewordInfusionType = ST_None;
	RemoveBuff(EET_Runeword11);
	
	RemoveAbilityAll('Glyphword 14 _Stats');
	RemoveAbilityAll('Glyphword 10 _Stats');

	RemoveBuff(EET_Resonance);
	StopEffect('resonance_sword');
	ResetSkillComboCounter(S_Sword_s22);
	ResetSkillComboCounter(S_Sword_s23);
	ResetSkillComboCounter(S_Sword_s24);
	ResetSkillComboCounter(S_Sword_s25);
	ResetCripplingShot();
	ResetDeadlyPrecision();

	if(GetStat(BCS_Focus) > 0)
	{
		AddTimer('DelayedAdrenalineDrain', theGame.params.ADRENALINE_DRAIN_AFTER_COMBAT_DELAY, , , , true);
	}
	
	usedQuenInCombat = false;		
	theGame.GetGamerProfile().ResetStat(ES_FinesseKills);

	LogChannel( 'OnCombatFinished', "OnCombatFinished: DelayedSheathSword timer added" ); 
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	disableAutoSheathe = inGameConfigWrapper.GetVarValue( 'Accessibility', 'DisableAutomaticSwordSheathe' );			
	if( !disableAutoSheathe )
	{
		if ( ShouldAutoSheathSwordInstantly() )
			AddTimer( 'DelayedSheathSword', 0.5f );
		else
			AddTimer( 'DelayedSheathSword', 2.f );
	}
	
	OnBlockAllCombatTickets( false ); 
}

@wrapMethod(W3PlayerWitcher) function Attack( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity)
{
	if(false) 
	{
		wrappedMethod(hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity);
	}
	
	super.Attack(hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity);
}

@wrapMethod(W3PlayerWitcher) function SpecialAttackLightSustainCost(dt : float, id : int)
{
	var cost, delay, focusPerSec : float;
	var reduction : SAbilityAttributeValue;
	var skillLevel : int;

	// 5.01 tree: 5.01 code.
	if (spectreVanillaSkills())
	{
		wrappedMethod(dt, id);
		return;
	}
	
	if(abilityManager && abilityManager.IsInitialized() && IsAlive() && CanUseSkill(S_Sword_s01) && HasResourcesForWhirl(dt))
	{
		PauseStaminaRegen('WhirlSkill');
		PauseFocusGain(true);
		AddTimer('ResumeFocusGain', 1.f);
		WhirlDrainResources(dt);
	}
	else if(abilityManager && abilityManager.IsInitialized() && IsAlive() && CanUseSkill(S_Sword_s35))
	{
		PauseStaminaRegen('WhirlSkill');
		if(GetStat(BCS_Stamina) > 0)
		{
			cost = GetStaminaActionCost(ESAT_Ability, GetSkillAbilityName(S_Sword_s35), dt);
			delay = GetStaminaActionDelay(ESAT_Ability, GetSkillAbilityName(S_Sword_s35), dt);
			skillLevel = GetSkillLevel(S_Sword_s35);
			if(skillLevel > 1)
			{
				reduction = GetSkillAttributeValue(S_Sword_s35, 'cost_reduction', false, true) * ((float)(skillLevel - 1) / (float)(skillLevel + 1));
				cost = MaxF(0, cost * (1 - reduction.valueMultiplicative) - reduction.valueAdditive);
			}
			DrainStamina(ESAT_FixedValue, cost, delay, GetSkillAbilityName(S_Sword_s35));
		}
		else if(GetStat(BCS_Focus) > 0)
		{
			focusPerSec = GetWhirlFocusCostPerSec();
			DrainFocus(focusPerSec * dt);
		}
		else
			OnPerformSpecialAttack(true, false);
	}
	else
	{
		OnPerformSpecialAttack(true, false);
	}
}

@addMethod(W3PlayerWitcher) function HasResourcesForWhirl(dt : float) : bool
{
	return GetStat(BCS_Stamina) >= GetWhirlStaminaCost(dt);
}

@addMethod(W3PlayerWitcher) function GetWhirlStaminaCost(dt : float) : float
{
	var cost : float;
	cost = GetStaminaActionCost(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
	cost *= MaxF(0, 1 - CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s01, 'stamina_cost_reduction_after_1', false, false)) * (GetSkillLevel(S_Sword_s01) - 1));
	if(HasBuff(EET_Mutagen04))
		cost *= 1 + ((W3Mutagen04_Effect)GetBuff(EET_Mutagen04)).GetAttackCostIncrease();
	return cost;
}

@addMethod(W3PlayerWitcher) function WhirlDrainResources(dt : float)
{
	var delay : float;
	var cost : float;
	delay = GetStaminaActionDelay(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
	cost = GetWhirlStaminaCost(dt);
	DrainStamina(ESAT_FixedValue, cost, delay, GetSkillAbilityName(S_Sword_s01));
	cost = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s01, 'stamina_cost_per_sec', false, false))
		 * MaxF(0, 1 - CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s01, 'stamina_cost_reduction_after_1', false, false)) * (GetSkillLevel(S_Sword_s01) - 1));
	cost *= dt;
	DrainFocus(cost/GetStatMax(BCS_Stamina));
}

@addMethod(W3PlayerWitcher) function GetNumHostilesInRange() : int
{
	var ents : array<CGameplayEntity>;
	
	FindGameplayEntitiesInRange(ents, this, 30, 100, , FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile, this);
	
	return ents.Size();
}

@addMethod(W3PlayerWitcher) function GetWhirlDamageBonus() : float
{
	var bonusCount : int;
	var ability : SAbilityAttributeValue;
	var damageBonus : float;
	
	bonusCount = Clamp(GetNumHostilesInRange() - 1, 0, 5);
	ability = GetSkillAttributeValue(S_Sword_s01, 'whirl_dmg_bonus', false, true) * GetSkillLevel(S_Sword_s01);
	damageBonus = ability.valueMultiplicative * bonusCount;
	
	return damageBonus;
}

@addMethod(W3PlayerWitcher) function GetRendPowerBonus() : float
{
	var	rendLoad, rendBonus, rendRatio : float;
	var attackBonus, rendBonusPerPoint, staminaRendBonus : SAbilityAttributeValue;
	
	rendBonus = 0;
	attackBonus = GetSkillAttributeValue(S_Sword_s02, 'attack_damage_bonus', false, true) * GetSkillLevel(S_Sword_s02);
	rendBonus += attackBonus.valueMultiplicative;
	rendRatio = GetSpecialAttackTimeRatio();
	if(rendRatio > 0)
	{
		staminaRendBonus = GetSkillAttributeValue(S_Sword_s02, 'stamina_max_dmg_bonus', false, true) * GetSkillLevel(S_Sword_s02);
		rendBonus += rendRatio * GetStatMax(BCS_Stamina) * staminaRendBonus.valueMultiplicative;
	}
	rendLoad = GetStat(BCS_Focus);
	if(rendLoad > 0)
	{
		rendBonusPerPoint = GetSkillAttributeValue(S_Sword_s02, 'adrenaline_damage_bonus', false, true);
		if(rendBonusPerPoint.valueAdditive == 0 && rendBonusPerPoint.valueBase == 0 && rendBonusPerPoint.valueMultiplicative == 0)
			rendBonusPerPoint = GetSkillAttributeValue(S_Sword_s02, 'adrenaline_final_damage_bonus', false, true);
		rendBonusPerPoint = rendBonusPerPoint * GetSkillLevel(S_Sword_s02);
		rendBonus += rendLoad * rendBonusPerPoint.valueMultiplicative;
	}

	return rendBonus;
}

@addMethod(W3PlayerWitcher) function GetRendStaminaCost(dt : float) : float
{
	return GetStaminaActionCost(ESAT_Ability, GetSkillAbilityName(S_Sword_s02), dt);
}

@wrapMethod(W3PlayerWitcher) function SpecialAttackHeavySustainCost(dt : float, id : int)
{
	var focusHighlight, ratio : float;
	var hud : CR4ScriptedHud;
	var hudWolfHeadModule : CR4HudModuleWolfHead;		
	
	// 5.01 tree: 5.01 code.
	if (spectreVanillaSkills())
	{
		wrappedMethod(dt, id);
		return;
	}

	PauseStaminaRegen('RendSkill');
	
	DrainStamina(ESAT_Ability, 0, 0, GetSkillAbilityName(S_Sword_s02), dt);

	
	if(GetStat(BCS_Stamina) <= 0)
		OnPerformSpecialAttack(false, false);
		
	
	ratio = EngineTimeToFloat(theGame.GetEngineTime() - specialHeavyStartEngineTime) / specialHeavyChargeDuration;
	
	if(ratio > 0.99) 
		ratio = 1;
		
	SetSpecialAttackTimeRatio(ratio);
}

@wrapMethod(W3PlayerWitcher) function IsSpecialLightAttackInputHeld ( time : float, id : int )
{
	var hasResource : bool;
	
	if(false) 
	{
		wrappedMethod(time, id);
	}
	
	if ( GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver' )
	{
		if ( GetBIsCombatActionAllowed() && inputHandler.IsActionAllowed(EIAB_SwordAttack))
		{
			hasResource = HasResourcesForWhirl(0.5f);
			
			if(hasResource)
			{
				SetupCombatAction( EBAT_SpecialAttack_Light, BS_Pressed );
				RemoveTimer('IsSpecialLightAttackInputHeld');
			}
			else if(!playedSpecialAttackMissingResourceSound)
			{
				SetShowToLowStaminaIndication(GetWhirlStaminaCost(0.5f));
				SoundEvent("gui_no_stamina");
				playedSpecialAttackMissingResourceSound = true;
			}
		}			
	}
	else
	{
		RemoveTimer('IsSpecialLightAttackInputHeld');
	}
}

@wrapMethod(W3PlayerWitcher) function IsSpecialHeavyAttackInputHeld ( time : float, id : int )
{		
	var cost : float;
	
	// 5.01 tree: 5.01 code.
	if (spectreVanillaSkills())
	{
		wrappedMethod(time, id);
		return;
	}
	
	if ( GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver' )
	{
		cost = GetRendStaminaCost(0.5f);
		
		if( GetBIsCombatActionAllowed() && inputHandler.IsActionAllowed(EIAB_SwordAttack))
		{
			if(GetStat(BCS_Stamina) >= cost)
			{
				SetupCombatAction( EBAT_SpecialAttack_Heavy, BS_Pressed );
				RemoveTimer('IsSpecialHeavyAttackInputHeld');
			}
			else if(!playedSpecialAttackMissingResourceSound)
			{
				SetShowToLowStaminaIndication(cost);
				SoundEvent("gui_no_stamina");
				playedSpecialAttackMissingResourceSound = true;
			}
		}
	}
	else
	{
		RemoveTimer('IsSpecialHeavyAttackInputHeld');
	}
}

@wrapMethod(W3PlayerWitcher) function EvadePressed( bufferAction : EBufferActionType )
{
	var cat : float;
	
	if(false) 
	{
		wrappedMethod(bufferAction);
	}
	
	if( (bufferAction == EBAT_Dodge && IsActionAllowed(EIAB_Dodge)) || (bufferAction == EBAT_Roll && IsActionAllowed(EIAB_Roll)) )
	{
		if( bufferAction == EBAT_Dodge && !HasStaminaToUseAction(ESAT_Dodge, '', 0, 0 ) ||
			bufferAction == EBAT_Roll && !HasStaminaToUseAction(ESAT_Roll, '', 0, 0 ) )
		{
			SoundEvent("gui_no_stamina");
			return;
		}
		
		if(bufferAction != EBAT_Roll && ShouldProcessTutorial('TutorialDodge'))
		{
			FactsAdd("tut_in_dodge", 1, 2);
			
			if(FactsQuerySum("tut_fight_use_slomo") > 0)
			{
				theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_TutorialFight) );
				FactsRemove("tut_fight_slomo_ON");
			}
		}				
		else if(bufferAction == EBAT_Roll && ShouldProcessTutorial('TutorialRoll'))
		{
			FactsAdd("tut_in_roll", 1, 2);
			
			if(FactsQuerySum("tut_fight_use_slomo") > 0)
			{
				theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_TutorialFight) );
				FactsRemove("tut_fight_slomo_ON");
			}
		}
			
		if ( GetBIsInputAllowed() )
		{			
			if ( GetBIsCombatActionAllowed() )
			{
				CriticalEffectAnimationInterrupted("Dodge 2");
				PushCombatActionOnBuffer( bufferAction, BS_Released );
				ProcessCombatActionBuffer();
			}					
			else if ( IsInCombatAction() && GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
			{
				if ( CanPlayHitAnim() && IsThreatened() )
				{
					CriticalEffectAnimationInterrupted("Dodge 1");
					PushCombatActionOnBuffer( bufferAction, BS_Released );
					ProcessCombatActionBuffer();							
				}
				else
					PushCombatActionOnBuffer( bufferAction, BS_Released );
			}
			
			else if ( !( IsCurrentSignChanneled() ) )
			{
				
				PushCombatActionOnBuffer( bufferAction, BS_Released );
			}
		}
		else
		{
			if ( IsInCombatAction() && GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
			{
				if ( CanPlayHitAnim() && IsThreatened() )
				{
					CriticalEffectAnimationInterrupted("Dodge 3");
					PushCombatActionOnBuffer( bufferAction, BS_Released );
					ProcessCombatActionBuffer();							
				}
				else
					PushCombatActionOnBuffer( bufferAction, BS_Released );
			}
			LogChannel( 'InputNotAllowed', "InputNotAllowed" );
		}
	}
	else
	{
		DisplayActionDisallowedHudMessage(EIAB_Dodge);
	}
}

@wrapMethod(W3PlayerWitcher) function OnMutation11Triggered()
{
	var min, max : SAbilityAttributeValue;
	var healValue : float;
	var quenEntity : W3QuenEntity;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if( IsSwimming() || IsDiving() || IsSailing() || IsUsingHorse() || IsUsingBoat() || IsUsingVehicle() || IsUsingExploration() )
	{
		AddEffectDefault( EET_Mutation11Debuff, NULL, "Mutation 11 Debuff", false );
	}
	else
	{
		AddEffectDefault( EET_Mutation11Buff, this, "Mutation 11", false );
	}
}

@addMethod(W3PlayerWitcher) function Mutation12GetBonus() : float
{			 
	var min, max : SAbilityAttributeValue;
	var buffs : array< CBaseGameplayEffect >;
	
	buffs = GetDrunkMutagens();

	if(buffs.Size() > 0)
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation12', 'mut12bonus', min, max);

		return buffs.Size() * min.valueAdditive;
	}
	
	return 0;
}

@wrapMethod(W3PlayerWitcher) function AddMutation12Decoction()
{
	if(false) 
	{
		wrappedMethod();
	}
}

@wrapMethod(W3PlayerWitcher) function Mutation11ShockWave( skipQuenSign : bool )
{
	var action : W3DamageAction;
	var ents : array< CGameplayEntity >;
	var i, j : int;
	var damages : array< SRawDamage >;
	var quen : W3QuenEntity;
	
	if(false) 
	{
		wrappedMethod(skipQuenSign);
	}

	FindGameplayEntitiesInSphere(ents, GetWorldPosition(), 5.f, 1000, '', FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral, this);
	
	if( ents.Size() > 0 )
	{
		damages = theGame.GetDefinitionsManager().GetDamagesFromAbility( 'Mutation11' );
	}
	
	for(i=0; i<ents.Size(); i+=1)
	{
		action = new W3DamageAction in theGame;
		action.Initialize( this, ents[i], NULL, "Mutation11", EHRT_Heavy, CPS_SpellPower, false, false, true, false );
		
		for( j=0; j<damages.Size(); j+=1 )
		{
			action.AddDamage( damages[j].dmgType, damages[j].dmgVal );
		}
		
		action.SetCannotReturnDamage( true );
		action.SetProcessBuffsIfNoDamage( true );
		action.AddEffectInfo( EET_KnockdownTypeApplicator );
		action.SetHitAnimationPlayType( EAHA_ForceYes );
		action.SetCanPlayHitParticle( false );
		
		theGame.damageMgr.ProcessAction( action );
		delete action;
	}
	
	mutation11QuenEntity = ( W3QuenEntity )GetSignEntity( ST_Quen );
	if( !mutation11QuenEntity )
	{
		mutation11QuenEntity = (W3QuenEntity)theGame.CreateEntity( GetSignTemplate( ST_Quen ), GetWorldPosition(), GetWorldRotation() );
		mutation11QuenEntity.CreateAttachment( this, 'quen_sphere' );
		AddTimer( 'DestroyMutation11QuenEntity', 2.f );
	}
	mutation11QuenEntity.PlayHitEffect( 'quen_impulse_explode', mutation11QuenEntity.GetWorldRotation() );
	
	if( !skipQuenSign )
	{
		
		PlayEffect( 'mutation_11_second_life' );
		
		quen = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
		quen.Init( signOwner, signs[ST_Quen].entity, true, true );
		quen.SetAlternateCast( S_Magic_s04 );
		quen.freeCast = true;
		quen.OnStarted();
		quen.OnThrowing();
		quen.SetDataFromRestore(1000000.f, 10.f);
	}
}

@addMethod(W3PlayerWitcher) function Mutation11GetBaseStrength() : float
{
	var drainStrength : float;
	var swordDmg, avAP, avSI : float;
	var abl : SAbilityAttributeValue;
	var curStats : SPlayerOffenseStats;
	var sword : SItemUniqueId;

	abl  = GetTotalSignSpellPower(S_Magic_1);
	abl += GetTotalSignSpellPower(S_Magic_2);
	abl += GetTotalSignSpellPower(S_Magic_3);
	abl += GetTotalSignSpellPower(S_Magic_4);
	abl += GetTotalSignSpellPower(S_Magic_5);
	avSI = MaxF(0.0, abl.valueMultiplicative / 5.0 - 1.0) * 100;
	curStats = GetOffenseStatsList();
	avAP = MaxF(0.0,
				(	curStats.steelFastAP * (1 - curStats.steelFastCritChance/100.0) + curStats.steelFastCritAP * curStats.steelFastCritChance/100.0
				+	curStats.silverFastAP * (1 - curStats.silverFastCritChance/100.0) + curStats.silverFastCritAP * curStats.silverFastCritChance/100.0
				+	curStats.steelStrongAP * (1 - curStats.steelStrongCritChance/100.0) + curStats.steelStrongCritAP * curStats.steelStrongCritChance/100.0
				+	curStats.silverStrongAP * (1 - curStats.silverStrongCritChance/100.0) + curStats.silverStrongCritAP * curStats.silverStrongCritChance/100.0
				)/4.0
		) * 100;

	sword = inv.GetCurrentlyHeldSword();
	if( sword == GetInvalidUniqueId() )
	{
		GetItemEquippedOnSlot(EES_SteelSword, sword);
		if( sword == GetInvalidUniqueId() )
			GetItemEquippedOnSlot(EES_SilverSword, sword);
	}
	if( sword != GetInvalidUniqueId() )
	{
		if( inv.GetItemCategory(sword) == 'steelsword' )
			swordDmg = GetTotalWeaponDamage(sword, theGame.params.DAMAGE_NAME_SLASHING, GetInvalidUniqueId());
		else if( inv.GetItemCategory(sword) == 'silversword' )
			swordDmg = GetTotalWeaponDamage(sword, theGame.params.DAMAGE_NAME_SILVER, GetInvalidUniqueId());
	}

	drainStrength = swordDmg + avAP + avSI;
	return drainStrength;
}

@wrapMethod(W3PlayerWitcher) function GetMutationLocalizedDescription( mutationType : EPlayerMutationType ) : string
{
	var pam : W3PlayerAbilityManager;
	var locKey : name;
	var arrStr : array< string >;
	var dm : CDefinitionsManagerAccessor;
	var min, max, sp : SAbilityAttributeValue;
	var tmp, tmp2, tox, critBonusDamage, val : float;
	var stats, stats2 : SPlayerOffenseStats;
	var buffPerc, exampleEnemyCount, debuffPerc : int;
	
	if(false) 
	{
		wrappedMethod(mutationType);
	}

	pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
	locKey = pam.GetMutationDescriptionLocalizationKey( mutationType );
	dm = theGame.GetDefinitionsManager();
	
	switch( mutationType )
	{
		case EPMT_Mutation1 :
			dm.GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', min, max);							
			arrStr.PushBack( NoTrailZeros( RoundMath( 100 * min.valueAdditive ) ) );
			break;
			
		case EPMT_Mutation2 :
			sp = GetPowerStatValue( CPS_SpellPower );
			
			
			dm.GetAbilityAttributeValue( 'Mutation2', 'crit_chance_factor', min, max );
			arrStr.PushBack( NoTrailZeros( RoundMath( 100 * ( ClampF(min.valueAdditive + SignPowerStatToPowerBonus(sp.valueMultiplicative) * min.valueMultiplicative, 0.f, 1.f) ) ) ) );
			
			
			dm.GetAbilityAttributeValue( 'Mutation2', 'crit_damage_factor', min, max );
			critBonusDamage = min.valueAdditive + SignPowerStatToPowerBonus(sp.valueMultiplicative) * min.valueMultiplicative;
			
			arrStr.PushBack( NoTrailZeros( RoundMath( 100 * critBonusDamage ) ) );
			break;
			
		case EPMT_Mutation3 :
		
			dm.GetAbilityAttributeValue('Mutation3', 'attack_power', min, max);
			tmp = min.valueMultiplicative;
			
			dm.GetAbilityAttributeValue('Mutation3', 'mutation3_buff_rate_sword', min, max);
			tmp2 = tmp * min.valueAdditive;
			arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
			dm.GetAbilityAttributeValue('Mutation3', 'mutation3_buff_rate_other', min, max);
			tmp2 = tmp * min.valueAdditive;
			arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
			dm.GetAbilityAttributeValue('Mutation3', 'mutation3_debuff_rate', min, max);
			tmp2 = tmp * min.valueAdditive;
			arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
			dm.GetAbilityAttributeValue('Mutation3', 'mutation3_buff_rate_kill', min, max);
			tmp2 = tmp * min.valueAdditive;
			arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
			dm.GetAbilityAttributeValue('Mutation3', 'mutation3_maxcap', min, max);
			tmp2 = tmp * min.valueAdditive;
			arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
			break;
			
		case EPMT_Mutation4 :
			
			dm.GetAbilityAttributeValue( 'Mutation4', 'toxicityRegenFactor', min, max );
			tmp = min.valueAdditive;
			arrStr.PushBack( NoTrailZeros( tmp * 100 ) );

			dm.GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
			tmp = min.valueAdditive;
			arrStr.PushBack( NoTrailZeros( tmp ) );

			arrStr.PushBack( NoTrailZeros( RoundMath( tmp * GetStat( BCS_Toxicity ) ) ) );
			arrStr.PushBack( NoTrailZeros( RoundMath( tmp * GetStatMax( BCS_Toxicity ) ) ) );
			
			dm.GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
			tmp = min.valueAdditive;
			arrStr.PushBack( NoTrailZeros( tmp ) );

			dm.GetAbilityAttributeValue( 'Mutation4BloodDebuff', 'staminaRegen', min, max );
			tmp = AbsF( min.valueMultiplicative ) * 100;
			arrStr.PushBack( NoTrailZeros( tmp ) );
			break;
			
		case EPMT_Mutation5 :
			dm.GetAbilityAttributeValue( 'Mutation5', 'mut5_duration_per_point', min, max );
			arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
			arrStr.PushBack( NoTrailZeros( min.valueAdditive * GetStatMax(BCS_Focus) ) );
			arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
			
			break;
		
		case EPMT_Mutation6 :	
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'full_freeze_chance', min, max );
			arrStr.PushBack( RoundMath( 100 * min.valueMultiplicative ) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'ForceDamage', min, max );
			val = CalculateAttributeValue( min );
			arrStr.PushBack( RoundMath( val ) );
			sp = GetTotalSignSpellPower( S_Magic_1 );
			arrStr.PushBack( RoundMath( val * sp.valueMultiplicative ) );
		
			break;
			
		case EPMT_Mutation7 :
			
			dm.GetAbilityAttributeValue( 'Mutation7BuffEffect', 'duration', min, max );
			arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
			
			dm.GetAbilityAttributeValue( 'Mutation7Buff', 'attack_power', min, max );
			buffPerc = RoundMath( 100 * min.valueMultiplicative );
			arrStr.PushBack( NoTrailZeros( buffPerc ) );
			
			dm.GetAbilityAttributeValue( 'Mutation7DebuffEffect', 'duration', min, max );
			arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				
			dm.GetAbilityAttributeValue( 'Mutation7Debuff', 'attack_power', min, max );
			buffPerc = RoundMath( -100 * min.valueMultiplicative );
			arrStr.PushBack( NoTrailZeros( buffPerc ) );
			
			break;
		
		case EPMT_Mutation8 :
			
			dm.GetAbilityAttributeValue( 'Mutation8', 'hp_perc_trigger', min, max );
			arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
			
			dm.GetAbilityAttributeValue( 'Mutation8', 'dmg_bonus', min, max );
			arrStr.PushBack( FloatToStringPrec( 100 * min.valueMultiplicative, 0 ) );
			
			arrStr.PushBack( FloatToStringPrec( 100 * min.valueMultiplicative * GetStatMax(BCS_Focus), 0 ) );
			
			break;
			
		case EPMT_Mutation9 :
			
			dm.GetAbilityAttributeValue( 'Mutation9', 'mut9_damage', min, max );
			arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
			
			dm.GetAbilityAttributeValue( 'Mutation9', 'health_reduction', min, max );
			arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
			
			dm.GetAbilityAttributeValue( 'Mutation9', 'mut9_slowdown', min, max );
			arrStr.PushBack( NoTrailZeros( 100 * min.valueAdditive ) );
			
			break;
			
		case EPMT_Mutation10 :

			dm.GetAbilityAttributeValue( 'Mutation10Effect', 'mutation10_factor', min, max );
			arrStr.PushBack( NoTrailZeros( min.valueMultiplicative ) );
			arrStr.PushBack( NoTrailZeros( RoundMath(GetToxicityDamage())) );

			theGame.GetDefinitionsManager().GetAbilityAttributeValue('ToxicityEffect', 'DirectDamage', min, max);
			tmp = min.valueMultiplicative * GetStatMax(BCS_Vitality);
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation10Effect', 'mutation10_factor', min, max);
			tmp *= 1 + min.valueMultiplicative * GetStatMax(BCS_Toxicity)/100.0;
			arrStr.PushBack( NoTrailZeros( RoundMath(tmp)) );
			
			break;
			
		case EPMT_Mutation11 :
			
			dm.GetAbilityAttributeValue( 'Mutation11BuffEffect', 'duration', min, max);
			arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
			
			dm.GetAbilityAttributeValue( 'Mutation11DebuffEffect', 'duration', min, max);
			arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
			
			arrStr.PushBack( NoTrailZeros( MaxF(1, Mutation11GetBaseStrength()) * GetStatMax(BCS_Focus) ) );
			
			break;
			
		case EPMT_Mutation12 : 
			
			dm.GetAbilityAttributeValue( 'Mutation12', 'maxcap', min, max );
			arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );	
			
			dm.GetAbilityAttributeValue( 'Mutation12', 'mut12bonus', min, max );
			arrStr.PushBack( NoTrailZeros( min.valueAdditive * 100 ) );
			
			dm.GetAbilityAttributeValue( 'Mutation12', 'mut12bonus', min, max );
			arrStr.PushBack( NoTrailZeros( 1 + min.valueAdditive * 3 ) );
			break;
			
		case EPMT_MutationMaster :
			
			arrStr.PushBack( "4" );
			
			break;
	}
	
	return GetLocStringByKeyExtWithParams( locKey, , , arrStr );
}

@addMethod(W3PlayerWitcher) function CountAlchemy18Abilities(skillLevel : int) : int
{
	var absToAdd : int;
	var maxAbsAllowed : int;
	var names : array<name>;
	var m_alchemyManager : W3AlchemyManager;
	var recipe : SAlchemyRecipe;
	var i : int;
	
	absToAdd = 0;
	maxAbsAllowed = skillLevel * RoundMath(CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s18, 'max_abs_per_lvl_s18', false, false)));
	m_alchemyManager = new W3AlchemyManager in this;
	m_alchemyManager.Init();
	names = GetAlchemyRecipes();
	for(i = 0; i < names.Size(); i += 1)
	{
		m_alchemyManager.GetRecipe(names[i], recipe);
		if(absToAdd < maxAbsAllowed && IsAlchemy18Recipe(recipe.cookedItemType))
			absToAdd += 1;
	}
	
	return absToAdd;
}

@addMethod(W3PlayerWitcher) function RecalcAlchemy18Abilities()
{
	var absToAdd, curAbs : int;
	var skillName : name = SkillEnumToName(S_Alchemy_s18);

	// Spectre's own count. With the 5.01 alchemy skills, 5.01 adds them as it learns recipes (AddAlchemyRecipe, OnSkillEquip).
	if(spectreVanillaAlchemySkills())
		return;

	if(CanUseSkill(S_Alchemy_s18))
		absToAdd = CountAlchemy18Abilities(GetSkillLevel(S_Alchemy_s18));
	else
		absToAdd = 0;
	curAbs = GetAbilityCount(skillName);

	if(absToAdd == 0)
		RemoveAbilityAll(skillName);
	else if(absToAdd > curAbs)
		AddAbilityMultiple(skillName, absToAdd - curAbs);
	else if(absToAdd < curAbs)
		RemoveAbilityMultiple(skillName, curAbs - absToAdd);
}

@wrapMethod(W3PlayerWitcher) function AddAlchemyRecipe(nam : name, optional isSilent : bool, optional skipTutorialUpdate : bool) : bool
{
	var i, potions, bombs : int;
	var found : bool;
	var m_alchemyManager : W3AlchemyManager;
	var recipe : SAlchemyRecipe;
	var knownBombTypes : array<string>;
	var strRecipeName, recipeNameWithoutLevel : string;
	
	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
		return wrappedMethod(nam, isSilent, skipTutorialUpdate);
	
	if(!IsAlchemyRecipe(nam))
		return false;
	
	found = false;
	for(i=0; i<alchemyRecipes.Size(); i+=1)
	{
		if(alchemyRecipes[i] == nam)
			return false;
		
		
		if(StrCmp(alchemyRecipes[i],nam) > 0)
		{
			alchemyRecipes.Insert(i,nam);
			found = true;
			AddAlchemyHudNotification(nam,isSilent);
			break;
		}			
	}	

	if(!found)
	{
		alchemyRecipes.PushBack(nam);
		AddAlchemyHudNotification(nam,isSilent);
	}
	
	m_alchemyManager = new W3AlchemyManager in this;
	m_alchemyManager.Init(alchemyRecipes);
	m_alchemyManager.GetRecipe(nam, recipe);

	// 5.01 tree: Acquired Tolerance as in 5.01.
	if (spectreVanillaSkills())
	{
		if (CanUseSkill(S_Alchemy_s18) && recipe.cookedItemType != EACIT_Bolt && recipe.cookedItemType != EACIT_Undefined
			&& recipe.cookedItemType != EACIT_Dye && recipe.level <= GetSkillLevel(S_Alchemy_s18))
			AddAbility(spectreSkillAbility(SkillEnumToName(S_Alchemy_s18)), true);
	}
	else
		RecalcAlchemy18Abilities();
	
	
	if(recipe.cookedItemType == EACIT_Bomb)
	{
		bombs = 0;
		for(i=0; i<alchemyRecipes.Size(); i+=1)
		{
			m_alchemyManager.GetRecipe(alchemyRecipes[i], recipe);
			
			
			if(recipe.cookedItemType == EACIT_Bomb)
			{
				strRecipeName = NameToString(alchemyRecipes[i]);
				recipeNameWithoutLevel = StrLeft(strRecipeName, StrLen(strRecipeName)-2);
				if(!knownBombTypes.Contains(recipeNameWithoutLevel))
				{
					bombs += 1;
					knownBombTypes.PushBack(recipeNameWithoutLevel);
				}
			}
		}
		
		theGame.GetGamerProfile().SetStat(ES_KnownBombRecipes, bombs);
	}		
	
	else if(recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_MutagenPotion || recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_Quest)
	{
		potions = 0;
		for(i=0; i<alchemyRecipes.Size(); i+=1)
		{
			m_alchemyManager.GetRecipe(alchemyRecipes[i], recipe);
			
			
			if(recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_MutagenPotion || recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_Quest)
			{
				potions += 1;
			}				
		}		
		theGame.GetGamerProfile().SetStat(ES_KnownPotionRecipes, potions);
	}
	
	theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_AlchemyRecipe );
			
	return true;
}

@wrapMethod(W3PlayerWitcher) function ToxicityLowEnoughToDrinkPotion( slotid : EEquipmentSlots, optional itemId : SItemUniqueId ) : bool
{
	var item 				: SItemUniqueId;

	if(itemId != GetInvalidUniqueId())
			item = itemId; 
		else 
			item = itemSlots[slotid];

	if(IsMutationActive(EPMT_Mutation12) && spectreMutation12CanDrinkDecoction())
	{
		return true;
	}

	// Alchemy 5.01 variant: 5.01 code (Spectre's Mutation 12 above still applies).
	if (spectreAlchemy501())
		return wrappedMethod(slotid, itemId);

	return (theGame.alchexts.GetTotalToxicity(item) <= abilityManager.GetStatMax(BCS_Toxicity) );
}

@wrapMethod(W3PlayerWitcher) function DrinkPotionFromSlot(slot : EEquipmentSlots):void
{
	var item : SItemUniqueId;		
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleItemInfo;
	
	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
	{
		wrappedMethod(slot);
		return;
	}
	
	GetItemEquippedOnSlot(slot, item);
	if(IsInCombatAction() && (((int)GetBehaviorVariable('combatActionType')) == CAT_SpecialAttack || ((int)GetBehaviorVariable('combatActionType')) == CAT_CastSign && IsCurrentSignChanneled()))
	{
		DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ));
	}
	else if(!CanUseSkill(S_Perk_15) && (inv.ItemHasTag(item, 'Alcohol') || inv.ItemHasTag(item, 'Uncooked')) && !ToxicityLowEnoughToDrinkPotion(slot))
	{
		SendToxicityTooHighMessage();
	}
	else if(inv.ItemHasTag(item, 'Edibles'))	
	{
		ConsumeItem( item );
	}
	else
	{			
		if (ToxicityLowEnoughToDrinkPotion(slot))
		{
			DrinkPreparedPotion(slot);
		}
		else
		{
			SendToxicityTooHighMessage();
		}
	}
	
	hud = (CR4ScriptedHud)theGame.GetHud(); 
	if ( hud ) 
	{ 
		module = (CR4HudModuleItemInfo)hud.GetHudModule("ItemInfoModule");
		if( module )
		{
			module.ForceShowElement();
		}
	}
}

@wrapMethod(W3PlayerWitcher) function ResetCharacterDev()
{
	ForceSetStat(BCS_Toxicity, 0);						
	
	wrappedMethod();	
}

@wrapMethod(W3PlayerWitcher) function HasAllItemsFromSet(setItemTag : name) : bool
{
	var item : SItemUniqueId;
	
	if(false) 
	{
		wrappedMethod(setItemTag);
	}
	
	if(!GetItemEquippedOnSlot(EES_SteelSword, item) || !inv.ItemHasTag(item, setItemTag))
		return false;
	
	if(!GetItemEquippedOnSlot(EES_SilverSword, item) || !inv.ItemHasTag(item, setItemTag))
		return false;
		
	if(!GetItemEquippedOnSlot(EES_Boots, item) || !inv.ItemHasTag(item, setItemTag))
		return false;
		
	if(!GetItemEquippedOnSlot(EES_Pants, item) || !inv.ItemHasTag(item, setItemTag))
		return false;
		
	if(!GetItemEquippedOnSlot(EES_Gloves, item) || !inv.ItemHasTag(item, setItemTag))
		return false;
		
	if(!GetItemEquippedOnSlot(EES_Armor, item) || !inv.ItemHasTag(item, setItemTag))
		return false;

	return true;
}

@wrapMethod(W3PlayerWitcher) function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
{			
	var i, groupID, quantity : int;
	var fistsID : array<SItemUniqueId>;
	var pam : W3PlayerAbilityManager;
	var isSkillMutagen : bool;		
	var armorEntity : CItemEntity;
	var armorMeshComponent : CComponent;
	var armorSoundIdentification : name;
	var category : name;
	var tagOfASet : name;
	var prevSkillColor : ESkillColor;
	var containedAbilities : array<name>;
	var dm : CDefinitionsManagerAccessor;
	var otherMask, previousItemInSlot : SItemUniqueId;
	var tutStatePot : W3TutorialManagerUIHandlerStatePotions;
	var tutStateFood : W3TutorialManagerUIHandlerStateFood;
	var tutStateSecondPotionEquip : W3TutorialManagerUIHandlerStateSecondPotionEquip;
	var boltItem : SItemUniqueId;
	var tutBolt : SUITutorial;
	var aerondight : W3Effect_Aerondight;
	var phantomWeapon : W3Effect_PhantomWeapon;
	
	if(false) 
	{
		wrappedMethod(item, slot, ignoreMounting, toHand);
	}
	
	if(!inv.IsIdValid(item))
	{
		LogAssert(false, "W3PlayerWitcher.EquipItemInGivenSlot: invalid item");
		return false;
	}
	if(slot == EES_InvalidSlot || slot == EES_HorseBlinders || slot == EES_HorseSaddle || slot == EES_HorseBag || slot == EES_HorseTrophy)
	{
		LogAssert(false, "W3PlayerWitcher.EquipItem: Cannot equip item <<" + inv.GetItemName(item) + ">> - provided slot <<" + slot + ">> is invalid");
		return false;
	}
	if(itemSlots[slot] == item)
	{
		return true;
	}	
	
	// Gear above Geralt's level only when "Equip gear of any level" is on (HasRequiredLevelToEquipItem).
	if(!HasRequiredLevelToEquipItem(item))
	{
		return false;
	}
	
	if( slot == EES_SilverSword && inv.ItemHasTag( item, 'Aerondight' ) )
	{
		if(IsInCombat())
		{
			AddEffectDefault( EET_Aerondight, this, "Aerondight" );


			aerondight = (W3Effect_Aerondight)GetBuff( EET_Aerondight );
			aerondight.Pause( 'ManageAerondightBuff' );
		}
	}		
	
	if( slot == EES_SteelSword && inv.ItemHasTag( item, 'PhantomWeapon' ) )
	{
		if(IsInCombat())
		{
			AddEffectDefault( EET_PhantomWeapon, this, "PhantomWeapon" );
			phantomWeapon = (W3Effect_PhantomWeapon)GetBuff( EET_PhantomWeapon );
			phantomWeapon.Pause( 'ManageIrisBuff' );
		}
	}		
	
	
	previousItemInSlot = itemSlots[slot];
	if( IsItemEquipped(item)) 
	{
		SwapEquippedItems(slot, GetItemSlot(item));
		return true;
	}
	
	
	isSkillMutagen = IsSlotSkillMutagen(slot);
	if(isSkillMutagen)
	{
		pam = (W3PlayerAbilityManager)abilityManager;
		if(!pam.IsSkillMutagenSlotUnlocked(slot))
		{
			return false;
		}
	}
	
	
	if(inv.IsIdValid(previousItemInSlot))
	{			
		if(!UnequipItemFromSlot(slot, true))
		{
			LogAssert(false, "W3PlayerWitcher.EquipItem: Cannot equip item <<" + inv.GetItemName(item) + ">> !!");
			return false;
		}
	}		
	
	
	if(inv.IsItemMask(item))
	{
		if(slot == EES_Quickslot1)
			GetItemEquippedOnSlot(EES_Quickslot2, otherMask);
		else
			GetItemEquippedOnSlot(EES_Quickslot1, otherMask);
			
		if(inv.IsItemMask(otherMask))
			UnequipItem(otherMask);
	}
	
	if(isSkillMutagen)
	{
		groupID = pam.GetSkillGroupIdOfMutagenSlot(slot);
		prevSkillColor = pam.GetSkillGroupColor(groupID);
	}
	
	itemSlots[slot] = item;
	
	category = inv.GetItemCategory( item );

	
	if( !ignoreMounting && ShouldMount(slot, item, category) )
	{
		
		inv.MountItem( item, toHand, IsSlotSkillMutagen( slot ) );
	}		
	
	theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_EQUIPPED, inv.GetItemName(item), slot );
			
	if(slot == EES_RangedWeapon)
	{			
		rangedWeapon = ( Crossbow )( inv.GetItemEntityUnsafe(item) );
		if(!rangedWeapon)
			AddTimer('DelayedOnItemMount', 0.1, true);
		
		if ( ( IsSwimming() || IsDiving() ) && inv.IsItemCrossbow(item) )
		{
			GetItemEquippedOnSlot(EES_Bolt, boltItem);
			
			if(inv.IsIdValid(boltItem))
			{
				if ( !inv.ItemHasTag(boltItem, 'UnderwaterAmmo' ))
				{
					AddAndEquipInfiniteBolt(false, true);
				}
			}
			else if(!IsAnyItemEquippedOnSlot(EES_Bolt))
			{
				AddAndEquipInfiniteBolt(false, true);
			}
		}
		else if(!IsAnyItemEquippedOnSlot(EES_Bolt) && inv.IsItemCrossbow(item))
		{
			AddAndEquipInfiniteBolt();
		}

		if( ShouldProcessTutorial('TutorialRadialSelectBolts') )
		{
			tutBolt.menuName = 'RadialMenu';
			tutBolt.tutorialStateName = 'Radial';
			tutBolt.triggerCondition = EUITTC_OnMenuOpen;
			tutBolt.priority = 10;
			tutBolt.abortOnMenuClose = true;
			theGame.GetTutorialSystem().uiHandler.RegisterUIHint(tutBolt);
		}
	}
	else if(slot == EES_Bolt)
	{
		if(rangedWeapon)
		{
			inv.UpdateEquippedBolt();
			if ( !IsSwimming() || !IsDiving() )
			{
				rangedWeapon.OnReplaceAmmo();
				rangedWeapon.OnWeaponReload();
			}
			else
			{
				DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ));
			}
		}
	}		
	
	else if(isSkillMutagen)
	{
		theGame.GetGuiManager().IgnoreNewItemNotifications( true );
		
		
		quantity = inv.GetItemQuantity( item );
		if( quantity > 1 )
		{
			inv.SplitItem( item, quantity - 1 );
		}
		
		pam.OnSkillMutagenEquipped(item, slot, prevSkillColor);
		LogSkillColors("Mutagen <<" + inv.GetItemName(item) + ">> equipped to slot <<" + slot + ">>");
		LogSkillColors("Group bonus color is now <<" + pam.GetSkillGroupColor(groupID) + ">>");
		LogSkillColors("");
		
		theGame.GetGuiManager().IgnoreNewItemNotifications( false );
	}
	else if(slot == EES_Gloves && HasWeaponDrawn(false))
	{
		if(HasBuff(EET_Runeword4))
			((W3Effect_Runeword4)GetBuff(EET_Runeword4)).PlayRuneword4FX();
	}
	
	else if( ( slot == EES_Petard1 || slot == EES_Petard2 ) && inv.IsItemBomb( GetSelectedItemId() ) )
	{
		SelectQuickslotItem( slot );
	}

	
	if(inv.ItemHasAbility(item, 'MA_HtH'))
	{
		inv.GetItemContainedAbilities(item, containedAbilities);
		fistsID = inv.GetItemsByName('fists');
		dm = theGame.GetDefinitionsManager();
		for(i=0; i<containedAbilities.Size(); i+=1)
		{
			if(dm.AbilityHasTag(containedAbilities[i], 'MA_HtH'))
			{					
				inv.AddItemCraftedAbility(fistsID[0], containedAbilities[i], true);
			}
		}
	}		
	
	
	if(inv.IsItemAnyArmor(item))
	{
		pam = (W3PlayerAbilityManager)abilityManager;
		
		pam.ManageSetArmorTypeBonus();
		pam.SpectreRefreshArmorPieceSkills();
	}
	
	
	UpdateItemSetBonuses( item, true );
			
	
	theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );

	
	if(ShouldProcessTutorial('TutorialPotionCanEquip3'))
	{
		if(IsSlotPotionSlot(slot))
		{
			tutStatePot = (W3TutorialManagerUIHandlerStatePotions)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(tutStatePot)
			{
				tutStatePot.OnPotionEquipped(inv.GetItemName(item));
			}
			
			tutStateSecondPotionEquip = (W3TutorialManagerUIHandlerStateSecondPotionEquip)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(tutStateSecondPotionEquip)
			{
				tutStateSecondPotionEquip.OnPotionEquipped(inv.GetItemName(item));
			}
			
		}
	}
	else if (FactsQuerySum("tut_forced_preparation") > 0)
	{
		theGame.GetTutorialSystem().ForcedAlchemyCleanup();
	}
	
	if(ShouldProcessTutorial('TutorialFoodSelectTab'))
	{
		if( IsSlotPotionSlot(slot) && inv.IsItemFood(item))
		{
			tutStateFood = (W3TutorialManagerUIHandlerStateFood)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(tutStateFood)
			{
				tutStateFood.OnFoodEquipped();
			}
		}
	}
	
	
	
	
	tagOfASet = inv.DetectTagOfASet(item);
	CheckForFullyArmedByTag(tagOfASet);
	
	return true;
}

@wrapMethod(W3PlayerWitcher) function UnequipItemFromSlot(slot : EEquipmentSlots, optional reequipped : bool) : bool
{
	var item, bolts, id : SItemUniqueId;
	var items : array<SItemUniqueId>;
	var retBool : bool;
	var fistsID, bolt : array<SItemUniqueId>;
	var i, groupID : int;
	var pam : W3PlayerAbilityManager;
	var prevSkillColor : ESkillColor;
	var containedAbilities : array<name>;
	var dm : CDefinitionsManagerAccessor;
	var isSwimming : bool;
	var hud 				: CR4ScriptedHud;
	var damagedItemModule 	: CR4HudModuleDamagedItems;
	
	if(false) 
	{
		wrappedMethod(slot, reequipped);
	}
	
	if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots') || !inv.IsIdValid(itemSlots[slot]))
		return false;
		
	
	if(IsSlotSkillMutagen(slot))
	{
		
		pam = (W3PlayerAbilityManager)abilityManager;
		groupID = pam.GetSkillGroupIdOfMutagenSlot(slot);
		prevSkillColor = pam.GetSkillGroupColor(groupID);
	}
	
	
	if(slot == EES_SilverSword  || slot == EES_SteelSword)
	{
		PauseOilBuffs( slot == EES_SteelSword );
	}
		
	item = itemSlots[slot];
	itemSlots[slot] = GetInvalidUniqueId();
	
	
	if( slot == EES_SilverSword && inv.ItemHasTag( item, 'Aerondight' ) )
	{
		RemoveBuff( EET_Aerondight );
	}
	
	if( slot == EES_SteelSword && inv.ItemHasTag( item, 'PhantomWeapon' ) )
	{
		RemoveBuff( EET_PhantomWeapon );
	}
	
	
	if(slot == EES_RangedWeapon)
	{
		
		this.OnRangedForceHolster( true, true );
		rangedWeapon.ClearDeployedEntity(true);
		rangedWeapon = NULL;
	
		
		if(GetItemEquippedOnSlot(EES_Bolt, bolts))
		{
			if(inv.ItemHasTag(bolts, theGame.params.TAG_INFINITE_AMMO))
			{
				inv.RemoveItem(bolts, inv.GetItemQuantity(bolts) );
			}
		}
	}
	else if(IsSlotSkillMutagen(slot))
	{			
		pam.OnSkillMutagenUnequipped(item, slot, prevSkillColor);
		LogSkillColors("Mutagen <<" + inv.GetItemName(item) + ">> unequipped from slot <<" + slot + ">>");
		LogSkillColors("Group bonus color is now <<" + pam.GetSkillGroupColor(groupID) + ">>");
		LogSkillColors("");
	}
	
	
	if(currentlyEquipedItem == item)
	{
		currentlyEquipedItem = GetInvalidUniqueId();
		RaiseEvent('ForcedUsableItemUnequip');
	}
	if(currentlyEquipedItemL == item)
	{
		if ( currentlyUsedItemL )
		{
			currentlyUsedItemL.OnHidden( this );
		}
		HideUsableItem ( true );
	}
			
	
	if( !IsSlotPotionMutagen(slot) )
	{
		GetInventory().UnmountItem(item, true);
	}
	
	retBool = true;
			
	
	if(IsAnyItemEquippedOnSlot(EES_RangedWeapon) && slot == EES_Bolt)
	{			
		if(inv.ItemHasTag(item, theGame.params.TAG_INFINITE_AMMO))
		{
			
			inv.RemoveItem(item, inv.GetItemQuantityByName( inv.GetItemName(item) ) );
		}
		else if (!reequipped)
		{
			
			AddAndEquipInfiniteBolt();
		}
	}
	
	
	if(slot == EES_SilverSword  || slot == EES_SteelSword)
	{
		OnEquipMeleeWeapon(PW_None, true);			
	}
	
	if(  GetSelectedItemId() == item )
	{
		ClearSelectedItemId();
	}
	
	if(inv.IsItemBody(item))
	{
		retBool = true;
	}		
	
	if(inv.ItemHasAbility(item, 'MA_HtH'))
	{
		inv.GetItemContainedAbilities(item, containedAbilities);
		fistsID = inv.GetItemsByName('fists');
		dm = theGame.GetDefinitionsManager();
		for(i=0; i<containedAbilities.Size(); i+=1)
		{
			if(dm.AbilityHasTag(containedAbilities[i], 'MA_HtH'))
			{
				inv.RemoveItemCraftedAbility(fistsID[0], containedAbilities[i]);
			}
		}
	}
	
	
	if(inv.IsItemAnyArmor(item))
	{
		pam = (W3PlayerAbilityManager)abilityManager;
		
		pam.ManageSetArmorTypeBonus();
		pam.SpectreRefreshArmorPieceSkills();
	}
	
	
	UpdateItemSetBonuses( item, false );
	
	
	if( inv.ItemHasTag( item, theGame.params.ITEM_SET_TAG_BONUS ) && !IsSetBonusActive( EISB_RedWolf_2 ) )
	{
		SkillReduceBombAmmoBonus();
	}

	if( slot == EES_Gloves )
	{
		thePlayer.DestroyEffect('runeword_4');
	}
	
	
	hud = (CR4ScriptedHud)theGame.GetHud();
	if ( hud )
	{
		damagedItemModule = hud.GetDamagedItemModule();
		if ( damagedItemModule )
		{
			damagedItemModule.OnItemUnequippedFromSlot( slot );
		}
	}
	
	
	theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
	
	return retBool;
}

@wrapMethod(W3PlayerWitcher) function CastSign( optional skipCastingAnimation : bool ) : bool
{
	var equippedSignStr : string;
	var newSignEnt : W3SignEntity;
	var spawnPos : Vector;
	var slotMatrix : Matrix;
	var target : CActor;
	
	if(false) 
	{
		wrappedMethod(skipCastingAnimation);
	}
	
	if ( IsInAir() )
	{
		return false;
	}

	// 5.01 tree: Flood of Anger as in 5.01.
	if (spectreVanillaSkills())
	{
		AddTemporarySkills();
	}

	if(equippedSign == ST_Aard)
	{
		CalcEntitySlotMatrix('l_weapon', slotMatrix);
		spawnPos = MatrixGetTranslation(slotMatrix);
	}
	else
	{
		spawnPos = GetWorldPosition();
	}
	
	if( equippedSign == ST_Aard || equippedSign == ST_Igni )
	{
		target = GetTarget();
		if(target)
			target.SignalGameplayEvent( 'DodgeSign' );
	}

	m_TriggerEffectDisablePending = true;
	m_TriggerEffectDisableTTW = 0.3; 
	
	newSignEnt = (W3SignEntity)theGame.CreateEntity( signs[equippedSign].template, spawnPos, GetWorldRotation() );
	return newSignEnt.Init( signOwner, signs[equippedSign].entity );
}

@addMethod( W3PlayerWitcher ) function spectreReduceSignBuffAmmo(sign : ESignType)
{
	var enhancements : array<CBaseGameplayEffect>;
	var i : int;
	var type : EEffectType;
	
	enhancements = GetShrineBuffs();
	
	switch(sign)
	{
		case ST_Aard :
			for( i=enhancements.Size()-1; i>=0; i-=1 )
			{
				type = enhancements[i].GetEffectType();
				if(type == EET_ShrineAard)
				{
					spectreReduceAllAardBuffAmmo((W3Effect_ShrineAard)enhancements[i]);
				}
			}
		break;

		case ST_Yrden :
			for( i=enhancements.Size()-1; i>=0; i-=1 )
			{
				type = enhancements[i].GetEffectType();
				if(type == EET_ShrineYrden)
				{
					spectreReduceAllYrdenBuffAmmo((W3Effect_ShrineYrden)enhancements[i]);
				}
			}
		break;

		case ST_Igni :
			for( i=enhancements.Size()-1; i>=0; i-=1 )
			{
				type = enhancements[i].GetEffectType();
				if(type == EET_ShrineIgni)
				{
					spectreReduceAllIgniBuffAmmo((W3Effect_ShrineIgni)enhancements[i]);
				}
			}
		break;

		case ST_Quen :
			for( i=enhancements.Size()-1; i>=0; i-=1 )
			{
				type = enhancements[i].GetEffectType();
				if(type == EET_ShrineQuen)
				{
					spectreReduceAllQuenBuffAmmo((W3Effect_ShrineQuen)enhancements[i]);
				}
			}
		break;

		case ST_Axii :
			for( i=enhancements.Size()-1; i>=0; i-=1 )
			{
				type = enhancements[i].GetEffectType();
				if(type == EET_ShrineAxii)
				{
					spectreReduceAllAxiiBuffAmmo((W3Effect_ShrineAxii)enhancements[i]);
				}
			}
		break;
	}
}


@wrapMethod(W3PlayerWitcher) function StartFrenzy()
{
	var ratio, duration : float;
	var skillLevel : int;

	// 5.01 tree: 5.01 code.
	if (spectreVanillaSkills())
	{
		wrappedMethod();
		return;
	}

	isInFrenzy = true;
	skillLevel = GetSkillLevel(S_Alchemy_s16);
	ratio = PowF(1.0f - abilityManager.GetStatPercents(BCS_Toxicity) * 0.1f, skillLevel);
	duration = skillLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s16, 'slowdown_duration', false, true));

	theGame.SetTimeScale(ratio, theGame.GetTimescaleSource(ETS_SkillFrenzy), theGame.GetTimescalePriority(ETS_SkillFrenzy) );
	AddTimer('SkillFrenzyFinish', 2 * ratio, , , , true);
}

@wrapMethod(W3PlayerWitcher) function GetToxicityDamageThreshold() : float
{
	var ret : float;
	
	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
		return wrappedMethod();
	
	ret = theGame.params.TOXICITY_DAMAGE_THRESHOLD;
	
	return ret;
}

@addField(W3PlayerWitcher)
private var cachedToxDmg : float;

@addMethod(W3PlayerWitcher) function GetToxicityDamage() : float
{
	var min, max : SAbilityAttributeValue;
	var dmg : float;
	
	if(cachedToxDmg == 0)
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('ToxicityEffect', 'DirectDamage', min, max);
		cachedToxDmg = min.valueMultiplicative;
	}
	dmg = cachedToxDmg * GetStatMax(BCS_Vitality);
	if(HasBuff(EET_Mutation10))
		dmg *= ((W3Effect_Mutation10)GetBuff(EET_Mutation10)).GetDrainMult();
	
	return dmg;
}

@addMethod(W3PlayerWitcher) function RecalcTransmutationAbilities()
{
	var ablName : name = GetSkillAbilityName(S_Alchemy_s13);
	var offset : float = GetStat(BCS_Toxicity) - GetStat(BCS_Toxicity, true);
	var numAbls : int = GetAbilityCount(ablName);
	var targetNumAbls : int;

	// Spectre's Transmutation. With the 5.01 alchemy skills, 5.01 adds them per decoction (W3Mutagen_Effect.OnEffectAdded).
	if(spectreVanillaAlchemySkills())
		return;

	if(!CanUseSkill(S_Alchemy_s13))
	{
		RemoveAbilityAll(ablName);
		return;
	}
	
	targetNumAbls = RoundMath(offset) * GetSkillLevel(S_Alchemy_s13);
	if(numAbls < targetNumAbls)
		AddAbilityMultiple(ablName, targetNumAbls - numAbls);
	else if(numAbls > targetNumAbls)
		RemoveAbilityMultiple(ablName, numAbls - targetNumAbls);
}

@wrapMethod(W3PlayerWitcher) function CalculatePotionDuration(item : SItemUniqueId, isMutagenPotion : bool, optional itemName : name) : float
{
	var duration, skillPassiveMod, mutagenSkillMod : float;
	var val, maxVal : SAbilityAttributeValue;

	// Wolf Hour: the length of its effect, with or without the alchemy 5.01 variant.
	if (inv.IsIdValid(item))
		itemName = inv.GetItemName(item);
	if (itemName == 'Wolf Hour')
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('WolfHourEffect', 'duration', val, maxVal);
		return CalculateAttributeValue(GetAttributeRandomizedValue(val, maxVal));
	}

	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
		return wrappedMethod(item, isMutagenPotion, itemName);

	duration = theGame.alchexts.CalculatePotionDuration(item, isMutagenPotion, itemName);

	// 5.01 tree: the 5.01 skills lengthen potions as in 5.01 (per alchemy rank, and alchemy_s14 for decoctions).
	if (spectreVanillaSkills())
	{
		skillPassiveMod = CalculateAttributeValue(GetAttributeValue('potion_duration'));
		if (isMutagenPotion && CanUseSkill(S_Alchemy_s14))
		{
			val = GetSkillAttributeValue(S_Alchemy_s14, 'duration', false, true);
			mutagenSkillMod = val.valueMultiplicative * GetSkillLevel(S_Alchemy_s14);
		}
		duration = duration * (1 + skillPassiveMod + mutagenSkillMod);
	}
	return duration;														
}

@addMethod(W3PlayerWitcher) function GetAdaptationToxReduction() : float
{
	var attr : SAbilityAttributeValue;

	// Spectre's Adaptation. The 5.01 skill with this id does something else.
	if(!spectreVanillaAlchemySkills() && CanUseSkill(S_Alchemy_s14))
	{
		attr = GetSkillAttributeValue(S_Alchemy_s14, 'tox_off_bonus', false, false);
		return attr.valueMultiplicative * GetSkillLevel(S_Alchemy_s14);
	}
	else
		return 0;
}

@addMethod(W3PlayerWitcher) function spectreMutation12CanDrinkDecoction() : bool
{
	var min, max : SAbilityAttributeValue;
	var mutagens, metabolisms : array< CBaseGameplayEffect >;
	
	theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation12', 'maxcap', min, max);
	
	metabolisms = spectreGetMutation12Metabolism();

	mutagens = GetDrunkMutagens();

	if((metabolisms.Size() + mutagens.Size()) < min.valueAdditive)
	{
		return true;
	}

	return false;
}

@addMethod(W3PlayerWitcher) function spectreGetMutation12Metabolism() : array<CBaseGameplayEffect>
{
	return effectManager.spectreGetMutation12Metabolism();
}

@wrapMethod(W3PlayerWitcher) function HasFreeToxicityToDrinkPotion( item : SItemUniqueId, effectType : EEffectType, out finalPotionToxicity : float, out toxicityOffset : float, out adrenaline : float ) : bool
{
	var i : int;
	var maxTox, baseToxicity : float;
	var costReduction : SAbilityAttributeValue;
	var isDecoction : bool;

	toxicityOffset = 0;
	adrenaline = 0;

	if( effectType == EET_WhiteHoney )
	{
		return true;
	}

	if(IsMutationActive(EPMT_Mutation12) && spectreMutation12CanDrinkDecoction())
	{
		return true;
	}

	// Alchemy 5.01 variant: 5.01 code (Spectre's Mutation 12 above still applies).
	if (spectreAlchemy501())
		return wrappedMethod(item, effectType, finalPotionToxicity, toxicityOffset, adrenaline);

	finalPotionToxicity = theGame.alchexts.CalculatePotionToxicity(item);
	baseToxicity = finalPotionToxicity;
	isDecoction = effectType >= EET_Mutagen01 && effectType <= EET_Mutagen28;

	if( CanUseSkill( S_Perk_32 ) && !isDecoction )
	{
		costReduction = GetSkillAttributeValue( S_Perk_32, 'cost_reduction', false, true );
		costReduction = costReduction * GetSkillLevel( S_Perk_32 );
		adrenaline = FloorF( GetStat( BCS_Focus ) );
		costReduction = costReduction * adrenaline;
		finalPotionToxicity = ( finalPotionToxicity - costReduction.valueBase ) * ( 1 - costReduction.valueMultiplicative ) - costReduction.valueAdditive;
		finalPotionToxicity = MaxF( 0.f, finalPotionToxicity );
	}

	return (theGame.alchexts.GetTotalToxicity(item) - (baseToxicity - finalPotionToxicity) <= abilityManager.GetStatMax(BCS_Toxicity) );
}

@wrapMethod(W3PlayerWitcher) function DrinkPreparedPotion( slotid : EEquipmentSlots, optional itemId : SItemUniqueId )
{	
	var potion_data		: spectreExtendedPotionData;
	var potionBuffs		: array<CBaseGameplayEffect>;
	var potionBuffIdx	: int;
	var potParams : W3PotionParams;
	var potionParams : SCustomEffectParams;
	var factPotionParams : W3Potion_Fact_Params;
	var adrenaline, hpGainValue, staminaGainValue, duration, finalPotionToxicity, toxicityOffset : float;
	var ret : EEffectInteract;
	var effectType : EEffectType;
	var item : SItemUniqueId;
	var customAbilityName, factId : name;
	var atts : array<name>;
	var i : int;
	var mutagenParams : W3MutagenBuffCustomParams;
	
	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
	{
		wrappedMethod(slotid, itemId);
		return;
	}
	
	
	if(itemId != GetInvalidUniqueId())
		item = itemId; 
	else 
		item = itemSlots[slotid];
	
	
	if(!inv.IsIdValid(item))
		return;
		
	
	if( inv.SingletonItemGetAmmo(item) == 0 )
		return;
		
	
	inv.GetPotionItemBuffData(item, effectType, customAbilityName);
		
	
	if( !HasFreeToxicityToDrinkPotion( item, effectType, finalPotionToxicity, toxicityOffset, adrenaline ) )
	{
		return;
	}
			
	
	if(effectType == EET_Fact)
	{
		inv.GetItemAttributes(item, atts);
		
		for(i=0; i<atts.Size(); i+=1)
		{
			if(StrBeginsWith(NameToString(atts[i]), "fact_"))
			{
				factId = atts[i];
				break;
			}
		}
		
		factPotionParams = new W3Potion_Fact_Params in theGame;
		factPotionParams.factName = factId;
		factPotionParams.potionItemName = inv.GetItemName(item);
		
		potionParams.buffSpecificParams = factPotionParams;
	}
	
	else if(inv.ItemHasTag( item, 'Mutagen' ))
	{
		mutagenParams = new W3MutagenBuffCustomParams in theGame;

		if(IsMutationActive(EPMT_Mutation12) && spectreMutation12CanDrinkDecoction())
		{
			mutagenParams.toxicityOffset = 0;
			theGame.MutationHUDFeedback(MFT_PlayOnce);
		}
		else
		{
			mutagenParams.toxicityOffset = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity_offset'));
		}
		
		mutagenParams.potionItemName = inv.GetItemName(item);
		
		finalPotionToxicity += 0.001f;
		
		potionParams.buffSpecificParams = mutagenParams;
	}
	
	else
	{
		potParams = new W3PotionParams in theGame;
		potParams.potionItemName = inv.GetItemName(item);
		
		potionParams.buffSpecificParams = potParams;
	}

	duration = CalculatePotionDuration(item, inv.ItemHasTag( item, 'Mutagen' ));		
	
	potion_data = new spectreExtendedPotionData in theGame;
	potion_data.effectType = effectType;

	potion_data.duration = theGame.alchexts.CalculatePotionDuration(item, inv.ItemHasTag(item, 'Mutagen') ) + theGame.alchexts.GetEffectRemainingDuration(effectType, "drank_potion");
	potion_data.substance = theGame.alchexts.GetPotionSecondarySubstance(item);
	potion_data.customAbilityName = customAbilityName;
	potion_data.itemName = potParams.potionItemName;
	potion_data.itemid = item;
	potion_data.toxicity = finalPotionToxicity;
	finalPotionToxicity = 0;
	potion_data.buffSpecificParams = (W3PotionParams)potionParams.buffSpecificParams;
	potionParams.buffSpecificParams = potion_data;
	potionParams.effectType = EET_PotionDigestion;
	potionParams.creator = this;

	if(inv.ItemHasTag( item, 'Mutagen' ) && IsMutationActive(EPMT_Mutation12) && spectreMutation12CanDrinkDecoction())
	{
		potionParams.sourceName = "Mutation12" + NameToString(potParams.potionItemName) + IntToString(RandRange(2147483647, 0) );
	}
	else
	{
		potionParams.sourceName = NameToString(potParams.potionItemName) + IntToString(RandRange(2147483647, 0) );
	}

	potionParams.duration = theGame.alchexts.digestion_time * theGame.alchexts.digestion_modifier;
	potionParams.customAbilityName = 'PotionDigestionEffect';
	ret = AddEffectCustom(potionParams);
	
	inv.SingletonItemRemoveAmmo(item);
	
	
	if(ret == EI_Pass || ret == EI_Override || ret == EI_Cumulate)
	{
		if( finalPotionToxicity > 0.f )
		{				
			abilityManager.GainStat(BCS_Toxicity, finalPotionToxicity );

			if ( inv.ItemHasTag( item, 'Mutagen' ) )
			{
				abilityManager.DrainToxicity(finalPotionToxicity);
			}
		}
		
		
		if(CanUseSkill(S_Perk_13) && !inv.ItemHasTag( item, 'Mutagen' ) && effectType != EET_WhiteHoney)
		{
			adrenaline = FloorF(GetStat(BCS_Focus));
			abilityManager.DrainFocus(adrenaline);
		}

		// 5.01: perk_32 spends the Adrenaline Points it used to lower the toxicity (HasFreeToxicityToDrinkPotion).
		if(CanUseSkill(S_Perk_32))
		{
			abilityManager.DrainFocus(adrenaline);
		}
		
		if (!IsEffectActive('invisible'))
		{
			PlayEffect('use_potion');
		}
		
		if ( inv.ItemHasTag( item, 'Mutagen' ) )
		{
			
			theGame.GetGamerProfile().CheckTrialOfGrasses();
			
			
			SetFailedFundamentalsFirstAchievementCondition(true);
		}
		
		
		if(CanUseSkill(S_Alchemy_s02))
		{
			hpGainValue = ClampF(GetStatMax(BCS_Vitality) * CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s02, 'vitality_gain_perc', false, true)) * GetSkillLevel(S_Alchemy_s02), 0, GetStatMax(BCS_Vitality));
			GainStat(BCS_Vitality, hpGainValue);
		}			
		
		
		if(CanUseSkill(S_Alchemy_s04) && !skillBonusPotionEffect && (RandF() < CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s04, 'apply_chance', false, true)) * GetSkillLevel(S_Alchemy_s04)))
		{
			AddRandomPotionEffectFromAlch4Skill( effectType );
		}

		// 5.01 tree: alchemy_s03 lengthens the active potions while toxicity is above its threshold.
		if(spectreVanillaAlchemySkills() && CanUseSkill(S_Alchemy_s03) && GetStat(BCS_Toxicity, true) > GetStatMax(BCS_Toxicity) * GetAlchemyS03Threshold())
		{
			potionBuffs = GetPotionBuffs();
			for(potionBuffIdx = 0; potionBuffIdx < potionBuffs.Size(); potionBuffIdx += 1)
				potionBuffs[potionBuffIdx].DelayedRecoveryPotionDurationIncrease();
		}

		theGame.GetGamerProfile().SetStat(ES_ActivePotions, effectManager.GetPotionBuffsCount());
	}
	
	if (theGame.GetDLCManager().IsDLCAvailable('dlcvhud') 
	&& theGame.GetDLCManager().IsDLCEnabled('dlcvhud') 
	)
	{
		((CR4InventoryMenu)((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild()).PopulateTabData( InventoryMenuTab_Potions );
	}

	theTelemetry.LogWithLabel(TE_ELIXIR_USED, inv.GetItemName(item));
	
	if(ShouldProcessTutorial('TutorialPotionAmmo'))
	{
		FactsAdd("tut_used_potion");
	}
	
	SetFailedFundamentalsFirstAchievementCondition(true);
}

@wrapMethod(W3PlayerWitcher) function AddRandomPotionEffectFromAlch4Skill( currentlyDrankPotion : EEffectType )
{
	// 5.01 alchemy skills: Side Effects as in 5.01. Spectre's alchemy skills have no such skill.
	if (spectreVanillaAlchemySkills())
		wrappedMethod(currentlyDrankPotion);
}

@wrapMethod(W3PlayerWitcher) function HasRunewordActive(abilityName : name) : bool
{
	var item : SItemUniqueId;
	var hasRuneword : bool;
	
	if(false) 
	{
		wrappedMethod(abilityName);
	}
	
	hasRuneword = false;
	
	if(GetItemEquippedOnSlot(EES_SteelSword, item) && (IsItemHeld(item) || abilityName == 'Runeword 5 _Stats' || abilityName == 'Runeword 6 _Stats'))
	{
		hasRuneword = inv.ItemHasAbility(item, abilityName);				
	}
	
	if(!hasRuneword)
	{
		if(GetItemEquippedOnSlot(EES_SilverSword, item) && (IsItemHeld(item) || abilityName == 'Runeword 5 _Stats' || abilityName == 'Runeword 6 _Stats'))
		{
			hasRuneword = inv.ItemHasAbility(item, abilityName);
		}
	}
	
	return hasRuneword;
}

@addMethod(W3PlayerWitcher) function HasGlyphwordActive(abilityName : name) : bool
{
	var item : SItemUniqueId;
	var hasGlyphword : bool;
	
	hasGlyphword = false;
	
	if(GetItemEquippedOnSlot(EES_Armor, item))
	{
		hasGlyphword = inv.ItemHasAbility(item, abilityName);
	}
	
	return hasGlyphword;
}

@wrapMethod(W3PlayerWitcher) function AddRepairObjectBuff(armor : bool, weapon : bool) : bool
{
	var added : bool;
	
	if(false) 
	{
		wrappedMethod(armor, weapon);
	}
	
	added = false;

	if(weapon && (IsAnyItemEquippedOnSlot(EES_SilverSword) || IsAnyItemEquippedOnSlot(EES_SteelSword)) )
	{
		added = super.spectreApplyEnhancement(armor, weapon);
	}
	
	if(armor && (IsAnyItemEquippedOnSlot(EES_Armor) || IsAnyItemEquippedOnSlot(EES_Gloves) || IsAnyItemEquippedOnSlot(EES_Boots) || IsAnyItemEquippedOnSlot(EES_Pants)) )
	{
		added = super.spectreApplyEnhancement(armor, weapon);
	}
	
	/*
	if(weapon)
	{
		AddEffectDefault(EET_EnhancedWeapon, this, "repair_object", false);
		added = true;
	}
	
	if(armor)
	{
		AddEffectDefault(EET_EnhancedArmor, this, "repair_object", false);
		added = true;
	}
	*/

	return added;
}

@wrapMethod(W3PlayerWitcher) function OnTaskSyncAnim( npc : CNewNPC, animNameLeft : name )
{
	var tmpBool : bool;
	var tmpName : name;
	var damage, points, resistance : float;
	var min, max : SAbilityAttributeValue;
	var mc : EMonsterCategory;
	
	if(false) 
	{
		wrappedMethod(npc, animNameLeft);
	}
	
	super.OnTaskSyncAnim( npc, animNameLeft );
	
	if( animNameLeft == 'BruxaBite' && IsMutationActive( EPMT_Mutation4 ) )
	{
		theGame.GetMonsterParamsForActor( npc, mc, tmpName, tmpBool, tmpBool, tmpBool );
		
		if( mc == MC_Vampire )
		{
			GetResistValue( CDS_BleedingRes, points, resistance );
			
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'BleedingEffect', 'DirectDamage', min, max );
			damage = MaxF( 0.f, max.valueMultiplicative * GetMaxHealth() - points );
			
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'BleedingEffect', 'duration', min, max );
			damage *= min.valueAdditive * ( 1 - MinF( 1.f, resistance ) );
			
			if( damage > 0.f )
			{
				ProcessActionMutation4ReturnedDamage( damage, npc, EAHA_ForceNo );					
			}
		}
	}
}

@wrapMethod(W3PlayerWitcher) function ProcessActionMutation4ReturnedDamage( damageDealt : float, attacker : CActor, hitAnimationType : EActionHitAnim, optional action : W3DamageAction ) : bool
{
	var customParams				: SCustomEffectParams;
	var currToxicity				: float;
	var min, max, customDamageValue	: SAbilityAttributeValue;
	var dm							: CDefinitionsManagerAccessor;
	var animAction					: W3DamageAction;
	var customDuration				: float;
	
	if(false) 
	{
		wrappedMethod(damageDealt, attacker, hitAnimationType, action);
	}

	if( damageDealt <= 0 )
	{
		return false;
	}
	
	currToxicity = GetStat( BCS_Toxicity );

	if( currToxicity <= 0 )
	{
		return false;
	}
	
	dm = theGame.GetDefinitionsManager();
	dm.GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
	customDamageValue.valueAdditive = currToxicity * min.valueAdditive;
	dm.GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
	customDuration = min.valueAdditive;
	
	if( customDamageValue.valueAdditive <= 0 || customDuration <= 0 )
	{
		return false;
	}
	
	if( action )
	{
		action.SetMutation4Triggered();
	}
	
	customParams.effectType = EET_Acid;
	customParams.effectValue = customDamageValue;
	customParams.duration = customDuration;
	customParams.creator = this;
	customParams.sourceName = 'Mutation4';
	
	attacker.AddEffectCustom( customParams );
	
	
	animAction = new W3DamageAction in theGame;
	animAction.Initialize( this, attacker, NULL, 'Mutation4', EHRT_Reflect, CPS_Undefined, true, false, false, false );
	animAction.SetCannotReturnDamage( true );
	animAction.SetCanPlayHitParticle( false );
	animAction.SetHitAnimationPlayType( hitAnimationType );
	theGame.damageMgr.ProcessAction( animAction );
	delete animAction;
	
	theGame.MutationHUDFeedback( MFT_PlayOnce );
	
	return true;
}

@wrapMethod(W3PlayerWitcher) function OnCombatActionEnd()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	this.CleanCombatActionBuffer();		
	super.OnCombatActionEnd();
}

@wrapMethod(W3PlayerWitcher) function GetPowerStatValue( stat : ECharacterPowerStats, optional ablName : name, optional ignoreDeath : bool ) : SAbilityAttributeValue
{
	var result :  SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod( stat, ablName, ignoreDeath ) ;
	}
	
	result = super.GetPowerStatValue( stat, ablName, ignoreDeath );

	return result;
}

@wrapMethod(W3PlayerWitcher) function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool
{
	var pam : W3PlayerAbilityManager;
	var i : int;

	if(false) 
	{
		wrappedMethod( damageAction, buffNotApplied ) ;
	}
	
	if(IsThrowingItem() || IsThrowingItemWithAim())
	{
		if(!damageAction.IsDoTDamage() && damageAction.DealsAnyDamage() && damageAction.GetHitAnimationPlayType() != EAHA_ForceNo)
		{
			if(inv.IsItemBomb(selectedItemId))
			{
				BombThrowAbort();
			}
			else
			{
				ThrowingAbort();
			}			
		}
	}
	
	if( !((W3Effect_Toxicity)damageAction.causer) )
		MeditationForceAbort(true);
	
	
	if(IsDoingSpecialAttack(false))
		damageAction.SetHitAnimationPlayType(EAHA_ForceNo);

	if(damageAction.DealtDamage())
	{
		ResetSkillComboCounter(S_Sword_s24);
		StopAllSkillComboEffectsEx(S_Sword_s24, PreciseBlowsCounterId_Fast);
		StopAllSkillComboEffectsEx(S_Sword_s24, PreciseBlowsCounterId_Strong);
	}
	if(CanUseSkill(S_Sword_s19) && tempLearnedSignSkills.Size() > 0)
	{
		pam = (W3PlayerAbilityManager)abilityManager;
		for(i=0; i<tempLearnedSignSkills.Size(); i+=1)
			pam.RemoveTemporarySkill(tempLearnedSignSkills[i]);
		tempLearnedSignSkills.Clear();
		RemoveAbilityAll(SkillEnumToName(S_Sword_s19));
	}
	
	return super.ReactToBeingHit(damageAction, buffNotApplied);
}

@wrapMethod(W3PlayerWitcher) function ShouldPauseHealthRegenOnHit() : bool
{
	if(false) 
	{
		wrappedMethod();
	}
	
	if( ( HasBuff( EET_Swallow ) && GetPotionBuffLevel( EET_Swallow ) >= 3 ) || HasBuff( EET_Runeword8 ) || HasBuff( EET_Mutation11Buff ) || HasBuff( EET_UndyingSkillImmortal ) )
	{
		return false;
	}
		
	return true;
}

@wrapMethod(W3PlayerWitcher) function CalculatedArmorStaminaRegenBonus() : float
{
	var armorEq, glovesEq, pantsEq, bootsEq : bool;
	var armorId, glovesId, pantsId, bootsId : SItemUniqueId;
	var staminaRegenVal : float;
	var armorRegenVal : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(!spectreArmorRegenPenaltyOn())
		return 0.0f;
	
	armorRegenVal = GetAttributeValue('staminaRegen_armor_mod');
	staminaRegenVal = armorRegenVal.valueMultiplicative;

	armorEq = inv.GetItemEquippedOnSlot( EES_Armor, armorId );
	glovesEq = inv.GetItemEquippedOnSlot( EES_Gloves, glovesId );
	pantsEq = inv.GetItemEquippedOnSlot( EES_Pants, pantsId );
	bootsEq = inv.GetItemEquippedOnSlot( EES_Boots, bootsId );
	
	if ( !armorEq )
		staminaRegenVal += 0.11;
	if ( !glovesEq )
		staminaRegenVal += 0.02;
	if ( !pantsEq )
		staminaRegenVal += 0.03;
	if ( !bootsEq )
		staminaRegenVal += 0.04;

	return staminaRegenVal;
}

@wrapMethod(W3PlayerWitcher) function GetOffenseStatsList( optional hackMode : int ) : SPlayerOffenseStats
{
	var playerOffenseStats : SPlayerOffenseStats;
	var min, max, value : SAbilityAttributeValue;
	var attackPower : SAbilityAttributeValue;
	var fastAPBonus, strongAPBonus, steelAPBonus, silverAPBonus : SAbilityAttributeValue;
	var critChance, critPowerBonus, fastCritChanceBonus, strongCritChanceBonus, fastCritPowerBonus, strongCritPowerBonus : float;
	var steelCritChanceBonus, silverCritChanceBonus, steelCritPowerBonus, silverCritPowerBonus : float;
	var steelDmg, silverDmg, elementalSteel, elementalSilver : float;
	var attackPowerCrossbow : SAbilityAttributeValue;
	var silverSword, steelSword, crossbow, bolt : SItemUniqueId;
	var mutagen : CBaseGameplayEffect;
	var thunder : W3Potion_Thunderbolt;
	var strongDmgMult, bonusDmgMult, bonusDmgCrossbow, bonusDmgMultCrossbow, bonusDmgMultSteel, bonusDmgMultSilver : float;
	var steelFastAP, silverFastAP, steelStrongAP, silverStrongAP, steelFastCritAP, silverFastCritAP, steelStrongCritAP, silverStrongCritAP : SAbilityAttributeValue;
	var steelFastCritChance, silverFastCritChance, steelStrongCritChance, silverStrongCritChance : float;
	var heightenedToleranceCritBonus : SAbilityAttributeValue;

	// Both trees: Spectre's damage code deals the damage with either tree, so the stats follow it.
	if(false)
	{
		wrappedMethod(hackMode);
	}

	if(!abilityManager || !abilityManager.IsInitialized())
		return playerOffenseStats;
	
	value = GetSkillAttributeValue(S_Sword_2, 'heavy_attack_dmg_boost', false, true);
	strongDmgMult = 1 + value.valueMultiplicative;

	attackPower = GetPowerStatValue(CPS_AttackPower);

	if(IsSetBonusActive(EISB_Bear_1))
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetSetBonusAbility(EISB_Bear_1), 'attack_power', min, max);
		attackPower.valueMultiplicative += min.valueMultiplicative * GetSetPartsEquipped(EIST_Bear) * FloorF(GetStat(BCS_Focus));
	}
	critChance = CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_CHANCE));
	critPowerBonus = CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
	// As the damage code: the 5.01 Cat School's critical damage and Heightened Tolerance.
	critPowerBonus += CalculateAttributeValue(GetAttributeValue('critical_hit_chance_fast_style'));
	AccumulateHeightenedToleranceCritBonus(heightenedToleranceCritBonus);
	critPowerBonus += CalculateAttributeValue(heightenedToleranceCritBonus);

	fastAPBonus = GetSkillAttributeValue(S_Sword_1, PowerStatEnumToName(CPS_AttackPower), false, true);
	strongAPBonus = GetSkillAttributeValue(S_Sword_2, PowerStatEnumToName(CPS_AttackPower), false, true);
	// The school techniques' bonuses for fast and strong attacks (attackAction_AN.ws).
	fastAPBonus += GetAttributeValue('attack_power_fast_style');
	strongAPBonus += GetAttributeValue('attack_power_heavy_style');
	if (CanUseSkill(S_Sword_s21))
		fastAPBonus += GetSkillAttributeValue(S_Sword_s21, PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s21); 
	if (CanUseSkill(S_Sword_s04))
		strongAPBonus += GetSkillAttributeValue(S_Sword_s04, PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s04);
	if (HasBuff(EET_LynxSetBonus))
	{
		fastAPBonus.valueMultiplicative += ((W3Effect_LynxSetBonus)GetBuff(EET_LynxSetBonus)).GetLynxBonus(false);
		strongAPBonus.valueMultiplicative += ((W3Effect_LynxSetBonus)GetBuff(EET_LynxSetBonus)).GetLynxBonus(true);
	}
	if (CanUseSkill(S_Sword_s17)) 
	{
		fastCritChanceBonus = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s17);
		fastCritPowerBonus = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s17);
	}
	if (CanUseSkill(S_Sword_s08)) 
	{
		strongCritChanceBonus = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s08);
		strongCritPowerBonus = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s08);
	}
	
	if (GetItemEquippedOnSlot(EES_SteelSword, steelSword))
	{
		steelDmg = GetTotalWeaponDamage(steelSword, theGame.params.DAMAGE_NAME_SLASHING, GetInvalidUniqueId());
		steelDmg += GetTotalWeaponDamage(steelSword, theGame.params.DAMAGE_NAME_PIERCING, GetInvalidUniqueId());
		steelDmg += GetTotalWeaponDamage(steelSword, theGame.params.DAMAGE_NAME_BLUDGEONING, GetInvalidUniqueId());
		elementalSteel = CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.DAMAGE_NAME_FIRE));
		elementalSteel += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.DAMAGE_NAME_FROST)); 
		elementalSteel += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.DAMAGE_NAME_POISON)); 
		if (!GetInventory().IsItemHeld(steelSword))
		{
			steelCritChanceBonus += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.CRITICAL_HIT_CHANCE));
			steelCritPowerBonus += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			steelAPBonus += GetInventory().GetItemAttributeValue(steelSword, 'attack_power');
		}
		bonusDmgMultSteel += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, 'sword_dmg_bonus'));
		steelCritChanceBonus += CalculateAttributeValue(inv.GetOilCriticalChanceBonus(steelSword, MC_NotSet));
		steelCritPowerBonus += CalculateAttributeValue(inv.GetOilCriticalDamageBonus(steelSword, MC_NotSet));
	}

	if (GetItemEquippedOnSlot(EES_SilverSword, silverSword))
	{
		silverDmg = GetTotalWeaponDamage(silverSword, theGame.params.DAMAGE_NAME_SILVER, GetInvalidUniqueId());
		elementalSilver = CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.DAMAGE_NAME_FIRE));
		elementalSilver += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.DAMAGE_NAME_FROST));
		elementalSilver += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.DAMAGE_NAME_POISON)); 
	
		{
			silverCritChanceBonus += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.CRITICAL_HIT_CHANCE));
			silverCritPowerBonus += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			silverAPBonus += GetInventory().GetItemAttributeValue(silverSword, 'attack_power');
		}
		
		bonusDmgMultSilver += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, 'sword_dmg_bonus'));
		
		silverCritChanceBonus += CalculateAttributeValue(inv.GetOilCriticalChanceBonus(silverSword, MC_NotSet));
		silverCritPowerBonus += CalculateAttributeValue(inv.GetOilCriticalDamageBonus(silverSword, MC_NotSet));
	}
	
	if (GetInventory().IsItemHeld(steelSword))
	{
		silverCritChanceBonus -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.CRITICAL_HIT_CHANCE));
		silverCritPowerBonus -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		silverAPBonus -= GetInventory().GetItemAttributeValue(steelSword, 'attack_power');
	}
	if (GetInventory().IsItemHeld(silverSword))
	{
		steelCritChanceBonus -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.CRITICAL_HIT_CHANCE));
		steelCritPowerBonus -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		steelAPBonus -= GetInventory().GetItemAttributeValue(silverSword, 'attack_power');
	}

	thunder = (W3Potion_Thunderbolt)GetBuff(EET_Thunderbolt);
	if(thunder && thunder.GetBuffLevel() == 3 && GetCurWeather() == EWE_Storm)
	{
		critPowerBonus += 1.0f;
	}
	

	if(HasGlyphwordActive('Glyphword 4 _Stats'))
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 4 _Stats', 'glyphword4_mod', min, max);
		bonusDmgMult += CalculateAttributeValue(min);
	}

	if(HasBuff(EET_Mutation10))
	{
		steelDmg += GetToxicityDamage();
		silverDmg += GetToxicityDamage();
	}
	
	steelFastAP = attackPower + fastAPBonus + steelAPBonus;
	silverFastAP = attackPower + fastAPBonus + silverAPBonus;
	steelStrongAP = attackPower + strongAPBonus + steelAPBonus;
	silverStrongAP = attackPower + strongAPBonus + silverAPBonus;
	steelFastCritAP = steelFastAP;
	steelFastCritAP.valueMultiplicative += critPowerBonus + fastCritPowerBonus + steelCritPowerBonus;
	silverFastCritAP = silverFastAP;
	silverFastCritAP.valueMultiplicative += critPowerBonus + fastCritPowerBonus + silverCritPowerBonus;
	steelStrongCritAP = steelStrongAP;
	steelStrongCritAP.valueMultiplicative += critPowerBonus + strongCritPowerBonus + steelCritPowerBonus;
	silverStrongCritAP = silverStrongAP;
	silverStrongCritAP.valueMultiplicative += critPowerBonus + strongCritPowerBonus + silverCritPowerBonus;
	steelFastCritChance = critChance + fastCritChanceBonus + steelCritChanceBonus;
	silverFastCritChance = critChance + fastCritChanceBonus + silverCritChanceBonus;
	steelStrongCritChance = critChance + strongCritChanceBonus + steelCritChanceBonus;
	silverStrongCritChance = critChance + strongCritChanceBonus + silverCritChanceBonus;
	
	playerOffenseStats.steelFastAP = steelFastAP.valueMultiplicative;
	playerOffenseStats.silverFastAP = silverFastAP.valueMultiplicative;
	playerOffenseStats.steelStrongAP = steelStrongAP.valueMultiplicative;
	playerOffenseStats.silverStrongAP = silverStrongAP.valueMultiplicative;
	playerOffenseStats.steelFastCritAP = steelFastCritAP.valueMultiplicative;
	playerOffenseStats.silverFastCritAP = silverFastCritAP.valueMultiplicative;
	playerOffenseStats.steelStrongCritAP = steelStrongCritAP.valueMultiplicative;
	playerOffenseStats.silverStrongCritAP = silverStrongCritAP.valueMultiplicative;
	playerOffenseStats.steelFastCritChance = steelFastCritChance * 100;
	playerOffenseStats.silverFastCritChance = silverFastCritChance * 100;
	playerOffenseStats.steelStrongCritChance = steelStrongCritChance * 100;
	playerOffenseStats.silverStrongCritChance = silverStrongCritChance * 100;
	if ( steelDmg != 0 )
	{
		playerOffenseStats.steelFastDmg = ((steelDmg + elementalSteel) * (1 + bonusDmgMult + bonusDmgMultSteel) + steelFastAP.valueBase) * steelFastAP.valueMultiplicative + steelFastAP.valueAdditive;
		playerOffenseStats.steelFastCritDmg = ((steelDmg + elementalSteel) * (1 + bonusDmgMult + bonusDmgMultSteel) + steelFastCritAP.valueBase) * steelFastCritAP.valueMultiplicative + steelFastCritAP.valueAdditive;
		playerOffenseStats.steelFastDPS = playerOffenseStats.steelFastDmg * (1 - steelFastCritChance) + playerOffenseStats.steelFastCritDmg * steelFastCritChance;
		playerOffenseStats.steelStrongDmg = ((steelDmg + elementalSteel) * (strongDmgMult + bonusDmgMult + bonusDmgMultSteel) + steelStrongAP.valueBase) * steelStrongAP.valueMultiplicative + steelStrongAP.valueAdditive;
		playerOffenseStats.steelStrongCritDmg = ((steelDmg + elementalSteel) * (strongDmgMult + bonusDmgMult + bonusDmgMultSteel) + steelStrongCritAP.valueBase) * steelStrongCritAP.valueMultiplicative + steelStrongCritAP.valueAdditive;
		playerOffenseStats.steelStrongDPS = playerOffenseStats.steelStrongDmg * (1 - steelStrongCritChance) + playerOffenseStats.steelStrongCritDmg * steelStrongCritChance;
	}
	if ( silverDmg != 0 )
	{
		playerOffenseStats.silverFastDmg = ((silverDmg + elementalSilver) * (1 + bonusDmgMult + bonusDmgMultSilver) + silverFastAP.valueBase) * silverFastAP.valueMultiplicative + silverFastAP.valueAdditive;
		playerOffenseStats.silverFastCritDmg = ((silverDmg + elementalSilver) * (1 + bonusDmgMult + bonusDmgMultSilver) + silverFastCritAP.valueBase) * silverFastCritAP.valueMultiplicative + silverFastCritAP.valueAdditive;
		playerOffenseStats.silverFastDPS = playerOffenseStats.silverFastDmg * (1 - silverFastCritChance) + playerOffenseStats.silverFastCritDmg * silverFastCritChance;
		playerOffenseStats.silverStrongDmg = ((silverDmg + elementalSilver) * (strongDmgMult + bonusDmgMult + bonusDmgMultSilver) + silverStrongAP.valueBase) * silverStrongAP.valueMultiplicative + silverStrongAP.valueAdditive;
		playerOffenseStats.silverStrongCritDmg = ((silverDmg + elementalSilver) * (strongDmgMult + bonusDmgMult + bonusDmgMultSilver) + silverStrongCritAP.valueBase) * silverStrongCritAP.valueMultiplicative + silverStrongCritAP.valueAdditive;
		playerOffenseStats.silverStrongDPS = playerOffenseStats.silverStrongDmg * (1 - silverStrongCritChance) + playerOffenseStats.silverStrongCritDmg * silverStrongCritChance;
	}
	
	playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_PIERCING;
	playerOffenseStats.crossbowElementaDmgType = '';
	if (GetItemEquippedOnSlot(EES_RangedWeapon, crossbow))
	{
		attackPowerCrossbow = attackPower + GetInventory().GetItemAttributeValue(crossbow, PowerStatEnumToName(CPS_AttackPower));
		playerOffenseStats.crossbowAttackPower = attackPowerCrossbow.valueMultiplicative;
		playerOffenseStats.crossbowCritChance = GetCriticalHitChance( false, false, NULL, MC_NotSet, true );

		value = GetCriticalHitDamageBonus( crossbow, MC_NotSet, false ) + inv.GetItemAttributeValue( crossbow, theGame.params.CRITICAL_HIT_DAMAGE_BONUS );
		if( IsMutationActive( EPMT_Mutation9 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'critical_damage', min, max );
			value += min;
		}
		if( CanUseSkill(S_Sword_s07) )
		{
			value += GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * GetSkillLevel(S_Sword_s07);
		}
		playerOffenseStats.crossbowCritDmgBonus = CalculateAttributeValue(value);

		if (GetItemEquippedOnSlot(EES_Bolt, bolt))
		{
			playerOffenseStats.crossbowSteelDmgType = GetCrossbowSteelDmgName();
			inv.GetItemStatByName(inv.GetItemName(bolt), playerOffenseStats.crossbowSteelDmgType, playerOffenseStats.crossbowSteelDmg);
			inv.GetItemStatByName(inv.GetItemName(bolt), 'SilverDamage', playerOffenseStats.crossbowSilverDmg);
			playerOffenseStats.crossbowElementaDmgType = GetCrossbowElementaDmgName();
			if(IsNameValid(playerOffenseStats.crossbowElementaDmgType))
				inv.GetItemStatByName(inv.GetItemName(bolt), playerOffenseStats.crossbowElementaDmgType, playerOffenseStats.crossbowElementaDmg);
		}

		if( CanUseSkill(S_Sword_s15) )
		{
			bonusDmgCrossbow += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s15, 'xbow_dmg_bonus', false, true)) * GetSkillLevel(S_Sword_s15);
		}
		
		playerOffenseStats.crossbowSteelDmg += bonusDmgCrossbow;
		playerOffenseStats.crossbowSilverDmg += bonusDmgCrossbow;
		playerOffenseStats.crossbowElementaDmg += bonusDmgCrossbow;

		if( IsMutationActive( EPMT_Mutation9 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'mut9_damage', min, max);
			playerOffenseStats.crossbowSteelDmg *= 1 + min.valueMultiplicative;
			playerOffenseStats.crossbowSilverDmg *= 1 + min.valueMultiplicative;
			playerOffenseStats.crossbowElementaDmg *= 1 + min.valueMultiplicative;
		}
		
		playerOffenseStats.crossbowSteelDmg = (playerOffenseStats.crossbowSteelDmg * (1 + bonusDmgMultCrossbow) + attackPowerCrossbow.valueBase) * attackPowerCrossbow.valueMultiplicative;
		playerOffenseStats.crossbowSilverDmg = (playerOffenseStats.crossbowSilverDmg * (1 + bonusDmgMultCrossbow) + attackPowerCrossbow.valueBase) * attackPowerCrossbow.valueMultiplicative;
		playerOffenseStats.crossbowElementaDmg = (playerOffenseStats.crossbowElementaDmg * (1 + bonusDmgMultCrossbow) + attackPowerCrossbow.valueBase) * attackPowerCrossbow.valueMultiplicative;
	}
	
	return playerOffenseStats;
}



@wrapMethod(W3PlayerWitcher) function HasRecentlyCountered() : bool
{
	return wrappedMethod();
}

@wrapMethod(W3PlayerWitcher) function SetRecentlyCountered(counter : bool)
{
	wrappedMethod(counter);
}

@addMethod(W3PlayerWitcher) timer function spectreRemoveTempSkillsDelay ( dt : float, id : int)
{
	// Flood of Anger lasts the whole sign, as in 5.01: a channeled sign keeps it while it is held.
	if ( IsCastingSign() )
	{
		AddTimer('spectreRemoveTempSkillsDelay', 0.1, false);
		return;
	}
	RemoveTemporarySkills();
}


@wrapMethod(W3PlayerWitcher) function RemoveTemporarySkills()
{
	var i : int;
	var pam : W3PlayerAbilityManager;

	// 5.01 tree: 5.01 code (waits for the sign to end and clears the supercharged sign).
	if (spectreVanillaSkills())
	{
		wrappedMethod();
		return;
	}

	if(tempLearnedSignSkills.Size() > 0)
	{
		pam = (W3PlayerAbilityManager)abilityManager;
		for(i=0; i<tempLearnedSignSkills.Size(); i+=1)
		{
			pam.RemoveTemporarySkill(tempLearnedSignSkills[i]);
		}
		
		tempLearnedSignSkills.Clear();						
	}
	RemoveAbilityAll(SkillEnumToName(S_Sword_s19));
}

@wrapMethod(W3PlayerWitcher) function RemoveTemporarySkill(skill : SSimpleSkill) : bool
{
	var pam : W3PlayerAbilityManager;
	
	if(false) 
	{
		wrappedMethod(skill);
	}
	
	pam = (W3PlayerAbilityManager)abilityManager;
	if(pam && pam.IsInitialized())
		return pam.RemoveTemporarySkill(skill);
		
	return false;
}

@wrapMethod(W3PlayerWitcher) function AddTemporarySkills()
{
	// 5.01 tree: 5.01 code.
	if (spectreVanillaSkills())
	{
		wrappedMethod();
		// sword_s19 holds Spectre's 0.25 Sign Intensity per rank; 5.01 gives 0.5 (spectre_vanilla_sword_s19).
		// The 5.01 code removes it by name, so it is added twice per rank instead of using the copy.
		if (HasAbility('sword_s19'))
		{
			RemoveAbilityAll('sword_s19');
			AddAbilityMultiple('sword_s19', 2 * GetSkillLevel(S_Sword_s19));
		}
		return;
	}

	// Spectre's tree: Flood of Anger is applied by the sign itself (W3SignEntity.InitFoA).
	// Doing it here too (the 5.0 Aard finisher calls this) lost the list of temporary skills.
}

@addMethod(W3PlayerWitcher) function AddTemporarySkills_Public() : bool
{
	tempLearnedSignSkills.Clear();
	if(CanUseSkill(S_Sword_s19) && GetStat(BCS_Focus) >= 3)
	{
		tempLearnedSignSkills = ((W3PlayerAbilityManager)abilityManager).AddTempNonAlchemySkills();
		AddAbilityMultiple(SkillEnumToName(S_Sword_s19), GetSkillLevel(S_Sword_s19));

		RemoveTimer('spectreRemoveTempSkillsDelay');
		AddTimer('spectreRemoveTempSkillsDelay', 1, false);
		// Also with every Signs skill already at its maximum: the intensity still applies and costs.
		return true;
	}
	return false;
}

@replaceMethod(W3PlayerWitcher) function QuenImpulse( isAlternate : bool, signEntity : W3QuenEntity, source : string, optional forceSkillLevel : int )
{
	var level, i, j : int;
	var atts, damages : array<name>;
	var ents : array<CGameplayEntity>;
	var action : W3DamageAction;
	var dm : CDefinitionsManagerAccessor;
	var skillAbilityName : name;
	var dmg : float;
	var min, max : SAbilityAttributeValue;
	var pos : Vector;
	var spellPower : SAbilityAttributeValue;
	var staminaPrc : float;
	
	if(forceSkillLevel > 0)
		level = forceSkillLevel;
	else
		level = GetSkillLevel(S_Magic_s13);

	spellPower = signEntity.GetQuenPower();
	if(spellPower.valueMultiplicative <= 0)
		spellPower = GetTotalSignSpellPower(S_Magic_4);
	
	dm = theGame.GetDefinitionsManager();
	skillAbilityName = GetSkillAbilityName(S_Magic_s13);

	if(level >= 2)
	{
		dm.GetAbilityAttributes(skillAbilityName, atts);
		for(i = 0; i < atts.Size(); i += 1)
		{
			if(IsDamageTypeNameValid(atts[i]))
				damages.PushBack(atts[i]);
		}
	}

	FindGameplayEntitiesInRange(ents, this, 3, 100, , FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile, this);
	
	for(i = 0; i < ents.Size(); i += 1)
	{
		action = new W3DamageAction in theGame;
		action.Initialize(this, ents[i], signEntity, source, EHRT_Light, CPS_SpellPower, false, false, true, false);
		action.SetSignSkill(S_Magic_s13);
		action.SetCannotReturnDamage(true);
		action.SetProcessBuffsIfNoDamage(true);

		if(level >= 2)
		{
			for(j = 0; j < damages.Size(); j += 1)
			{
				dm.GetAbilityAttributeValue(skillAbilityName, damages[j], min, max);
				dmg = CalculateAttributeValue(GetAttributeRandomizedValue(min, max)) * (level - 1);
				if( HasGlyphwordActive( 'Glyphword 5 _Stats' ) )
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Glyphword 5 _Stats', 'glyphword5_dmg_boost', min, max );
					dmg *= 1 + min.valueMultiplicative;
				}

				if(dmg > 0)
				{
					action.SetHitEffectAllTypes('hit_electric_quen');
					action.AddDamage(damages[j], dmg);
				}
			}
		}
		
		if(level == 3)
			action.AddEffectInfo(EET_KnockdownTypeApplicator);
		else if(level >= 1)
			action.AddEffectInfo(EET_Stagger);
		
		theGame.damageMgr.ProcessAction( action );
		delete action;
	}
	
	if(isAlternate)
	{
		signEntity.PlayHitEffect('quen_impulse_explode', signEntity.GetWorldRotation());
		signEntity.EraseFirstTimeStamp();
		
		if(level >= 2)
		{
			signEntity.PlayHitEffect('quen_electric_explode', signEntity.GetWorldRotation());
		}
	}
	else
	{
		signEntity.PlayEffect('lasting_shield_impulse');
	}
}

@addMethod(W3PlayerWitcher) function PlayGlyphword5FX(ent : CGameplayEntity)
{
	var template : CEntityTemplate;
	var component : CComponent;
	
	template = (CEntityTemplate)LoadResource('glyphword_5');
	
	component = ent.GetComponent('torso3effect');
	if(component)
		thePlayer.PlayEffect('reflection_damge', component);
	else
		thePlayer.PlayEffect('reflection_damge', ent);
}

@wrapMethod(W3PlayerWitcher) function OnSignCastPerformed(signType : ESignType, isAlternate : bool)
{
	var items : array<SItemUniqueId>;
	var weaponEnt : CEntity;
	var fxName : name;
	var pos : Vector;
	
	if(false) 
	{
		wrappedMethod(signType, isAlternate);
	}
	
	super.OnSignCastPerformed(signType, isAlternate);
	
	if(HasRunewordActive('Runeword 1 _Stats') && GetStat(BCS_Focus) >= 1.0f) 
	{
		DrainFocus(1.0f);
		runewordInfusionType = signType;
		items = inv.GetHeldWeapons();
		weaponEnt = inv.GetItemEntityUnsafe(items[0]);
		
		
		weaponEnt.StopEffect('runeword_aard');
		weaponEnt.StopEffect('runeword_axii');
		weaponEnt.StopEffect('runeword_igni');
		weaponEnt.StopEffect('runeword_quen');
		weaponEnt.StopEffect('runeword_yrden');
				
		
		if(signType == ST_Aard)
			fxName = 'runeword_aard';
		else if(signType == ST_Axii)
			fxName = 'runeword_axii';
		else if(signType == ST_Igni)
			fxName = 'runeword_igni';
		else if(signType == ST_Quen)
			fxName = 'runeword_quen';
		else if(signType == ST_Yrden)
			fxName = 'runeword_yrden';
			
		weaponEnt.PlayEffect(fxName);
	}
	
	
	if( IsMutationActive( EPMT_Mutation6 ) && signType == ST_Aard && !isAlternate )
	{
		pos = GetWorldPosition() + GetWorldForward() * 2;
		
		theGame.GetSurfacePostFX().AddSurfacePostFXGroup( pos, 0.f, 3.f, 2.f, 5.f, 0 );
	}

	if(!HasBuff(EET_GryphonSetBonus) && IsSetBonusActive( EISB_Gryphon_1 ))
	{
		AddEffectDefault( EET_GryphonSetBonus, NULL, signType );
	}
}

@wrapMethod(W3PlayerWitcher) function GetTotalSignSpellPower(signSkill : ESkill) : SAbilityAttributeValue
{
	var sp : SAbilityAttributeValue;
	var penalty : SAbilityAttributeValue;
	var penaltyReduction : float;
	var penaltyReductionLevel : int; 
	var mutagen : CBaseGameplayEffect;
	var min, max : SAbilityAttributeValue;

	if(false) 
	{
		wrappedMethod(signSkill);
	}
	
	sp = GetSkillAttributeValue(signSkill, PowerStatEnumToName(CPS_SpellPower), true, true);
	
	if ( signSkill == S_Magic_s01 && spectreVanillaSkills() )
	{
		// 5.01 tree: Aard Sweep's penalty as in 5.01.
		penaltyReductionLevel = GetSkillLevel(S_Magic_s01) + 1;
		if(penaltyReductionLevel > 0)
		{
			penaltyReduction = 1 - penaltyReductionLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Magic_s01, 'spell_power_penalty_reduction', true, true));
			penalty = GetSkillAttributeValue(S_Magic_s01, PowerStatEnumToName(CPS_SpellPower), false, false);
			sp += penalty * penaltyReduction;
		}
	}
	else if ( signSkill == S_Magic_s01 )
	{
		penaltyReductionLevel = GetSkillLevel(S_Magic_s01) - 1;
		if(penaltyReductionLevel > 0)
		{
			penaltyReduction = penaltyReductionLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Magic_s01, 'spell_power_penalty_reduction', false, false));
			sp.valueMultiplicative += penaltyReduction;
		}
	}
	
	
	if(signSkill == S_Magic_1 || signSkill == S_Magic_s01)
	{
		sp += GetAttributeValue('spell_power_aard');
	}
	else if(signSkill == S_Magic_2 || signSkill == S_Magic_s02 || signSkill == S_Magic_s28)
	{
		sp += GetAttributeValue('spell_power_igni');
	}
	else if(signSkill == S_Magic_3 || signSkill == S_Magic_s03)
	{
		sp += GetAttributeValue('spell_power_yrden');
	}
	else if(signSkill == S_Magic_4 || signSkill == S_Magic_s04)
	{
		sp += GetAttributeValue('spell_power_quen');
	}
	else if(signSkill == S_Magic_5 || signSkill == S_Magic_s05 || signSkill == S_Magic_s31)
	{
		sp += GetAttributeValue('spell_power_axii');
	}
	
	sp.valueBase = MaxF(sp.valueBase, 0);
	sp.valueMultiplicative = MaxF(sp.valueMultiplicative, 0);
	sp.valueAdditive = MaxF(sp.valueAdditive, 0);

	return sp;
}

@wrapMethod(W3PlayerWitcher) function Runeword10Triggerred()
{
	var min, max : SAbilityAttributeValue; 
	
	if(false) 
	{
		wrappedMethod();
	}
	
	theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 10 _Stats', 'health', min, max );
	GainStat(BCS_Vitality, min.valueMultiplicative * GetStatMax(BCS_Vitality));
	PlayEffect('runeword_10_stamina');
}

@wrapMethod(W3PlayerWitcher) function Runeword12Triggerred()
{
	var min, max : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 12 _Stats', 'focus', min, max );
	GainStat(BCS_Focus, min.valueAdditive);
	PlayEffect('runeword_20_adrenaline');	
}

@addMethod(W3PlayerWitcher) function spectreDebug_RestoreMutagensSpent()
{
	var total : array<int>;
	
	total = ((W3PlayerAbilityManager)abilityManager).spectreGetMutationsUsedMutagens();
	
	if(total[0] > 0) inv.AddAnItem('Greater mutagen red', total[0]);
	if(total[1] > 0) inv.AddAnItem('Greater mutagen blue', total[1]);
	if(total[2] > 0) inv.AddAnItem('Greater mutagen green', total[2]);
}

@wrapMethod(W3PlayerWitcher) function Debug_ClearCharacterDevelopment( optional resetLevels : bool )
{
	var template : CEntityTemplate;
	var entity : CEntity;
	var invTesting : CInventoryComponent;
	var i, totalExp, currentLevel, totalSkillPoints : int;
	var items : array<SItemUniqueId>;
	var abs : array<name>;
	var isMutationSystemEnabled : bool;
	var weaponId : SItemUniqueId;	

	if(false) 
	{
		wrappedMethod(resetLevels);
	}	
	
	ForceSetStat(BCS_Toxicity, 0);
	if(GetItemEquippedOnSlot(EES_SilverSword, weaponId))
	{
		if(inv.CanItemHaveOil(weaponId))
		{
			inv.RemoveAllOilsFromItem(weaponId);
			inv.RemoveAllOilAbilitiesFromItem(weaponId);
		}
	}
	
	if(GetItemEquippedOnSlot(EES_SteelSword, weaponId))
	{
		if(inv.CanItemHaveOil(weaponId))
		{
			inv.RemoveAllOilsFromItem(weaponId);
			inv.RemoveAllOilAbilitiesFromItem(weaponId);
		}
	}
	
	UnequipItemFromSlot(EES_SilverSword);
	UnequipItemFromSlot(EES_SteelSword);
	UnequipItemFromSlot(EES_Bolt);
	UnequipItemFromSlot(EES_RangedWeapon);
	UnequipItemFromSlot(EES_Armor);
	UnequipItemFromSlot(EES_Boots);
	UnequipItemFromSlot(EES_Pants);
	UnequipItemFromSlot(EES_Gloves);
	UnequipItemFromSlot(EES_Petard1);
	UnequipItemFromSlot(EES_Petard2);
	UnequipItemFromSlot(EES_Quickslot1);
	UnequipItemFromSlot(EES_Quickslot2);
	UnequipItemFromSlot(EES_Potion1);
	UnequipItemFromSlot(EES_Potion2);
	UnequipItemFromSlot(EES_Potion3);
	UnequipItemFromSlot(EES_Potion4);
	UnequipItemFromSlot(EES_Mask);
	UnequipItemFromSlot(EES_SkillMutagen1);
	UnequipItemFromSlot(EES_SkillMutagen2);
	UnequipItemFromSlot(EES_SkillMutagen3);
	UnequipItemFromSlot(EES_SkillMutagen4);
	HorseUnequipItem(EES_HorseBlinders);
	HorseUnequipItem(EES_HorseSaddle);
	HorseUnequipItem(EES_HorseBag);
	HorseUnequipItem(EES_HorseTrophy);
	
	currentLevel = levelManager.GetLevel();
	totalExp = levelManager.GetPointsTotal(EExperiencePoint);
	totalSkillPoints = levelManager.GetPointsTotal(ESkillPoint);
	isMutationSystemEnabled = ((W3PlayerAbilityManager)abilityManager).IsMutationSystemEnabled();
	
	spectreDebug_RestoreMutagensSpent();
	
	GetCharacterStats().GetAbilities(abs, false);
	for(i=0; i<abs.Size(); i+=1)
		RemoveAbility(abs[i]);
	abs.Clear();
	GetCharacterStatsParam(abs);		
	for(i=0; i<abs.Size(); i+=1)
		AddAbility(abs[i]);
				
	delete levelManager;
	levelManager = new W3LevelManager in this;
	levelManager.Initialize();
	levelManager.PostInit(this, false, true);
	
	if(!resetLevels)
	{
		levelManager.spectreAddPoints(EExperiencePoint, totalExp, false, true);
		levelManager.AddPoints(ESkillPoint, Max(0, totalSkillPoints - levelManager.GetPointsTotal(ESkillPoint)), false);
	}
	
	delete abilityManager;
	SetAbilityManager();
	abilityManager.Init(this, GetCharacterStats(), false, theGame.GetDifficultyMode());
	
	delete effectManager;
	SetEffectManager();
	
	abilityManager.PostInit();
	((W3PlayerAbilityManager)abilityManager).MutationSystemEnable(isMutationSystemEnabled);
}

@addMethod(W3PlayerWitcher) function ResetAbilityManager() 
{
	delete abilityManager; 
	
	SetAbilityManager();
}

@wrapMethod(W3PlayerWitcher) function CanSprint( speed : float ) : bool
{
	if(false) 
	{
		wrappedMethod(speed);
	}
	
	if(theGame.GetEngineTimeAsSeconds() - blockSprintTimestamp < 2)
	{
		return false;
	}
	if( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
	{
		if ( this.GetPlayerCombatStance() ==  PCS_AlertNear )
		{
			if ( IsSprintActionPressed() )
				OnRangedForceHolster( true, false );
		}
		else
			return false;
	}
	if( GetCurrentStateName() != 'Swimming' && GetStat(BCS_Stamina) <= 0 )
	{
		SetSprintActionPressed(false,true);
		blockSprintTimestamp = theGame.GetEngineTimeAsSeconds();
		return false;
	}
	
	return super.CanSprint( speed ); 
}

@addField(W3PlayerWitcher)
var blockSprintTimestamp : float;

@wrapMethod(W3PlayerWitcher) function PerformParryCheck( parryInfo : SParryInfo ) : bool
{
	if(false) 
	{
		wrappedMethod(parryInfo);
	}
	
	if( super.PerformParryCheck( parryInfo ) )
	{
		return true;
	}
	return false;
}

@wrapMethod(W3PlayerWitcher) function PerformCounterCheck( parryInfo: SParryInfo ) : bool
{
	var fistFightCheck, isInFistFight		: bool;
	
	if(false) 
	{
		wrappedMethod(parryInfo);
	}
	
	if( super.PerformCounterCheck( parryInfo ) )
	{
		isInFistFight = FistFightCheck( parryInfo.target, parryInfo.attacker, fistFightCheck );
		
		if( isInFistFight && fistFightCheck )
		{
			FactsAdd( "statistics_fist_fight_counter" );
			AddTimer( 'FistFightCounterTimer', 0.5f, , , , true );
		}
		
		return true;
	}
	return false;
}

@wrapMethod(W3PlayerWitcher) function GainAdrenalineFromPerk21( action : name )
{
	var min, max : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(action);
	}
	
	if(!HasBuff(EET_Perk21InternalCooldown) || action == 'kill')
	{
		switch(action)
		{
			case 'kill':
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('perk_21', 'stamina_kill', min, max);
				GainStat(BCS_Stamina, min.valueMultiplicative * GetStatMax(BCS_Stamina));
				break;
			case 'crit':
			case 'counter':
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('perk_21', 'stamina_other', min, max);
				GainStat(BCS_Stamina, min.valueMultiplicative * GetStatMax(BCS_Stamina));
				break;
			default:
				break;
		}
		AddEffectDefault(EET_Perk21InternalCooldown, this, "Perk21");
	}	
}

@addMethod(W3PlayerWitcher) function SpectreRecalcSetItemsEquipped()
{
	var slotsToCheck : array<EEquipmentSlots>;
	var setType : EItemSetType;
	var item : SItemUniqueId;
	var i : int;
	
	for(i = 0; i < amountOfSetPiecesEquipped.Size(); i += 1)
		amountOfSetPiecesEquipped[i] = 0;
	
	slotsToCheck.PushBack(EES_Armor);
	slotsToCheck.PushBack(EES_Boots);
	slotsToCheck.PushBack(EES_Pants);
	slotsToCheck.PushBack(EES_Gloves);
	slotsToCheck.PushBack(EES_SilverSword);
	slotsToCheck.PushBack(EES_SteelSword);

	for(i = 0; i < slotsToCheck.Size(); i += 1)
	{
		if(GetItemEquippedOnSlot(slotsToCheck[i], item) && inv.ItemHasTag(item, 'SetBonusPiece'))
		{
			setType = CheckSetType( item );
			amountOfSetPiecesEquipped[ setType ] += 1;
			ManageSetBonusesSoundbanks( setType );
		}
	}
}

@wrapMethod(W3PlayerWitcher) function IsSetBonusActive( bonus : EItemSetBonus ) : bool
{
	if(false) 
	{
		wrappedMethod(bonus);
	}
	
	switch(bonus)
	{
		case EISB_Lynx_1:			return amountOfSetPiecesEquipped[ EIST_Lynx ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
		case EISB_Lynx_2:			return amountOfSetPiecesEquipped[ EIST_Lynx ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
		case EISB_Gryphon_1:		return amountOfSetPiecesEquipped[ EIST_Gryphon ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
		case EISB_Gryphon_2:		return amountOfSetPiecesEquipped[ EIST_Gryphon ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
		case EISB_Bear_1:			return amountOfSetPiecesEquipped[ EIST_Bear ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
		case EISB_Bear_2:			return amountOfSetPiecesEquipped[ EIST_Bear ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
		case EISB_Wolf_1:			return amountOfSetPiecesEquipped[ EIST_Wolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
		case EISB_Wolf_2:			return amountOfSetPiecesEquipped[ EIST_Wolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
		case EISB_RedWolf_1:		return amountOfSetPiecesEquipped[ EIST_RedWolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
		case EISB_RedWolf_2:		return amountOfSetPiecesEquipped[ EIST_RedWolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
		case EISB_Vampire:			return amountOfSetPiecesEquipped[ EIST_Vampire ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
		case EISB_Viper:			return amountOfSetPiecesEquipped[ EIST_Viper ] >= GetNumItemsRequiredForSetActivation(EIST_Viper);
		case EISB_KaerMorhen:		return amountOfSetPiecesEquipped[ EIST_KaerMorhen ] >= GetNumItemsRequiredForSetActivation(EIST_KaerMorhen);		   
		case EISB_Netflix_1:		return amountOfSetPiecesEquipped[ EIST_Netflix ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
		case EISB_Netflix_2:		return amountOfSetPiecesEquipped[ EIST_Netflix ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
		default:					return false;
	}
}

@wrapMethod(W3PlayerWitcher) function GetSetPartsEquipped( setType : EItemSetType ) : int
{
	if(false) 
	{
		wrappedMethod(setType);
	}
	
	switch( setType )
	{
		case EIST_Lynx:
		case EIST_Lynx_Minor:
			return amountOfSetPiecesEquipped[ EIST_Lynx ] + amountOfSetPiecesEquipped[ EIST_Lynx_Minor ];
		case EIST_Gryphon:
		case EIST_Gryphon_Minor:
			return amountOfSetPiecesEquipped[ EIST_Gryphon ] + amountOfSetPiecesEquipped[ EIST_Gryphon_Minor ];
		case EIST_Bear:
		case EIST_Bear_Minor:
			return amountOfSetPiecesEquipped[ EIST_Bear ] + amountOfSetPiecesEquipped[ EIST_Bear_Minor ];
		case EIST_Wolf:
		case EIST_Wolf_Minor:
			return amountOfSetPiecesEquipped[ EIST_Wolf ] + amountOfSetPiecesEquipped[ EIST_Wolf_Minor ];
		case EIST_RedWolf:
		case EIST_RedWolf_Minor:
			return amountOfSetPiecesEquipped[ EIST_RedWolf ] + amountOfSetPiecesEquipped[ EIST_RedWolf_Minor ];
		case EIST_Netflix:
		case EIST_Netflix_Minor:
			return amountOfSetPiecesEquipped[ EIST_Netflix ] + amountOfSetPiecesEquipped[ EIST_Netflix_Minor ];
		default:
			return amountOfSetPiecesEquipped[ setType ];
	}
}

@addMethod(W3PlayerWitcher) function GetSetPartsEquippedRaw( setType : EItemSetType ) : int
{
	return amountOfSetPiecesEquipped[ setType ];
}

@addMethod(W3PlayerWitcher) function HasMixedSetsEquipped() : bool
{
	return	amountOfSetPiecesEquipped[ EIST_Lynx ] > 0 && amountOfSetPiecesEquipped[ EIST_Lynx_Minor ] > 0 ||
			amountOfSetPiecesEquipped[ EIST_Gryphon ] > 0 && amountOfSetPiecesEquipped[ EIST_Gryphon_Minor ] > 0 ||
			amountOfSetPiecesEquipped[ EIST_Bear ] > 0 && amountOfSetPiecesEquipped[ EIST_Bear_Minor ] > 0 ||
			amountOfSetPiecesEquipped[ EIST_Wolf ] > 0 && amountOfSetPiecesEquipped[ EIST_Wolf_Minor ] > 0 ||
			amountOfSetPiecesEquipped[ EIST_RedWolf ] > 0 && amountOfSetPiecesEquipped[ EIST_RedWolf_Minor ] > 0 ||
			amountOfSetPiecesEquipped[ EIST_Netflix ] > 0 && amountOfSetPiecesEquipped[ EIST_Netflix_Minor ] > 0;
}

@wrapMethod(W3PlayerWitcher) function UpdateItemSetBonuses( item : SItemUniqueId, increment : bool )
{
	var setType : EItemSetType;
	var tutorialStateSets : W3TutorialManagerUIHandlerStateSetItemsUnlocked;
	var id : SItemUniqueId;
	
	if(false) 
	{
		wrappedMethod(item, increment);
	}
				
	if( !inv.IsIdValid( item ) || !inv.ItemHasTag(item, theGame.params.ITEM_SET_TAG_BONUS ) )  
	{
		return;
	}
	
	setType = CheckSetType( item );
	
	if( increment )
	{
		amountOfSetPiecesEquipped[ setType ] += 1;
		
		if( GetSetPartsEquipped(setType) >= GetNumItemsRequiredForSetActivation(setType) && ShouldProcessTutorial( 'TutorialSetBonusesUnlocked' ) && theGame.GetTutorialSystem().uiHandler && theGame.GetTutorialSystem().uiHandler.GetCurrentStateName() == 'SetItemsUnlocked' )
		{
			tutorialStateSets = ( W3TutorialManagerUIHandlerStateSetItemsUnlocked )theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			tutorialStateSets.OnSetBonusCompleted();
		}
	}
	else if( amountOfSetPiecesEquipped[ setType ] > 0 )
	{
		amountOfSetPiecesEquipped[ setType ] -= 1;
	}
	
	theGame.alchexts.abltymgr.UpdateManticoreBonus(setType, amountOfSetPiecesEquipped[setType] == theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS);
	
	if( setType != EIST_Vampire )
	{
		if(amountOfSetPiecesEquipped[ setType ] == theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS)
		{
			theGame.GetGamerProfile().AddAchievement( EA_ReadyToRoll );
		}
		else 
		{
			theGame.GetGamerProfile().NoticeAchievementProgress( EA_ReadyToRoll, amountOfSetPiecesEquipped[ setType ]);
		}
	}
	
	ManageActiveSetBonuses( setType );
	
	
	ManageSetBonusesSoundbanks( setType );
}

@wrapMethod(W3PlayerWitcher) function ManageActiveSetBonuses( setType : EItemSetType )
{
	var l_i				: int;
	
	if(false) 
	{
		wrappedMethod(setType);
	}
	
	if( setType == EIST_Lynx || setType == EIST_Lynx_Minor )
	{
		
		if( HasBuff( EET_LynxSetBonus ) && !IsSetBonusActive( EISB_Lynx_1 ) )
		{
			RemoveBuff( EET_LynxSetBonus );
		}
	}
	
	else if( setType == EIST_Gryphon )
	{
		
		if( !IsSetBonusActive( EISB_Gryphon_1 ) )
		{
			RemoveBuff( EET_GryphonSetBonus );
		}
		
		if( IsSetBonusActive( EISB_Gryphon_2 ) && !HasBuff( EET_GryphonSetBonusYrden ) )
		{
			for( l_i = 0 ; l_i < yrdenEntities.Size() ; l_i += 1 )
			{
				if( yrdenEntities[ l_i ].GetIsPlayerInside() && !yrdenEntities[ l_i ].IsAlternateCast() )
				{
					AddEffectDefault( EET_GryphonSetBonusYrden, this, "GryphonSetBonusYrden" );
					break;
				}
			}
		}
		else
		{
			RemoveBuff( EET_GryphonSetBonusYrden );
		}
	}
	else if( setType == EIST_KaerMorhen )
	{
		if( !IsSetBonusActive(EISB_KaerMorhen) && HasBuff(EET_KaerMorhenSetBonus) )
		{
			RemoveBuff(EET_KaerMorhenSetBonus);
		}
		else if( IsSetBonusActive(EISB_KaerMorhen) && !HasBuff(EET_KaerMorhenSetBonus) && IsInCombat() )
		{
			AddEffectDefault(EET_KaerMorhenSetBonus, this, "KaerMorhenSetBonus");
		}
	}
}

@wrapMethod(W3PlayerWitcher) function CheckSetTypeByName( itemName : name ) : EItemSetType
{
	var dm : CDefinitionsManagerAccessor;
	
	if(false) 
	{
		wrappedMethod(itemName);
	}
	
	dm = theGame.GetDefinitionsManager();
	
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_LYNX ) )
	{
		return EIST_Lynx;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_GRYPHON ) )
	{
		return EIST_Gryphon;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_BEAR ) )
	{
		return EIST_Bear;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_WOLF ) )
	{
		return EIST_Wolf;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_RED_WOLF ) )
	{
		return EIST_RedWolf;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_VAMPIRE ) )
	{
		return EIST_Vampire;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_VIPER ) )
	{
		return EIST_Viper;
	}
	else 
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_NETFLIX ) )
	{
		return EIST_Netflix;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_KAER_MORHEN ) )
	{
		return EIST_KaerMorhen;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_LYNX_MINOR ) )
	{
		return EIST_Lynx_Minor;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_GRYPHON_MINOR ) )
	{
		return EIST_Gryphon_Minor;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_BEAR_MINOR ) )
	{
		return EIST_Bear_Minor;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_WOLF_MINOR ) )
	{
		return EIST_Wolf_Minor;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_RED_WOLF_MINOR ) )
	{
		return EIST_RedWolf_Minor;
	}
	else
	if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_NETFLIX_MINOR ) )
	{
		return EIST_Netflix_Minor;
	}
	else
	{
		return EIST_Undefined;
	}
}

@wrapMethod(W3PlayerWitcher) function CheckSetType( item : SItemUniqueId ) : EItemSetType
{
	var stopLoop 	: bool;
	var tags 		: array<name>;
	var i 			: int;
	var setType 	: EItemSetType;
	
	if(false) 
	{
		wrappedMethod(item);
	}
	
	stopLoop = false;
	
	inv.GetItemTags( item, tags );
	
	
	for( i=0; i<tags.Size(); i+=1 )
	{
		switch( tags[i] )
		{
			case theGame.params.ITEM_SET_TAG_LYNX:
			case theGame.params.ITEM_SET_TAG_GRYPHON:
			case theGame.params.ITEM_SET_TAG_BEAR:
			case theGame.params.ITEM_SET_TAG_WOLF:
			case theGame.params.ITEM_SET_TAG_RED_WOLF:
			case theGame.params.ITEM_SET_TAG_VAMPIRE:
			case theGame.params.ITEM_SET_TAG_VIPER:
			case theGame.params.ITEM_SET_TAG_NETFLIX:
			case theGame.params.ITEM_SET_TAG_KAER_MORHEN:
			case theGame.params.ITEM_SET_TAG_LYNX_MINOR:
			case theGame.params.ITEM_SET_TAG_GRYPHON_MINOR:
			case theGame.params.ITEM_SET_TAG_BEAR_MINOR:
			case theGame.params.ITEM_SET_TAG_WOLF_MINOR:
			case theGame.params.ITEM_SET_TAG_RED_WOLF_MINOR:
			case theGame.params.ITEM_SET_TAG_NETFLIX_MINOR:
				setType = SetItemNameToType( tags[i] );
				stopLoop = true;
				break;
		}		
		if ( stopLoop )
		{
			break;
		}
	}
	
	return setType;
}

@wrapMethod(W3PlayerWitcher) function SetBonusStatusByType(setType : EItemSetType, out desc1, desc2 : string, out isActive1, isActive2 : bool):void
{
	var setBonus : EItemSetBonus;
	
	if(false) 
	{
		wrappedMethod(setType, desc1, desc2, isActive1, isActive2);
	}

	isActive1 = (GetSetPartsEquipped(setType) >= GetNumItemsRequiredForSetActivation(setType));

	isActive2 = (amountOfSetPiecesEquipped[ setType ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS);

	setBonus = ItemSetTypeToItemSetBonus( setType, 1 );
	desc1 = GetSetBonusTooltipDescription( setBonus );
	
	setBonus = ItemSetTypeToItemSetBonus( setType, 2 );
	desc2 = GetSetBonusTooltipDescription( setBonus );
}

@wrapMethod(W3PlayerWitcher)  function ItemSetTypeToItemSetBonus( setType : EItemSetType, nr : int ) : EItemSetBonus
{
	var setBonus : EItemSetBonus;

	if(false) 
	{
		wrappedMethod(setType, nr);
	}

	if( nr == 1 )
	{
		switch( setType )
		{
			case EIST_Lynx: 			setBonus = EISB_Lynx_1;		break;
			case EIST_Gryphon: 			setBonus = EISB_Gryphon_1;	break;
			case EIST_Bear: 			setBonus = EISB_Bear_1;		break;
			case EIST_Wolf: 			setBonus = EISB_Wolf_1;		break;
			case EIST_RedWolf: 			setBonus = EISB_RedWolf_1;	break;
			case EIST_Netflix:			setBonus = EISB_Netflix_1;	break;
			case EIST_Vampire:			setBonus = EISB_Vampire;	break;
			case EIST_Viper:			setBonus = EISB_Viper;		break;
			case EIST_KaerMorhen:		setBonus = EISB_KaerMorhen;	break;
			case EIST_Lynx_Minor:		setBonus = EISB_Lynx_1;		break;
			case EIST_Gryphon_Minor:	setBonus = EISB_Gryphon_1;	break;
			case EIST_Bear_Minor:		setBonus = EISB_Bear_1;		break;
			case EIST_Wolf_Minor:		setBonus = EISB_Wolf_1;		break;
			case EIST_RedWolf_Minor: 	setBonus = EISB_RedWolf_1;	break;
			case EIST_Netflix_Minor:	setBonus = EISB_Netflix_1;	break;
		}
	}
	else
	{
		switch( setType )
		{
			case EIST_Lynx: 			setBonus = EISB_Lynx_2;		break;
			case EIST_Gryphon: 			setBonus = EISB_Gryphon_2;	break;
			case EIST_Bear: 			setBonus = EISB_Bear_2;		break;
			case EIST_Wolf: 			setBonus = EISB_Wolf_2;		break;
			case EIST_RedWolf: 			setBonus = EISB_RedWolf_2;	break;
			case EIST_Netflix: 			setBonus = EISB_Netflix_2;	break;
			case EIST_Vampire:			setBonus = EISB_Undefined;	break;
			case EIST_Viper:			setBonus = EISB_Undefined;	break;
			case EIST_KaerMorhen:		setBonus = EISB_Undefined;	break;
			case EIST_Lynx_Minor:		setBonus = EISB_Undefined;	break;
			case EIST_Gryphon_Minor:	setBonus = EISB_Undefined;	break;
			case EIST_Bear_Minor:		setBonus = EISB_Undefined;	break;
			case EIST_Wolf_Minor:		setBonus = EISB_Undefined;	break;
			case EIST_RedWolf_Minor: 	setBonus = EISB_Undefined;	break;
			case EIST_Netflix_Minor:	setBonus = EISB_Undefined;	break;
		}
	} 

	return setBonus;
}

@wrapMethod(W3PlayerWitcher) function GetSetBonusTooltipDescription( bonus : EItemSetBonus ) : string
{
	var finalString : string;
	var arrString	: array<string>;
	var dm			: CDefinitionsManagerAccessor;
	var min, max 	: SAbilityAttributeValue;
	var tempString	: string;
	var tmpVal		: float;
	
	if(false) 
	{
		wrappedMethod(bonus);
	}
	
	switch( bonus )
	{
		case EISB_Lynx_1:			tempString = "skill_desc_lynx_set_ability1"; break;
		case EISB_Lynx_2:			tempString = "skill_desc_lynx_set_ability2"; break;
		case EISB_Gryphon_1:		tempString = "skill_desc_gryphon_set_ability1"; break;
		case EISB_Gryphon_2:		tempString = "skill_desc_gryphon_set_ability2"; break;
		case EISB_Bear_1:			tempString = "skill_desc_bear_set_ability1"; break;
		case EISB_Bear_2:			tempString = "skill_desc_bear_set_ability2"; break;
		case EISB_Wolf_1:			tempString = "skill_desc_wolf_set_ability1"; break;
		case EISB_Wolf_2:			tempString = "skill_desc_wolf_set_ability2"; break;
		case EISB_RedWolf_1:		tempString = "skill_desc_red_wolf_set_ability1"; break;
		case EISB_RedWolf_2:		tempString = "skill_desc_red_wolf_set_ability2"; break;
		case EISB_Vampire:			tempString = "skill_desc_vampire_set_ability1"; break;
		case EISB_Netflix_1:		tempString = "skill_desc_netflix_set_ability1"; break;
		case EISB_Netflix_2:		tempString = "skill_desc_netflix_set_ability2"; break;
		case EISB_Viper:			tempString = "skill_desc_viper_set_ability1"; break;
		case EISB_KaerMorhen:		tempString = "skill_desc_kaer_morhen_set_ability1"; break;
		default:					tempString = ""; break;
	}
	
	dm = theGame.GetDefinitionsManager();
	
	switch( bonus )
	{
	case EISB_Lynx_1:
		dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'lynx_ap_boost', min, max );
		arrString.PushBack( FloatToString( min.valueAdditive * 100 ) ); 
		arrString.PushBack( FloatToString( min.valueAdditive * 100 * GetSetPartsEquipped( EIST_Lynx ) ) );
		dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'lynx_boost_max', min, max );
		arrString.PushBack( FloatToString( min.valueAdditive * 100 ) ); 
																									   
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_Lynx_2:
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_Gryphon_1:
		dm.GetAbilityAttributeValue( 'GryphonSetBonusEffect', 'gryphon_tier1_bonus', min, max );
		arrString.PushBack( FloatToString( min.valueAdditive * 100 ) ); 
		arrString.PushBack( FloatToString( min.valueAdditive * 100 * GetSetPartsEquipped( EIST_Gryphon ) ) );
		dm.GetAbilityAttributeValue( 'GryphonSetBonusEffect', 'duration', min, max );
		arrString.PushBack( FloatToString( min.valueAdditive ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;	
	case EISB_Gryphon_2:
		dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
		arrString.PushBack( FloatToString( ( min.valueAdditive - 1 )* 100) );
		dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'spell_power', min, max );
		arrString.PushBack( FloatToString( min.valueMultiplicative * 100) );
		dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'slashing_resistance_perc', min, max );
		arrString.PushBack( FloatToString( min.valueAdditive * 100) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
	case EISB_Bear_1:
		dm.GetAbilityAttributeValue( 'setBonusAbilityBear_1', 'bonus_focus_gain', min, max );
		arrString.PushBack( NoTrailZeros( CalculateAttributeValue(min) ) );
		arrString.PushBack( NoTrailZeros( CalculateAttributeValue(min) * GetSetPartsEquipped( EIST_Bear ) ) );
		dm.GetAbilityAttributeValue( 'setBonusAbilityBear_1', 'attack_power', min, max );
		arrString.PushBack( NoTrailZeros( min.valueMultiplicative * 100 ) );
		arrString.PushBack( NoTrailZeros( min.valueMultiplicative * 100 * GetSetPartsEquipped( EIST_Bear ) ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_Bear_2: 
		dm.GetAbilityAttributeValue( 'setBonusAbilityBear_2', 'stamina_attack', min, max );
		arrString.PushBack( NoTrailZeros( CalculateAttributeValue(min) * 100 ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_Wolf_1:
		arrString.PushBack( FloatToString( GetSetPartsEquipped( EIST_Wolf ) ) );
		dm.GetAbilityAttributeValue( 'SetBonusAbilityWolf_1', 'per_piece_oil_bonus', min, max );
		arrString.PushBack( RoundMath( CalculateAttributeValue(min) * 100 ) );
		arrString.PushBack( RoundMath( CalculateAttributeValue(min) * 100 * GetSetPartsEquipped( EIST_Wolf ) ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_Wolf_2:
		dm.GetAbilityAttributeValue( 'SetBonusAbilityWolf_2', 'per_oil_crit_chance_bonus', min, max );
		arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
		dm.GetAbilityAttributeValue( 'SetBonusAbilityWolf_2', 'per_oil_crit_power_bonus', min, max );
		arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_RedWolf_1:
		dm.GetAbilityAttributeValue( 'setBonusAbilityRedWolf_1', 'per_redwolf_piece_crit_chance_bonus', min, max );
		arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
		arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 * GetSetPartsEquipped( EIST_RedWolf ) ) );
		dm.GetAbilityAttributeValue( 'setBonusAbilityRedWolf_1', 'per_redwolf_piece_crit_power_bonus', min, max );
		arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
		arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 * GetSetPartsEquipped( EIST_RedWolf ) ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_RedWolf_2:
		dm.GetAbilityAttributeValue( 'setBonusAbilityRedWolf_2', 'amount', min, max );
		arrString.PushBack( NoTrailZeros( CalculateAttributeValue(min) * 100 ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_Vampire:
		dm.GetAbilityAttributeValue( 'setBonusAbilityVampire', 'life_percent', min, max );
		arrString.PushBack( FloatToString( min.valueAdditive ) );
		arrString.PushBack( FloatToString( min.valueAdditive * GetSetPartsEquipped( EIST_Vampire ) ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_Viper:
		dm.GetAbilityAttributeValue( 'setBonusAbilityViper_1', 'per_viper_piece_poison_healing_rate', min, max );
		arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
		arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 * GetSetPartsEquipped( EIST_Viper ) ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	case EISB_KaerMorhen:
		dm.GetAbilityAttributeValue( 'KaerMorhenSetBonusEffect', 'staminaRegen', min, max );
		tmpVal = CalculateAttributeValue(min);
		arrString.PushBack( FloatToString( tmpVal ) );
		dm.GetAbilityAttributeValue( 'KaerMorhenSetBonusEffect', 'maxStacks', min, max );
		arrString.PushBack( FloatToString( tmpVal * CalculateAttributeValue(min) ) );
		finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
		break;
	default:
		finalString = GetLocStringByKeyExtWithParams( tempString );
	}
	
	return finalString;
}

@addMethod(W3PlayerWitcher) function LoadCurrentSetBonusSoundbank()
{
	if(IsSetBonusActive(EISB_Lynx_1) || IsSetBonusActive(EISB_Lynx_2))
	{
		LoadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
	}
	if(IsSetBonusActive(EISB_Gryphon_1) || IsSetBonusActive(EISB_Gryphon_2))
	{
		LoadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
	}

	LoadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
}

@wrapMethod(W3PlayerWitcher) function ManageSetBonusesSoundbanks( setType : EItemSetType )
{
	if(false) 
	{
		wrappedMethod(setType);
	}
	
	if( GetSetPartsEquipped(setType) >= GetNumItemsRequiredForSetActivation(setType) )
	{
		switch( setType )
		{
			case EIST_Lynx:
				LoadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
				break;
			case EIST_Gryphon:
				LoadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
				break;
			case EIST_Bear:
				LoadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
				break;
		}
	}
	else
	{
		switch( setType )
		{
			case EIST_Lynx:
				UnloadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
				break;
			case EIST_Gryphon:
				UnloadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
				break;
			case EIST_Bear:
				UnloadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
				break;
		}
	}
}

@wrapMethod(W3PlayerWitcher) function VampiricSetAbilityRegeneration()
{
	var healthMax		: float;
	var healthToReg		: float;
	var healthPrc		: float;
	var min, max		: SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	healthMax = GetStatMax( BCS_Vitality );
	
	theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'setBonusAbilityVampire', 'life_percent', min, max );
	healthPrc = min.valueAdditive;

	healthToReg = ( healthPrc * GetSetPartsEquipped(EIST_Vampire) * healthMax ) / 100;
	
	GainStat( BCS_Vitality, healthToReg );
}

@wrapMethod(W3PlayerWitcher) function BearSetBonusQuenReapply( dt : float, id : int )
{
	var newQuen		: W3QuenEntity;
	
	if(false) 
	{
		wrappedMethod(dt, id);
	}
	
	newQuen = (W3QuenEntity)theGame.CreateEntity( GetSignTemplate( ST_Quen ), GetWorldPosition(), GetWorldRotation() );
	newQuen.Init( signOwner, GetSignEntity( ST_Quen ), true );
	newQuen.freeCast = true;
	newQuen.OnStarted();
	newQuen.OnThrowing();
	newQuen.OnEnded();
	
	m_quenReappliedCount += 1;
	
	RemoveTimer( 'BearSetBonusQuenReapply');
}

@addMethod(W3PlayerWitcher) function GetGryphonSetTier1Bonus() : float
{
	var abl			: SAbilityAttributeValue;
	
	abl = GetAttributeValue( 'gryphon_tier1_bonus' );
	return abl.valueAdditive * GetSetPartsEquipped( EIST_Gryphon );
}

@addMethod(W3PlayerWitcher) function GetPerk6StaminaCostReduction() : float
{
	var abl			: SAbilityAttributeValue;
	var bonus		: float;
	
	abl = GetAttributeValue('perk_6_stamina_cost_reduction');
	bonus = abl.valueMultiplicative;
	bonus = ClampF(bonus, 0, 1);

	return bonus;
}

@addMethod(W3PlayerWitcher) timer function GiveStandAloneEP1Items(dt : float, timerId : int)
{
	var items : array<SItemUniqueId>;
	
	if( inv )
	{			
		inv.GetAllItems(items);
		if( items.Size() <= 0 )
			return;
	}
	else
		return;
	
	StandaloneEp1_1();
	
	FactsAdd("standalone_ep1_inv", 1);
		
	RemoveTimer('GiveStandAloneEP1Items');
}

@addMethod(W3PlayerWitcher) timer function GiveStandAloneEP2Items(dt : float, timerId : int)
{
	var items : array<SItemUniqueId>;
	
	if( inv )
	{			
		inv.GetAllItems(items);
		if( items.Size() <= 0 )
			return;
	}
	else
		return;
	
	StandaloneEp2_1();
	
	FactsAdd("standalone_ep2_inv", 1);
		
	RemoveTimer('GiveStandAloneEP2Items');
}

@wrapMethod(W3PlayerWitcher) function StandaloneEp1_1()
{
	var i, inc, quantityLow, randLow, quantityMedium, randMedium, quantityHigh, randHigh, startingMoney : int;
	var pam : W3PlayerAbilityManager;
	var ids : array<SItemUniqueId>;
	var STARTING_LEVEL : int;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	FactsAdd("StandAloneEP1", 1);
	
	
	inv.RemoveAllItems();
	spectreMountBodyParts();
	
	
	inv.AddAnItem('Illusion Medallion', 1, true, true, false);
	inv.AddAnItem('q103_safe_conduct', 1, true, true, false);
	
	
	theGame.GetGamerProfile().ClearAllAchievementsForEP1();
	
	
	STARTING_LEVEL = 32;
	inc = STARTING_LEVEL - GetLevel();
	for(i=0; i<inc; i+=1)
	{
		levelManager.AddPoints(EExperiencePoint, levelManager.GetTotalExpForNextLevel() - levelManager.GetPointsTotal(EExperiencePoint), false);
	}
	
	
	levelManager.ResetCharacterDev();
	pam = (W3PlayerAbilityManager)abilityManager;
	if(pam)
	{
		pam.ResetCharacterDev();
	}
	levelManager.SetFreeSkillPoints(levelManager.GetLevel() - 1 + 11);	
	
	inv.AddAnItem('Greater mutagen red', 1);
	inv.AddAnItem('Greater mutagen green', 1);
	inv.AddAnItem('Greater mutagen blue', 1);
	inv.AddAnItem('Mutagen red', 2);
	inv.AddAnItem('Mutagen green', 2);
	inv.AddAnItem('Mutagen blue', 2);
	inv.AddAnItem('Lesser mutagen red', 2);
	inv.AddAnItem('Lesser mutagen green', 2);
	inv.AddAnItem('Lesser mutagen blue', 2);
	
	
	startingMoney = 40000;
	if(GetMoney() > startingMoney)
	{
		RemoveMoney(GetMoney() - startingMoney);
	}
	else
	{
		AddMoney( 40000 - GetMoney() );
	}
	
	
	
	
	
	ids.Clear();
	ids = inv.AddAnItem('EP1 Standalone Starting Armor');
	EquipItem(ids[0]);
	ids.Clear();
	ids = inv.AddAnItem('EP1 Standalone Starting Boots');
	EquipItem(ids[0]);
	ids.Clear();
	ids = inv.AddAnItem('EP1 Standalone Starting Gloves');
	EquipItem(ids[0]);
	ids.Clear();
	ids = inv.AddAnItem('EP1 Standalone Starting Pants');
	EquipItem(ids[0]);
	
	
	ids.Clear();
	ids = inv.AddAnItem('EP1 Standalone Starting Steel Sword');
	EquipItem(ids[0]);
	ids.Clear();
	ids = inv.AddAnItem('EP1 Standalone Starting Silver Sword');
	EquipItem(ids[0]);
	
	
	inv.AddAnItem('Torch', 1, true, true, false);
	
	quantityLow = 1;
	randLow = 2;
	quantityMedium = 2;
	randMedium = 2;
	quantityHigh = 3;
	randHigh = 2;
	
	inv.AddAnItem('Alghoul bone marrow',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Amethyst dust',quantityLow+RandRange(randLow));
	inv.AddAnItem('Arachas eyes',quantityLow+RandRange(randLow));
	inv.AddAnItem('Arachas venom',quantityLow+RandRange(randLow));
	inv.AddAnItem('Basilisk hide',quantityLow+RandRange(randLow));
	inv.AddAnItem('Basilisk venom',quantityLow+RandRange(randLow));
	inv.AddAnItem('Bear pelt',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Berserker pelt',quantityLow+RandRange(randLow));
	inv.AddAnItem('Coal',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Cotton',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Dark iron ingot',quantityLow+RandRange(randLow));
	inv.AddAnItem('Dark iron ore',quantityLow+RandRange(randLow));
	inv.AddAnItem('Deer hide',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Diamond dust',quantityLow+RandRange(randLow));
	inv.AddAnItem('Draconide leather',quantityLow+RandRange(randLow));
	inv.AddAnItem('Drowned dead tongue',quantityLow+RandRange(randLow));
	inv.AddAnItem('Drowner brain',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Dwimeryte ingot',quantityLow+RandRange(randLow));
	inv.AddAnItem('Dwimeryte ore',quantityLow+RandRange(randLow));
	inv.AddAnItem('Emerald dust',quantityLow+RandRange(randLow));
	inv.AddAnItem('Endriag chitin plates',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Endriag embryo',quantityLow+RandRange(randLow));
	inv.AddAnItem('Ghoul blood',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Goat hide',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Hag teeth',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Hardened leather',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Hardened timber',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Harpy feathers',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Horse hide',quantityLow+RandRange(randLow));
	inv.AddAnItem('Iron ore',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Leather straps',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Leather',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Linen',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Meteorite ingot',quantityLow+RandRange(randLow));
	inv.AddAnItem('Meteorite ore',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Necrophage skin',quantityLow+RandRange(randLow));
	inv.AddAnItem('Nekker blood',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Nekker heart',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Oil',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Phosphorescent crystal',quantityLow+RandRange(randLow));
	inv.AddAnItem('Pig hide',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Pure silver',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Rabbit pelt',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Rotfiend blood',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Sapphire dust',quantityLow+RandRange(randLow));
	inv.AddAnItem('Silk',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Silver ingot',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Silver ore',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Specter dust',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Steel ingot',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Steel plate',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('String',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Thread',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Timber',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Twine',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Venom extract',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Water essence',quantityMedium+RandRange(randMedium));
	inv.AddAnItem('Wolf liver',quantityHigh+RandRange(randHigh));
	inv.AddAnItem('Wolf pelt',quantityMedium+RandRange(randMedium));
	
	inv.AddAnItem('Alcohest', 5);
	inv.AddAnItem('Dwarven spirit', 5);

	
	ids.Clear();
	ids = inv.AddAnItem('Crossbow 5');
	EquipItem(ids[0]);
	ids.Clear();
	ids = inv.AddAnItem('Blunt Bolt', 100);
	EquipItem(ids[0]);
	inv.AddAnItem('Broadhead Bolt', 100);
	inv.AddAnItem('Split Bolt', 100);
	
	
	RemoveAllAlchemyRecipes();
	RemoveAllCraftingSchematics();
	
	
	
	
	AddAlchemyRecipe('Recipe for Cat 1');
	
	
	
	AddAlchemyRecipe('Recipe for Maribor Forest 1');
	AddAlchemyRecipe('Recipe for Petris Philtre 1');
	AddAlchemyRecipe('Recipe for Swallow 1');
	AddAlchemyRecipe('Recipe for Tawny Owl 1');
	
	AddAlchemyRecipe('Recipe for White Gull 1');
	AddAlchemyRecipe('Recipe for White Honey 1');
	AddAlchemyRecipe('Recipe for White Raffards Decoction 1');
	
	
	
	AddAlchemyRecipe('Recipe for Beast Oil 1');
	AddAlchemyRecipe('Recipe for Cursed Oil 1');
	AddAlchemyRecipe('Recipe for Hanged Man Venom 1');
	AddAlchemyRecipe('Recipe for Hybrid Oil 1');
	AddAlchemyRecipe('Recipe for Insectoid Oil 1');
	AddAlchemyRecipe('Recipe for Magicals Oil 1');
	AddAlchemyRecipe('Recipe for Necrophage Oil 1');
	AddAlchemyRecipe('Recipe for Specter Oil 1');
	AddAlchemyRecipe('Recipe for Vampire Oil 1');
	AddAlchemyRecipe('Recipe for Draconide Oil 1');
	AddAlchemyRecipe('Recipe for Ogre Oil 1');
	AddAlchemyRecipe('Recipe for Relic Oil 1');
	AddAlchemyRecipe('Recipe for Beast Oil 2');
	AddAlchemyRecipe('Recipe for Cursed Oil 2');
	AddAlchemyRecipe('Recipe for Hanged Man Venom 2');
	AddAlchemyRecipe('Recipe for Hybrid Oil 2');
	AddAlchemyRecipe('Recipe for Insectoid Oil 2');
	AddAlchemyRecipe('Recipe for Magicals Oil 2');
	AddAlchemyRecipe('Recipe for Necrophage Oil 2');
	AddAlchemyRecipe('Recipe for Specter Oil 2');
	AddAlchemyRecipe('Recipe for Vampire Oil 2');
	AddAlchemyRecipe('Recipe for Draconide Oil 2');
	AddAlchemyRecipe('Recipe for Ogre Oil 2');
	AddAlchemyRecipe('Recipe for Relic Oil 2');
	
	
	AddAlchemyRecipe('Recipe for Dancing Star 1');
	
	AddAlchemyRecipe('Recipe for Dwimeritum Bomb 1');
	
	AddAlchemyRecipe('Recipe for Grapeshot 1');
	AddAlchemyRecipe('Recipe for Samum 1');
	
	AddAlchemyRecipe('Recipe for White Frost 1');
	
	
	
	AddAlchemyRecipe('Recipe for Dwarven spirit 1');
	AddAlchemyRecipe('Recipe for Alcohest 1');
	AddAlchemyRecipe('Recipe for White Gull 1');
	
	
	AddStartingSchematics();
	
	
	ids.Clear();
	ids = inv.AddAnItem('Swallow 2');
	EquipItem(ids[0]);
	ids.Clear();
	ids = inv.AddAnItem('Thunderbolt 2');
	EquipItem(ids[0]);
	ids.Clear();
	ids = inv.AddAnItem('Tawny Owl 2');
	EquipItem(ids[0]);
	ids.Clear();
	
	ids = inv.AddAnItem('Grapeshot 2');
	EquipItem(ids[0]);
	ids.Clear();
	ids = inv.AddAnItem('Samum 2');
	EquipItem(ids[0]);
	
	inv.AddAnItem('Dwimeritum Bomb 1');
	inv.AddAnItem('Dragons Dream 1');
	inv.AddAnItem('Silver Dust Bomb 1');
	inv.AddAnItem('White Frost 2');
	inv.AddAnItem('Devils Puffball 2');
	inv.AddAnItem('Dancing Star 2');
	inv.AddAnItem('Beast Oil 1');
	inv.AddAnItem('Cursed Oil 1');
	inv.AddAnItem('Hanged Man Venom 2');
	inv.AddAnItem('Hybrid Oil 1');
	inv.AddAnItem('Insectoid Oil 1');
	inv.AddAnItem('Magicals Oil 1');
	inv.AddAnItem('Necrophage Oil 2');
	inv.AddAnItem('Specter Oil 1');
	inv.AddAnItem('Vampire Oil 1');
	inv.AddAnItem('Draconide Oil 1');
	inv.AddAnItem('Relic Oil 1');
	inv.AddAnItem('Black Blood 1');
	inv.AddAnItem('Blizzard 1');
	inv.AddAnItem('Cat 2');
	inv.AddAnItem('Full Moon 1');
	inv.AddAnItem('Maribor Forest 1');
	inv.AddAnItem('Petris Philtre 1');
	inv.AddAnItem('White Gull 1', 3);
	inv.AddAnItem('White Honey 2');
	inv.AddAnItem('White Raffards Decoction 1');
	
	
	inv.AddAnItem('Mutagen 17');	
	inv.AddAnItem('Mutagen 19');	
	inv.AddAnItem('Mutagen 27');	
	inv.AddAnItem('Mutagen 26');	
	
	
	inv.AddAnItem('weapon_repair_kit_1', 5);
	inv.AddAnItem('weapon_repair_kit_2', 3);
	inv.AddAnItem('armor_repair_kit_1', 5);
	inv.AddAnItem('armor_repair_kit_2', 3);
	
	
	quantityMedium = 2;
	quantityLow = 1;
	inv.AddAnItem('Rune stribog lesser', quantityMedium);
	inv.AddAnItem('Rune stribog', quantityLow);
	inv.AddAnItem('Rune dazhbog lesser', quantityMedium);
	inv.AddAnItem('Rune dazhbog', quantityLow);
	inv.AddAnItem('Rune devana lesser', quantityMedium);
	inv.AddAnItem('Rune devana', quantityLow);
	inv.AddAnItem('Rune zoria lesser', quantityMedium);
	inv.AddAnItem('Rune zoria', quantityLow);
	inv.AddAnItem('Rune morana lesser', quantityMedium);
	inv.AddAnItem('Rune morana', quantityLow);
	inv.AddAnItem('Rune triglav lesser', quantityMedium);
	inv.AddAnItem('Rune triglav', quantityLow);
	inv.AddAnItem('Rune svarog lesser', quantityMedium);
	inv.AddAnItem('Rune svarog', quantityLow);
	inv.AddAnItem('Rune veles lesser', quantityMedium);
	inv.AddAnItem('Rune veles', quantityLow);
	inv.AddAnItem('Rune perun lesser', quantityMedium);
	inv.AddAnItem('Rune perun', quantityLow);
	inv.AddAnItem('Rune elemental lesser', quantityMedium);
	inv.AddAnItem('Rune elemental', quantityLow);
	
	inv.AddAnItem('Glyph aard lesser', quantityMedium);
	inv.AddAnItem('Glyph aard', quantityLow);
	inv.AddAnItem('Glyph axii lesser', quantityMedium);
	inv.AddAnItem('Glyph axii', quantityLow);
	inv.AddAnItem('Glyph igni lesser', quantityMedium);
	inv.AddAnItem('Glyph igni', quantityLow);
	inv.AddAnItem('Glyph quen lesser', quantityMedium);
	inv.AddAnItem('Glyph quen', quantityLow);
	inv.AddAnItem('Glyph yrden lesser', quantityMedium);
	inv.AddAnItem('Glyph yrden', quantityLow);
	
	
	spectreLearnKitRecipes();
	StandaloneEp1_2();
}

// Standalone expansion starts with Spectre's alchemy: the kit gives potions, bombs and oils that Spectre does not
// refill at meditation, so Geralt learns the level 1 recipe of each (Spectre brews the better levels from it).
// With the vanilla alchemy package they refill as in 5.01.
@addMethod(W3PlayerWitcher) function spectreLearnKitRecipes()
{
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var items : array<SItemUniqueId>;
	var bases : array<string>;
	var recipeName, cooked : name;
	var level, i : int;

	if (spectreAlchemy501())
		return;
	inv.GetAllItems(items);
	for (i = 0; i < items.Size(); i += 1)
	{
		if (inv.IsItemPotion(items[i]) || inv.IsItemBomb(items[i]) || inv.IsItemOil(items[i]))
			bases.PushBack(StrBeforeLast(NameToString(inv.GetItemName(items[i])), " "));
	}
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('alchemy_recipes');
	for (i = 0; i < main.subNodes.Size(); i += 1)
	{
		if (!dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', recipeName))
			continue;
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', cooked);
		level = 0;
		dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', level);
		if (level == 1 && bases.Contains(StrBeforeLast(NameToString(cooked), " ")))
			AddAlchemyRecipe(recipeName, true, true);
	}
}

@wrapMethod(W3PlayerWitcher) function StandaloneEp1_2()
{
	var horseId : SItemUniqueId;
	var ids : array<SItemUniqueId>;
	var ents : array< CJournalBase >;
	var i : int;
	var manager : CWitcherJournalManager;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	inv.AddAnItem( 'Cows milk', 20 );
	ids.Clear();
	ids = inv.AddAnItem( 'Dumpling', 44 );
	EquipItem(ids[0]);
	
	
	inv.AddAnItem('Clearing Potion', 2, true, false, false);
	
	
	GetHorseManager().RemoveAllItems();
	
	ids.Clear();
	ids = inv.AddAnItem('Horse Bag 2');
	horseId = GetHorseManager().MoveItemToHorse(ids[0]);
	GetHorseManager().EquipItem(horseId);
	
	ids.Clear();
	ids = inv.AddAnItem('Horse Blinder 2');
	horseId = GetHorseManager().MoveItemToHorse(ids[0]);
	GetHorseManager().EquipItem(horseId);
	
	ids.Clear();
	ids = inv.AddAnItem('Horse Saddle 2');
	horseId = GetHorseManager().MoveItemToHorse(ids[0]);
	GetHorseManager().EquipItem(horseId);
	
	manager = theGame.GetJournalManager();

	
	manager.GetActivatedOfType( 'CJournalCreature', ents );
	for(i=0; i<ents.Size(); i+=1)
	{
		manager.ActivateEntry(ents[i], JS_Inactive, false, true);
	}
	
	
	ents.Clear();
	manager.GetActivatedOfType( 'CJournalCharacter', ents );
	for(i=0; i<ents.Size(); i+=1)
	{
		manager.ActivateEntry(ents[i], JS_Inactive, false, true);
	}
	
	
	ents.Clear();
	manager.GetActivatedOfType( 'CJournalQuest', ents );
	for(i=0; i<ents.Size(); i+=1)
	{
		
		if( StrStartsWith(ents[i].baseName, "q60"))
			continue;
			
		manager.ActivateEntry(ents[i], JS_Inactive, false, true);
	}
	
	
	manager.ActivateEntryByScriptTag('TutorialAard', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialAdrenaline', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialAxii', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialAxiiDialog', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialCamera', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialCamera_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialCiriBlink', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialCiriCharge', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialCiriStamina', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialCounter', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialDialogClose', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialFallingRoll', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialFocus', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialFocusClues', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialHorseRoad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialHorseSpeed0', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialHorseSpeed0_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialHorseSpeed1', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialHorseSpeed2', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialHorseSummon', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialHorseSummon_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialIgni', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalAlternateSings', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalBoatDamage', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalBoatMount', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalBuffs', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalCharDevLeveling', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalCharDevSkills', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalCrafting', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalCrossbow', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalDialogGwint', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalDialogShop', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalDive', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalDodge', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalDodge_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalDrawWeapon', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalDrawWeapon_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalDurability', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalExplorations', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalExplorations_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalFastTravel', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalFocusRedObjects', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalGasClouds', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalHeavyAttacks', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalHorse', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalHorseStamina', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalJump', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalLightAttacks', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalLightAttacks_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalMeditation', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalMeditation_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalMonsterThreatLevels', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalMovement', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalMovement_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalMutagenIngredient', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalMutagenPotion', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalOils', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalPetards', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalPotions', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalPotions_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalQuestArea', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalRadial', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalRifts', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalRun', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalShopDescription', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalSignCast', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalSignCast_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalSpecialAttacks', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJournalStaminaExploration', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialJumpHang', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialLadder', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialLadderMove', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialLadderMove_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialObjectiveSwitching', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialOxygen', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialParry', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialPOIUncovered', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialQuen', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialRoll', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialRoll_pad', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialSpeedPairing', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialSprint', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialStaminaSigns', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialStealing', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialSwimmingSpeed', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialTimedChoiceDialog', JS_Active);
	manager.ActivateEntryByScriptTag('TutorialYrden', JS_Active);
	
	
	FactsAdd('kill_base_tutorials');
	
	
	theGame.GetTutorialSystem().RemoveAllQueuedTutorials();
	
	if( FactsQuerySum("standalone_ep1") < 1 )
		FactsAdd("standalone_ep1");
	FactsRemove("StandAloneEP1");
	
	theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
}

@wrapMethod(W3PlayerWitcher) function StandaloneEp2_1()
{
	var i, inc, quantityLow, randLow, quantityMedium, randMedium, quantityHigh, randHigh, startingMoney : int;
	var pam : W3PlayerAbilityManager;
	var ids : array<SItemUniqueId>;
	var STARTING_LEVEL : int;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	FactsAdd( "StandAloneEP2", 1 );
	
	
	inv.RemoveAllItems();
	spectreMountBodyParts();
	
	
	inv.AddAnItem( 'Illusion Medallion', 1, true, true, false );
	inv.AddAnItem( 'q103_safe_conduct', 1, true, true, false );
	
	
	theGame.GetGamerProfile().ClearAllAchievementsForEP2();
	
	
	levelManager.Hack_EP2StandaloneLevelShrink( 35 );
	
	
	levelManager.ResetCharacterDev();
	pam = ( W3PlayerAbilityManager )abilityManager;
	if( pam )
	{
		pam.ResetCharacterDev();
	}
	levelManager.SetFreeSkillPoints( levelManager.GetLevel() - 1 + 11 );	
	
	inv.AddAnItem('Greater mutagen red', 1);
	inv.AddAnItem('Greater mutagen green', 1);
	inv.AddAnItem('Greater mutagen blue', 1);
	inv.AddAnItem('Mutagen red', 2);
	inv.AddAnItem('Mutagen green', 2);
	inv.AddAnItem('Mutagen blue', 2);
	inv.AddAnItem('Lesser mutagen red', 2);
	inv.AddAnItem('Lesser mutagen green', 2);
	inv.AddAnItem('Lesser mutagen blue', 2);
	
	
	startingMoney = 20000;
	if( GetMoney() > startingMoney )
	{
		RemoveMoney( GetMoney() - startingMoney );
	}
	else
	{
		AddMoney( 20000 - GetMoney() );
	}
	
	
	ids.Clear();
	ids = inv.AddAnItem( 'EP2 Standalone Starting Armor' );
	EquipItem( ids[0] );
	ids.Clear();
	ids = inv.AddAnItem( 'EP2 Standalone Starting Boots' );
	EquipItem( ids[0] );
	ids.Clear();
	ids = inv.AddAnItem( 'EP2 Standalone Starting Gloves' );
	EquipItem( ids[0] );
	ids.Clear();
	ids = inv.AddAnItem( 'EP2 Standalone Starting Pants' );
	EquipItem( ids[0] );
	
	
	ids.Clear();
	ids = inv.AddAnItem( 'EP2 Standalone Starting Steel Sword' );
	EquipItem( ids[0] );
	ids.Clear();
	ids = inv.AddAnItem( 'EP2 Standalone Starting Silver Sword' );
	EquipItem( ids[0] );
	
	
	inv.AddAnItem( 'Torch', 1, true, true, false );
	
	
	quantityLow = 1;
	randLow = 3;
	quantityMedium = 4;
	randMedium = 4;
	quantityHigh = 8;
	randHigh = 6;
	
	inv.AddAnItem( 'Alghoul bone marrow',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Amethyst dust',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Arachas eyes',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Arachas venom',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Basilisk hide',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Basilisk venom',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Bear pelt',quantityHigh+RandRange( randHigh ) );
	inv.AddAnItem( 'Berserker pelt',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Coal',quantityHigh+RandRange( randHigh ) );
	inv.AddAnItem( 'Cotton',quantityHigh+RandRange( randHigh ) );


	inv.AddAnItem( 'Deer hide',quantityHigh+RandRange( randHigh ) );
	inv.AddAnItem( 'Diamond dust',quantityLow+RandRange( randLow ) );

	inv.AddAnItem( 'Drowned dead tongue',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Drowner brain',quantityMedium+RandRange( randMedium ) );



	inv.AddAnItem( 'Endriag chitin plates',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Endriag embryo',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Ghoul blood',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Goat hide',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Hag teeth',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Hardened leather',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Hardened timber',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Harpy feathers',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Horse hide',quantityLow+RandRange( randLow ) );






	inv.AddAnItem( 'Necrophage skin',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Nekker blood',quantityHigh+RandRange( randHigh ) );
	inv.AddAnItem( 'Nekker heart',quantityMedium+RandRange( randMedium ) );

	inv.AddAnItem( 'Phosphorescent crystal',quantityLow+RandRange( randLow ) );
	inv.AddAnItem( 'Pig hide',quantityMedium+RandRange( randMedium ) );

	inv.AddAnItem( 'Rabbit pelt',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Rotfiend blood',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Sapphire dust',quantityLow+RandRange( randLow ) );



	inv.AddAnItem( 'Specter dust',quantityMedium+RandRange( randMedium ) );







	inv.AddAnItem( 'Water essence',quantityMedium+RandRange( randMedium ) );
	inv.AddAnItem( 'Wolf liver',quantityHigh+RandRange( randHigh ) );
	inv.AddAnItem( 'Wolf pelt',quantityMedium+RandRange( randMedium ) );
	
	inv.AddAnItem( 'Alcohest', 5 );
	inv.AddAnItem( 'Dwarven spirit', 5 );

	
	ids.Clear();
	ids = inv.AddAnItem( 'Crossbow 5' );
	EquipItem( ids[0] );
	ids.Clear();
	ids = inv.AddAnItem( 'Blunt Bolt', 100 );
	EquipItem( ids[0] );
	inv.AddAnItem( 'Broadhead Bolt', 100 );
	inv.AddAnItem( 'Split Bolt', 100 );
	
	
	RemoveAllAlchemyRecipes();
	RemoveAllCraftingSchematics();
	
	
	
	
	
	
	
	
	
	AddAlchemyRecipe( 'Recipe for Petris Philtre 2' );
	AddAlchemyRecipe( 'Recipe for Swallow 1' );
	AddAlchemyRecipe( 'Recipe for Tawny Owl 1' );
	
	AddAlchemyRecipe( 'Recipe for White Gull 1' );
	
	
	
	
	
	AddAlchemyRecipe( 'Recipe for Beast Oil 1' );
	AddAlchemyRecipe( 'Recipe for Cursed Oil 1' );
	AddAlchemyRecipe( 'Recipe for Hanged Man Venom 1' );
	AddAlchemyRecipe( 'Recipe for Hybrid Oil 1' );
	AddAlchemyRecipe( 'Recipe for Insectoid Oil 2' );
	AddAlchemyRecipe( 'Recipe for Magicals Oil 1' );
	AddAlchemyRecipe( 'Recipe for Necrophage Oil 1' );
	AddAlchemyRecipe( 'Recipe for Specter Oil 1' );
	AddAlchemyRecipe( 'Recipe for Vampire Oil 2' );
	AddAlchemyRecipe( 'Recipe for Draconide Oil 2' );
	AddAlchemyRecipe( 'Recipe for Ogre Oil 1' );
	AddAlchemyRecipe( 'Recipe for Relic Oil 1' );
	AddAlchemyRecipe( 'Recipe for Beast Oil 2' );
	AddAlchemyRecipe( 'Recipe for Cursed Oil 2' );
	AddAlchemyRecipe( 'Recipe for Hanged Man Venom 2' );
	AddAlchemyRecipe( 'Recipe for Hybrid Oil 2' );
	AddAlchemyRecipe( 'Recipe for Insectoid Oil 2' );
	AddAlchemyRecipe( 'Recipe for Magicals Oil 2' );
	AddAlchemyRecipe( 'Recipe for Necrophage Oil 2' );
	AddAlchemyRecipe( 'Recipe for Specter Oil 2' );
	AddAlchemyRecipe( 'Recipe for Vampire Oil 2' );
	AddAlchemyRecipe( 'Recipe for Draconide Oil 2' );
	AddAlchemyRecipe( 'Recipe for Ogre Oil 2' );
	AddAlchemyRecipe( 'Recipe for Relic Oil 2' );
	
	
	AddAlchemyRecipe( 'Recipe for Dancing Star 1' );
	
	AddAlchemyRecipe( 'Recipe for Dwimeritum Bomb 1' );
	
	AddAlchemyRecipe( 'Recipe for Grapeshot 1' );
	AddAlchemyRecipe( 'Recipe for Samum 1' );
	
	AddAlchemyRecipe( 'Recipe for White Frost 1' );
	
	
	
	AddAlchemyRecipe( 'Recipe for Dwarven spirit 1' );
	AddAlchemyRecipe( 'Recipe for Alcohest 1' );
	AddAlchemyRecipe( 'Recipe for White Gull 1' );
	
	
	AddStartingSchematics();
	
	
	ids.Clear();
	ids = inv.AddAnItem( 'Swallow 2' );
	EquipItem( ids[0] );
	ids.Clear();
	ids = inv.AddAnItem( 'Thunderbolt 2' );
	EquipItem( ids[0] );
	ids.Clear();
	ids = inv.AddAnItem( 'Tawny Owl 2' );
	EquipItem( ids[0] );
	ids.Clear();
	
	ids = inv.AddAnItem( 'Grapeshot 2' );
	EquipItem( ids[0] );
	ids.Clear();
	ids = inv.AddAnItem( 'Samum 2' );
	EquipItem( ids[0] );
	
	inv.AddAnItem( 'Dwimeritum Bomb 1' );
	inv.AddAnItem( 'Dragons Dream 1' );
	inv.AddAnItem( 'Silver Dust Bomb 1' );
	inv.AddAnItem( 'White Frost 2' );
	inv.AddAnItem( 'Devils Puffball 2' );
	inv.AddAnItem( 'Dancing Star 2' );
	inv.AddAnItem( 'Beast Oil 1' );
	inv.AddAnItem( 'Cursed Oil 1' );
	inv.AddAnItem( 'Hanged Man Venom 2' );
	inv.AddAnItem( 'Hybrid Oil 2' );
	inv.AddAnItem( 'Insectoid Oil 2' );
	inv.AddAnItem( 'Magicals Oil 1' );
	inv.AddAnItem( 'Necrophage Oil 2' );
	inv.AddAnItem( 'Ogre Oil 1' );
	inv.AddAnItem( 'Specter Oil 1' );
	inv.AddAnItem( 'Vampire Oil 2' );
	inv.AddAnItem( 'Draconide Oil 2' );
	inv.AddAnItem( 'Relic Oil 1' );
	inv.AddAnItem( 'Black Blood 1' );
	inv.AddAnItem( 'Blizzard 1' );
	inv.AddAnItem( 'Cat 2' );
	inv.AddAnItem( 'Full Moon 1' );
	inv.AddAnItem( 'Golden Oriole 1' );
	inv.AddAnItem( 'Killer Whale 1' );
	inv.AddAnItem( 'Maribor Forest 1' );
	inv.AddAnItem( 'Petris Philtre 2' );
	inv.AddAnItem( 'White Gull 1', 3 );
	inv.AddAnItem( 'White Honey 2' );
	inv.AddAnItem( 'White Raffards Decoction 1' );
	
	
	inv.AddAnItem( 'Mutagen 17' );	
	inv.AddAnItem( 'Mutagen 19' );	
	inv.AddAnItem( 'Mutagen 27' );	
	inv.AddAnItem( 'Mutagen 26' );	
	
	
	inv.AddAnItem( 'weapon_repair_kit_1', 5 );
	inv.AddAnItem( 'weapon_repair_kit_2', 3 );
	inv.AddAnItem( 'armor_repair_kit_1', 5 );
	inv.AddAnItem( 'armor_repair_kit_2', 3 );
	
	
	quantityMedium = 2;
	quantityLow = 1;
	inv.AddAnItem( 'Rune stribog lesser', quantityMedium );
	inv.AddAnItem( 'Rune stribog', quantityLow );
	inv.AddAnItem( 'Rune dazhbog lesser', quantityMedium );
	inv.AddAnItem( 'Rune dazhbog', quantityLow );
	inv.AddAnItem( 'Rune devana lesser', quantityMedium );
	inv.AddAnItem( 'Rune devana', quantityLow );
	inv.AddAnItem( 'Rune zoria lesser', quantityMedium );
	inv.AddAnItem( 'Rune zoria', quantityLow );
	inv.AddAnItem( 'Rune morana lesser', quantityMedium );
	inv.AddAnItem( 'Rune morana', quantityLow );
	inv.AddAnItem( 'Rune triglav lesser', quantityMedium );
	inv.AddAnItem( 'Rune triglav', quantityLow );
	inv.AddAnItem( 'Rune svarog lesser', quantityMedium );
	inv.AddAnItem( 'Rune svarog', quantityLow );
	inv.AddAnItem( 'Rune veles lesser', quantityMedium );
	inv.AddAnItem( 'Rune veles', quantityLow );
	inv.AddAnItem( 'Rune perun lesser', quantityMedium );
	inv.AddAnItem( 'Rune perun', quantityLow );
	inv.AddAnItem( 'Rune elemental lesser', quantityMedium );
	inv.AddAnItem( 'Rune elemental', quantityLow );
	
	inv.AddAnItem( 'Glyph aard lesser', quantityMedium );
	inv.AddAnItem( 'Glyph aard', quantityLow );
	inv.AddAnItem( 'Glyph axii lesser', quantityMedium );
	inv.AddAnItem( 'Glyph axii', quantityLow );
	inv.AddAnItem( 'Glyph igni lesser', quantityMedium );
	inv.AddAnItem( 'Glyph igni', quantityLow );
	inv.AddAnItem( 'Glyph quen lesser', quantityMedium );
	inv.AddAnItem( 'Glyph quen', quantityLow );
	inv.AddAnItem( 'Glyph yrden lesser', quantityMedium );
	inv.AddAnItem( 'Glyph yrden', quantityLow );
	
	
	spectreLearnKitRecipes();
	StandaloneEp2_2();
}

@wrapMethod(W3PlayerWitcher) function StandaloneEp2_2()
{
	var horseId : SItemUniqueId;
	var ids : array<SItemUniqueId>;
	var ents : array< CJournalBase >;
	var i : int;
	var manager : CWitcherJournalManager;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	inv.AddAnItem( 'Cows milk', 20 );
	ids.Clear();
	ids = inv.AddAnItem( 'Dumpling', 44 );
	EquipItem( ids[0] );
	
	
	inv.AddAnItem( 'Clearing Potion', 2, true, false, false );
	
	
	GetHorseManager().RemoveAllItems();
	
	ids.Clear();
	ids = inv.AddAnItem( 'Horse Bag 2' );
	horseId = GetHorseManager( ).MoveItemToHorse( ids[0] );
	GetHorseManager().EquipItem( horseId );
	
	ids.Clear();
	ids = inv.AddAnItem( 'Horse Blinder 2' );
	horseId = GetHorseManager().MoveItemToHorse( ids[0] );
	GetHorseManager().EquipItem( horseId );
	
	ids.Clear();
	ids = inv.AddAnItem( 'Horse Saddle 2' );
	horseId = GetHorseManager().MoveItemToHorse( ids[0] );
	GetHorseManager().EquipItem( horseId );
	
	manager = theGame.GetJournalManager();

	
	manager.GetActivatedOfType( 'CJournalCreature', ents );
	for(i=0; i<ents.Size(); i+=1)
	{
		manager.ActivateEntry( ents[i], JS_Inactive, false, true );
	}
	
	
	ents.Clear();
	manager.GetActivatedOfType( 'CJournalCharacter', ents );
	for(i=0; i<ents.Size(); i+=1)
	{
		manager.ActivateEntry( ents[i], JS_Inactive, false, true );
	}
	
	
	ents.Clear();
	manager.GetActivatedOfType( 'CJournalQuest', ents );
	for(i=0; i<ents.Size(); i+=1)
	{
		
		if( StrStartsWith( ents[i].baseName, "q60" ) )
			continue;
			
		manager.ActivateEntry( ents[i], JS_Inactive, false, true );
	}
	
	
	manager.ActivateEntryByScriptTag( 'TutorialAard', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialAdrenaline', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialAxii', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialAxiiDialog', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialCamera', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialCamera_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialCiriBlink', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialCiriCharge', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialCiriStamina', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialCounter', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialDialogClose', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialFallingRoll', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialFocus', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialFocusClues', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialHorseRoad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed0', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed0_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed1', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed2', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialHorseSummon', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialHorseSummon_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialIgni', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalAlternateSings', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalBoatDamage', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalBoatMount', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalBuffs', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalCharDevLeveling', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalCharDevSkills', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalCrafting', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalCrossbow', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalDialogGwint', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalDialogShop', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalDive', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalDodge', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalDodge_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalDrawWeapon', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalDrawWeapon_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalDurability', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalExplorations', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalExplorations_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalFastTravel', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalFocusRedObjects', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalGasClouds', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalHeavyAttacks', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalHorse', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalHorseStamina', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalJump', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalLightAttacks', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalLightAttacks_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalMeditation', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalMeditation_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalMonsterThreatLevels', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalMovement', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalMovement_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalMutagenIngredient', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalMutagenPotion', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalOils', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalPetards', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalPotions', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalPotions_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalQuestArea', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalRadial', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalRifts', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalRun', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalShopDescription', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalSignCast', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalSignCast_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalSpecialAttacks', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJournalStaminaExploration', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialJumpHang', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialLadder', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialLadderMove', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialLadderMove_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialObjectiveSwitching', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialOxygen', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialParry', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialPOIUncovered', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialQuen', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialRoll', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialRoll_pad', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialSpeedPairing', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialSprint', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialStaminaSigns', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialStealing', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialSwimmingSpeed', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialTimedChoiceDialog', JS_Active );
	manager.ActivateEntryByScriptTag( 'TutorialYrden', JS_Active );
	
	inv.AddAnItem( 'Geralt Shirt', 1 );
	inv.AddAnItem( 'Thread', 13 );
	inv.AddAnItem( 'String', 9 );
	inv.AddAnItem( 'Linen', 4 );
	inv.AddAnItem( 'Silk', 6 );
	inv.AddAnItem( 'Nigredo', 3 );
	inv.AddAnItem( 'Albedo', 1 );
	inv.AddAnItem( 'Rubedo', 1 );
	inv.AddAnItem( 'Rebis', 1 );
	inv.AddAnItem( 'Dog tallow', 4 );
	inv.AddAnItem( 'Lunar shards', 3 );
	inv.AddAnItem( 'Quicksilver solution', 5 );
	inv.AddAnItem( 'Aether', 1 );
	inv.AddAnItem( 'Optima mater', 3 );
	inv.AddAnItem( 'Fifth essence', 2 );
	inv.AddAnItem( 'Hardened timber', 6 );
	inv.AddAnItem( 'Fur square', 1 );
	inv.AddAnItem( 'Leather straps', 11 ); 
	inv.AddAnItem( 'Leather squares', 6 ); 
	inv.AddAnItem( 'Leather', 3 ); 
	inv.AddAnItem( 'Hardened leather', 14 ); 
	inv.AddAnItem( 'Chitin scale', 8 ); 
	inv.AddAnItem( 'Draconide leather', 5 ); 
	inv.AddAnItem( 'Infused draconide leather', 0 );
	inv.AddAnItem( 'Steel ingot', 5 );
	inv.AddAnItem( 'Dark iron ore', 2 );
	inv.AddAnItem( 'Dark iron ingot', 3 );
	inv.AddAnItem( 'Dark iron plate', 1 );
	inv.AddAnItem( 'Dark steel ingot', 10 );
	inv.AddAnItem( 'Dark steel plate', 6 );
	inv.AddAnItem( 'Silver ore', 2 );
	inv.AddAnItem( 'Silver ingot', 6 );
	inv.AddAnItem( 'Meteorite ore', 3 );
	inv.AddAnItem( 'Meteorite ingot', 3 );
	inv.AddAnItem( 'Meteorite plate', 2 );
	inv.AddAnItem( 'Meteorite silver ingot', 6 );
	inv.AddAnItem( 'Meteorite silver plate', 5 );
	inv.AddAnItem( 'Orichalcum ingot', 0 );
	inv.AddAnItem( 'Orichalcum plate', 1 );
	inv.AddAnItem( 'Dwimeryte ingot', 6 );
	inv.AddAnItem( 'Dwimeryte plate', 5 );
	inv.AddAnItem( 'Dwimeryte enriched ingot', 0 );
	inv.AddAnItem( 'Dwimeryte enriched plate', 0 );
	inv.AddAnItem( 'Emerald dust', 0 );
	inv.AddAnItem( 'Ruby dust', 4 );
	inv.AddAnItem( 'Ruby', 2 );
	inv.AddAnItem( 'Ruby flawless', 1 );
	inv.AddAnItem( 'Sapphire dust', 0 );
	inv.AddAnItem( 'Sapphire', 0 );
	inv.AddAnItem( 'Monstrous brain', 8 );
	inv.AddAnItem( 'Monstrous blood', 14 );
	inv.AddAnItem( 'Monstrous bone', 9 );
	inv.AddAnItem( 'Monstrous claw', 14 );
	inv.AddAnItem( 'Monstrous dust', 9 );
	inv.AddAnItem( 'Monstrous ear', 5 );
	inv.AddAnItem( 'Monstrous egg', 1 );
	inv.AddAnItem( 'Monstrous eye', 10 );
	inv.AddAnItem( 'Monstrous essence', 7 );
	inv.AddAnItem( 'Monstrous feather', 8 );
	inv.AddAnItem( 'Monstrous hair', 12 );
	inv.AddAnItem( 'Monstrous heart', 7 );
	inv.AddAnItem( 'Monstrous hide', 4 );
	inv.AddAnItem( 'Monstrous liver', 5 );
	inv.AddAnItem( 'Monstrous plate', 1 );
	inv.AddAnItem( 'Monstrous saliva', 6 );
	inv.AddAnItem( 'Monstrous stomach', 3 );
	inv.AddAnItem( 'Monstrous tongue', 5 );
	inv.AddAnItem( 'Monstrous tooth', 9 );
	inv.AddAnItem( 'Venom extract', 0 );
	inv.AddAnItem( 'Siren vocal cords', 1 );
	
	
	SelectQuickslotItem( EES_RangedWeapon );
	
	
	FactsAdd( 'kill_base_tutorials' );
	
	
	theGame.GetTutorialSystem().RemoveAllQueuedTutorials();
	
	
	if( FactsQuerySum("standalone_ep2") < 1 )
		FactsAdd("standalone_ep2");
	FactsRemove( "StandAloneEP2" );
	
	theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
}

@addMethod( W3PlayerWitcher ) timer function spectreCooldownBuffCheck( dt : float, id : int )
{
	if(thePlayer.HasBuff(EET_AardCooldown))
	{
		if(!thePlayer.HasTag('spectre_aard_cooldown_active'))
		{
			thePlayer.AddTag('spectre_aard_cooldown_active');
		}
	}
	else
	{
		if(thePlayer.HasTag('spectre_aard_cooldown_active'))
		{
			thePlayer.RemoveTag('spectre_aard_cooldown_active');
		}
	}

	if(thePlayer.HasBuff(EET_IgniCooldown))
	{
		if(!thePlayer.HasTag('spectre_igni_cooldown_active'))
		{
			thePlayer.AddTag('spectre_igni_cooldown_active');
		}
	}
	else
	{
		if(thePlayer.HasTag('spectre_igni_cooldown_active'))
		{
			thePlayer.RemoveTag('spectre_igni_cooldown_active');
		}
	}

	if(thePlayer.HasBuff(EET_YrdenCooldown))
	{
		if(!thePlayer.HasTag('spectre_yrden_cooldown_active'))
		{
			thePlayer.AddTag('spectre_yrden_cooldown_active');
		}
	}
	else
	{
		if(thePlayer.HasTag('spectre_yrden_cooldown_active'))
		{
			thePlayer.RemoveTag('spectre_yrden_cooldown_active');
		}
	}

	if(thePlayer.HasBuff(EET_QuenCooldown))
	{
		if(!thePlayer.HasTag('spectre_quen_cooldown_active'))
		{
			thePlayer.AddTag('spectre_quen_cooldown_active');
		}
	}
	else
	{
		if(thePlayer.HasTag('spectre_quen_cooldown_active'))
		{
			thePlayer.RemoveTag('spectre_quen_cooldown_active');
		}
	}

	if(thePlayer.HasBuff(EET_AxiiCooldown))
	{
		if(!thePlayer.HasTag('spectre_axii_cooldown_active'))
		{
			thePlayer.AddTag('spectre_axii_cooldown_active');
		}
	}
	else
	{
		if(thePlayer.HasTag('spectre_axii_cooldown_active'))
		{
			thePlayer.RemoveTag('spectre_axii_cooldown_active');
		}
	}

	if(thePlayer.HasBuff(EET_WhirlCooldown))
	{
		if(!thePlayer.HasTag('spectre_whirl_cooldown_active'))
		{
			thePlayer.AddTag('spectre_whirl_cooldown_active');
		}
	}
	else
	{
		if(thePlayer.HasTag('spectre_whirl_cooldown_active'))
		{
			thePlayer.RemoveTag('spectre_whirl_cooldown_active');
		}
	}

	if(thePlayer.HasBuff(EET_RendCooldown))
	{
		if(!thePlayer.HasTag('spectre_rend_cooldown_active'))
		{
			thePlayer.AddTag('spectre_rend_cooldown_active');
		}
	}
	else
	{
		if(thePlayer.HasTag('spectre_rend_cooldown_active'))
		{
			thePlayer.RemoveTag('spectre_rend_cooldown_active');
		}
	}

}

@addMethod( W3PlayerWitcher ) timer function spectreDelayedLevelUpEquipped( dt : float, id : int )
{
	spectreLevelUpEquipped();
}

@wrapMethod( W3PlayerWitcher ) function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
{
	var didEquip : bool;

	didEquip = wrappedMethod(item, slot, ignoreMounting, toHand);
	if(didEquip)
		spectreLevelUpEquipped();

	return didEquip;
}

@wrapMethod( W3PlayerWitcher ) function OnLevelGained(currentLevel : int, show : bool)
{
	spectreLevelUpEquipped();

	wrappedMethod(currentLevel, show);
}

function spectreLevelUpEquipped()
{
	var inventory : CInventoryComponent;
	var item : SItemUniqueId;
	var playerLevel, itemLevel, levelDiff, i, k : int;
	var slots : array<EEquipmentSlots>;

	if( !GetWitcherPlayer() )
	{
		return;
	}

	if(!spectreLevelUpEquippedOn() || spectre_Settings_Main_Bool('acs_item_management_settings','acs_disable_vanilla_items_autoscale', false))
	{
		return;
	}
	
	inventory = GetWitcherPlayer().inv;
	playerLevel = GetWitcherPlayer().GetLevel();
	
	slots.PushBack(EES_SteelSword);
	slots.PushBack(EES_SilverSword);
	slots.PushBack(EES_Armor);
	slots.PushBack(EES_Gloves);
	slots.PushBack(EES_Pants);
	slots.PushBack(EES_Boots);
	
	for( k = 0; k < slots.Size(); k += 1 )
	{
		if( inventory.GetItemEquippedOnSlot(slots[k], item) )
		{
			itemLevel = inventory.GetItemLevel(item);
			levelDiff = playerLevel - itemLevel;
			for( i = 0; i < levelDiff; i += 1 )
			{
				spectreLevelUpItem(item, inventory);
			}
		}
	}
}

function spectreLevelUpItem(item : SItemUniqueId, inventory : CInventoryComponent)
{
	var dmgBoost : float;

	if( inventory.ItemHasTag( item, 'PlayerSteelWeapon' ) || inventory.GetItemCategory( item ) == 'steelsword' )
	{
		inventory.AddItemCraftedAbility(item, 'autogen_fixed_steel_dmg', true );		
	}
	else if( inventory.ItemHasTag( item, 'PlayerSilverWeapon' ) || inventory.GetItemCategory( item ) == 'silversword' )
	{
		inventory.AddItemCraftedAbility(item, 'autogen_fixed_silver_dmg', true );		
	}
	else if( inventory.GetItemCategory( item ) == 'armor' )
	{
		inventory.AddItemCraftedAbility(item, 'autogen_fixed_armor_armor', true );		
	}
	else if( inventory.GetItemCategory( item ) == 'boots' || inventory.GetItemCategory( item ) == 'pants' )
	{
		inventory.AddItemCraftedAbility(item, 'autogen_fixed_pants_armor', true ); 
	}
	else if( inventory.GetItemCategory( item ) == 'gloves' )
	{
		inventory.AddItemCraftedAbility(item, 'autogen_fixed_gloves_armor', true );
	}
}

@wrapMethod(W3PlayerWitcher) function OilSelectionPopup( steel : bool )
{
	var cat, tags : array<name>;
	var m_popupData : W3ItemSelectionPopupData;

	if (false)
	{
		wrappedMethod(steel);
	}
	
	m_popupData = new W3ItemSelectionPopupData in theGame.GetGuiManager();
	m_popupData.targetInventory = thePlayer.GetInventory();
	m_popupData.overrideQuestItemRestrictions = true;
	
	if(steel)
	{
		m_popupData.checkTagsOR = true;
		tags.PushBack('SteelOil');
		tags.PushBack('SilverOil');
		m_popupData.selectionMode = EISPM_RadialMenuSteelOil;
	}
	else
	{
		m_popupData.checkTagsOR = true;
		tags.PushBack('SteelOil');
		tags.PushBack('SilverOil');
		m_popupData.selectionMode = EISPM_RadialMenuSilverOil;
	}
	m_popupData.filterTagsList = tags;		
	
	cat.PushBack('oil');
	m_popupData.categoryFilterList = cat;
	
	theGame.RequestPopup('ItemSelectionPopup', m_popupData);
	
	ToggleRadialMenuInput(false);
	radialPopupShown = true;
}


@replaceMethod(W3PlayerWitcher) function IsMutationActive( mutationType : EPlayerMutationType) : bool
{
	var swordQuality : int;
	var sword : SItemUniqueId;

	if( !IsMutationEquipped(mutationType) )
	{
		return false;
	}
	
	switch( mutationType )
	{
		case EPMT_Mutation4 :
		case EPMT_Mutation5 :
		case EPMT_Mutation7 :
		case EPMT_Mutation8 :
		case EPMT_Mutation10 :
		case EPMT_Mutation11 :
		case EPMT_Mutation12 :
			if( IsInFistFight() )
			{
				return false;
			}
		default:
			break;
	}
	
	if( mutationType == EPMT_Mutation1 )
	{
		sword = inv.GetCurrentlyHeldSword();			
		swordQuality = inv.GetItemQuality( sword );
		
		
		if( swordQuality < 3 )
		{
			return false;
		}
	}
	
	return true;
}

@replaceMethod(W3PlayerWitcher) function SetEquippedMutation( mutationType : EPlayerMutationType ) : bool
{
	return ( ( W3PlayerAbilityManager ) abilityManager ).SetEquippedMutation( mutationType );
}

@addMethod(W3PlayerWitcher) function spectreSetEquippedMutation( mutationType : EPlayerMutationType, unequip: bool ) : bool
{
	return ( ( W3PlayerAbilityManager ) abilityManager ).spectreSetEquippedMutation( mutationType, unequip );
}

@replaceMethod(W3PlayerWitcher) function GetEquippedMutationType() : EPlayerMutationType
{
	return ( ( W3PlayerAbilityManager ) abilityManager ).GetEquippedMutationType();
}

@addMethod(W3PlayerWitcher) function spectreGetEquippedMutations() : array<EPlayerMutationType>
{
	return ( ( W3PlayerAbilityManager ) abilityManager ).spectreGetEquippedMutations();
}

@addMethod(W3PlayerWitcher) function RemoveAllEquippedMutations() : bool
{
	return ( ( W3PlayerAbilityManager ) abilityManager ).RemoveAllEquippedMutations();
}

@addMethod(W3PlayerWitcher) function IsMutationEquipped(mutationType : EPlayerMutationType) : bool
{
	return ( ( W3PlayerAbilityManager ) abilityManager ).IsMutationEquipped(mutationType);
}

@addMethod(W3PlayerWitcher) function GetMutationSoundBank(mutationType : EPlayerMutationType) : string
{
	return ( ( W3PlayerAbilityManager ) abilityManager ).GetMutationSoundBank(mutationType);
}

@addMethod(W3PlayerWitcher) function UpdateMutationSkillSlots()
{
	( ( W3PlayerAbilityManager ) abilityManager ).UpdateMutationSkillSlots();
}

@addMethod(W3PlayerWitcher) function GetMutationColors(mutationType : EPlayerMutationType ) : array< ESkillColor >
{
	return ( ( W3PlayerAbilityManager ) abilityManager ).GetMutationColors(mutationType);
}
