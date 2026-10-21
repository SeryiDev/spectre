/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SYrdenEffects
{
	editable var castEffect		: name;
	editable var placeEffect	: name;
	editable var shootEffect	: name;
	editable var activateEffect : name;
}

struct SYrdenEffectSettings
{
	editable var effectEntityTemplate : CEntityTemplate;
	editable var rangeModifier : float;
	editable var count : int;
	editable var calculateCountFromSpacing : bool;
	editable var desiredSpacing : float;
	editable var randomLocationDeviation : float;
	editable var randomAngleDeviation : float;

	default rangeModifier = 1;
	default count = 8;
	default desiredSpacing = 0.5;
}

statemachine class W3YrdenEntity extends W3SignEntity
{
	editable var effects		: array< SYrdenEffects >;
	editable var projTemplate	: CEntityTemplate;
	editable var projDestroyFxEntTemplate : CEntityTemplate;
	editable var runeTemplates	: array< CEntityTemplate >;
	editable var radialEffects : array<SYrdenEffectSettings>;
	editable var centerRuneTemplate	: CEntityTemplate;

	public var validTargetsInArea, allActorsInArea : array< CActor >; 
	protected var flyersInArea	: array< CNewNPC >;
	
	protected var trapDuration	: float;
	protected var charges		: int;
	protected var isPlayerInside : bool;
	protected var baseModeRange : float;
	
	public var notFromPlayerCast : bool;
	public var fxEntities : array< CEntity >;
	
	public var wasSignSupercharged : bool; 
	
	default skillEnum = S_Magic_3;

	public function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{
		notFromPlayerCast = notPlayerCast;
		
		return super.Init(inOwner, prevInstance, skipCastingAnimation, notPlayerCast);
	}
		
	public function GetSignType() : ESignType
	{
		return ST_Yrden;
	}
		
	public function GetIsPlayerInside() : bool
	{
		return isPlayerInside;
	}
	
	public function SkillUnequipped(skill : ESkill)
	{
		var i : int;
	
		super.SkillUnequipped(skill);
		
		if(skill == S_Magic_s11)
		{
			for(i=0; i<validTargetsInArea.Size(); i+=1)
				validTargetsInArea[i].RemoveBuff( EET_YrdenHealthDrain );
		}
	}
	
	public function IsValidTarget( target : CActor ) : bool
	{
		return target && target.GetHealth() > 0.f && target.GetAttitude( owner.GetActor() ) == AIA_Hostile;
	}
	
	public function SkillEquipped(skill : ESkill)
	{
		var i : int;
		var params : SCustomEffectParams;
	
		super.SkillEquipped(skill);
	
		if(skill == S_Magic_s11)
		{
			params.effectType = EET_YrdenHealthDrain;
			params.creator = owner.GetActor();
			params.sourceName = "yrden_mode0";
			params.isSignEffect = true;
			
			for(i=0; i<validTargetsInArea.Size(); i+=1)
				validTargetsInArea[i].AddEffectCustom(params);
		}
	}

	event OnProcessSignEvent( eventName : name )
	{
		if ( eventName == 'yrden_draw_ready' )
		{
			PlayEffect( 'yrden_cast' );
		}
		else
		{
			return super.OnProcessSignEvent(eventName);
		}
		
		return true;
	}
	
	public final function ClearActorsInArea()
	{
		var i : int;
		
		for(i=0; i<validTargetsInArea.Size(); i+=1)
			validTargetsInArea[i].SignalGameplayEventParamObject('LeavesYrden', this );
		
		validTargetsInArea.Clear();
		flyersInArea.Clear();
		allActorsInArea.Clear();
	}
	
	protected function GetSignStats()
	{
		var chargesAtt, trapDurationAtt, fortifiedSignsAtt : SAbilityAttributeValue;
		var player : CR4Player;
		var rangeAttr : SAbilityAttributeValue;
		var rangeMult : float;
	
		super.GetSignStats();
		
		wasSignSupercharged = GetWitcherPlayer().IsSuperchargedSign();	
		
		chargesAtt = owner.GetSkillAttributeValue(skillEnum, 'charge_count', false, true);
		trapDurationAtt = owner.GetSkillAttributeValue(skillEnum, 'trap_duration', false, true);
		baseModeRange = CalculateAttributeValue( owner.GetSkillAttributeValue(skillEnum, 'range', false, true) );
		
		
		if ( thePlayer.CanUseSkill( S_Magic_s42 ) )
		{
			rangeAttr = thePlayer.GetSkillAttributeValue( S_Magic_s42, 'range', false, true );
			rangeMult = 1 + ( rangeAttr.valueMultiplicative * thePlayer.GetSkillLevel( S_Magic_s42 ) );
			baseModeRange *= rangeMult;
		}

		trapDurationAtt += owner.GetActor().GetTotalSignSpellPower(skillEnum);
		trapDurationAtt.valueMultiplicative -= 1;	
		
		charges = (int)CalculateAttributeValue(chargesAtt);
		trapDuration = CalculateAttributeValue(trapDurationAtt);
		
		
		player = (CR4Player)owner.GetActor();
		if(player.CanUseSkill(S_Magic_s36))
		{
			fortifiedSignsAtt = player.GetSkillAttributeValue(S_Magic_s36, 'duration', false, true);
			trapDuration *= 1 + fortifiedSignsAtt.valueMultiplicative * player.GetSkillLevel(S_Magic_s36);
		}

	}
	
	event OnStarted()
	{
		var player : CR4Player;
		
		Attach(true, true);
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
		
			
			
		
		if ( owner.ChangeAspect( this, S_Magic_s03 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'YrdenChanneled' );
		}
		else
		{
			GotoState( 'YrdenCast' );
		}
	}
	
	
	protected latent function Place(trapPos : Vector)
	{
		var trapPosTest, trapPosResult, collisionNormal, scale : Vector;
		var rot : EulerAngles;
		var witcher : W3PlayerWitcher;
		var trigger : CComponent;
		var min, max : SAbilityAttributeValue;
		var rangeAttr : SAbilityAttributeValue;
		var rangeMult : float;
		
		witcher = GetWitcherPlayer();
		witcher.yrdenEntities.PushBack(this);
		
		DisablePreviousYrdens();
		
		if( GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
			
			trigger = GetComponent( "Slowdown" );
			scale = trigger.GetLocalScale() * min.valueAdditive;			
			
			trigger.SetScale( scale );
		}

		
		if ( thePlayer.CanUseSkill( S_Magic_s42 ) )
		{
			rangeAttr = thePlayer.GetSkillAttributeValue( S_Magic_s42, 'range', false, true );
			rangeMult = 1 + ( rangeAttr.valueMultiplicative * thePlayer.GetSkillLevel( S_Magic_s42 ) );
			
			trigger = GetComponent( "Slowdown" );
			scale = trigger.GetLocalScale() * rangeMult;			
			
			trigger.SetScale( scale );
		}
		
		
		Detach();
		
		
		SleepOneFrame();
		
		
		trapPosTest = trapPos;
		trapPosTest.Z -= 0.5;		
		rot = GetWorldRotation();
		rot.Pitch = 0;
		rot.Roll = 0;
		
		if(theGame.GetWorld().StaticTrace(trapPos, trapPosTest, trapPosResult, collisionNormal))
		{
			trapPosResult.Z += 0.1;	
			TeleportWithRotation ( trapPosResult, rot );
		}
		else
		{
			TeleportWithRotation ( trapPos, rot );
		}
		
		
		SleepOneFrame();
		
		AddTimer('TimedCanceled', trapDuration, , , , true);
		
		if(!notFromPlayerCast)
			owner.GetActor().OnSignCastPerformed(ST_Yrden, fireMode);
	}
	
	private final function DisablePreviousYrdens()
	{
		var maxCount, i, size, currCount : int;
		var isAlternate : bool;
		var witcher : W3PlayerWitcher;
		
		
		isAlternate = IsAlternateCast();
		witcher = GetWitcherPlayer();
		size = witcher.yrdenEntities.Size();
		
		
		maxCount = 1;
		currCount = 0;
		
		if(!isAlternate && owner.CanUseSkill(S_Magic_s10) && owner.GetSkillLevel(S_Magic_s10) >= 5)
		{
			maxCount += 1;
		}
		else if (!isAlternate && owner.CanUseSkill(S_Magic_s42))
		{
			maxCount += owner.GetSkillLevel(S_Magic_s42);
		}
		
		for(i=size-1; i>=0; i-=1)
		{
			
			if(!witcher.yrdenEntities[i])
			{
				witcher.yrdenEntities.Erase(i);		
				continue;
			}
			
			if(witcher.yrdenEntities[i].IsAlternateCast() == isAlternate)
			{
				currCount += 1;
				
				
				if(currCount > maxCount)
				{
					witcher.yrdenEntities[i].OnSignAborted(true);
				}
			}
		}
	}
	
	timer function TimedCanceled( delta : float , id : int)
	{
		var i : int;
		var areas : array<CComponent>;
		
		isPlayerInside = false;
		
		super.CleanUp();
		StopAllEffects();
		
		
		areas = GetComponentsByClassName('CTriggerAreaComponent');
		for(i=0; i<areas.Size(); i+=1)
			areas[i].SetEnabled(false);
		
		for(i=0; i<validTargetsInArea.Size(); i+=1)
		{
			validTargetsInArea[i].BlockAbility('Flying', false);
		}
		
		for( i=0; i<fxEntities.Size(); i+=1 )
		{
			fxEntities[i].StopAllEffects();
			fxEntities[i].DestroyAfter( 5.f );
		}
		
		UpdateGryphonSetBonusYrdenBuff();
		ClearActorsInArea();
		DestroyAfter(3);
	}
	
	
	protected function NotifyGameplayEntitiesInArea( componentName : CName )
	{
		var entities : array<CGameplayEntity>;
		var triggerAreaComp : CTriggerAreaComponent;
		var i : int;
		var ownerActor : CActor;
		
		ownerActor = owner.GetActor();
		triggerAreaComp = (CTriggerAreaComponent)this.GetComponent( componentName );
		triggerAreaComp.GetGameplayEntitiesInArea( entities, 6.0 );
		
		for ( i=0 ; i < entities.Size() ; i+=1 )
		{
			if( !((CActor)entities[i]) )
				entities[i].OnYrdenHit( ownerActor );
		}
	}
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, selected : bool )
	{
	}
	
	protected function UpdateGryphonSetBonusYrdenBuff()
	{
		var player : W3PlayerWitcher;
		var i : int;
		var isPlayerInYrden, hasBuff : bool;
		
		player = GetWitcherPlayer();
		hasBuff = player.HasBuff( EET_GryphonSetBonusYrden );
		
		if ( player.IsSetBonusActive( EISB_Gryphon_2 ) ) 
		{
			isPlayerInYrden = false;
			
			for( i=0 ; i < player.yrdenEntities.Size() ; i+=1 )
			{
				if( !player.yrdenEntities[i].IsAlternateCast() && player.yrdenEntities[i].isPlayerInside )
				{
					isPlayerInYrden = true;
					break;
				}
			}
			
			if( isPlayerInYrden && !hasBuff )
			{
				player.AddEffectDefault( EET_GryphonSetBonusYrden, NULL, "GryphonSetBonusYrden" );
			}
			else if( !isPlayerInYrden && hasBuff )
			{
				player.RemoveBuff( EET_GryphonSetBonusYrden, false, "GryphonSetBonusYrden" );
			}
		}
		else if( hasBuff )
		{
			player.RemoveBuff( EET_GryphonSetBonusYrden, false, "GryphonSetBonusYrden" );
		}
	}
}

state YrdenCast in W3YrdenEntity extends NormalCast
{
	event OnThrowing()
	{
		//modSpectre
	
	if( super.OnThrowing() )
	{
		if(!parent.notFromPlayerCast)
		{
			if( caster.GetPlayer() )
			{
				if(!GetWitcherPlayer().CanUseSkill( S_Perk_14 ))
				{
					GetWitcherPlayer().spectreReduceSignBuffAmmo(GetWitcherPlayer().GetEquippedSign());
				}

				parent.ManagePlayerStamina();
				parent.ManageGryphonSetBonusBuff();
				thePlayer.AddEffectDefault(EET_YrdenCooldown, NULL, "normal_cast");
				if(thePlayer.HasBuff(EET_Mutagen10))
					((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
				if(thePlayer.HasBuff(EET_Mutagen17))
					((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
				if(thePlayer.HasBuff(EET_Mutagen22))
					((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
			}
			else
			{
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
		}
		
		parent.CleanUp();	
		parent.StopEffect( 'yrden_cast' );			
		parent.GotoState( 'YrdenSlowdown' );

		thePlayer.ResumeStaminaRegen( 'SignCast' );
	}
}
}

state YrdenChanneled in W3YrdenEntity extends Channeling
{
	event OnEnterState( prevStateName : name )
	{
		//modSpectre
	var actor : CActor;
	var player : CR4Player;
	var stamina : float;
	
	
	super.OnEnterState( prevStateName );
	
	caster.OnDelayOrientationChange();

	actor = caster.GetActor();
	player = (CR4Player)actor;
		
	if(player)
	{
		if( parent.cachedCost <= 0.0f )
		{
			parent.cachedCost = player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0 );
		}
		stamina = player.GetStat(BCS_Stamina);
	}
		
	if( player && player.CanUseSkill(S_Perk_09) && player.GetStat(BCS_Focus) >= 1 )
	{
		if( parent.cachedCost > 0 )
		{
			player.DrainFocus( 1 * parent.foaMult );
		}
		parent.SetUsedFocus( true );
	}
	else
	{
		actor.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		actor.StartStaminaRegen();
		actor.PauseStaminaRegen( 'SignCast' );
		parent.SetUsedFocus( false );
		if(parent.usedFoA)
			player.DrainFocus( 1 * parent.foaMult );
	}
	
	ChannelYrden();
}
	
	event OnThrowing()
	{
		//modSpectre

	if(!GetWitcherPlayer().CanUseSkill( S_Perk_14 ))
	{
		GetWitcherPlayer().spectreReduceSignBuffAmmo(GetWitcherPlayer().GetEquippedSign());
	}
	
	parent.CleanUp();	

	parent.StopEffect( 'yrden_cast' );

	caster.GetActor().ResumeStaminaRegen( 'SignCast' );
	
	parent.GotoState( 'YrdenShock' );
}
	
	event OnEnded(optional isEnd : bool)
	{
	}
	
	event OnSignAborted( optional force : bool )
	{
		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
		
		parent.AddTimer('TimedCanceled', 0, , , , true);
		
		super.OnSignAborted( force );
	}		
	
	entry function ChannelYrden()
	{
		//modSpectre

	while( Update() )
	{
		Sleep(theTimer.timeDelta);
	}

	OnSignAborted();
}
}


state YrdenShock in W3YrdenEntity extends Active
{
	private var usedShockAreaName : name;
	
	event OnEnterState( prevStateName : name )
	{
		//modSpectre
	var skillLevel : int;

	
	super.OnEnterState( prevStateName );

	if(caster.IsPlayer())
	{
		thePlayer.AddEffectDefault(EET_YrdenCooldown, NULL, "alt_cast");
		if(thePlayer.HasBuff(EET_Mutagen10))
			((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
		if(thePlayer.HasBuff(EET_Mutagen17))
			((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
		if(thePlayer.HasBuff(EET_Mutagen22))
			((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
	}
	
	skillLevel = parent.turretLevel;
	
	if(skillLevel == 1)
		usedShockAreaName = 'Shock_lvl_1';
	else if(skillLevel == 2)
		usedShockAreaName = 'Shock_lvl_2';
	else if(skillLevel >= 3)
		usedShockAreaName = 'Shock_lvl_3';
		
	parent.GetComponent(usedShockAreaName).SetEnabled( true );
	
	ActivateShock();

	thePlayer.ResumeStaminaRegen( 'SignCast' );
}
	
	event OnLeaveState( nextStateName : name )
	{
		parent.GetComponent(usedShockAreaName).SetEnabled( false );
		parent.ClearActorsInArea();
	}
	
	entry function ActivateShock()
	{
		var i, size : int;
		var target : CActor;
		var hitEntity : CEntity;
		var shot, validTargetsUpdated : bool;
			
		parent.Place(parent.GetWorldPosition());
		
		parent.PlayEffect( parent.effects[parent.fireMode].placeEffect );
		parent.PlayEffect( parent.effects[parent.fireMode].castEffect );
		
		
		Sleep(1.f);
		
		while( parent.charges > 0 )
		{
			hitEntity = NULL;
			shot = false;
			size = parent.validTargetsInArea.Size();
			if ( size > 0 )
			{
				do
				{
					target = parent.validTargetsInArea[RandRange(size)];
					if(target.GetHealth() <= 0.f || target.IsInAgony() )
					{
						parent.validTargetsInArea.Remove(target);
						size -= 1;
						target = NULL;
					}
				}while(size > 0 && !target)
				
				if(target && target.GetGameplayVisibility())
				{
					shot = true;
					hitEntity = ShootTarget(target, true, 0.2f, false);
				}
			}
			
			if(hitEntity)
			{
				Sleep(2.f);		
			}
			else if(shot)
			{
				Sleep(0.1f);	
			}
			else
			{
				validTargetsUpdated = false;
				
				
				if( parent.validTargetsInArea.Size() == 0 )
				{				
					for( i=0; i<parent.allActorsInArea.Size(); i+=1 )
					{
						if( parent.IsValidTarget( parent.allActorsInArea[i] ) )
						{
							parent.validTargetsInArea.PushBack( parent.allActorsInArea[i] );
							validTargetsUpdated = true;
						}
					}
				}
				
				
				if( !validTargetsUpdated )
				{
					Sleep(1.f);		
				}
			}
		}
		
		parent.GotoState( 'Discharged' );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		//modSpectre
	var target : CNewNPC;		
	var projectile : CProjectileTrajectory;		

	
	target = (CNewNPC)(activator.GetEntity());
	
	if( target && !parent.allActorsInArea.Contains( target ) )
	{
		parent.allActorsInArea.PushBack( target );
	}
	
	if ( parent.charges && parent.IsValidTarget( target ) && !parent.validTargetsInArea.Contains(target) )
	{
		if( parent.validTargetsInArea.Size() == 0 )
		{
			parent.PlayEffect( parent.effects[parent.fireMode].activateEffect );
		}
		
		parent.validTargetsInArea.PushBack( target );			
	}		
	else if(parent.projDestroyFxEntTemplate)
	{
		projectile = (CProjectileTrajectory)activator.GetEntity();
		
		if(projectile && !((W3SignProjectile)projectile) && IsRequiredAttitudeBetween(caster.GetActor(), projectile.caster, true, true, false))
		{
			if(projectile.IsStopped())
			{
				
				projectile.SetIsInYrdenAlternateRange(parent);
			}
			else
			{			
				ShootDownProjectile(projectile);
			}
		}
	}
}
	
	public final function ShootDownProjectile(projectile : CProjectileTrajectory)
	{
		var hitEntity, fxEntity : CEntity;
		
		hitEntity = ShootTarget(projectile, false, 0.1f, true);
					
		
		if(hitEntity == projectile || !hitEntity)
		{
			
			fxEntity = theGame.CreateEntity( parent.projDestroyFxEntTemplate, projectile.GetWorldPosition() );
			
			
			
			if(!hitEntity)
			{
				parent.PlayEffect( parent.effects[1].shootEffect );		
				parent.PlayEffect( parent.effects[1].shootEffect, fxEntity );
			}
			
			projectile.StopProjectile();
			projectile.Destroy();			
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		//modSpectre
	var target : CNewNPC;
	var projectile : CProjectileTrajectory;

	
	target = (CNewNPC)(activator.GetEntity());
	
	if ( target && parent.charges && target.GetAttitude( thePlayer ) == AIA_Hostile )
	{
		parent.validTargetsInArea.Erase( parent.validTargetsInArea.FindFirst( target ) );
	}
	
	if ( parent.validTargetsInArea.Size() <= 0 )
	{
		parent.StopEffect( parent.effects[parent.fireMode].activateEffect );
	}

	if( target && parent.allActorsInArea.Contains( target ) )
	{
		parent.allActorsInArea.Erase( parent.allActorsInArea.FindFirst( target ) );
	}
}
	
	var traceFrom, traceTo : Vector;
	private function ShootTarget( targetNode : CNode, useTargetsPositionCorrection : bool, extraRayCastLengthPerc : float, useProjectileGroups : bool ) : CEntity
	{
		var results : array<SRaycastHitResult>;
		var i, ind : int;
		var min : float;
		var collisionGroupsNames : array<name>;
		var entity : CEntity;
		var targetActor : CActor;
		var targetPos : Vector;
		var physTest : bool;
		
		traceFrom = virtual_parent.GetWorldPosition();
		traceFrom.Z += 1.f;
		
		targetPos = targetNode.GetWorldPosition();
		traceTo = targetPos;
		if(useTargetsPositionCorrection)
			traceTo.Z += 1.f;
		
		traceTo = traceFrom + (traceTo - traceFrom) * (1.f + extraRayCastLengthPerc);
		
		collisionGroupsNames.PushBack( 'RigidBody' );
		collisionGroupsNames.PushBack( 'Static' );
		collisionGroupsNames.PushBack( 'Debris' );	
		collisionGroupsNames.PushBack( 'Destructible' );	
		collisionGroupsNames.PushBack( 'Terrain' );
		collisionGroupsNames.PushBack( 'Phantom' );
		collisionGroupsNames.PushBack( 'Water' );
		collisionGroupsNames.PushBack( 'Boat' );		
		collisionGroupsNames.PushBack( 'Door' );
		collisionGroupsNames.PushBack( 'Platforms' );
		
		if(useProjectileGroups)
		{
			collisionGroupsNames.PushBack( 'Projectile' );
		}
		else
		{			
			collisionGroupsNames.PushBack( 'Character' );			
		}
		
		physTest = theGame.GetWorld().GetTraceManager().RayCastSync(traceFrom, traceTo, results, collisionGroupsNames);

		if ( !physTest || results.Size() == 0 )
			FindActorsAtLine( traceFrom, traceTo, 0.05f, results, collisionGroupsNames );
		
		if ( results.Size() > 0 )
		{
			
			while(results.Size() > 0)
			{
				
				min = results[0].distance;
				ind = 0;
				
				for(i=1; i<results.Size(); i+=1)
				{
					if(results[i].distance < min)
					{
						min = results[i].distance;
						ind = i;
					}
				}
				
				
				if(results[ind].component)
				{
					entity = results[ind].component.GetEntity();
					targetActor = (CActor)entity;
					
					
					if(targetActor && IsRequiredAttitudeBetween(targetActor, caster.GetActor(), false, false, true))
						return NULL;
					
					
					if( (targetActor && targetActor.GetHealth() > 0.f && targetActor.IsAlive()) || (!targetActor && entity) )
					{
						
						YrdenTrapHitEnemy(targetActor, results[ind].position);						
						return entity;
					}
					else if(targetActor)
					{
						
						results.EraseFast(ind);
					}
				}
				else
				{
					break;
				}
			}
		}
		
		return NULL;
	}
	
	private final function YrdenTrapHitEnemy(entity : CEntity, hitPosition : Vector)
	{
		//modSpectre
	var component : CComponent;
	var targetActor, casterActor : CActor;
	var action : W3DamageAction;
	var player : W3PlayerWitcher;
	var skillType : ESkill;
	var skillLevel, i : int;
	var damageBonusFlat : float;		
	var damages : array<SRawDamage>;
	var glyphwordY : W3YrdenEntity;

	
	parent.StopEffect( parent.effects[parent.fireMode].castEffect );
	//parent.PlayEffect( parent.effects[parent.fireMode].shootEffect );
	parent.PlayEffect( parent.effects[parent.fireMode].castEffect );
		
	targetActor = (CActor)entity;
	if(targetActor)
	{
		component = targetActor.GetComponent('torso3effect');		
		if ( component )
		{
			parent.PlayEffect( parent.effects[parent.fireMode].shootEffect, component );
		}
	}
	
	if(!targetActor || !component)
	{
		parent.PlayEffect( parent.effects[parent.fireMode].shootEffect, entity );
	}

	
	
		parent.charges -= 1;
	
	
	casterActor = caster.GetActor();
	if ( casterActor && (CGameplayEntity)entity)
	{
		
		action =  new W3DamageAction in theGame.damageMgr;
		player = caster.GetPlayer();
		skillType = virtual_parent.GetSkill();

		
		action.Initialize( casterActor, (CGameplayEntity)entity, this, casterActor.GetName()+"_sign_yrden_alt", EHRT_Light, CPS_SpellPower, false, false, true, false, 'yrden_shock', 'yrden_shock', 'yrden_shock', 'yrden_shock');
		virtual_parent.InitSignDataForDamageAction(action);
		action.hitLocation = hitPosition;
		action.SetCanPlayHitParticle(true);
		
		
		if(parent.turretDamageBonus > 0) 
		{
			action.GetDTs(damages);
			action.ClearDamage();
			
			for(i=0; i<damages.Size(); i+=1)
			{
				damages[i].dmgVal += parent.turretDamageBonus;
				action.AddDamage(damages[i].dmgType, damages[i].dmgVal);
			}
		}
		
		
		theGame.damageMgr.ProcessAction( action );
		
		((CGameplayEntity)entity).OnYrdenHit( casterActor );
	}
	else
	{
		entity.PlayEffect( 'yrden_shock' );
	}
	
	if((W3PlayerWitcher)casterActor && ((W3PlayerWitcher)casterActor).HasGlyphwordActive('Glyphword 15 _Stats'))
	{
		glyphwordY = (W3YrdenEntity)theGame.CreateEntity(GetWitcherPlayer().GetSignTemplate(ST_Yrden), entity.GetWorldPosition(), entity.GetWorldRotation() );
		glyphwordY.Init(caster, parent, true, true);
		glyphwordY.CacheActionBuffsFromSkill();
		glyphwordY.GotoState( 'YrdenSlowdown' );
	}
}
	
	event OnThrowing()
	{
		parent.CleanUp();	
	}
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, selected : bool )
	{
		frame.DrawLine(traceFrom, traceTo, Color(255, 255, 0));
	}
}

state YrdenSlowdown in W3YrdenEntity extends Active
{
	event OnEnterState( prevStateName : name )
	{
		//modSpectre

	super.OnEnterState( prevStateName );
	
	parent.GetComponent( 'Slowdown' ).SetEnabled( true );
	parent.PlayEffect( 'yrden_slowdown_sound' );
	
	ActivateSlowdown();

	thePlayer.ResumeStaminaRegen( 'SignCast' );
}
	
	event OnLeaveState( nextStateName : name )
	{
		CleanUp();
		parent.GetComponent('Slowdown').SetEnabled( false );
		parent.ClearActorsInArea();
	}
	
	private function CleanUp()
	{
		var i, size : int;

		size = parent.validTargetsInArea.Size();
		for( i = 0; i < size; i += 1 )
		{
			parent.validTargetsInArea[i].RemoveBuff( EET_YrdenHealthDrain );
		}
		
		for( i=0; i<virtual_parent.fxEntities.Size(); i+=1 )
		{
			virtual_parent.fxEntities[i].StopAllEffects();
			virtual_parent.fxEntities[i].DestroyAfter( 5.f );
		}
		

	}
	
	event OnThrowing()
	{
		parent.CleanUp();	
	}
	
	event OnSignAborted( force : bool )
	{
		if( force )
			CleanUp();
		
		parent.AddTimer('TimedCanceled', 0, , , , true);
		
		super.OnSignAborted( force );
	}
	
	entry function ActivateSlowdown()
	{
		var obj : CEntity;
		var pos : Vector;
		
		obj = (CEntity)parent;
		pos = obj.GetWorldPosition();
		parent.Place(pos);
		
		CreateTrap();
		
		theGame.GetBehTreeReactionManager().CreateReactionEvent( parent, 'YrdenCreated', parent.trapDuration, 30, 0.1f, 999, true );
		parent.NotifyGameplayEntitiesInArea( 'Slowdown' );
		YrdenSlowdown_Loop();
	}
	
	private function CreateTrap()
	{
		//modSpectre
	var i, size : int;
	var worldPos : Vector;
	var isSetBonus2Active : bool;
	var worldRot : EulerAngles;
	var polarAngle, yrdenRange, unitAngle : float;
	var runePositionLocal, runePositionGlobal : Vector;
	var entity : CEntity;
	var j, count : int;
	var traceResult : Vector;
	var effectSettings : SYrdenEffectSettings;
	

	thePlayer.ResumeStaminaRegen( 'SignCast' );

	isSetBonus2Active = GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 );
	worldPos = virtual_parent.GetWorldPosition();
	worldRot = virtual_parent.GetWorldRotation();
	yrdenRange = virtual_parent.baseModeRange;
	size = virtual_parent.runeTemplates.Size();
	unitAngle = 2 * Pi() / size;
	
	if( isSetBonus2Active )
	{
		virtual_parent.PlayEffect( 'ability_gryphon_set' );
	}
	
	for( i=0; i<size; i+=1 )
	{
		polarAngle = unitAngle * i;
		
		runePositionLocal.X = yrdenRange * CosF( polarAngle );
		runePositionLocal.Y = yrdenRange * SinF( polarAngle );
		runePositionLocal.Z = 0.f;
		
		runePositionGlobal = worldPos + runePositionLocal;			
		runePositionGlobal = TraceFloor( runePositionGlobal );
		runePositionGlobal.Z += 0.05f;		
		
		entity = theGame.CreateEntity( virtual_parent.runeTemplates[i], runePositionGlobal, worldRot );
		virtual_parent.fxEntities.PushBack( entity );
	}

	// 5.01 trap art: radial effects and the center rune. The Gryphon range is already in baseModeRange.
	size = virtual_parent.radialEffects.Size();
	for( i=0; i<size; i+=1 )
	{
		effectSettings = virtual_parent.radialEffects[i];
		if(effectSettings.calculateCountFromSpacing)
		{
			count = (int)((2.f * Pi() * yrdenRange) / effectSettings.desiredSpacing);
		}
		else
		{
			count = effectSettings.count;
		}

		unitAngle = 2 * Pi() / count;
		for( j=0; j<count; j+=1 )
		{
			polarAngle = unitAngle * j;
			if(effectSettings.randomAngleDeviation > 0)
			{
				polarAngle += RandRangeF(effectSettings.randomAngleDeviation, -effectSettings.randomAngleDeviation);
			}

			runePositionLocal.X = yrdenRange * effectSettings.rangeModifier * CosF( polarAngle );
			runePositionLocal.Y = yrdenRange * effectSettings.rangeModifier * SinF( polarAngle );
			runePositionLocal.Z = 0.f;

			if(effectSettings.randomLocationDeviation > 0)
			{
				runePositionLocal.X += RandRangeF(effectSettings.randomLocationDeviation, -effectSettings.randomLocationDeviation);
				runePositionLocal.Y += RandRangeF(effectSettings.randomLocationDeviation, -effectSettings.randomLocationDeviation);
			}

			runePositionGlobal = worldPos + runePositionLocal;
			runePositionGlobal = TraceFloor( runePositionGlobal );
			runePositionGlobal.Z += 0.05f;

			entity = theGame.CreateEntity( virtual_parent.radialEffects[i].effectEntityTemplate, runePositionGlobal, worldRot );
			virtual_parent.fxEntities.PushBack( entity );
		}
	}

	traceResult = TraceFloor( worldPos );
	entity = theGame.CreateEntity( virtual_parent.centerRuneTemplate, traceResult, worldRot );
	virtual_parent.fxEntities.PushBack( entity );
}
	
	entry function YrdenSlowdown_Loop()
	{
		//modSpectre
	var i							: int;
	var casterActor, curTarget		: CActor;
	var casterPlayer				: CR4Player;
	var npc							: CNewNPC;
	var params, paramsDrain			: SCustomEffectParams;
	var min, max, pts, prc			: float;
	var startingMin					: float;
	var slowPower, drainNoRes		: float;
	var decayDelay, timePassed		: float;
	var inc, mult, slow				: float;
	var dt							: float = 0.1f;
	var ablMin, ablMax				: SAbilityAttributeValue;
	var superchargedBonus, bonus	: float;
	var currentlyAnimatedCS			: CBaseGameplayEffect;

	
	casterActor = caster.GetActor();
	casterPlayer = caster.GetPlayer();

	params.effectType = EET_Slowdown; 
	params.creator = casterActor;
	params.sourceName = "yrden_mode0";
	params.isSignEffect = true;
	params.customAbilityName = '';
	params.duration = 0.2;
	
	min = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'min_slowdown', false, false));
	max = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, false));
	startingMin = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'min_starting_slowdown', false, false));
	slowPower = parent.yrdenPower.valueMultiplicative;
	
	if(parent.isEntanglement)
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 15 _Stats', 'glyphword15_slow_cap', ablMin, ablMax);
		max = CalculateAttributeValue(ablMin);
	}

	if(parent.hasSupercharged)
	{
		paramsDrain.effectType = EET_YrdenHealthDrain;
		paramsDrain.creator = casterActor;
		paramsDrain.sourceName = "yrden_mode0";
		paramsDrain.isSignEffect = true;
		paramsDrain.customAbilityName = '';
		paramsDrain.duration = 0.2;
		superchargedBonus = parent.superchargedDmg;

		//modSpectre: 5.01 tree, Supercharged Glyphs' drain per second as in 5.01 (W3Effect_YrdenHealthDrain.OnUpdate).
		if(spectreVanillaSkills())
		{
			paramsDrain.effectValue = casterPlayer.GetSkillAttributeValue(S_Magic_s11, 'direct_damage_per_sec', false, true) * casterPlayer.GetSkillLevel(S_Magic_s11);
			ablMin = casterActor.GetTotalSignSpellPower(S_Magic_3);
			paramsDrain.effectValue.valueMultiplicative += ClampF(ablMin.valueMultiplicative / 100, 0.0, 0.15);
			superchargedBonus = 0;
		}
	}

	timePassed = 0;
	mult = 0;
	decayDelay = parent.trapDuration / 3.0;
	inc = dt / (parent.trapDuration - decayDelay);
	
	while(true)
	{
		for(i=parent.flyersInArea.Size()-1; i>=0; i-=1)
		{
			npc = parent.flyersInArea[i];
			if(!npc.IsFlying())
			{
				parent.validTargetsInArea.PushBack(npc);
				npc.BlockAbility('Flying', true);
				parent.flyersInArea.EraseFast(i);
			}
		}
		
		for(i=0; i<parent.validTargetsInArea.Size(); i+=1)
		{
			curTarget = parent.validTargetsInArea[i];

			curTarget.GetResistValue(CDS_ShockRes, pts, prc);
			if(prc < 1)
			{
				if(parent.isEntanglement)
					slow = max * (1 - prc);
				else
					slow = MaxF(0, startingMin * (1 + SignPowerStatToPowerBonus(slowPower - pts/100))) * (1 - prc);
				slow = ClampF(slow, min, max);
				bonus = MaxF(0, superchargedBonus * (1 - prc));
				if(timePassed >= decayDelay)
				{
					slow = min + (slow - min) * (1 - MinF(mult, 1));
					bonus *= 1 - MinF(mult, 1);
				}
				params.effectValue.valueAdditive = slow;
				currentlyAnimatedCS = curTarget.GetCurrentlyAnimatedCS();
				if(currentlyAnimatedCS && !((W3Effect_PoisonCritical)currentlyAnimatedCS) || curTarget.GetIsRecoveringFromKnockdown())
				{
					if(curTarget.HasBuff(EET_Slowdown))
						curTarget.RemoveBuff(EET_Slowdown);
				}
				else if(!curTarget.HasBuff(EET_Slowdown))
					curTarget.AddEffectCustom(params);
				else
					((W3Effect_Slowdown)curTarget.GetBuff(EET_Slowdown)).ResetSlowdownEffect(params.effectValue);
				if(parent.hasSupercharged)
				{
					if(!curTarget.HasBuff(EET_YrdenHealthDrain))
						curTarget.AddEffectCustom(paramsDrain);

					((W3Effect_YrdenHealthDrain)curTarget.GetBuff(EET_YrdenHealthDrain)).SetDmgBonus(bonus);
				}
			}
			
			curTarget.OnYrdenHit( casterActor );
		}
		
		timePassed += dt;
		if(timePassed >= decayDelay)
			mult += inc;
		Sleep(dt);
	}
}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var target : CNewNPC;
		var casterActor : CActor;
		
		target = (CNewNPC)(activator.GetEntity());
		casterActor = caster.GetActor();
		if( (W3PlayerWitcher)activator.GetEntity() )
		{
			parent.isPlayerInside = true;
		}
		
		if( target && !parent.allActorsInArea.Contains( target ) )
		{
			parent.allActorsInArea.PushBack( target );
		}
		
		if ( parent.IsValidTarget( target ) && !parent.validTargetsInArea.Contains(target))
		{
			if (!target.IsFlying())
			{
				
				if( parent.validTargetsInArea.Size() == 0 )
				{
					parent.PlayEffect( parent.effects[parent.fireMode].activateEffect );
				}
				
				parent.validTargetsInArea.PushBack( target );		
				target.SignalGameplayEventParamObject('EntersYrden', parent );
				target.BlockAbility('Flying', true);
			}
			else
			{
				parent.flyersInArea.PushBack(target);
			}
		}
		if( parent.isPlayerInside && GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 ) )
		{
			parent.UpdateGryphonSetBonusYrdenBuff();
		}

	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		//modSpectre
	var target : CNewNPC;
	var i : int;

	
	target = (CNewNPC)(activator.GetEntity());

	if( (W3PlayerWitcher)activator.GetEntity() )
	{
		parent.isPlayerInside = false;
	}
	if( target )
	{
		i = parent.validTargetsInArea.FindFirst( target );
		if( i >= 0 )
		{
			target.RemoveBuff( EET_YrdenHealthDrain );
			
			parent.validTargetsInArea.Erase( i );
		}
		target.SignalGameplayEventParamObject('LeavesYrden', parent );
		target.BlockAbility('Flying', false);
		parent.flyersInArea.Remove(target);
	}
	
	if ( parent.validTargetsInArea.Size() == 0 )
	{
		parent.StopEffect( parent.effects[parent.fireMode].activateEffect );
	}
	if( !parent.isPlayerInside )
	{
		parent.UpdateGryphonSetBonusYrdenBuff();
	}
	
	if( target && parent.allActorsInArea.Contains( target ) )
	{
		parent.allActorsInArea.Erase( parent.allActorsInArea.FindFirst( target ) );
	}
}
}

state Discharged in W3YrdenEntity extends Active
{
	event OnEnterState( prevStateName : name )
	{
		YrdenExpire();
	}
	
	entry function YrdenExpire()
	{
		Sleep( 1.f );
		OnSignAborted( true );
	}
}