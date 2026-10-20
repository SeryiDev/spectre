// CalculateDuration stays as in 5.01 in wellHydrated.ws so that Script Merger can merge other mods' changes to it.
@replaceMethod(W3Effect_WellHydrated) function CalculateDuration(optional setInitialDuration : bool)
{
	var min, max : SAbilityAttributeValue;
	
	super.CalculateDuration(setInitialDuration);
	
	if( isOnPlayer && GetWitcherPlayer() )
	{
		if( sourceName == "alcohol" && GetWitcherPlayer().CanUseSkill( S_Perk_15 ) )
		{
			min = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_15, 'duration_bonus', false, false );
			duration *= 1 + min.valueMultiplicative;
		}
		
		if( GetWitcherPlayer().HasRunewordActive( 'Runeword 6 _Stats' ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
			duration *= 1 + min.valueMultiplicative;
		}
	}
}

@addMethod(W3Effect_WellHydrated) event OnPerk15Unequipped()
{
	var timeLeftPrc : float;
	
	timeLeftPrc = timeLeft / duration;
	SetTimeLeft( initialDuration * timeLeftPrc );
	duration = initialDuration;
}
