@wrapMethod(W3GuiBaseInventoryComponent) function GetAlchemyBookText(item : SItemUniqueId):string
{
	var dm 					: CDefinitionsManagerAccessor;
	var finalString			: string;
	var tempString			: string;
	var recipe				: SAlchemyRecipe;
	var currentIngredient	: SItemParts;
	var htmlNewline			: string;
	var itemType 			: EInventoryFilterType;
	var i					: int;
	var craftedItemName		: name;
	var color				: string;
	var attributes			: array<SAttributeTooltip>;
	var minWeightAttribute 	: SAbilityAttributeValue;
	var maxWeightAttribute 	: SAbilityAttributeValue;
	var minQuality 			: int;
	var maxQuality 			: int;
	var itemDesc			: string;
	var itemQuantity		: int;
	var fontColor	 		: string;
	
	if(false) 
	{
		wrappedMethod(item);
	}
	
	htmlNewline = "&#10;";
	finalString = "";
	
	recipe = getAlchemyRecipeFromName(_inv.GetItemName(item));
	dm = theGame.GetDefinitionsManager();
	craftedItemName = recipe.cookedItemName;
	_inv.GetItemStatsFromName(craftedItemName, attributes);
	_inv.GetPotionAttributesByName(craftedItemName, attributes);
	_inv.GetBombAttributesForTooltipByName(craftedItemName, attributes);
	_inv.GetItemQualityFromName(craftedItemName, minQuality, maxQuality);
	dm.GetItemAttributeValueNoRandom(craftedItemName, true, 'weight', minWeightAttribute, maxWeightAttribute);
	itemType = dm.GetFilterTypeByItem(craftedItemName);

	
	tempString = GetLocStringByKeyExt(GetFilterTypeName( itemType )) + " / " + GetLocStringByKeyExt("item_category_" + dm.GetItemCategory(craftedItemName));
	finalString += "<font color=\"#FF8832\">" + tempString + "</font>";

	finalString += htmlNewline + GetItemRarityDescriptionFromInt(minQuality);

	if (attributes.Size() > 0)
	{
		finalString += htmlNewline;
		for (i = 0; i < attributes.Size(); i += 1)
		{
			
			color = attributes[i].attributeColor;
			tempString = htmlNewline + "<font color=\"#" + color + "\">";
			if( attributes[i].percentageValue )
			{
				tempString += NoTrailZeros(attributes[i].value * 100 ) +" %";
			}
			else
			{
				tempString += NoTrailZeros(attributes[i].value);
			}
			tempString += " " + attributes[i].attributeName;
			tempString += "</font>";
			finalString += tempString;
		}

	}
	
	if(dm.ItemHasTag(craftedItemName, 'Mutagen'))
		_inv.FillInMutagenDescriptionByName(craftedItemName, itemDesc);
	else
		itemDesc = GetLocStringByKeyExt(_inv.GetItemLocalizedDescriptionByName(craftedItemName));
	
	finalString += htmlNewline; 
	finalString += htmlNewline + "<font color=\"#C49560\">" + itemDesc + "</font>";
	
	finalString += htmlNewline;
	finalString += htmlNewline + GetLocStringByKeyExt("panel_crafting_ingredients_start") + ":";
	
	for (i = 0; i < recipe.requiredIngredients.Size(); i += 1)
	{
		currentIngredient = recipe.requiredIngredients[i];
		itemQuantity = thePlayer.inv.GetItemQuantityByName(currentIngredient.itemName);
		if(currentIngredient.quantity > itemQuantity)
		{
			fontColor = "<font color=\"#FF0000\">";
		}
		else
		{
			fontColor = "<font color=\"#00FF00\">";
		}
		finalString += htmlNewline + fontColor + itemQuantity + " / " + currentIngredient.quantity + " " + GetLocStringByKeyExt( _inv.GetItemLocalizedNameByName(currentIngredient.itemName ) ) + "</font>";
	}
	
	return finalString;
}

@wrapMethod(W3GuiBaseInventoryComponent) function GetSchematicBookText(item : SItemUniqueId):string
{
	var dm 					: CDefinitionsManagerAccessor;
	var finalString			: string;
	var tempString			: string;
	var htmlNewline			: string;
	var craftingSchematic	: SCraftingSchematic;
	var craftedItemName		: name;
	var currentIngredient	: SItemParts;
	var i					: int;
	var color				: string;
	var attributes			: array<SAttributeTooltip>;
	var minWeightAttribute 	: SAbilityAttributeValue;
	var maxWeightAttribute 	: SAbilityAttributeValue;
	var minQuality 			: int;
	var maxQuality 			: int;
	var itemType 			: EInventoryFilterType;
	var itemQuantity		: int;
	var fontColor	 		: string;
	
	var delimiter			: string;
	var prefix				: string;
	var language 	  		: string;
	var audioLanguage 		: string;
	
	if(false) 
	{
		wrappedMethod(item);
	}
	
	theGame.GetGameLanguageName(audioLanguage,language);
	if (language == "AR")
	{
		delimiter = "";
		prefix = "&nbsp;";
	}
	else
	{
		delimiter = ": ";
		prefix = "";
	}
	
	htmlNewline = "&#10;";
	finalString = "";
	
	dm = theGame.GetDefinitionsManager();
	craftingSchematic = getCraftingSchematicFromName(_inv.GetItemName(item));
	craftedItemName = craftingSchematic.craftedItemName;
	_inv.GetItemStatsFromName(craftedItemName, attributes);
	_inv.GetItemQualityFromName(craftedItemName, minQuality, maxQuality);
	itemType = dm.GetFilterTypeByItem(craftedItemName);
	dm.GetItemAttributeValueNoRandom(craftedItemName, true, 'weight', minWeightAttribute, maxWeightAttribute);

	tempString = GetLocStringByKeyExt(GetFilterTypeName( itemType )) + " / " + GetLocStringByKeyExt("item_category_" + dm.GetItemCategory(craftedItemName));
	finalString += "<font color=\"#FF8832\">" + tempString + "</font>";
	finalString += htmlNewline + GetItemRarityDescriptionFromInt(minQuality);
	
	if (attributes.Size() > 0)
	{
		finalString += htmlNewline;
		for (i = 0; i < attributes.Size(); i += 1)
		{
			
			color = attributes[i].attributeColor;
			tempString = htmlNewline + "<font color=\"#" + color + "\">";
			if( attributes[i].percentageValue )
			{
				tempString += (NoTrailZeros(attributes[i].value * 100 ) +"%" + prefix);
			}
			else
			{
				tempString += (NoTrailZeros(attributes[i].value) + prefix);
			}
			tempString += " " + attributes[i].attributeName;
			tempString += "</font>";
			finalString += tempString;
		}
	}
	
	finalString += htmlNewline;
	finalString += htmlNewline + "<font color=\"#C49560\">" + GetLocStringByKeyExt(_inv.GetItemLocalizedDescriptionByName(craftedItemName)) + "</font>";
	
	finalString += htmlNewline;
	finalString += htmlNewline + _inv.GetItemLevelColor( theGame.GetDefinitionsManager().GetItemLevelFromName( craftedItemName ) ) + GetLocStringByKeyExt( 'panel_inventory_item_requires_level' ) + ": " + theGame.GetDefinitionsManager().GetItemLevelFromName( craftedItemName ) + "</font>"; 

	finalString += htmlNewline;
	finalString += htmlNewline + GetLocStringByKeyExt("panel_crafting_ingredients_start") + ":";
	
	for (i = 0; i < craftingSchematic.ingredients.Size(); i += 1)
	{
		currentIngredient = craftingSchematic.ingredients[i];
		itemQuantity = thePlayer.inv.GetItemQuantityByName(currentIngredient.itemName);
		if(currentIngredient.quantity > itemQuantity)
		{
			fontColor = "<font color=\"#FF0000\">";
		}
		else
		{
			fontColor = "<font color=\"#00FF00\">";
		}
		finalString += htmlNewline + fontColor + itemQuantity + " / " + currentIngredient.quantity + " " + GetLocStringByKeyExt( _inv.GetItemLocalizedNameByName(currentIngredient.itemName ) ) + "</font>";
	}
	
	return finalString;
}

@wrapMethod( W3GuiBaseInventoryComponent ) function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
{
	var uiData : SInventoryItemUIData;
	var slotType : EEquipmentSlots;
	var curr, max : float;
	var gridSize : int;
	var equipped : int;
	var isQuest	 : bool;
	var canDrop	 : bool;
	var maxAmmo  : int;
	var charges  : string;
	var cantEquip : bool;
	var weight : float;
	var durability : float;
	var price : int;
	var colorName:name;
	var i : int;
	var highlightedItemsCount : int;
	var itemName : name;
	var quantity : int;
	var bRead : bool;
	var tmp: bool;
	var chargesCount:int;

	if (false 
	|| (theGame.GetDLCManager().IsDLCAvailable('dlc_eh') && theGame.GetDLCManager().IsDLCEnabled('dlc_eh') )
	|| (theGame.GetDLCManager().IsDLCAvailable('dlcvhud') && theGame.GetDLCManager().IsDLCEnabled('dlcvhud') )
	)
	{
		wrappedMethod(item, flashObject);

		return;
	}
	
	uiData = _inv.GetInventoryItemUIData( item );
	slotType = GetItemEquippedSlot( item );
	equipped = GetCurrentSlotForItem( item );
	isQuest = _inv.ItemHasTag(item,'Quest');
	canDrop = !isQuest && !_inv.ItemHasTag(item, 'NoDrop');
		
	if( slotType == EES_Quickslot2 && !_inv.IsItemMask( item ) ) 
	{
		slotType = EES_Quickslot1;
	}
	
	if( slotType == EES_Petard2 ) 
	{
		slotType = EES_Petard1;
	}
	
	if( _inv.ItemHasTag(item, 'NoEquip') )
		slotType = EES_InvalidSlot;
	
	flashObject.SetMemberFlashInt( "id", ItemToFlashUInt(item) );
	
	if(_inv.IsItemSingletonItem(item))
	{
		if( thePlayer.inv.SingletonItemGetMaxAmmo(item) > 0 )
		{
			chargesCount = thePlayer.inv.SingletonItemGetAmmo(item);
			
			if( chargesCount <= 0 )
			{
				charges = "<font color=\"#CC0000\">" +  chargesCount + " " +"</font>";
			}
			else
			{
				charges = "<font color=\"#DEDEDE\">" +  chargesCount +  " " +"</font>";
			}
		}
		else
		{
			charges = "";
		}
		
		flashObject.SetMemberFlashString( "charges",  charges);
		flashObject.SetMemberFlashInt( "quantity", quantity);
	}
	else
	{
		quantity = _inv.GetItemQuantity(item);
		flashObject.SetMemberFlashInt( "quantity", quantity);
	}
	
	itemName = _inv.GetItemName(item); 
	
	highlightedItemsCount = highlightedItems.Size();
	if (highlightedItemsCount > 0)
	{
		itemName = _inv.GetItemName(item);
		
		for (i = 0; i < highlightedItemsCount; i += 1)
		{
			if (highlightedItems[i] == itemName)
			{
				flashObject.SetMemberFlashBool( "highlighted", true );
			}
		}
	}		
	
	if( _inv.ItemHasTag( item, 'ReadableItem' ) && !isItemSchematic( item ) )
	{
		bRead = _inv.IsBookRead(item);
		
		flashObject.SetMemberFlashBool( "isReaded", bRead );
	}
	
	durability = _inv.GetItemDurability(item) / _inv.GetItemMaxDurability(item);
	weight = _inv.GetItemEncumbrance( item );
	price = _inv.GetItemQuantity(item) * _inv.GetItemPrice(item);
	flashObject.SetMemberFlashNumber("durability", durability); 
	flashObject.SetMemberFlashNumber("weight", weight); 
	flashObject.SetMemberFlashInt( "price", price); 
	flashObject.SetMemberFlashString( "iconPath",  _inv.GetItemIconPathByUniqueID(item) );
	if (GridPositionEnabled())
	{
		flashObject.SetMemberFlashInt( "gridPosition", uiData.gridPosition );
	}
	else
	{
		flashObject.SetMemberFlashInt( "gridPosition", -1 );
	}
	gridSize =  Clamp( uiData.gridSize, 1, 2 ); 
	
	if( _inv.IsItemColored( item ) )
	{
		colorName = _inv.GetItemColor( item );
		flashObject.SetMemberFlashString( "itemColor", NameToString( colorName ) );
	}
	
	flashObject.SetMemberFlashInt( "gridSize", gridSize );
	flashObject.SetMemberFlashInt( "slotType", slotType );
	flashObject.SetMemberFlashBool( "isNew", uiData.isNew );
	
	if( autoCleanNewMark && uiData.isNew )
	{
		uiData.isNew = false;
		_inv.SetInventoryItemUIData( item, uiData );
	}
	
	flashObject.SetMemberFlashBool( "isOilApplied", _inv.ItemHasAnyActiveOilApplied(item) && !_inv.IsItemOil( item ) );
	flashObject.SetMemberFlashInt( "equipped", equipped );
	
	if (theGame.GetDLCManager().IsDLCAvailable('dlcvhud') 
	&& theGame.GetDLCManager().IsDLCEnabled('dlcvhud') 
	)
	{
		if (theGame.GetInGameConfigWrapper().GetVarValue('vlad', 'quality')) flashObject.SetMemberFlashInt( "quality", _inv.GetItemQuality( item ) ); 
		else if (GetWitcherPlayer().IsItemEquipped(item)) flashObject.SetMemberFlashInt( "quality", 1 );
		
		flashObject.SetMemberFlashInt("rarity", _inv.GetItemQuality( item ) );
		flashObject.SetMemberFlashBool("dyable", _inv.ItemHasTag(item, 'HoodsDyable') || _inv.ItemHasTag(item, 'Dyable') );
	}
	else
	{
		flashObject.SetMemberFlashInt( "quality", _inv.GetItemQuality( item ) );
	}
	
	flashObject.SetMemberFlashInt( "socketsCount", _inv.GetItemEnhancementSlotsCount( item ) );
	flashObject.SetMemberFlashInt( "socketsUsedCount", _inv.GetItemEnhancementCount( item ) );
	flashObject.SetMemberFlashInt( "groupId", -1);
	
	
	flashObject.SetMemberFlashBool( "isSilverOil", (_inv.ItemHasTag(item, 'SilverOil')||_inv.ItemHasTag(item, 'SteelOil')) );
	flashObject.SetMemberFlashBool( "isSteelOil", (_inv.ItemHasTag(item, 'SilverOil')||_inv.ItemHasTag(item, 'SteelOil')) );
	flashObject.SetMemberFlashBool( "isArmorUpgrade", _inv.ItemHasTag(item, 'ArmorUpgrade') );
	flashObject.SetMemberFlashBool( "isWeaponUpgrade",  _inv.ItemHasTag(item, 'WeaponUpgrade') );
	flashObject.SetMemberFlashBool( "isArmorRepairKit", _inv.ItemHasTag(item, 'ArmorReapairKit') );
	flashObject.SetMemberFlashBool( "isWeaponRepairKit", _inv.ItemHasTag(item, 'WeaponReapairKit') );
	flashObject.SetMemberFlashBool( "isDye", _inv.IsItemDye( item ) );
	flashObject.SetMemberFlashBool( "isMask", _inv.IsItemMask( item ) ); 
	
	
	flashObject.SetMemberFlashBool( "canBeDyed", !_inv.ItemHasTag(item, 'noDye') );
	
	flashObject.SetMemberFlashBool( "showExtendedTooltip", true );
	
	tmp = _inv.IsItemEnchanted(item);
	flashObject.SetMemberFlashBool( "enchanted", tmp);
	
	if( _inv.HasItemDurability(item) )
	{
		curr = RoundMath( _inv.GetItemDurability(item) / _inv.GetItemMaxDurability(item) * 100);

		if ( curr == 100 )
		{
			curr = 99.99;
		}
		
		flashObject.SetMemberFlashNumber( "durability", curr );
		
		if( curr <= ITEM_NEED_REPAIR_DISPLAY_VALUE )
		{
			flashObject.SetMemberFlashBool( "needRepair", true );
		}
		else
		{
			flashObject.SetMemberFlashBool( "needRepair", false );				
		}
	}
	else
	{
		flashObject.SetMemberFlashBool( "needRepair", false );
		flashObject.SetMemberFlashNumber( "durability", 1);
	}
	
	if( thePlayer.IsInCombatAction() && IsUnequipSwordIsAlllowed(item))
	{
		flashObject.SetMemberFlashInt( "actionType", IAT_None );	
	}
	else
	{
		flashObject.SetMemberFlashInt( "actionType", GetItemActionType( item ) );
	}

	flashObject.SetMemberFlashBool( "cantEquip", cantEquip );
	
	flashObject.SetMemberFlashString( "category", _inv.GetItemCategory(item) );
}

@wrapMethod( W3GuiBaseInventoryComponent ) function GetInventoryFlashArray( out flashArray : CScriptedFlashArray, flashObject : CScriptedFlashObject ) : void
{
	spectreManageStrongAlcoholData(_inv);
	wrappedMethod(flashArray, flashObject);
}	
