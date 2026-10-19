/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Mutagen23_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen23;
	default dontAddAbilityOnTarget = true;

	public function AddM23Abilities()
	{
		var mutagenSlots : array<SMutagenSlot>;
		var i : int;
		var item : SItemUniqueId;
		var mutagensCount : int;
		var inv : CInventoryComponent;
		var abilities : array<name>;
		var numAbls : int;
	
		mutagenSlots = GetWitcherPlayer().GetPlayerSkillMutagens();
		inv = GetWitcherPlayer().GetInventory();
		
		for(i = 0; i < mutagenSlots.Size(); i += 1)
		{
			item = mutagenSlots[i].item;
			if(item != GetInvalidUniqueId())
			{
				abilities.Clear();
				inv.GetItemAbilities(item, abilities);
				if(abilities.Contains('greater_mutagen_color_green'))
					mutagensCount += 4;
				else if(abilities.Contains('mutagen_color_green'))
					mutagensCount += 2;
				else if(abilities.Contains('lesser_mutagen_color_green'))
					mutagensCount += 1;
			}
		}
		
		numAbls = target.GetAbilityCount(abilityName);

		if(mutagensCount > numAbls)
		{
			target.AddAbilityMultiple(abilityName, mutagensCount - numAbls);
		}
		else if(mutagensCount < numAbls)
		{
			target.RemoveAbilityMultiple(abilityName, numAbls - mutagensCount);
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		AddM23Abilities();
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(abilityName);
	}
}
