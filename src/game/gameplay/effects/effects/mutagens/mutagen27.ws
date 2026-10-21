/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/

class W3Mutagen27_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen27;

	protected var isMutagenEffectActive : bool;
	protected var bonusTimeLeft : float;
	protected var bonusDuration : float;
	protected var dmgWindow : float;
	protected var cachedNumHits : float;
	protected var cachedTime : float;
	
	public function ResetAccumulatedHits()
	{
		cachedNumHits = 0;
		cachedTime = 0;
	}
	
	public function AccumulateHits()
	{
		if(IsBonusActive())
			return;
		
		cachedNumHits += 1;
		
		if(cachedNumHits == 1)
		{
			cachedTime = theGame.GetEngineTimeAsSeconds();
			return;
		}

		if(dmgWindow <= 0)
		{
			dmgWindow = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Mutagen27Effect', 'mutagen27_dmg_window'));
		}
		
		if(theGame.GetEngineTimeAsSeconds() - cachedTime <= dmgWindow)
		{
			SetMutagenEffectActive(true);
			return;
		}
		
		cachedNumHits = 1;
		cachedTime = theGame.GetEngineTimeAsSeconds();
	}
	
	function SetMutagenEffectActive(a : bool)
	{
		isMutagenEffectActive = a;
		if(isMutagenEffectActive)
		{
			if(bonusDuration <= 0)
			{
				bonusDuration = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Mutagen27Effect', 'mutagen27_bonus_duration'));
			}
			bonusTimeLeft = bonusDuration;
			thePlayer.PlayEffect( 'power' ); 
		}
		else
		{
			ResetAccumulatedHits();
		}
	}
	
	public function IsBonusActive() : bool
	{
		return isMutagenEffectActive;
	}
	
	public function OnTimeUpdated(dt : float)
	{
		super.OnTimeUpdated(dt);
		
		if(IsBonusActive())
		{
			bonusTimeLeft -= dt;
			if(bonusTimeLeft <= 0)
			{
				SetMutagenEffectActive(false);
			}
		}
	}
	
	public function ReduceDamage(out damageData : W3DamageAction)
	{
		if(IsBonusActive())
		{
			damageData.SetAllProcessedDamageAs(0);
			damageData.SetWasDodged();
			thePlayer.PlayEffect( 'power_place_quen' );
			thePlayer.SoundEvent("sign_quen_discharge_short");
		}
	}
}
