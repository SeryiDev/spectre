/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen24_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen24;

	default dontAddAbilityOnTarget = true;
	default isPositive = false;
	default isNegative = false;
	default isNeutral = true;
	
	var cooldownTimer : float; default cooldownTimer = 0.0f;
	
	public function ManageMutagen24Bonus()
	{
		var min, max : SAbilityAttributeValue;
		var hpThreshold, cooldownTime : float;
		
		if(target == thePlayer && thePlayer.IsInCombat())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'm24_hp_threshold', min, max);
			hpThreshold = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			if(!thePlayer.HasAbility(abilityName))
			{
				if(thePlayer.GetStatPercents(BCS_Vitality) <= hpThreshold && cooldownTimer <= 0.0f)
				{
					AddMutagen24Bonus();
				}
			}
			else
			{
				if(thePlayer.GetStatPercents(BCS_Vitality) > hpThreshold)
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'm24_cooldown_time', min, max);
					cooldownTime = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
					cooldownTimer = cooldownTime;
					ResetMutagen24Bonus();
				}
			}
		}
		else if(target == thePlayer && !thePlayer.IsInCombat())
		{
			ResetMutagen24Bonus();
		}
	}
	
	private function AddMutagen24Bonus()
	{
		thePlayer.AddAbility(abilityName);
		thePlayer.SoundEvent("magic_geralt_healing_oneshot");
		ForceUpdateBuffsModule();
	}
	
	public function ResetMutagen24Bonus()
	{
		if(thePlayer.HasAbility(abilityName))
		{
			thePlayer.RemoveAbilityAll(abilityName);
			ForceUpdateBuffsModule();
		}
	}
	
	function ForceUpdateBuffsModule()
	{
		if(cooldownTimer > 0)
		{
			isPositive = false;
			isNegative = true;
			isNegative = false;
		}
		else if(thePlayer.HasAbility(abilityName))
		{
			isPositive = true;
			isNegative = false;
			isNeutral = false;
		}
		else
		{
			isPositive = false;
			isNegative = false;
			isNeutral = true;
		}
		((CR4HudModuleBuffs)((CR4ScriptedHud)theGame.GetHud()).GetHudModule("BuffsModule")).ForceUpdate();
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		if(cooldownTimer > 0.0f)
			cooldownTimer -= dt;
		else if(cooldownTimer > -999.0f)
		{
			cooldownTimer = -1000.0f;
			ForceUpdateBuffsModule();
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		ManageMutagen24Bonus();
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		ResetMutagen24Bonus();
	}
}
