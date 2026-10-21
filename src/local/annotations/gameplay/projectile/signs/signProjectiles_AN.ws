@wrapMethod(W3AardProjectile) function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
{
	var dmgVal : float;
	var sp : SAbilityAttributeValue;
	var isMutation6 : bool;
	var victimNPC : CNewNPC;
	var aardDRTier : int;
	
	if(false) 
	{
		wrappedMethod(collider, pos, normal);
	}

	if ( hitEntities.FindFirst( collider ) != -1 )
	{
		return;
	}
	
	hitEntities.PushBack( collider );

	super.ProcessCollision( collider, pos, normal );
	
	victimNPC = (CNewNPC) collider;
	aardDRTier = 1;
	if( owner.IsPlayer() && victimNPC )
		aardDRTier = victimNPC.SignDRRegisterAard();
	
	if( victimNPC && victimNPC.IsAlive() && IsRequiredAttitudeBetween(victimNPC, caster, true ) )
	{
		isMutation6 = ( ( W3PlayerWitcher )owner.GetPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation6 ) );
		if ( owner.CanUseSkill(S_Magic_s06) )		
		{			
			dmgVal = GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * CalculateAttributeValue( owner.GetSkillAttributeValue( S_Magic_s06, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
			action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
		}
		else if ( owner.CanUseSkill( S_Magic_s33 ) )
			action.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, GetWitcherPlayer().CalcMagic33Damage() );

		if( victimNPC.IsAlive() && GetStaminaDrainPerc() > 0.f )
		{
			victimNPC.DrainStamina(ESAT_FixedValue, GetStaminaDrainPerc() * victimNPC.GetStatMax(BCS_Stamina) + 1, 1);
		}
	}
	else
	{
		isMutation6 = false;
	}
	
	action.SetHitAnimationPlayType(EAHA_ForceNo);
	action.SetProcessBuffsIfNoDamage(true);

	if ( !owner.IsPlayer() )
	{
		action.AddEffectInfo( EET_KnockdownTypeApplicator );
	}

	if( owner.IsPlayer() && victimNPC )
	{
		if( aardDRTier == 2 )
		{
			action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
			action.RemoveBuffsByType( EET_Knockdown );
			action.RemoveBuffsByType( EET_HeavyKnockdown );
			action.RemoveBuffsByType( EET_LongStagger );
			action.RemoveBuffsByType( EET_Stagger );
			action.RemoveBuffsByType( EET_Ragdoll );
			action.AddEffectInfo( EET_LongStagger );
		}
		else if( aardDRTier == 3 )
		{
			action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
			action.RemoveBuffsByType( EET_Knockdown );
			action.RemoveBuffsByType( EET_HeavyKnockdown );
			action.RemoveBuffsByType( EET_LongStagger );
			action.RemoveBuffsByType( EET_Stagger );
			action.RemoveBuffsByType( EET_Ragdoll );
			action.AddEffectInfo( EET_Stagger );
		}
		else if( aardDRTier >= 4 )
		{
			action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
			action.RemoveBuffsByType( EET_Knockdown );
			action.RemoveBuffsByType( EET_HeavyKnockdown );
			action.RemoveBuffsByType( EET_LongStagger );
			action.RemoveBuffsByType( EET_Stagger );
			action.RemoveBuffsByType( EET_Ragdoll );
			action.SetHitReactionType( EHRT_None, false );
			action.SetHitAnimationPlayType( EAHA_ForceNo );
		}
	}

	theGame.damageMgr.ProcessAction( action );
	
	CheckFrostEffect( collider );
	
	collider.OnAardHit( this );
	
	if( isMutation6 && victimNPC && victimNPC.IsAlive() )
	{
		ProcessMutation6( victimNPC );
	}
}

@wrapMethod(W3AardProjectile) function ProcessMutation6( victimNPC : CNewNPC )
{
	var result : EEffectInteract;
	var mutationAction : W3DamageAction;
	var min, max : SAbilityAttributeValue;
	var dmgVal : float;
	var instaKill, hasKnockdown : bool;
	var freezingChance, pts, prc : float;
	
	if(false) 
	{
		wrappedMethod(victimNPC);
	}

	hasKnockdown = victimNPC.HasBuff( EET_Knockdown ) || victimNPC.HasBuff( EET_HeavyKnockdown ) || victimNPC.GetIsRecoveringFromKnockdown();
	theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'full_freeze_chance', min, max );

	((CActor)victimNPC).GetResistValue(CDS_FrostRes, pts, prc);
	freezingChance = ClampF(min.valueMultiplicative * (1 - prc), 0.0, 1.0);

	result = EI_Deny;

	if( RandF() < freezingChance && !victimNPC.IsInAir() && !victimNPC.IsImmuneToInstantKill() )
	{
		result = victimNPC.AddEffectDefault( EET_Frozen, this, "Mutation 6", true );
	}

	instaKill = false;
	if( EffectInteractionSuccessfull( result ) && hasKnockdown )
	{
		mutationAction = new W3DamageAction in theGame.damageMgr;
		mutationAction.Initialize( owner.GetActor(), victimNPC, this, "Mutation 6", EHRT_None, CPS_Undefined, false, false, true, false );
		mutationAction.SetInstantKill();
		mutationAction.SetForceExplosionDismemberment();
		mutationAction.SetIgnoreInstantKillCooldown();
		theGame.damageMgr.ProcessAction( mutationAction );
		delete mutationAction;
		instaKill = true;
	}

	if( !instaKill && !victimNPC.HasBuff( EET_Frozen ) )
	{
		victimNPC.RemoveAllBuffsOfType(EET_Stagger);
		victimNPC.RemoveAllBuffsOfType(EET_LongStagger);
		victimNPC.RemoveAllBuffsOfType(EET_Knockdown);
		victimNPC.RemoveAllBuffsOfType(EET_HeavyKnockdown);

		mutationAction = new W3DamageAction in theGame.damageMgr;
		mutationAction.Initialize( owner.GetActor(), victimNPC, this, "Mutation 6", EHRT_None, CPS_SpellPower, false, false, true, false );
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'ForceDamage', min, max );
		dmgVal = CalculateAttributeValue( min );
		mutationAction.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
		mutationAction.ClearEffects();
		mutationAction.SetProcessBuffsIfNoDamage( true );
		mutationAction.SetForceExplosionDismemberment();
		mutationAction.SetIgnoreInstantKillCooldown();
		mutationAction.SetBuffSourceName( "Mutation 6" );
		mutationAction.AddEffectInfo( EET_KnockdownTypeApplicator );
		theGame.damageMgr.ProcessAction( mutationAction );
		delete mutationAction;
	}
}

@wrapMethod(W3IgniProjectile) function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
{
	var signPower, channelDmg : SAbilityAttributeValue;
	var burnChance : float;					
	var maxArmorReduction, pts, prc : float;			
	var applyNbr : int;						
	var i : int;
	var npc : CNewNPC;
	var armorRedAblName : name;
	var currentReduction : int;
	var actorVictim : CActor;
	var ownerActor : CActor;
	var dmg : float;
	var performBurningTest : bool;
	var igniEntity : W3IgniEntity;
	var postEffect : CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
	var params : SCustomEffectParams;
	
	if(false) 
	{
		wrappedMethod(collider, pos, normal);
	}
	
	postEffect.AddSurfacePostFXGroup( pos, 0.5f, 8.0f, 10.0f, 2.5f, 1 );
	
	if ( hitEntities.Contains( collider ) )
	{
		return;
	}
	hitEntities.PushBack( collider );		
	
	super.ProcessCollision( collider, pos, normal );	
		
	ownerActor = owner.GetActor();
	actorVictim = ( CActor ) action.victim;
	npc = (CNewNPC)collider;
	signPower = signEntity.GetOwner().GetTotalSignSpellPower(signEntity.GetSkill());

	if ( owner.CanUseSkill(S_Magic_s08) && (CActor)collider)
	{	
		((CActor)collider).GetResistValue(CDS_FireRes, pts, prc);
		if(prc < 1)
		{
			params.effectType = EET_MeltArmorDebuff;
			params.creator = owner.GetActor();
			if(signEntity.IsAlternateCast())
				params.sourceName = "alt_cast";
			else
				params.sourceName = "normal_cast";
			params.customPowerStatValue = signPower;
			((CActor)collider).AddEffectCustom(params);
		}
	}

	if(owner.CanUseSkill(S_Magic_s07) && !igniEntity.hitEntities.Contains( collider ) && !signEntity.IsAlternateCast())
	{
		dmg = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s07, 'fire_damage_bonus', false, false)) * owner.GetSkillLevel(S_Magic_s07);
		action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
	}

	if(signEntity.IsAlternateCast())		
	{
		igniEntity = (W3IgniEntity)signEntity;
		performBurningTest = igniEntity.UpdateBurningChance(actorVictim, dt);
		
		if( igniEntity.hitEntities.Contains( collider ) )
		{
			channelCollided = true;
			action.SetHitEffect('');
			action.SetHitEffect('', true );
			action.SetHitEffect('', false, true);
			action.SetHitEffect('', true, true);
			action.ClearDamage();

			channelDmg = owner.GetSkillAttributeValue(signSkill, 'channeling_damage', false, false);
			channelDmg += owner.GetSkillAttributeValue(signSkill, 'channeling_damage_after_1', false, false) * (owner.GetSkillLevel(S_Magic_s02) - 1);
			dmg = channelDmg.valueAdditive + channelDmg.valueMultiplicative * actorVictim.GetMaxHealth();
			if(owner.CanUseSkill(S_Magic_s07))
			{
				dmg += CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s07, 'channeling_damage_bonus', false, false)) * owner.GetSkillLevel(S_Magic_s07);
			}
			dmg *= signPower.valueMultiplicative;
			dmg *= dt;
			action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
			action.SetIsDoTDamage(dt);

			if(!collider)
				return;
		}
		else
		{
			igniEntity.hitEntities.PushBack( collider );
		}
		
		if(!performBurningTest)
		{
			action.ClearEffects();
		}
	}
	
	if ( npc && npc.IsShielded( ownerActor ) )
	{
		collider.OnIgniHit( this );	
		return;
	}
	
	if ( !owner.IsPlayer() )
	{
		burnChance = signPower.valueMultiplicative;
		if ( RandF() < burnChance )
		{
			action.AddEffectInfo(EET_Burning);
		}
		
		dmg = CalculateAttributeValue(signPower);
		if ( dmg <= 0 )
		{
			dmg = 20;
		}			
		action.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmg);
	}
	
	if(signEntity.IsAlternateCast())
	{
		action.SetHitAnimationPlayType(EAHA_ForceNo);
	}
	else		
	{
		
		if(ownerActor.HasTag('mq1060_witcher'))
		{
			action.SetHitEffect('igni_cone_hit_red', false, false);
			action.SetHitEffect('igni_cone_hit_red', true, false);
		}
		else
		{
			action.SetHitEffect('igni_cone_hit', false, false);
			action.SetHitEffect('igni_cone_hit', true, false);
		}			
		action.SetHitReactionType(EHRT_Igni, false);
	}
	
	theGame.damageMgr.ProcessAction( action );	
	
	
	if ( owner.CanUseSkill(S_Magic_s08) && (CActor)collider)
	{	
		maxArmorReduction = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, true)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s08);
		applyNbr = RoundMath( 100 * maxArmorReduction * ( signPower.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED ) );
		
		armorRedAblName = SkillEnumToName(S_Magic_s08);
		currentReduction = ((CActor)collider).GetAbilityCount(armorRedAblName);
		
		applyNbr -= currentReduction;
		
		for ( i = 0; i < applyNbr; i += 1 )
			action.victim.AddAbility(armorRedAblName, true);
	}	
	collider.OnIgniHit( this );		
}
