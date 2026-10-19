@wrapMethod(W3LeshyRootProjectile) function DelayDamageTimer( delta : float , id : int)
{
	var attributeName 	: name;
	var victims 		: array<CGameplayEntity>;
	var rootDmg 		: float;
	var i 				: int;
	
	if(false) 
	{
		wrappedMethod( delta , id );
	}
	
	action = new W3Action_Attack in this;
	action.SetHitAnimationPlayType(EAHA_ForceYes);
	action.attacker = owner;
	
	FindGameplayEntitiesInRange( victims, fxEntity, 2, 99, , FLAG_OnlyAliveActors );
	
	if ( victims.Size() > 0 )
	{
		for ( i = 0 ; i < victims.Size() ; i += 1 )
		{
			if ( !((CActor)victims[i]).IsCurrentlyDodging() )
			{
				
				action.Initialize( (CGameplayEntity)caster, victims[i], this, caster.GetName()+"_"+"root_projectile", EHRT_Heavy, CPS_AttackPower, false, true, false, false);
				rootDmg = 400;
				action.AddDamage(theGame.params.DAMAGE_NAME_RENDING, rootDmg );
				theGame.damageMgr.ProcessAction( action );
 
 
				victims[i].OnRootHit();
			}
		}
	}
	
	delete action;
}

