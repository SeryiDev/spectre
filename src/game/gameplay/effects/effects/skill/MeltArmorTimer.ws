class W3Effect_MeltArmorTimer extends CBaseGameplayEffect
{
	default effectType = EET_MeltArmorTimer;
	default isPositive = true;
	default dontAddAbilityOnTarget = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		if(target != GetWitcherPlayer())
		{
			isActive = false;
			return false;
		}
		super.OnEffectAdded(customParams);
	}
	
	protected function GetSelfInteraction(e : CBaseGameplayEffect) : EEffectInteract
	{
		return EI_Cumulate;
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		timeLeft = effect.timeLeft;
		duration = effect.duration;
	}
}
