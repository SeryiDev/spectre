@wrapMethod(CR4EnchantingMenu) function OnEnchantItem(itemId : SItemUniqueId, enchantmentName : name)
{	
	var curIngredient       : SItemParts;
	var enchantSchematic	: SEnchantmentSchematic;
	var enchantResult   	: bool;
	var schematicFound		: bool;
	var i, price : int;
	var playerMoney : int;
	var ingredientsCount : int;
	var unEnchantmentName : name;
	var unEnchantSchematic	: SEnchantmentSchematic;

	if(false) 
	{
		wrappedMethod(itemId, enchantmentName);
	}
	
	schematicFound = m_enchantmentManager.GetSchematic( enchantmentName, enchantSchematic );
		
	if (!schematicFound)
	{
		
		OnPlaySoundEvent("gui_global_denied");
		
		return false;
	}
	
	
	price = 0; 
	playerMoney = m_playerInventory.GetMoney();
	
	if (playerMoney < price)
	{
		showNotification( GetLocStringByKeyExt( "panel_shop_notification_not_enough_money" ) );
		
		
		return false;
	}

	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 1 _Stats'))unEnchantmentName = 'Runeword 1';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 2 _Stats'))unEnchantmentName = 'Runeword 2';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 4 _Stats'))unEnchantmentName = 'Runeword 4';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 5 _Stats'))unEnchantmentName = 'Runeword 5';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 6 _Stats'))unEnchantmentName = 'Runeword 6';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 8 _Stats'))unEnchantmentName = 'Runeword 8';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 10 _Stats'))unEnchantmentName = 'Runeword 10';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 11 _Stats'))unEnchantmentName = 'Runeword 11';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 12 _Stats'))unEnchantmentName = 'Runeword 12';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 1 _Stats'))unEnchantmentName = 'Glyphword 1';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 2 _Stats'))unEnchantmentName = 'Glyphword 2';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 3 _Stats'))unEnchantmentName = 'Glyphword 3';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 4 _Stats'))unEnchantmentName = 'Glyphword 4';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 5 _Stats'))unEnchantmentName = 'Glyphword 5';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 6 _Stats'))unEnchantmentName = 'Glyphword 6';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 7 _Stats'))unEnchantmentName = 'Glyphword 7';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 10 _Stats'))unEnchantmentName = 'Glyphword 10';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 12 _Stats'))unEnchantmentName = 'Glyphword 12';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 14 _Stats'))unEnchantmentName = 'Glyphword 14';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 15 _Stats'))unEnchantmentName = 'Glyphword 15';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 17 _Stats'))unEnchantmentName = 'Glyphword 17';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 18 _Stats'))unEnchantmentName = 'Glyphword 18';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 20 _Stats'))unEnchantmentName = 'Glyphword 20';

	m_enchantmentManager.GetSchematic( unEnchantmentName, unEnchantSchematic );

	ingredientsCount = unEnchantSchematic.ingredients.Size();
	
	for (i = 0; i < ingredientsCount; i=i+1 )
	{
		curIngredient = unEnchantSchematic.ingredients[i];
		m_playerInventory.AddAnItem(curIngredient.itemName, curIngredient.quantity);
	}
	
	m_playerInventory.UnenchantItem(itemId);
	enchantResult = m_playerInventory.EnchantItem( itemId, enchantmentName, getEnchamtmentStatName(enchantmentName) );
	
	if (enchantResult)
	{
		ingredientsCount = enchantSchematic.ingredients.Size();
		
		for (i = 0; i < ingredientsCount; i=i+1 )
		{
			curIngredient = enchantSchematic.ingredients[i];
			m_playerInventory.RemoveItemByName(curIngredient.itemName, curIngredient.quantity);
		}
		
		UpdateItemsCounter();
		
		populateData();
		
		populateItemList();
		populateEnchantmentsList(itemId);
		populateIngredientsList(getEnchantmentData(enchantmentName, m_allwordsData));
		
		theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_enchanting_notification_enchant_done") + ": " + GetLocStringByKeyExt(enchantSchematic.localizedName) );
		
		
		UpdateMerchantData();
		
		m_playerInventory.NotifyEnhancedItem(itemId);
	}
	else
	{
		OnPlaySoundEvent("gui_global_denied");
	}
}

@wrapMethod(CR4EnchantingMenu) function OnRemoveEnchantment(itemId : SItemUniqueId):void
{
	var unenchantResult : bool;
	var unEnchantmentName : name;
	var unEnchantSchematic	: SEnchantmentSchematic;
	var curIngredient       : SItemParts;
	var i, ingredientsCount : int;

	if(false) 
	{
		wrappedMethod(itemId);
	}
	
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 1 _Stats'))unEnchantmentName = 'Runeword 1';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 2 _Stats'))unEnchantmentName = 'Runeword 2';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 4 _Stats'))unEnchantmentName = 'Runeword 4';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 5 _Stats'))unEnchantmentName = 'Runeword 5';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 6 _Stats'))unEnchantmentName = 'Runeword 6';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 8 _Stats'))unEnchantmentName = 'Runeword 8';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 10 _Stats'))unEnchantmentName = 'Runeword 10';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 11 _Stats'))unEnchantmentName = 'Runeword 11';
	if(m_playerInventory.ItemHasAbility(itemId, 'Runeword 12 _Stats'))unEnchantmentName = 'Runeword 12';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 1 _Stats'))unEnchantmentName = 'Glyphword 1';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 2 _Stats'))unEnchantmentName = 'Glyphword 2';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 3 _Stats'))unEnchantmentName = 'Glyphword 3';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 4 _Stats'))unEnchantmentName = 'Glyphword 4';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 5 _Stats'))unEnchantmentName = 'Glyphword 5';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 6 _Stats'))unEnchantmentName = 'Glyphword 6';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 7 _Stats'))unEnchantmentName = 'Glyphword 7';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 10 _Stats'))unEnchantmentName = 'Glyphword 10';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 12 _Stats'))unEnchantmentName = 'Glyphword 12';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 14 _Stats'))unEnchantmentName = 'Glyphword 14';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 15 _Stats'))unEnchantmentName = 'Glyphword 15';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 17 _Stats'))unEnchantmentName = 'Glyphword 17';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 18 _Stats'))unEnchantmentName = 'Glyphword 18';
	if(m_playerInventory.ItemHasAbility(itemId, 'Glyphword 20 _Stats'))unEnchantmentName = 'Glyphword 20';

	m_enchantmentManager.GetSchematic( unEnchantmentName, unEnchantSchematic );

	ingredientsCount = unEnchantSchematic.ingredients.Size();

	for (i = 0; i < ingredientsCount; i=i+1 )
	{
		curIngredient = unEnchantSchematic.ingredients[i];
		m_playerInventory.AddAnItem(curIngredient.itemName, curIngredient.quantity);
	}
	
	unenchantResult = m_playerInventory.UnenchantItem(itemId);
	if (unenchantResult)
	{
		theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("panel_enchanting_notification_enchant_removed"));
		
		UpdateMerchantData();
		UpdateItemsCounter();
		populateData();
		populateIngredientsList(getEnchantmentData(unEnchantmentName, m_allwordsData));
		populateItemList();
		populateEnchantmentsList(itemId);
		
		m_playerInventory.NotifyEnhancedItem(itemId);
	}
	else
	{
		OnPlaySoundEvent("gui_global_denied");
	}
}
