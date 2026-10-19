/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/






class W3Effect_Slowdown extends CBaseGameplayEffect
{
	private saved var slowdownCauserId : int;
	private saved var decayPerSec : float;			
	private saved var decayDelay : float;			
	private saved var delayTimer : float;			
	private saved var slowdown : float;				

	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_Slowdown;
	default attributeName = 'slowdown';
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAdded(customParams);
		
		dm = theGame.GetDefinitionsManager();
		
		dm.GetAbilityAttributeValue(abilityName, 'decay_per_sec', min, max);
		decayPerSec = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		dm.GetAbilityAttributeValue(abilityName, 'decay_delay', min, max);
		decayDelay = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		RecalcSlowdown();
		delayTimer = 0;
	}
	
	public function ResetSlowdownEffect(newVal : SAbilityAttributeValue)
	{
		effectValue = newVal;
		RecalcSlowdown();
		timeLeft = initialDuration;
		delayTimer = 0;
	}

	private function RecalcSlowdown()
	{
		slowdown = ClampF(CalculateAttributeValue(effectValue), 0, 1);
		
		if(slowdownCauserId)
		{
			target.ResetAnimationSpeedMultiplier(slowdownCauserId);
		}
		
		slowdownCauserId = target.SetAnimationSpeedMultiplier(1 - slowdown);
	}
	
	event OnUpdate(dt : float)
	{
		if(decayDelay >= 0 && decayPerSec > 0)
		{
			if(delayTimer >= decayDelay)
			{
				target.ResetAnimationSpeedMultiplier(slowdownCauserId);
				slowdown -= decayPerSec * dt;
				
				if(slowdown > 0)
					slowdownCauserId = target.SetAnimationSpeedMultiplier( 1 - slowdown );
				else
					isActive = false;
			}
			else
			{
				delayTimer += dt;
			}
		}
		
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();		
		target.ResetAnimationSpeedMultiplier(slowdownCauserId);
	}
	
	event OnEffectAddedPost()
	{
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
		
		super.OnEffectAddedPost();
	}
}
