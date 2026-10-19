class W3Effect_MeltArmorDebuff extends CBaseGameplayEffect
{
	default effectType = EET_MeltArmorDebuff;
	default isNegative = true;
	default dontAddAbilityOnTarget = true;
	
	function RemoveAbilities()
	{
		target.RemoveAbilityAll(abilityName);
		thePlayer.RemoveAllBuffsOfType(EET_MeltArmorTimer);
	}
	
	function AddAbilities()
	{
		var creatorSkillLevel : int;
		var debuffRate : int;
		var dt : float;

		debuffRate = thePlayer.GetSkillLevel(S_Magic_s08) * RoundMath(1 + 7.0*SignPowerStatToPowerBonus(creatorPowerStat.valueMultiplicative));

		if(debuffRate > 0)
		{
			target.AddAbilityMultiple(abilityName, debuffRate);
			thePlayer.AddEffectDefault(EET_MeltArmorTimer, NULL, "");
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		RemoveAbilities();
	}
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		if(GetCreator() != GetWitcherPlayer())
		{
			isActive = false;
			return false;
		}
		
		super.OnEffectAdded(customParams);
		AddAbilities();
	}
	
	protected function GetSelfInteraction(e : CBaseGameplayEffect) : EEffectInteract
	{
		return EI_Cumulate;
	}
}
