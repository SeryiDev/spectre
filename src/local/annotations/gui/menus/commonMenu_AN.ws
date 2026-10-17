@wrapMethod(CR4CommonMenu) function OnHotkeyTriggered(keyCode:EInputKey)
{	
	var outRSKeys   : array< EInputKey >;

	theInput.GetCurrentKeysForAction('CameraLock', outRSKeys);

	if (outRSKeys.Contains(keyCode) && ((CR4CharacterMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild()))
 	{
		if(!(((W3PlayerAbilityManager)GetWitcherPlayer().abilityManager ).spectreResetSkill))
 		{
			((W3PlayerAbilityManager)GetWitcherPlayer().abilityManager ).spectreResetSkill(true);

			theSound.SoundEvent( "gui_inventory_potion_attach" );
		}
		else
		{
			((W3PlayerAbilityManager)GetWitcherPlayer().abilityManager ).spectreResetSkill(false);

			theSound.SoundEvent( "gui_inventory_boots_back" );
 		}
 	}

	wrappedMethod(keyCode);
}
