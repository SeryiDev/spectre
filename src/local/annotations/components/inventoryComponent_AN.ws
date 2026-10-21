@addMethod(CInventoryComponent) function spectreIsItemWeaponUpgrade(item : SItemUniqueId) : bool							
{
	return ItemHasTag(item, 'WeaponUpgrade');
}

@addMethod(CInventoryComponent) function spectreIsItemArmorUpgrade(item : SItemUniqueId) : bool							
{
	return ItemHasTag(item, 'ArmorUpgrade');
}

@addMethod(CInventoryComponent) function spectreIsItemWeaponRepairKit(item : SItemUniqueId) : bool							
{
	return (ItemHasTag(item, 'RepairSteel') || ItemHasTag(item, 'RepairSilver'));
}

@addMethod(CInventoryComponent) function spectreIsItemArmorRepairKit(item : SItemUniqueId) : bool							
{
	return ItemHasTag(item, 'RepairArmor');
}


@wrapMethod(CInventoryComponent) function GetDaysToIncreaseFunds() : int
{
	if(false) 
	{
		wrappedMethod();
	}
	
	return 3;
}

@wrapMethod(CInventoryComponent) function GetItemLevel(item : SItemUniqueId) : int
{
	var itemCategory : name;
	var itemAttributes : array<SAbilityAttributeValue>;
	var itemName : name;
	var isWitcherGear : bool;
	var isRelicGear : bool;
	var level: int;
	
	if(false) 
	{
		wrappedMethod(item);
	}

	itemCategory = GetItemCategory(item);
	itemName = GetItemName(item);
	
	isWitcherGear = false;
	isRelicGear = false;
	if ( RoundMath(CalculateAttributeValue( GetItemAttributeValue(item, 'quality' ) )) == 5 ) isWitcherGear = true;
	if ( RoundMath(CalculateAttributeValue( GetItemAttributeValue(item, 'quality' ) )) == 4 ) isRelicGear = true;
									 
	switch(itemCategory)
	{
		case 'armor' :
		case 'boots' : 
		case 'gloves' :
		case 'pants' :
			itemAttributes.PushBack( GetItemAttributeValue(item, 'armor') );
			break;
			
		case 'silversword' :
			itemAttributes.PushBack( GetItemAttributeValue(item, 'SilverDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'BludgeoningDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'RendingDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'ElementalDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'FireDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'PiercingDamage') );
			break;
			
		case 'steelsword' :
			itemAttributes.PushBack( GetItemAttributeValue(item, 'SlashingDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'BludgeoningDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'RendingDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'ElementalDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'FireDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'SilverDamage') );
			itemAttributes.PushBack( GetItemAttributeValue(item, 'PiercingDamage') );
			break;
			
		case 'crossbow' :
			itemAttributes.PushBack( GetItemAttributeValue(item, 'attack_power') );
			break;

		default :
			break;
	}
	
	level = theGame.params.GetItemLevel(itemCategory, itemAttributes, itemName); 
	
	
	return level;
}

@addMethod(CInventoryComponent) function AddMasterArmorerItems()
{
	if(FactsDoesExist("sq108_master_bsmith_helped"))
	{
		AddItemsFromLootDefinition('_store__Master_Armorsmith_Yoana');
	}
}

@wrapMethod(CInventoryComponent) function GiveItemTo( otherInventory : CInventoryComponent, itemId : SItemUniqueId, optional quantity : int, optional refreshNewFlag : bool, optional forceTransferNoDrops : bool, optional informGUI : bool ) : SItemUniqueId
{
	var arr : array<SItemUniqueId>;
	var itemName : name;
	var i : int;
	var uiData : SInventoryItemUIData;
	var isQuestItem : bool;
	
	if(false) 
	{
		wrappedMethod( otherInventory, itemId, quantity, refreshNewFlag, forceTransferNoDrops, informGUI );
	}
	
	
	if(quantity == 0)
		quantity = 1;
	
	quantity = Clamp(quantity, 0, GetItemQuantity(itemId));		
	if(quantity == 0)
		return GetInvalidUniqueId();
		
	itemName = GetItemName(itemId);
	
	if(!forceTransferNoDrops && ( ItemHasTag(itemId, 'NoDrop') && !ItemHasTag(itemId, 'Lootable') ))
	{
		LogItems("Cannot transfer item <<" + itemName + ">> as it has the NoDrop tag set!!!");
		return GetInvalidUniqueId();
	}
	
	
	if(IsItemSingletonItem(itemId))
	{
		
		if(otherInventory == thePlayer.inv && otherInventory.GetItemQuantityByName(itemName) > 0)
		{
			LogAssert(false, "CInventoryComponent.GiveItemTo: cannot add singleton item as player already has this item!");
			
			GetWitcherPlayer().DisplayHudMessage(GetLocStringByKeyExt("panel_alchemy_exception_already_cooked")); 
			return GetInvalidUniqueId();
		}
		
		else
		{
			arr = GiveItem(otherInventory, itemId, quantity, informGUI);
		}			
	}
	else
	{
		
		if ( CanItemHaveOil(itemId) )
		{
			RemoveAllOilsFromItem(itemId);
			RemoveAllOilAbilitiesFromItem(itemId);
		}
		arr = GiveItem(otherInventory, itemId, quantity, informGUI);
	}
	
	
	if(otherInventory == thePlayer.inv)
	{
		isQuestItem = this.IsItemQuest( itemId );
		theTelemetry.LogWithLabelAndValue(TE_INV_ITEM_PICKED, itemName, quantity);
		
		if ( !theGame.AreSavesLocked() && ( isQuestItem || this.GetItemQuality( itemId ) >= 4 ) )
		{
			theGame.RequestAutoSave( "item gained", false );
		}
	}
	
	if (refreshNewFlag)
	{
		for (i = 0; i < arr.Size(); i += 1)
		{
			uiData = otherInventory.GetInventoryItemUIData( arr[i] );
			uiData.isNew = true;
			otherInventory.SetInventoryItemUIData( arr[i], uiData );
		}
	}
	
	return arr[0];
}

@addField(CInventoryComponent)
protected var tempTransferredItems : array< SItemUniqueId >;
	
@addMethod(CInventoryComponent) function IsItemTempTransferred( item : SItemUniqueId ) : bool
{
	return tempTransferredItems.Contains( item );
}

@addMethod(CInventoryComponent) function TransferStashItemsTo()
{
	var stashInv : CInventoryComponent;
	var rawItems, arr : array< SItemUniqueId >;
	var item : SItemUniqueId;
	var i : int;

	if( GetEntity() != GetWitcherPlayer() )
		return;
		
	if( tempTransferredItems.Size() != 0 )
		return;
	
	stashInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
	stashInv.GetAllItems( rawItems );
	for( i = 0; i < rawItems.Size(); i += 1 )
	{
		item = rawItems[i];
		if( !HasItem( stashInv.GetItemName( item ) ) && stashInv.CanTransferItem( item ) )
		{
			arr = stashInv.GiveItem( this, item, stashInv.GetItemQuantity( item ) );
		}
	}
	tempTransferredItems = arr;
}

@addMethod(CInventoryComponent) function CanTransferItem( item : SItemUniqueId ) : bool
{
	if( ItemHasTag( item, theGame.params.TAG_DONT_SHOW ) || ItemHasTag( item, theGame.params.TAG_DONT_SHOW_ONLY_IN_PLAYERS ) )
		return false;
	
	if( GetItemName( item ) == 'Crowns' )
		return false;
	
	if( IsItemHorseItem( item ) && GetWitcherPlayer().GetHorseManager().IsItemEquipped( item ) )
		return false;
	
	if( GetEntity() == GetWitcherPlayer() && GetWitcherPlayer().IsItemEquipped( item ) )
		return false;
	
	return true;
}

@addMethod(CInventoryComponent) function TransferStashItemsFrom()
{
	var stashInv : CInventoryComponent;
	var arr : array< SItemUniqueId >;
	var item : SItemUniqueId;
	var i : int;
	
	if( tempTransferredItems.Size() == 0 )
		return;
		
	stashInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
	for( i = 0; i < tempTransferredItems.Size(); i += 1 )
	{
		item = tempTransferredItems[i];
		arr = GiveItem( stashInv, item, GetItemQuantity( item ) );
	}
	tempTransferredItems.Clear();
}

@wrapMethod(CInventoryComponent) function ClearKnownRecipes()
{
	var witcher : W3PlayerWitcher;
	var recipes, craftRecipes : array<name>;
	var i : int;
	var itemName : name;
	var allItems : array<SItemUniqueId>;
	var id : SItemUniqueId;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	witcher = GetWitcherPlayer();
	if(!witcher)
		return;	
	
	
	recipes = witcher.GetAlchemyRecipes();
	craftRecipes = witcher.GetCraftingSchematicsNames();
	ArrayOfNamesAppend(recipes, craftRecipes);
	
	
	GetAllItems(allItems);
	
	
	for(i=allItems.Size()-1; i>=0; i-=1)
	{
		id = allItems[i];
		itemName = GetItemName(id);
		if(recipes.Contains(itemName))
			RemoveItem(id, GetItemQuantity(id));
	}
}

@addMethod(CInventoryComponent) function ClearLowLevelWeapons()
{
	var witcher : W3PlayerWitcher;
	var i : int;
	var allItems : array<SItemUniqueId>;
	var id : SItemUniqueId;
	var witcherLevel: int;

	witcher = GetWitcherPlayer();
	if(!witcher)
		return;

	allItems = GetAllWeapons();
	witcherLevel = witcher.GetLevel();

	for(i=allItems.Size()-1; i>=0; i-=1)
	{
		id = allItems[i];
		if(witcherLevel - GetItemLevel(id) > 3)
			RemoveItem(id, GetItemQuantity(id));
	}
}

@wrapMethod(CInventoryComponent) function RecycleItem( id : SItemUniqueId, level : ECraftsmanLevel ) :  array<SItemUniqueId>
{
	var itemsAdded : array<SItemUniqueId>;
	var currentAdded : array<SItemUniqueId>;
	var parts : array<SItemParts>;
	var i : int;
	var dontMarkAsNew : bool;
	
	if(false) 
	{
		wrappedMethod(id, level);
	}
	
	if( this == GetWitcherPlayer().GetInventory() )
		dontMarkAsNew = false;
	else
		dontMarkAsNew = true;
	
	parts = GetItemRecyclingParts( id );
	
	for ( i = 0; i < parts.Size(); i += 1 )
	{
		currentAdded = AddAnItem( parts[i].itemName, parts[i].quantity, , dontMarkAsNew );
		itemsAdded.PushBack(currentAdded[0]);
	}

	RemoveItem(id);
	
	return itemsAdded;
}

@addMethod(CInventoryComponent) function ItemHasRecyclingParts( id : SItemUniqueId ) : bool
{
	var parts : array<SItemParts>;
	parts = GetItemRecyclingParts( id );
	return parts.Size() > 0;
}

@addMethod(CInventoryComponent) function RemoveAllOilAbilitiesFromItem( id : SItemUniqueId )
{
	RemoveItemCraftedAbility( id, 'BeastOil_1');
	RemoveItemCraftedAbility( id, 'BeastOil_2');
	RemoveItemCraftedAbility( id, 'BeastOil_3');
	RemoveItemCraftedAbility( id, 'CursedOil_1');
	RemoveItemCraftedAbility( id, 'CursedOil_2');
	RemoveItemCraftedAbility( id, 'CursedOil_3');
	RemoveItemCraftedAbility( id, 'HangedManVenom_1');
	RemoveItemCraftedAbility( id, 'HangedManVenom_2');
	RemoveItemCraftedAbility( id, 'HangedManVenom_3');
	RemoveItemCraftedAbility( id, 'HybridOil_1');
	RemoveItemCraftedAbility( id, 'HybridOil_2');
	RemoveItemCraftedAbility( id, 'HybridOil_3');
	RemoveItemCraftedAbility( id, 'InsectoidOil_1');
	RemoveItemCraftedAbility( id, 'InsectoidOil_2');
	RemoveItemCraftedAbility( id, 'InsectoidOil_3');
	RemoveItemCraftedAbility( id, 'MagicalsOil_1');
	RemoveItemCraftedAbility( id, 'MagicalsOil_2');
	RemoveItemCraftedAbility( id, 'MagicalsOil_3');
	RemoveItemCraftedAbility( id, 'NecrophageOil_1');
	RemoveItemCraftedAbility( id, 'NecrophageOil_2');
	RemoveItemCraftedAbility( id, 'NecrophageOil_3');
	RemoveItemCraftedAbility( id, 'SpecterOil_1');
	RemoveItemCraftedAbility( id, 'SpecterOil_2');
	RemoveItemCraftedAbility( id, 'SpecterOil_3');
	RemoveItemCraftedAbility( id, 'VampireOil_1');
	RemoveItemCraftedAbility( id, 'VampireOil_2');
	RemoveItemCraftedAbility( id, 'VampireOil_3');
	RemoveItemCraftedAbility( id, 'DraconideOil_1');
	RemoveItemCraftedAbility( id, 'DraconideOil_2');
	RemoveItemCraftedAbility( id, 'DraconideOil_3');
	RemoveItemCraftedAbility( id, 'OgreOil_1');
	RemoveItemCraftedAbility( id, 'OgreOil_2');
	RemoveItemCraftedAbility( id, 'OgreOil_3');
	RemoveItemCraftedAbility( id, 'RelicOil_1');
	RemoveItemCraftedAbility( id, 'RelicOil_2');
	RemoveItemCraftedAbility( id, 'RelicOil_3');
}

@addMethod(CInventoryComponent) function GetOilAttackPowerBonus( weaponId : SItemUniqueId, monsterCategory : EMonsterCategory ) : SAbilityAttributeValue
{
	var i : int;
	var oils : array< W3Effect_Oil >;
	var attrVal : SAbilityAttributeValue;
	
	oils = GetOilsAppliedOnItem( weaponId );
	for( i = 0; i < oils.Size(); i += 1 )
	{
		attrVal += oils[ i ].GetAttackPowerBonus( monsterCategory );
	}
	return attrVal;
}

@addMethod(CInventoryComponent) function GetOilResistReductionBonus( weaponId : SItemUniqueId, monsterCategory : EMonsterCategory ) : SAbilityAttributeValue
{
	var i : int;
	var oils : array< W3Effect_Oil >;
	var attrVal : SAbilityAttributeValue;
	
	oils = GetOilsAppliedOnItem( weaponId );
	for( i = 0; i < oils.Size(); i += 1 )
	{
		attrVal += oils[ i ].GetResistReductionBonus( monsterCategory );
	}
	return attrVal;
}

@addMethod(CInventoryComponent) function GetOilCriticalChanceBonus( weaponId : SItemUniqueId, monsterCategory : EMonsterCategory ) : SAbilityAttributeValue
{
	var i : int;
	var oils : array< W3Effect_Oil >;
	var attrVal : SAbilityAttributeValue;
	
	oils = GetOilsAppliedOnItem( weaponId );
	for( i = 0; i < oils.Size(); i += 1 )
	{
		attrVal += oils[ i ].GetCriticalChanceBonus( monsterCategory );
	}
	return attrVal;
}

@addMethod(CInventoryComponent) function GetOilCriticalDamageBonus( weaponId : SItemUniqueId, monsterCategory : EMonsterCategory ) : SAbilityAttributeValue
{
	var i : int;
	var oils : array< W3Effect_Oil >;
	var attrVal : SAbilityAttributeValue;
	
	oils = GetOilsAppliedOnItem( weaponId );
	for( i = 0; i < oils.Size(); i += 1 )
	{
		attrVal += oils[ i ].GetCriticalDamageBonus( monsterCategory );
	}
	return attrVal;
}

@addMethod(CInventoryComponent) function GetOilProtectionAgainstMonster( weaponId : SItemUniqueId, monsterCategory : EMonsterCategory ) : float
{
	var i : int;
	var oils : array< W3Effect_Oil >;
	var bonus : float;
	
	oils = GetOilsAppliedOnItem( weaponId );
	for( i = 0; i < oils.Size(); i += 1 )
	{
		bonus += oils[ i ].GetProtectionAgainstMonster( monsterCategory );
	}
	return bonus;
}

@addMethod(CInventoryComponent) function GetOilPoisonChanceAgainstMonster( weaponId : SItemUniqueId, monsterCategory : EMonsterCategory ) : float
{
	var i : int;
	var oils : array< W3Effect_Oil >;
	var bonus : float;
	
	oils = GetOilsAppliedOnItem( weaponId );
	for( i = 0; i < oils.Size(); i += 1 )
	{
		bonus += oils[ i ].GetPoisonChanceAgainstMonster( monsterCategory );
	}
	return bonus;
}

@wrapMethod(CInventoryComponent) function GetParamsForRunewordTooltip(runewordName : name, out i : array<int>, out f : array<float>, out s : array<string>)
{
	var min, max : SAbilityAttributeValue;
	var val : float;
	var attackRangeBase, attackRangeExt : CAIAttackRange;
	
	if(false) 
	{
		wrappedMethod(runewordName, i, f, s);
	}
	
	i.Clear();
	f.Clear();
	s.Clear();
	
	switch(runewordName)
	{
		case 'Glyphword 2':
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 2 _Stats', 'glyphword2_mod', min, max);
			i.PushBack( RoundMath( CalculateAttributeValue(min) * 100) );
			i.PushBack( RoundMath( CalculateAttributeValue(min) * 100) );
			break;
		case 'Glyphword 3':
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 3 _Stats', 'glyphword3_mod', min, max);
			i.PushBack( RoundMath( CalculateAttributeValue(min) * 100) );
			i.PushBack( RoundMath( CalculateAttributeValue(min) * 100) );
			break;
		case 'Glyphword 4':
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 4 _Stats', 'glyphword4_mod', min, max);
			i.PushBack( RoundMath( CalculateAttributeValue(min) * 100) );
			i.PushBack( RoundMath( CalculateAttributeValue(min) * 100) );
			break;
		case 'Glyphword 5':
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 5 _Stats', 'glyphword5_dmg_boost', min, max);
			i.PushBack( RoundMath(min.valueMultiplicative * 100) );
			break;
		case 'Glyphword 6' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 6 _Stats', 'glyphword6_stamina_drain_perc', min, max);				
			i.PushBack( RoundMath( CalculateAttributeValue(min) * 100) );
			break;
		case 'Glyphword 7' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 7 _Stats', 'glyphword7_dmg_buff', min, max);
			i.PushBack( RoundMath( CalculateAttributeValue(min) ) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 7 _Stats', 'glyphword7_burnchance_debuff', min, max);
			i.PushBack( -1 * RoundMath( CalculateAttributeValue(min) * 100 ) );
			break;
		case 'Glyphword 10' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 10 abl', 'attack_power', min, max);
			i.PushBack( RoundMath( min.valueMultiplicative*100 ) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 10 abl', 'g10_max_stacks', min, max);
			i.PushBack( RoundMath( i[0]*CalculateAttributeValue(min) ) );
			break;
		case 'Glyphword 12' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 12 _Stats', 'glyphword12_range', min, max);
			val = CalculateAttributeValue(min);
			s.PushBack( NoTrailZeros(val) );
			
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 12 _Stats', 'glyphword12_chance', min, max);
			i.PushBack( RoundMath( min.valueAdditive * 100) );
			break;
		case 'Glyphword 14' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 14 abl', 'critical_hit_chance', min, max);
			i.PushBack( RoundMath( min.valueAdditive*100 ) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 14 abl', 'g14_max_stacks', min, max);
			i.PushBack( RoundMath( i[0]*CalculateAttributeValue(min) ) );
			break;
		case 'Glyphword 15' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 15 _Stats', 'glyphword15_range', min, max);
			val = CalculateAttributeValue(min);
			s.PushBack( NoTrailZeros(val) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 15 _Stats', 'glyphword15_duration', min, max);
			val = CalculateAttributeValue(min);
			s.PushBack( NoTrailZeros(val) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 15 _Stats', 'glyphword15_slow_cap', min, max);
			val = CalculateAttributeValue(min);
			s.PushBack( NoTrailZeros(val * 100) );
			break;
		case 'Glyphword 17' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 17 _Stats', 'glyphword17_quen_buff', min, max);
			val = CalculateAttributeValue(min);
			i.PushBack( RoundMath(val * 100) );
			break;				
		case 'Glyphword 18' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 18 _Stats', 'increas_duration', min, max);
			val = CalculateAttributeValue(min);
			s.PushBack( NoTrailZeros(val) );
			break;
		case 'Glyphword 20' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 20 _Stats', 'FireDamage', min, max);
			val = CalculateAttributeValue(min);
			i.PushBack( RoundMath(val) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 20 _Stats', 'radius', min, max);
			val = CalculateAttributeValue(min);
			i.PushBack( RoundMath(val) );
			break;
			
		case 'Runeword 1' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 1 _Stats', 'runeword1_fire_dmg', min, max);
			s.PushBack( NoTrailZeros(min.valueMultiplicative * 100) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 1 _Stats', 'runeword1_yrden_duration', min, max);
			s.PushBack( NoTrailZeros(min.valueAdditive) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 1 _Stats', 'runeword1_quen_heal', min, max);
			s.PushBack( NoTrailZeros(min.valueMultiplicative * 100) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 1 _Stats', 'runeword1_confusion_duration', min, max);
			s.PushBack( NoTrailZeros(min.valueAdditive) );
			break;
		case 'Runeword 2' :
			attackRangeBase = theGame.GetAttackRangeForEntity(GetWitcherPlayer(), 'specialattacklight');
			attackRangeExt = theGame.GetAttackRangeForEntity(GetWitcherPlayer(), 'runeword2_light');				
			s.PushBack( NoTrailZeros(attackRangeExt.rangeMax - attackRangeBase.rangeMax) );
			
			attackRangeBase = theGame.GetAttackRangeForEntity(GetWitcherPlayer(), 'slash_long');
			attackRangeExt = theGame.GetAttackRangeForEntity(GetWitcherPlayer(), 'runeword2_heavy');				
			s.PushBack( NoTrailZeros(attackRangeExt.rangeMax - attackRangeBase.rangeMax) );
			
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 2 _Stats', 'runeword2_damage_debuff', min, max);
			val = CalculateAttributeValue(min * 100);
			s.PushBack( NoTrailZeros(val) );
			break;
		case 'Runeword 4' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 4 _Stats', 'dmg_gain_rate', min, max);
			i.PushBack( RoundMath(max.valueMultiplicative) );	
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 4 _Stats', 'max_bonus', min, max);
			i.PushBack( RoundMath(max.valueMultiplicative * 100) );	
			break;
		case 'Runeword 6' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 6 _Stats', 'runeword6_duration_bonus', min, max );
			i.PushBack( RoundMath(min.valueMultiplicative * 100) );
			break;
		case 'Runeword 7' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 7 _Stats', 'stamina', min, max );
			i.PushBack( RoundMath(min.valueMultiplicative * 100) );
			break;
		case 'Runeword 8' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 8 Regen', 'focus_drain', min, max );
			s.PushBack( NoTrailZeros(min.valueMultiplicative) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 8 Regen', 'vitalityCombatRegen', min, max );
			s.PushBack( NoTrailZeros(min.valueMultiplicative * 100) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 8 Regen', 'staminaRegen', min, max );
			s.PushBack( NoTrailZeros(min.valueMultiplicative * 100) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 8 Regen', 'toxicityRegen', min, max );
			s.PushBack( NoTrailZeros(-1 * min.valueAdditive) );
			break;
		case 'Runeword 10' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 10 _Stats', 'health', min, max );
			i.PushBack( RoundMath(min.valueMultiplicative * 100) );
			break;
		case 'Runeword 11' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 11 _Stats', 'duration_gain_rate', min, max );
			s.PushBack( NoTrailZeros(max.valueMultiplicative) );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 11 _Stats', 'max_bonus', min, max );
			s.PushBack( NoTrailZeros(max.valueMultiplicative * 100) );
			break;
		case 'Runeword 12' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 12 _Stats', 'focus', min, max );
			f.PushBack(min.valueAdditive);
			break;
		case 'Runeword 13' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 13 _Stats', 'duration', min, max );
			s.PushBack( NoTrailZeros(min.valueAdditive) );
			break;
		case 'Runeword 14' :
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 13 _Stats', 'duration', min, max );
			s.PushBack( NoTrailZeros(min.valueAdditive) );
			break;
		default:
			break;
	}
}

@wrapMethod(CInventoryComponent) function GetPotionAttributesForTooltip(itemID : SItemUniqueId, out tips : array<SAttributeTooltip>)
{
	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
	{
		wrappedMethod(itemID, tips);
		return;
	}
	GetPotionAttributesByName(GetItemName(itemID), tips);
}

@addMethod(CInventoryComponent) function GetPotionAttributesByName(itemName : name, out tips : array<SAttributeTooltip>)
{
	var dm			: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
	var abs1, abs	: array<name>;
	var weights		: array<float>;
	var i, j, k		: int;
	var buffType	: EEffectType;
	var abilityName	: name;
	var attrs		: array<name>;
	var val			: SAbilityAttributeValue;
	var newAttr		: SAttributeTooltip;
	var min, max	: SAbilityAttributeValue;
	
	if(!dm.ItemHasTag(itemName, 'Potion') && !dm.ItemHasTag(itemName, 'Edibles') && !dm.ItemHasTag(itemName, 'Drinks'))
		return;
	
	if(dm.ItemHasTag(itemName, 'Mutagen'))
		return;
		
	dm.GetItemAbilitiesWithWeights(itemName, GetEntity() == thePlayer, abs1, weights, i, j);
	
	for(j = 0; j < abs1.Size(); j += 1)
	{
		abs.Clear();
		dm.GetContainedAbilities(abs1[j], abs);
			
		for(i = 0; i < abs.Size(); i += 1)
		{
			EffectNameToType(abs[i], buffType, abilityName);
			
			if(buffType != EET_Undefined)
			{
				attrs.Clear();
				dm.GetAbilityAttributes(abs[i], attrs);
	 
				attrs.Remove('duration');
				attrs.Remove('level');
				
				if(buffType == EET_Cat)
				{

					attrs.Remove('highlightObjectsRange');
				}
				else if(buffType == EET_MariborForest)
				{
					attrs.Remove('focus_on_drink');
				}
				else if(buffType == EET_KillerWhale)
				{
					attrs.Remove('swimmingStamina');
					attrs.Remove('vision_strength');
				}
				else if(buffType == EET_Thunderbolt)
				{
					attrs.Remove('critical_hit_chance');
				}
				else if(buffType == EET_WhiteRaffardDecoction)
				{
					dm.GetAbilityAttributeValue(abs1[j], 'level', min, max);
					if(min.valueAdditive == 3)
						attrs.Insert(0, 'duration');
				}
				
				for(k = 0; k < attrs.Size(); k += 1)
				{
					dm.GetAbilityAttributeValue(abs[i], attrs[k], min, max);
					val = GetAttributeRandomizedValue(min, max);
					
					newAttr.originName = attrs[k];
					newAttr.attributeName = GetAttributeNameLocStr(attrs[k], false);
					
					if(buffType == EET_MariborForest && attrs[k] == 'focus_gain')
					{
						newAttr.value = val.valueAdditive;
						newAttr.percentageValue = true;
					}
					else if(buffType == EET_GoldenOriole && attrs[k] == 'poison_resistance_perc')
					{
						newAttr.value = val.valueAdditive;
						newAttr.percentageValue = true;
					}
					else if(buffType == EET_Swallow && attrs[k] == 'bleeding_resistance_perc')
					{
						newAttr.value = val.valueAdditive;
						newAttr.percentageValue = true;
					}
					else if(val.valueMultiplicative != 0)
					{
						newAttr.value = val.valueMultiplicative;
						newAttr.percentageValue = true;
					}
					else if(val.valueAdditive != 0)
					{
						if(buffType == EET_Thunderbolt)
						{
							newAttr.value = val.valueAdditive * 100;
							newAttr.percentageValue = true;
						}
						else if(buffType == EET_Blizzard)
						{
							newAttr.value = 1 - val.valueAdditive;
							newAttr.percentageValue = true;
						}
						else
						{
							newAttr.value = val.valueAdditive;
							newAttr.percentageValue = false;
						}
					}
					else
					{
						newAttr.value = val.valueBase;
						newAttr.percentageValue = false;
					}
					
					tips.PushBack(newAttr);
				} 

				// Alchemy 5.01 variant: the 5.01 values, without Spectre's duration.
				if (IsItemPotion(GetItemId(itemName)) && !spectreAlchemy501()) 
				{
					theGame.alchexts.ChangePotionTooltipData(GetItemId(itemName), tips);
				}
			}
		}
	}
}

@addMethod(CInventoryComponent) function FillInMutagenDescription(potionId : SItemUniqueId, out uniqueDescription : string)
{
	var i			: int;
	var buffType	: EEffectType;
	var abilityName	: name;
	var abs			: array<name>;
	
	if(!ItemHasTag(potionId, 'Mutagen'))
		return;
		
	GetItemContainedAbilities(potionId, abs);
	
	for(i = 0; i < abs.Size(); i += 1)
	{
		EffectNameToType(abs[i], buffType, abilityName);
		
		if(buffType != EET_Undefined)
			break;
	}
	
	FillInMutagenDescriptionFromBuffType(buffType, GetItemLocalizedDescriptionByUniqueID(potionId), uniqueDescription);
}

@addMethod(CInventoryComponent) function FillInMutagenDescriptionByName(potionName : name, out uniqueDescription : string)
{
	var i, j		: int;
	var buffType	: EEffectType;
	var abilityName	: name;
	var abs1, abs2	: array<name>;
	var dm			: CDefinitionsManagerAccessor;
	var weights		: array<float>;
	var tmpI, tmpJ	: int;
	
	dm = theGame.GetDefinitionsManager();
	
	if(!dm.ItemHasTag(potionName, 'Mutagen'))
		return;
		
	dm.GetItemAbilitiesWithWeights(potionName, GetEntity() == thePlayer, abs1, weights, tmpI, tmpJ);
	
	for(i = 0; i < abs1.Size(); i += 1)
	{
		dm.GetContainedAbilities(abs1[i], abs2);
			
		for(j = 0; j < abs2.Size(); j += 1)
		{
			EffectNameToType(abs2[j], buffType, abilityName);
			
			if(buffType != EET_Undefined)
				break;
		}
		
		if(buffType != EET_Undefined)
			break;
	}
	
	FillInMutagenDescriptionFromBuffType(buffType, GetItemLocalizedDescriptionByName(potionName), uniqueDescription);
}

@addMethod(CInventoryComponent) function FillInMutagenDescriptionFromBuffType(buffType : EEffectType, locKey : string, out uniqueDescription : string)
{
	var min, max	: SAbilityAttributeValue;
	var argsInt 	: array<int>;
	var argsFloat	: array<float>;
	var argsString	: array<string>;
	var dm			: CDefinitionsManagerAccessor;
	var floatVal	: float;
	
	dm = theGame.GetDefinitionsManager();
															   
	switch(buffType)
	{
		case EET_Mutagen01:
			dm.GetAbilityAttributeValue('Mutagen01Effect', 'critical_hit_chance', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			dm.GetAbilityAttributeValue('Mutagen01Effect', 'mutagen01_max_stack', min, max);
			argsInt.PushBack(RoundMath(argsInt[0] * min.valueAdditive));
			dm.GetAbilityAttributeValue('KatakanBonusEffect', 'critical_hit_damage_bonus', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen02:
			dm.GetAbilityAttributeValue('Mutagen02Effect', 'mutagen02_resist_reduction', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			dm.GetAbilityAttributeValue('Mutagen02Effect', 'mutagen02_max_stack', min, max);
			argsInt.PushBack(RoundMath(argsInt[0] * min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen04:
			dm.GetAbilityAttributeValue('Mutagen04Effect', 'attackCostIncrease', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive * 100));
			dm.GetAbilityAttributeValue('Mutagen04Effect', 'healthReductionPerc', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen05:
			dm.GetAbilityAttributeValue('Mutagen05Effect', 'attack_power', min, max);
			floatVal = min.valueMultiplicative * 100;
			dm.GetAbilityAttributeValue('Mutagen05Effect', 'mutagen05_buff_rate', min, max);
			argsString.PushBack(NoTrailZeros(floatVal * min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen05Effect', 'mutagen05_max_stack', min, max);
			argsString.PushBack(NoTrailZeros(floatVal * min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen05Effect', 'mutagen05_debuff_rate', min, max);
			argsString.PushBack(NoTrailZeros(floatVal * min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen06:
			dm.GetAbilityAttributeValue('Mutagen06Effect', 'vitality', min, max);
			argsString.PushBack(NoTrailZeros(min.valueBase));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen07:
			dm.GetAbilityAttributeValue('Mutagen07Effect', 'lifeLeech', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen09:
			dm.GetAbilityAttributeValue('Mutagen09Effect', 'mutagen09_bonus_lesser', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen09Effect', 'mutagen09_bonus_medium', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen09Effect', 'mutagen09_bonus_greater', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen10:
			dm.GetAbilityAttributeValue('Mutagen10Effect', 'attack_power', min, max);
			floatVal = min.valueMultiplicative;
			argsInt.PushBack(RoundMath(floatVal * 100));
			dm.GetAbilityAttributeValue('Mutagen10Effect', 'mutagen10_max_stack', min, max);
			argsInt.PushBack(RoundMath(floatVal * 100 * min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen11:
			dm.GetAbilityAttributeValue('Mutagen11Effect', 'damageIncrease', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen12:
			dm.GetAbilityAttributeValue('Mutagen12Effect', 'vitalityRegen', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen12Effect', 'vitalityCombatRegen', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen12Effect', 'm12_threshold', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			dm.GetAbilityAttributeValue('TrollBonusEffect', 'vitalityCombatRegen', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen13:
			dm.GetAbilityAttributeValue('Mutagen13Effect', 'staminaRegen', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen13Effect', 'mutagen13_max_stack', min, max);
			argsInt.PushBack(RoundMath(argsInt[0] * min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen14:
			dm.GetAbilityAttributeValue('Mutagen14Effect', 'mutagen14_bonus', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen15:
			dm.GetAbilityAttributeValue('Mutagen15Effect', 'focus_gain', min, max);
			floatVal = min.valueAdditive * 100;
			dm.GetAbilityAttributeValue('Mutagen15Effect', 'mutagen15_buff_rate', min, max);
			argsString.PushBack(NoTrailZeros(floatVal * min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen15Effect', 'mutagen15_max_stack', min, max);
			argsString.PushBack(NoTrailZeros(floatVal * min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen15Effect', 'mutagen15_debuff_rate', min, max);
			argsString.PushBack(NoTrailZeros(floatVal * min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen16:
			dm.GetAbilityAttributeValue('Mutagen16Effect', 'mutagen16_health_prc', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen17:
			dm.GetAbilityAttributeValue('Mutagen17Effect', 'spell_power', min, max);
			argsInt.PushBack(RoundMath(min.valueMultiplicative * 100));
			dm.GetAbilityAttributeValue('Mutagen17Effect', 'mutagen17_max_stack', min, max);
			argsInt.PushBack(RoundMath(argsInt[0] * min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen18:
			dm.GetAbilityAttributeValue('Mutagen18Effect', 'vitalityCombatRegen', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen18Effect', 'mutagen18_max_stack', min, max);
			argsInt.PushBack(RoundMath(argsInt[0] * min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen19:
			dm.GetAbilityAttributeValue('Mutagen19Effect', 'quen_power_bonus', min, max);
			argsString.PushBack(NoTrailZeros(min.valueMultiplicative * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen20:
			dm.GetAbilityAttributeValue('Mutagen20Effect', 'fire_resistance_perc', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen21:
			dm.GetAbilityAttributeValue('Mutagen21Effect', 'healingRatio', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen22:
			dm.GetAbilityAttributeValue('Mutagen22Effect', 'spell_power', min, max);
			floatVal = min.valueMultiplicative * 100;
			dm.GetAbilityAttributeValue('Mutagen22Effect', 'mutagen22_buff_rate', min, max);
			argsString.PushBack(NoTrailZeros(floatVal * min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen22Effect', 'mutagen22_max_stack', min, max);
			argsString.PushBack(NoTrailZeros(floatVal * min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen22Effect', 'mutagen22_debuff_rate', min, max);
			argsString.PushBack(NoTrailZeros(floatVal * min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen23:
			dm.GetAbilityAttributeValue('Mutagen23Effect', 'vitalityCombatRegen', min, max);
			argsString.PushBack(NoTrailZeros(1*min.valueAdditive));
			argsString.PushBack(NoTrailZeros(2*min.valueAdditive));
			argsString.PushBack(NoTrailZeros(4*min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen24:
			dm.GetAbilityAttributeValue('Mutagen24Effect', 'attack_power', min, max);
			argsInt.PushBack(RoundMath(min.valueMultiplicative * 100));
			dm.GetAbilityAttributeValue('Mutagen24Effect', 'spell_power', min, max);
			argsInt.PushBack(RoundMath(min.valueMultiplicative * 100));
			dm.GetAbilityAttributeValue('Mutagen24Effect', 'staminaRegen', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen24Effect', 'focus_gain', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			dm.GetAbilityAttributeValue('Mutagen24Effect', 'm24_hp_threshold', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			dm.GetAbilityAttributeValue('Mutagen24Effect', 'm24_cooldown_time', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen25:
			dm.GetAbilityAttributeValue('Mutagen25Effect', 'mutagen25_bonus_lesser', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive*100));
			dm.GetAbilityAttributeValue('Mutagen25Effect', 'mutagen25_bonus_medium', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive*100));
			dm.GetAbilityAttributeValue('Mutagen25Effect', 'mutagen25_bonus_greater', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive*100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen26:
			dm.GetAbilityAttributeValue('Mutagen26Effect', 'returned_damage', min, max);
			argsInt.PushBack(RoundMath(min.valueMultiplicative * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case EET_Mutagen27:
			dm.GetAbilityAttributeValue('Mutagen27Effect', 'mutagen27_dmg_window', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive));
			dm.GetAbilityAttributeValue('Mutagen27Effect', 'mutagen27_bonus_duration', min, max);
			argsString.PushBack(NoTrailZeros(min.valueAdditive));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case EET_Mutagen28:
			argsInt.PushBack(RoundMath(10));
			dm.GetAbilityAttributeValue('Mutagen28Effect', 'mutagen28_dmg_mult', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			dm.GetAbilityAttributeValue('Mutagen28Effect', 'mutagen28_dmg_reduction', min, max);
			argsInt.PushBack(RoundMath(min.valueAdditive * 100));
			uniqueDescription += GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		default:
			uniqueDescription += GetLocStringByKeyExt(locKey);
			break;
	}
	
	uniqueDescription += "<br><br><font color=\"#FBEDCF\">" + GetLocStringByKeyExt( "spectre_toxicity_offset_description" ) + "</font>";
}

@addMethod(CInventoryComponent) function GetBombAttributesForTooltip(item : SItemUniqueId, out itemStats : array<SAttributeTooltip>)
{
	GetBombAttributesForTooltipByName(GetItemName(item), itemStats);					   
}

@addMethod(CInventoryComponent) function GetBombAttributesForTooltipByName(itemName : name, out itemStats : array<SAttributeTooltip>)
{
	var dm							: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
	var abs1, abs					: array<name>;
	var weights						: array<float>;
	var i, j, k						: int;
	var buffType					: EEffectType;
	var attrs						: array<name>;
	var abilityName, attributeName	: name;
	var attributeColor				: string;
	var isPercentageValue			: string;
	var stat						: SAttributeTooltip;
	var attributeVal				: SAbilityAttributeValue;
	var min, max					: SAbilityAttributeValue;
	
	if(!dm.ItemHasTag(itemName, 'Petard'))
		return;
	
	dm.GetItemAbilitiesWithWeights(itemName, GetEntity() == thePlayer, abs1, weights, i, j);
	
	for(j = 0; j < abs1.Size(); j += 1)
	{
		abs.Clear();
		dm.GetContainedAbilities(abs1[j], abs);
			
		for(i = 0; i < abs.Size(); i += 1)
		{
			EffectNameToType(abs[i], buffType, abilityName);
			
			if(buffType != EET_Undefined)
			{
				attrs.Clear();
				dm.GetAbilityAttributes(abs[i], attrs);
				
				attrs.Remove('duration');
				attrs.Remove('level');
				
				for(k = 0; k < attrs.Size(); k += 1)
				{
					attributeName = attrs[k];
					if(FindAttrInTooltipSettings(attributeName, attributeColor, isPercentageValue))
					{
						dm.GetAbilityAttributeValue(abs[i], attributeName, min, max);
						attributeVal = GetAttributeRandomizedValue(min, max);
						stat.attributeColor = attributeColor;
						stat.percentageValue = isPercentageValue;			
						stat.primaryStat = false;
						stat.value = 0;
						stat.originName = attributeName;
						if(attributeVal.valueBase != 0)
						{
							stat.value = attributeVal.valueBase;
						}
						if(attributeVal.valueMultiplicative != 0)
						{				
							stat.value = attributeVal.valueMultiplicative;
							stat.percentageValue = true;
						}
						if(attributeVal.valueAdditive != 0)
						{				
							stat.value = attributeVal.valueAdditive;
						}
						if (stat.value != 0)
						{
							stat.attributeName = GetAttributeNameLocStr(attributeName, false);
							itemStats.PushBack(stat);
						}
					}
				}
			}
		}
	}
}

@addMethod(CInventoryComponent) function FindAttrInTooltipSettings(attributeName : name, out attributeColor : string, out isPercentageValue : string) : bool
{
	var i, settingsSize : int;
	var attributeString : string;
	
	settingsSize = theGame.tooltipSettings.GetNumRows();
	for(i = 0; i < settingsSize; i += 1)
	{
		attributeString = theGame.tooltipSettings.GetValueAt(0, i);
		if(StrLen(attributeString) <= 0)
			continue;
		
		if(NameToString(attributeName) != attributeString)
			continue;
		
		if(!IsNameValid(attributeName))
			continue;
		
		attributeColor = theGame.tooltipSettings.GetValueAt(1,i);
		isPercentageValue = theGame.tooltipSettings.GetValueAt(2,i);
		
		return true;
	}
	
	return false;							
}

@addMethod(CInventoryComponent) function GetEnhancedBuffInfo(item : SItemUniqueId) : string
{
	var dm							: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
	var min, max					: SAbilityAttributeValue;
	var attrs						: array<name>;
	var k							: int;
	var abilityName, attributeName	: name;
	var attributeColor				: string;
	var isPercentageValue			: string;
	var attributeVal				: SAbilityAttributeValue;
	var statVal						: float;
	var descr						: string;
	
	if(GetEntity() != GetWitcherPlayer())
		return "";
	
	descr = "";
	
	if(thePlayer.HasBuff(EET_EnhancedWeapon) && IsItemWeapon(item) && !IsItemBolt(item))
	{
		descr += "<img src=\"img://icons/buffs/enhanced_sword.png\" width=\"25\" height=\"25\" align=\"top\" \">" + " " + GetLocStringByKey("effect_enhanced_weapon");
		descr += " (" + RoundMath(thePlayer.GetBuff(EET_EnhancedWeapon).GetDurationLeft()) + " " + GetLocStringByKeyExt("per_second") + "):";
		abilityName = EffectTypeToName(EET_EnhancedWeapon);
		dm.GetAbilityAttributes(abilityName, attrs);
		attrs.Remove('duration');
	}
	
	if(thePlayer.HasBuff(EET_EnhancedArmor) && IsItemAnyArmor(item))
	{
		descr += "<img src=\"img://icons/buffs/enhanced_armor.png\" width=\"25\" height=\"25\" align=\"top\" \">" + " " + GetLocStringByKey("effect_enhanced_armor");
		descr += " (" + RoundMath(thePlayer.GetBuff(EET_EnhancedArmor).GetDurationLeft()) + " " + GetLocStringByKeyExt("per_second") + "):";
		abilityName = EffectTypeToName(EET_EnhancedArmor);
		dm.GetAbilityAttributes(abilityName, attrs);
		attrs.Remove('duration');
		attrs.Remove('slashing_resistance_perc');
		attrs.Remove('piercing_resistance_perc');
		attrs.Remove('bludgeoning_resistance_perc');
		attrs.Remove('rending_resistance_perc');
		attrs.Remove('elemental_resistance_perc');
	}
	
	if(descr != "")
	{
		descr += "<font color=\"#dbd8c5\">";
	}
	
	for(k = 0; k < attrs.Size(); k += 1)
	{
		attributeName = attrs[k];
		if(FindAttrInTooltipSettings(attributeName, attributeColor, isPercentageValue))
		{
			dm.GetAbilityAttributeValue(abilityName, attributeName, min, max);
			attributeVal = GetAttributeRandomizedValue(min, max);
			if(attributeVal.valueBase != 0)
				statVal = attributeVal.valueBase;
			if(attributeVal.valueMultiplicative != 0)
			{
				statVal = attributeVal.valueMultiplicative;
				isPercentageValue = true;
			}
			if(attributeVal.valueAdditive != 0)
				statVal = attributeVal.valueAdditive;
			if(isPercentageValue)
				statVal = RoundMath(statVal * 100);
			if(statVal != 0)
			{
				descr += "<br>";
				descr += "  ";
				if(statVal > 0)
					descr += "+";
				descr += NoTrailZeros(statVal);
				if(isPercentageValue)
					descr += " %";
				descr += "  " + GetAttributeNameLocStr(attributeName, false);
			}	  
		}
	}
	
	if(descr != "")
		descr += "</font><br><br>";
	
	return descr;
}

@wrapMethod(CInventoryComponent) function GetItemBaseStats(itemId : SItemUniqueId, out itemStats : array<SAttributeTooltip>)
{
	var attributes : array<name>;
	
	var dm	: CDefinitionsManagerAccessor;
	var oilAbilities, oilAttributes : array<name>;
	var weights : array<float>;
	var i, j : int;
	var tmpI, tmpJ : int;
	
	var idx			  : int;
	var oilStatsCount : int;
	var oilName  	  : name;
	var oilStats 	  : array<SAttributeTooltip>;
	var oilStatFirst  : SAttributeTooltip;
	var oils		  : array< W3Effect_Oil >;
	
	if(false) 
	{
		wrappedMethod(itemId, itemStats);
	}
	
	GetItemBaseAttributes(itemId, attributes);
	
	
	oils = GetOilsAppliedOnItem( itemId );
	dm = theGame.GetDefinitionsManager();
	for( i=0; i<oils.Size(); i+=1 )
	{
		oilName = oils[ i ].GetOilItemName();
		
		oilAbilities.Clear();
		weights.Clear();
		dm.GetItemAbilitiesWithWeights(oilName, GetEntity() == thePlayer, oilAbilities, weights, tmpI, tmpJ);
		
		oilAttributes.Clear();
		oilAttributes = dm.GetAbilitiesAttributes(oilAbilities);
		
		oilStatsCount = oilAttributes.Size();
		for (idx = 0; idx < oilStatsCount; idx+=1)
		{
			attributes.Remove(oilAttributes[idx]);
		}
	}

	if(IsItemBomb(itemId) && thePlayer.CanUseSkill(S_Alchemy_s10))
	{
		if(!attributes.Contains('PhysicalDamage'))
			attributes.PushBack('PhysicalDamage');
		if(!attributes.Contains('SilverDamage'))
			attributes.PushBack('SilverDamage');
	}
	
	GetItemTooltipAttributes(itemId, attributes, itemStats);
}

@wrapMethod(CInventoryComponent) function GetItemTooltipAttributes(itemId : SItemUniqueId, attributes : array<name>, out itemStats : array<SAttributeTooltip>, optional respectAttributeOrder : bool):void
{
	var itemCategory:name;
	var i, j, settingsSize : int;
	var attributeString : string;
	var attributeColor : string;
	var attributeName : name;
	var isPercentageValue : string;
	var primaryStatLabel : string;
	var statLabel		 : string;
	
	var stat : SAttributeTooltip;
	var attributeVal : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(itemId, attributes, itemStats, respectAttributeOrder);
	}
	
	settingsSize = theGame.tooltipSettings.GetNumRows();
	itemStats.Clear();
	itemCategory = GetItemCategory(itemId);
	for(i=0; i<settingsSize; i+=1)
	{
		
		attributeString = theGame.tooltipSettings.GetValueAt(0,i);
		if(StrLen(attributeString) <= 0)
			continue;						
		
		attributeName = '';
		
		
		for(j=0; j<attributes.Size(); j+=1)
		{
			if(NameToString(attributes[j]) == attributeString)
			{
				attributeName = attributes[j];
				break;
			}
		}
		if(!IsNameValid(attributeName))
			continue;
		
		
		if(itemCategory == 'silversword' && attributeName == 'SlashingDamage') continue;
		if(itemCategory == 'steelsword' && attributeName == 'SilverDamage') continue;
		
		attributeColor = theGame.tooltipSettings.GetValueAt(1,i);
		
		isPercentageValue = theGame.tooltipSettings.GetValueAt(2,i);	
		
		
		attributeVal = GetItemAttributeValue(itemId, attributeName);
		ExcludeEnhancements(itemId, attributeName, attributeVal);
		stat.attributeColor = attributeColor;
		stat.percentageValue = isPercentageValue;			
		stat.primaryStat = IsPrimaryStatById(itemId, attributeName, primaryStatLabel);
		stat.value = 0;
		stat.originName = attributeName;
		if(attributeVal.valueBase != 0)
		{
			stat.value = attributeVal.valueBase;
		}
		if(attributeVal.valueMultiplicative != 0)
		{				
			stat.value = attributeVal.valueMultiplicative;
			stat.percentageValue = true;
		}
		if(attributeVal.valueAdditive != 0)
		{				
			stat.value = attributeVal.valueAdditive;
		}
		if(IsItemBomb(itemId))
		{
			if(thePlayer.CanUseSkill(S_Alchemy_s10))
			{
				if(attributeName == 'PhysicalDamage')
					stat.value += CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s10, 'PhysicalDamage', false, false)) * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s10);
				else if(attributeName == 'SilverDamage')
					stat.value += CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s10, 'SilverDamage', false, false)) * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s10);
			}
			if(thePlayer.CanUseSkill(S_Perk_20) && IsDamageTypeNameValid(attributeName))
			{
				attributeVal = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_20, 'dmg_multiplier', false, false);
				stat.value *= 1 + attributeVal.valueMultiplicative;
			}
		}
		if (stat.value != 0)
		{
			statLabel = GetAttributeNameLocStr(attributeName, false);
			stat.attributeName = statLabel;
			if(IsItemBomb(itemId) && stat.originName == 'duration')
			{
				stat.originName = 'cloud_duration';
				stat.attributeName = GetAttributeNameLocStr('cloud_duration', false);
			}
			itemStats.PushBack(stat);
		}
	}

	if(respectAttributeOrder)
	{
		SortItemStatsForAttributeOrder(attributes, itemStats);
	}
}

@addMethod(CInventoryComponent) function ExcludeEnhancements(itemId : SItemUniqueId, attributeName : name, out attributeVal : SAbilityAttributeValue)
{
	var enhancements : array<name>;
	var i : int;
	var dm : CDefinitionsManagerAccessor;
	var min, max : SAbilityAttributeValue;
	
	if(!IsItemWeapon(itemId) && !IsItemAnyArmor(itemId))
		return;
	
	dm = theGame.GetDefinitionsManager();
		
	GetItemEnhancementItems(itemId, enhancements);
	
	if(enhancements.Size() > 0)
	{
		for(i = 0; i < enhancements.Size(); i += 1)
		{
			dm.GetItemAttributeValueNoRandom(enhancements[i], true, attributeName, min, max);
			attributeVal -= min;
		}
	}
}
	
@wrapMethod(CInventoryComponent) function GetItemStatsFromName(itemName : name, out itemStats : array<SAttributeTooltip>)
{
	var itemCategory : name;
	var i, j, settingsSize : int;
	var attributeString : string;
	var attributeColor : string;
	var attributeName : name;
	var isPercentageValue : string;
	var attributes, itemAbilities, tmpArray : array<name>;
	var weights : array<float>;
	var stat : SAttributeTooltip;
	var attributeVal, min, max : SAbilityAttributeValue;
	var dm	: CDefinitionsManagerAccessor;
	var primaryStatLabel : string;
	var statLabel		 : string;
	
	if(false) 
	{
		wrappedMethod(itemName, itemStats);
	}
	
	settingsSize = theGame.tooltipSettings.GetNumRows();
	dm = theGame.GetDefinitionsManager();
	dm.GetItemAbilitiesWithWeights(itemName, GetEntity() == thePlayer, itemAbilities, weights, i, j);
	attributes = dm.GetAbilitiesAttributes(itemAbilities);
	
	itemStats.Clear();
	itemCategory = dm.GetItemCategory(itemName);
	for(i=0; i<settingsSize; i+=1)
	{
		
		attributeString = theGame.tooltipSettings.GetValueAt(0,i);
		if(StrLen(attributeString) <= 0)
			continue;						
		
		attributeName = '';
		
		
		for(j=0; j<attributes.Size(); j+=1)
		{
			if(NameToString(attributes[j]) == attributeString)
			{
				attributeName = attributes[j];
				break;
			}
		}
		if(!IsNameValid(attributeName))
			continue;
		
		
		if(itemCategory == 'silversword' && attributeName == 'SlashingDamage') continue;
		if(itemCategory == 'steelsword' && attributeName == 'SilverDamage') continue;
		
		if(!spectreArmorRegenPenaltyOn() && attributeName == 'staminaRegen_armor_mod')
			continue;
		
		
		attributeColor = theGame.tooltipSettings.GetValueAt(1,i);
		
		isPercentageValue = theGame.tooltipSettings.GetValueAt(2,i);
		
		
		dm.GetAbilitiesAttributeValue(itemAbilities, attributeName, min, max);
		attributeVal = GetAttributeRandomizedValue(min, max);
		
		stat.attributeColor = attributeColor;
		stat.percentageValue = isPercentageValue;
		
		stat.primaryStat = IsPrimaryStat(itemCategory, attributeName, primaryStatLabel);
		
		stat.value = 0;
		stat.originName = attributeName;
		
		if(attributeVal.valueBase != 0)
		{
			stat.value = attributeVal.valueBase;
		}
		if(attributeVal.valueMultiplicative != 0)
		{
			stat.value = attributeVal.valueMultiplicative;
			stat.percentageValue = true;
		}
		if(attributeVal.valueAdditive != 0)
		{				
			statLabel = GetAttributeNameLocStr(attributeName, false);
			stat.value = attributeVal.valueBase + attributeVal.valueAdditive;
		}
		
		if (attributeName == 'toxicity_offset')
		{
			stat.percentageValue = false;
		}

		statLabel = GetAttributeNameLocStr(attributeName, false);

		if (stat.value != 0)
		{
			stat.attributeName = statLabel;
			
			itemStats.PushBack(stat);
		}
		
		
	}
}

@replaceMethod(CInventoryComponent) function GetArmorType(item : SItemUniqueId) : EArmorType
{
	var isItemEquipped : bool;
	
	isItemEquipped = GetWitcherPlayer().IsItemEquipped(item);
	
	if(ItemHasTag(item, 'LightArmor'))
		return EAT_Light;
	else if(ItemHasTag(item, 'MediumArmor'))
		return EAT_Medium;
	else if(ItemHasTag(item, 'HeavyArmor'))
		return EAT_Heavy;
	
	return EAT_Undefined;
}

@addMethod(CInventoryComponent) function GetArmorTypeByName(item : name) : EArmorType
{
	if(theGame.GetDefinitionsManager().ItemHasTag(item, 'LightArmor'))
		return EAT_Light;
	else if(theGame.GetDefinitionsManager().ItemHasTag(item, 'MediumArmor'))
		return EAT_Medium;
	else if(theGame.GetDefinitionsManager().ItemHasTag(item, 'HeavyArmor'))
		return EAT_Heavy;
	
	return EAT_Undefined;
}

@wrapMethod(CInventoryComponent) function IsItemEncumbranceItem(item : SItemUniqueId) : bool
{
	if(false) 
	{
		wrappedMethod(item);
	}
	
	if (theGame.GetInGameConfigWrapper().GetVarValue('Accessibility', 'WeightlessItems') == "true")
		return false;

	if(tempTransferredItems.Contains(item))
		return false;

	if(ItemHasTag(item, theGame.params.TAG_ENCUMBRANCE_ITEM_FORCE_YES))
		return true;
		
	if(ItemHasTag(item, theGame.params.TAG_ENCUMBRANCE_ITEM_FORCE_NO))
		return false;

	
	if (
			IsRecipeOrSchematic( item )
		||	IsItemBody( item )
	
		)
		return false;

	return true;
}

@wrapMethod(CInventoryComponent) function GetItemEncumbrance(item : SItemUniqueId) : float
{
	var itemCategory : name;
	var mult, weight : float;
	
	if(false) 
	{
		wrappedMethod(item);
	}
	
	if( FactsQuerySum( "modSpectre_debug_zero_enc" ) > 0 )
	{
		return 0;
	}

	// Alchemy 5.01 variant: potions, decoctions, oils and bombs weigh nothing, as in 5.01.
	if( IsItemAlchemyItem( item ) && spectreAlchemy501() )
	{
		return 0;
	}

	if ( IsItemEncumbranceItem( item ) )
	{
		mult = 1 - (spectre_Settings_Main_Float('spectreGameplayOptions','spectreEncumbranceMultiplier', 0) * 0.01);
		weight = GetItemWeight( item );
		if( weight < 0.01 ) weight = 0.01;
		weight *= GetItemQuantity( item ) * mult;
		if( weight < 0.01 ) weight = 0;
		return weight;
	}
	
	return 0;
}

@addMethod(CInventoryComponent) function spectreGenerateItemLevel( item : SItemUniqueId, rewardItem : bool ) : int
{
	var stat : SAbilityAttributeValue;
	var playerLevel : int;
	var lvl, i : int;
	var quality : int;
	var ilMin, ilMax : int;

	playerLevel = GetWitcherPlayer().GetLevel();

	lvl = playerLevel;
	
	if ( ( W3MerchantNPC )GetEntity() )
	{
		lvl = playerLevel + (int)(RandF()*3.9999) - 1;
	}
	else if ( rewardItem )
	{
		lvl = playerLevel;							 
	}
	else if ( ItemHasTag( item, 'AutogenUseLevelRange') )
	{
		quality = RoundMath( CalculateAttributeValue( GetItemAttributeValue( item, 'quality' ) ) );
		ilMin = RoundMath(CalculateAttributeValue( GetItemAttributeValue( item, 'item_level_min' ) ));
		ilMax = RoundMath(CalculateAttributeValue( GetItemAttributeValue( item, 'item_level_max' ) ));
		
		if ( !ItemHasTag( item, 'AutogenForceLevel') )
			lvl = playerLevel + (int)(RandF()*2.9999) - 1;
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			if ( lvl < ilMin + theGame.params.GetNewGamePlusLevel() ) lvl = ilMin + theGame.params.GetNewGamePlusLevel();
			if ( lvl > ilMax + theGame.params.GetNewGamePlusLevel() ) lvl = ilMax + theGame.params.GetNewGamePlusLevel();
		}
		else
		{
			if ( lvl < ilMin ) lvl = ilMin;
			if ( lvl > ilMax ) lvl = ilMax;
		}

	}
	else if ( !ItemHasTag( item, 'AutogenForceLevel') )
	{
		quality = RoundMath( CalculateAttributeValue( GetItemAttributeValue( item, 'quality' ) ) );

		switch( quality )
		{
		case 4:
		case 3:
			lvl = playerLevel + (int)(RandF()*2.9999) - 1;
			break;
		case 2:
		case 1:
			lvl = playerLevel + (int)(RandF()*1.9999) - 1;
			break;
		default:
			lvl = playerLevel;
			break;
		}
	}
	
	lvl = Clamp(lvl, 1, GetWitcherPlayer().GetMaxLevel());

	if ( ItemHasTag( item, 'PlayerSteelWeapon' ) && !( ItemHasAbility( item, 'autogen_steel_base' ) || ItemHasAbility( item, 'autogen_fixed_steel_base' ) )  ) 
	{
		if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_steel_base') )
			return 0;
	
		if ( ItemHasTag(item, 'AutogenUseLevelRange') )
			AddItemCraftedAbility(item, 'autogen_fixed_steel_base' ); 
		else
			AddItemCraftedAbility(item, 'autogen_steel_base' );
			
		for( i=0; i<lvl; i+=1 ) 
		{
			if (FactsQuerySum("StandAloneEP1") > 0)
			{
				AddItemCraftedAbility(item, 'autogen_fixed_steel_dmg', true );
				continue;
			}
			
			if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag(item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
				AddItemCraftedAbility(item, 'autogen_fixed_steel_dmg', true );
			else
				AddItemCraftedAbility(item, 'autogen_steel_dmg', true ); 
		}
	}
	else if ( ItemHasTag( item, 'PlayerSilverWeapon' ) && !( ItemHasAbility( item, 'autogen_silver_base' ) || ItemHasAbility( item, 'autogen_fixed_silver_base' ) ) ) 
	{
		if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_silver_base') )
			return 0;
		
		if ( ItemHasTag(item, 'AutogenUseLevelRange') )
			AddItemCraftedAbility(item, 'autogen_fixed_silver_base' ); 
		else
			AddItemCraftedAbility(item, 'autogen_silver_base' ); 
			
		for( i=0; i<lvl; i+=1 ) 
		{
			if (FactsQuerySum("StandAloneEP1") > 0)
			{
				AddItemCraftedAbility(item, 'autogen_fixed_silver_dmg', true ); 
				continue;
			}
		
			if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag(item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
				AddItemCraftedAbility(item, 'autogen_fixed_silver_dmg', true ); 
			else
				AddItemCraftedAbility(item, 'autogen_silver_dmg', true ); 
		}
	}
	else if ( GetItemCategory( item ) == 'armor' && !( ItemHasAbility( item, 'autogen_armor_base' ) || ItemHasAbility( item, 'autogen_fixed_armor_base' ) ) ) 
	{
		if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_armor_base') )
			return 0;
			
		if ( ItemHasTag(item, 'AutogenUseLevelRange') )
			AddItemCraftedAbility(item, 'autogen_fixed_armor_base' ); 
		else
			AddItemCraftedAbility(item, 'autogen_armor_base' ); 
			
		for( i=0; i<lvl; i+=1 ) 
		{
			if (FactsQuerySum("StandAloneEP1") > 0)
			{
				AddItemCraftedAbility(item, 'autogen_fixed_armor_armor', true ); 
				continue;
			}
		
			if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag( item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
				AddItemCraftedAbility(item, 'autogen_fixed_armor_armor', true ); 
			else
				AddItemCraftedAbility(item, 'autogen_armor_armor', true );		
		}
	}
	else if ( ( GetItemCategory( item ) == 'boots' || GetItemCategory( item ) == 'pants' ) && !( ItemHasAbility( item, 'autogen_pants_base' ) || ItemHasAbility( item, 'autogen_fixed_pants_base' ) ) ) 
	{
		if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_pants_base') )
			return 0;
			
		if ( ItemHasTag(item, 'AutogenUseLevelRange') )
			AddItemCraftedAbility(item, 'autogen_fixed_pants_base' ); 
		else 
			AddItemCraftedAbility(item, 'autogen_pants_base' ); 
			
		for( i=0; i<lvl; i+=1 ) 
		{
			if (FactsQuerySum("StandAloneEP1") > 0)
			{
				AddItemCraftedAbility(item, 'autogen_fixed_pants_armor', true ); 
				continue;
			}
		
			if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag( item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
				AddItemCraftedAbility(item, 'autogen_fixed_pants_armor', true ); 
			else
				AddItemCraftedAbility(item, 'autogen_pants_armor', true ); 
		}
	}
	else if ( GetItemCategory( item ) == 'gloves' && !( ItemHasAbility( item, 'autogen_gloves_base' ) || ItemHasAbility( item, 'autogen_fixed_gloves_base' ) ) ) 
	{
		if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_gloves_base') )
			return 0;
			
		if ( ItemHasTag(item, 'AutogenUseLevelRange') )
			AddItemCraftedAbility(item, 'autogen_fixed_gloves_base' ); 
		else
			AddItemCraftedAbility(item, 'autogen_gloves_base' ); 
			
		for( i=0; i<lvl; i+=1 ) 
		{
			if (FactsQuerySum("StandAloneEP1") > 0)
			{
				AddItemCraftedAbility(item, 'autogen_fixed_gloves_armor', true ); 
				continue;
			}
		
			if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag(item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
				AddItemCraftedAbility(item, 'autogen_fixed_gloves_armor', true ); 
			else
				AddItemCraftedAbility(item, 'autogen_gloves_armor', true );
		}
	}

	return lvl;
}

@wrapMethod(CInventoryComponent) function GenerateItemLevel( item : SItemUniqueId, rewardItem : bool )
{
	if(false)
	{
		wrappedMethod(item, rewardItem);
	}

	spectreGenerateItemLevel(item, rewardItem);
}

@addMethod(CInventoryComponent) function AddItemLevelAbility(item : SItemUniqueId)
{

	if( ItemHasTag( item, 'PlayerSteelWeapon' ) ) 
	{
		AddItemCraftedAbility(item, 'autogen_steel_dmg', true ); 
	}
	else if( ItemHasTag( item, 'PlayerSilverWeapon' ) ) 
	{
		AddItemCraftedAbility(item, 'autogen_silver_dmg', true ); 
	}
	else if( GetItemCategory( item ) == 'armor' )
	{
		AddItemCraftedAbility(item, 'autogen_armor_armor', true );		
	}
	else if( GetItemCategory( item ) == 'boots' || GetItemCategory( item ) == 'pants' )
	{
		AddItemCraftedAbility(item, 'autogen_pants_armor', true ); 
	}
	else if( GetItemCategory( item ) == 'gloves' )
	{
		AddItemCraftedAbility(item, 'autogen_gloves_armor', true );
	}
}

@replaceMethod(CInventoryComponent) function OnItemAdded(data : SItemChangedData)
{
	var i, j : int;
	var ent	: CGameplayEntity;
	var allCardsNames, foundCardsNames : array<name>;
	var allStringNamesOfCards : array<string>;
	var foundCardsStringNames : array<string>;
	var gwintCards : array<SItemUniqueId>;
	var itemName : name;
	var witcher : W3PlayerWitcher;
	var itemCategory : name;
	var dm : CDefinitionsManagerAccessor;
	var locKey : string;
	var leaderCardsHack : array<name>;
	var itemLevel : int;						 
	var hud : CR4ScriptedHud;
	var journalUpdateModule : CR4HudModuleJournalUpdate;
	var itemId : SItemUniqueId;
	var isItemShematic : bool;
	var ngp : bool;
	
	
	ent = (CGameplayEntity)GetEntity();
	
	itemId = data.ids[0];
	
	
	if( data.informGui )
	{
		recentlyAddedItems.PushBack( itemId );
		if( ItemHasTag( itemId, 'FocusObject' ) )
		{
			GetWitcherPlayer().GetMedallion().Activate( true, 3.0);
		} 
	}
	
	itemLevel = 0;
	if ( ItemHasTag(itemId, 'Autogen') ) 
		itemLevel = spectreGenerateItemLevel( itemId, false );
	if( itemLevel == 0 )
		itemLevel = GetItemLevel( itemId );
	
	witcher = GetWitcherPlayer();
	
	
	if(ent == witcher || ((W3MerchantNPC)ent) )
	{
		ngp = FactsQuerySum("NewGamePlus") > 0;
		for(i=0; i<data.ids.Size(); i+=1)
		{
			
			if ( GetItemModifierInt(data.ids[i], 'ItemQualityModified') <= 0 )
				spectreAddRandomEnhancementToItem(data.ids[i], itemLevel);
			
			if ( ngp )
				SetItemModifierInt(data.ids[i], 'DoNotAdjustNGPDLC', 1);	
			
			itemName = GetItemName(data.ids[i]);
			
			if ( ngp && GetItemModifierInt(data.ids[i], 'NGPItemAdjusted') <= 0 && !ItemHasTag(data.ids[i], 'Autogen') )
			{
				IncreaseNGPItemlevel(data.ids[i]);
			}
			
		}
	}
	if(ent == witcher)
	{
		for(i=0; i<data.ids.Size(); i+=1)
		{	
			
			if( ItemHasTag( itemId, theGame.params.GWINT_CARD_ACHIEVEMENT_TAG ) || !FactsDoesExist( "fix_for_gwent_achievement_bug_121588" ) )
			{
				
				leaderCardsHack.PushBack('gwint_card_emhyr_gold');
				leaderCardsHack.PushBack('gwint_card_emhyr_silver');
				leaderCardsHack.PushBack('gwint_card_emhyr_bronze');
				leaderCardsHack.PushBack('gwint_card_foltest_gold');
				leaderCardsHack.PushBack('gwint_card_foltest_silver');
				leaderCardsHack.PushBack('gwint_card_foltest_bronze');
				leaderCardsHack.PushBack('gwint_card_francesca_gold');
				leaderCardsHack.PushBack('gwint_card_francesca_silver');
				leaderCardsHack.PushBack('gwint_card_francesca_bronze');
				leaderCardsHack.PushBack('gwint_card_eredin_gold');
				leaderCardsHack.PushBack('gwint_card_eredin_silver');
				leaderCardsHack.PushBack('gwint_card_eredin_bronze');
				
				dm = theGame.GetDefinitionsManager();
				
				allCardsNames = theGame.GetDefinitionsManager().GetItemsWithTag(theGame.params.GWINT_CARD_ACHIEVEMENT_TAG);
				
				
				gwintCards = GetItemsByTag(theGame.params.GWINT_CARD_ACHIEVEMENT_TAG);

				
				allStringNamesOfCards.PushBack('gwint_name_emhyr');
				allStringNamesOfCards.PushBack('gwint_name_emhyr');
				allStringNamesOfCards.PushBack('gwint_name_emhyr');
				allStringNamesOfCards.PushBack('gwint_name_foltest');
				allStringNamesOfCards.PushBack('gwint_name_foltest');
				allStringNamesOfCards.PushBack('gwint_name_foltest');
				allStringNamesOfCards.PushBack('gwint_name_francesca');
				allStringNamesOfCards.PushBack('gwint_name_francesca');
				allStringNamesOfCards.PushBack('gwint_name_francesca');
				allStringNamesOfCards.PushBack('gwint_name_eredin');
				allStringNamesOfCards.PushBack('gwint_name_eredin');
				allStringNamesOfCards.PushBack('gwint_name_eredin');
				
				
				for(j=0; j<allCardsNames.Size(); j+=1)
				{
					itemName = allCardsNames[j];
					locKey = dm.GetItemLocalisationKeyName(allCardsNames[j]);
					if (!allStringNamesOfCards.Contains(locKey))
					{
						allStringNamesOfCards.PushBack(locKey);
					}
				}
				
				
				if(gwintCards.Size() >= allStringNamesOfCards.Size())
				{
					foundCardsNames.Clear();
					for(j=0; j<gwintCards.Size(); j+=1)
					{
						itemName = GetItemName(gwintCards[j]);
						locKey = dm.GetItemLocalisationKeyName(itemName);
						
						if(!foundCardsStringNames.Contains(locKey) || leaderCardsHack.Contains(itemName))
						{
							foundCardsStringNames.PushBack(locKey);
						}
					}

					if(foundCardsStringNames.Size() >= allStringNamesOfCards.Size())
					{
						theGame.GetGamerProfile().AddAchievement(EA_GwintCollector);
						FactsAdd("gwint_all_cards_collected", 1, -1);
					}
					else 
					{
						theGame.GetGamerProfile().NoticeAchievementProgress(EA_GwintCollector, foundCardsStringNames.Size(), allStringNamesOfCards.Size());
					}
				}
				
				if(!FactsDoesExist("fix_for_gwent_achievement_bug_121588"))
					FactsAdd("fix_for_gwent_achievement_bug_121588", 1, -1);
			}
			
			itemCategory = GetItemCategory( itemId );
			isItemShematic = itemCategory == 'alchemy_recipe' ||  itemCategory == 'crafting_schematic';
			
			if( isItemShematic )
			{
				ReadSchematicsAndRecipes( itemId, !data.informGui );
			}					
			
			
			if( ItemHasTag( data.ids[i], 'GwintCard'))
			{
				witcher.AddGwentCard(GetItemName(data.ids[i]), data.quantity);
			}
			
			
			
			if( !isItemShematic && ( this.ItemHasTag( itemId, 'ReadableItem' ) || this.ItemHasTag( itemId, 'Painting' ) ) && !this.ItemHasTag( itemId, 'NoNotification' ) )
			{
				if (!spectre_Settings_Main_Bool('acs_item_management_settings','acs_auto_read_enabled', false))
				{
					hud = (CR4ScriptedHud)theGame.GetHud();

					if( hud )
					{
						journalUpdateModule = (CR4HudModuleJournalUpdate)hud.GetHudModule( "JournalUpdateModule" );
						if( journalUpdateModule )
						{
							journalUpdateModule.AddQuestBookInfo( itemId );
						}
					}
				}
			}				
		}
	}
	
	
	if( IsItemSingletonItem( itemId ) )
	{
		for(i=0; i<data.ids.Size(); i+=1)
		{
			if(!GetItemModifierInt(data.ids[i], 'is_initialized', 0))
			{
				SingletonItemRefillAmmo(data.ids[i]);
				SetItemModifierInt(data.ids[i], 'is_initialized', 1);
			}
		}			
	}
	
	
	if(ent)
		ent.OnItemGiven(data);
}

@wrapMethod(CInventoryComponent) function SingletonItemRefillAmmo( id : SItemUniqueId, optional alchemyTableUsed : bool )
{
	var before : int;

	// Alchemy 5.01 variant: 5.01 code, but the charges a potion already has above its maximum are kept.
	if (spectreAlchemy501())
	{
		before = GetItemModifierInt(id, 'ammo_current');
		wrappedMethod(id, alchemyTableUsed);
		if (GetItemModifierInt(id, 'ammo_current') < before)
			SetItemModifierInt(id, 'ammo_current', before);
		spectreShowRefilledItem(id);
		return;
	}

	if (GetItemModifierInt(id, 'ammo_current') < 0) SetItemModifierInt(id, 'ammo_current', 1); 
	{
		return;
	}
}

// Alchemy 5.01 variant: Spectre hides empty potions (NoShow). A potion that has charges again shows.
@addMethod(CInventoryComponent) function spectreShowRefilledItem(id : SItemUniqueId)
{
	if (GetItemModifierInt(id, 'ammo_current') > 0 && ItemHasTag(id, 'NoShow'))
		RemoveItemTag(id, 'NoShow');
}

@wrapMethod(CInventoryComponent) function SingletonItemSetAmmo(id : SItemUniqueId, quantity : int)
{
	wrappedMethod(id, quantity);

	if (spectreAlchemy501())
		spectreShowRefilledItem(id);
	else
		theGame.alchexts.OnSingletonChanged(id, quantity);
}

@wrapMethod(CInventoryComponent) function SingletonItemAddAmmo(id : SItemUniqueId, quantity : int)
{
	var ammo : int;

	// Alchemy 5.01 variant: 5.01 code, but the charges a potion already has above its maximum are kept.
	if (spectreAlchemy501())
	{
		ammo = GetItemModifierInt(id, 'ammo_current');
		wrappedMethod(id, quantity);
		if (GetItemModifierInt(id, 'ammo_current') < ammo)
			SetItemModifierInt(id, 'ammo_current', ammo);
		spectreShowRefilledItem(id);
		return;
	}
		
	if(quantity <= 0)
		return;
		
	ammo = GetItemModifierInt(id, 'ammo_current');
	
	if(ammo == -1)
		return;	
		
	ammo = Clamp(ammo + quantity, 0, SingletonItemGetMaxAmmo(id));

	SetItemModifierInt(id, 'ammo_current', ammo);

	theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnAmmoChanged ); 
	
	theGame.alchexts.OnSingletonChanged(id, ammo);
}

@wrapMethod(CInventoryComponent) function HasNotFilledSingletonItem( optional alchemyTableUsed : bool ) : bool
{
	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
		return wrappedMethod(alchemyTableUsed);

	return (false);
}

@wrapMethod(CInventoryComponent) function SingletonItemRemoveAmmo(itemID : SItemUniqueId, optional quantity : int)
{
	var ammo : int;

	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
	{
		wrappedMethod(itemID, quantity);
		return;
	}
	
	if(!IsItemSingletonItem(itemID) || ItemHasTag(itemID, theGame.params.TAG_INFINITE_AMMO))
		return;
	
	if(quantity <= 0)
		quantity = 1;
		
	ammo = GetItemModifierInt(itemID, 'ammo_current');
	ammo = Max(0, ammo - quantity);
	SetItemModifierInt(itemID, 'ammo_current', ammo);theGame.alchexts.OnSingletonChanged(itemID, ammo);
	
	
	if(ammo == 0 && ShouldProcessTutorial('TutorialAlchemyRefill') && FactsQuerySum("q001_nightmare_ended") > 0)
	{
		FactsAdd('tut_alch_refill', 1);
	}
	theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnAmmoChanged );
}

@wrapMethod(CInventoryComponent) function SingletonItemGetMaxAmmo(itemID : SItemUniqueId) : int
{
	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
		return wrappedMethod(itemID);
	
	return (theGame.alchexts.GetMaxAmmoForItem(itemID, this) );
}

@wrapMethod(CInventoryComponent) function ManageSingletonItemsBonus()
{
	// Alchemy 5.01 variant: 5.01 code.
	if (spectreAlchemy501())
	{
		wrappedMethod();
		return;
	}

	theGame.alchexts.OnAlchemyTableUsed(); 

	return;
}

@addMethod(CInventoryComponent) function AddQualityAbilityToItem(item : SItemUniqueId)
{
	var ability			: name;
	var itemCategory 	: name;
	var itemQuality		: int;
										   
	itemQuality = RoundMath(CalculateAttributeValue(GetItemAttributeValue(item, 'quality' )));
	itemCategory = GetItemCategory(item);
	
	if ( itemCategory == 'armor' )
	{
		switch ( itemQuality )
		{
			case 1:
				ability = 'quality_common_armor';
				break;
			case 2 : 
				ability = 'quality_masterwork_armor'; 																			 
				break;
			case 3 : 
				ability = 'quality_magical_armor'; 															   
				break;
			case 4:
				ability = 'quality_relic_armor';																  
				break;
			default : break;
		}
	}
	else if ( itemCategory == 'gloves' )
	{
		switch ( itemQuality )
		{
			case 1:
				ability = 'quality_common_gloves';
				break;
			case 2 : 
				ability = 'quality_masterwork_gloves'; 																		  
				break;
			case 3 : 
				ability = 'quality_magical_gloves'; 															   
				break;
			case 4:
				ability = 'quality_relic_gloves';															   
				break;
			default : break;
		}
	}
	else if ( itemCategory == 'pants' )
	{
		switch ( itemQuality )
		{
			case 1:
				ability = 'quality_common_pants';
				break;
			case 2 : 
				ability = 'quality_masterwork_pants'; 																		 
				break;
			case 3 : 
				ability = 'quality_magical_pants'; 															   
				break;
			case 4:
				ability = 'quality_relic_pants';																  
				break;
			default : break;
		}
	}
	else if ( itemCategory == 'boots' )
	{
		switch ( itemQuality )
		{
			case 1 : 
				ability = 'quality_common_boots'; 			
				break;
			case 2 : 
				ability = 'quality_masterwork_boots'; 																									 
				break;
			case 3 : 
				ability = 'quality_magical_boots'; 															   
				break;
			case 4 : 
				ability = 'quality_relic_boots'; 																			  
				break;
			default : break;
		}
	}
	else if( itemCategory == 'steelsword' )
	{
		switch ( itemQuality )
		{
			case 1 : 
				ability = 'quality_common_steelsword'; 	
				break;
			case 2 : 
				ability = 'quality_masterwork_steelsword'; 																		  
				break;
			case 3 : 
				ability = 'quality_magical_steelsword'; 															   
				break;
			case 4 : 
				ability = 'quality_relic_steelsword'; 																	   
				break;
			default : break;
		}
	}
	else if( itemCategory == 'silversword' )
	{
		switch ( itemQuality )
		{
			case 1 : 
				ability = 'quality_common_silversword';	
				break;
			case 2 : 
				ability = 'quality_masterwork_silversword';																  
				break;
			case 3 : 
				ability = 'quality_magical_silversword'; 														   
				break;
			case 4 : 
				ability = 'quality_relic_silversword';																   
				break;
			default : break;
		}
	}
		
	if(IsNameValid(ability))
		AddItemCraftedAbility(item, ability, false);
}

@replaceMethod(CInventoryComponent) function AddRandomEnhancementToItem(item : SItemUniqueId)
{
	spectreAddRandomEnhancementToItem(item, GetItemLevel(item));
}

@addMethod(CInventoryComponent) function spectreAddRandomEnhancementToItem(item : SItemUniqueId, itemLevel : int)
{
	var itemCategory 	: name;
	var itemQuality		: int;
	var craftedAbility	: name; 
	
	SetItemModifierInt(item, 'ItemQualityModified', 1);

	if( ItemHasTag(item, 'DoNotEnhance') )
		return;
	
	itemQuality = RoundMath(CalculateAttributeValue(GetItemAttributeValue(item, 'quality' )));
	
	if( itemQuality > 4 )
		return;
	
	AddQualityAbilityToItem(item);
	
	itemCategory = GetItemCategory(item);

	if( itemQuality == 4 ) 
	{
		if ( itemCategory == 'armor' )
			AddItemCraftedAbility(item, theGame.params.GetRandomCommonArmorAbility(), true);
		return;
	}
		
	if ( itemCategory == 'armor' )
	{
		if( itemQuality >= 1 )
		{
			AddItemCraftedAbility(item, theGame.params.GetRandomCommonArmorAbility(), true);
		}
		if( itemQuality >= 2 )
		{
			craftedAbility = theGame.params.GetRandomMasterworkArmorAbility();
			AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 10)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 20)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 30)
				AddItemCraftedAbility(item, craftedAbility, true);
		}
		if( itemQuality >= 3 )
		{
			craftedAbility = theGame.params.GetRandomMagicalArmorAbility();
			AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 10)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 20)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 30)
				AddItemCraftedAbility(item, craftedAbility, true);
		}
	}
	else if ( itemCategory == 'gloves' )
	{
		if( itemQuality >= 2 )
			AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkGlovesAbility(), true);
		if( itemQuality >= 3 )
			AddItemCraftedAbility(item, theGame.params.GetRandomMagicalGlovesAbility(), true);
	}
	else if ( itemCategory == 'pants' )
	{
		if( itemQuality >= 2 )
			AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkPantsAbility(), true);
		if( itemQuality >= 3 )
			AddItemCraftedAbility(item, theGame.params.GetRandomMagicalPantsAbility(), true);
	}
	else if ( itemCategory == 'boots' )
	{
		//boots get only one master + magic ability
		if( itemQuality >= 2 )
			AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkBootsAbility(), true);
		if( itemQuality >= 3 )
			AddItemCraftedAbility(item, theGame.params.GetRandomMagicalBootsAbility(), true);
	}
	else if ( itemCategory == 'steelsword' || itemCategory == 'silversword' )
	{
		//sword gets one ability per 10 levels
		if( itemQuality >= 1 )
		{
			//same ability multiplied
			craftedAbility = theGame.params.GetRandomCommonWeaponAbility();
			AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 10)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 20)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 30)
				AddItemCraftedAbility(item, craftedAbility, true);
		}
		if( itemQuality >= 2 )
		{
			//same ability multiplied
			craftedAbility = theGame.params.GetRandomMasterworkWeaponAbility();
			AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 10)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 20)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 30)
				AddItemCraftedAbility(item, craftedAbility, true);
		}
		if( itemQuality >= 3 )
		{
			//same ability multiplied
			craftedAbility = theGame.params.GetRandomMagicalWeaponAbility();
			AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 10)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 20)
				AddItemCraftedAbility(item, craftedAbility, true);
			if(itemLevel >= 30)
				AddItemCraftedAbility(item, craftedAbility, true);
		}
	}
}

@wrapMethod(CInventoryComponent) function GetItemQualityFromName( itemName : name, out min : int, out max : int)
{
	var dm : CDefinitionsManagerAccessor;
	var attributeName : name;
	var attributes, itemAbilities : array<name>;
	var attributeMin, attributeMax : SAbilityAttributeValue;
	
	var tmpInt : int;
	var tmpArray : array<float>;
	
	if(false) 
	{
		wrappedMethod(itemName, min, max);
	}
	
	min = 0;
	max = 0;
	dm = theGame.GetDefinitionsManager();
	
	dm.GetItemAbilitiesWithWeights(itemName, GetEntity() == thePlayer, itemAbilities, tmpArray, tmpInt, tmpInt);
	attributes = dm.GetAbilitiesAttributes(itemAbilities);
	for (tmpInt = 0; tmpInt < attributes.Size(); tmpInt += 1)
	{
		if (attributes[tmpInt] == 'quality')
		{
			dm.GetAbilitiesAttributeValue(itemAbilities, 'quality', attributeMin, attributeMax);
			min = RoundMath(CalculateAttributeValue(attributeMin));
			max = RoundMath(CalculateAttributeValue(attributeMax));
			break;
		}
	}
	min = Max(1, min);
	max = Max(min, max);
}

@addMethod(CInventoryComponent) function GetSetArmorType() : EArmorType
{
	var armorPieces : array<int>;
	
	CountSetArmorPieces(armorPieces);
	
	if( armorPieces[0] == 4 )
		return EAT_Light;
	if( armorPieces[1] == 4 )
		return EAT_Medium;
	if( armorPieces[2] == 4 )
		return EAT_Heavy;
	
	return EAT_Undefined;
}

@addMethod(CInventoryComponent) function IsSetArmorType(item : SItemUniqueId) : bool
{
	return IsItemAnyArmor(item) && !ItemHasTag(item, 'spectre_NoSetBonuses') &&
			(!theGame.GetDLCManager().IsEP2Enabled() || !ItemHasTag(item, 'SetBonusPiece'));
}

@addMethod(CInventoryComponent) function IsSetArmorTypeByName(itemName : name) : bool
{
	var dm : CDefinitionsManagerAccessor;
	
	dm = theGame.GetDefinitionsManager();
	return dm.IsItemAnyArmor(itemName) && !dm.ItemHasTag(itemName, 'spectre_NoSetBonuses') &&
			(!theGame.GetDLCManager().IsEP2Enabled() || !dm.ItemHasTag(itemName, 'SetBonusPiece'));
}

@addMethod(CInventoryComponent) function GetSetArmorItemDescription(item : SItemUniqueId, out counterText : string, out descrText : string) : int
{
	var paramsInt : array<int>;
	var armorType : EArmorType;
	var min, max : SAbilityAttributeValue;
	var armorPieces : array<int>;
	var count : int;
	
	if(!IsSetArmorType(item))
		return 0;
	
	CountSetArmorPieces(armorPieces);
	armorType = GetArmorType(item); //affected by glyphwords
	
	switch(armorType)
	{
		case EAT_Heavy:
			count = armorPieces[2];
			break;
		case EAT_Medium:
			count = armorPieces[1];
			break;
		case EAT_Light:
			count = armorPieces[0];
			break;
	}
	counterText = count + "/4";
	GetSetArmorItemDescriptionByType(armorType, descrText);

	return count;
}

@addMethod(CInventoryComponent) function GetSetArmorItemDescriptionByName(item : name, out descrText : string)
{
	var armorType : EArmorType;
	
	if(!IsSetArmorTypeByName(item))
		return;
	
	armorType = GetArmorTypeByName(item);
	GetSetArmorItemDescriptionByType(armorType, descrText);
}

@addMethod(CInventoryComponent) function GetSetArmorItemDescriptionByType(armorType : EArmorType, out descrText : string)
{
	var paramsInt : array<int>;
	var paramsString : array<string>;
	var min, max : SAbilityAttributeValue;
	var dm : CDefinitionsManagerAccessor;
	
	dm = theGame.GetDefinitionsManager();
	
	switch(armorType)
	{
		case EAT_Heavy:
			dm.GetAbilityAttributeValue('ArmorTypeHeavySetBonusAbility', 'slashing_resistance_perc', min, max);
			paramsInt.PushBack(RoundMath(100*CalculateAttributeValue(min)));
			descrText = GetLocStringByKeyExtWithParams("item_desc_armor_type_heavy_set_bonus", paramsInt);
			break;
		case EAT_Medium:
			dm.GetAbilityAttributeValue('ArmorTypeMediumSetBonusAbility', 'toxicityRegen', min, max);
			paramsString.PushBack(NoTrailZeros(-1*min.valueAdditive));
			descrText = GetLocStringByKeyExtWithParams("item_desc_armor_type_medium_set_bonus", , , paramsString);
			break;
		case EAT_Light:
			dm.GetAbilityAttributeValue('ArmorTypeLightSetBonusAbility', 'dodge_safe_ange_dist_deg', min, max);
			paramsInt.PushBack(RoundMath(CalculateAttributeValue(min)));
			descrText = GetLocStringByKeyExtWithParams("item_desc_armor_type_light_set_bonus", paramsInt);
			break;
	}
}

@addMethod(CInventoryComponent) function CountArmorPieces(out pieces : array<int>)
{
	var item : SItemUniqueId;
	var armors : array<SItemUniqueId>;
	var i : int;
	var armorType : EArmorType;

	armors.Resize(4);
	if(GetItemEquippedOnSlot(EES_Armor, item))
		armors[0] = item;
	if(GetItemEquippedOnSlot(EES_Boots, item))
		armors[1] = item;
	if(GetItemEquippedOnSlot(EES_Pants, item))
		armors[2] = item;
	if(GetItemEquippedOnSlot(EES_Gloves, item))
		armors[3] = item;
	pieces.Clear();
	pieces.Resize(3);
	for(i = 0; i < armors.Size(); i += 1)
	{
		if(armors[i] != GetInvalidUniqueId())
		{
			armorType = GetArmorType(armors[i]);
			if(armorType == EAT_Light)
				pieces[0] += 1;
			else if(armorType == EAT_Medium)
				pieces[1] += 1;
			else if(armorType == EAT_Heavy)
				pieces[2] += 1;
		}
	}
}

@addMethod(CInventoryComponent) function CountSetArmorPieces(out pieces : array<int>)
{
	var item : SItemUniqueId;
	var armors : array<SItemUniqueId>;
	var i : int;
	var armorType : EArmorType;

	armors.Resize(4);
	if(GetItemEquippedOnSlot(EES_Armor, item) && IsSetArmorType(item))
		armors[0] = item;
	if(GetItemEquippedOnSlot(EES_Boots, item) && IsSetArmorType(item))
		armors[1] = item;
	if(GetItemEquippedOnSlot(EES_Pants, item) && IsSetArmorType(item))
		armors[2] = item;
	if(GetItemEquippedOnSlot(EES_Gloves, item) && IsSetArmorType(item))
		armors[3] = item;
	pieces.Clear();
	pieces.Resize(3);
	for(i = 0; i < armors.Size(); i += 1)
	{
		if(armors[i] != GetInvalidUniqueId())
		{
			armorType = GetArmorType(armors[i]); //with respect to glyphwords
			if(armorType == EAT_Light)
				pieces[0] += 1;
			else if(armorType == EAT_Medium)
				pieces[1] += 1;
			else if(armorType == EAT_Heavy)
				pieces[2] += 1;
		}
	}
}

@addMethod(CInventoryComponent) function GetTotalArmorWeight() : float
{
	var armorEq, glovesEq, pantsEq, bootsEq : bool;
	var tempItem : SItemUniqueId;
	var weight : float;
	
	weight = 0;
	armorEq = GetItemEquippedOnSlot( EES_Armor, tempItem );
	if(armorEq) weight += GetItemWeight( tempItem );
	glovesEq = GetItemEquippedOnSlot( EES_Gloves, tempItem );
	if(glovesEq) weight += GetItemWeight( tempItem );
	pantsEq = GetItemEquippedOnSlot( EES_Pants, tempItem );
	if(pantsEq) weight += GetItemWeight( tempItem );
	bootsEq = GetItemEquippedOnSlot( EES_Boots, tempItem );
	if(bootsEq) weight += GetItemWeight( tempItem );
	
	return weight;
}

@wrapMethod(CInventoryComponent) function IsItemSetItem(item : SItemUniqueId) : bool
{
	if(false) 
	{
		wrappedMethod(item);
	}

	return
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_BEAR) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_BEAR_MINOR) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_GRYPHON) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_GRYPHON_MINOR) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_LYNX) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_LYNX_MINOR) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_WOLF) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_WOLF_MINOR) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_RED_WOLF) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_RED_WOLF_MINOR) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_VAMPIRE ) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_VIPER) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_KAER_MORHEN) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_NETFLIX) ||
		ItemHasTag(item, theGame.params.ITEM_SET_TAG_NETFLIX_MINOR)
		;
}

@wrapMethod(CInventoryComponent) function DetectTagOfASet(item : SItemUniqueId) : name
{
	if(false) 
	{
		wrappedMethod(item);
	}

	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_BEAR) )
		return theGame.params.ITEM_SET_TAG_BEAR;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_GRYPHON) )
		return theGame.params.ITEM_SET_TAG_GRYPHON;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_LYNX) )
		return theGame.params.ITEM_SET_TAG_LYNX;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_WOLF) )
		return theGame.params.ITEM_SET_TAG_WOLF;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_RED_WOLF) )
		return theGame.params.ITEM_SET_TAG_RED_WOLF;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_KAER_MORHEN) )
		return theGame.params.ITEM_SET_TAG_KAER_MORHEN;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_VAMPIRE) )
		return theGame.params.ITEM_SET_TAG_VAMPIRE;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_VIPER) )
		return theGame.params.ITEM_SET_TAG_VIPER;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_NETFLIX) )
		return theGame.params.ITEM_SET_TAG_NETFLIX;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_BEAR_MINOR) )
		return theGame.params.ITEM_SET_TAG_BEAR_MINOR;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_GRYPHON_MINOR) )
		return theGame.params.ITEM_SET_TAG_GRYPHON_MINOR;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_LYNX_MINOR) )
		return theGame.params.ITEM_SET_TAG_LYNX_MINOR;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_WOLF_MINOR) )
		return theGame.params.ITEM_SET_TAG_WOLF_MINOR;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_RED_WOLF_MINOR) )
		return theGame.params.ITEM_SET_TAG_RED_WOLF_MINOR;
	if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_NETFLIX_MINOR) )
		return theGame.params.ITEM_SET_TAG_NETFLIX_MINOR;
		
	return '';
}
