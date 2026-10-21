/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Effect_AxiiGuardMe extends CBaseGameplayEffect
{
	private var drainStaminaOnExit : bool;

	default effectType = EET_AxiiGuardMe;
	default resistStat = CDS_WillRes;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default drainStaminaOnExit = false;
	
	private saved var glyphwordAblAdded : bool; //modSpectre
	
	private function AddGlyphwordBonuses() //modSpectre
	{
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var min, max : SAbilityAttributeValue;
		var count, maxStacks : float;
		
		if(!isOnPlayer && GetCreator() == thePlayer && isSignEffect)
		{
			dm.GetAbilityAttributeValue('Glyphword 10 abl', 'g10_max_stacks', min, max);
			maxStacks = CalculateAttributeValue(min);
			count = thePlayer.GetAbilityCount('Glyphword 10 abl');
			if(count < maxStacks)
			{
				thePlayer.AddAbility('Glyphword 10 abl', true);
				glyphwordAblAdded = true;
			}
		}
	}
	
	private function RemoveGlyphwordBonuses() //modSpectre
	{
		if(glyphwordAblAdded)
			thePlayer.RemoveAbility('Glyphword 10 abl');
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var npc : CNewNPC;
		var bonusAbilityName : name;
		var skillLevel, i : int;
		
		super.OnEffectAdded(customParams);
		
		AddGlyphwordBonuses(); //modSpectre
		
		npc = (CNewNPC)target;
		
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		
		
		if ( npc.HasAttitudeTowards( thePlayer ) && npc.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			npc.ResetAttitude( thePlayer );
		}
		
		if ( npc.HasTag('animal') || npc.IsHorse() )
		{
			npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
		}
		else
		{
			npc.SetTemporaryAttitudeGroup('npc_charmed', AGP_Axii);
		}
		
		npc.SignalGameplayEvent('AxiiGuardMeAdded');
		npc.SignalGameplayEvent('NoticedObjectReevaluation');
		
		
		skillLevel = GetWitcherPlayer().GetSkillLevel(S_Magic_s05);
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
		for(i=0; i<skillLevel; i+=1)
			target.AddAbility(bonusAbilityName, true);

		
		skillLevel = thePlayer.GetSkillLevel( S_Magic_s31 );
		bonusAbilityName = thePlayer.GetSkillAbilityName( S_Magic_s31 );
		target.AddAbilityMultiple( bonusAbilityName, skillLevel );
			
		if (npc.IsHorse())
			npc.GetHorseComponent().ResetPanic();
	}
	
	event OnEffectRemoved()
	{
		var npc : CNewNPC;
		var bonusAbilityName : name;
		
		super.OnEffectRemoved();
		
		RemoveGlyphwordBonuses(); //modSpectre
		
		npc = (CNewNPC)target;		
		if(npc)
		{
			npc.ResetTemporaryAttitudeGroup(AGP_Axii);
			npc.SignalGameplayEvent('NoticedObjectReevaluation');
			((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		}
		
		if(drainStaminaOnExit)
		{
			target.DrainStamina(ESAT_FixedValue, target.GetStat(BCS_Stamina));
		}
		
		
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);		
		while(target.HasAbility(bonusAbilityName))
			target.RemoveAbility(bonusAbilityName);

		bonusAbilityName = thePlayer.GetSkillAbilityName( S_Magic_s31 );
		target.RemoveAbilityAll( bonusAbilityName );
	}
	
	public function SetDrainStaminaOnExit()
	{
		drainStaminaOnExit = true;
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		if ( duration > 0 )
		{
			if (FactsQuerySum("used_red_haze_3") > 0)
				duration = MaxF(duration, 12.f);
			else if (FactsQuerySum("used_red_haze_2") > 0)
				duration = MaxF(duration, 10.f);
			else if (FactsQuerySum("used_red_haze") > 0)
				duration = MaxF(duration, 8.f);
			else
				duration = MaxF(8.f, duration); //modSpectre
		}
	}
}
