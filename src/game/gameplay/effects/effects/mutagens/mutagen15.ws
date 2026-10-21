/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen15_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen15;
	default dontAddAbilityOnTarget = true;
	
	public function ManageMutagen15Bonus(damageAction : W3DamageAction)
	{
		var attackAction : W3Action_Attack;

		attackAction = (W3Action_Attack)damageAction;
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			if(attackAction && attackAction.attacker == thePlayer && attackAction.DealsAnyDamage() && attackAction.IsActionMelee()
				&& !thePlayer.GetInventory().IsItemFists(attackAction.GetWeaponId()))
			{
				AddMutagen15Ability();
			}
			else if(damageAction.victim == thePlayer && damageAction.DealsAnyDamage()
				&& !(damageAction.IsDoTDamage() && (CBaseGameplayEffect)damageAction.causer))
			{
				RemoveMutagen15Abilities(damageAction.GetDamageDealt());
			}
		}
		else
		{
			RemoveMutagen15AbilitiesAll();
		}
	}
	
	public function RemoveMutagen15AbilitiesAll()
	{
		thePlayer.RemoveAbilityAll(abilityName);
	}
	
	private function RemoveMutagen15Abilities(dmgVal : float)
	{
		var min, max : SAbilityAttributeValue;
		var debuffRate : float;
		var abilityCount, debuffNum : int;
		
		if(dmgVal <= 0)
			return;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen15_debuff_rate', min, max);
		debuffRate = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		debuffNum = RoundMath(debuffRate * dmgVal / thePlayer.GetMaxHealth() * 100);
		abilityCount = thePlayer.GetAbilityCount(abilityName);
		
		if(debuffNum < abilityCount)
			thePlayer.RemoveAbilityMultiple(abilityName, debuffNum);
		else
			thePlayer.RemoveAbilityAll(abilityName);
	}
	
	private function AddMutagen15Ability()
	{
		var abilityCount, maxStack, buffRate : int;
		var min, max : SAbilityAttributeValue;

		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen15_max_stack', min, max);
			maxStack = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen15_buff_rate', min, max);
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
	
	var fgBonus : float; default fgBonus = -1;
	function GetFGBonus() : float
	{
		var min, max : SAbilityAttributeValue;
		
		if(fgBonus < 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'focus_gain', min, max);
			fgBonus = min.valueAdditive;
		}
		return fgBonus;
	}
	
	public final function GetStacks() : int
	{
		return RoundMath( GetFGBonus() * 100 * thePlayer.GetAbilityCount(abilityName) );
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(abilityName);
	}
}
