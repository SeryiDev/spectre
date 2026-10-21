/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/




class W3Effect_Mutation11Buff extends CBaseGameplayEffect
{
	default effectType = EET_Mutation11Buff;
	default isPositive = true;

	private var drainTemplate : CEntityTemplate;
	private var actors : array< CActor >;
	private var numActors : int;
	private var drainEnts : array< CEntity >;
	private var drainStrength : float;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var min, max			: SAbilityAttributeValue;		
		var i					: int;
		var tmpActors			: array< CActor >;
		
		super.OnEffectAdded( customParams );

		drainTemplate = (CEntityTemplate)LoadResource("fx\monsters\noonwraith\drain_energy\drain_energy.w2ent", true);
		tmpActors = GetActorsInRange( target, 30, 50, '', true );
		for(i = tmpActors.Size() - 1; i >= 0; i -= 1)
		{
			if( GetAttitudeBetween( target, tmpActors[i] ) != AIA_Hostile )
			{
				tmpActors.Erase( i );
			}
		}
		numActors = Min(3, tmpActors.Size());
		for(i = 0; i < numActors; i += 1)
		{
			actors.PushBack(tmpActors[i]);
		}
		
		drainStrength = ((W3PlayerWitcher)target).Mutation11GetBaseStrength();
		drainStrength *= target.GetStat(BCS_Focus);

		drainStrength /= 1.0 * numActors;

		drainStrength = MaxF(1, drainStrength);

		for(i = 0; i < actors.Size(); i += 1)
		{
			PlayDrainEnergy( actors[i] );
			AddDrainBuff( actors[i] );
		}
	}

	private function PlayDrainEnergy( npc : CActor )
	{
		var targetNode : CNode;
		var sourceNode : CNode;
		var drainEffectEntity : CEntity;
		
		targetNode = target.GetComponent("DrainEnergyTarget");
		if( !targetNode )
			targetNode = target;
		
		sourceNode = npc.GetComponent("torso3effect");
		if( !sourceNode )
			sourceNode = npc;
		
		drainEffectEntity = theGame.CreateEntity( drainTemplate, sourceNode.GetWorldPosition(), target.GetWorldRotation() );
		drainEffectEntity.PlayEffect( 'drain_energy', targetNode );
		
		drainEnts.PushBack( drainEffectEntity );
	}

	private function AddDrainBuff( npc : CActor )
	{
		var drainParams : SCustomEffectParams;
		
		drainParams.effectType	= EET_VitalityDrain;
		drainParams.creator		= target;
		drainParams.sourceName	= 'Mutation11';
		drainParams.duration	= initialDuration;
		drainParams.effectValue.valueAdditive = drainStrength;
			
		npc.AddEffectCustom( drainParams );
	}

	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		
		GetWitcherPlayer().Mutation11StartAnimation();
		
		
		target.ResumeHPRegenEffects( '', true );
		
		
		target.StartVitalityRegen();
		
		
		target.AddEffectDefault( EET_Mutation11Immortal, target, "Mutation 11", false );
		
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}
	
	event OnUpdate( deltaTime : float )
	{
		var i : int;
		var sourceNode : CNode;
		var val : SAbilityAttributeValue;
		
		super.OnUpdate( deltaTime );
		
		numActors = 0;
		for( i = 0; i < actors.Size(); i += 1 )
		{
			if( !actors[i].IsAlive() )
			{
				if( drainEnts[i] && drainEnts[i].IsEffectActive( 'drain_energy' ) )
				{
					drainEnts[i].StopEffect( 'drain_energy' );
					drainEnts[i].DestroyAfter( 3 );
				}
			}
			else
			{
				numActors += 1;
				if( drainEnts[i] )
				{
					sourceNode = actors[i].GetComponent("torso3effect");
					if( !sourceNode )
						sourceNode = actors[i];
					drainEnts[i].Teleport( sourceNode.GetWorldPosition() );
				}
				val = actors[i].GetBuff(EET_VitalityDrain).GetEffectValue();
			}
		}
		
		target.Heal( drainStrength * numActors * deltaTime );
	}
	
	event OnEffectRemoved()
	{
		var i : int;
		
		target.RemoveBuff( EET_Mutation11Immortal );
		
		
		target.AddEffectDefault( EET_Mutation11Debuff, NULL, "Mutation 11 Debuff", false );
		
		super.OnEffectRemoved();

		for( i = 0; i < drainEnts.Size(); i += 1 )
		{
			if( drainEnts[i] )
			{
				drainEnts[i].StopEffect( 'drain_energy' );
				drainEnts[i].DestroyAfter( 3 );
			}
		}

		Impulse();
	}
	
	public function Impulse()
	{
		var ents					: array<CGameplayEntity>;
		var i, j					: int;
		var action					: W3DamageAction;
		var damages					: array< SRawDamage >;
		
		damages = theGame.GetDefinitionsManager().GetDamagesFromAbility( 'Mutation11' );

		FindGameplayEntitiesInRange(ents, target, 5.f, 1000, , FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile, target);
		for(i = 0; i < ents.Size(); i += 1)
		{
			action = new W3DamageAction in theGame;
			action.Initialize(target, ents[i], NULL, "Mutation11", EHRT_Heavy, CPS_SpellPower, false, false, true, false);
			for(j = 0; j < damages.Size(); j += 1)
			{
				action.AddDamage(damages[j].dmgType, damages[j].dmgVal);
			}
			action.AddEffectInfo(EET_KnockdownTypeApplicator);
			action.SetCannotReturnDamage(true);
			action.SetProcessBuffsIfNoDamage(true);
			action.SetHitAnimationPlayType(EAHA_ForceYes);
			action.SetHitEffectAllTypes('hit_electric_quen');
			theGame.damageMgr.ProcessAction(action);
			delete action;
		}
		
		target.PlayEffect('lasting_shield_discharge');
	}
}	
