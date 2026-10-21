@wrapMethod(CPlayerInput) function OnSelectSign(action : SInputAction)
{
	if(false) 
	{
		wrappedMethod(action);
	}
	
	if( IsPressed( action ) )
	{
		
		if(altSignCasting)
		{
			switch( action.aName )
			{				
				case 'SelectAard' :
					AltCastSign(ST_Aard);
					break;
				case 'SelectYrden' :
					AltCastSign(ST_Yrden);
					break;
				case 'SelectIgni' :
					AltCastSign(ST_Igni);
					break;
				case 'SelectQuen' :
					AltCastSign(ST_Quen);
					break;
				case 'SelectAxii' :
					AltCastSign(ST_Axii);
					break;
				default :
					break;
			}
		}
		
		else
		{
			switch( action.aName )
			{
				case 'SelectAard' :
					GetWitcherPlayer().SetEquippedSign(ST_Aard);
					break;
				case 'SelectYrden' :
					GetWitcherPlayer().SetEquippedSign(ST_Yrden);
					break;
				case 'SelectIgni' :
					GetWitcherPlayer().SetEquippedSign(ST_Igni);
					break;
				case 'SelectQuen' :
					GetWitcherPlayer().SetEquippedSign(ST_Quen);
					break;
				case 'SelectAxii' :
					GetWitcherPlayer().SetEquippedSign(ST_Axii);
					break;
				default :
					break;
			}

			if( spectreSignInstantCastOn() )
			{
				thePlayer.SetCastSignHoldTimestamp( theGame.GetEngineTimeAsSeconds() );
				return CastSign();
			}
		}
	}
	
	else if (IsReleased( action ) && altSignCasting && GetWitcherPlayer().IsCurrentSignChanneled())
	{
		thePlayer.AbortSign();
	}
	
}

@wrapMethod(CPlayerInput) function OnCbtSpecialAttackLight( action : SInputAction )
{
	if(false) 
	{
		wrappedMethod(action);
	}
	
	if(!theInput.LastUsedPCInput() && IsPressed( action ) && theInput.GetActionValue( 'CastSign' ) > 0)
	{
		return false;
	}
	

	if ( IsReleased( action )  )
	{
		thePlayer.CancelHoldAttacks();
		return true;
	}
	if(thePlayer.HasBuff(EET_WhirlCooldown))
	{
		thePlayer.SoundEvent("gui_no_adrenaline");
		return false;
	}
	
	if ( !IsPlayerAbleToPerformSpecialAttack() )
		return false;
	
	if( !IsActionAllowed(EIAB_LightAttacks) ) 
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_LightAttacks);
		return false;
	}
	if(!IsActionAllowed(EIAB_SpecialAttackLight) )
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_SpecialAttackLight);
		return false;
	}
	
	if( IsPressed(action) && (thePlayer.CanUseSkill(S_Sword_s01) || thePlayer.CanUseSkill(S_Sword_s35)) )	
	{			
		thePlayer.PrepareToAttack();
		thePlayer.SetPlayedSpecialAttackMissingResourceSound(false);
		thePlayer.AddTimer( 'IsSpecialLightAttackInputHeld', 0.00001, true );
	}
}

@wrapMethod(CPlayerInput) function OnCbtSpecialAttackHeavy( action : SInputAction )
{
	if(false) 
	{
		wrappedMethod(action);
	}
	
	if(!theInput.LastUsedPCInput() && IsPressed( action ) && theInput.GetActionValue( 'CastSign' ) > 0)
	{
		return false;
	}
	

	if ( IsReleased( action )  )
	{
		thePlayer.CancelHoldAttacks();
		return true;
	}
	
	if(thePlayer.HasBuff(EET_RendCooldown))
	{
		thePlayer.SoundEvent("gui_no_adrenaline");
		return false;
	}
	
	if ( !IsPlayerAbleToPerformSpecialAttack() || GetWitcherPlayer().IsInCombatAction_SpecialAttackHeavy() ) 
		return false;
	
	if( !IsActionAllowed(EIAB_HeavyAttacks))
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_HeavyAttacks);
		return false;
	}		
	if(!IsActionAllowed(EIAB_SpecialAttackHeavy))
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_SpecialAttackHeavy);
		return false;
	}
	
	if( IsPressed(action) && thePlayer.CanUseSkill(S_Sword_s02) )	
	{	
		thePlayer.PrepareToAttack();
		thePlayer.SetPlayedSpecialAttackMissingResourceSound(false);
		thePlayer.AddTimer( 'IsSpecialHeavyAttackInputHeld', 0.00001, true );
	}
	else if ( IsPressed(action) )
	{
		if ( theInput.IsActionPressed('AttackHeavy') )
			theInput.ForceDeactivateAction('AttackHeavy');
		else if ( theInput.IsActionPressed('AttackWithAlternateHeavy') )
			theInput.ForceDeactivateAction('AttackWithAlternateHeavy');
	}
}

@wrapMethod(CPlayerInput) function AltCastSign(signType : ESignType)
{
	var signSkill : ESkill;	
	
	if(false) 
	{
		wrappedMethod(signType);
	}
	
	if( !thePlayer.GetBIsInputAllowed() )
	{	
		return;
	}

	if( !IsActionAllowed(EIAB_Signs) || GetWitcherPlayer().IsSignBlocked(signType) )
	{				
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs);
		return;
	}
	if ( thePlayer.IsHoldingItemInLHand() && thePlayer.IsUsableItemLBlocked() )
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, false, false, true);
		return;
	}
	if( !IsActionAllowed(EIAB_NonPatternAlternatives))
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_NonPatternAlternatives, false, false, true);
		return;
	}

	signSkill = SignEnumToSkillEnum(signType);
	if( signSkill != S_SUndefined )
	{
		if(!thePlayer.CanUseSkill(signSkill))
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs, false, false, true);
			return;
		}
	
		if( thePlayer.HasStaminaToUseSkill( signSkill, false ) )
		{
			GetWitcherPlayer().SetEquippedSign(signType);	

			if(IsSignOnCooldown(thePlayer.GetEquippedSign()))
			{
				thePlayer.SoundEvent("gui_no_adrenaline");
				return;
			}

			thePlayer.SetupCombatAction( EBAT_CastSign, BS_Pressed );
		}
		else
		{
			thePlayer.SoundEvent("gui_no_stamina");
		}
	}
}

@wrapMethod(CPlayerInput) function OnCastSign( action : SInputAction )
{
	var signSkill : ESkill;

	if(false) 
	{
		wrappedMethod(action);
	}

	if (IsReleased( action ) && altSignCasting && GetWitcherPlayer().IsCurrentSignChanneled())
	{
		theGame.GetGuiManager().ShowNotification(GetLocStringByKey("ACS_initialized"));
	}

	if( altSignCasting )
		thePlayer.ApplyCastSettings(); 
	
	
	if(altSignCasting && !theInput.LastUsedPCInput() && !action.isActivatedWithPattern)
	{
		if(IsPressed( action ))
		{
			thePlayer.BlockAction(EIAB_Interactions, 'NGE_CastSign_Block');
			thePlayer.BlockAction(EIAB_InteractionAction, 'NGE_CastSign_Block');
			thePlayer.BlockAction(EIAB_InteractionContainers, 'NGE_CastSign_Block');
		}
		else if(IsReleased( action ))
		{
			thePlayer.UnblockAction(EIAB_Interactions, 'NGE_CastSign_Block');
			thePlayer.UnblockAction(EIAB_InteractionAction, 'NGE_CastSign_Block');
			thePlayer.UnblockAction(EIAB_InteractionContainers, 'NGE_CastSign_Block');
		}
		
		return false;
	}
	
	if( !thePlayer.GetBIsInputAllowed() )
	{	
		return false;
	}
	
	if( IsPressed(action) )
	{
		if( !IsActionAllowed(EIAB_NonPatternAlternatives) && !action.isActivatedWithPattern)
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_NonPatternAlternatives, false, false, true);
			return false;
		}
		return CastSign();
	}
}

@addMethod(CPlayerInput) function CastSign() : bool
{
	var signSkill : ESkill;
	
	if( GetWitcherPlayer().IsInCombatAction() && thePlayer.GetBehaviorVariable( 'combatActionType' ) == (int)CAT_CastSign )
	{
		return false;
	}

	if( !IsActionAllowed(EIAB_Signs) )
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs);
		return false;
	}
	if ( thePlayer.IsHoldingItemInLHand() && thePlayer.IsUsableItemLBlocked() )
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, false, false, true);
		return false;
	}

	signSkill = SignEnumToSkillEnum( thePlayer.GetEquippedSign() );
	if( signSkill != S_SUndefined )
	{
		if(!thePlayer.CanUseSkill(signSkill))
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs, false, false, true);
			return false;
		}

		if(IsSignOnCooldown(thePlayer.GetEquippedSign()))
		{
			thePlayer.SoundEvent("gui_no_adrenaline");
			return false;
		}
	
		if( thePlayer.HasStaminaToUseSkill( signSkill, false ) )
		{
			thePlayer.SetupCombatAction( EBAT_CastSign, BS_Pressed );
		}
		else
		{
			thePlayer.SoundEvent("gui_no_stamina");
		}
	}
	return true;
}

@addMethod(CPlayerInput) function IsSignOnCooldown(signType : ESignType) : bool
{
	switch(signType)
	{
		case ST_Aard: 	return thePlayer.HasBuff(EET_AardCooldown);
		case ST_Igni: 	return thePlayer.HasBuff(EET_IgniCooldown);
		case ST_Yrden: 	return thePlayer.HasBuff(EET_YrdenCooldown);
		case ST_Quen: 	return thePlayer.HasBuff(EET_QuenCooldown);
		case ST_Axii: 	return thePlayer.HasBuff(EET_AxiiCooldown);
		default:		return true;
	}
	return true;
}

@wrapMethod(CPlayerInput) function OnThrowBomb(action : SInputAction)
{
	var selectedItemId : SItemUniqueId;
	
	selectedItemId = thePlayer.GetSelectedItemId();
	if(!thePlayer.inv.IsItemBomb(selectedItemId))
		return false;
	
	if( thePlayer.inv.SingletonItemGetAmmo(selectedItemId) == 0 || !thePlayer.HasStaminaToUseAction(ESAT_UsableItem) )
	{
		
		if(IsPressed(action))
		{			
			thePlayer.SoundEvent( "gui_ingame_low_stamina_warning" );
		}
		
		return false;
	}
	
	wrappedMethod(action);
	
	return false;
}

@wrapMethod(CPlayerInput) function OnThrowBombHold(action : SInputAction)
{
	var selectedItemId : SItemUniqueId;
	
	selectedItemId = thePlayer.GetSelectedItemId();
	if(!thePlayer.inv.IsItemBomb(selectedItemId))
		return false;
	
	if( thePlayer.inv.SingletonItemGetAmmo(selectedItemId) == 0 || !thePlayer.HasStaminaToUseAction(ESAT_UsableItem) )
	{
		return false;
	}
	
	wrappedMethod(action);
		
	return false;
}

@wrapMethod(CPlayerInput) function OnCbtThrowItem( action : SInputAction )
{	
	if(!thePlayer.HasStaminaToUseAction(ESAT_UsableItem))
	{
		return false;
	}	
	
	wrappedMethod(action);
	
	return false;
}

@wrapMethod(CPlayerInput) function OnCommPanelAlch( action : SInputAction )
{
	var ent 				 : CEntity;
	
	// Alchemy 5.01 variant: 5.01 code, no fire needed.
	if (spectreAlchemy501())
	{
		wrappedMethod(action);
		return true;
	}
	
	ent = (CEntity)theGame.GetEntityByTag( 'ACS_Meditation_Campfire' );

	if( IsReleased(action) )
	{
		if( theGame.alchexts.fire_src == 0 || theGame.alchexts.casual_alchemy
			|| ent || FactsQuerySum("ACS_Meditation_Allow_Alchemy") > 0 )
		{
			PushAlchemyScreen();
		}
	}
}

@wrapMethod(CPlayerInput) function OnExpFocus( action : SInputAction )
{
	var inGameConfigWrapper : CInGameConfigWrapper;
	var isAccessibilityFocusToggle, isFocusStart, isFocusStop : bool;
	var mouserControllerScheme : MouserControllerScheme;

	if(false) 
	{
		wrappedMethod(action);
	}

	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	isAccessibilityFocusToggle = inGameConfigWrapper.GetVarValue('Accessibility', 'FocusToggle') == "true";
	if (isAccessibilityFocusToggle)
	{
		if ( IsReleased( action ) )
		{
			isFocusStart = !theGame.GetFocusModeController().IsActive();
			isFocusStop = theGame.GetFocusModeController().IsActive();
		}
		if ( IsPressed( action ) && !GetIsAltSignCastingPressed() )
			return false;
	}
	else
	{
		isFocusStart = IsPressed( action );
		isFocusStop = IsReleased( action );
	}

	if(!thePlayer.IsCiri())
	{
		if(altSignCasting && !theInput.LastUsedPCInput() && theInput.IsActionPressed('CastSign'))
		{
			if((isFocusStart || isAccessibilityFocusToggle) && !GetWitcherPlayer().IsCurrentSignChanneled())
			{
				theGame.GetFocusModeController().Deactivate();
				mouserControllerScheme = theInput.GetMouserControllerScheme();
				if (mouserControllerScheme == MouserControllerScheme_Comfort)
					AltCastSign(ST_Yrden);
				else
					AltCastSign(ST_Igni);
				return false;
			}

			if (isFocusStop && GetWitcherPlayer().IsCurrentSignChanneled())
			{
				thePlayer.AbortSign();
				return false;
			}
		}
	}
	
	if(thePlayer.IsCiri() && IsActionAllowed(EIAB_ExplorationFocus))
	{
		if( isFocusStart )
		{
			if( thePlayer.GoToCombatIfNeeded() )
			{
				OnCommGuard( action );
				return false;
			}
			theGame.GetFocusModeController().Activate();
		}
		else if( isFocusStop )
		{
			theGame.GetFocusModeController().Deactivate();
		}
	}
	else if(IsActionAllowed(EIAB_ExplorationFocus) && !GetWitcherPlayer().IsCurrentSignChanneled()) 
	{
		if( isFocusStart )
		{
			if( thePlayer.GoToCombatIfNeeded() )
			{
				OnCommGuard( action );
				return false;
			}
			theGame.GetFocusModeController().Activate();
		}
		else if( isFocusStop )
		{
			theGame.GetFocusModeController().Deactivate();
		}
	}
	else
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_ExplorationFocus);
		theGame.GetFocusModeController().Deactivate();	
	}
}

@wrapMethod(CPlayerInput) function OnAltQuen( action : SInputAction )
{
	var mouserControllerScheme : MouserControllerScheme;

	if(false) 
	{
		wrappedMethod(action);
	}

	mouserControllerScheme = theInput.GetMouserControllerScheme();

	if(!thePlayer.IsCiri())
	{
		if(altSignCasting && !theInput.LastUsedPCInput() && theInput.IsActionPressed('CastSign') && (mouserControllerScheme == MouserControllerScheme_None || mouserControllerScheme == MouserControllerScheme_Comfort))
		{
			if(IsPressed( action ) && !GetWitcherPlayer().IsCurrentSignChanneled())
			{
				AltCastSign(ST_Quen);
				return false;
			} 

			if (IsReleased( action ) && GetWitcherPlayer().IsCurrentSignChanneled())
			{
				thePlayer.AbortSign();
				return false;
			}
		}
	}
}
