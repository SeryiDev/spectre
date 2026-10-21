/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/




class W3Potion_WhiteRaffardDecoction extends CBaseGameplayEffect
{
	default effectType = EET_WhiteRaffardDecoction;
	
	default dontAddAbilityOnTarget = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		AddVitality();
		
		if(GetBuffLevel() == 3)
		{
			target.SetImmortalityMode(AIM_Invulnerable, AIC_WhiteRaffardsPotion);
		}
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		AddVitality();
	}
	
	function AddVitality()
	{
		var vitality : float;
		var vitAtt, min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, StatEnumToName(BCS_Vitality), min, max);
		vitAtt = GetAttributeRandomizedValue(min, max);
		vitality = target.GetStatMax(BCS_Vitality) * vitAtt.valueMultiplicative + vitAtt.valueAdditive;
		target.GainStat(BCS_Vitality, vitality);
		target.RemoveAllBuffsOfType(EET_Bleeding);
		target.RemoveAllBuffsOfType(EET_Bleeding1);
		target.RemoveAllBuffsOfType(EET_Bleeding2);
		target.RemoveAllBuffsOfType(EET_Bleeding3);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		if(GetBuffLevel() == 3)
		{
			target.SetImmortalityMode(AIM_None, AIC_WhiteRaffardsPotion);
		}
	}
		
}
