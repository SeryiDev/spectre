/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen21_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen21;

	public final function Heal(cost : float)
	{
		var vitality : float;
		var min, max : SAbilityAttributeValue;
		
		if(!target.IsInCombat())
			return;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'healingRatio', min, max);
		vitality = target.GetStatMax(BCS_Vitality);
		vitality *= CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		vitality *= cost;
		target.GainStat(BCS_Vitality, vitality);
	}
}
