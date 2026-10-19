// Spectre: equipment level options (group spectreEquipmentOptions, "Equipment").
//
//   spectreEquipAnyLevel     Gear of any level can be equipped (default on). Off: as in the base game, gear above
//                            Geralt's level cannot be equipped, and tooltips show the level it needs. Turning it
//                            off unequips the gear above his level.
//   spectreLevelUpEquipped   Equipped weapons and armor rise to Geralt's level when equipped and when he levels up
//                            (default on). Gear that already rose keeps its level when it is turned off.

function spectreEquipAnyLevel() : bool
{
	return spectre_Settings_Main_Bool('spectreEquipmentOptions', 'spectreEquipAnyLevel', true);
}

function spectreLevelUpEquippedOn() : bool
{
	return spectre_Settings_Main_Bool('spectreEquipmentOptions', 'spectreLevelUpEquipped', true);
}

// Value of spectreEquipAnyLevel last applied by spectreApplyEquipmentOptions.
@addField(CR4Player)
var spectreEquipOptionsApplied : bool;
@addField(CR4Player)
var spectreAppliedEquipAnyLevel : bool;

@addMethod(CR4Player) function SpectreEquipmentOptionsChanged() : bool
{
	return !spectreEquipOptionsApplied || spectreAppliedEquipAnyLevel != spectreEquipAnyLevel();
}

// Runs when the game menu closes (spectreWatcher). Turning "any level" off unequips the gear above Geralt's level.
@addMethod(CR4Player) function SpectreApplyEquipmentOptions()
{
	var witcher : W3PlayerWitcher;
	var slots : array<EEquipmentSlots>;
	var item : SItemUniqueId;
	var i : int;

	spectreEquipOptionsApplied = true;
	spectreAppliedEquipAnyLevel = spectreEquipAnyLevel();
	witcher = (W3PlayerWitcher)this;
	if (!witcher || spectreAppliedEquipAnyLevel)
		return;

	slots.PushBack(EES_SteelSword);
	slots.PushBack(EES_SilverSword);
	slots.PushBack(EES_Armor);
	slots.PushBack(EES_Gloves);
	slots.PushBack(EES_Pants);
	slots.PushBack(EES_Boots);
	slots.PushBack(EES_RangedWeapon);
	for (i = 0; i < slots.Size(); i += 1)
	{
		if (witcher.inv.GetItemEquippedOnSlot(slots[i], item) && !witcher.HasRequiredLevelToEquipItem(item))
			witcher.UnequipItemFromSlot(slots[i]);
	}
}
