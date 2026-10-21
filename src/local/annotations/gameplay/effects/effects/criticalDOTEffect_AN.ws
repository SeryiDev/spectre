@wrapMethod(W3CriticalDOTEffect) function OnTimeUpdated(deltaTime : float)
{
	if(false) 
	{
		wrappedMethod(deltaTime);
	}

	if(pauseCounters.Size() == 0)
	{							
		if( duration != -1 )
			timeLeft -= deltaTime;				
		OnUpdate(deltaTime);	
		
		
		if(!this)
			return;
	}

	if(duration != -1 && timeLeft <= 0 && isActive)
	{
		isActive = false;
	}
	
}

@wrapMethod(W3CriticalDOTEffect) function OnEffectAdded(optional customParams : W3BuffCustomParams)
{
	var i : int;
	var animHandling : ECriticalHandling;
	var veh : CGameplayEntity;
	var horseComp : W3HorseComponent;
	var boatComp : CBoatComponent;
	var params : W3BuffDoTParams;
	var perk20Bonus : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(customParams);
	}
			
	
	if(IsImmuneToAllDamage(100000))		
	{
		isActive = false;
		return true;
	}
	
	params = (W3BuffDoTParams)customParams;
	
	super.OnEffectAdded(customParams);
	
	if(isOnPlayer)
	{
		for(i=0; i<blockedActions.Size(); i+=1)
		{
			thePlayer.BlockAction( blockedActions[i], EffectTypeToName( effectType ) );
		}
	}
	
	if(!isOnPlayer)
		target.PauseStaminaRegen('in_critical_state');
		
	if(target.IsCriticalTypeHigherThanAllCurrent(criticalStateType))		
	{			
		if(target.IsInAir())
		{
			animHandling = airHandling;
		}			
		else
		{
			
			if(isOnPlayer)
			{
				if( !thePlayer.CanReactToCriticalState() )
				{
					animHandling = explorationStateHandling;
				}
				
				else
				{
					veh = thePlayer.GetUsedVehicle();
					
					if((W3Boat)veh)
					{
						
						
						animHandling = attachedHandling;
					}
					
					else if(veh)
					{
						horseComp = ((CNewNPC)veh).GetHorseComponent();
						horseComp.OnCriticalEffectAdded( criticalStateType );
						animHandling = onHorseHandling;
					}	
					
					else
					{
						animHandling = ECH_HandleNow;
					}
				}
			}
			
			else
			{
				
				animHandling = ECH_HandleNow;
			}
		}
	}
	
	else
	{
		animHandling = postponeHandling;
	}
	
	
	if(animHandling == ECH_HandleNow)
	{
		target.StartCSAnim(this);
	}
	else if(animHandling == ECH_Abort)
	{
		LogCritical("Cancelling CS <<" + criticalStateType + ">> as it cannot play anim right now and its handling wishes to abort in such case");
		isActive = false;
	}
	
	
	if(isOnPlayer)
		theGame.HapticStart( "classic_vibro_large_oneshot" );	
}
