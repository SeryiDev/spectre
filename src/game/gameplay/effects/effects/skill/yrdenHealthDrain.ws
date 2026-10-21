/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Effect_YrdenHealthDrain extends CBaseGameplayEffect
{
	default effectType = EET_YrdenHealthDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	private var dmgBonus : float;
	private var lastPlayedTime : float;
	
	public function SetDmgBonus(b : float)
	{
		dmgBonus = b;
	}
	
	public function GetDmgBonus() : float
	{
		return dmgBonus;
	}
	
	public function PlayFX()
	{
		if(theGame.GetEngineTimeAsSeconds() - lastPlayedTime > 1.f)
		{
			target.PlayEffect('yrden_shock');
			lastPlayedTime = theGame.GetEngineTimeAsSeconds();
		}
	}

	//modSpectre: with the 5.01 tree, Supercharged Glyphs drains health as in 5.01: direct damage per second from
	// effectValue (set by YrdenSlowdown_Loop), cut to 15% against bosses. Spectre's tree uses GetDmgBonus instead.
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		if(spectreVanillaSkills() && (target.HasAbility( 'SkillBoss' ) || target.HasAbility( 'Boss' ) || target.HasAbility('MonsterMHBoss') || target.GetCharacterStats().HasAbilityWithTag('Boss') || (W3MonsterHuntNPC)target || (target.HasTag( 'HideHealthBarModule' ) && !target.HasTag( 'NotBoss' ))) )
		{
			effectValue.valueMultiplicative *= 0.15;
		}
	}

	event OnUpdate(dt : float)
	{
		var dmg, maxHealth : float;

		super.OnUpdate(dt);
		if(!spectreVanillaSkills() || !target.IsAlive())
			return true;

		if(target.UsesEssence())
			maxHealth = target.GetStatMax(BCS_Essence);
		else
			maxHealth = target.GetStatMax(BCS_Vitality);
		dmg = MaxF(0, dt * (effectValue.valueAdditive + effectValue.valueMultiplicative * maxHealth));
		if(dmg > 0)
		{
			effectManager.CacheDamage(theGame.params.DAMAGE_NAME_DIRECT, dmg, GetCreator(), this, dt, true, CPS_Undefined, false);
			PlayFX();
		}
	}
}
