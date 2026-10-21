/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen17_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen17;
	default dontAddAbilityOnTarget = true;
	
	public function ManageMutagen17Bonus(attackAction : W3Action_Attack)
	{
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			if(attackAction.DealsAnyDamage() && attackAction.IsActionMelee()
				&& !thePlayer.GetInventory().IsItemFists(attackAction.GetWeaponId()))
			{
				AddMutagen17Ability();
			}
		}
		else
		{
			RemoveMutagen17Abilities();
		}
	}
	
	public function RemoveMutagen17Abilities()
	{
		thePlayer.RemoveAbilityAll(abilityName);
	}
	
	private function AddMutagen17Ability()
	{
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;

		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen17_max_stack', min, max);
			maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			abilityCount = thePlayer.GetAbilityCount(abilityName);
			
			if(abilityCount < maxStack)
			{
				thePlayer.AddAbility(abilityName, true);
			}
		}
	}
	
	var spBonus : float; default spBonus = -1;
	function GetSPBonus() : float
	{
		var min, max : SAbilityAttributeValue;
		
		if(spBonus < 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'spell_power', min, max);
			spBonus = min.valueMultiplicative;
		}
		return spBonus;
	}
	
	public final function GetStacks() : int
	{
		return RoundMath( GetSPBonus() * 100 * thePlayer.GetAbilityCount(abilityName) );
	}

	public final function ClearBoost()
	{
		
	}

	public final function HasBoost() : bool
	{
		return false;
	}


	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(abilityName);
	}
}
