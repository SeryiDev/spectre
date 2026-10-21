@addField(W3BoltProjectile)
protected  var boltItemName				: name; 

@wrapMethod(W3BoltProjectile) function OnProjectileInit()
{
	collidedEntities.Clear();							  
	wrappedMethod();
}

@wrapMethod(W3BoltProjectile) function ProcessDamageAction(victim : CGameplayEntity, pos : Vector, boneName : name)
{
	var action : W3Action_Attack;
	var victimTags, attackerTags : array<name>;
	var boltAdded : bool;
	var boneNameString : string;
	
	if(false) 
	{
		wrappedMethod(victim, pos, boneName);
	}
	
	boneNameString = NameToString(boneName);

	if(collidedEntities.Contains(victim))
		return;
	
	if(GetOwner().GetInventory().GetItemQuantity(itemId) <= 0 && IsNameValid(boltItemName))
	{
		GetOwner().GetInventory().AddAnItem(boltItemName, 1, true, true);
		itemId = GetOwner().GetInventory().GetItemId(boltItemName);
		boltAdded = true;
	}

	if(caster == thePlayer)
	{
		
		thePlayer.ApplyItemAbilities(itemId);
		
		
		thePlayer.ApplyItemAbilities(crossbowId);
	}
	
	action = new W3Action_Attack in this;
	action.Init( (CGameplayEntity)caster, victim, this, itemId, 'bolt', caster.GetName(), EHRT_Light, false, false, '', AST_NotSet, ASD_NotSet, false, true, false, false, , , , , crossbowId);
	
	
	if ( (CNewNPC)victim )
	{
		if ( StrFindFirst(boneNameString, "head") >= 0 || StrFindFirst(boneNameString, "neck") >= 0 || StrFindFirst(boneNameString, "hroll") >= 0 || ( StrFindFirst(boneNameString, "pelvis") >= 0 && ((CNewNPC)victim).IsHuman() ) )
			action.SetHeadShot();
	}
		
	theGame.damageMgr.ProcessAction( action );		
	delete action;
	
	
	if(caster == thePlayer)
	{
		
		thePlayer.RemoveItemAbilities(itemId);
		
		
		thePlayer.RemoveItemAbilities(crossbowId);
	}

	if(boltAdded)
	{
		GetOwner().GetInventory().RemoveItemByName(boltItemName, 1);
		boltAdded = false;
	}
	
	collidedEntities.PushBack(victim);
	
	
	if(caster == thePlayer && (CActor)victim && IsRequiredAttitudeBetween(caster, victim, true))
	{
		FactsAdd("ach_crossbow", 1, 4 );
	}
	
	
	victimTags = victim.GetTags();		
	attackerTags = caster.GetTags();		
	AddHitFacts( victimTags, attackerTags, "_bolt_hit" );
}

@wrapMethod(W3BoltProjectile) function ReleaseProjectiles2( time : float , id : int)
{
	var sideVec, vecToTarget	: Vector;
	var sideLen 				: float;	
	var distanceToTarget		: float;
	var	projectileFlightTime 	: float;
	var attackRange				: float;
	var target 					: CActor = thePlayer.GetTarget();
	var inv 					: CInventoryComponent;
	var boneIndex				: int;
	var npc						: CNewNPC;
	var vcc						: SVirtualControllerData;
	var boneName				: name;

	if(false) 
	{
		wrappedMethod(time, id);
	}
	
	if ( thePlayer.IsDiving() )
	{
		attackRange = theGame.params.UNDERWATER_THROW_RANGE;
		projSpeed = projSpeed * 0.6;
	}
	else
	{
		attackRange = theGame.params.MAX_THROW_RANGE;
	}
	
	
	boneIndex = -1;
	npc = (CNewNPC)(thePlayer.GetDisplayTarget());
	if ( npc && thePlayer.IsCombatMusicEnabled() && thePlayer.playerAiming.GetCurrentStateName() == 'Waiting' )
	{
		if ( thePlayer.HasVirtualControllerTarget() )
		{
			vcc = thePlayer.GetTargetableVirtualController();
			boneName = vcc.boneName;
			boneIndex = vcc.boneIndex;
		}
		else
		{
			boneName = 'torso2';
			boneIndex = npc.GetBoneIndex( boneName );
		}
	}
	if ( target.HasTag('AddRagdollCollision'))
	{
		collisionGroups.Remove('Character');
	}
	if ( boneIndex >= 0 )
		projectiles[0].ShootProjectileAtBone( projAngle, projSpeed, npc, boneName, attackRange, collisionGroups );
	else
		projectiles[0].ShootProjectileAtPosition( projAngle, projSpeed, targetPos, attackRange, collisionGroups );
		
	projectiles[0].SoundEvent("cmb_arrow_swoosh");
	
	boltItemName = GetOwner().GetInventory().GetItemName(itemId);
	
	if(!FactsDoesExist("debug_fact_inf_bolts"))
	{
		inv = GetOwner().GetInventory();
	
		if(!inv.ItemHasTag(itemId, theGame.params.TAG_INFINITE_AMMO))
			inv.RemoveItem(itemId);
	}

	thePlayer.DrainStamina(ESAT_UsableItem);

	if ( dodgeable && target )
	{
		distanceToTarget = VecDistance( thePlayer.GetWorldPosition(), target.GetWorldPosition() );		
		
		
		projectileFlightTime = distanceToTarget / projSpeed;
		target.SignalGameplayEventParamFloat('Time2DodgeProjectile', projectileFlightTime );
	}
	
	if ( projectiles.Size() > 1 )
	{
		vecToTarget = GetOwner().GetWorldPosition() - targetPos;
		sideVec = VecCross(VecNormalize(vecToTarget), Vector(0, 0, 1));
		sideLen = SinF( 3.0f * Pi() / 180.0f ) * VecLength(vecToTarget);		
		
		projectiles[1].ShootProjectileAtPosition( projAngle, projSpeed, targetPos + VecNormalize(sideVec) * sideLen, attackRange, collisionGroups );
		projectiles[1].SoundEvent("cmb_arrow_swoosh");
		
		if(projectiles.Size() > 2)
		{
			projectiles[2].ShootProjectileAtPosition( projAngle, projSpeed, targetPos - VecNormalize(sideVec) * sideLen, attackRange, collisionGroups);
			projectiles[2].SoundEvent("cmb_arrow_swoosh");
		}
	} 
}
