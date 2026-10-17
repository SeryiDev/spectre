@wrapMethod( W3GameParams ) function InitArmorAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	ARMOR_COMMON_ABILITIES.PushBack('MA_SlashingResistance');
	ARMOR_COMMON_ABILITIES.PushBack('MA_PiercingResistance');
	ARMOR_COMMON_ABILITIES.PushBack('MA_BludgeoningResistance');
	ARMOR_COMMON_ABILITIES.PushBack('MA_RendingResistance');
	ARMOR_COMMON_ABILITIES.PushBack('MA_ElementalResistance');
	
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_Vitality');
	
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
}

@wrapMethod( W3GameParams ) function InitGlovesAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	GLOVES_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
	GLOVES_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
	GLOVES_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
	GLOVES_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');		
	
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');	
}

@wrapMethod( W3GameParams ) function InitPantsAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_Vitality');
	
	PANTS_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	PANTS_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	PANTS_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	PANTS_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	PANTS_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
}

@wrapMethod( W3GameParams ) function InitBootsAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	BOOTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
	BOOTS_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
	BOOTS_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
	BOOTS_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
	
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
}

@wrapMethod( W3GameParams ) function InitWeaponAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	WEAPON_COMMON_ABILITIES.PushBack('MA_ArmorPenetration');
	WEAPON_COMMON_ABILITIES.PushBack('MA_ArmorPenetrationPerc');
	WEAPON_COMMON_ABILITIES.PushBack('MA_AttackPowerMult');
	WEAPON_COMMON_ABILITIES.PushBack('MA_CriticalChance');
	WEAPON_COMMON_ABILITIES.PushBack('MA_CriticalDamage');
	WEAPON_COMMON_ABILITIES.PushBack('MA_AdrenalineGain');
														
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_BleedingChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_FreezingChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_PoisonChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_ConfusionChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_BurningChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_StaggerChance');
													 
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
}

@wrapMethod( W3GameParams ) function GetDurabilityMultiplier(durabilityRatio : float, isWeapon : bool) : float
{
	var currDiff : EDifficultyMode;
	
	if(false) 
	{
		wrappedMethod(durabilityRatio, isWeapon);
	}
	
	currDiff = theGame.GetDifficultyMode();
	switch( currDiff )
	{
		case EDM_Easy:
			return ClampF(1.0f - (1.0f - durabilityRatio)/4.0f, 0.8f, 1.0f);
		case EDM_Medium:
			return ClampF(1.0f - (1.0f - durabilityRatio)/4.0f, 0.7f, 1.0f);
		case EDM_Hard:
			return ClampF(1.0f - (1.0f - durabilityRatio)/2.0f, 0.6f, 1.0f);
		case EDM_Hardcore:
			return ClampF(1.0f - (1.0f - durabilityRatio)/2.0f, 0.5f, 1.0f);
		default:
			return 1.0f;
	}
}

@addMethod(W3GameParams) function GetRandomCommonArmorAbility() : name
{
	return ARMOR_COMMON_ABILITIES[RandRange(ARMOR_COMMON_ABILITIES.Size())];
}

@addMethod(W3GameParams) function GetRandomCommonWeaponAbility() : name
{
	return WEAPON_COMMON_ABILITIES[RandRange(WEAPON_COMMON_ABILITIES.Size())];
}

@wrapMethod( W3GameParams ) function GetItemLevel(itemCategory : name, itemAttributes : array<SAbilityAttributeValue>, optional itemName : name, optional out baseItemLevel : int) : int
{
	var stat : SAbilityAttributeValue;
	var stat_f : float;
	var stat1,stat2,stat3,stat4,stat5,stat6,stat7 : SAbilityAttributeValue;
	var stat_min, stat_add : float;
	var level : int;
	
	if(false) 
	{
		wrappedMethod(itemCategory, itemAttributes);
	}
	
	if ( itemCategory == 'armor' )
	{
		stat_min = 25;
		stat_add = 5;
		stat = itemAttributes[0];
		level = CeilF( ( stat.valueBase - stat_min ) / stat_add );
	} else
	if ( itemCategory == 'boots' )
	{
		stat_min = 5;
		stat_add = 2;
		stat = itemAttributes[0];
		level = CeilF( ( stat.valueBase - stat_min ) / stat_add );
	} else
	if ( itemCategory == 'gloves' )
	{
		stat_min = 1;
		stat_add = 2;
		stat = itemAttributes[0];
		level = CeilF( ( stat.valueBase - stat_min ) / stat_add ); 
	} else
	if ( itemCategory == 'pants' )
	{
		stat_min = 5;
		stat_add = 2;
		stat = itemAttributes[0];
		level = CeilF( ( stat.valueBase - stat_min ) / stat_add ); 
	} else
	if ( itemCategory == 'silversword' )
	{
		stat_min = 90;
		stat_add = 10;
		stat1 = itemAttributes[0];
		stat2 = itemAttributes[1];
		stat3 = itemAttributes[2];
		stat4 = itemAttributes[3];
		stat5 = itemAttributes[4];
		stat6 = itemAttributes[5];
		stat_f = MaxF(0, stat1.valueBase - 1) + MaxF(0, stat2.valueBase - 1) + MaxF(0, stat3.valueBase - 1) + MaxF(0, stat4.valueBase - 1) + MaxF(0, stat5.valueBase - 1) + MaxF(0, stat6.valueBase - 1);
		level = CeilF( ( stat_f - stat_min ) / stat_add );  
	} else
	if ( itemCategory == 'steelsword' )
	{
		stat_min = 25;
		stat_add = 8;
		stat1 = itemAttributes[0];
		stat2 = itemAttributes[1];
		stat3 = itemAttributes[2];
		stat4 = itemAttributes[3];
		stat5 = itemAttributes[4];
		stat6 = itemAttributes[5];
		stat7 = itemAttributes[6];
		stat_f = MaxF(0, stat1.valueBase - 1) + MaxF(0, stat2.valueBase - 1) + MaxF(0, stat3.valueBase - 1) + MaxF(0, stat4.valueBase - 1) + MaxF(0, stat5.valueBase - 1) + MaxF(0, stat6.valueBase - 1) + MaxF(0, stat7.valueBase - 1);
		level = CeilF( ( stat_f - stat_min ) / stat_add );  
	} else
	if ( itemCategory == 'bolt' )
	{
		if ( itemName == 'Tracking Bolt' ) { level = 2; } else
		if ( itemName == 'Bait Bolt' ) { level = 2; }  else
		if ( itemName == 'Blunt Bolt' ) { level = 2; }  else
		if ( itemName == 'Broadhead Bolt' ) { level = 10; }  else
		if ( itemName == 'Target Point Bolt' ) { level = 5; }  else
		if ( itemName == 'Split Bolt' ) { level = 15; }  else
		if ( itemName == 'Explosive Bolt' ) { level = 20; }  else
		if ( itemName == 'Broadhead Bolt Legendary' ) { level = 20; }  else
		if ( itemName == 'Target Point Bolt Legendary' ) { level = 15; }  else
		if ( itemName == 'Blunt Bolt Legendary' ) { level = 12; }  else
		if ( itemName == 'Split Bolt Legendary' ) { level = 24; }  else
		if ( itemName == 'Explosive Bolt Legendary' ) { level = 26; } 
	} else
	if ( itemCategory == 'crossbow' )
	{
		stat = itemAttributes[0];
		level = 1;
		if ( stat.valueMultiplicative > 1.01 ) level = 2;
		if ( stat.valueMultiplicative > 1.1 ) level = 4;
		if ( stat.valueMultiplicative > 1.2 ) level = 8;
		if ( stat.valueMultiplicative > 1.3 ) level = 11;
		if ( stat.valueMultiplicative > 1.4 ) level = 15;
		if ( stat.valueMultiplicative > 1.5 ) level = 19;
		if ( stat.valueMultiplicative > 1.6 ) level = 22;
		if ( stat.valueMultiplicative > 1.7 ) level = 25;
		if ( stat.valueMultiplicative > 1.8 ) level = 27;
		if ( stat.valueMultiplicative > 1.9 ) level = 32;
		
		if ( stat.valueMultiplicative > 2.0 ) level = 34;
		if ( stat.valueMultiplicative > 2.1 ) level = 38;
	} 
	level = Clamp(level, 1, GetWitcherPlayer().GetMaxLevel());
	
	return level;
}
