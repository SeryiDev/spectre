/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/


class W3Mutagen02_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen02;
	default dontAddAbilityOnTarget = true;
	
	public function AddDebuffToEnemy(enemy : CActor)
	{
		var abilityCount, maxStack : int;
		var min, max : SAbilityAttributeValue;
		
		if(enemy && enemy != thePlayer)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen02_max_stack', min, max);
			maxStack = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
			abilityCount = enemy.GetAbilityCount(abilityName);
			
			if(abilityCount < maxStack)
				enemy.AddAbility(abilityName, true);
		}
	}
}
