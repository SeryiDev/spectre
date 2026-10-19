/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class W3Effect_KaerMorhenSetBonus extends CBaseGameplayEffect
{
	default effectType = EET_KaerMorhenSetBonus;
	default isPositive = true;
	default dontAddAbilityOnTarget = true;
	
	var UPDATE_INTERVAL : float; default UPDATE_INTERVAL = 1.0f;
	var timeInterval : float; default timeInterval = 0.0f;
	var maxStacks : int;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAdded( customParams );
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'maxStacks', min, max);
		maxStacks = RoundMath(min.valueAdditive);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		thePlayer.RemoveAbilityAll(abilityName);
	}
		
	event OnUpdate(dt : float)
	{
		var numEnemies, maxStack, abilityCount : int;
	
		super.OnUpdate(dt);
		
		timeInterval += dt;
		
		if(timeInterval >= UPDATE_INTERVAL)
		{
			timeInterval -= UPDATE_INTERVAL;
			
			numEnemies = Clamp(GetWitcherPlayer().GetNumHostilesInRange() - 1, 0, maxStacks);
			abilityCount = thePlayer.GetAbilityCount(abilityName);
				
			if(numEnemies > abilityCount)
			{
				thePlayer.AddAbilityMultiple(abilityName, numEnemies - abilityCount);
			}
			else if(numEnemies < abilityCount)
			{
				thePlayer.RemoveAbilityMultiple(abilityName, abilityCount - numEnemies);
			}
		}
	}
}
