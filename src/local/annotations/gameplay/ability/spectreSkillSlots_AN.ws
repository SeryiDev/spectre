// Spectre: skill slot rules, kept apart from the rest of the ability manager.
//
// The slots open as in 5.01 (total skill points for the 12 mutagen slots, researched mutations for the
// 4 middle ones). The option "All skill slots open from the start" (spectreSkillTreeOptions /
// spectreAllSlotsUnlocked) opens all of them at once, as in Spectre v0.93. None of this depends on
// which skill tree is in use.

// Skill slots open as in 5.01: the 12 mutagen-linked slots with total skill points (0, 2, 4 ... 30),
// the 4 middle ones with researched mutations. With "All skill slots open from the start" they all
// open at once, as in Spectre v0.93.
// A save keeps the unlock level each slot had, so read it again from the XML.
@addMethod(W3PlayerAbilityManager) function SpectreRefreshSlotUnlockLevels()
{
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var id, lvl, i, j : int;
	var allOpen : bool;

	allOpen = SpectreAllSlotsUnlocked();
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition( 'skill_slots' );
	for( i=0; i<main.subNodes.Size(); i+=1 )
	{
		if( !dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'id', id ) )
			continue;
		if( !dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'unlockedOnLevel', lvl ) )
			lvl = 0;
		for( j=0; j<skillSlots.Size(); j+=1 )
		{
			if( skillSlots[ j ].id != id )
				continue;
			if( allOpen && skillSlots[ j ].groupID != MUTATION_SKILL_GROUP_ID )
				skillSlots[ j ].unlockedOnLevel = 0;
			else
				skillSlots[ j ].unlockedOnLevel = lvl;
		}
	}
}

@addMethod(W3PlayerAbilityManager) function SpectreAllSlotsUnlocked() : bool
{
	return spectre_Settings_Main_Bool('spectreSkillTreeOptions', 'spectreAllSlotsUnlocked', false);
}

// Recomputes every slot lock after the slot option changes.
@addMethod(W3PlayerAbilityManager) function SpectreApplySlotOption()
{
	var i, skillPoints : int;

	SpectreDropExtraSlots();
	SpectreRefreshSlotUnlockLevels();
	skillPoints = GetWitcherPlayer().levelManager.GetPointsFree(ESkillPoint)
		+ GetWitcherPlayer().levelManager.GetPointsUsed(ESkillPoint) + GetMutationsUsedSkillPoints();
	for( i=0; i<skillSlots.Size(); i+=1 )
	{
		if( skillSlots[ i ].groupID != MUTATION_SKILL_GROUP_ID )
			skillSlots[ i ].unlocked = ( skillPoints >= skillSlots[ i ].unlockedOnLevel );
	}
	UpdateMutationSkillSlotsLocks();
	SpectreUnequipLockedSlots();
	SpectreRefreshMutagenSlots();
}

// Spectre v0.93 shipped 26 skill slots for Vladimir UI, 10 of them unusable; 5.01 has 16. A save keeps the slots it had, so the ones
// the XML no longer lists are emptied and removed.
@addMethod(W3PlayerAbilityManager) function SpectreDropExtraSlots()
{
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var ids : array<int>;
	var id, i : int;

	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition( 'skill_slots' );
	for( i=0; i<main.subNodes.Size(); i+=1 )
	{
		if( dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'id', id ) )
			ids.PushBack( id );
	}
	if( ids.Size() == 0 )
		return;

	totalSkillSlotsCount = 0;
	for( i=skillSlots.Size()-1; i>=0; i-=1 )
	{
		if( ids.Contains( skillSlots[ i ].id ) )
		{
			totalSkillSlotsCount = Max( totalSkillSlotsCount, skillSlots[ i ].id );
			continue;
		}
		if( skillSlots[ i ].socketedSkill != S_SUndefined )
			SpectreUnequipAnySlot( skillSlots[ i ].id );
		skillSlots.Erase( i );
	}
}

// The four mutagen slots open at 2, 9, 16 and 28 skill points, as in 5.01, or all at once with "Use Spectre's skill
// progression" (IsSkillMutagenSlotUnlocked). A save keeps the level each slot had, so read it again from the XML,
// and a mutagen in a slot that is now locked goes back to the inventory.
@addMethod(W3PlayerAbilityManager) function SpectreRefreshMutagenSlots()
{
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var group, lvl, i, j : int;

	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition( 'mutagen_slots' );
	for( i=0; i<main.subNodes.Size(); i+=1 )
	{
		if( !dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'skillGroup', group ) )
			continue;
		if( !dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'unlockedAtLevel', lvl ) )
			lvl = 0;
		// The menu compares the skill points with this level itself, so the option has to change it.
		if( SpectreAllSlotsUnlocked() )
			lvl = 0;
		for( j=0; j<mutagenSlots.Size(); j+=1 )
		{
			if( mutagenSlots[ j ].skillGroupID == group )
				mutagenSlots[ j ].unlockedAtLevel = lvl;
		}
	}

	for( j=0; j<mutagenSlots.Size(); j+=1 )
	{
		if( owner.GetInventory().IsIdValid( mutagenSlots[ j ].item ) && !IsSkillMutagenSlotUnlocked( mutagenSlots[ j ].equipmentSlot ) )
			GetWitcherPlayer().UnequipItemFromSlot( mutagenSlots[ j ].equipmentSlot );
	}
}

// A save from before can have skills in slots that are now locked.
@addMethod(W3PlayerAbilityManager) function SpectreUnequipLockedSlots()
{
	var i : int;

	for( i=0; i<skillSlots.Size(); i+=1 )
	{
		if( !skillSlots[ i ].unlocked && skillSlots[ i ].socketedSkill != S_SUndefined )
			UnequipSkill( skillSlots[ i ].id );
	}
}

// Whether a skill may go in a slot. The four middle slots only take the colors of the equipped mutation.
// The remaster panel already checks it; the classic panel's border art lets any General skill through.
@addMethod(W3PlayerAbilityManager) function SpectreSkillFitsSlot(skill : ESkill, slotID : int) : bool
{
	var idx : int;
	var mutation : EPlayerMutationType;
	var colors : array<ESkillColor>;

	idx = GetSkillSlotIndex(slotID, false);
	if (idx < 0 || skillSlots[idx].groupID != MUTATION_SKILL_GROUP_ID)
		return true;

	mutation = GetEquippedMutationType();
	if (mutation == EPMT_None)
		return true;

	colors = GetMutationColors(mutation);
	return colors.Contains(GetSkillColor(skill));
}
