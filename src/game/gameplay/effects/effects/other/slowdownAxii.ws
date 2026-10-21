/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_SlowdownAxii extends CBaseGameplayEffect //modSpectre
{
	default effectType = EET_SlowdownAxii;

	private saved var slowdownCauserId : int;
	
	default attributeName = 'slowdown';
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		slowdownCauserId = target.SetAnimationSpeedMultiplier( 1 - ClampF(effectValue.valueAdditive, 0.0, 0.999) );
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();		
		target.ResetAnimationSpeedMultiplier(slowdownCauserId);
	}
}
