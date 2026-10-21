/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen25_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen25;

	private saved var m25Bonus : float;
	
	public function GetM25Bonus() : float
	{
		return m25Bonus;
	}
	
	public function RecalcM25Bonus()
	{
		var mutagenSlots : array<SMutagenSlot>;
		var i : int;
		var item : SItemUniqueId;
		var mutagensCount : array<int>;
		var inv : CInventoryComponent;
		var abilities : array<name>;
		var abl : SAbilityAttributeValue;
		
		mutagenSlots = GetWitcherPlayer().GetPlayerSkillMutagens();
		inv = GetWitcherPlayer().GetInventory();
		
		mutagensCount.Resize(3);
		m25Bonus = 0;
		
		for(i = 0; i < mutagenSlots.Size(); i += 1)
		{
			item = mutagenSlots[i].item;
			if(item != GetInvalidUniqueId())
			{
				abilities.Clear();
				inv.GetItemAbilities(item, abilities);
				if(abilities.Contains('greater_mutagen_color_red'))
					mutagensCount[2] += 1;
				else if(abilities.Contains('mutagen_color_red'))
					mutagensCount[1] += 1;
				else if(abilities.Contains('lesser_mutagen_color_red'))
					mutagensCount[0] += 1;
			}
		}
		
		abl = thePlayer.GetAbilityAttributeValue(abilityName, 'mutagen25_bonus_lesser');
		m25Bonus += abl.valueAdditive * mutagensCount[0];
		abl = thePlayer.GetAbilityAttributeValue(abilityName, 'mutagen25_bonus_medium');
		m25Bonus += abl.valueAdditive * mutagensCount[1];
		abl = thePlayer.GetAbilityAttributeValue(abilityName, 'mutagen25_bonus_greater');
		m25Bonus += abl.valueAdditive * mutagensCount[2];
		
		m25Bonus = ClampF(m25Bonus, 0, 1);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		RecalcM25Bonus();
	}

	public function GetAttackPowerBonus() : SAbilityAttributeValue
	{
		var min, max : SAbilityAttributeValue;

		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, PowerStatEnumToName(CPS_AttackPower), min, max);
		return GetAttributeRandomizedValue(min, max);
	}
}
