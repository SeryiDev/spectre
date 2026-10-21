/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen19_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen19;

	public function ProtectiveQuen(action : W3DamageAction)
	{
		var attackAction : W3Action_Attack;
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		if(action.attacker == witcher)
			return;
		
		if(action.victim != witcher)
			return;
		
		if(witcher.IsAnyQuenActive())
			return;
		
		if(!witcher.IsAttackerAtBack(action.attacker))
			return;
		
		if(action.IsDoTDamage() && (CBaseGameplayEffect)action.causer)
			return;
		
		if(action.WasDodged())
			return;
		
		attackAction = (W3Action_Attack)action;
		if(attackAction && attackAction.CanBeParried() && (attackAction.IsParried() || attackAction.IsCountered()))
			return;
		
		witcher.CastFreeQuen();
	}

	public function GetQuenPowerBonus() : SAbilityAttributeValue
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var min, max : SAbilityAttributeValue;
		var enemies : array<CActor>;
		var i : int;
		var nullAttr : SAbilityAttributeValue;
		
		if(target != witcher)
			return nullAttr;
		
		enemies = witcher.GetHostileEnemies();
		for(i = 0; i < enemies.Size(); i += 1)
		{
			if(enemies[i].spectreIsSpecter())
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'quen_power_bonus', min, max);
				return GetAttributeRandomizedValue(min, max);
			}
		}
		
		return nullAttr;
	}
}
