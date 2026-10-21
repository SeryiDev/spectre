@wrapMethod(W3Effect_Burning) function OnUpdate(deltaTime : float)
{
	var player : CR4Player = thePlayer;	
	var i : int;
	var range : float;
	var actor : CActor;
	var ents : array<CGameplayEntity>;
	var min, max : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(deltaTime);
	}

	if ( this.isOnPlayer )
	{
		if ( player.bLAxisReleased )
			player.SetOrientationTargetCustomHeading( player.GetHeading(), 'BurningEffect' );
		else if ( player.GetPlayerCombatStance() == PCS_AlertNear )
			player.SetOrientationTargetCustomHeading( VecHeading( player.moveTarget.GetWorldPosition() - player.GetWorldPosition() ), 'BurningEffect' );
		else
			player.SetOrientationTargetCustomHeading( VecHeading( theCamera.GetCameraDirection() ), 'BurningEffect' );
	}
	
	else if(isWithGlyphword12)
	{
		glyphword12Delay += deltaTime;
		
		if(glyphword12Delay <= CalculateAttributeValue(player.GetAttributeValue('glyphword12_burning_delay')) )
		{
			range = CalculateAttributeValue(player.GetAttributeValue('glyphword12_range'));
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 12 _Stats', 'duration', min, max);
			FindGameplayEntitiesInCylinder(ents, target.GetWorldPosition(), range, 2.f, 10,,FLAG_OnlyAliveActors + FLAG_ExcludePlayer + FLAG_ExcludeTarget, target);

			for(i=0; i<ents.Size(); i+=1)
			{
				actor = (CActor)ents[i];
				
				if(glyphword12NotBurnedEntities.Contains(ents[i]))
					continue;
				
				
				glyphword12NotBurnedEntities.PushBack(ents[i]);
				if(!IsRequiredAttitudeBetween(thePlayer, actor, true, false, false) || (RandF() < glyphword12BurningChance) || actor.HasBuff(EET_Burning))
				{
					continue;
				}
				
				actor.AddEffectDefault(EET_Burning, thePlayer, 'glyphword 12');
			}
			
			glyphword12Delay = 0.f;
		}
	}

	
	// 5.01 turns every hit reaction off at the start and turns them back on, except Igni, halfway through.
	if(!this.IsOnPlayer() && duration * 0.5 <= duration - timeLeft)
	{
		for(i=0; i<allowedHits.Size(); i+=1)
			allowedHits[i] = true;

		allowedHits[EHRT_Igni] = false;
	}

	if(cachedMPAC && cachedMPAC.GetSubmergeDepth() <= -1)
		target.RemoveAllBuffsOfType(effectType);
	else
		super.OnUpdate(deltaTime);
}
