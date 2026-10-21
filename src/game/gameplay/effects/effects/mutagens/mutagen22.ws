/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen22_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen22;
	default dontAddAbilityOnTarget = true;
	
	public function AddMutagen22Ability()
	{
		var abilityCount, maxStack, buffRate : int;
		var min, max : SAbilityAttributeValue;
		
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen22_max_stack', min, max);
			maxStack = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen22_buff_rate', min, max);
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
	
	public function RemoveMutagen22Abilities(damageAction : W3DamageAction)
	{
		var attackAction : W3Action_Attack;
		var min, max : SAbilityAttributeValue;
		var dmgVal, debuffRate : float;
		var abilityCount, debuffNum : int;

		attackAction = (W3Action_Attack)damageAction;
		
		if(target != thePlayer || !thePlayer.IsInCombat() || !thePlayer.IsThreatened())
		{
			RemoveMutagen22AbilitiesAll();
			return;
		}
		
		if(!damageAction || damageAction.victim != thePlayer || !damageAction.DealsAnyDamage()
			|| (damageAction.IsDoTDamage() && (CBaseGameplayEffect)damageAction.causer))
		{
			return;
		}
		
		dmgVal = damageAction.GetDamageDealt();
		
		if(dmgVal <= 0)
			return;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen22_debuff_rate', min, max);
		debuffRate = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		debuffNum = RoundMath(debuffRate * dmgVal / thePlayer.GetMaxHealth() * 100);
		abilityCount = thePlayer.GetAbilityCount(abilityName);
		
		if(debuffNum < abilityCount)
			thePlayer.RemoveAbilityMultiple(abilityName, debuffNum);
		else
			thePlayer.RemoveAbilityAll(abilityName);
	}
	
	public function RemoveMutagen22AbilitiesAll()
	{
		thePlayer.RemoveAbilityAll(abilityName);
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
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(abilityName);
	}
}
