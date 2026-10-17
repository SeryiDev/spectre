class W3spectreEnhancementBuffParams extends W3BuffCustomParams
{
	var currCount : int; 
	
	var maxCount : int;
}

@wrapMethod(W3RepairObjectEnhancement) function OnTimeUpdated(dt : float)
{
	if (false)
	{
		wrappedMethod(dt);
	}

	if( target == GetWitcherPlayer() )
	{
		if( isActive && pauseCounters.Size() == 0)
		{
			timeActive += dt;	
		}

		return;
	}

	super.OnTimeUpdated(dt);

}

@addMethod( W3RepairObjectEnhancement ) protected function spectreDisplayBuff( visible : bool )
{	
	if( visible )
	{

	}
	else
	{
		GetWitcherPlayer().RemoveBuff( this.effectType );
	}	
}

@addMethod( W3RepairObjectEnhancement ) public final function spectreReapplyBuff( newMax : int )
{
	spectreRepairObjectMaxCount = newMax;
	spectreRepairObjectCurrCount = newMax;		
}

@addMethod( W3RepairObjectEnhancement ) public final function spectreReduceAmmo()
{
	if( spectreRepairObjectCurrCount == 1 )
	{
		spectreDisplayBuff( false );
	}
	
	spectreRepairObjectCurrCount = Max( 0, spectreRepairObjectCurrCount - 1 );
}

@addMethod( W3RepairObjectEnhancement ) public final function spectreGetAmmoMaxCount() : int
{
	return spectreRepairObjectMaxCount;
}

@addMethod( W3RepairObjectEnhancement ) public final function spectreGetAmmoCurrentCount() : int
{
	return spectreRepairObjectCurrCount;
}


@addField( W3RepairObjectEnhancement )
private saved var spectreRepairObjectCurrCount : int;

@addField( W3RepairObjectEnhancement )
private saved var spectreRepairObjectMaxCount : int;
