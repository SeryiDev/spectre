class W3Effect_Runeword11 extends CBaseGameplayEffect
{
	default effectType = EET_Runeword11;
	default isPositive = true;
	
	var bonusAdrenaline : float;
	var rate : float;
	var maxBonus : float;
	
	event OnEffectAdded(customParams : W3BuffCustomParams)
	{
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 11 _Stats', 'duration_gain_rate', min, max);
		rate = max.valueMultiplicative;

		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 11 _Stats', 'max_bonus', min, max);
		maxBonus = max.valueMultiplicative;

		super.OnEffectAdded(customParams);
	}
	
	public function IncBonusAdrenaline(delta : float)
	{
		bonusAdrenaline += delta * rate;
		bonusAdrenaline = MinF(bonusAdrenaline, thePlayer.GetStatMax(BCS_Focus) * maxBonus);
	}
	
	public function GetBonusAdrenaline() : float
	{
		bonusAdrenaline = MinF(bonusAdrenaline, thePlayer.GetStatMax(BCS_Focus) * maxBonus);
		return bonusAdrenaline;
	}
	
	public function GetExpirationBonus() : float
	{
		return GetBonusAdrenaline()/thePlayer.GetStatMax(BCS_Focus);
	}
	
	public function GetStacks() : int
	{
		return RoundMath(GetExpirationBonus() * 100);
	}
	
	public function GetMaxStacks() : int
	{
		return 100;
	}
}
