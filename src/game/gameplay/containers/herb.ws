/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/





class W3Herb extends W3RefillableContainer 
{
	protected optional autobind foliageComponent : CSwitchableFoliageComponent = single;
	protected var isEmptyAppearance : bool;
	
	
	function  GetStaticMapPinTag( out tag : name )
	{
		var items : array< SItemUniqueId >;
		
		tag = '';
		
		
		
		
		
		
		
		if ( foliageComponent )
		{
			if ( foliageComponent.GetEntry() == 'empty' )
			{
				return;
			}
		}
		else if ( isEmptyAppearance )
		{
			return;
		}
		if ( IsEmpty() )
		{
			return;
		}
		if ( !inv )
		{
			return;
		}
		if ( inv.GetItemCount() == 0 )
		{
			return;
		}
		inv.GetAllItems( items );
		tag = inv.GetItemName( items[ 0 ] );
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnStreamIn();
		
		if( inv.IsEmpty() )
		{
			AddTimer( 'Refill', 20, true );
		}
	
		if(lootInteractionComponent)
			lootInteractionComponent.SetEnabled( !inv || !inv.IsEmpty() ) ;
			
		if ( foliageComponent )
		{
			if ( inv.IsEmpty() )
			{
				foliageComponent.SetAndSaveEntry( 'empty' );
			}
			else
			{
				foliageComponent.SetAndSaveEntry( 'full' );
			}
		}
	}	

	function ApplyAppearance( appearanceName : string )
	{
		if ( appearanceName == "2_empty" )
		{
			isEmptyAppearance = true;
		}
		else
		{
			isEmptyAppearance = false;
		}
		super.ApplyAppearance( appearanceName );
	}
	
	protected function PreRefillContainer()
	{
		inv.ResetContainerData();
	}
	event OnInteractionActivated(interactionComponentName : string, activator : CEntity){var herbs	: array<SItemUniqueId>;var herb	: SItemUniqueId;var yield	: int;var count	: int;if (spectreAlchemy501()) return super.OnInteractionActivated(interactionComponentName, activator);/*modSpectre: alchemy 5.01 variant, 5.01 yield*/if (adjusted_yield || activator != thePlayer || inv.IsEmpty() )return (false);inv.GetAllItems(herbs);	if (herbs.Size() > 1 || HasQuestItem() || focusModeHighlight == FMV_Clue){super.OnInteractionActivated(interactionComponentName, activator);return (false);	}herb = herbs[0];count = inv.GetItemQuantity(herb);yield = theGame.alchexts.herbctrl.GetHerbYield() - count;switch ((int)(yield > 0) - (int)(yield < 0) ){case -1:	inv.RemoveItem(herb, -yield);					break ;case 1:		inv.AddAnItem(inv.GetItemName(herb), yield);	break ;default:break ;}adjusted_yield = true;}//modSpectre
}
