@wrapMethod( CBTTaskDodge ) function IsAvailable() : bool
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(instantActivation)
		return true;

	if ( npc.HasBuff(EET_CounterStrikeHit) || npc.IsInAir() || !npc.IsOnGround() || npc.WasCountered() )
			return false;
		
	if ( !npc.IsCurrentlyDodging() && Time2Dodge && dodgeEventTime )
	{
		if ( dodgeEventTime + 0.25f < GetLocalTime() )
		{
			Time2Dodge = false;
		}
		if ( delayDodgeHeavyAttack > 0 && dodgeEventTime > GetLocalTime() )
		{
			return false;
		}
	}
	
	return Time2Dodge && super.IsAvailable();
}

@wrapMethod( CBTTaskDodge ) function OnActivate() : EBTNodeStatus
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if ( npc.HasBuff(EET_CounterStrikeHit) || npc.IsInAir() || !npc.IsOnGround() || npc.WasCountered() )
		return BTNS_Failed;
	
	if ( swingDir != -1 )
	{
		npc.SetBehaviorVariable( 'HitSwingDirection', swingDir );
	}
	if ( swingType != -1 )
	{
		npc.SetBehaviorVariable( 'HitSwingType', swingType );
	}
	npc.SetIsCurrentlyDodging(true);
	npc.IncDefendCounter();
	if ( interruptTaskToExecuteCounter && CheckCounter() )
	{
		npc.DisableHitAnimFor(0.1);
		return BTNS_Completed;
	}
	
	
	return super.OnActivate();
}

@wrapMethod( CBTTaskDodge ) function OnDeactivate()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	swingType = -1;
	swingDir = -1;
	performDodgeDelay = 0;
	GetActor().SetIsCurrentlyDodging(false);
	super.OnDeactivate();
}

@wrapMethod( CBTTaskDodge ) function Dodge() : bool
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}

	if ( npc.HasBuff(EET_CounterStrikeHit) || npc.IsInAir() || !npc.IsOnGround() || npc.WasCountered() )
		return false;
	
	if ( dodgeEventTime + 0.25f < GetLocalTime() )
	{
		return false;
	}

	
	if ( !CheckDistance() )
	{
		return false;
	}
	
	InitializeCombatDataStorage();
	
	if( !ChooseAndCheckDodge() )
	{
		return false;
	}
	
	if( !CheckNavMesh() )
	{
		return false;
	}
	
	return true;
}

@addField(CBTTaskDodge)
private var counterStaminaCost : float;

@wrapMethod( CBTTaskDodge ) function GetDodgeStats()
{
	var npc : CNewNPC = GetNPC();
	var multiplier : float;
	
	if(false) 
	{
		wrappedMethod();
	}

	if( FactsQuerySum("NewGamePlus") > 0 )
		multiplier = 1.15;
	else
		multiplier = 1.0;
	
	
	dodgeChanceAttackLight	= (int)(ClampF(multiplier*100*CalculateAttributeValue(npc.GetAttributeValue('dodge_melee_light_chance')),0,100));	
	dodgeChanceAttackHeavy	= (int)(ClampF(multiplier*100*CalculateAttributeValue(npc.GetAttributeValue('dodge_melee_heavy_chance')),0,100));	
	dodgeChanceAard			= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_magic_chance')));
	dodgeChanceIgni			= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_magic_chance')));
	dodgeChanceBomb			= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_bomb_chance')));
	dodgeChanceProjectile	= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_projectile_chance')));
	dodgeChanceFear			= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dodge_fear_chance')));
	counterChance 			= MaxF(0, ClampF(multiplier*100*CalculateAttributeValue(npc.GetAttributeValue('counter_chance')),0,100));			
	hitsToCounter 			= (int)MaxF(0, CalculateAttributeValue(npc.GetAttributeValue('hits_to_roll_counter')));
	counterMultiplier 		= (int)MaxF(0, 100*CalculateAttributeValue(npc.GetAttributeValue('counter_chance_per_hit')));
	counterChance 			+= Max( 0, npc.GetDefendCounter() ) * counterMultiplier;
	counterStaminaCost		= CalculateAttributeValue(npc.GetAttributeValue( 'counter_stamina_cost' ));																								
	
	if ( hitsToCounter < 0 )
	{
		hitsToCounter = 65536;
	}
}

@wrapMethod( CBTTaskDodge ) function ChooseAndCheckDodge() : bool
{
	var npc 							: CNewNPC = GetNPC();
	var dodgeChance 					: int;
	
	if(false) 
	{
		wrappedMethod();
	}

	if ( npc.HasBuff(EET_CounterStrikeHit) || npc.IsInAir() || !npc.IsOnGround() || npc.WasCountered() )
		return false;																							  
	
	switch (dodgeType)
	{
		case EDT_Attack_Light 	: dodgeChance = dodgeChanceAttackLight; 	break;
		case EDT_Attack_Heavy	: dodgeChance = dodgeChanceAttackHeavy; 	break;
		case EDT_Aard			: dodgeChance = dodgeChanceAard; 			break;
		case EDT_Igni			: dodgeChance = dodgeChanceIgni; 			break;
		case EDT_Bomb			: dodgeChance = dodgeChanceBomb; 			break;
		case EDT_Projectile		: dodgeChance = dodgeChanceProjectile; 		break;
		case EDT_Fear			: dodgeChance = dodgeChanceFear; 			break;
		default : return false;
	}
	
	if ( ( RandRange(100) < dodgeChance ) || ignoreDodgeChanceStats )
	{
		if (dodgeType == EDT_Attack_Light || dodgeType == EDT_Attack_Heavy || dodgeType == EDT_Fear)
		{
			dodgeDirection = EDD_Back;
		}
		else if ( dodgeType == EDT_Projectile || dodgeType == EDT_Bomb )
		{
			dodgeDirection = EDD_Back;
		}
		
		npc.SetBehaviorVariable( 'DodgeDirection',(int)dodgeDirection );
		return true;
	}
	
	return false;
}

@wrapMethod( CBTTaskDodge ) function OnListenedGameplayEvent( eventName : name ) : bool
{
	var npc 							: CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod(eventName);
	}

	if ( npc.HasBuff(EET_CounterStrikeHit) || npc.IsInAir() || !npc.IsOnGround() || npc.WasCountered() )
		return false;		
	if ( eventName == 'swingType' )
	{
		swingType = this.GetEventParamInt(-1);
	}
	if ( eventName == 'swingDir' )
	{
		swingDir = this.GetEventParamInt(-1);
	}
	
	if ( eventName == 'Time2DodgeProjectile' )
	{
		dodgeType = EDT_Projectile;
		ownerPosition = npc.GetWorldPosition();
		performDodgeDelay = this.GetEventParamFloat(-1);
		performDodgeDelay = ClampF( (performDodgeDelay -0.4), 0, 99 );
		npc.AddTimer( 'DelayDodgeProjectileEventTimer', performDodgeDelay );
		return true;
	}
	else if ( eventName == 'Time2DodgeBomb' )
	{
		dodgeType = EDT_Bomb;
		ownerPosition = npc.GetWorldPosition();
		performDodgeDelay = this.GetEventParamFloat(-1);
		performDodgeDelay = ClampF( (performDodgeDelay -0.4), 0, 99 );
		npc.AddTimer( 'DelayDodgeBombEventTimer', performDodgeDelay );
		return true;
	}
	else if ( ( eventName == 'Time2DodgeFast' && earlyDodgeActivation ) || eventName == 'Time2Dodge' || eventName == 'Time2DodgeProjectileDelayed' || eventName == 'Time2DodgeBombDelayed' )
	{
		GetDodgeStats();
		if ( interruptTaskToExecuteCounter && CheckCounter() && !npc.IsCountering() )
		{
			npc.DisableHitAnimFor(0.1);
			Complete(true);
			return false;
		}
		
		if ( eventName != 'Time2DodgeProjectileDelayed' && eventName != 'Time2DodgeBombDelayed')
		{
			dodgeType = this.GetEventParamInt(-1);
		}
		
		if ( delayDodgeHeavyAttack > 0 && dodgeType == EDT_Attack_Heavy )
		{
			dodgeEventTime = GetLocalTime() + delayDodgeHeavyAttack;
		}
		else
		{
			dodgeEventTime = GetLocalTime();
		}
		
		if ( Dodge() )
		{
			Time2Dodge = true;
			if ( npc.IsInHitAnim() && signalGameplayEventWhileInHitAnim )
				npc.SignalGameplayEvent('WantsToPerformDodge');
			else if ( dodgeType == EDT_Attack_Heavy )
				npc.SignalGameplayEvent('WantsToPerformDodgeAgainstHeavyAttack');
		}
		
		return true;
	}		
	
	return false;
}

@wrapMethod( CBTTaskCircularDodge ) function ChooseAndCheckDodge() : bool
{
	var npc : CNewNPC = GetNPC();
	var target : CActor = npc.GetTarget();
	var dodgeChance : int;
	
	if(false) 
	{
		wrappedMethod();
	}

	if ( npc.HasBuff(EET_CounterStrikeHit) || npc.IsInAir() || !npc.IsOnGround() || npc.WasCountered() )
		return false;																							  
	
	switch (dodgeType)
	{
		case EDT_Attack_Light	: dodgeChance = dodgeChanceAttackLight; break;
		case EDT_Attack_Heavy	: dodgeChance = dodgeChanceAttackHeavy; break;
		case EDT_Aard			: dodgeChance = dodgeChanceAard; break;
		case EDT_Igni			: dodgeChance = dodgeChanceIgni; break;
		case EDT_Bomb			: dodgeChance = dodgeChanceBomb; break;
		case EDT_Projectile		: dodgeChance = dodgeChanceProjectile; break;
		case EDT_Fear			: dodgeChance = dodgeChanceFear; break;
		default : return false;
	}
	
	npc.slideTarget = target;
	
	
	if (RandRange(100) < dodgeChance || ignoreDodgeChanceStats)
	{
		if (dodgeType == EDT_Attack_Light || dodgeType == EDT_Attack_Heavy || dodgeType == EDT_Fear)
		{
			dodgeDirection = EDD_Back;
		}
		else if ( RandRange(100) < 50 )
		{
			RotateToAngle( -angle );
			dodgeDirection = EDD_Left;
		}
		else
		{
			RotateToAngle( angle );
			dodgeDirection = EDD_Right;
		}
		npc.SetBehaviorVariable( 'DodgeDirection',(int)dodgeDirection);
		return true;
	}
	
	return false;
}
