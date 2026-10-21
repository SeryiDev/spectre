@replaceMethod(W3TooltipComponent) function GetBaseItemData( item : SItemUniqueId, itemInvComponent : CInventoryComponent, optional isShopItem : bool, optional compareWithItem : SItemUniqueId, optional compareItemInv : CInventoryComponent ) : CScriptedFlashObject
{
	var wplayer		     : W3PlayerWitcher;
	var tooltipData  	 : CScriptedFlashObject;
	var genericStatsList : CScriptedFlashArray;
	var statsList        : CScriptedFlashArray;
	var propsList	     : CScriptedFlashArray;
	var socketsList	     : CScriptedFlashArray;
	
	var itemName 			: name;
	var transmogAppearance	: name;
	var itemLabel			: string;
	var itemSlot     		: EEquipmentSlots;
	var equipedItem 		: SItemUniqueId;
	var equipedItemName		: name;
	var equipedItemStats	: array<SAttributeTooltip>;
	
	var weightAttribute		  : SAbilityAttributeValue;
	var categoryName		  : name;
	var categoryLabel		  : string;
	var typeString			  : string;
	var typeDesc			  : string;
	var weightValue 		  : float;	
	
	var primaryStatLabel       : string;
	var primaryStatValue       : float;
	var primaryStatOriginValue : float;
	
	var primaryStatDiff     		 : string;
	var primaryStatDiffValue		 : float;
	var primaryStatDiffStr  		 : string;
	var eqPrimaryStatLabel  		 : string;
	var eqPrimaryStatValue  		 : float;
	var primaryStatDurabilityPenalty : float;
	var durMult 					 : float;
	
	var uniqueDescription	: string;
	var durabilityValue		: int;
	var durabilityStrValue	: string;
	var durabilityLabel 	: string;
	var durabilityRatio     : float;
	
	var armorType			: string;
	
	
	
	var itemStats 			: array<SAttributeTooltip>;
	var compStats			: array<SAttributeTooltip>;
	var isWeaponOrArmor		: bool;
	
	var isArmorOrWeapon		: bool;
	var tmpStr				: string;
	
	var invItem : SInventoryItem;
	var invItemPrice : int;
	var invItemPriceString : string;
	
	var allItems	: array< SItemUniqueId >;
	var i,j : int;
	var m_schematicList, m_recipeList, arrNames, arrUniqueNames : array< name >;
	var itemCategory : name;
	
	var requiredLevel		  : string;
	var additionalDescription : string;
	var alchRecipe            : SAlchemyRecipe;
	
	var craftSchematic        : SCraftingSchematic;
	var craftItemName	      : name;
	var craftItemCategory     : name;
	
	
	var ignorePrimaryStat	  : bool;
	var itemAttributePrefix	  : string;
	
	var rarityColor : string;
	var canBeCompared  : bool;		
	var itemLevel, craftedItemLevel : int;
	
	var armorTypeGlyphWordBonus : bool;
	var armorEnumType : EArmorType;
	
	var ammo, ammoBonus : float;
	var additionalRarityDescription : string;
	
	var definitionsMgr : CDefinitionsManagerAccessor;
	
	if (!IsInited())
	{
		LogChannel('GUI_Tooltip', "W3TooltipComponent is not initialized, can't get tooltip data");
		return NULL;
	}
	if( !itemInvComponent.IsIdValid(item) )
	{
		LogChannel('GUI_Tooltip', "W3TooltipComponent.GetBaseItemData incorrect item ID");
		return NULL;
	}		
	
	
	
	
	if (!compareItemInv)
	{
		compareItemInv = m_playerInv;
	}
	
	definitionsMgr = theGame.GetDefinitionsManager();
	wplayer = GetWitcherPlayer();
	tooltipData = m_flashValueStorage.CreateTempFlashObject();
	propsList = tooltipData.CreateFlashArray();
	socketsList = tooltipData.CreateFlashArray();
	statsList = tooltipData.CreateFlashArray();
	
	isArmorOrWeapon = itemInvComponent.IsItemAnyArmor(item) || itemInvComponent.IsItemWeapon(item) ;		
	itemName = itemInvComponent.GetItemName(item);		
	itemLabel = GetLocStringByKeyExt(itemInvComponent.GetItemLocalizedNameByUniqueID(item));
	itemSlot = itemInvComponent.GetSlotForItemId(item);
	
	
	
	categoryName =  itemInvComponent.GetItemCategory(item);
	additionalDescription = "";
	craftItemName = '';
	
	if (categoryName == 'crafting_schematic')
	{
		craftSchematic = GetSchematicDataFromXML(itemName); 
		craftItemName = craftSchematic.craftedItemName;
	}
	else
	if (categoryName == 'alchemy_recipe')
	{
		alchRecipe = GetRecipeDataFromXML(itemName);
		craftItemName = alchRecipe.cookedItemName;
	}
	else if (spectreAlchemy501())
	{
		// Alchemy 5.01 variant: no secondary substance or ingredient text.
	}
	else if (categoryName == 'potion') 
	{
		additionalDescription = theGame.alchexts.GetPotionSubstanceDescription(item); 
	}
	else 
	{
		additionalDescription = theGame.alchexts.ing_mngr.GetIngredientDescription(itemName,,true);
	}
	
	if (craftItemName != '')
	{
		
		craftItemCategory = definitionsMgr.GetItemCategory(craftItemName);
		itemInvComponent.GetItemStatsFromName(craftItemName, itemStats);
		itemInvComponent.GetPotionAttributesByName(craftItemName, itemStats);																	   
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			IncreaseNGPPrimaryStatValue( craftItemCategory, itemStats );
		}
		wplayer.GetItemEquippedOnSlot(GetSlotForItemByCategory(craftItemCategory), equipedItem);
		additionalDescription = "<br/><br/><font size = '21' color = '#B58D45'>";
		additionalDescription += StrUpperUTF(GetLocStringByKeyExt(m_playerInv.GetItemLocalizedNameByName(craftItemName))) + "</font>";
		
		if (categoryName == 'crafting_schematic' && craftItemCategory != 'upgrade' && craftItemCategory != 'junk' && !definitionsMgr.ItemHasTag(craftItemName, 'CraftingIngredient'))
		{
			craftedItemLevel = definitionsMgr.GetItemLevelFromName( craftItemName );
			if ( FactsQuerySum("NewGamePlus") > 0 )
			{
				if ( theGame.params.NewGamePlusLevelDifference() > 0 )
				{
					craftedItemLevel += theGame.params.NewGamePlusLevelDifference();
					if ( craftedItemLevel > GetWitcherPlayer().GetMaxLevel() ) 
					{
						craftedItemLevel = GetWitcherPlayer().GetMaxLevel();
					}
				}
			}
			additionalDescription += "<br/>";
			additionalDescription += itemInvComponent.GetItemLevelColor( craftedItemLevel ) + GetLocStringByKeyExt( 'panel_inventory_item_requires_level' ) + " " + craftedItemLevel + "</font>";
		}
		addComponentsInfo(item, itemInvComponent, additionalDescription);														
		
		ignorePrimaryStat = false;
		itemAttributePrefix = "";
	}
	else
	{
		itemInvComponent.GetItemBaseStats(item, itemStats);
		
		if (itemInvComponent.IsItemPotion(item) || itemInvComponent.IsItemFood(item) )
		{
			itemInvComponent.GetPotionAttributesForTooltip(item, itemStats);
		}
		if (itemInvComponent.IsItemBomb(item))
		{
			itemInvComponent.GetBombAttributesForTooltip(item, itemStats);
		}
		if (compareItemInv.IsIdValid(compareWithItem))
		{
			equipedItem = compareWithItem;
		}
		else
		{
			wplayer.GetItemEquippedOnSlot(itemSlot, equipedItem);
		}
		ignorePrimaryStat = isArmorOrWeapon;
		if (isArmorOrWeapon)
		{
			itemAttributePrefix = "+";
		}
	}
	
	if (categoryName == 'gwint')
	{
		additionalDescription += GetGwintCardDescription(itemName);
	}
	
	if (itemInvComponent.ItemHasTag(item, 'ReadableItem') && itemInvComponent.IsBookRead(item))
	{
		additionalDescription += "<br/><font color=\"#19D900\">" + GetLocStringByKeyExt("book_already_known") + "</font>";
	}

	spectreAddStrongAlcoholToxStat(itemStats, item, itemInvComponent);

	if( isShopItem )
	{
		addRecipeInfo( item, itemInvComponent, additionalDescription );
	}
	
	
	if(itemInvComponent.IsItemOil(item))
		AddOilStats(itemStats, statsList, tooltipData);
	else
		AddItemStats(itemStats, statsList, tooltipData, ignorePrimaryStat, itemAttributePrefix, isArmorOrWeapon || itemInvComponent.IsItemTrophy(item));
	AddBuffStats(item, itemInvComponent, statsList, tooltipData);
	
	
	
	primaryStatDiff = "none";
	primaryStatDiffValue = 0;
	primaryStatDiffStr = "";
	eqPrimaryStatValue = 0;
	
	if( compareItemInv.IsIdValid( equipedItem ) && !( equipedItem == item && compareItemInv == itemInvComponent ) )
	{
		equipedItemName = compareItemInv.GetItemName(equipedItem);
		
		if (compareItemInv.GetItemCategory(equipedItem) == 'crossbow')
		{
			GetCrossbowPrimatyStat(equipedItem, compareItemInv, eqPrimaryStatLabel, eqPrimaryStatValue);
		}
		else
		{
			compareItemInv.GetItemPrimaryStat(equipedItem, eqPrimaryStatLabel, eqPrimaryStatValue);
			if( compareItemInv.ItemHasTag( equipedItem, 'Aerondight' ) )
			{
				if( compareItemInv.GetItemModifierFloat( equipedItem, 'PermDamageBoost' ) >= 0.f )
				{
					eqPrimaryStatValue += compareItemInv.GetItemModifierFloat( equipedItem, 'PermDamageBoost' );
				}
			}
		}
		
		canBeCompared = isArmorOrWeapon;
	}
	else
	{		
		canBeCompared = false;
	}
	
	if (categoryName == 'crossbow')
	{
		GetCrossbowPrimatyStat(item, itemInvComponent, primaryStatLabel, primaryStatOriginValue);
	}
	else
	{
		itemInvComponent.GetItemPrimaryStat(item, primaryStatLabel, primaryStatOriginValue);
	}
	
	if( false && itemInvComponent.IsItemSingletonItem( item ) && ( itemInvComponent.SingletonItemGetMaxAmmo(item) > 0 ) )
	{
		if( itemInvComponent.IsItemOil( item ) )
		{
			ammo = CalculateAttributeValue( itemInvComponent.GetItemAttributeValue(item, 'ammo') );
			
			if( thePlayer.CanUseSkill( S_Alchemy_s06 ) )
			{
				ammoBonus = CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Alchemy_s06, 'ammo_bonus', false, false ) );
				ammoBonus = ammo * (1 + ammoBonus * thePlayer.GetSkillLevel( S_Alchemy_s06 ) ) - ammo;
				tooltipData.SetMemberFlashString( "charges", RoundF( ammo ) + " ( +" + RoundF( ammoBonus ) + " ) " + GetLocStringByKeyExt( "inventory_tooltip_charges" ) );
			}
			else
			{
				tooltipData.SetMemberFlashString( "charges", RoundF( ammo ) + " " + GetLocStringByKeyExt( "inventory_tooltip_charges" ) );
			}
		}
		else
		{
			tooltipData.SetMemberFlashString( "charges", itemInvComponent.SingletonItemGetAmmo( item ) + "/" + itemInvComponent.SingletonItemGetMaxAmmo( item )+ " " + GetLocStringByKeyExt( "inventory_tooltip_charges" ) );
		}
	}
	else if( itemInvComponent.GetItemName( item ) == 'q705_tissue_extractor' )
	{
		tooltipData.SetMemberFlashString( "charges", thePlayer.GetTissueExtractorChargesCurr() + "/" + thePlayer.GetTissueExtractorChargesMax() + " " + GetLocStringByKeyExt( "inventory_tooltip_charges" ) );
	}
	
	if (isArmorOrWeapon)
	{
		primaryStatValue = RoundMath(primaryStatOriginValue);
		
		if (canBeCompared)
		{
			eqPrimaryStatValue = RoundMath(eqPrimaryStatValue);
		}
		else
		{
			eqPrimaryStatValue = primaryStatValue;
		}
		
		primaryStatDiff = GetStatDiff(primaryStatValue, eqPrimaryStatValue);
		primaryStatDiffValue = primaryStatValue - eqPrimaryStatValue;
		
		if (primaryStatDiffValue > 0)
		{
			primaryStatDiffStr = "<font color=\"#19D900\">+" + NoTrailZeros(primaryStatDiffValue) + "</font>";
		}
		else if (primaryStatDiffValue < 0)
		{
			primaryStatDiffStr = "<font color=\"#E00000\">" + NoTrailZeros(primaryStatDiffValue) + "</font>";
		}
		
		if (itemInvComponent.IsItemEnchanted(item))
		{
			AddEnchantmentData(item, itemInvComponent, tooltipData);
		}
	}

	if( ( isArmorOrWeapon || categoryName == 'mask' ) && itemInvComponent.IsItemSetItem( item ) && itemInvComponent.ItemHasTag(item, 'SetBonusPiece') || itemInvComponent.IsSetArmorType(item) )
	{
		AddSetAttributes( item, itemInvComponent, tooltipData );
	}		
	
	if (itemInvComponent.IsItemWeapon(item))
	{
		tooltipData.SetMemberFlashNumber("PrimaryStatDelta", .1);
	}
	else
	{
		tooltipData.SetMemberFlashNumber("PrimaryStatDelta", 0);
	}
	
	
	
	weightValue = itemInvComponent.GetItemEncumbrance( item );

	if(itemInvComponent.ItemHasTag(item, 'spectreStrongAlcoholTag')) 
	{
		categoryLabel = GetLocStringByKeyExt("item_category_edibles") + " / " + GetLocStringById(1099516); 
	}
	else if (categoryName == 'horse_bag' || categoryName == 'horse_blinder' || categoryName == 'horse_saddle' )
	{
		categoryLabel = GetLocStringByKeyExt("item_category_misc");
	}
	else if (itemInvComponent.ItemHasTag(item, 'SecondaryWeapon'))
	{
		categoryLabel = GetLocStringByKeyExt("item_category_secondary");
	}
	else
	{
		categoryLabel = GetLocStringByKeyExt("item_category_" + categoryName);
	}
	typeString = GetLocStringByKeyExt(GetFilterTypeName( itemInvComponent.GetFilterTypeByItem(item) ));
	
	uniqueDescription = "";
	if( itemInvComponent.ItemHasTag(item, 'Mutagen') )
	{
		itemInvComponent.FillInMutagenDescription(item, uniqueDescription);
	}
	else if( categoryName == 'alchemy_recipe' && theGame.GetDefinitionsManager().ItemHasTag(craftItemName, 'Mutagen') )
	{
		itemInvComponent.FillInMutagenDescriptionByName(craftItemName, uniqueDescription);
	}
	else if (categoryName == 'gwint')
	{
		uniqueDescription = "";
	}
	else if (!isArmorOrWeapon)
	{
		if(!itemInvComponent.IsItemHorseItem(item))
			uniqueDescription = GetLocStringByKeyExt( StrReplaceAll(itemInvComponent.GetItemLocalizedNameByUniqueID(item), "item_name_", "item_desc_") );
		if(uniqueDescription == "")
		{
			if( categoryName == 'junk' && !itemInvComponent.ItemHasRecyclingParts(item) )
				uniqueDescription = GetLocStringByKeyExt( "item_desc_junk_no_ingr" );
			else
				uniqueDescription = GetLocStringByKeyExt( itemInvComponent.GetItemLocalizedDescriptionByUniqueID(item) );
		}
	}
	else
	{																								
		uniqueDescription = GetLocStringByKeyExt( itemInvComponent.GetItemLocalizedDescriptionByUniqueID(item) );
	}
	if ( theGame.GetGuiManager().GetShowItemNames() )
	{
		uniqueDescription = "<font color=\"#FFDB00\">Item name: '" + itemName + "'</font><br>" + uniqueDescription;
	}
	
	if( itemInvComponent.ItemHasTag( item, 'Aerondight' ) )
	{
		uniqueDescription = GetAerondightTooltipDescription( itemInvComponent, item );
	}
	if( itemInvComponent.ItemHasTag( item, 'PhantomWeapon' ) ) 
	{
		uniqueDescription = GetIrisTooltipDescription( item );
	}
	
	uniqueDescription += additionalDescription;
	
	uniqueDescription = itemInvComponent.GetEnhancedBuffInfo(item) + uniqueDescription;
	
	if (categoryName == 'armor'|| categoryName == 'pants' || categoryName == 'boots' || categoryName == 'gloves')
	{
		armorType = "";
		armorTypeGlyphWordBonus = false; 
		armorEnumType = itemInvComponent.GetArmorType(item);
		
		switch (armorEnumType)
		{
			case EAT_Light:
				armorType = GetLocStringByKeyExt("item_type_light_armor");
				break;
			case EAT_Medium:
				armorType = GetLocStringByKeyExt("item_type_medium_armor");
				break;
			case EAT_Heavy:
				armorType = GetLocStringByKeyExt("item_type_heavy_armor");
				break;
		}
		
		tooltipData.SetMemberFlashBool("hasEnchantedType", armorTypeGlyphWordBonus);
		typeDesc = armorType;
	} 
	else
	{
		typeDesc = categoryLabel;
	}
	
	if(itemInvComponent.ItemHasTag(item, 'spectreStrongAlcoholTag') && uniqueDescription == GetLocStringByKeyExt("item_desc_alchemy_ingredient")) 
	{
		uniqueDescription = GetLocStringById(1084296);
	}

	if ( itemInvComponent.IsItemAnyArmor(item) || itemInvComponent.IsItemBolt(item) || itemInvComponent.IsItemWeapon(item) )
	{
		itemLevel = itemInvComponent.GetItemLevel( item );
		requiredLevel = itemInvComponent.GetItemLevelColorById( item ) + GetLocStringByKeyExt( 'panel_inventory_item_requires_level' ) + " " + itemLevel + "</font>";
	}
	else
	{
		requiredLevel = "";
	}
	
	// The required level shows only while gear has one ("Equip gear of any level" off).
	if (!spectreEquipAnyLevel())
		tooltipData.SetMemberFlashString("RequiredLevel", requiredLevel);
	
	if (categoryName == 'alchemy_recipe' )
	{
		
		m_recipeList     = GetWitcherPlayer().GetAlchemyRecipes();
		itemInvComponent.GetAllItems( allItems );
		for( j = 0; j < m_recipeList.Size(); j+= 1 )
		{	
			if ( itemInvComponent.GetItemName(item) == m_recipeList[j] )
			{
				typeDesc = "<font color='#FF0000'>" + GetLocStringByKeyExt("item_recipe_known");
				break;
			}
		}
		
		categoryLabel = GetLocStringByKeyExt("item_category_misc");
	}
	else if (categoryName == 'crafting_schematic' )
	{
		
		m_schematicList = GetWitcherPlayer().GetCraftingSchematicsNames();			
		itemInvComponent.GetAllItems( allItems );
		for( j = 0; j < m_schematicList.Size(); j+= 1 )
		{	
			if ( itemInvComponent.GetItemName(item) == m_schematicList[j] )
			{
				typeDesc = "<font color='#FF0000'>" + GetLocStringByKeyExt("item_schematic_known");
				break;
			}
		}
	}
	
	
	
	AddOilInfo(item, itemInvComponent, tooltipData);
	AddSocketsInfo(item, itemInvComponent, socketsList);
	
	if(weightValue != 0)
	{
		tmpStr = FloatToStringPrec( weightValue, 2 );
		addGFxItemStat(propsList, "weight", tmpStr, "attribute_name_weight");
	}

	durMult = 1;
	if ( isArmorOrWeapon && !itemInvComponent.IsItemBolt( item ) )
	{
		durabilityRatio = itemInvComponent.GetItemDurabilityRatio(item);
		if( durabilityRatio != -1 )
		{
			durabilityValue = RoundMath( durabilityRatio * 100);
			durabilityStrValue = IntToString(durabilityValue) + " %";
			durabilityLabel = GetLocStringByKeyExt("panel_inventory_tooltip_durability");
			if (durabilityValue < 100)
			{
				durabilityStrValue = "<font color='#E70000'>" + durabilityStrValue + "</font>";
				durabilityLabel = "<font color='#E70000'>" + durabilityLabel + "</font>";
				tooltipData.SetMemberFlashString("DurabilityDescription", GetLocStringByKeyExt("tooltip_durability_description"));
			}
			addGFxItemStat(propsList, "repair", durabilityStrValue, durabilityLabel, true);
			
			durMult = theGame.params.GetDurabilityMultiplier( durabilityRatio, itemInvComponent.IsItemWeapon(item));
			if (durMult < 1)
			{
				primaryStatDurabilityPenalty = primaryStatValue - RoundMath( primaryStatOriginValue * durMult );
			}
		}
	}
	if ( m_shopInv )
	{
		if ( isShopItem == true )
		{
			invItemPrice = m_shopInv.GetItemPriceModified( item, false );
			
			invItemPriceString = invItemPrice;
			
			if (m_shopInv.GetItemQuantity(item) > 1)
			{
				invItemPriceString += " (" + (m_shopInv.GetItemQuantity(item) * invItemPrice) + ")";
			}
			
			addGFxItemStat( propsList, "price", "<font color ='#FFFFFF' font face=\"$BoldFont\">" + invItemPriceString + "</font>", "panel_inventory_item_price" );
		}
		else
		{
			invItem = m_playerInv.GetItem( item );
			invItemPrice = m_shopInv.GetInventoryItemPriceModified( invItem, true );
			
			if ( invItemPrice < 0 || m_playerInv.ItemHasTag(item, 'Quest'))
			{
				tooltipData.SetMemberFlashString("WarningMessage", GetLocStringByKeyExt("panel_shop_not_for_sale"));
				addGFxItemStat( propsList, "notforsale", " ");
			}
			else
			{
				invItemPriceString = invItemPrice;
				
				if (m_playerInv.GetItemQuantity(item) > 1)
				{
					invItemPriceString += " (" + (m_playerInv.GetItemQuantity(item) * invItemPrice) + ")";
				}
				addGFxItemStat( propsList, "price", "<font color ='#FFFFFF'>" + invItemPriceString + "</font>", "panel_inventory_item_price" );
			}
		}
	}
	else
	{
		invItemPrice = itemInvComponent.GetItemPriceModified( item, true );
		invItemPriceString = invItemPrice;
		
		if (itemInvComponent.GetItemQuantity(item) > 1)
		{
			invItemPriceString += " (" + (itemInvComponent.GetItemQuantity(item) * invItemPrice) + ")";
		}
		
		addGFxItemStat( propsList, "price", "<font color ='#FFFFFF'>" + invItemPriceString + "</font>", "panel_inventory_item_price" );
	}
	
	
	
	if( compareItemInv.IsIdValid( compareWithItem ) )
	{
		tooltipData.SetMemberFlashString( "EquippedTitle", GetLocStringByKeyExt( "panel_blacksmith_equipped" ) );
	}	
	
	tooltipData.SetMemberFlashUInt("ItemId", ItemToFlashUInt(item));
	tooltipData.SetMemberFlashString("ItemType", typeDesc);
	tooltipData.SetMemberFlashString("ItemRarity", GetItemRarityDescription(item, itemInvComponent, rarityColor ) + additionalRarityDescription );
	tooltipData.SetMemberFlashInt("ItemRarityIdx", itemInvComponent.GetItemQuality(item));
	tooltipData.SetMemberFlashString("ItemName", rarityColor + itemLabel + "</font>");
	tooltipData.SetMemberFlashString("IconPath", itemInvComponent.GetItemIconPathByUniqueID(item) );
	tooltipData.SetMemberFlashString("ItemCategory", categoryLabel);														 
	tooltipData.SetMemberFlashString("Description", uniqueDescription);
	tooltipData.SetMemberFlashArray("SocketsList", socketsList);
	tooltipData.SetMemberFlashArray("StatsList", statsList);
	tooltipData.SetMemberFlashArray("PropertiesList", propsList);
	tooltipData.SetMemberFlashString("PrimaryStatLabel", primaryStatLabel);
	tooltipData.SetMemberFlashString("PrimaryStatDiff", primaryStatDiff);
	tooltipData.SetMemberFlashString("PrimaryStatDiffStr", primaryStatDiffStr);
	tooltipData.SetMemberFlashNumber("PrimaryStatValue", primaryStatValue);
	tooltipData.SetMemberFlashNumber("PrimaryStatDurabilityPenalty", primaryStatDurabilityPenalty);
	tooltipData.SetMemberFlashBool("CanBeCompared", canBeCompared);
	tooltipData.SetMemberFlashBool("EnableFullScreenInfo", isArmorOrWeapon);

	transmogAppearance = itemInvComponent.GetItemTemplateOverride(item);
	if(transmogAppearance)
	{
		tooltipData.SetMemberFlashString( "TransmogText", GetTransmogItemLabel(itemInvComponent.GetItemLocalizedNameByName(transmogAppearance)));
		tooltipData.SetMemberFlashString("IconPath", itemInvComponent.GetItemIconPathByName(transmogAppearance) );
	}
	
	return tooltipData;
}

@addMethod(W3TooltipComponent) function addComponentsInfo( item : SItemUniqueId, itemInvComponent : CInventoryComponent, out description : string )
{
	var schematic 		 	 : SCraftingSchematic;		
	var recipe 			 	 : SAlchemyRecipe;
	var enchantment			 : SEnchantmentSchematic;
	var itemName			 : name;
	var count	 			 : int;
	var curItemPart			 : SItemParts;
	var ingredients			 : array<SItemParts>;
	var i 					 : int;
	var itemQuantity		 : int;
	var fontColor	 		 : string;

	itemName = itemInvComponent.GetItemName(item);
	schematic = getCraftingSchematicFromName(itemName);
		
	if(schematic.schemName != '')
	{
		ingredients = schematic.ingredients;
	}			
	else 
	{
		recipe = getAlchemyRecipeFromName(itemName);
		if(recipe.recipeName != '')
		{
			ingredients = recipe.requiredIngredients;
		}
		else
		{
			enchantment = getEnchantmentSchematicFromName(itemName);
			if(enchantment.schemName != '')
			{
				ingredients = enchantment.ingredients;
			}
		}
	}
		
	count = ingredients.Size();
	for(i = 0; i < count; i += 1)
	{
		curItemPart = ingredients[i];
			
		itemQuantity = m_playerInv.GetItemQuantityByName(curItemPart.itemName);
		if(curItemPart.quantity > itemQuantity)
		{
			fontColor = "<font color=\"#FF0000\">";
		}
		else
		{
			fontColor = "<font color=\"#00FF00\">";
		}
		description += "<br/>" + fontColor + itemQuantity + " / " + curItemPart.quantity + " " + GetLocStringByKeyExt( m_playerInv.GetItemLocalizedNameByName(curItemPart.itemName ) ) + "</font>";
	}
}

@wrapMethod(W3TooltipComponent) function AddSetAttributes( itemId : SItemUniqueId, itemInvComponent : CInventoryComponent, out flashDataObj : CScriptedFlashObject ):bool
{
	var setAttributesList : CScriptedFlashArray;
	var setAttribute  	  : CScriptedFlashObject;
	var currentCount, activationCount, fullCount : int;
	var desc1, desc2, counterText : string;
	var isActive1, isActive2 : bool;
	var setType : EItemSetType;
	
	if(false) 
	{
		wrappedMethod( itemId , itemInvComponent, flashDataObj );
	}
	
	setType = GetWitcherPlayer().GetSetBonusStatusByName( itemInvComponent.GetItemName(itemId), desc1, desc2, isActive1, isActive2 );
	
	if( setType != EIST_Undefined )
	{
		currentCount = GetWitcherPlayer().GetSetPartsEquippedRaw( setType );
		activationCount = GetNumItemsRequiredForSetActivation(setType);
		fullCount = GetNumItemsRequiredForFullSet(setType);
		
		counterText = currentCount + "/" + fullCount;
		
		flashDataObj.SetMemberFlashString( "SetCounter", counterText);
		
		setAttributesList = flashDataObj.CreateFlashArray();
		
		if ( !itemInvComponent.ItemHasTag( itemId, theGame.params.ITEM_SET_TAG_BONUS ) )
		{
			setAttribute = flashDataObj.CreateFlashObject();
			setAttribute.SetMemberFlashString( "value", "" );
			setAttribute.SetMemberFlashString( "name", GetLocStringByKeyExt( "tooltip_set_bonus_not_avilable_yet" ) );
			setAttribute.SetMemberFlashBool( "active", true );
			setAttributesList.PushBackFlashObject( setAttribute );
		}

		if( isActive1 && GetWitcherPlayer().HasMixedSetsEquipped() )
			desc1 = "(" + GetWitcherPlayer().GetSetPartsEquipped( setType ) + "/" + fullCount + ") " + desc1;
		
		setAttribute = flashDataObj.CreateFlashObject();
		setAttribute.SetMemberFlashString( "value", activationCount );
		setAttribute.SetMemberFlashString( "name", desc1 );
		setAttribute.SetMemberFlashBool( "active", isActive1 );
		setAttributesList.PushBackFlashObject( setAttribute );
		
		if( desc2 != "" && fullCount != activationCount )
		{
			
			setAttribute = flashDataObj.CreateFlashObject();
			setAttribute.SetMemberFlashString( "value", fullCount );
			setAttribute.SetMemberFlashString( "name", desc2 );
			setAttribute.SetMemberFlashBool( "active", isActive2 );
			setAttributesList.PushBackFlashObject( setAttribute );
		}
		
		flashDataObj.SetMemberFlashArray( "SetStatsList", setAttributesList );
		
		return true;
	}
	else
	{
		activationCount = 4;
		fullCount = 4;
		currentCount = itemInvComponent.GetSetArmorItemDescription(itemId, counterText, desc1);
		isActive1 = (currentCount == activationCount);
		
		flashDataObj.SetMemberFlashString( "SetCounter", counterText);
		setAttributesList = flashDataObj.CreateFlashArray();
		setAttribute = flashDataObj.CreateFlashObject();
		setAttribute.SetMemberFlashString( "value", activationCount );
		setAttribute.SetMemberFlashString( "name", desc1 );
		setAttribute.SetMemberFlashBool( "active", isActive1 );
		setAttributesList.PushBackFlashObject( setAttribute );
		
		flashDataObj.SetMemberFlashArray( "SetStatsList", setAttributesList );
	}
	
	return false;
}

@wrapMethod(W3TooltipComponent) function AddOilInfo(itemId : SItemUniqueId, itemInvComponent : CInventoryComponent, out flashDataObj : CScriptedFlashObject):void
{
	var oilName		  : name;
	var oilLocName	  : string;
	var oilCharges 	  : int;
	var oilMaxCharges : int;
	var oilBonus 	  : float;
	var oilStats 	  : array<SAttributeTooltip>;
	var oilBonusValue : string;
	var i, j, count	  : int;
	var appliedOilsList : array< W3Effect_Oil >;
	var appliedOil    	: W3Effect_Oil;
	
	if(false) 
	{
		wrappedMethod(itemId, itemInvComponent, flashDataObj);
	}
	
	appliedOilsList = itemInvComponent.GetOilsAppliedOnItem( itemId );
	count = appliedOilsList.Size();
	
	for( i = 0; i < count; i+=1 )
	{
		appliedOil = appliedOilsList[i];
		oilName = appliedOil.GetOilItemName();
		
		if (oilName != '')
		{
			oilLocName = GetLocStringByKeyExt( itemInvComponent.GetItemLocalizedNameByName( oilName ) );
			oilCharges = appliedOil.GetAmmoCurrentCount();
			oilMaxCharges = appliedOil.GetAmmoMaxCount();		
			itemInvComponent.GetItemStatsFromName( oilName, oilStats );

			if( oilCharges < 1 )
				continue;
				
			oilBonusValue = oilLocName + " (" + oilCharges + "/" + oilMaxCharges + ")";
			flashDataObj.SetMemberFlashString("appliedOilInfo" +(string)(i + 1), oilBonusValue);
		}
	}
}

@addMethod(W3TooltipComponent) function AddOilStats(itemStats : array<SAttributeTooltip>, out resultGFxArray : CScriptedFlashArray, rootGFxObject : CScriptedFlashObject) : void
{
	var l_flashObject : CScriptedFlashObject;
	var currentStat	  : SAttributeTooltip;
	var i, statsCount : int;
	var valuePrefix	  : string;
	var valuePostfix  : string;
	var valueString   : string;
	var min, max      : SAbilityAttributeValue;
	
	statsCount= itemStats.Size();
	for( i = 0; i < statsCount; i += 1) 
	{
		currentStat = itemStats[i];
		if( GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_1 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Wolf_1 ), 'per_piece_oil_bonus', min, max );
			currentStat.value *= 1 + CalculateAttributeValue(min) * GetWitcherPlayer().GetSetPartsEquipped( EIST_Wolf );
		}
		valuePrefix = "";
		valuePostfix = "";
		valueString = NoTrailZeros( RoundMath( currentStat.value * 100 ) ) + " %";
		l_flashObject = rootGFxObject.CreateFlashObject();
		l_flashObject.SetMemberFlashString("id", NameToString(currentStat.originName));
		l_flashObject.SetMemberFlashString("name", currentStat.attributeName);
		l_flashObject.SetMemberFlashString("color", currentStat.attributeColor);				
		l_flashObject.SetMemberFlashString("value", valuePrefix + valueString + valuePostfix);
		l_flashObject.SetMemberFlashString("valuePrefix", valuePrefix);
		l_flashObject.SetMemberFlashBool("isPercentageValue", currentStat.percentageValue);
		l_flashObject.SetMemberFlashNumber("floatValue", currentStat.value);
		resultGFxArray.PushBackFlashObject(l_flashObject);
	}
}

@wrapMethod(W3TooltipComponent) function AddItemStats(itemStats : array<SAttributeTooltip>, out resultGFxArray : CScriptedFlashArray, rootGFxObject : CScriptedFlashObject, ignorePrimaryStat : bool, defaultPrefix : string, toggleToxicityDisplayMode : bool):void
{
	var l_flashObject : CScriptedFlashObject;
	var currentStat	  : SAttributeTooltip;
	var i, statsCount : int;
	var maxToxicity   : int;
	var valuePrefix	  : string;
	var valuePostfix  : string;
	var valueString   : string;
	
	if(false) 
	{
		wrappedMethod(itemStats, resultGFxArray, rootGFxObject, ignorePrimaryStat, defaultPrefix, toggleToxicityDisplayMode);
	}
	
	statsCount= itemStats.Size();
	for( i = 0; i < statsCount; i += 1) 
	{
		currentStat = itemStats[i];
		if(!spectreArmorRegenPenaltyOn() && currentStat.originName == 'staminaRegen_armor_mod')
		{
			continue;
		}
		if (!ignorePrimaryStat || !currentStat.primaryStat)
		{
			
			if (currentStat.originName == 'toxicity' && !toggleToxicityDisplayMode)
			{
				if (GetWitcherPlayer().CanUseSkill(S_Alchemy_s03))
				{
					currentStat.value -= CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s03, 'toxicityReduction', false, false)) * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s03);
				}
			}
			if (currentStat.originName == 'toxicity_offset' && !toggleToxicityDisplayMode)
			{
				if (GetWitcherPlayer().CanUseSkill(S_Alchemy_s14))
				{
					currentStat.value *= MaxF(0, 1 - GetWitcherPlayer().GetAdaptationToxReduction());
				}
			}
			
			if (currentStat.originName == 'toxicity_offset')
			{
				currentStat.percentageValue = false;
				valuePrefix = "";
				valuePostfix = "";
			}
			if (currentStat.originName == 'toxicity')
			{
				if (!toggleToxicityDisplayMode)
				{
					valuePrefix = "";
					valuePostfix = "";
				}
				else
				{
					valuePrefix = "+";
					valuePostfix = "";
					currentStat.attributeName = GetLocStringByKeyExt("panel_common_statistics_tooltip_current_maximum");
				}
			}
			else
			if (currentStat.originName == 'duration' || currentStat.originName == 'cloud_duration' || currentStat.originName == 'duration_out_of_cloud' || currentStat.originName == 'poison_immunity_duration')
			{
				valuePrefix = "";
				valuePostfix = " " + GetLocStringByKeyExt("per_second");
			}				
			else
			{
				valuePrefix = defaultPrefix;
				valuePostfix = "";
			}
			
			if(currentStat.originName == 'slow_motion')
			{
				currentStat.attributeName = GetLocStringByKey('attribute_name_SlowdownEffect');
			}
			else if(currentStat.originName == 'focus')
			{
				currentStat.attributeName = GetLocStringByKey('focus');
			}
			else if(currentStat.originName == 'air')
			{
				currentStat.attributeName = GetLocStringByKey('panel_hud_breath');
			}
			else if(currentStat.originName == 'vitalityCombatRegen')
			{
				currentStat.attributeName = GetLocStringByKey('panel_common_statistics_tooltip_incombat_regen');
			}
			else if(currentStat.originName == 'returned_damage')
			{
				currentStat.attributeName = GetLocStringByKey('attribute_name_return_damage');
			}
			
			if( currentStat.percentageValue )
			{
				valueString = NoTrailZeros( RoundMath( currentStat.value * 100 ) ) + " %";
			}
			else if(currentStat.originName == 'focus_gain')
			{
				valueString = NoTrailZeros(currentStat.value);
			}
			else
			{
				valueString = NoTrailZeros( RoundMath( currentStat.value ) );
			}
			if( currentStat.value < 0 && valuePrefix == "+" )
				valuePrefix = "";
			
			l_flashObject = rootGFxObject.CreateFlashObject();
			l_flashObject.SetMemberFlashString("id", NameToString(currentStat.originName));
			l_flashObject.SetMemberFlashString("name", currentStat.attributeName);
			l_flashObject.SetMemberFlashString("color", currentStat.attributeColor);				
			l_flashObject.SetMemberFlashString("value", valuePrefix + valueString + valuePostfix);
			l_flashObject.SetMemberFlashString("valuePrefix", valuePrefix);
			l_flashObject.SetMemberFlashBool("isPercentageValue", currentStat.percentageValue);
			l_flashObject.SetMemberFlashNumber("floatValue", currentStat.value);
			resultGFxArray.PushBackFlashObject(l_flashObject);
		}
	}
}

@wrapMethod(W3TooltipComponent) function AddBuffStats(itemId : SItemUniqueId, itemInvComponent : CInventoryComponent, out resultGFxArray : CScriptedFlashArray, rootGFxObject : CScriptedFlashObject) : void
{
	var min, max 		 : SAbilityAttributeValue;
	var curFlashObject   : CScriptedFlashObject;
	var buffDuration     : float;
	var idx, len         : int;
	var curBufValue      : float;
	var curBufValueStr   : string;
	var additionalBufStr : string;
	var isEdibles : bool;
	var isDrinks  : bool;
	var isPotion, isMutagenPotion  : bool;
	
	var t1:int;
	var t2:int;
	
	if(false) 
	{
		wrappedMethod(itemId, itemInvComponent, resultGFxArray, rootGFxObject);
	}
		
	isEdibles = itemInvComponent.ItemHasTag(itemId, 'Edibles');
	isDrinks = itemInvComponent.ItemHasTag(itemId, 'Drinks');
	isPotion = itemInvComponent.ItemHasTag(itemId, 'Potion');
	isMutagenPotion = itemInvComponent.ItemHasTag(itemId, 'Mutagen');
	
	if (isPotion)
	{
		buffDuration = GetWitcherPlayer().CalculatePotionDuration( itemId, isMutagenPotion );
	}
	
	if (isEdibles || isDrinks || itemInvComponent.IsItemBomb(itemId))
	{
		buffDuration = GetBuffDuration(itemId, itemInvComponent);
	}
	
	if (buffDuration > 0 )
	{
		len = resultGFxArray.GetLength();
		
		for (idx = 0; idx < len; idx+=1)
		{
			curFlashObject = resultGFxArray.GetElementFlashObject(idx);
			
			if (curFlashObject.GetMemberFlashString("id") == NameToString('duration'))
			{
				curBufValue = 0;
				
				if (isEdibles || isDrinks)
				{
					resultGFxArray.RemoveElement(idx);
					continue;
				}
				
				curBufValue = curFlashObject.GetMemberFlashNumber("floatValue");
				
				curBufValue += buffDuration;	 
				if (isPotion)
				{
					curBufValue = buffDuration;
				}
				curBufValueStr = NoTrailZeros( RoundMath( curBufValue) ) + " " + GetLocStringByKeyExt("per_second");
				
				curFlashObject.SetMemberFlashString("value",  curBufValueStr);
				curFlashObject.SetMemberFlashNumber("floatValue", curBufValue);
				
				return;
			}
		}
		
		if(itemInvComponent.ItemHasTag(itemId, 'Alcohol') && GetWitcherPlayer().CanUseSkill(S_Perk_15))
		{
			min = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_15, 'duration_bonus', false, false );
			buffDuration *= 1 + min.valueMultiplicative;
		}
		
		curFlashObject = rootGFxObject.CreateFlashObject();
		if (isEdibles && GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats'))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
			curBufValueStr = "<font color='#E67E0B'>" + NoTrailZeros ( RoundMath( buffDuration * (1 + min.valueMultiplicative) )) + " " + GetLocStringByKeyExt("per_second") + "</font>";
			curFlashObject.SetMemberFlashString("name", "<font color='#E67E0B'>" + GetAttributeNameLocStr('duration', false) + "</font>");
			curFlashObject.SetMemberFlashBool("enchanted", true);
		}
		else
		{
			curBufValueStr = NoTrailZeros( RoundMath( buffDuration) ) + " " + GetLocStringByKeyExt("per_second");
			curFlashObject.SetMemberFlashString("name", GetAttributeNameLocStr('duration', false));
		}
		
		curFlashObject.SetMemberFlashString("value", curBufValueStr);
		curFlashObject.SetMemberFlashNumber("floatValue", buffDuration);
		resultGFxArray.PushBackFlashObject(curFlashObject);
	}
}

@wrapMethod(W3TooltipComponent) function GetRecipeDataFromXML(recipeName:name):SAlchemyRecipe
{
	var dm : CDefinitionsManagerAccessor;
	var main, ingredients : SCustomNode;
	var tmpBool : bool;
	var tmpName : name;
	var tmpString : string;
	var tmpInt : int;
	var ing : SItemParts;
	var i,k : int;
	var rec : SAlchemyRecipe;
	
	if(false) 
	{
		wrappedMethod(recipeName);
	}
	
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('alchemy_recipes');
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
		
		if (tmpName == recipeName)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', tmpName))
				rec.cookedItemName = tmpName;
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'type_name', tmpName))
				rec.typeName = tmpName;
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
				rec.level = tmpInt;	
			if(dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'cookedItemType', tmpString))
				rec.cookedItemType = AlchemyCookedItemTypeStringToEnum(tmpString);
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'cookedItemQuantity', tmpInt))
				rec.cookedItemQuantity = tmpInt;
			
			
			ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
			for(k=0; k<ingredients.subNodes.Size(); k+=1)
			{		
				ing.itemName = '';
				ing.quantity = -1;
			
				if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))						
					ing.itemName = tmpName;
				if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
					ing.quantity = tmpInt;
					
				rec.requiredIngredients.PushBack(ing);						
			}
			
			rec.recipeName = recipeName;
			
			
			rec.cookedItemIconPath			= dm.GetItemIconPath( rec.cookedItemName );
			rec.recipeIconPath				= dm.GetItemIconPath( rec.recipeName );
			break;
		}
	}
	return rec;
}

@addMethod(W3TooltipComponent) function GetIrisTooltipDescription( sword : SItemUniqueId ) : string
{
	var uniqueDesc		: string;
	var argsInt			: array<int>;
	var dm				: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
	var min, max		: SAbilityAttributeValue;
	var phantomWeapon	: W3Effect_PhantomWeapon;
	var healthPrc		: float;
	var hitsToCharge	: float;

	dm.GetAbilityAttributeValue( 'PhantomWeaponEffect', 'dmg_bonus_prc', min, max );
	argsInt.PushBack( RoundMath( min.valueAdditive * 100 ) );
	healthPrc = min.valueAdditive;
	dm.GetAbilityAttributeValue( 'PhantomWeaponEffect', 'hitsToCharge', min, max );
	argsInt.PushBack( RoundMath( min.valueAdditive ) );
	hitsToCharge = min.valueAdditive;
	dm.GetAbilityAttributeValue( 'PhantomWeaponEffect', 'stackDrainDelay', min, max );
	argsInt.PushBack( RoundMath( min.valueAdditive ) );
	argsInt.PushBack( RoundMath( min.valueAdditive ) );
	
	phantomWeapon = (W3Effect_PhantomWeapon)thePlayer.GetBuff( EET_PhantomWeapon );
	if( phantomWeapon )
		argsInt.PushBack( phantomWeapon.GetCurrentCount() );
	else
		argsInt.PushBack( 0 );
	
	argsInt.PushBack( RoundMath( hitsToCharge ) );
	argsInt.PushBack( RoundMath( thePlayer.GetMaxHealth() * healthPrc ) );
	
	uniqueDesc = GetLocStringByKeyExtWithParams( "attribute_name_double_strike", argsInt );
	
	return uniqueDesc;
}

@replaceMethod(W3TooltipComponent) function GetAerondightTooltipDescription( itemInvComponent : CInventoryComponent, sword : SItemUniqueId ) : string
{
	var uniqueDesc		: string;
	var argsInt			: array<int>;
	var val_1, val_2	: float;
	var min, max		: SAbilityAttributeValue;
	var aerondight		: W3Effect_Aerondight;
	var dm				: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
	
	dm.GetAbilityAttributeValue( 'AerondightEffect', 'dmg_boost_per_enemy', min, max );
	argsInt.PushBack( RoundMath( min.valueAdditive ) );
	dm.GetAbilityAttributeValue( 'AerondightEffect', 'crit_dmg_bonus', min, max );
	argsInt.PushBack( RoundMath( min.valueAdditive * 100 ) );
	dm.GetAbilityAttributeValue( 'AerondightEffect', 'hitsToCharge', min, max );
	argsInt.PushBack( RoundMath( min.valueAdditive ) );
	dm.GetAbilityAttributeValue( 'AerondightEffect', 'stackDrainDelay', min, max );
	argsInt.PushBack( RoundMath( min.valueAdditive ) );
	
	uniqueDesc = GetLocStringByKeyExtWithParams( "attribute_name_aerondight", argsInt );
	
	argsInt.Clear();
	
	aerondight = (W3Effect_Aerondight)thePlayer.GetBuff( EET_Aerondight );
	if( aerondight )
	{
		argsInt.PushBack( aerondight.GetCurrentCount() );
		argsInt.PushBack( aerondight.GetMaxCount() );
		argsInt.PushBack( RoundMath( aerondight.GetDamageBoost() ) );
	}
	else
	{
		argsInt.PushBack( 0 );
		dm.GetAbilityAttributeValue( 'AerondightEffect', 'hitsToCharge', min, max );
		argsInt.PushBack( RoundMath( min.valueAdditive ) );
		argsInt.PushBack( 0 );
	}
	
	uniqueDesc += GetLocStringByKeyExtWithParams( "attribute_name_aerondight_counter", argsInt );
	
	return uniqueDesc;
}

@replaceMethod function CalculateStatsComparance(itemStats : array<SAttributeTooltip>, compareItemStats : array<SAttributeTooltip>, rootGFxObject : CScriptedFlashObject, out compResult : CScriptedFlashArray, optional ignorePrimStat : bool, optional dontCompare : bool, optional extendedData:bool)
{
	var l_flashObject	: CScriptedFlashObject;
	var attributeVal 	: SAbilityAttributeValue;
	
	var strDifference 	: string;
	var strDiffPrefix   : string;
	var strDiffPostfix  : string;
	var strDiffValue	: string;
	var strValue		: string;
	
	var percentDiff 	: float;
	var nDifference 	: float;
	var i, j, price 	: int;
	var statsCount		: int;
	var comparedStats 	: array<SAttributeTooltip>;

	var valuePrefix	  : string;
	var valuePostfix  : string;
	
	var diffValue : string;
	var statToCompareExist : bool;

	statsCount = itemStats.Size();
	for( i = 0; i < statsCount; i += 1 ) 
	{
		if(!spectreArmorRegenPenaltyOn() && itemStats[i].originName == 'staminaRegen_armor_mod')
		{
			continue;
		}
		if (!(itemStats[i].primaryStat && ignorePrimStat))
		{
			if(itemStats[i].originName == 'slow_motion')
				itemStats[i].attributeName = GetLocStringByKey('attribute_name_SlowdownEffect');
			else if(itemStats[i].originName == 'air')
				itemStats[i].attributeName = GetLocStringByKey('panel_hud_breath');
			
			l_flashObject = rootGFxObject.CreateFlashObject();
			l_flashObject.SetMemberFlashString("name",itemStats[i].attributeName);
			l_flashObject.SetMemberFlashString("color",itemStats[i].attributeColor);
			
			strDifference = "better";
			strDiffPrefix = "";
			strDiffPostfix = "";
			strDiffValue = "";
			
			valuePrefix = "";
			valuePostfix = "";
			
			statToCompareExist = false;
			
			
			if (!dontCompare)
			{			
				for( j = 0; j < compareItemStats.Size(); j += 1 )
				{
					
					if( itemStats[i].attributeName == compareItemStats[j].attributeName )
					{
						statToCompareExist = true;
						
						if( itemStats[i].percentageValue )	
						{
							nDifference = RoundMath(itemStats[i].value * 100) - RoundMath(compareItemStats[j].value * 100);
							percentDiff = AbsF( nDifference / RoundMath(itemStats[i].value * 100) );
						}
						else
						{
							nDifference = RoundMath(itemStats[i].value) - RoundMath(compareItemStats[j].value);
							percentDiff = AbsF( nDifference / RoundMath(itemStats[i].value) );
						}
						
						
						if(nDifference > 0)
						{
							strDiffPrefix = "<font color=\"#19D900\"> +";
							strDiffPostfix = "</font>";
							
							strDifference = "better";
							
						}
						
						else if(nDifference < 0)
						{
							strDiffPrefix = "<font color=\"#E00000\"> ";
							strDiffPostfix = "</font>";
							
							strDifference = "worse";
							
						}
						else
						{
							strDifference = "none";
						}
						if (nDifference != 0)
						{
							if( itemStats[i].percentageValue )						
								strDiffValue = strDiffPrefix + RoundMath(nDifference) + " %" + strDiffPostfix;
							else
								strDiffValue = strDiffPrefix + RoundMath(nDifference) + strDiffPostfix;
						}
						
						else
						{
							strDiffPrefix = "";
							strDiffPostfix = "";
							strDiffValue = "";
						}
						compareItemStats.Remove(compareItemStats[j]);
						break;
					}
				}
				
				
				if (strDiffValue == "" && !statToCompareExist)
				{
					if( itemStats[i].value < 0 )
					{
						strDifference = "worse";
						strDiffPrefix = "<font color=\"#E00000\"> ";
					}
					else
					{
						strDifference = "better";
						strDiffPrefix = "<font color=\"#19D900\"> +";
					}
					strDiffPostfix = "</font>";
					if( itemStats[i].percentageValue )
					{
						strDiffValue = strDiffPrefix + RoundMath(itemStats[i].value *100) + " %" + strDiffPostfix;
					}
					else
					{
						strDiffValue = strDiffPrefix + RoundMath(itemStats[i].value) + strDiffPostfix;
					}
				}
			}
			else
			{
				strDifference = "none";
			}
			
			l_flashObject.SetMemberFlashString("icon", strDifference);
			l_flashObject.SetMemberFlashBool("primaryStat", itemStats[i].primaryStat);
			
			if (itemStats[i].originName == 'toxicity' || itemStats[i].originName == 'toxicity_offset')
			{
				valuePrefix = "";
				valuePostfix = "";
			}
			else
			if (itemStats[i].originName == 'duration' || itemStats[i].originName == 'cloud_duration' || itemStats[i].originName == 'duration_out_of_cloud' || itemStats[i].originName == 'poison_immunity_duration')
			{
				valuePrefix = "";
				valuePostfix = " " + GetLocStringByKeyExt("per_second");
			}
			else
			if (ignorePrimStat) 
			{
				valuePrefix = "+";
				valuePostfix = "";
			}
			else
			{
				valuePrefix = "";
				valuePostfix = "";
			}
			
			if( itemStats[i].value < 0 && valuePrefix == "+" )
				valuePrefix = "";
					
			if( itemStats[i].percentageValue )
			{
				l_flashObject.SetMemberFlashString("value", valuePrefix + RoundMath( itemStats[i].value * 100 ) + " %" + valuePostfix );
			}
			
			else
			{
				l_flashObject.SetMemberFlashString("value", valuePrefix + RoundMath( itemStats[i].value ) + valuePostfix );
			}
			
			l_flashObject.SetMemberFlashString("diffValue", strDiffValue);
			
			compResult.PushBackFlashObject(l_flashObject);
		}
	}
	
	
	if (!dontCompare)
	{
		if (ignorePrimStat) 
		{
			valuePrefix = "+";
		}
		else
		{
			valuePrefix = "";
		}
		
		for( j = 0; j < compareItemStats.Size(); j += 1 )
		{
			if(!spectreArmorRegenPenaltyOn() && compareItemStats[j].originName == 'staminaRegen_armor_mod')
			{
				continue;
			}
			if (!(compareItemStats[j].primaryStat && ignorePrimStat))
			{
				l_flashObject = rootGFxObject.CreateFlashObject();
				l_flashObject.SetMemberFlashString("name",compareItemStats[j].attributeName);
				l_flashObject.SetMemberFlashString("color",compareItemStats[j].attributeColor);
				if( compareItemStats[j].value < 0 )
				{
					l_flashObject.SetMemberFlashString("icon", "better");
					diffValue = "<font color=\"#19D900\"> +";
					compareItemStats[j].value *= -1;
				}
				else
				{
					l_flashObject.SetMemberFlashString("icon", "worse");
					diffValue = "<font color=\"#E00000\"> -";
				}
				
				if( compareItemStats[j].percentageValue )
				{
					strValue = valuePrefix + "0 %";
					diffValue += RoundMath( compareItemStats[j].value * 100 ) + " %</font>";
				}
				else
				{
					strValue = valuePrefix + "0";
					diffValue += RoundMath(compareItemStats[j].value) + "</font>";
				}
				
				l_flashObject.SetMemberFlashString("value", strValue);
				l_flashObject.SetMemberFlashString("diffValue", diffValue);
				
				compResult.PushBackFlashObject(l_flashObject);
			}
		}
	}
}
