@addField(W3Mutagen16_Effect)
var healthPrc : float;

@wrapMethod( W3Mutagen16_Effect ) function UpdateEncumbrance()
{
	if(false)
	{
		wrappedMethod();
	}
}


@wrapMethod( W3Mutagen16_Effect ) function OnEffectAddedPost()
{
	if(false)
	{
		wrappedMethod();
	}

	return true;
}

@wrapMethod( W3Mutagen16_Effect ) function OnEffectRemoved()
{	
	if(false)
	{
		wrappedMethod();
	}

	return true;
}	

@addMethod( W3Mutagen16_Effect ) function Mutagen16ModifyHitAnim(out action : W3DamageAction)
{
	if(action.IsDoTDamage())
		return;

	if(healthPrc <= 0)
	{
		healthPrc = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Mutagen16Effect', 'mutagen16_health_prc'));
	}
	
	if(action.GetDamageDealt() <= healthPrc * target.GetMaxHealth())
	{
		action.SetHitAnimationPlayType(EAHA_ForceNo);
	}
}
