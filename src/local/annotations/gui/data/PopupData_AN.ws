@wrapMethod(QuantityPopupData) function OnUserFeedback( KeyCode:string ) : void
{
	var newItemId    : SItemUniqueId;
	var curInventory : CInventoryComponent;
	var updateInfiniteBolts : bool;
	var isItemEquipped : bool;

	if(false)
	{
		wrappedMethod(KeyCode);
	}
	
	updateInfiniteBolts = false;
	
	if (KeyCode == "escape-gamepad_B")
	{
		if (actionType == QTF_Dismantle && blacksmithRef)
		{
			blacksmithRef.HandleActionConfirmation(false);
		}
		ClosePopup();
	}
	else if (KeyCode == "enter-gamepad_A" && craftingRef)
	{
		craftingRef.BuyIngredient(itemId, currentValue, false);
	}
	if (KeyCode == "enter-gamepad_A")
	{
		switch(actionType)
		{
			case QTF_MoveToStash:
			
				inventoryRef.handleMoveToStashQuantity(itemId, currentValue);
				break;
				
			case QTF_Sell:
				
				newItemId = inventoryRef.SellItem(itemId, currentValue);
				
				curInventory = inventoryRef.getShopInventory();
				
				if (curInventory && curInventory.IsIdValid(newItemId))
				{

					if (currentValue == maxValue)
					{
						inventoryRef.InventoryRemoveItem(itemId);
					}
					else
					{
						inventoryRef.InventoryUpdateItem(itemId);
					}
					inventoryRef.ShopUpdateItem(newItemId); 
					inventoryRef.UpdatePlayerMoney();
					inventoryRef.UpdateMerchantData();
				}
				break;
				
			case QTF_Buy:
				
				inventoryRef.BuyItem(itemId, currentValue);
				
				inventoryRef.UpdatePlayerMoney();
				inventoryRef.UpdateMerchantData();
				
				break;
			case QTF_Give:
				
				inventoryRef.GiveItem(itemId, currentValue);
				inventoryRef.UpdateData();
				
				break;
			case QTF_Take:
				
				inventoryRef.TakeItem(itemId, currentValue);
				inventoryRef.UpdateData();
				
				break;
			case QTF_Drop:
				
				curInventory = inventoryRef.GetCurrentInventory(itemId);
				
				isItemEquipped = GetWitcherPlayer().IsItemEquipped(itemId);
				
				if (curInventory.IsItemBolt(itemId) && !curInventory.ItemHasTag(itemId, theGame.params.TAG_INFINITE_AMMO))
				{
					updateInfiniteBolts = true;
				}
				
				if(inventoryRef)
					inventoryRef.OnUpdateGFxButtonsList();
				if (!inventoryRef.FinalDropItem(itemId, currentValue))
				{
					ClosePopup();
					return;
				}
				inventoryRef.OnUpdateGFxButtonsList();
				
				if (currentValue == maxValue)
				{
					if (updateInfiniteBolts)
					{
						inventoryRef.PaperdollUpdateAll();
					}
					else
					{
						inventoryRef.PaperdollRemoveItem(itemId);
					}
					inventoryRef.InventoryRemoveItem(itemId);
				}
				else
				{
					inventoryRef.InventoryUpdateItem(itemId);
				}
				
				break;
			case QTF_Dismantle:
				if (blacksmithRef)
				{
					blacksmithRef.OnDisassembleStack(itemId, (int)(itemCost) * currentValue, currentValue);
				}
				break;
			default:
				break;
		}
		
		inventoryRef.UpdateAllItemData();
		
		ClosePopup();
	}
}
