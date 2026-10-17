class W3Effect_Runeword4 extends CBaseGameplayEffect
{
	default effectType = EET_Runeword4;
	default isPositive = true;
	
	var overhealBonus : float;
	var rate : float;
	var maxBonus : float;
	
	event OnEffectAdded(customParams : W3BuffCustomParams)
	{
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 4 _Stats', 'dmg_gain_rate', min, max);
		rate = max.valueMultiplicative;

		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 4 _Stats', 'max_bonus', min, max);
		maxBonus = max.valueMultiplicative;

		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		thePlayer.StopEffect('runeword_4');
		super.OnEffectRemoved();
	}
	
	public function IncOverhealBonus(hp : float)
	{
		overhealBonus += hp * rate;
		PlayRuneword4FX();
	}
	
	public function GetOverhealBonus() : float
	{
		PlayRuneword4FX();
		return overhealBonus;
	}
	
	public function GetDamageBonus() : float
	{
		return GetOverhealBonus()/thePlayer.GetStatMax(BCS_Vitality);
	}
	
	public function PlayRuneword4FX()
	{
		overhealBonus = MinF(overhealBonus, thePlayer.GetStatMax(BCS_Vitality) * maxBonus);
		if(!thePlayer.IsEffectActive('runeword_4', true))
			thePlayer.PlayEffect('runeword_4');
	}
	
	public function GetStacks() : int
	{
		return RoundMath(GetDamageBonus() * 100);
	}
	
	public function GetMaxStacks() : int
	{
		return 100;
	}
}
