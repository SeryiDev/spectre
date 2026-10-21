/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/




class W3Potion_WhiteHoney extends CBaseGameplayEffect
{
	default effectType = EET_WhiteHoney;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		CleanupToxicity();
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		CleanupToxicity();
	}
	
	function CleanupToxicity()
	{
		target.ForceSetStat(BCS_Toxicity, 0);
			
		thePlayer.RemoveAllPotionEffects();
	}
}
