/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Potion_GoldenOriole extends CBaseGameplayEffect
{
	default effectType = EET_GoldenOriole;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		HandlePoisonStatus();
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		
		HandlePoisonStatus();
	}
	
	function HandlePoisonStatus()
	{
		var min, max : SAbilityAttributeValue;
		
		target.RemoveAllBuffsOfType(EET_Poison);
		target.RemoveAllBuffsOfType(EET_PoisonCritical);
		if(GetBuffLevel() == 3)
		{
			target.AddBuffImmunity(EET_Poison, 'GoldenOrioleTempPoisonImmunity', true);
			target.AddBuffImmunity(EET_PoisonCritical, 'GoldenOrioleTempPoisonImmunity', true);
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'poison_immunity_duration', min, max);
			target.AddTimer('RemoveGoldenOriolePoisonImmunity', min.valueAdditive, false, false, , true, true);
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveBuffImmunity(EET_Poison, 'GoldenOrioleTempPoisonImmunity');
		target.RemoveBuffImmunity(EET_PoisonCritical, 'GoldenOrioleTempPoisonImmunity');
	}
	
	
	
	
	
	protected function GetEffectStrength() : float
	{		
		var i : int;
		var val, tmp : SAbilityAttributeValue;
		var ret : float;
		var isPoint : bool;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
		
		dm.GetAbilityAttributes(abilityName, atts);
		
		
		for(i=0; i<atts.Size(); i+=1)
		{
			if(IsNonPhysicalResistStat(ResistStatNameToEnum(atts[i], isPoint)))
			{
				dm.GetAbilityAttributeValue(abilityName, atts[i], val, tmp);
				
				if(isPoint)
					ret += CalculateAttributeValue(val);
				else
					ret += 100 * CalculateAttributeValue(val);
			}
		}

		return ret;
	}
}
