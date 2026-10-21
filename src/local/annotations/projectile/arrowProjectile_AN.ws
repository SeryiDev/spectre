@wrapMethod(W3ArrowProjectile) function OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
{
	
	var actorVictim	: CActor;
	var casterPos 	: Vector;
	var parryInfo 	: SParryInfo;
	var arrowHitPos : Vector;
	var bounce		: bool;
	var abs 		: array<name>;
	var isRolling	: bool;
	var template 	: CEntityTemplate;
	var meshComponent 	: CMeshComponent;
	var boundingBox 	: Box;
	var arrowSize 		: Vector;
	var hitPos 			: Vector;
	var attackPower		: SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}

	
	if ( yrdenAlternate )
	{
		return true;
	}
	
	SetShouldBeAttachedToVictim( true );
	
	if ( !isActive )
	{
		return true;
	}
	
	if(collidingComponent)
		victim = (CGameplayEntity)collidingComponent.GetEntity();
	
	if ( collidingComponent || !hitCollisionsGroups.Contains( 'Water' ) )
		RemoveTimer( 'CheckIfInfWaterLoop' );
	
	super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	
	if(!victim && thePlayer.HasAbility('sq108_heavy_armor _Stats', true))
		victim = thePlayer;
	
	if( collidingComponent && !hitCollisionsGroups.Contains( 'Static' ) && !((CActor)victim).IsCurrentlyDodging() )
	{	
		if ( !victim || collidedEntities.Contains(victim) || victim == caster )
			return false;
		
		actorVictim = (CActor)victim;
		
		if ( hitCollisionsGroups.Contains( 'Ragdoll' ) && actorVictim )
		{
			boneName = ((CMovingPhysicalAgentComponent)actorVictim.GetMovingAgentComponent()).GetRagdollBoneName(actorIndex);
		}
		
	}
	else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) || hitCollisionsGroups.Contains( 'Debris' ) || hitCollisionsGroups.Contains( 'Destructible' ) || hitCollisionsGroups.Contains( 'RigidBody' ) || hitCollisionsGroups.Contains( 'Foliage' ) || hitCollisionsGroups.Contains( 'Door' ) || hitCollisionsGroups.Contains( 'Platforms' ) || hitCollisionsGroups.Contains( 'Fence' ) )	//modSpectre																																																																																																			 
	{
		StopProjectile();
		isActive = false;
		StopActiveTrail();
		
		
		AddTimer('TimeDestroy', 5, false);
		isScheduledForDestruction = true;
		
		
		arrowHitPos = pos + RotForward( this.GetWorldRotation() ) * 0.5f; 
		Teleport( arrowHitPos );
		
		this.SoundEvent("cmb_arrow_impact_dirt");
		return true;
	}
	else if ( hitCollisionsGroups.Contains( 'Water' ) )
	{
		if ( isUnderwater )
		{
			return false;
		}
		
		
		SoundEvent("cmb_arrow_impact_water");
		
		CheckIfInfWater();
		return true;
	}	
	else 
	{
		return false;
	}
	
	if ( !actorVictim ) 
	{
		StopProjectile();
		isActive = false;
		StopActiveTrail();
		
		
		AddTimer('TimeDestroy', 5, false);
		isScheduledForDestruction = true;
		
		
		if( StrFindFirst( this.GetName(), "bolt" ) != -1 )
		{
			
			meshComponent = (CMeshComponent)GetComponentByClassName('CMeshComponent');
			if( meshComponent )
			{
				boundingBox = meshComponent.GetBoundingBox();
				arrowSize = boundingBox.Max - boundingBox.Min;
				
				hitPos = pos;
				hitPos -= RotForward(  this.GetWorldRotation() ) * arrowSize.X * 0.7f; 
				
				Teleport( hitPos );
			}
		}
		
		ProcessDamageAction(victim, pos, boneName);
		
		this.SoundEvent("cmb_arrow_impact_wood");
		
		return true;
	}		
	else if (victim == thePlayer)
	{
		bounce = false;
		
		if ( thePlayer.IsCurrentlyDodging() && thePlayer.GetBehaviorVariable( 'isRolling' ) == 1.f )
		{
			isRolling = true;
		}
		else if ( thePlayer.CanParryAttack() )
		{

			parryInfo = thePlayer.ProcessParryInfo(((CActor)caster),((CActor)victim),AST_Jab,ASD_NotSet,'attack_light',((CActor)caster).GetInventory().GetItemFromSlot('l_weapon'), true);
			if ( thePlayer.PerformParryCheck(parryInfo) )
			{
				if ( spectreVanillaSkills() && (thePlayer.CanUseSkill(S_Sword_s10) || thePlayer.CanUseSkill(S_Sword_s33)) )
				{
					// 5.01 tree: Arrow Deflection as in 5.01.
					if(ProcessCombat_ArrowDeflection())
						return true;
					GetWitcherPlayer().GainAdrenalineFromPerk31( 'parry' );
					bounce = true;
				}
				else if ( !spectreVanillaSkills() && thePlayer.CheckCounterSpamming( (CActor)caster ) && thePlayer.CanUseSkill(S_Sword_s10) )
				{
					casterPos = caster.GetWorldPosition();
					casterPos.Z += 1.5;
					this.Init(thePlayer);
					this.ShootProjectileAtPosition(2,projSpeed*0.7,casterPos);
					ActivateTrail('arrow_trail_red');
					isBouncedArrow = true;
					return true;
				}
				else
				{
					bounce = true;
				}
			}
		}

		if(!bounce && (W3PlayerWitcher)thePlayer && ((W3PlayerWitcher)thePlayer).HasGlyphwordActive( 'Glyphword 1 _Stats' ))
		{
			thePlayer.PlayEffect('glyphword_reflection');
			template = (CEntityTemplate)LoadResource('glyphword_1');
			theGame.CreateEntity(template, GetWorldPosition(), thePlayer.GetWorldRotation(), , , true);
			this.SoundEvent( "cmb_arrow_bounce" );
			bounce = true;
		}
		
		if(!bounce)
		{
			thePlayer.GetCharacterStats().GetAbilities(abs, true);				
			bounce = abs.Contains(theGame.params.BOUNCE_ARROWS_ABILITY);
			
			if(bounce)
			{
				FactsAdd("sq108_arrow_deflected");
				thePlayer.PlayEffect( 'bolt_bump' );
			}
		}

		if( !bounce && (W3PlayerWitcher)thePlayer )
		{
			if( RandF() < CalculateAttributeValue(((W3PlayerWitcher)thePlayer).GetAttributeValue('q108_bounce_arrows')) )
			{
				thePlayer.PlayEffect( 'bolt_bump' );
				bounce = true;
			}
		}
		
		if(bounce)
		{	
			this.bounceOfVelocityPreserve = 0.7;
			this.BounceOff(normal,pos);
			this.Init(thePlayer);
			ActivateTrail('arrow_trail_orange');
			return false;
		}
		else if ( !isRolling )
		{
			thePlayer.SetIsDodgingProjectile( false );

			if( actorVictim.IsAlive() )
				ProcessDamageAction( actorVictim, pos, boneName );
			
			this.SoundEvent( "cmb_arrow_impact_body" );
			
			if( IsNameValid( boneName ) )
				AttachArrowToRagdoll( actorVictim, pos, boneName );
			else
			{
				StopProjectile();
				StopActiveTrail();
				isActive = false;
				SmartDestroy();
			}
		}
	}
	else if ( (CNewNPC)victim && ((CNewNPC)victim).IsShielded(caster) ) 
	{
		((CNewNPC)victim).SignalGameplayEvent('PerformAdditiveParry');
		
		this.SoundEvent("cmb_arrow_impact_wood");
		
		AttachArrowToShield(actorVictim, pos);

		if(caster == thePlayer)
			GetWitcherPlayer().ResetCripplingShot();
	}
	else
	{
		if(actorVictim.IsAlive())
		{
			if ( actorVictim.HasAbility( 'BounceBoltsWildhunt' ))
			{
				if(caster == thePlayer)
					GetWitcherPlayer().ResetCripplingShot();

				this.bounceOfVelocityPreserve = 0.1;
				this.BounceOff(normal, pos);
				this.Init(actorVictim);
				this.PlayEffect('sparks');
				this.SoundEvent("cmb_arrow_impact_metal");
				ActivateTrail('arrow_trail_orange');
				return false;
			}
			else
			{
				ProcessDamageAction(actorVictim, pos, boneName);
			}
		}
		else if ( actorVictim.IsInAgony() )
		{
			
			actorVictim.SignalGameplayEvent('AbandonAgony');
			
			actorVictim.SetKinematic(false);
		}
		
		this.SoundEvent("cmb_arrow_impact_body");
		
		if( ShouldPierceVictim( actorVictim ) ) 
		{
			Mutation9HitFX( actorVictim );
		}
		else if(IsNameValid(boneName))
		{
			AttachArrowToRagdoll(actorVictim,pos,boneName);
		}
		else
		{
			StopProjectile();
			StopActiveTrail();
			isActive = false;
			SmartDestroy();
		}
	}
	return true;
}

@wrapMethod(W3ArrowProjectile) function ProcessDamageAction(victim : CGameplayEntity, pos : Vector, boneName : name)
{
	var action : W3DamageAction;
	var victimTags, attackerTags : array<name>;
	var none 		: SAbilityAttributeValue;
	var heldWeaponPiercingDmg, heldWeaponSilverDmg : float;
	var boneNameString : string; 
	
	if(false) 
	{
		wrappedMethod(victim, pos, boneName);
	}
	
	boneNameString = NameToString(boneName);
	heldWeaponPiercingDmg = GetHeldWeaponDamage( theGame.params.DAMAGE_NAME_PIERCING );
	heldWeaponSilverDmg = GetHeldWeaponDamage( theGame.params.DAMAGE_NAME_SILVER );
	if( heldWeaponPiercingDmg > 0 )
		projDMG = heldWeaponPiercingDmg;
	if( heldWeaponSilverDmg > 0 )
		projSilverDMG = heldWeaponSilverDmg;

	action = new W3DamageAction in this;
	action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_AttackPower,false,true,false,false);				
	if( isOnFire )		
	{
		action.AddEffectInfo(EET_Burning);
		action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, projDMG );
		action.AddDamage(theGame.params.DAMAGE_NAME_SILVER, projSilverDMG );
	}
	else
	{
		action.AddDamage(theGame.params.DAMAGE_NAME_PIERCING, projDMG );
		action.AddDamage(theGame.params.DAMAGE_NAME_SILVER, projSilverDMG );
	}
		
	if( this.projEfect != EET_Undefined )
	{
		action.AddEffectInfo(this.projEfect);
	}
	
	if ( ((CNewNPC)victim) )
	{
		if ( StrFindFirst(boneNameString, "head") >= 0 || StrFindFirst(boneNameString, "neck") >= 0 || StrFindFirst(boneNameString, "hroll") >= 0 || ( StrFindFirst(boneNameString, "pelvis") >= 0 && ((CNewNPC)victim).IsHuman() ) )
			action.SetHeadShot();
	}
	
	if(isBouncedArrow || deflected)
	{
		action.SetBouncedArrow();
	}
	
	theGame.damageMgr.ProcessAction( action );
	collidedEntities.PushBack(victim);
	delete action;
	
	
	victimTags = victim.GetTags();
	
	attackerTags = caster.GetTags();
	
	AddHitFacts( victimTags, attackerTags, "_arrow_hit" );
}

@addMethod(W3ArrowProjectile) function GetHeldWeaponDamage( damageTypeName : name ) : float
{
	var itemCategory : name;
	var heldWeapons : array <SItemUniqueId>;
	var i : int;
	var inv : CInventoryComponent;
	var actorAttacker : CActor;
	
	actorAttacker = (CActor)caster;
	
	if( !actorAttacker )
		return 0;
	
	inv = actorAttacker.GetInventory();
	heldWeapons = inv.GetHeldWeapons();
	for( i = 0; i < heldWeapons.Size(); i += 1 )
	{
		itemCategory = inv.GetItemCategory( heldWeapons[i] );
		if( itemCategory == 'bow' || itemCategory == 'crossbow' )
		{
			return actorAttacker.GetTotalWeaponDamage( heldWeapons[i], damageTypeName, GetInvalidUniqueId() );
		}
	}
	return 0;
}
