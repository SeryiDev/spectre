@wrapMethod(W3InventoryItemContext) function HandleUserFeedback(keyName:string):void 
{
	var itemsCount   : int;
	var itemCategory : name;
	var isItemValid  : bool;
	var isSchematic  : bool;
	var isArmorOrWeapon : bool;
	var playerInv    : W3GuiBaseInventoryComponent;
	var notificationText : string;
	var language : string;
	var audioLanguage : string;
	var result : bool;
	
	if(false) 
	{
		wrappedMethod(keyName);
	}
		
	isItemValid = invComponentRef.IsIdValid(currentItemId);
	
	if (!isItemValid && invSecondComponentRef && invSecondComponentRef.IsIdValid(currentItemId))
	{
		isItemValid = true;
	}
	
	if (!isItemValid)
	{
		return;
	}
	
	super.HandleUserFeedback(keyName);
	itemsCount = invComponentRef.GetItemQuantity( currentItemId );
	
	if( keyName == "gamepad_X" )
	{
		isArmorOrWeapon = invComponentRef.IsItemAnyArmor( currentItemId ) || invComponentRef.IsItemWeapon( currentItemId );
		
		if( isArmorOrWeapon )
		{
			if( invMenuRef.IsItemInPreview( currentItemId ) )
			{
				invMenuRef.UnPreviewItem( currentItemId );
			}
			else
			{
				invMenuRef.PreviewItem( currentItemId );
				return;
			}
		}
		else if(!GetWitcherPlayer().CanUseSkill(S_Perk_15) && (invComponentRef.ItemHasTag(currentItemId, 'Alcohol') || invComponentRef.ItemHasTag(currentItemId, 'Uncooked')) && !GetWitcherPlayer().ToxicityLowEnoughToDrinkPotion(EES_Potion1,currentItemId))
		{
			notificationText = GetLocStringByKeyExt("menu_cannot_perform_action_now") + "<br/>" + GetLocStringByKeyExt("panel_common_statistics_tooltip_current_toxicity");
			theGame.GetGameLanguageName(audioLanguage,language);
			if (language == "AR")
				notificationText += (int)(thePlayer.abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(thePlayer.abilityManager.GetStatMax(BCS_Toxicity)) + " :";
			else
				notificationText += ": " + (int)(thePlayer.abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(thePlayer.abilityManager.GetStatMax(BCS_Toxicity));
			theSound.SoundEvent("gui_global_denied");
			invMenuRef.showNotification(notificationText);
		} else
		if( invComponentRef.ItemHasTag(currentItemId, 'Edibles') || invComponentRef.ItemHasTag(currentItemId, 'Drinks') || invComponentRef.ItemHasTag(currentItemId, 'Consumable'))
		{
			invMenuRef.OnConsumeItem(currentItemId);
		} else
		if (invComponentRef.ItemHasTag(currentItemId, 'Potion'))
		{
			if (GetWitcherPlayer().ToxicityLowEnoughToDrinkPotion(EES_Potion1,currentItemId))	
			{
				if (thePlayer.IsInCombat())	
				{
					notificationText = GetLocStringByKeyExt("menu_cannot_perform_action_combat");

					theSound.SoundEvent("gui_global_denied");

					invMenuRef.showNotification(notificationText);
				}
				else
				{
					GetWitcherPlayer().DrinkPreparedPotion(EES_Potion1,currentItemId);
					invMenuRef.InventoryUpdateItem(currentItemId);
					
					
					if(thePlayer.inv.GetItemName(currentItemId) == 'Mutagen 3')
					{
						invMenuRef.PaperdollUpdateAll();
						invMenuRef.PopulateTabData( InventoryMenuTab_Potions );
					}
					
					invMenuRef.UpdatePlayerStatisticsData();
				}
			}
			else
			{
				notificationText = GetLocStringByKeyExt("menu_cannot_perform_action_now") + "<br/>" + GetLocStringByKeyExt("panel_common_statistics_tooltip_current_toxicity");
				theGame.GetGameLanguageName(audioLanguage,language);
				if (language == "AR")
				{
					notificationText += (int)(thePlayer.abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(thePlayer.abilityManager.GetStatMax(BCS_Toxicity)) + " :";
				}
				else
				{
					notificationText += ": " + (int)(thePlayer.abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(thePlayer.abilityManager.GetStatMax(BCS_Toxicity));
				}
				theSound.SoundEvent("gui_global_denied");
				invMenuRef.showNotification(notificationText);
			}
		}
		else if( invComponentRef.GetItemName( currentItemId ) == 'q705_tissue_extractor' )
		{
			
			result = thePlayer.TissueExtractorDischarge();
			
			if( result )
			{
				
				invMenuRef.ShowItemTooltip( currentItemId, 0 );
				
				
				invMenuRef.PopulateTabData(InventoryMenuTab_Ingredients);
				invMenuRef.InventoryUpdateItem( currentItemId );
				
				
				invMenuRef.OnPlaySoundEvent( "gui_character_buy_skill" );
			}
			else
			{
				
				invMenuRef.OnPlaySoundEvent( "gui_global_denied" );
			}
		}
		
		updateInputFeedback();
	}
	else
	if (keyName == "enter-gamepad_A")
	{
		if ( IsPadBindingExist(keyName) ) 
		{
			execurePrimaryAction();
		}
	}
	else
	if (keyName == "gamepad_Y")
	{
		invMenuRef.OnDropItem(currentItemId, itemsCount);
		
		
	}
	else
	if (keyName == "gamepad_L2")
	{
		itemCategory = invComponentRef.GetItemCategory(currentItemId); 
		isSchematic = itemCategory == 'alchemy_recipe' || itemCategory == 'crafting_schematic';
		if (isSchematic)
		{
			playerInv = invMenuRef.GetCurrentInventoryComponent();
			if (playerInv)
			{
				invMenuRef.ShowBookPopup( GetLocStringByKeyExt ( invComponentRef.GetItemLocalizedNameByUniqueID( currentItemId ) ), playerInv.GetBookText( currentItemId ), currentItemId, true );
			}
		}
	}
}

@wrapMethod(W3InventoryGridContext) function updateInputFeedback():void
{
	var currentInventoryState : EInventoryMenuState;
	var canDrop : bool;
	var isBodkinBolt : bool;
	var isQuestItem : bool;
	var curEquipedItem : SItemUniqueId;
	var cantUse : bool;
	var isArmorOrWeapon : bool;
	var buttonLabel : string;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	LogChannel('CONTEXT'," updateInputFeedback "+invMenuRef+"; "+invComponentRef);
	m_inputBindings.Clear();
	m_contextBindings.Clear();
	if (!invMenuRef || !invComponentRef)
	{
		return;
	}
	currentInventoryState = invMenuRef.GetCurrentInventoryState();
	
	if (invComponentRef.IsIdValid(currentItemId))
	{
		canDrop = !invComponentRef.ItemHasTag(currentItemId, 'NoDrop');
		isQuestItem = invComponentRef.ItemHasTag(currentItemId,'Quest');
		isBodkinBolt = invComponentRef.GetItemName(currentItemId) == 'Bodkin Bolt';
		
		
		
		cantUse = FactsQuerySum("tut_forced_preparation") > 0 && invComponentRef.GetItemName(currentItemId) == 'Thunderbolt 1';
		if(canDrop && cantUse)
		{
			canDrop = false;
		}
		
		switch (currentInventoryState)
		{
			case IMS_Player:
				
				isArmorOrWeapon = invComponentRef.IsItemAnyArmor( currentItemId ) || invComponentRef.IsItemWeapon( currentItemId );	
				
				if( isArmorOrWeapon && !invComponentRef.IsItemCrossbow( currentItemId ) && !invComponentRef.IsItemBolt( currentItemId ) )
				{
					if( invMenuRef.IsItemInPreview( currentItemId ) )
					{
						AddInputBinding( "panel_button_unpreview_item", "gamepad_X", IK_X, true );
					}
					else
					{
						AddInputBinding( "panel_button_preview_item", "gamepad_X", IK_X, true );
					}
				}

				if (invComponentRef.ItemHasTag(currentItemId, 'mod_dye'))
				{
					AddInputBinding("panel_button_hud_interaction_useitem", "enter-gamepad_A", IK_E, true);
				}
				else if( invComponentRef.GetItemName( currentItemId ) == 'q705_tissue_extractor' )
				{
					AddInputBinding("panel_button_hud_interaction_useitem", "gamepad_X", IK_X, true);
				}
				else if (invComponentRef.ItemHasTag(currentItemId, 'Painting'))
				{
					AddInputBinding("panel_button_common_examine", "enter-gamepad_A", IK_E, true);
				}
				else if (invComponentRef.ItemHasTag(currentItemId, 'ReadableItem'))
				{
					AddInputBinding("panel_button_inventory_read", "enter-gamepad_A", IK_E, true);
				}
				else if ((invComponentRef.ItemHasTag(currentItemId, 'Edibles')) ||
						(invComponentRef.ItemHasTag(currentItemId, 'Drinks')) ||
						(invComponentRef.ItemHasTag(currentItemId, 'Potion')))
				{
					if (invComponentRef.IsItemSingletonItem(currentItemId) && thePlayer.inv.SingletonItemGetAmmo(currentItemId) == 0)
					{
						cantUse = true;
					}
					
					if (!cantUse)
					{
						AddInputBinding("panel_button_inventory_consume", "gamepad_X", IK_E, true);
					}
					if ( invComponentRef.GetItemName( currentItemId ) != 'q111_imlerith_acorn'  && !invComponentRef.ItemHasTag( currentItemId, 'NoEquip' ) ) 
					{
						AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
					}
				}
				else if (invComponentRef.ItemHasTag(currentItemId, 'Upgrade'))
				{
					AddInputBinding("panel_button_inventory_put_in_socket", "enter-gamepad_A", IK_E, true);
				}
				else if (
				(
				invComponentRef.ItemHasTag(currentItemId, 'SteelOil') 
				&& 
				(
				GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, curEquipedItem) || GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, curEquipedItem)
				)
				) 
				||
				(
				invComponentRef.ItemHasTag(currentItemId, 'SilverOil') 
				&& 
				(
				GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, curEquipedItem) || GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, curEquipedItem)
				)
				)
				)
				{
					
					AddInputBinding("panel_button_inventory_upgrade", "enter-gamepad_A", IK_E, true);
				}
				else if (invComponentRef.GetSlotForItemId(currentItemId) != EES_InvalidSlot) 
				{
					AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
				}
				else if ( invComponentRef.ItemHasTag(currentItemId, 'ArmorReapairKit') )
				{
					if ( GetWitcherPlayer().HasRepairAbleGearEquiped() )
					{
						AddInputBinding("panel_button_hud_interaction_useitem", "enter-gamepad_A", IK_E, true);
					}
				}
				else if ( invComponentRef.ItemHasTag(currentItemId, 'WeaponReapairKit') )
				{
					if ( GetWitcherPlayer().HasRepairAbleWaponEquiped() )
					{
						AddInputBinding("panel_button_hud_interaction_useitem", "enter-gamepad_A", IK_E, true);
					}
				}
				else if ( invComponentRef.ItemHasTag(currentItemId, 'Sharpstone') )
				{
					AddInputBinding("panel_button_hud_interaction_useitem", "enter-gamepad_A", IK_E, true);
				}
				else if ( invComponentRef.GetItemName(currentItemId) == 'Razor' )
				{
					AddInputBinding("panel_button_hud_interaction_useitem", "enter-gamepad_A", IK_E, true);
				}
				else if ( invComponentRef.ItemHasRecyclingParts(currentItemId) && invComponentRef.GetItemQuantityByName('gear_dismantle_kit_1') > 0 && ( invComponentRef.IsItemCraftingIngredient(currentItemId) || invComponentRef.IsItemJunk(currentItemId) ) )
				{
					AddInputBinding("panel_button_hud_interaction_dismantle", "enter-gamepad_A", IK_E, true);
				}
				else if ( invComponentRef.ItemHasRecyclingParts(currentItemId) && invComponentRef.GetItemQuantityByName('alchemy_dismantle_kit_1') > 0 && invComponentRef.IsItemAlchemyIngredient(currentItemId) )
				{
					AddInputBinding("panel_button_hud_interaction_dismantle", "enter-gamepad_A", IK_E, true);
				}
				break;
			case IMS_Shop:
				if (!isBodkinBolt)
				{
					AddInputBinding("panel_inventory_quantity_popup_sell", "enter-gamepad_A", IK_Space, true);
				}
				break;
			case IMS_Container:
				AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
				break;
			case IMS_HorseInventory:
				if (IsHorseItem(currentItemId))
				{
					AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
				}
				else
				{
					AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
				}
				break;
			case IMS_Stash:
				AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
				break;
			default:
				break;
		}
		if (canDrop && !isQuestItem && !isBodkinBolt && currentInventoryState != IMS_Shop)
		{
			AddInputBinding("panel_button_common_drop", "gamepad_Y", IK_R, true);
		}
		if (invComponentRef.CanBeCompared(currentItemId))
		{
			buttonLabel = GetHoldLabel() + " " + GetLocStringByKeyExt("panel_common_compare");
			AddInputBinding(buttonLabel, "gamepad_L2", -1, true, true, true);
		}
	}
	
	m_managerRef.updateInputFeedback();
}

@wrapMethod(W3InventoryGridContext) function execurePrimaryAction():void
{
	var currentInventoryState : EInventoryMenuState;
	var itemsCount : int;
	var newId  : SItemUniqueId;
	
	if(false) 
	{
		wrappedMethod();
	}

	if ( invComponentRef.IsIdValid(currentItemId) )
	{
		currentInventoryState = invMenuRef.GetCurrentInventoryState();
		itemsCount = invComponentRef.GetItemQuantity( currentItemId );

		switch (currentInventoryState)
		{
			case IMS_Player:
				if (invComponentRef.ItemHasTag(currentItemId, 'mod_dye'))
				{
					invMenuRef.OnUseDye(currentItemId);
				}
				else if ( invComponentRef.ItemHasTag(currentItemId, 'Painting') )
				{
					invMenuRef.ShowPainting(currentItemId);
				}
				else if (invComponentRef.ItemHasTag(currentItemId, 'Sharpstone'))
				{
					invMenuRef.OnUseSharpstone(currentItemId);
				}
				else if (invComponentRef.ItemHasTag(currentItemId, 'ReadableItem'))
				{
					invMenuRef.OnReadBook(currentItemId);
				}
				else if (invComponentRef.ItemHasTag(currentItemId, 'Upgrade'))
				{
					invMenuRef.OnPutInSocket(currentItemId);
				}
				else if (invComponentRef.ItemHasTag(currentItemId, 'WeaponReapairKit') || 
						 invComponentRef.ItemHasTag(currentItemId, 'ArmorReapairKit'))
				{
					invMenuRef.OnRepairItem(currentItemId);
				}
				else if (invComponentRef.ItemHasTag(currentItemId, 'SteelOil') || 
					 invComponentRef.ItemHasTag(currentItemId, 'SilverOil'))
				{
					invMenuRef.ShowApplyOilMode(currentItemId);
				}
				else if (invComponentRef.GetItemName(currentItemId) == 'Razor')
				{
					ShaveGeralt_Quest();
					invMenuRef.spectreUpdateFace();
					theSound.SoundEvent("gui_inventory_other_attach");
					invMenuRef.showNotification(GetLocStringByKeyExt("spectre_used_razor_success"));
				}
				else if ( invComponentRef.ItemHasRecyclingParts(currentItemId) && invComponentRef.GetItemQuantityByName('gear_dismantle_kit_1') > 0 && ( invComponentRef.IsItemCraftingIngredient(currentItemId) || invComponentRef.IsItemJunk(currentItemId) ) )
				{
					invMenuRef.PlayerDismantleItem(currentItemId);
					UpdateContext();
				}
				else if ( invComponentRef.ItemHasRecyclingParts(currentItemId) && invComponentRef.GetItemQuantityByName('alchemy_dismantle_kit_1') > 0 && invComponentRef.IsItemAlchemyIngredient(currentItemId) )
				{
					invMenuRef.PlayerDismantleItem(currentItemId);
					UpdateContext();
				}
				else if (!invMenuRef.TryEquipToPockets(currentItemId, currentSlot))
				{
					invMenuRef.OnEquipItem(currentItemId, currentSlot, itemsCount);
				}
				break;
			case IMS_Shop:
				invMenuRef.OnSellItem(currentItemId, itemsCount);
				break;
			case IMS_Container:
				invMenuRef.OnTransferItem(currentItemId, itemsCount, -1);
				break;
			case IMS_HorseInventory:
				
				if (IsHorseItem(currentItemId))
				{
					newId = GetWitcherPlayer().GetHorseManager().MoveItemToHorse(currentItemId, itemsCount);
					GetWitcherPlayer().GetHorseManager().EquipItem(newId);
					invMenuRef.UpdateHorsePaperdoll();
					invMenuRef.PopulateTabData(invMenuRef.getTabFromItem(currentItemId));
				}
				else
				{
					GetWitcherPlayer().GetHorseManager().MoveItemToHorse(currentItemId, itemsCount);
					invMenuRef.UpdateHorseInventory();
					invMenuRef.PopulateTabData(invMenuRef.getTabFromItem(currentItemId));
				}
				break;
			case IMS_Stash:
				invMenuRef.MoveToStash(currentItemId);
				break;
			default:
				break;
		}
	}
}
