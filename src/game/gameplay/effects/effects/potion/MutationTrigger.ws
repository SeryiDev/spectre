class W3Potion_MutationTrigger extends CBaseGameplayEffect
{
	default effectType = EET_MutationTrigger;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var witcher : W3PlayerWitcher;
		
		super.OnEffectAdded(customParams);
		
		if(!isOnPlayer)
		{
			timeLeft = 0;
			return false;
		}
		
		witcher = ((W3PlayerWitcher)target);
		
		if( witcher.IsSwimming() || witcher.IsDiving() || witcher.IsSailing() || witcher.IsUsingHorse() || witcher.IsUsingBoat() || witcher.IsUsingVehicle() || witcher.IsUsingExploration() )
		{
			timeLeft = 0;
			return false;
		}
		else
		{
			if( witcher.IsInCombat() && witcher.IsMutationActive( EPMT_Mutation11 ) && !witcher.HasBuff( EET_Mutation11Debuff ) && !witcher.IsInAir() )
			{
				witcher.OnMutation11Triggered();
			}
			else
			{
				timeLeft = 0;
				return false;
			}
		}
	}
}
