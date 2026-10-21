/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/




class W3Potion_Swallow extends W3Potion_VitalityRegen
{
	default effectType = EET_Swallow;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		target.RemoveAllBuffsOfType(EET_Bleeding);
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);

		target.RemoveAllBuffsOfType(EET_Bleeding);
	}
}
