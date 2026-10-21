/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen01_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen01;
	
	default dontAddAbilityOnTarget = true;
	
	var bonusAbility : name; default bonusAbility = 'KatakanBonusEffect';
	
	public function ManageMutagen01Bonus(attackAction : W3Action_Attack)
	{
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			if(attackAction.DealsAnyDamage() && !attackAction.IsCriticalHit() && attackAction.IsActionMelee()
				&& !thePlayer.GetInventory().IsItemFists(attackAction.GetWeaponId()))
			{
				AddMutagen01Ability();
			}
			else if(attackAction.IsCriticalHit())
			{
				RemoveMutagen01Abilities();
			}
		}
		else
		{
			RemoveMutagen01Abilities();
		}
	}
	
	public function RemoveMutagen01Abilities()
	{
		thePlayer.RemoveAbilityAll(abilityName);
		thePlayer.RemoveAbilityAll(bonusAbility);
	}
	
	private function AddMutagen01Ability()
	{
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;
		
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen01_max_stack', min, max);
			maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			abilityCount = thePlayer.GetAbilityCount(abilityName);
			
			if(abilityCount < maxStack)
			{
				thePlayer.AddAbility(abilityName, true);
				abilityCount += 1;
			}
			
			if(abilityCount >= maxStack && !thePlayer.HasAbility(bonusAbility))
				thePlayer.AddAbility(bonusAbility);
		}
	}
	
	var critBonus : float; default critBonus = -1;
	function GetCritBonus() : float
	{
		var min, max : SAbilityAttributeValue;
		
		if(critBonus < 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'critical_hit_chance', min, max);
			critBonus = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		}
		return critBonus;
	}
	
	public final function GetStacks() : int
	{
		return RoundMath( GetCritBonus() * 100 * thePlayer.GetAbilityCount(abilityName) );
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(abilityName);
		target.RemoveAbilityAll(bonusAbility);
	}
}
