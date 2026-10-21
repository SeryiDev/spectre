/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen05_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen05;
	default dontAddAbilityOnTarget = true;
	
	public function ManageMutagen05Bonus(damageAction : W3DamageAction)
	{
		var attackAction : W3Action_Attack;

		attackAction = (W3Action_Attack)damageAction;
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			if(attackAction && attackAction.attacker == thePlayer && attackAction.DealsAnyDamage() && attackAction.IsActionMelee()
				&& !thePlayer.GetInventory().IsItemFists(attackAction.GetWeaponId()))
			{
				AddMutagen05Ability();
			}
			else if(damageAction.victim == thePlayer && damageAction.DealsAnyDamage()
				&& !(damageAction.IsDoTDamage() && (CBaseGameplayEffect)damageAction.causer))
			{
				RemoveMutagen05Abilities(damageAction.GetDamageDealt());
			}
		}
		else
		{
			RemoveMutagen05AbilitiesAll();
		}
	}
	
	public function RemoveMutagen05AbilitiesAll()
	{
		thePlayer.RemoveAbilityAll(abilityName);
	}
	
	private function RemoveMutagen05Abilities(dmgVal : float)
	{
		var min, max : SAbilityAttributeValue;
		var debuffRate : float;
		var abilityCount, debuffNum : int;
		
		if(dmgVal <= 0)
			return;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen05_debuff_rate', min, max);
		debuffRate = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		debuffNum = RoundMath(debuffRate * dmgVal / thePlayer.GetMaxHealth() * 100);
		abilityCount = thePlayer.GetAbilityCount(abilityName);
		
		if(debuffNum < abilityCount)
			thePlayer.RemoveAbilityMultiple(abilityName, debuffNum);
		else
			thePlayer.RemoveAbilityAll(abilityName);
	}
	
	private function AddMutagen05Ability()
	{
		var abilityCount, maxStack, buffRate : int;
		var min, max : SAbilityAttributeValue;

		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen05_max_stack', min, max);
			maxStack = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen05_buff_rate', min, max);
			buffRate = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
			abilityCount = thePlayer.GetAbilityCount(abilityName);
			
			if(abilityCount + buffRate < maxStack)
			{
				thePlayer.AddAbilityMultiple(abilityName, buffRate);
			}
			else if(abilityCount < maxStack)
			{
				thePlayer.AddAbilityMultiple(abilityName, maxStack - abilityCount);
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
