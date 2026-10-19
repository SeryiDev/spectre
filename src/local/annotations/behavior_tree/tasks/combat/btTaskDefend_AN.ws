@wrapMethod( CBTTaskDefend ) function OnActivate() : EBTNodeStatus
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
		
	npc.SetGuarded(true);
	npc.SetParryEnabled( true );
	if ( useCustomHits )
	{
		npc.customHits = true;
		npc.SetCanPlayHitAnim( true );
	}
	
	m_activationTime = GetLocalTime();
	
	return BTNS_Active;
}

@wrapMethod( CBTTaskDefend ) function OnDeactivate()
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
		
	npc.SetGuarded(false);
	npc.SetParryEnabled( false );
	if ( useCustomHits )
	{
		npc.customHits = false;
	}
	npc.SetIsInHitAnim(false);
	npc.DisableHitAnimFor(2.0);
}

@wrapMethod( CBTTaskDefend ) function OnGameplayEvent( eventName : name ) : bool
{
	var npc 					: CNewNPC = GetNPC();
	var data 					: CDamageData;
	var l_currentDuration		: float;
	
	if(false) 
	{
		wrappedMethod(eventName);
	}
		
	if ( eventName == 'BeingHit' )
	{
		data = (CDamageData) GetEventParamBaseDamage();
		
		if( (CBaseGameplayEffect) data.causer )
			return true;
		
		if( playParrySound )			
			npc.SoundEvent( "cmb_play_parry" );

		if ( data.customHitReactionRequested )
		{
			npc.RaiseEvent('CustomHit');
			SetHitReactionDirection();
		}

		Complete(true);
		return true;
	}
	else if ( listenToParryEvents && ( eventName == 'ParryPerform' || eventName == 'ParryStagger' ) && npc.CanPlayHitAnim() )
	{
		npc.RaiseEvent('CustomHit');
		SetHitReactionDirection();
		return true;
	}
	else if ( eventName == 'IsDefending' )
	{
		SetEventRetvalInt(1);
		
		l_currentDuration = GetLocalTime() - m_activationTime;
		
		if ( completeTaskOnIsDefending && l_currentDuration > minimumDuration )
			Complete(true);
		return true;
	}
	
	else if ( eventName == 'DamageTaken' )
	{
		data = (CDamageData) GetEventParamBaseDamage();
		
		if( !data.isDoTDamage && playParrySound )			
			npc.SoundEvent( "cmb_play_parry" );
	}
	
	
	return false;
}

