@addField(W3GuiContainerInventoryComponent)
var spectrePlayerTabIndex : int;


@addMethod(W3GuiContainerInventoryComponent) function spectreIsWeaponUpgradeItem( item : SItemUniqueId ) : bool
{
	return _inv.spectreIsItemWeaponUpgrade( item );
}

@addMethod(W3GuiContainerInventoryComponent) function spectreIsArmorUpgradeItem( item : SItemUniqueId ) : bool
{
	return _inv.spectreIsItemArmorUpgrade( item );
}

@addMethod(W3GuiContainerInventoryComponent) function spectreIsWeaponRepairItem( item : SItemUniqueId ) : bool
{
	return _inv.spectreIsItemWeaponRepairKit( item );
}

@addMethod(W3GuiContainerInventoryComponent) function spectreIsArmorRepairItem( item : SItemUniqueId ) : bool
{
	return _inv.spectreIsItemArmorRepairKit( item );
}

@wrapMethod(W3GuiContainerInventoryComponent) function ShouldShowItem( item : SItemUniqueId ) : bool
{
    if (theGame.GetDLCManager().IsDLCAvailable('dlcvhud') 
	&& theGame.GetDLCManager().IsDLCEnabled('dlcvhud') 
	)
	{
		wrappedMethod(item);

		return false;
	}

    if (dontShowEquipped)
    {
        if (isHorseItem(item))
        {
            if (GetWitcherPlayer().GetHorseManager().IsItemEquipped(item))
            {
                return false;
            }
        }
        else
        {
            if ( _inv == GetWitcherPlayer().GetInventory() && GetWitcherPlayer().IsItemEquipped(item))
            {
                return false;
            }
        }
    }
    
    if( spectrePlayerTabIndex != -1 )
    {
        if( spectreGetTabForItem( item ) != spectrePlayerTabIndex )
        {
            return false;
        }
    }
    
    return super.ShouldShowItem( item );
}

@addMethod(W3GuiContainerInventoryComponent) function spectreGetTabForItem( item : SItemUniqueId ) : int
{
    var isJunk, isTrophy : bool;
    
    isTrophy = _inv.IsItemTrophy( item );
    isJunk = ( !isItemReadable(item) && !isFoodItem(item) && !isIngredientItem( item ) && !isWeaponItem( item ) && !isArmorItem( item ) && !isAlchemyItem( item ) && !isUpgradeItem( item ) && !isItemSchematic( item ) && !isToolItem(item) && !isHorseItem( item ) && !isTrophy );
    
    if( isIngredientItem( item ) && !IsItemDye( item ) )
    {
        return 0;
    }

    if( (isQuestItem( item ) && !isTrophy) || ( ( isJunk || isItemReadable( item ) ) && !isQuickslotItem( item ) && !isTrophy ) )
    {
        return 1;
    }

    if( isFoodItem( item ) || isHorseItem( item ) || isTrophy )
    {
        return 2;
    }

    if( isAlchemyItem( item ) && !isFoodItem( item ) && !isItemUsable( item ) && !IsItemDye( item ) )
    {
        return 3;
    }

    if( isWeaponItem( item ) || isArmorItem( item ) || isUpgradeItem( item ) || isToolItem( item ) || isItemUsable( item ) || isQuickslotItem( item ) || IsItemDye( item ) )
    {
        return 4;
    }
    
    return 4;
}
