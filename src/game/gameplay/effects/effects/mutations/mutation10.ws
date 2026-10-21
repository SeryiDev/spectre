/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Mutation10 extends CBaseGameplayEffect
{
	private var drainFactor : float;

	default effectType = EET_Mutation10;
	default isPositive = true;
	
	event OnEffectAddedPost()
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAddedPost();

		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation10Effect', 'mutation10_factor', min, max);
		drainFactor = min.valueMultiplicative;
		
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		thePlayer.PlayEffect( 'mutation_10' );
		thePlayer.PlayEffect( 'critical_toxicity' );
		thePlayer.AddTimer( 'Mutation10StopEffect', 5.f );
	}
	
	event OnEffectRemoved()
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
		
		super.OnEffectRemoved();
	}
	
	public function GetStacks() : int
	{
		return RoundMath( GetWitcherPlayer().GetToxicityDamage() ); //modSpectre
	}
	
	public function GetDrainMult() : float
	{
		return 1 + drainFactor * thePlayer.GetStat(BCS_Toxicity)/100.0;
	}
}
