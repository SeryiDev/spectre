@wrapMethod(W3Effect_Shrine) function OnEffectAdded(optional customParams : W3BuffCustomParams)
{
	var shrineParams : W3ShrineEffectParams;
	var retEvent : bool;

	if (false)
	{
		wrappedMethod(customParams);
	}

	shrineParams = (W3ShrineEffectParams)customParams;

	if(shrineParams)
	{			
		isFromMutagen23 = shrineParams.isFromMutagen23;
		spectreShrineCurrCount = shrineParams.spectreShrineEffectCurrCount;
		spectreShrineMaxCount = shrineParams.spectreShrineEffectMaxCount;
	}

	super.OnEffectAdded(customParams);


}

@wrapMethod(W3Effect_Shrine) function OnTimeUpdated(dt : float)
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


@addMethod( W3Effect_Shrine ) protected function spectreDisplayBuff( visible : bool )
{	
	if( visible )
	{

	}
	else
	{
		GetWitcherPlayer().RemoveBuff( this.effectType );
	}	
}

@addMethod( W3Effect_Shrine ) public final function spectreReapplyBuff( newMax : int )
{
	spectreShrineMaxCount = newMax;
	spectreShrineCurrCount = newMax;		
}

@addMethod( W3Effect_Shrine ) public final function spectreReduceAmmo()
{
	if( spectreShrineCurrCount == 1 )
	{
		spectreDisplayBuff( false );
	}
	
	spectreShrineCurrCount = Max( 0, spectreShrineCurrCount - 1 );
}

@addMethod( W3Effect_Shrine ) public final function spectreGetAmmoMaxCount() : int
{
	return spectreShrineMaxCount;
}

@addMethod( W3Effect_Shrine ) public final function spectreGetAmmoCurrentCount() : int
{
	return spectreShrineCurrCount;
}


@addField( W3Effect_Shrine )
public saved var spectreShrineCurrCount : int;

@addField( W3Effect_Shrine )
public saved var spectreShrineMaxCount : int;

@addField( W3ShrineEffectParams )
public saved var spectreShrineEffectCurrCount : int;

@addField( W3ShrineEffectParams )
public saved var spectreShrineEffectMaxCount : int;
