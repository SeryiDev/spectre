/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen10_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen10;
	default dontAddAbilityOnTarget = true;

	public function ManageMutagen10Bonus(attackAction : W3Action_Attack)
	{
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			if(attackAction.DealsAnyDamage() && attackAction.IsActionMelee()
				&& !thePlayer.GetInventory().IsItemFists(attackAction.GetWeaponId()))
			{
				RemoveMutagen10Abilities();
			}
		}
		else
		{
			RemoveMutagen10Abilities();
		}
	}
	
	public function RemoveMutagen10Abilities()
	{
		thePlayer.RemoveAbilityAll(abilityName);
	}
	
	public function AddMutagen10Ability()
	{
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;

		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen10_max_stack', min, max);
			maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			abilityCount = thePlayer.GetAbilityCount(abilityName);
			
			if(abilityCount < maxStack)
			{
				thePlayer.AddAbility(abilityName, true);
			}
		}
	}
	
	var apBonus : float; default apBonus = -1;
	function GetAPBonus() : float
	{
		var min, max : SAbilityAttributeValue;
		
		if(apBonus < 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'attack_power', min, max);
			apBonus = min.valueMultiplicative;
		}
		return apBonus;
	}
	
	public final function GetStacks() : int
	{
		return RoundMath( GetAPBonus() * 100 * thePlayer.GetAbilityCount(abilityName) );
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(abilityName);
	}
}
