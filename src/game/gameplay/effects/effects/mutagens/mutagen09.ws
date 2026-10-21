/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Mutagen09_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen09;

	private saved var m09Bonus : float;
	
	public function GetM09Bonus() : float
	{
		return m09Bonus;
	}
	
	public function RecalcM09Bonus()
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
		m09Bonus = 0;
		
		for(i = 0; i < mutagenSlots.Size(); i += 1)
		{
			item = mutagenSlots[i].item;
			if(item != GetInvalidUniqueId())
			{
				abilities.Clear();
				inv.GetItemAbilities(item, abilities);
				if(abilities.Contains('greater_mutagen_color_blue'))
					mutagensCount[2] += 1;
				else if(abilities.Contains('mutagen_color_blue'))
					mutagensCount[1] += 1;
				else if(abilities.Contains('lesser_mutagen_color_blue'))
					mutagensCount[0] += 1;
			}
		}
		
		abl = thePlayer.GetAbilityAttributeValue(abilityName, 'mutagen09_bonus_lesser');
		m09Bonus += abl.valueAdditive * mutagensCount[0];
		m09Bonus += abl.valueAdditive * mutagensCount[1];
		abl = thePlayer.GetAbilityAttributeValue(abilityName, 'mutagen09_bonus_greater');
		m09Bonus += abl.valueAdditive * mutagensCount[2];
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		RecalcM09Bonus();
	}
}
