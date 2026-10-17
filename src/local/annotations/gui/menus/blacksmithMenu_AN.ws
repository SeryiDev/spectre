@wrapMethod(CR4BlacksmithMenu) function OnRemoveImprovements(item : SItemUniqueId, price : int)
{
	var socketItems	  : array<name>;
	var itemsListText : string;
	var idx, len	  : int;

	if(false) 
	{
		wrappedMethod(item, price);
	}
	
	_inv.GetItemEnhancementItems(item, socketItems);
	itemsListText = GetLocStringByKeyExt("panel_blacksmith_items_added");
	len = socketItems.Size();
	for (idx = 0; idx < len; idx+=1)
	{
		itemsListText += ("<br/> +" + GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(socketItems[idx])));
		
		_inv.AddAnItem( socketItems[idx] );
	}
	
	_fixerInventory.AddMoney(price);
	_inv.RemoveMoney(price);
	_inv.RemoveAllItemEnhancements(item);
	
	if (_inv.GetItemQuantity(item) > 1)
	{
		UpdateItem(item);
	}
	else
	{
		RemoveItem(item);
	}
	
	UpdatePlayerMoney();
	UpdateMerchantData();
	theSound.SoundEvent( 'gui_inventory_buy' );		
}

@wrapMethod(CR4BlacksmithMenu) function OnDisassembleItem( item : SItemUniqueId, price : int)
{
	var partList	  		: array <SItemParts>;
	var currentPartList 	: array <SItemParts>;
	var runesList	  		: array <name>;
	var itemsListText 		: string;
	var idx, len			: int;
	var i, x				: int;		
	var itemsCount	  		: int;
	var entryFound			: bool;
	var updateAfter			: bool;
	var craftComp			: W3CraftsmanComponent;
	var itemsAdded			: array <SItemUniqueId>;
	var itemsToUpdate		: array <SItemUniqueId>;
	var curPart				: SItemUniqueId;

	if(false) 
	{
		wrappedMethod(item, price);
	}
	
	if( m_lastConfirmedDisassembleQuantity < 1 )
	{
		OnPlaySoundEvent( "gui_global_denied" );
		return 0;
	}
	
	itemsListText = "<font color =\"#404040\">" + GetLocStringByKeyExt( "panel_blacksmith_items_removed" ) + ": </font>";
	itemsListText += "<br/>" + ( GetLocStringByKeyExt( _inv.GetItemLocalizedNameByUniqueID( item ) ) + " x" + m_lastConfirmedDisassembleQuantity );
	
	if ( m_standaloneMode )
	{
		
		
		
		if( _inv.GetItemQuantity( item ) == m_lastConfirmedDisassembleQuantity)
		{
			RemoveItem( item );
			updateAfter = false;
		}
		else
		{
			updateAfter = true;
		}
		
		_standaloneDismantleInv.DoDismantling( item, m_lastConfirmedDisassembleQuantity, itemsAdded );
		
		if( updateAfter )
		{
			UpdateItem( item );
		}
		
		if( itemsAdded.Size() )
		{
			itemsListText += "<br/>" + "<font color =\"#404040\">" + GetLocStringByKeyExt( "panel_blacksmith_items_added" ) + ": </font>";
			itemsListText += "<br/>" + GetLocStringByKeyExt( _inv.GetItemLocalizedNameByName( _inv.GetItemName( itemsAdded[0] ) ) ) + " x" + m_lastConfirmedDisassembleQuantity;
			showNotification( itemsListText );
		}
	}
	else
	{
		
		
		partList = _inv.GetItemRecyclingParts(item);
		
		len = partList.Size();
		for (idx = 0; idx < len; idx+=1)
		{
			partList[idx].quantity = _inv.GetItemQuantityByName(partList[idx].itemName);
		}
		
		itemsListText += "<br/>" + "<font color =\"#404040\">" + GetLocStringByKeyExt("panel_blacksmith_items_added") + ": </font>";
		
		GetWitcherPlayer().StartInvUpdateTransaction();
		
		_fixerInventory.AddMoney(price * m_lastConfirmedDisassembleQuantity);
		_inv.RemoveMoney(price * m_lastConfirmedDisassembleQuantity);
		if ( _inv.GetItemEnhancementCount(item) > 0 )
		{
			_inv.GetItemEnhancementItems(item, runesList);
			for (idx = 0; idx <  runesList.Size(); idx+=1)
			{
				_inv.AddAnItem( runesList[idx] );
				itemsListText += "<br/>" + (GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(runesList[idx])) + " x1");
			}		
		}
		
		craftComp = (W3CraftsmanComponent)_fixerNpc.GetComponentByClassName( 'W3CraftsmanComponent' );
		
		for (i = 0; i < m_lastConfirmedDisassembleQuantity; i += 1)
		{
			if ( craftComp )
			{
				if ( craftComp.IsCraftsmanType( ECT_Smith ) )
				{
					itemsAdded = _inv.RecycleItem(item, craftComp.GetCraftsmanLevel( ECT_Smith ) );
				}
				else if ( craftComp.IsCraftsmanType( ECT_Armorer ) )
				{
					itemsAdded = _inv.RecycleItem(item, craftComp.GetCraftsmanLevel( ECT_Armorer ) );
				}
				else
				{
					itemsAdded = _inv.RecycleItem( item, ECL_Journeyman );
				}
			}
			else
			{
				itemsAdded = _inv.RecycleItem( item, ECL_Journeyman );
			}
		}
		
		for (idx = 0; idx < len; idx+=1)
		{
			itemsCount = _inv.GetItemQuantityByName(partList[idx].itemName) - partList[idx].quantity;
			itemsListText += "<br/>" + GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(partList[idx].itemName)) + " x" + itemsCount;
		}
		
		
		showNotification(itemsListText);
		
		if (_inv.GetItemQuantity(item) > 0)
		{
			itemsToUpdate.PushBack(item);
		}
		else
		{
			RemoveItem(item);
		}
		
		len = itemsAdded.Size();
		for (idx = 0; idx < len; idx+=1)
		{
			curPart = itemsAdded[idx];
			partList.Clear();
			partList = _inv.GetItemRecyclingParts( curPart );
			if (partList.Size() > 0)
			{
				itemsToUpdate.PushBack(curPart);
			}
		}
	}
	
	
	
	if (itemsToUpdate.Size() > 0)
	{
		UpdateItemsList(itemsToUpdate);
	}
	
	GetWitcherPlayer().FinishInvUpdateTransaction();
	
	UpdatePlayerMoney();
	UpdateMerchantData();
	UpdateItemsCounter();
	
	theSound.SoundEvent( 'gui_inventory_buy' );
}
