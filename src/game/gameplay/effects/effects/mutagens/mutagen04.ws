/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen04_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen04;
	var healthRed : float;
	var costInc : float;
	
	public function GetHealthReductionPrc(cost : float) : float
	{
		var min, max : SAbilityAttributeValue;
		
		if(healthRed <= 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'healthReductionPerc', min, max);
			healthRed = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		}
		return cost * healthRed;
	}
	
	public function GetAttackCostIncrease() : float
	{
		var min, max : SAbilityAttributeValue;
		
		if(costInc <= 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'attackCostIncrease', min, max);
			costInc = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		}
		return costInc;
	}
}
