/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen12_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen12;
	
	var additionalAbilityName : name; default additionalAbilityName = 'TrollBonusEffect';
	
	public function ManageAdditionalBonus()
	{
		var min, max : SAbilityAttributeValue;
		var threshold : float;
		
		if(target == thePlayer && thePlayer.IsInCombat())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'm12_threshold', min, max);
			threshold = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			if(thePlayer.GetStatPercents(BCS_Stamina) <= threshold && !thePlayer.HasAbility(additionalAbilityName))
			{
				thePlayer.AddAbility(additionalAbilityName);
			}
			else if(thePlayer.HasAbility(additionalAbilityName))
			{
				thePlayer.RemoveAbilityAll(additionalAbilityName);
			}
		}
		else if(thePlayer.HasAbility(additionalAbilityName))
		{
			thePlayer.RemoveAbilityAll(additionalAbilityName);
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(additionalAbilityName);
	}
}
