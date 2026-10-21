@addField(W3DamageManagerProcessor)
private var weaponsAreNotDeadly			: bool;

@addField(W3DamageManagerProcessor)
private var victimHealthPercBeforeHit	: float;

@addField(W3DamageManagerProcessor)
private var mutation8Triggered			: bool;

@addField(W3DamageManagerProcessor)
private var hasArmor					: bool;

@replaceMethod( W3DamageManagerProcessor ) function ProcessAction(act : W3DamageAction)
{
	var wasAlive, validDamage, isFrozen, autoFinishersEnabled : bool;
	var focusDrain : float;
	var npc : CNewNPC;
	var buffs : array<EEffectType>;
	var arrStr : array<string>;
	var aerondight	: W3Effect_Aerondight;
	var min, max : SAbilityAttributeValue;
	var phantomWeapon : W3Effect_PhantomWeapon;

	wasAlive = act.victim.IsAlive();		
	npc = (CNewNPC)act.victim;
	
	
	InitializeActionVars(act);

	if (!action.GetSimulateOnly())
	{
		ProcessPreHitModifications();
		ProcessActionQuest(act);
	}
	
	
	isFrozen = (actorVictim && actorVictim.HasBuff(EET_Frozen));

	if(actorVictim)
		actorVictim.DodgeDamage(action);

	if(!action.WasDodged())
		validDamage = ProcessActionDamage();
	else
		validDamage = 0;
	
	
	if(wasAlive && !action.victim.IsAlive())
	{
		arrStr.PushBack(action.victim.GetDisplayName());
		if(npc && npc.WillBeUnconscious())
		{
			theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_unconscious", , , arrStr), NULL, action.victim);
		}
		else if(action.attacker && action.attacker.GetDisplayName() != "")
		{
			arrStr.PushBack(action.attacker.GetDisplayName());
			theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_killed", , , arrStr), action.attacker, action.victim);
		}
		else
		{
			theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_dies", , , arrStr), NULL, action.victim);
		}
	}
	
	if( wasAlive && action.DealsAnyDamage() )
	{
		if( action.victim == thePlayer )
			((CActor)action.attacker).SignalGameplayEventParamFloat( 'CausesDamage', ClampF( action.processedDmg.vitalityDamage / (0.5 * thePlayer.GetMaxHealth()), 0.0f, 1.0f ) );
		else
			((CActor)action.attacker).SignalGameplayEventParamFloat( 'CausesDamage', 1.0 );

		if( playerAttacker && action.GetIsHeadShot() )
			actorVictim.SignalGameplayEvent( 'Headshot' );
	}
	
	
	ProcessActionReaction(isFrozen, wasAlive);
	
	
	if(action.DealsAnyDamage() || action.ProcessBuffsIfNoDamage())
		ProcessActionBuffs();
	
	
	if(theGame.CanLog() && !validDamage && action.GetEffectsCount() == 0)
	{
		LogAssert(false, "W3DamageManagerProcessor.ProcessAction: action deals no damage and gives no buffs - investigate!");
		if ( theGame.CanLog() )
		{
			LogDMHits("*** Action has no valid damage and no valid buffs - investigate!", action);
		}
	}
	
	if( actorAttacker && wasAlive )
		actorAttacker.OnProcessActionPost(action);

	
	// Adrenaline lost to a hit, as in 5.01: a set amount for light, heavy and super heavy attacks. Spectre's
	// Bear set (bonus 1) still takes 0.035 per piece off it, so with the whole set light hits give Adrenaline.
	if(actorVictim == GetWitcherPlayer() && action.DealsAnyDamage() && !action.IsDoTDamage())
	{
		if(actorAttacker && attackAction)
		{
			if(actorAttacker.IsHeavyAttack( attackAction.GetAttackName() ))
				focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('heavy_attack_focus_drain'));
			else if(actorAttacker.IsSuperHeavyAttack( attackAction.GetAttackName() ))
				focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('super_heavy_attack_focus_drain'));
			else
				focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain'));
		}
		else
		{
			focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain'));
		}

		if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
			focusDrain *= MaxF(0, 1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16)));

		if(GetWitcherPlayer().IsSetBonusActive(EISB_Bear_1))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetSetBonusAbility(EISB_Bear_1), 'bonus_focus_gain', min, max);
			min.valueAdditive *= GetWitcherPlayer().GetSetPartsEquipped(EIST_Bear);
			focusDrain -= min.valueAdditive;
		}
		
		if(focusDrain > 0)
			thePlayer.DrainFocus(focusDrain);
		else if(focusDrain < 0)
			thePlayer.GainStat(BCS_Focus, -focusDrain);
	}

	if(actorAttacker == GetWitcherPlayer() && thePlayer.CanUseSkill(S_Perk_21) && actorVictim && (action.IsActionMelee() || action.IsActionRanged() || action.IsActionWitcherSign()))
	{
		if(action.IsCriticalHit() && action.DealsAnyDamage())
		{
			GetWitcherPlayer().GainAdrenalineFromPerk21('crit');
		}
	}
	
	if(action.EndsQuen() && actorVictim)
	{
		actorVictim.FinishQuen(false);			
	}

	if(playerAttacker && actorVictim && actorVictim.WasCountered() && !action.IsDoTDamage())
		actorVictim.SetWasCountered(false);

	
	if(actorVictim == thePlayer && attackAction && attackAction.IsActionMelee() && (ShouldProcessTutorial('TutorialDodge') || ShouldProcessTutorial('TutorialCounter') || ShouldProcessTutorial('TutorialParry')) )
	{
		if(attackAction.IsCountered())
		{
			theGame.GetTutorialSystem().IncreaseCounters();
		}
		else if(attackAction.IsParried())
		{
			theGame.GetTutorialSystem().IncreaseParries();
		}
		
		if(attackAction.CanBeDodged() && !attackAction.WasDodged())
		{
			GameplayFactsAdd("tut_failed_dodge", 1, 1);
			GameplayFactsAdd("tut_failed_roll", 1, 1);
		}
	}
	
	if( playerAttacker && npc && action.IsActionMelee() && action.DealtDamage() && IsRequiredAttitudeBetween( playerAttacker, npc, true ) )
	{			
		if( attackAction && !attackAction.WasDodged() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ))
		{
			aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
			if( aerondight )
			{
				if( aerondight.IsFullyCharged() )
				{
					aerondight.PlayTrailEffect( npc.GetBloodType() );
					aerondight.DischargeAerondight();																			 
				}
				else
					aerondight.AddCharge();
			}
		}

		if( attackAction && !attackAction.WasDodged() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'PhantomWeapon' ) )																																															   
		{
			phantomWeapon = (W3Effect_PhantomWeapon)playerAttacker.GetBuff( EET_PhantomWeapon );
			if( phantomWeapon )			 
			{
				if( phantomWeapon.IsWeaponCharged() )
					phantomWeapon.DrainAttackerHealth();
				if( attackAction.GetBuffSourceName() == "PhantomWeapon" )
					phantomWeapon.DischargePhantomWeapon();
				else if( !phantomWeapon.IsWeaponCharged() )
					phantomWeapon.AddCharge();
			}
		}
	}
}

@wrapMethod( W3DamageManagerProcessor ) function InitializeActionVars(act : W3DamageAction)
{
	var tmpName : name;
	var tmpBool	: bool;
	
	if(false) 
	{
		wrappedMethod(act);
	}

	action 				= act;
	playerAttacker 		= (CR4Player)action.attacker;
	playerVictim		= (CR4Player)action.victim;
	attackAction 		= (W3Action_Attack)action;		
	actorVictim 		= (CActor)action.victim;
	actorAttacker		= (CActor)action.attacker;
	dm 					= theGame.GetDefinitionsManager();
	
	if(attackAction)
		weaponId 		= attackAction.GetWeaponId();
		
	theGame.GetMonsterParamsForActor(actorVictim, victimMonsterCategory, tmpName, tmpBool, tmpBool, victimCanBeHitByFists);
	
	if(actorAttacker)
		theGame.GetMonsterParamsForActor(actorAttacker, attackerMonsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
	
	weaponsAreNotDeadly = NonDeadlyWeaponFight();
	
	if(actorVictim && actorVictim.UsesVitality())
		victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Vitality);
	else if(actorVictim && actorVictim.UsesEssence())
		victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Essence);
	
	CheckMutation8Finisher();
}

@addMethod(W3DamageManagerProcessor) function NonDeadlyWeaponFight() : bool
{
	var attackerNonDeadly, victimNonDeadly : bool;
	var attackerWeaponId, victimWeaponId : SItemUniqueId;
	var heldWeapons : array<SItemUniqueId>;
	var attackerInv, victimInv : CInventoryComponent;
	
	if(!attackAction || !attackAction.IsActionMelee() || !actorAttacker || !actorVictim)
		return false;
	
	attackerInv = actorAttacker.GetInventory();
	heldWeapons = attackerInv.GetHeldWeapons();
	if(heldWeapons.Size() > 0)
		attackerWeaponId = heldWeapons[0];
	
	if(attackerWeaponId == GetInvalidUniqueId())
		return false;
	
	victimInv = actorVictim.GetInventory();
	heldWeapons = victimInv.GetHeldWeapons();
	if(heldWeapons.Size() > 0)
		victimWeaponId = heldWeapons[0];
	
	if(victimWeaponId == GetInvalidUniqueId())
		return false;
	
	if(actorAttacker.HasAbility('mon_ff204olaf') || actorAttacker.HasAbility('mon_ff205troll') || actorAttacker.HasAbility('mon_EP2_clubDwarfs') || actorAttacker.HasTag('mq7011_guards'))
		attackerNonDeadly = true;
	else
		attackerNonDeadly = attackerInv.ItemHasTag(attackerWeaponId, 'Wooden') || attackerInv.ItemHasTag(attackerWeaponId, 'Fists') && !attackerInv.ItemHasTag(attackerWeaponId, 'MagicWeaponFX');
	
	if(actorVictim.HasAbility('mon_ff204olaf') || actorVictim.HasAbility('mon_ff205troll') || actorVictim.HasAbility('mon_EP2_clubDwarfs') || actorVictim.HasTag('mq7011_guards'))
		victimNonDeadly = true;
	else
		victimNonDeadly = victimInv.ItemHasTag(victimWeaponId, 'Wooden') || victimInv.ItemHasTag(victimWeaponId, 'Fists') && !victimInv.ItemHasTag(victimWeaponId, 'MagicWeaponFX');
	
	return attackerNonDeadly && victimNonDeadly;
}

@addMethod(W3DamageManagerProcessor) function CheckMutation8Finisher()
{
	//if(((W3PlayerWitcher)playerAttacker) && ((W3PlayerWitcher)playerAttacker).IsMutationActive(EPMT_Mutation8) && ((W3PlayerWitcher)playerAttacker).HasRecentlyCountered() && ((CNewNPC)actorVictim) && !((CNewNPC)actorVictim).IsImmuneToMutation8Finisher())
	if(action.GetBuffSourceName() != "Finisher" && action.GetBuffSourceName() != "AutoFinisher" && attackAction && attackAction.IsActionMelee() && ((W3PlayerWitcher)playerAttacker) && ((W3PlayerWitcher)playerAttacker).IsMutationActive(EPMT_Mutation8) && actorVictim.WasCountered() && ((CNewNPC)actorVictim) && !((CNewNPC)actorVictim).IsImmuneToMutation8Finisher())
	{
		mutation8Triggered = true;
	}
	else
	{
		mutation8Triggered = false;
	}
}

@addMethod(W3DamageManagerProcessor) function CleanupMutation8Finisher()
{
	mutation8Triggered = false;
}

@replaceMethod( W3DamageManagerProcessor ) function ProcessActionDamage() : bool
{
	var directDmgIndex, size, i : int;
	var dmgInfos : array< SRawDamage >;
	var immortalityMode : EActorImmortalityMode;
	var dmgValue : float;
	var anyDamageProcessed, fallingRaffard : bool;
	var frozenAdditionalDamage : float;		
	var powerMod : SAbilityAttributeValue;
	var witcher : W3PlayerWitcher;
	var canLog : bool;
	var immortalityChannels : array<EActorImmortalityChannel>;
	var min, max : SAbilityAttributeValue; 
	var difficultyDamageMultiplier : float; 

	var enhancements : array<CBaseGameplayEffect>;
	var grindstoneBuff : W3Effect_EnhancedWeapon;
	var workbenchBuff : W3Effect_EnhancedArmor;

	if(!actorVictim || (!actorVictim.UsesVitality() && !actorVictim.UsesEssence()))
	{
		if(action.GetDamageValue(theGame.params.DAMAGE_NAME_FIRE) > 0)
			action.victim.OnFireHit((CGameplayEntity)action.causer);
	   
		if(!actorVictim.abilityManager)
			actorVictim.OnDeath(action);
		
		return false;
	}
	
	canLog = theGame.CanLog();
		
	if ( canLog )
	{
		LogBeginning();
	}
		
	ProcessDamageIncrease(dmgInfos);
	
	ProcessDamageDecrease();
	
	action.SetAllProcessedDamageAs(0);
	size = action.GetDTs( dmgInfos );
	action.SetDealtFireDamage(false);

	ProcessNewSkills_Combat( dmgInfos );
	action.SetDTs( dmgInfos );
	
	ProcessCriticalHitCheck();
	
	
	ProcessOnBeforeHitChecks();
	
	
	powerMod = GetAttackersPowerMod();

	
	anyDamageProcessed = false;
	directDmgIndex = -1;
	witcher = GetWitcherPlayer();
	size = dmgInfos.Size();			
	for( i = 0; i < size; i += 1 )
	{
		if(dmgInfos[i].dmgVal == 0)
			continue;
		
		if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
		{
			directDmgIndex = i;
			continue;
		}

		if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_POISON && witcher == actorVictim)
		{
			dmgValue = dmgInfos[i].dmgVal;
			
			if(witcher.IsSetBonusActive(EISB_Viper))
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'setBonusAbilityViper_1', 'per_viper_piece_poison_healing_rate', min, max );
				witcher.GainStat(BCS_Vitality, dmgValue * CalculateAttributeValue(min) * witcher.GetSetPartsEquipped( EIST_Viper ));
				if ( canLog )
				{
					LogDMHits("", action);
					LogDMHits("*** Player absorbs poison damage from Viper Set ability: " + (dmgValue * CalculateAttributeValue(min) * witcher.GetSetPartsEquipped( EIST_Viper )), action);
				}
				dmgInfos[i].dmgVal = 0;
			}
			if(dmgInfos[i].dmgVal == 0.f)
				continue;
		}
		
		
		if ( canLog )
		{
			LogDMHits("", action);
			LogDMHits("*** Incoming " + NoTrailZeros(dmgInfos[i].dmgVal) + " " + dmgInfos[i].dmgType + " damage", action);
			if(action.IsDoTDamage())
				LogDMHits("DoT's current dt = " + NoTrailZeros(action.GetDoTdt()) + ", estimated dps = " + NoTrailZeros(dmgInfos[i].dmgVal / action.GetDoTdt()), action);
		}
		
		
		anyDamageProcessed = true;
			
		
		dmgValue = MaxF(0, CalculateDamage(dmgInfos[i], powerMod));
	
		
		if( DamageHitsEssence(  dmgInfos[i].dmgType ) )		action.processedDmg.essenceDamage  += dmgValue;
		if( DamageHitsVitality( dmgInfos[i].dmgType ) )		action.processedDmg.vitalityDamage += dmgValue;
		if( DamageHitsMorale(   dmgInfos[i].dmgType ) )		action.processedDmg.moraleDamage   += dmgValue;
		if( DamageHitsStamina(  dmgInfos[i].dmgType ) )		action.processedDmg.staminaDamage  += dmgValue;
	}
	
	if(size == 0 && canLog)
	{
		LogDMHits("*** There is no incoming damage set (probably only buffs).", action);
	}
	
	if ( canLog )
	{
		LogDMHits("", action);
		LogDMHits("Processing block, parry, immortality, signs and other GLOBAL damage reductions...", action);		
	}
	
	if(actorVictim)
		actorVictim.ReduceDamage(action);
	
	ProcessDamageModification();
	
	if(directDmgIndex != -1)
	{
		anyDamageProcessed = true;
		
		immortalityChannels = actorVictim.GetImmortalityModeChannels(AIM_Invulnerable);
		fallingRaffard = immortalityChannels.Size() == 1 && immortalityChannels.Contains(AIC_WhiteRaffardsPotion) && action.GetBuffSourceName() == "FallingDamage";

		dmgValue = dmgInfos[directDmgIndex].dmgVal;
		if ( action.GetSignSkill() == S_Magic_1 )
			dmgValue = MaxF(0, CalculateDamage(dmgInfos[directDmgIndex], powerMod));
		
		if(action.GetIgnoreImmortalityMode() || (!actorVictim.IsImmortal() && !actorVictim.IsInvulnerable() && !actorVictim.IsKnockedUnconscious()) || fallingRaffard)
		{
			action.processedDmg.vitalityDamage += dmgValue;
			action.processedDmg.essenceDamage  += dmgValue;
		}
		else if( actorVictim.IsInvulnerable() )
		{
			
		}
		else if( actorVictim.IsImmortal() )
		{
			
			action.processedDmg.vitalityDamage += MinF(dmgValue, actorVictim.GetStat(BCS_Vitality)-1 );
			action.processedDmg.essenceDamage  += MinF(dmgValue, actorVictim.GetStat(BCS_Essence)-1 );
		}
	}
	
	if( actorVictim.HasAbility( 'OneShotImmune' ) )
	{
		if( action.processedDmg.vitalityDamage >= actorVictim.GetStatMax( BCS_Vitality ) )
		{
			action.processedDmg.vitalityDamage = actorVictim.GetStatMax( BCS_Vitality ) - 1;
		}
		else if( action.processedDmg.essenceDamage >= actorVictim.GetStatMax( BCS_Essence ) )
		{
			action.processedDmg.essenceDamage = actorVictim.GetStatMax( BCS_Essence ) - 1;
		}
	}
	
	if(action.HasDealtFireDamage())
		action.victim.OnFireHit( (CGameplayEntity)action.causer );
		
	ProcessInstantKill();
		
	ProcessActionDamage_DealDamage();

	if(playerAttacker && witcher && attackAction && attackAction.GetAttackName() != 'counter_attack_light')
	{
		witcher.SetRecentlyCountered(false);
		witcher.SetRecentlyDodged(false);
	}
	
	if( attackAction && !attackAction.IsCountered() && playerVictim && attackAction.IsActionMelee())
		theGame.GetGamerProfile().ResetStat(ES_CounterattackChain);
	
	ProcessActionDamage_ReduceDurability();
	
	if(playerAttacker && actorVictim)
	{
		if(action.IsActionMelee() && !playerAttacker.inv.IsItemFists( weaponId ) && !GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats')
		&& ( playerAttacker.inv.IsItemSteelSwordUsableByPlayer( attackAction.GetWeaponId() ) || playerAttacker.inv.IsItemSilverSwordUsableByPlayer( attackAction.GetWeaponId() ) ) )
		{
			enhancements = witcher.GetBuffs( EET_EnhancedWeapon );
			for( i=enhancements.Size()-1; i>=0; i-=1 )
			{
				grindstoneBuff = ( W3Effect_EnhancedWeapon ) enhancements[ i ];
				playerAttacker.spectreReduceAllGrindstoneAmmo(grindstoneBuff);
				size = grindstoneBuff.spectreGetAmmoCurrentCount();
			}
		}
		
		playerAttacker.ReduceAllOilsAmmo( weaponId );

		playerAttacker.inv.ReduceItemRepairObjectBonusCharge(weaponId);
	}
	
	if(actorVictim && actorAttacker && !action.GetCannotReturnDamage() && !action.GetSimulateOnly() )
		ProcessActionReturnedDamage();	


	if(playerVictim && action.DealsPhysicalOrSilverDamage() && !action.IsDoTDamage() && action.DealtDamage() && !attackAction.IsDoTDamage() && !GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats'))
	{
		enhancements = witcher.GetBuffs( EET_EnhancedArmor );
		for( i=enhancements.Size()-1; i>=0; i-=1 )
		{
			workbenchBuff = ( W3Effect_EnhancedArmor ) enhancements[ i ];
			playerVictim.spectreReduceAllWorkbenchAmmo(workbenchBuff);
			
			size = workbenchBuff.spectreGetAmmoCurrentCount();
		}
	}
	
	return anyDamageProcessed;
}

@wrapMethod( W3DamageManagerProcessor ) function ProcessInstantKill()
{
	var instantKill, focus : float;
	var victimIsImmune : bool;
	var witcherAttacker : W3PlayerWitcher;
	
	if(false) 
	{
		wrappedMethod();
	}

	witcherAttacker = GetWitcherPlayer();
	
	if( (W3MonsterHuntNPC)actorVictim )
	{
		return;
	}

	if( action.WasDodged() || ( attackAction && ( attackAction.IsParried() || attackAction.IsCountered() ) ) )
	{
		return;
	}

	victimIsImmune = actorVictim && actorVictim.IsImmuneToInstantKill();
	
	if( !actorVictim || !actorAttacker || victimIsImmune || action.GetSimulateOnly() )
	{
		if(victimIsImmune
		&& actorAttacker == witcherAttacker
		&& witcherAttacker.CanUseSkill(S_Sword_s30)
		&& witcherAttacker.IsDeadlyPrecisionEnabled()
		&& attackAction
		&& attackAction.GetAttackTypeName() == 'attack_heavy')
		{
			witcherAttacker.GainStat(BCS_Focus, GetTriggerChance(S_Sword_s30));
		}
		return;
	}
	
	if( actorAttacker.HasAbility( 'ForceInstantKill' ) && actorVictim != thePlayer )
	{
		action.SetInstantKill();
	}
	
	if( actorAttacker == thePlayer )
	{
		if((W3PlayerWitcher)playerAttacker && thePlayer.IsDoingSpecialAttack(false))
		{
			return;
		}
	}

	
	if( !action.GetInstantKill() )
	{
		
		instantKill = CalculateAttributeValue( actorAttacker.GetInventory().GetItemAttributeValue( weaponId, 'instant_kill_chance' ) );
		
		if( (W3PlayerWitcher)playerAttacker && action.IsActionMelee() && action.DealsAnyDamage() && thePlayer.CanUseSkill( S_Sword_s03 ) && !playerAttacker.inv.IsItemFists( weaponId ) && actorVictim && actorVictim.WasCountered() )
		{
			focus = thePlayer.GetStat( BCS_Focus );
			
			if( focus >= 1 )
			{
				instantKill += focus * CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Sword_s03, 'instant_kill_chance', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s03 );
			}
		}

		if( action.IsBouncedArrow() && playerAttacker && playerAttacker.CanUseSkill(S_Sword_s33) )
			instantKill += CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Sword_s33, 'instant_kill_chance', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s33 );

		if( attackAction && attackAction.GetAttackName() == 'bolt' && action.GetIsHeadShot() && playerAttacker && playerAttacker.CanUseSkill(S_Sword_s32) )
			instantKill += CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Sword_s32, 'instant_kill_chance', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s32 );

		if( actorAttacker == witcherAttacker
		&& witcherAttacker.CanUseSkill(S_Sword_s30)
		&& witcherAttacker.IsDeadlyPrecisionEnabled()
		&& attackAction
		&& attackAction.GetAttackTypeName() == 'attack_heavy' )
		{
			instantKill += GetTriggerChance(S_Sword_s30);
			witcherAttacker.ResetDeadlyPrecision();
		}
	}
	
	if( action.GetInstantKill() || ( RandF() < instantKill ) )
	{
		if( theGame.CanLog() )
		{
			if( action.GetInstantKill() )
			{
				instantKill = 1.f;
			}
			LogDMHits( "Instant kill!! (" + NoTrailZeros( instantKill * 100 ) + "% chance", action );
		}
		
		if( actorVictim && actorVictim.HasAbility( 'LastBreath' ) && !action.GetWasFrozen() )
		{
			if( actorVictim.UsesVitality() )
				action.processedDmg.vitalityDamage = GetLastBreathMaxAllowedDamage();
			else
				action.processedDmg.essenceDamage = GetLastBreathMaxAllowedDamage();
		}
		else
		{
			action.processedDmg.vitalityDamage = actorVictim.GetStat( BCS_Vitality );
			action.processedDmg.essenceDamage = actorVictim.GetStat( BCS_Essence );
		}
		action.SetCriticalHit();
		action.SetInstantKillFloater();
		
		if( playerAttacker )
		{
			thePlayer.SetLastInstantKillTime( theGame.GetGameTime() );
			theSound.SoundEvent( 'cmb_play_deadly_hit' );
			theGame.SetTimeScale( 0.2, theGame.GetTimescaleSource( ETS_InstantKill ), theGame.GetTimescalePriority( ETS_InstantKill ), true, true );
			thePlayer.AddTimer( 'RemoveInstantKillSloMo', 0.2 );
		}			
	}
}

@addMethod(W3DamageManagerProcessor) function GetLastBreathMaxAllowedDamage() : float
{
	return MaxF( 0, actorVictim.GetHealth() - actorVictim.GetMaxHealth() * CalculateAttributeValue( actorVictim.GetAttributeValue('lastbreath_threshold') ) );
}

@wrapMethod( W3DamageManagerProcessor ) function ProcessOnBeforeHitChecks()
{
	var effectAbilityName : name;
	var effectType : EEffectType;
	var i : int;
	var chance : float;
	var buffs : array<name>;
	var resPt, resPrc : float;
	
	// 5.01 tree: 5.01 code.
	if (spectreVanillaSkills())
	{
		wrappedMethod();
		return;
	}

	if( weaponsAreNotDeadly )
		return;
	
	if( playerAttacker && actorVictim && attackAction && attackAction.IsActionMelee() && playerAttacker.CanUseSkill(S_Alchemy_s12) )
	{
		chance = playerAttacker.inv.GetOilPoisonChanceAgainstMonster(weaponId, victimMonsterCategory);

		actorVictim.GetResistValue(theGame.effectMgr.GetBuffResistStat(EET_Poison), resPt, resPrc);
		chance = MaxF(0, chance * (1 - resPrc));

		if(((W3PlayerWitcher)playerAttacker).IsMutationActive(EPMT_Mutation12))
			chance *= MaxF(1.0f, 1.0f + ((W3PlayerWitcher)playerAttacker).Mutation12GetBonus());
		
		if(chance > 0 && RandF() < chance)
		{
			
			dm.GetContainedAbilities(playerAttacker.GetSkillAbilityName(S_Alchemy_s12), buffs);
			for(i=0; i<buffs.Size(); i+=1)
			{
				EffectNameToType(buffs[i], effectType, effectAbilityName);
				action.AddEffectInfo(effectType, , , effectAbilityName);
			}
		}
	}

	if((W3PlayerWitcher)playerAttacker && attackAction && SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
	{
		action.AddEffectInfo(EET_KnockdownTypeApplicator);
	}
}

@replaceMethod( W3DamageManagerProcessor ) function ProcessCriticalHitCheck()
{
	var critChance : float;
	var	canLog, meleeOrRanged, redWolfSet, isLightAttack, isHeavyAttack, mutation2 : bool;
	var arrStr : array<string>;
	var signPower, min, max : SAbilityAttributeValue;
	var aerondight : W3Effect_Aerondight;
	var blindnessCrit, confusionCrit : float;
	
	if( action.IsDoTDamage() )
		return;
	
	if( weaponsAreNotDeadly )
		return;
	
	meleeOrRanged = playerAttacker && attackAction && ( attackAction.IsActionMelee() || attackAction.IsActionRanged() );
	redWolfSet = ( W3Petard )action.causer && ( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsSetBonusActive( EISB_RedWolf_1 );
	mutation2 = ( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) && action.IsActionWitcherSign();
	
	if( meleeOrRanged || redWolfSet || mutation2 )
	{
		canLog = theGame.CanLog();
	
		
		if( mutation2 )
		{
			if( FactsQuerySum('debug_fact_critical_boy') > 0 )
			{
				critChance = 1.f;
			}
			else
			{
				signPower = action.GetPowerStatValue();
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_chance_factor', min, max);
				critChance = min.valueAdditive + SignPowerStatToPowerBonus(signPower.valueMultiplicative) * min.valueMultiplicative;
			}
		} 			
		else
		{
			if( attackAction )
			{
				// Spectre's Rend has its own critical chance. 5.01's does not.
				if( !spectreVanillaSkills() && SkillEnumToName(S_Sword_s02) == attackAction.GetAttackTypeName() )
				{
					critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s02, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * playerAttacker.GetSkillLevel(S_Sword_s02);
				}

				if( action.IsActionMelee() && (W3PlayerWitcher)playerAttacker && actorVictim && actorVictim.WasCountered() )
				{
					critChance += 0.25;
					if( playerAttacker.CanUseSkill(S_Sword_s11) && playerAttacker.GetSkillLevel(S_Sword_s11) > 1 )
						critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s11, theGame.params.CRITICAL_HIT_CHANCE, false, true))*(playerAttacker.GetSkillLevel(S_Sword_s11) - 1);
				}

				if(GetWitcherPlayer() && (GetWitcherPlayer().HasRecentlyCountered() || GetWitcherPlayer().HasRecentlyDodged()) && attackAction.GetAttackName() != 'counter_attack_light'
					&& playerAttacker.CanUseSkill(S_Sword_s31) && playerAttacker.GetSkillLevel(S_Sword_s31) > 3)
				{
					critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s31, theGame.params.CRITICAL_HIT_CHANCE, false, true));
				}
				
				
				isLightAttack = playerAttacker.IsLightAttack( attackAction.GetAttackName() );
				isHeavyAttack = playerAttacker.IsHeavyAttack( attackAction.GetAttackName() );
				critChance += playerAttacker.GetCriticalHitChance(isLightAttack, isHeavyAttack, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer );
				
				
				if(action.GetIsHeadShot())
				{
					critChance += theGame.params.HEAD_SHOT_CRIT_CHANCE_BONUS;
				}
				
				if ( actorVictim && actorVictim.IsAttackerAtBack(playerAttacker) )
				{
					critChance += theGame.params.BACK_ATTACK_CRIT_CHANCE_BONUS;
				}
					
				
				if( action.IsActionMelee() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
				{
					aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
					
					if( aerondight && aerondight.IsFullyCharged() )
					{
						critChance = 1.0;
					}
				}
			}
			else
			{
				
				critChance += playerAttacker.GetCriticalHitChance(false, false, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer );
			}
			
			if(actorVictim.HasBuff(EET_Blindness))
			{
				blindnessCrit = ((W3BlindnessEffect)actorVictim.GetBuff(EET_Blindness)).GetCritChanceBonus();
			}

			if(actorVictim.HasBuff(EET_Confusion))
			{
				//confusionCrit = ((W3ConfuseEffect)actorVictim.GetBuff(EET_Confusion)).GetCriticalHitChanceBonus();
			}
			
			if(blindnessCrit || confusionCrit)
			{
				critChance += MaxF(blindnessCrit, confusionCrit);
			}

			if(redWolfSet)
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_RedWolf_1 ), 'per_redwolf_piece_crit_chance_bonus', min, max );
				min.valueAdditive *= GetWitcherPlayer().GetSetPartsEquipped( EIST_RedWolf );
				critChance += CalculateAttributeValue( min );
			}
		}

		if( FactsQuerySum( "modSpectre_debug_dmg" ) > 0 )
		{
			if(!(action.IsDoTDamage() && (CBaseGameplayEffect)action.causer))
			{
				theGame.witcherLog.AddMessage("Dmg manager:");
				theGame.witcherLog.AddMessage("Attacker: " + actorAttacker.GetDisplayName());
				theGame.witcherLog.AddMessage("Victim: " + actorVictim.GetDisplayName());
				theGame.witcherLog.AddMessage("Critical hit chance prc: " + NoTrailZeros(critChance * 100));
			}
		}

		if(RandF() < critChance)
		{
			
			action.SetCriticalHit();
							
			if ( canLog )
			{
				LogDMHits("********************", action);
				LogDMHits("*** CRITICAL HIT ***", action);
				LogDMHits("********************", action);				
			}
			
			arrStr.PushBack(action.attacker.GetDisplayName());
			theGame.witcherLog.AddCombatMessage(theGame.witcherLog.COLOR_GOLD_BEGIN + GetLocStringByKeyExtWithParams("hud_combat_log_critical_hit",,,arrStr) + theGame.witcherLog.COLOR_GOLD_END, action.attacker, NULL);
		}
		else if ( canLog )
		{
			LogDMHits("... nope", action);
		}
	}	
}

@replaceMethod( W3DamageManagerProcessor ) function ProcessDamageIncrease(out dmgInfos : array< SRawDamage >)
{
	var i, bonusCount : int;
	var frozenBuff : W3Effect_Frozen;
	var frozenDmgInfo, bonusDmgInfo : SRawDamage;
	var forceDamageIdx, bonusDamageIdx : int;
	var bonusDamagePercents, bonusDamagePoints : float;
	var mpac : CMovingPhysicalAgentComponent;
	var perk20Bonus : SAbilityAttributeValue;
	var witcherAttacker : W3PlayerWitcher;
	var damageVal, damageBonus, min, max, sp : SAbilityAttributeValue;		
	var npcVictim : CNewNPC;
	var sword : SItemUniqueId;
	var actionFreeze : W3DamageAction;
	var dmgBonusMult : float;
	var addForceDamage : bool;
	var mutagen : CBaseGameplayEffect;
	var aardDamage : SRawDamage;
	var yrdens : array<W3YrdenEntity>;
	var j, levelDiff : int;
	var aardDamageF : float;
	var spellPower, spellPowerAard, spellPowerYrden : float;
	var spNetflix : SAbilityAttributeValue;
	var entities : array<CGameplayEntity>;
	var skillPassiveMod : float;
	var extraSignDamageMult, extraPoisonDamageMult, tempBonus, conjunctionDamageMult : float;
	var signSkillCatalystLevel, alchemySkillToxicShockLevel, meleeAttackCounterForResonanceSkill, dmgIdx, survivalSkillElementOfSurpriseLevel : int;
	var signSkillCatalystActive : bool;
	var minCatalyst, maxCatalyst, minEnhanced, maxEnhanced, minElementOfSurprise, maxElementOfSurprise, poisonDamageValue, tempAttribute, emptyAttribute : SAbilityAttributeValue;
	var toxicShockDamage : SRawDamage;
	var swordEntity : CWitcherSword;
	var monsterBonusType : name;
	var rendRatio, rendLoad, rendBonus : float;
	var rendBonusPerPoint, staminaRendBonus : SAbilityAttributeValue;
	
	if( !thePlayer.IsFistFightMinigameEnabled() && weaponsAreNotDeadly )
		return;
	
	action.GetDTs(dmgInfos);
	witcherAttacker = (W3PlayerWitcher)playerAttacker;
	npcVictim = (CNewNPC)actorVictim;
	
	if(action.IsActionMelee() && actorVictim && actorVictim.HasAbility( 'VulnerableFromFront' ) && actorAttacker && !actorVictim.IsAttackerAtBack(actorAttacker) )
	{
		action.SetIgnoreArmor( true );
	}
	
	dmgBonusMult = 0;
	addForceDamage = false;
	
	if( actorAttacker && attackAction && attackAction.IsActionMelee() && actorAttacker.IsWeaponHeld( 'fist' ) )
	{
		bonusDamagePoints = CalculateAttributeValue(actorAttacker.GetAttributeValue( 'fist_dmg_bonus' ));
		bonusDamageIdx = -1;
		for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
		{
			if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING )
			{
				dmgInfos[i].dmgVal += bonusDamagePoints;
				bonusDamageIdx = i;
			}
		}
		if( bonusDamageIdx == -1 )
		{
			bonusDmgInfo.dmgVal = bonusDamagePoints;
			bonusDmgInfo.dmgType = theGame.params.DAMAGE_NAME_BLUDGEONING;
			dmgInfos.PushBack( bonusDmgInfo );
		}
	}
	
	if(actorVictim)
	{
		mpac = (CMovingPhysicalAgentComponent)actorVictim.GetMovingAgentComponent();
		if(mpac && mpac.IsDiving())
		{
			mpac = (CMovingPhysicalAgentComponent)actorAttacker.GetMovingAgentComponent();	
			if(mpac && mpac.IsDiving())
			{
				action.SetUnderwaterDisplayDamageHack();
				if(playerAttacker && attackAction && attackAction.IsActionRanged())
				{
					for(i=0; i<dmgInfos.Size(); i+=1)
					{
						if(FactsQuerySum("NewGamePlus"))
						{
							dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP);
						}
						else
						{
							dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS);
						}
					}
				}
			}
		}
	}
	
	if(actorVictim && playerAttacker && GetWitcherPlayer().IsSetBonusActive( EISB_Netflix_2 ) && !action.IsDoTDamage() && ( (W3AardProjectile)action.causer || (W3AardEntity)action.causer)) 
	{	
		yrdens = GetWitcherPlayer().yrdenEntities;
		
		if(yrdens.Size() > 0)
		{
			spellPowerAard = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('spell_power_aard'));
			spellPowerYrden = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('spell_power_yrden'));				
			spellPower = ClampF(1 + spellPowerAard + spellPowerYrden + CalculateAttributeValue(GetWitcherPlayer().GetPowerStatValue(CPS_SpellPower)), 1, 3); 				
		
			for(i=0; i<yrdens.Size(); i+=1)
			{
				for(j=0; j<yrdens[i].validTargetsInArea.Size(); j+=1)
				{			
					if(yrdens[i].validTargetsInArea[j] == actorVictim )
					{
						levelDiff = playerAttacker.GetLevel() - actorVictim.GetLevel();
						aardDamage.dmgType = theGame.params.DAMAGE_NAME_DIRECT;	
						if( GetWitcherPlayer().CanUseSkill(S_Magic_s06) )
							aardDamageF = (RandRangeF(375.0, 325.0) + (playerAttacker.GetLevel() * 1.8f) + (GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * 100) ) * spellPower;
						else
							aardDamageF = (RandRangeF(375.0, 325.0) + (playerAttacker.GetLevel() * 1.8f) ) * spellPower;
						
						if( actorVictim.GetCharacterStats().HasAbilityWithTag('Boss') || (W3MonsterHuntNPC)actorVictim || (levelDiff < 0 && Abs(levelDiff) > theGame.params.LEVEL_DIFF_HIGH))
						{
							aardDamage.dmgVal = aardDamageF * 0.75f;
						}					
						else
						{
							aardDamage.dmgVal = aardDamageF;
						}
						
						spNetflix = action.GetPowerStatValue();
						aardDamage.dmgVal += 3 * actorVictim.GetHealth() * ( 0.01 + 0.03 * LogF( spNetflix.valueMultiplicative ) );
						dmgInfos.PushBack(aardDamage);
					}
				}
			}
		}																														   
	}
	
	if ( playerAttacker && action.IsActionRanged() && !action.IsDoTDamage() )
	{
		if ( ((W3BoltProjectile)action.causer) && GetWitcherPlayer().CanUseSkill(S_Sword_s15) )
		{
			damageVal.valueMultiplicative = 0;
			damageVal.valueAdditive = 0;
			damageVal.valueBase = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s15, 'xbow_dmg_bonus', false, true)) * GetWitcherPlayer().GetSkillLevel(S_Sword_s15);
			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal += damageVal.valueBase;
			}
		}
	}

	if( playerAttacker && action.IsActionWitcherSign() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
	{
		sword = playerAttacker.inv.GetCurrentlyHeldSword();
		damageVal.valueBase = 0;
		damageVal.valueMultiplicative = 0;
		damageVal.valueAdditive = 0;
		if( playerAttacker.inv.GetItemCategory(sword) == 'steelsword' )
		{
			damageVal.valueBase += GetWitcherPlayer().GetTotalWeaponDamage(sword, theGame.params.DAMAGE_NAME_SLASHING, GetInvalidUniqueId());
		}
		else if( playerAttacker.inv.GetItemCategory(sword) == 'silversword' )
		{
			damageVal.valueBase += GetWitcherPlayer().GetTotalWeaponDamage(sword, theGame.params.DAMAGE_NAME_SILVER, GetInvalidUniqueId());
		}
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', min, max);				
		damageVal.valueBase *= CalculateAttributeValue(min);
		if( action.IsDoTDamage() )
		{
			damageVal.valueBase *= action.GetDoTdt();
		}
		for( i = 0 ; i < dmgInfos.Size() ; i+=1)
		{
			dmgInfos[i].dmgVal += damageVal.valueBase;
		}
	}
	
	if( playerAttacker && action.IsActionWitcherSign() && action.GetSignType() == ST_Igni && !action.IsDoTDamage() && GetWitcherPlayer().HasGlyphwordActive('Glyphword 7 _Stats') )
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 7 _Stats', 'glyphword7_dmg_buff', min, max);
		damageVal.valueMultiplicative = 0;
		damageVal.valueAdditive = 0;
		damageVal.valueBase = CalculateAttributeValue(min);
		for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
		{
			dmgInfos[i].dmgVal += damageVal.valueBase;
		}
	}
	
	if( playerAttacker && action.IsActionWitcherSign() && playerAttacker.HasBuff(EET_Mutagen09) )
	{
		damageVal.valueMultiplicative = 0;
		damageVal.valueAdditive = 0;
		damageVal.valueBase = ((W3Mutagen09_Effect)playerAttacker.GetBuff(EET_Mutagen09)).GetM09Bonus();
		if( action.IsDoTDamage() )
			damageVal.valueBase *= action.GetDoTdt();
		for( i = 0 ; i < dmgInfos.Size() ; i += 1)
			dmgInfos[i].dmgVal += damageVal.valueBase;
	}
	
	if( playerAttacker && attackAction && attackAction.IsActionRanged() && ((W3BoltProjectile)action.causer) && !action.IsDoTDamage() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'mut9_damage', min, max);
		for( i = 0; i < dmgInfos.Size(); i += 1 )
			dmgInfos[i].dmgVal *= 1 + min.valueMultiplicative;
	}

	if( playerAttacker && (action.IsActionMelee() || action.IsActionWitcherSign()) && GetWitcherPlayer().IsMutationActive( EPMT_Mutation10 ) && GetWitcherPlayer().HasBuff(EET_Mutation10) )
	{
		damageVal.valueBase = 0;
		damageVal.valueMultiplicative = 0;
		damageVal.valueAdditive = 0;
		damageVal.valueBase += GetWitcherPlayer().GetToxicityDamage();
		if( action.IsDoTDamage() )
		{
			damageVal.valueBase *= action.GetDoTdt();
		}
		for( i = 0 ; i < dmgInfos.Size() ; i+=1)
		{
			dmgInfos[i].dmgVal += damageVal.valueBase;
		}
	}

	if( (W3PlayerWitcher)playerAttacker && action.IsActionRanged() && action.IsBouncedArrow() )
	{
		damageVal = actorVictim.GetPowerStatValue(CPS_AttackPower);
		for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
		{
			dmgInfos[i].dmgVal += damageVal.valueBase;
		}

		if( thePlayer.CanUseSkill(S_Sword_s10) && thePlayer.GetSkillLevel(S_Sword_s10) >= 2 )
		{
			dmgBonusMult += CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s10, 'damage_increase', false, true) ) * (thePlayer.GetSkillLevel(S_Sword_s10) - 1);
		}
	}
	
	if( actorAttacker && attackAction && actorAttacker.IsHeavyAttack(attackAction.GetAttackName()) )
	{
		if( playerAttacker == GetWitcherPlayer() )
		{
			damageBonus = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_2, 'heavy_attack_dmg_boost', false, true);
			dmgBonusMult += damageBonus.valueMultiplicative;
		}
		else
		{
			dmgBonusMult += 0.25;
		}
	}

	if(witcherAttacker)
	{
		if(action.IsActionMelee())
			dmgBonusMult += CalculateAttributeValue(witcherAttacker.GetAttributeValue( 'sword_dmg_bonus' ));
		if(action.IsActionWitcherSign())
			dmgBonusMult += CalculateAttributeValue(witcherAttacker.GetAttributeValue( 'spell_dmg_bonus' ));
	}

	if(witcherAttacker && attackAction && SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02 && spectreVanillaSkills())
	{
		// 5.01 tree: Rend's damage as in 5.01.
		rendRatio = witcherAttacker.GetSpecialAttackTimeRatio();
		rendLoad = MinF(rendRatio * witcherAttacker.GetStatMax(BCS_Focus), witcherAttacker.GetStat(BCS_Focus));
		if(rendLoad >= 1)
		{
			rendBonusPerPoint = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'adrenaline_damage_bonus', false, true);
			rendBonus = FloorF(rendLoad) * rendBonusPerPoint.valueMultiplicative * witcherAttacker.GetSkillLevel(S_Sword_s02);
			for(i=0; i<dmgInfos.Size(); i+=1)
				dmgInfos[i].dmgVal *= (1 + rendBonus);
		}
		staminaRendBonus = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'stamina_max_dmg_bonus', false, true);
		for(i=0; i<dmgInfos.Size(); i+=1)
			dmgInfos[i].dmgVal *= (1 + rendRatio * staminaRendBonus.valueMultiplicative);
		thePlayer.SetAttackActionName('');
	}
	else if(witcherAttacker && attackAction && SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
	{
		dmgBonusMult += witcherAttacker.GetRendPowerBonus();
	}

	if( witcherAttacker && actorVictim && attackAction.IsActionMelee() && GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_1 ) )
	{
		FindGameplayEntitiesInRange( entities, playerAttacker, 50, 1000, , FLAG_OnlyAliveActors );
		if( entities.Size() > 0 )
		{
			for( i=0; i<entities.Size(); i+=1 )
			{
				npcVictim = (CNewNPC) entities[i];
				if( npcVictim )
				{
					if( npcVictim.HasBuff( EET_Bleeding ) )  bonusCount += 1;
					if( npcVictim.HasBuff( EET_Bleeding1 ) ) bonusCount += 1;
					if( npcVictim.HasBuff( EET_Bleeding2 ) ) bonusCount += 1;
					if( npcVictim.HasBuff( EET_Bleeding3 ) ) bonusCount += 1;
				}
			}
			
			bonusCount *= ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped( EIST_Wolf );
			
			for( i=0; i<dmgInfos.Size() ; i+=1 )
			{
				dmgInfos[i].dmgVal *= 1 + bonusCount*0.01;
			}
		}
	}

	if(witcherAttacker && witcherAttacker.HasGlyphwordActive('Glyphword 4 _Stats') && action.IsActionMelee() && !witcherAttacker.IsDoingSpecialAttack(true) && !witcherAttacker.IsDoingSpecialAttack(false))
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 4 _Stats', 'glyphword4_mod', min, max);
		dmgBonusMult += CalculateAttributeValue(min);
	}
	
	// 5.01 tree: each alchemy rank also raises bomb damage (potion_duration, from alchemy_potionduration), as in 5.01.
	if ( spectreVanillaAlchemySkills() && playerAttacker && action.IsActionRanged() && ((W3Petard)action.causer) )
	{
		skillPassiveMod = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('potion_duration'));
		for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			dmgInfos[i].dmgVal *= ( 1 + skillPassiveMod );
	}

	// Each bomb bonus multiplies the damage on its own, as in 5.01.
	if ( playerAttacker && action.IsActionRanged() && ((W3Petard)action.causer) && !action.IsDoTDamage() )
	{
		if ( GetWitcherPlayer().CanUseSkill(S_Perk_20) && (!spectreVanillaSkills() || !action.IsDoTDamage()) )
		{
			perk20Bonus = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false);
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
				dmgInfos[i].dmgVal *= ( 1 + perk20Bonus.valueMultiplicative );
		}

		if ( GetWitcherPlayer().CanUseSkill(S_Perk_27) && (!spectreVanillaSkills() || !action.IsDoTDamage()) )
		{
			perk20Bonus = GetWitcherPlayer().GetAttributeValue('bomb_dmg_multiplier');
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
				dmgInfos[i].dmgVal *= ( 1 + perk20Bonus.valueMultiplicative );
		}

		if ( !playerVictim && playerAttacker.CanUseSkill(S_Alchemy_s25) && (!spectreVanillaAlchemySkills() || !action.IsDoTDamage()) )
		{
			tempBonus = playerAttacker.GetStat(BCS_Toxicity) * CalculateAttributeValue(playerAttacker.GetSkillAttributeValue( S_Alchemy_s25, 'bomb_damage_bonus', false, false) * playerAttacker.GetSkillLevel(S_Alchemy_s25));
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
				dmgInfos[i].dmgVal *= ( 1 + tempBonus );
		}
		
		if ( GetWitcherPlayer().CanUseSkill(S_Perk_44) && (!spectreVanillaSkills() || !action.IsDoTDamage()) )
		{
			thePlayer.AddEffectDefault( EET_ElementOfSurprise, NULL, "ElementOfSurpriseEffect" );
		}
	}
	
	if(actorVictim && playerAttacker && !action.IsDoTDamage() && actorVictim.HasBuff(EET_Frozen) && ((W3AardProjectile)action.causer || (W3AardEntity)action.causer || action.DealsPhysicalOrSilverDamage()))
	{
		frozenBuff = (W3Effect_Frozen)actorVictim.GetBuff(EET_Frozen);
		dm.GetAbilityAttributeValue(frozenBuff.GetAbilityName(), 'hpPercDamageBonusPerHit', min, max);
		bonusDamagePercents = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		dmgBonusMult += bonusDamagePercents;
		forceDamageIdx = -1;
		for(i = 0; i < dmgInfos.Size(); i += 1)
		{
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FORCE)
				forceDamageIdx = i;
		}
		
		if((W3AardProjectile)action.causer || (W3AardEntity)action.causer)
		{
			frozenDmgInfo.dmgVal = 0.05 * actorVictim.GetMaxHealth();
			frozenDmgInfo.dmgType = theGame.params.DAMAGE_NAME_FORCE;
			addForceDamage = true;
		}
		action.SetWasFrozen();
		actorVictim.RemoveAllBuffsOfType(EET_Frozen);
	}

	if ( actorVictim && playerAttacker && GetWitcherPlayer().CanUseSkill( S_Magic_s35 ) )
	{
		yrdens = GetWitcherPlayer().yrdenEntities;
		signSkillCatalystLevel = playerAttacker.GetSkillLevel( S_Magic_s35 );
		signSkillCatalystActive = yrdens.Size() > 0 && ( action.GetSignType() == ST_Aard || action.GetSignType() == ST_Igni );

		if ( signSkillCatalystActive )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(spectreSkillAbility('magic_s35'), 'spell_power_aard_igni', minCatalyst, maxCatalyst);
			extraSignDamageMult = minCatalyst.valueMultiplicative * signSkillCatalystLevel;

			for(i=0; i<yrdens.Size(); i+=1)
			{
				for(j=0; j<yrdens[i].validTargetsInArea.Size(); j+=1)
				{
					if(yrdens[i].validTargetsInArea[j] == actorVictim )
					{
						for ( dmgIdx = 0; dmgIdx < dmgInfos.Size(); dmgIdx += 1 )
						{
							dmgInfos[dmgIdx].dmgVal *= ( 1 + extraSignDamageMult );
						}
					}
				}
			}
		}
	}

	if( playerAttacker && attackAction && action.IsActionMelee() && playerAttacker.IsHeavyAttack( attackAction.GetAttackName() ) &&
		playerAttacker.CanUseSkill( S_Alchemy_s23 ) && GetWitcherPlayer().CanUseToxicShock() )
	{
		if ( actorVictim && actorVictim.HasBuff( EET_Poison ) )
		{
			alchemySkillToxicShockLevel = playerAttacker.GetSkillLevel(S_Alchemy_s23);
			// Spectre: 10 ranks, the same share of the attack's damage per rank.
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(spectreSkillAbility('alchemy_s23'), 'poison_dmg_level_1', minEnhanced, maxEnhanced);
			extraPoisonDamageMult = minEnhanced.valueMultiplicative * alchemySkillToxicShockLevel;

			toxicShockDamage.dmgType = theGame.params.DAMAGE_NAME_POISON;
			toxicShockDamage.dmgVal = action.GetDamageValueTotal() * extraPoisonDamageMult;
			dmgInfos.PushBack( toxicShockDamage );
			actorVictim.RemoveBuff( EET_Poison );
			GetWitcherPlayer().ConsumeToxicShock();
			thePlayer.AddTimer( 'ResetToxicShock', 5.0,,,, true );

			swordEntity = GetWitcherPlayer().GetHeldSwordEntity();
			if (swordEntity)
			{
				swordEntity.PlayEffect('toxic_shock_sword');
			}
		}
	}

	if ( playerAttacker && attackAction && attackAction.IsActionMelee() && thePlayer.HasBuff( EET_ElementOfSurprise ) )
	{
		survivalSkillElementOfSurpriseLevel = thePlayer.GetSkillLevel( S_Perk_44 );
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('perk_44', 'melee_damage_increase', minElementOfSurprise, maxElementOfSurprise);
		dmgBonusMult += minElementOfSurprise.valueMultiplicative * survivalSkillElementOfSurpriseLevel;
	}

	if(dmgBonusMult != 0)
	{
		for(i = 0 ; i < dmgInfos.Size(); i += 1)
		{
			dmgInfos[i].dmgVal *= 1 + dmgBonusMult;
		}
	}

	if(addForceDamage)
	{
		if(forceDamageIdx != -1)
			dmgInfos[forceDamageIdx].dmgVal += frozenDmgInfo.dmgVal;
		else
			dmgInfos.PushBack(frozenDmgInfo);
	}

	if ( actorVictim && playerAttacker && playerAttacker.CanUseSkill( S_Perk_37 ) )
	{
		conjunctionDamageMult = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue( S_Perk_37, 'damage_multiplier', false, false ) );
		conjunctionDamageMult = 1 + playerAttacker.GetSkillLevel( S_Perk_37 ) * conjunctionDamageMult;

		for ( i = 0; i < dmgInfos.Size(); i += 1 )
		{
			if ( IsDamageTypeAnyPhysicalType( dmgInfos[i].dmgType ) )
			{
				continue;
			}

			dmgInfos[i].dmgVal *= conjunctionDamageMult;
		}
	}

	npcVictim = (CNewNPC)actorVictim;
	if(npcVictim)
	{
		for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
		{
			dmgInfos[i].dmgVal *= 1 + npcVictim.GetCripplingStrikeDamageMultiplier();
		}
	}

	if(playerAttacker && playerAttacker.CanUseSkill(S_Perk_28))
	{
		for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
		{
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_POISON)
			{
				poisonDamageValue = playerAttacker.GetAttributeValue('poison_dmg_multiplier');
				dmgInfos[i].dmgVal *= 1 + poisonDamageValue.valueMultiplicative;
			}
		}
	}

	if( !playerAttacker && actorAttacker && playerVictim && playerVictim.CanUseSkill( S_Alchemy_s24 ) )
	{
		if ( playerVictim.GetStat( BCS_Toxicity, false ) / playerVictim.GetStatMax( BCS_Toxicity ) >= CalculateAttributeValue( playerVictim.GetSkillAttributeValue(S_Alchemy_s24, 'toxicity_threshold', false, true ) ) )
		{
			tempBonus = CalculateAttributeValue( playerVictim.GetSkillAttributeValue( S_Alchemy_s24, 'received_damage_multiplier', false, true ) );
			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal *= tempBonus;
			}
		}
	}

	if( actorVictim && playerAttacker && attackAction && attackAction.IsActionMelee() && playerAttacker.CanUseSkill(S_Alchemy_s26)
		&& playerAttacker.inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) )
	{
		monsterBonusType = MonsterCategoryToAttackPowerBonus(victimMonsterCategory);
		tempAttribute = playerAttacker.inv.GetItemAttributeValue(weaponId, monsterBonusType);

		if(tempAttribute != emptyAttribute && actorVictim.IsImmuneToBuff( EET_Poison ) )
		{
			tempBonus = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Alchemy_s26, 'damage_bonus_immune', false, true ) * playerAttacker.GetSkillLevel(S_Alchemy_s26) );
			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal *= 1 + tempBonus;
			}
		}
		else if(tempAttribute != emptyAttribute)
		{
			tempBonus = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Alchemy_s26, 'damage_bonus', false, true ) * playerAttacker.GetSkillLevel(S_Alchemy_s26) );
			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal *= 1 + tempBonus;
			}
		}
	}

	if( playerAttacker && attackAction && attackAction.IsActionMelee() && !playerAttacker.GetInventory().IsItemFists(weaponId) && playerAttacker.HasBuff(EET_Resonance) )
	{
		meleeAttackCounterForResonanceSkill = thePlayer.GetMeleeAttackCounterForResonanceSkill();
		if( meleeAttackCounterForResonanceSkill <= 3 )
		{
			tempAttribute = playerAttacker.GetPowerStatValue(CPS_SpellPower);
			tempBonus = tempAttribute.valueMultiplicative;
			tempBonus *= CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Magic_s41, 'sign_intensity_ratio', false, true ) * playerAttacker.GetSkillLevel(S_Magic_s41) );

			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal *= 1 + tempBonus;
			}

			if (meleeAttackCounterForResonanceSkill == 3)
			{
				playerAttacker.RemoveBuff(EET_Resonance);
				thePlayer.SetMeleeAttackCounterForResonanceSkill(1);

				if(GetWitcherPlayer())
				{
					GetWitcherPlayer().StopEffect('resonance_sword');
				}
			}
			else
			{
				thePlayer.SetMeleeAttackCounterForResonanceSkill(meleeAttackCounterForResonanceSkill+1);
			}
		}
	}

	if( attackAction && attackAction.GetAttackName() == 'bolt' )
	{
		if(thePlayer.CanUseSkill(S_Sword_s26))
		{
			tempBonus = ProcessNewSkill_AnatomicalKnowledge();
			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal += tempBonus;
			}
		}

		if(attackAction.GetIsHeadShot() && playerAttacker && playerAttacker.CanUseSkill(S_Sword_s32))
		{
			tempBonus = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Sword_s32, 'damage_increase', false, true ));
			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal *= 1 + tempBonus;
			}
		}
	}

	action.SetDTs(dmgInfos);
}

@addMethod( W3DamageManagerProcessor ) function ProcessDamageDecrease()
{
	var quen : W3QuenEntity;
	
	if(playerVictim && playerVictim.HasBuff(EET_Mutagen19))
	{
		((W3Mutagen19_Effect)playerVictim.GetBuff(EET_Mutagen19)).ProtectiveQuen(action);
	}
	
	if(playerVictim == GetWitcherPlayer() && GetWitcherPlayer().IsAnyQuenActive())
	{
		action.RemoveBuffsByType(EET_SlowdownFrost);
		action.RemoveBuffsByType(EET_Paralyzed);
	}
	
	if(playerVictim == GetWitcherPlayer())
	{
		quen = (W3QuenEntity)GetWitcherPlayer().GetSignEntity(ST_Quen);
		if(quen && quen.IsAnyQuenActive())
			quen.OnTargetHit(action);
	}
}

@wrapMethod( W3DamageManagerProcessor ) function ProcessActionReturnedDamage()
{
	var witcher 																			: W3PlayerWitcher;
	var quen 																				: W3QuenEntity;
	var params 																				: SCustomEffectParams;
	var processFireShield, canBeParried, canBeDodged, wasParried, wasDodged, returned 		: bool;
	var g5Chance																			: SAbilityAttributeValue;
	var dist, checkDist																		: float;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(action.WasDodged())
		return;
	
	if((W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !action.IsDoTDamage() && action.IsActionMelee() && (attackerMonsterCategory == MC_Necrophage || attackerMonsterCategory == MC_Vampire) && actorVictim.HasBuff(EET_BlackBlood))
	{
		returned = ProcessActionBlackBloodReturnedDamage();		
	}
	
	
	if(action.IsActionMelee() && actorVictim.HasAbility( 'Thorns' ) )
	{
		returned = ProcessActionThornDamage() || returned;
	}
	
	if(playerVictim && !playerAttacker && actorAttacker && attackAction && attackAction.IsActionMelee() && thePlayer.HasBuff(EET_Mutagen26))
	{
		returned = ProcessActionLeshenMutagenDamage() || returned;
	}
	
	
	if(action.IsActionMelee() && actorVictim.HasAbility( 'FireShield' ) )
	{
		witcher = GetWitcherPlayer();			
		processFireShield = true;			
		if(playerAttacker == witcher)
		{
			quen = (W3QuenEntity)witcher.GetSignEntity(ST_Quen);
			if(quen && quen.IsAnyQuenActive())
			{
				processFireShield = false;
			}
		}
		
		if(processFireShield)
		{
			params.effectType = EET_Burning;
			params.creator = actorVictim;
			params.sourceName = actorVictim.GetName();
			
			params.effectValue.valueMultiplicative = 0.01;
			actorAttacker.AddEffectCustom(params);
			returned = true;
		}
	}
	
	
	if(actorAttacker.UsesEssence())
	{
		returned = ProcessSilverStudsReturnedDamage() || returned;
	}
		
	
	if( (W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !playerAttacker.IsInFistFightMiniGame() && !action.IsDoTDamage() && action.IsActionMelee() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation4 ) )
	{
		
		dist = VecDistance( actorAttacker.GetWorldPosition(), actorVictim.GetWorldPosition() );
		checkDist = 3.f;
		if( actorAttacker.IsHuge() )
		{
			checkDist += 3.f;
		}

		if( dist <= checkDist )
		{
			returned = GetWitcherPlayer().ProcessActionMutation4ReturnedDamage( action.processedDmg.vitalityDamage, actorAttacker, EAHA_ForceYes, action ) || returned;
		}
	}
	
	action.SetWasDamageReturnedToAttacker( returned );
}

@wrapMethod( W3DamageManagerProcessor ) function ProcessActionLeshenMutagenDamage() : bool
{
	var damageAction : W3DamageAction;
	var returnedDamage, pts, perc : float;
	var mutagen : W3Mutagen26_Effect;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	mutagen = (W3Mutagen26_Effect)playerVictim.GetBuff(EET_Mutagen26);
	mutagen.GetReturnedDamage(pts, perc);
	
	if(pts <= 0 && perc <= 0)
		return false;
	
	if(action.GetDamageDealt() <= 0)
		return false;													   

	returnedDamage = pts + perc * action.GetDamageDealt();
	
	if(returnedDamage <= 0)
		return false;
	
	damageAction = new W3DamageAction in this;
	damageAction.Initialize( action.victim, action.attacker, NULL, "Mutagen26", EHRT_None, CPS_Undefined, true, false, false, false );
	damageAction.SetCannotReturnDamage( true );
	damageAction.SetHitAnimationPlayType( EAHA_ForceNo );
	damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
	damageAction.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, returnedDamage);
	
	theGame.damageMgr.ProcessAction(damageAction);
	delete damageAction;
	
	return true;
}

@wrapMethod( W3DamageManagerProcessor ) function ProcessSilverStudsReturnedDamage() : bool
{
	var damageAction : W3DamageAction;
	var returnedDamage : float;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	returnedDamage = CalculateAttributeValue(actorVictim.GetAttributeValue('returned_silver_damage'));
	
	if(returnedDamage <= 0)
		return false;
	
	damageAction = new W3DamageAction in this;		
	damageAction.Initialize( action.victim, action.attacker, NULL, "SilverStuds", EHRT_None, CPS_Undefined, true, false, false, false );
	damageAction.SetCannotReturnDamage( true );		
	damageAction.SetHitAnimationPlayType( EAHA_ForceNo );		
	
	damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
	
	theGame.damageMgr.ProcessAction(damageAction);
	delete damageAction;
	
	return true;
}

@wrapMethod( W3DamageManagerProcessor ) function ProcessActionBlackBloodReturnedDamage() : bool
{
	var returnedAction : W3DamageAction;
	var returnVal : SAbilityAttributeValue;
	var bb : W3Potion_BlackBlood;
	var potionLevel : int;
	var procDmg, returnedDamage : float;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	procDmg = action.GetDamageDealt();
	
	if(procDmg <= 0)
		return false;
	
	bb = (W3Potion_BlackBlood)actorVictim.GetBuff(EET_BlackBlood);
	potionLevel = bb.GetBuffLevel();
	
	returnVal = bb.GetReturnDamageValue();
	
	returnedDamage = (returnVal.valueBase + procDmg) * returnVal.valueMultiplicative + returnVal.valueAdditive;
	
	if(returnedDamage <= 0)
		return false;

	returnedAction = new W3DamageAction in this;
	returnedAction.Initialize( action.victim, action.attacker, bb, "BlackBlood", EHRT_None, CPS_Undefined, true, false, false, false );
	returnedAction.SetCannotReturnDamage( true );
	
	if(potionLevel == 1)
	{
		returnedAction.SetHitAnimationPlayType(EAHA_ForceNo);
	}
	else
	{
		returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
		returnedAction.SetHitReactionType(EHRT_Reflect);
	}
	
	returnedAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
	returnedAction.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, returnedDamage);
	
	theGame.damageMgr.ProcessAction(returnedAction);
	delete returnedAction;
	
	return true;
}

@wrapMethod( W3DamageManagerProcessor ) function ProcessActionThornDamage() : bool
{
	var damageAction 		: W3DamageAction;
	var damageVal 			: SAbilityAttributeValue;
	var damage				: float;
	var inv					: CInventoryComponent;
	var damageNames			: array < CName >;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	inv = actorAttacker.GetInventory();
	inv.GetWeaponDTNames( weaponId, damageNames );
	damage = actorAttacker.GetTotalWeaponDamage( weaponId, damageNames[0], GetInvalidUniqueId() );
	
	if( damage == 0 )
	{
		damage = 300;
	}
	
	damage *= 0.10f;
	
	if(damage <= 0)
		return false;
		
	damageAction = new W3DamageAction in this;
	damageAction.Initialize( action.victim, action.attacker, NULL, "Thorns", EHRT_Light, CPS_AttackPower, true, false, false, false );
	damageAction.SetCannotReturnDamage( true );
	damageAction.AddDamage( theGame.params.DAMAGE_NAME_PIERCING, damage );
	damageAction.SetHitAnimationPlayType( EAHA_ForceYes );
	theGame.damageMgr.ProcessAction( damageAction );
	delete damageAction;
	return true;
}

@wrapMethod( W3DamageManagerProcessor ) function GetAttackersPowerMod() : SAbilityAttributeValue
{		
	var powerMod, criticalDamageBonus, min, max, critReduction, sp 	: SAbilityAttributeValue;					
	var totalBonus, tempBonus										: float;
	var yrdenEnt 													: W3YrdenEntity;
	var aerondight													: W3Effect_Aerondight;
	var lynxSetBuff 												: W3Effect_LynxSetBonus;
	
	if(false) 
	{
		wrappedMethod();
	}
					
	if( thePlayer.IsFistFightMinigameEnabled() || weaponsAreNotDeadly )
	{
		powerMod.valueBase = 0;
		powerMod.valueMultiplicative = 1;
		powerMod.valueAdditive = 0;
		return powerMod;
	}

	if( action.IsDoTDamage() )
	{
		powerMod.valueMultiplicative = 1;
		powerMod.valueBase = 0;
		powerMod.valueAdditive = 0;
		return powerMod;
	}
	
	powerMod = action.GetPowerStatValue();

	if ( playerAttacker && (W3AardProjectile)action.causer )
		powerMod.valueMultiplicative = 1 + (powerMod.valueMultiplicative - 1) * theGame.params.AARD_SPELL_POWER_MULT;

	if( attackAction && attackAction.GetAttackName() == 'bolt' && attackAction.GetIsHeadShot() && playerAttacker && playerAttacker.CanUseSkill(S_Sword_s32) )
	{
		tempBonus = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Sword_s32, 'damage_increase', false, true ));
		powerMod.valueAdditive *= 1 + tempBonus;
	}

	if ( powerMod.valueAdditive == 0 && powerMod.valueBase == 0 && powerMod.valueMultiplicative == 0 && theGame.CanLog() )
	{
		LogDMHits("Attacker has power stat of 0!", action);
	}

	if( (W3PlayerWitcher)playerAttacker && action.IsActionWitcherSign() && StrContains(action.GetBuffSourceName(), "_sign_yrden_alt") )
	{
		yrdenEnt = (W3YrdenEntity)((W3PlayerWitcher)playerAttacker).GetSignEntity(ST_Yrden);
		if( yrdenEnt )
		{
			sp = yrdenEnt.GetCachedYrdenPower();
			if( !( sp.valueAdditive == 0 && sp.valueBase == 0 && sp.valueMultiplicative == 0 ) )				  
			{
				powerMod = sp;
			}
		}
	}

	if((W3PlayerWitcher)playerAttacker && thePlayer.IsDoingSpecialAttack(false) && thePlayer.GetStat(BCS_Focus) > 0)
	{
		powerMod.valueMultiplicative += ((W3PlayerWitcher)playerAttacker).GetWhirlDamageBonus();
	}

	if( (W3PlayerWitcher)playerAttacker && attackAction && attackAction.IsActionMelee() && playerAttacker.HasBuff( EET_LynxSetBonus ) )
	{
		lynxSetBuff = (W3Effect_LynxSetBonus)playerAttacker.GetBuff( EET_LynxSetBonus );
		powerMod.valueMultiplicative += lynxSetBuff.GetLynxBonus( playerAttacker.IsHeavyAttack( attackAction.GetAttackName() ) );
	}

	if( (W3PlayerWitcher)playerAttacker && attackAction && (attackAction.IsActionMelee() || attackAction.IsActionRanged()) && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive( EISB_Bear_1 ) )
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetSetBonusAbility(EISB_Bear_1), 'attack_power', min, max);
		powerMod.valueMultiplicative += min.valueMultiplicative * ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped(EIST_Bear) * FloorF(thePlayer.GetStat(BCS_Focus));
	}

	if(action.GetIsHeadShot())
	{
		powerMod.valueMultiplicative += theGame.params.HEAD_SHOT_DAMAGE_BONUS;
	}

	if(actorVictim && actorAttacker && actorVictim.IsAttackerAtBack(actorAttacker))
	{
		powerMod.valueMultiplicative += theGame.params.BACK_ATTACK_DAMAGE_BONUS;
	}

	if(action.IsCriticalHit())
	{
		if( playerAttacker && action.IsActionWitcherSign() && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_damage_factor', min, max);				
			criticalDamageBonus.valueAdditive = min.valueAdditive + SignPowerStatToPowerBonus(powerMod.valueMultiplicative) * min.valueMultiplicative;
		}
		else
		{
			criticalDamageBonus = actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker));
			// As in 5.01: despite its name, it is critical damage, on every hit (the 5.01 Cat School).
			criticalDamageBonus += actorAttacker.GetAttributeValue('critical_hit_chance_fast_style');
			
			if(playerAttacker && attackAction && attackAction.IsActionMelee())
			{
				if(playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s08))
				{
					criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s08);
				}
				else if (!playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s17))
				{
					criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s17);
				}
			}
			
			if( (W3PlayerWitcher)playerAttacker && (W3BoltProjectile)action.causer )
			{
				if( playerAttacker.CanUseSkill(S_Sword_s07) )
				{
					criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s07);
				}
				
				if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'critical_damage', min, max );
					criticalDamageBonus += min;
				}
			}
		}

		if( playerAttacker && actorVictim && attackAction && action.IsActionMelee() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
		{	
			aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
			if( aerondight && aerondight.IsFullyCharged() )
				criticalDamageBonus.valueAdditive += aerondight.GetCritPowerBoost();
		}

		if( ( W3Petard )action.causer && ( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsSetBonusActive( EISB_RedWolf_1 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_RedWolf_1 ), 'per_redwolf_piece_crit_power_bonus', min, max );
			min.valueAdditive *= GetWitcherPlayer().GetSetPartsEquipped( EIST_RedWolf );
			criticalDamageBonus += min;
		}

		if ( thePlayer.CanUseSkill( S_Alchemy_s27 ) && thePlayer.GetStatMax(BCS_Focus) == thePlayer.GetStat(BCS_Focus) && IsMonsterOilTarget() )
			criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Alchemy_s27, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Alchemy_s27);

		totalBonus = CalculateAttributeValue(criticalDamageBonus);
		critReduction = actorVictim.GetAttributeValue(theGame.params.CRITICAL_HIT_REDUCTION);
		totalBonus = totalBonus * ClampF(1 - critReduction.valueMultiplicative, 0.f, 1.f);

		powerMod.valueMultiplicative += totalBonus;
	}
	
	if( (W3PlayerWitcher)playerAttacker && action.IsActionRanged() && (W3BoltProjectile)action.causer )
	{
		powerMod.valueAdditive = 0;
	}

	powerMod.valueBase = MaxF(powerMod.valueBase, 0);
	powerMod.valueMultiplicative = MaxF(powerMod.valueMultiplicative, 0);
	powerMod.valueAdditive = MaxF(powerMod.valueAdditive, 0);
	
	return powerMod;
}

@replaceMethod( W3DamageManagerProcessor ) function GetDamageResists(dmgType : name, out resistPts : float, out resistPerc : float)
{
	var armorReduction, armorReductionPerc, skillArmorReduction : SAbilityAttributeValue;
	var bonusReduct, bonusResist, armorVal : float;
	var encumbranceBonus : float;
	var temp : bool;
	var mutagen : CBaseGameplayEffect;
	var min, max : SAbilityAttributeValue;
	var i : int;
	var meltArmorDebuff : float;
	var meltAblCount : int;
	var dbombEffect : W3Effect_DimeritiumEffect;
	var dbombArmorDebuff, dbombResReduction : float;
	var aerondight : W3Effect_Aerondight;
	
	if(thePlayer.IsFistFightMinigameEnabled())
	{
		resistPts = 0;
		resistPerc = 0;
		return;
	}
	
	if(action.GetIsHeadShot())
	{
		actorVictim.SignalGameplayEvent( 'Headshot' );
		resistPts = 0;
		resistPerc = 0;
		return;
	}

	if(playerAttacker && actorVictim && attackAction && action.IsActionMelee() && playerAttacker.inv.ItemHasTag(attackAction.GetWeaponId(), 'Aerondight'))
	{	
		aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff(EET_Aerondight);
		if(aerondight && aerondight.IsFullyCharged())
		{
			resistPts = 0;
			resistPerc = 0;
			return;
		}
	}

	if(action.GetBuffSourceName() == "PhantomWeapon")
	{
		resistPts = 0;
		resistPerc = 0;
		return;
	}

	if(actorVictim)
	{
		actorVictim.GetResistValue( GetResistForDamage(dmgType, action.IsDoTDamage()), resistPts, resistPerc );

		// 5.01 tree: Protective Coating as in 5.01 (Spectre's version is in W3PlayerWitcher.ReduceDamage).
		if(spectreVanillaAlchemySkills() && playerVictim && actorAttacker && playerVictim.CanUseSkill(S_Alchemy_s05))
		{
			GetOilProtectionAgainstMonster(dmgType, bonusResist, bonusReduct);
			resistPerc += bonusResist * playerVictim.GetSkillLevel(S_Alchemy_s05);
		}

		if(actorAttacker)
		{
			armorReduction = actorAttacker.GetAttributeValue('armor_reduction');
			armorReductionPerc = actorAttacker.GetAttributeValue('armor_reduction_perc');

			if(playerAttacker && playerAttacker.GetInventory().ItemHasActiveOilApplied( weaponId, victimMonsterCategory ))
			{
				armorReductionPerc += actorAttacker.GetInventory().GetOilResistReductionBonus( weaponId, victimMonsterCategory );
			}
	
			if( attackAction && playerAttacker && playerAttacker.CanUseSkill(S_Sword_2) && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) )
			{
				armorReduction += playerAttacker.GetSkillAttributeValue(S_Sword_2, 'armor_reduction', false, true);
			}
			
			if ( playerAttacker && attackAction &&
				 action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) &&
				 ( dmgType == theGame.params.DAMAGE_NAME_PHYSICAL ||
				   dmgType == theGame.params.DAMAGE_NAME_SLASHING ||
				   dmgType == theGame.params.DAMAGE_NAME_PIERCING ||
				   dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING ||
				   dmgType == theGame.params.DAMAGE_NAME_RENDING ||
				   dmgType == theGame.params.DAMAGE_NAME_SILVER
				 )
			   )
			{
				if( playerAttacker.CanUseSkill(S_Sword_s06) )
				{
					skillArmorReduction = playerAttacker.GetSkillAttributeValue(S_Sword_s06, 'armor_reduction_perc', false, true);
					armorReductionPerc += skillArmorReduction * playerAttacker.GetSkillLevel(S_Sword_s06);
				}
				if( playerAttacker.CanUseSkill(S_Sword_s28) && (CNewNPC)actorVictim )
				{
					armorReductionPerc.valueAdditive += ((CNewNPC)actorVictim).GetSunderArmorPercent();
				}
			}
		}
	}
	
	if(!action.GetIgnoreArmor())
	{
		resistPts += CalculateAttributeValue( actorVictim.GetTotalArmor() );
	}

	if( actorVictim != thePlayer && actorVictim.HasBuff(EET_DimeritiumEffect) )
	{
		dbombEffect = (W3Effect_DimeritiumEffect)actorVictim.GetBuff(EET_DimeritiumEffect);
		if(dbombEffect)
			dbombArmorDebuff = dbombEffect.GetArmorPiercing();
	}

	resistPts = MaxF(0, resistPts - CalculateAttributeValue(armorReduction) - dbombArmorDebuff);

	resistPts = MaxF(0, resistPts);
	
	if(action.IsPointResistIgnored() || action.IsDoTDamage())
	{
		resistPts = 0;
	}

	if(playerAttacker && dmgType == theGame.params.DAMAGE_NAME_SHOCK)
	{
		resistPts = 0;
	}

	if( !action.IsDoTDamage() && actorAttacker && actorVictim && actorVictim.HasAbility( 'IceArmor' ) && !actorAttacker.HasAbility( 'Ciri_Rage' ) )
	{
		if( theGame.GetDifficultyMode() != EDM_Easy )
		{
			resistPerc += 0.3;
		}
	}

	if( actorVictim != thePlayer && actorVictim.HasBuff(EET_DimeritiumEffect) )
	{
		dbombEffect = (W3Effect_DimeritiumEffect)actorVictim.GetBuff(EET_DimeritiumEffect);
		if(dbombEffect)
			dbombResReduction = dbombEffect.GetResistReduction();
	}

	if (playerVictim && playerVictim.CanUseSkill(S_Alchemy_s22) && actorAttacker && actorAttacker.HasBuff(EET_Poison))
	{
		resistPerc += CalculateAttributeValue( playerVictim.GetSkillAttributeValue(S_Alchemy_s22, 'defence_bonus', false, true ) ) * playerVictim.GetSkillLevel(S_Alchemy_s22);
	}

	if(actorVictim && actorVictim != thePlayer && actorVictim.HasAbility('Mutagen02Effect'))
	{
		resistPerc -= CalculateAttributeValue(actorVictim.GetAttributeValue('mutagen02_resist_reduction'));
		resistPerc = MaxF(0, resistPerc);
	}
		
	armorVal = resistPerc - CalculateAttributeValue(armorReductionPerc) - dbombResReduction;
	if(armorVal < 0)
		resistPts = MaxF(0, resistPts * (1 + armorVal));
	resistPerc = MaxF(0, armorVal);
	
	if( actorVictim != thePlayer && meltArmorDebuff > 0 )
	{
		resistPerc *= ClampF(1 - meltArmorDebuff, 0.0f, 1.0f);
	}
	
	hasArmor = (resistPts > 0);
}

@addMethod(W3DamageManagerProcessor) function GetAttackerAbilities()
{
	var arrNames, arrUniqueNames : array< name >;
	var i : int;

	actorAttacker.GetCharacterStats().GetAbilities( arrNames, false );
	ArrayOfNamesAppendUnique(arrUniqueNames, arrNames);
	if(arrUniqueNames.Size() > 0)
	{
		for( i = 0; i < arrUniqueNames.Size(); i += 1 )
			theGame.witcherLog.AddCombatMessage("Ability:" + arrUniqueNames[i], thePlayer, NULL);
	}
}

@wrapMethod( W3DamageManagerProcessor ) function CalculateDamage(dmgInfo : SRawDamage, powerMod : SAbilityAttributeValue) : float
{
	var rawDamage, finalDamage, finalIncomingDamage : float;
	var resistPoints, resistPercents : float;
	var npcAttacker : CNewNPC;
	var maxAllowedDmg, minAllowedDmg, mutagen14bonus : float ;
	var axiiLvl : float;
	var puppetBonus : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(dmgInfo , powerMod);
	}
	
	if(actorVictim.UsesVitality() && !DamageHitsVitality(dmgInfo.dmgType))
		return 0;
	
	if(actorVictim.UsesEssence() && !DamageHitsEssence(dmgInfo.dmgType))
		return 0;
	
	if(dmgInfo.dmgVal <= 0)
		return 0;
	
	if( !thePlayer.IsFistFightMinigameEnabled() && weaponsAreNotDeadly )
		return 10;
		
	npcAttacker = (CNewNPC)actorAttacker;

	GetDamageResists(dmgInfo.dmgType, resistPoints, resistPercents);

	rawDamage = MaxF(0, dmgInfo.dmgVal + powerMod.valueBase - resistPoints);

	finalDamage = MaxF(0, rawDamage * powerMod.valueMultiplicative + powerMod.valueAdditive);

	if( !action.IsDoTDamage() && npcAttacker && actorVictim && GetAttitudeBetween(npcAttacker, thePlayer) == AIA_Friendly && GetAttitudeBetween(actorVictim, thePlayer) == AIA_Hostile )
	{
		if( npcAttacker.HasBuff( EET_AxiiGuardMe ) )
		{
			axiiLvl = CalculateAttributeValue(npcAttacker.GetAttributeValue('alt_axii_level'));
			// Puppet: Spectre's rank 3 damage is 100%, and each rank adds 10% on top.
			puppetBonus = thePlayer.GetSkillAttributeValue(S_Magic_s05, 'attack_power', false, false);
			axiiLvl = 1 + axiiLvl * puppetBonus.valueMultiplicative;
			
			if( thePlayer.HasBuff(EET_Mutagen14) )
			{
				mutagen14bonus = ((W3Mutagen14_Effect)thePlayer.GetBuff(EET_Mutagen14)).GetMutagen14Bonus();
				maxAllowedDmg = MaxF(20, 0.12 * (1 + mutagen14bonus) * actorVictim.GetMaxHealth() * axiiLvl);
				minAllowedDmg = MaxF(10, 0.06 * (1 + mutagen14bonus) * actorVictim.GetMaxHealth() * axiiLvl);
			}
			else
			{
				maxAllowedDmg = MaxF(20, 0.12 * actorVictim.GetMaxHealth() * axiiLvl);
				minAllowedDmg = MaxF(10, 0.06 * actorVictim.GetMaxHealth() * axiiLvl);
			}
		}
		else if( npcAttacker.HasTag('mq1041_soldier') || npcAttacker.HasTag('mq1041_redanian') )
		{
			maxAllowedDmg = MaxF(20, 0.15 * actorVictim.GetMaxHealth());
			minAllowedDmg = MaxF(10, 0.10 * actorVictim.GetMaxHealth());
		}
		else
		{
			maxAllowedDmg = MaxF(20, 0.04 * actorVictim.GetMaxHealth());
			minAllowedDmg = MaxF(10, 0.02 * actorVictim.GetMaxHealth());
		}

		finalDamage = RandRangeF(maxAllowedDmg, minAllowedDmg);

		finalDamage = MaxF(10, finalDamage);

		if( npcAttacker.HasBuff( EET_AxiiGuardMe ) && thePlayer.CanUseSkill( S_Magic_s31 ) )
			finalDamage *= 1 + thePlayer.GetSkillLevel( S_Magic_s31 ) * CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Magic_s31, 'attack_power', false, true ) );

		if( FactsQuerySum( "modSpectre_zero_ally_dmg" ) > 0 )
			finalDamage = 0; 
	}
	
	finalIncomingDamage = finalDamage;
	
	if(finalDamage > 0.f)
	{
		finalDamage *= ClampF(1 - resistPercents, 0, 1);
	}

	if(finalDamage > 0 && dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE)
	{
		action.SetDealtFireDamage(true);
	}
		
	return finalDamage;
}

@addMethod( W3DamageManagerProcessor ) function ProcessDamageModification()
{
	var min, max : SAbilityAttributeValue;
	var mult, dmg : float;
	var ignoreDifficultySettings : bool;
	var npcAttacker, npcVictim : CNewNPC;
	
	npcAttacker = (CNewNPC)actorAttacker;
	npcVictim = (CNewNPC)actorVictim;
					
	ignoreDifficultySettings = actorAttacker.IgnoresDifficultySettings();
								 
	if(!action.DealsAnyDamage() || action.WasDodged() || action.IsDoTDamage() && (CBaseGameplayEffect)action.causer)
		return;
					
	if( (W3PlayerWitcher)playerAttacker )
	{
		if( (CThrowable)action.causer && ((W3PlayerWitcher)playerAttacker).CanUseSkill( S_Perk_16 ) )
		{
			mult = 0.5;
			action.processedDmg.vitalityDamage *= mult;
			action.processedDmg.essenceDamage *= mult;
		}

		if( (CThrowable)action.causer && !((CThrowable)action.causer).IsFromAimThrow() && !action.IsBouncedArrow() )
		{
			mult = 0.5;
			action.processedDmg.vitalityDamage *= mult;
			action.processedDmg.essenceDamage *= mult;
		}

		if( action.IsActionWitcherSign() && actorVictim.UsesVitality() )
		{
			mult = (0.75 - 0.5 * MaxF(0, 1 - 0.1 * (actorAttacker.GetLevel() - 1)));
			action.processedDmg.vitalityDamage *= mult;
			action.processedDmg.essenceDamage *= mult;
		}

		if( action.IsActionMelee() && ( thePlayer.IsDoingSpecialAttack(false) || thePlayer.IsDoingSpecialAttack(true) ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 2 _Stats', 'runeword2_damage_debuff', min, max);
			mult = CalculateAttributeValue(min);
			action.processedDmg.vitalityDamage *= 1 - mult;
			action.processedDmg.essenceDamage *= 1 - mult;
		}

		if( actorVictim.HasBuff(EET_YrdenHealthDrain) )
		{
			mult = ((W3Effect_YrdenHealthDrain)actorVictim.GetBuff(EET_YrdenHealthDrain)).GetDmgBonus();
			action.processedDmg.vitalityDamage *= 1 + mult;
			action.processedDmg.essenceDamage *= 1 + mult;
		}

		if( attackAction && attackAction.IsActionMelee() && playerAttacker.IsLightAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s05) && actorVictim.HasBuff(EET_Bleeding) )
		{
			mult = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'sword_s5_dmg_boost', false, true)) * playerAttacker.GetSkillLevel(S_Sword_s05);
			action.processedDmg.vitalityDamage *= 1 + mult;
			action.processedDmg.essenceDamage *= 1 + mult;
		}
		
		if( attackAction && attackAction.IsActionMelee() && ((W3PlayerWitcher)playerAttacker).IsMutationActive(EPMT_Mutation8) && actorVictim && actorVictim.WasCountered() )
		{
			dm.GetAbilityAttributeValue( 'Mutation8', 'dmg_bonus', min, max );
			mult = min.valueMultiplicative * playerAttacker.GetStat(BCS_Focus);
			action.processedDmg.vitalityDamage *= 1 + mult;
			action.processedDmg.essenceDamage *= 1 + mult;
		}
	}
	
	if(!thePlayer.IsFistFightMinigameEnabled() && weaponsAreNotDeadly)
	{
		if(playerAttacker)
		{
			if(actorVictim.HasAbility('mon_ff204olaf') || actorVictim.HasAbility('mon_ff205troll'))
				mult = 0.5;
			else
				mult = 1;
		}
		else if(actorAttacker.HasAbility('fistfight_q002'))
			mult = 0.25;
		else
			mult = 0.25 + MaxF(0, (int)theGame.GetSpawnDifficultyMode() - 1) * 0.25 + 0.1 * ClampF(actorAttacker.GetLevel() - actorVictim.GetLevel(), -10, 10);
		if(actorVictim.UsesEssence())
		{
			action.processedDmg.essenceDamage = 0.2 * (1 + 1 * (int)actorAttacker.IsHeavyAttack(attackAction.GetAttackName())) * actorVictim.GetMaxHealth();
			action.processedDmg.essenceDamage *= mult;
		}
		else if(actorVictim.UsesVitality())
		{
			action.processedDmg.vitalityDamage = 0.2 * (1 + 1 * (int)actorAttacker.IsHeavyAttack(attackAction.GetAttackName())) * actorVictim.GetMaxHealth();
			action.processedDmg.vitalityDamage *= mult;
		}
		ignoreDifficultySettings = true;
	}
	
	if( actorAttacker && actorAttacker != thePlayer && !ignoreDifficultySettings && actorVictim && actorVictim == thePlayer && GetAttitudeBetween(actorAttacker, thePlayer) == AIA_Hostile )
	{
		if(thePlayer.IsFistFightMinigameEnabled())
			mult = 1.0 + ((int)theGame.GetSpawnDifficultyMode() - 1) * 0.25 + 0.1 * ClampF(actorAttacker.GetLevel() - actorVictim.GetLevel(), -10, 10);
		else
			mult = CalculateAttributeValue(actorAttacker.GetAttributeValue(theGame.params.DIFFICULTY_DMG_MULTIPLIER));
		action.processedDmg.vitalityDamage *= mult;
		action.processedDmg.essenceDamage *= mult;
	}

	if( npcAttacker && npcVictim && GetAttitudeBetween(npcAttacker, npcVictim) == AIA_Friendly )
	{
		mult = 0.25;
		action.processedDmg.vitalityDamage *= mult;
		action.processedDmg.essenceDamage *= mult;
	}

	if( (W3PlayerWitcher)playerVictim && actorAttacker && actorAttacker.HasBuff(EET_DimeritiumEffect) )
	{
		mult = 1 - ((W3Effect_DimeritiumEffect)actorAttacker.GetBuff(EET_DimeritiumEffect)).GetDamageReduction();
		action.processedDmg.vitalityDamage *= mult;
		action.processedDmg.essenceDamage *= mult;
	}

	if( action.processedDmg.vitalityDamage < 1.f && !action.IsDoTDamage() )
	{
		action.processedDmg.vitalityDamage = 0;
	}
	
	if( action.processedDmg.essenceDamage < 1.f && !action.IsDoTDamage() )
	{
		action.processedDmg.essenceDamage = 0;
	}

	if( !action.DealsAnyDamage() && hasArmor )
	{
		action.SetArmorReducedDamageToZero(true);
	}
}

@addField(W3DamageManagerProcessor)
private var confusionInstakillTested : bool;
	
@addMethod(W3DamageManagerProcessor) function IsAxiiInstakillTarget() : bool
{
	return (!playerVictim && actorVictim && !((W3MonsterHuntNPC)actorVictim) && !actorVictim.IsImmuneToInstantKill() && actorVictim.IsAlive() && attackAction && attackAction.DealsAnyDamage() && (actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe)));
}

@addMethod(W3DamageManagerProcessor) function GetAxiiInstakillChance() : int
{
	var chance : int;
	var victimHealth, damageSeverity : float;
	var sp : SAbilityAttributeValue;
	
	if(IsAxiiInstakillTarget())
	{
		victimHealth = victimHealthPercBeforeHit * actorVictim.GetMaxHealth();
		damageSeverity = ClampF(action.GetDamageDealt() / victimHealth, 0.f, 1.f);
		chance = 1 + RoundMath(damageSeverity * 33.4);
		if(actorVictim.HasBuff(EET_Confusion) && ((W3ConfuseEffect)actorVictim.GetBuff(EET_Confusion)).IsSignEffect())
		{
			sp = ((W3ConfuseEffect)actorVictim.GetBuff(EET_Confusion)).GetCreatorPowerStat();
			chance = RoundMath(chance * (1 + SignPowerStatToPowerBonus(sp.valueMultiplicative)));
		}
	}
	
	return chance;
}	

@replaceMethod( W3DamageManagerProcessor ) function ProcessActionReaction(wasFrozen : bool, wasAlive : bool)
{
	var dismemberExplosion 			: bool;
	var damageName 					: name;
	var damage 						: array<SRawDamage>;
	var points, percents, hp, dmg 	: float;
	var counterAction 				: W3DamageAction;		
	var moveTargets					: array<CActor>;
	var i 							: int;
	var canPerformFinisher			: bool;
	var canDismember				: bool;
	var weaponName					: name;
	var npcVictim					: CNewNPC;
	var toxicCloud					: W3ToxicCloud;
	var playsNonAdditiveAnim		: bool;
	var bleedCustomEffect 			: SCustomEffectParams;
	var resPt, resPrc, chance		: float;
	
	if(!actorVictim)
		return;
	
	confusionInstakillTested = false;
	npcVictim = (CNewNPC)actorVictim;
	canPerformFinisher = CanPerformFinisher(actorVictim);
	canDismember = CanDismember(wasFrozen, dismemberExplosion, weaponName);
	

	if(canPerformFinisher && thePlayer.HasBuff(EET_Blizzard) && ((W3Potion_Blizzard)thePlayer.GetBuff(EET_Blizzard)).IsSlowMoActive())
		canPerformFinisher = false;

	if( actorVictim.IsAlive() && !canPerformFinisher && !canDismember && !mutation8Triggered )
	{
		if(!action.IsDoTDamage() && action.DealtDamage())
		{
			if ( actorAttacker && npcVictim)
			{
				npcVictim.NoticeActorInGuardArea( actorAttacker );
			}
			if ( !playerVictim )
			{
				actorVictim.RemoveAllBuffsOfType(EET_Knockdown);
				actorVictim.RemoveAllBuffsOfType(EET_HeavyKnockdown);
				if( playerAttacker )
					actorVictim.RemoveAllBuffsOfType(EET_AxiiGuardMe);
			}
			if(playerAttacker && action.IsActionMelee() && !playerAttacker.GetInventory().IsItemFists(weaponId) && playerAttacker.IsLightAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s05))
			{
				bleedCustomEffect.effectType = EET_Bleeding;
				bleedCustomEffect.creator = playerAttacker;
				bleedCustomEffect.sourceName = SkillEnumToName(S_Sword_s05);
				bleedCustomEffect.duration = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'sword_s5_duration', false, true));
				bleedCustomEffect.effectValue.valueMultiplicative = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'sword_s5_dmg_per_sec', false, true));
				chance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'sword_s5_chance', false, true)) * playerAttacker.GetSkillLevel(S_Sword_s05);
				actorVictim.GetResistValue(theGame.effectMgr.GetBuffResistStat(EET_Bleeding), resPt, resPrc);
				chance *= MaxF(0, 1 - resPrc);
				if(((W3PlayerWitcher)playerAttacker).IsMutationActive(EPMT_Mutation12))
					chance *= MaxF(1.0f, 1.0f + ((W3PlayerWitcher)playerAttacker).Mutation12GetBonus());
				if(RandF() < chance)
					actorVictim.AddEffectCustom(bleedCustomEffect);
			}
		}
		if(actorVictim && wasAlive)
		{
			playsNonAdditiveAnim = actorVictim.ReactToBeingHit( action );
		}
	}
	else
	{
		if( actorVictim.IsAlive() && (canPerformFinisher || canDismember || mutation8Triggered) )
		{
			actorVictim.Kill( 'Finisher', false, thePlayer );
		}
		
		if( !canPerformFinisher && canDismember )
		{
			ProcessDismemberment(wasFrozen, dismemberExplosion);
			toxicCloud = (W3ToxicCloud)action.causer;
			
			if( toxicCloud && toxicCloud.HasExplodingTargetDamages() )
				ProcessToxicCloudDismemberExplosion(toxicCloud.GetExplodingTargetDamages());

		}
		else if( canPerformFinisher )
		{
			thePlayer.AddTimer( 'DelayedFinisherInputTimer', 0.1f );
			thePlayer.SetFinisherVictim( actorVictim );
			thePlayer.CleanCombatActionBuffer();
			thePlayer.OnBlockAllCombatTickets( true );
			
			if( actorVictim.WillBeUnconscious() )
			{
				actorVictim.SetBehaviorVariable( 'prepareForUnconsciousFinisher', 1.0f );
				actorVictim.ActionRotateToAsync( thePlayer.GetWorldPosition() );
			}
			
			moveTargets = thePlayer.GetMoveTargets();
			
			for( i = 0; i < moveTargets.Size(); i += 1 )
			{
				if ( actorVictim != moveTargets[i] )
					moveTargets[i].SignalGameplayEvent( 'InterruptChargeAttack' );
			}
			
			if( theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled' ) == "true"
				|| ( (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation3 ) ) )
			{
				actorVictim.AddAbility( 'ForceFinisher', false );
			}
			
			if( actorVictim.HasTag( 'ForceFinisher' ) )
				actorVictim.AddAbility( 'ForceFinisher', false );
			
			actorVictim.SignalGameplayEvent( 'ForceFinisher' );
		}
		else if( weaponName == 'fists' && npcVictim )
		{
			npcVictim.DisableAgony();
		}
		
		thePlayer.FindMoveTarget();
	}
	
	if( attackAction.IsActionMelee() )
	{
		actorAttacker.SignalGameplayEventParamObject( 'HitActionReaction', actorVictim );
		actorVictim.OnHitActionReaction( actorAttacker, weaponName );
	}
	
	
	actorVictim.ProcessHitSound(action, playsNonAdditiveAnim || !actorVictim.IsAlive());
	
	
	
	if(action.IsCriticalHit() && action.DealtDamage() && !actorVictim.IsAlive() && actorAttacker == thePlayer )
		GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10 );
	
	
	if( attackAction && npcVictim && npcVictim.IsShielded( actorAttacker ) )
	{
		if(!npcVictim.HasStaminaToParry(attackAction.GetAttackName()) || actorAttacker.IsHeavyAttack(attackAction.GetAttackName()) &&  npcVictim.GetStaminaPercents() <= 0.34)
			npcVictim.ProcessShieldDestruction();
	}
	
	
	if( actorVictim && action.CanPlayHitParticle() && ( action.DealsAnyDamage() || (attackAction && attackAction.IsParried()) ) )
		actorVictim.PlayHitEffect(action);
		

	if( action.victim.HasAbility('mon_nekker_base') && !actorVictim.CanPlayHitAnim() && !((CBaseGameplayEffect) action.causer) ) 
	{
		
		actorVictim.PlayEffect(theGame.params.LIGHT_HIT_FX);
		actorVictim.SoundEvent("cmb_play_hit_light");
	}
		
	
	if(actorVictim && playerAttacker && action.IsActionMelee() && thePlayer.inv.IsItemFists(weaponId) )
	{
		actorVictim.SignalGameplayEvent( 'wasHitByFists' );	
			
		if(MonsterCategoryIsMonster(victimMonsterCategory))
		{
			if(!victimCanBeHitByFists)
			{
				playerAttacker.ReactToReflectedAttack(actorVictim);
			}
			else
			{			
				actorVictim.GetResistValue(CDS_PhysicalRes, points, percents);
			
				if(percents >= theGame.params.MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS)
					playerAttacker.ReactToReflectedAttack(actorVictim);
			}
		}			
	}
	
	ProcessSparksFromNoDamage();
	
	if(attackAction && attackAction.IsActionMelee() && actorAttacker && playerVictim && attackAction.IsCountered() && (W3PlayerWitcher)playerVictim)
	{
		actorAttacker.SetWasCountered(true);
		if( playerVictim == GetWitcherPlayer() )
			GetWitcherPlayer().SetRecentlyCountered(true);
	}

	if(attackAction && attackAction.IsActionMelee() && actorAttacker && playerVictim && attackAction.WasDodged() && playerVictim == GetWitcherPlayer())
	{
		GetWitcherPlayer().SetRecentlyDodged(true);
	}
	
	CleanupMutation8Finisher();
}

@wrapMethod( W3DamageManagerProcessor ) function CanDismember( wasFrozen : bool, out dismemberExplosion : bool, out weaponName : name ) : bool
{
	var dismember			: bool;
	var dismemberChance 	: int;
	var petard 				: W3Petard;
	var bolt 				: W3BoltProjectile;
	var arrow 				: W3ArrowProjectile;
	var inv					: CInventoryComponent;
	var toxicCloud			: W3ToxicCloud;
	var witcher				: W3PlayerWitcher;
	var i					: int;
	var secondaryWeapon		: bool;
	
	if(false) 
	{
		wrappedMethod( wasFrozen, dismemberExplosion, weaponName );
	}
	
	petard = (W3Petard)action.causer;
	bolt = (W3BoltProjectile)action.causer;
	arrow = (W3ArrowProjectile)action.causer;
	toxicCloud = (W3ToxicCloud)action.causer;
	
	if( playerAttacker )
		secondaryWeapon = playerAttacker.inv.ItemHasTag( weaponId, 'SecondaryWeapon' ) || playerAttacker.inv.ItemHasTag( weaponId, 'Wooden' );
	
	dismemberExplosion = false;
	weaponName = '';
	
	if( actorVictim.HasAbility( 'DisableDismemberment' ) )
		return false;
	
	if( actorVictim.HasTag( 'DisableDismemberment' ) )
		return false;
	
	if( actorVictim.WillBeUnconscious() )
		return false;
	
	if( playerAttacker && secondaryWeapon )
		return false;
	
	if( actorVictim.IsAlive() && !CanDismemberAliveTarget( actorVictim ) )
		return false;
	
	if( arrow && !wasFrozen )
		return false;
	
	if( !actorVictim.IsAlive() && actorAttacker.HasAbility( 'ForceDismemberment' ) )
	{
		dismember = true;
		dismemberExplosion = action.HasForceExplosionDismemberment();
	}
	else if( !actorVictim.IsAlive() && wasFrozen )
	{
		dismember = true;
		dismemberExplosion = action.HasForceExplosionDismemberment();
	}						
	else if( !actorVictim.IsAlive() && ((petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill())) )
	{
		dismember = true;
		dismemberExplosion = action.HasForceExplosionDismemberment();
	}
	else if( !actorVictim.IsAlive() && (W3Effect_YrdenHealthDrain)action.causer )
	{
		dismember = true;
		dismemberExplosion = true;
	}
	else if( !actorVictim.IsAlive() && toxicCloud && toxicCloud.HasExplodingTargetDamages() )
	{
		dismember = true;
		dismemberExplosion = true;
	}
	else if( !actorVictim.IsAlive() && actorVictim.HasTag( 'q803_ScoloForceFinisher' ) && playerAttacker && attackAction && attackAction.IsActionMelee() )
	{
		dismember = true;
		dismemberExplosion = false;
	}
	else
	{
		inv = actorAttacker.GetInventory();
		weaponName = inv.GetItemName( weaponId );
		
		if( attackAction 
			&& !inv.IsItemSteelSwordUsableByPlayer(weaponId) 
			&& !inv.IsItemSilverSwordUsableByPlayer(weaponId) 
			&& weaponName != 'polearm'
			&& weaponName != 'fists_lightning' 
			&& weaponName != 'fists_fire' )
		{
			dismember = false;
		}			
		else if ( !actorVictim.IsAlive() && action.IsCriticalHit() )
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}
		else if ( !actorVictim.IsAlive() && action.HasForceExplosionDismemberment() )
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else
		{
			if( mutation8Triggered )
			{
				dismemberChance = 100;
			}
			else if( !confusionInstakillTested && IsAxiiInstakillTarget() )
			{
				dismemberChance = GetAxiiInstakillChance();
				confusionInstakillTested = true;
			}
			else if ( !actorVictim.IsAlive() )
			{
				dismemberChance = theGame.params.DISMEMBERMENT_ON_DEATH_CHANCE;
				
				if(playerAttacker && playerAttacker.forceDismember)
				{
					dismemberChance = thePlayer.forceDismemberChance;
					dismemberExplosion = thePlayer.forceDismemberExplosion;
				}
				
				if(attackAction)
				{
					dismemberChance += RoundMath(100 * CalculateAttributeValue(inv.GetItemAttributeValue(weaponId, 'dismember_chance')));
					dismemberExplosion = attackAction.HasForceExplosionDismemberment();
				}
				
				witcher = (W3PlayerWitcher)actorAttacker;
				if(witcher && witcher.CanUseSkill(S_Perk_03))
					dismemberChance += RoundMath(100 * CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Perk_03, 'dismember_chance', false, true)));
				
				if( ( W3PlayerWitcher )playerAttacker && attackAction.IsActionMelee() && GetWitcherPlayer().IsMutationActive(EPMT_Mutation3) )	
				{
					if( thePlayer.inv.IsItemSteelSwordUsableByPlayer( weaponId ) || thePlayer.inv.IsItemSilverSwordUsableByPlayer( weaponId ) )
					{
						dismemberChance = 100;
					}
				}
			}
			
			dismemberChance = Clamp(dismemberChance, 0, 100);
			
			if (RandRange(100) < dismemberChance)
				dismember = true;
			else
				dismember = false;
		}
	}

	return dismember;
}

@addMethod(W3DamageManagerProcessor) function CanDismemberAliveTarget( actorVictim : CActor ) : bool
{
	return ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) || mutation8Triggered )
	&& actorVictim.IsVulnerable()
	&& !actorVictim.HasAbility('DisableDismemberment')
	&& !actorVictim.HasAbility('InstantKillImmune');
}

@wrapMethod( W3DamageManagerProcessor ) function CanPerformFinisher( actorVictim : CActor ) : bool
{
	var finisherChance 			: int;
	var areEnemiesAttacking		: bool;
	var i						: int;
	var victimToPlayerVector, playerPos	: Vector;
	var item 					: SItemUniqueId;
	var moveTargets				: array<CActor>;
	var res						: bool;
	var size					: int;
	var npc						: CNewNPC;
	
	if(false) 
	{
		wrappedMethod( actorVictim );
	}
	
	if ( (W3ReplacerCiri)thePlayer || playerVictim || !playerAttacker || !thePlayer.IsAlive() || thePlayer.isInFinisher || thePlayer.IsInAir() || thePlayer.IsUsingVehicle() )
		return false;
	
	if ( thePlayer.IsCurrentSignChanneled() )
		return false;
	
	if ( !attackAction || !attackAction.IsActionMelee() )
		return false;
	
	if ( thePlayer.IsSecondaryWeaponHeld() || !thePlayer.IsWeaponHeld( 'steelsword') && !thePlayer.IsWeaponHeld( 'silversword') )
		return false;
	
	item = thePlayer.inv.GetItemFromSlot( 'l_weapon' );
	
	if ( thePlayer.inv.IsIdValid( item ) )
		return false;
	
	if ( actorVictim.HasAbility( 'DisableFinishers' ) )
		return false;
	
	if ( !actorVictim.IsHuman() || actorVictim.IsWoman() )
		return false;
	
	if ( actorVictim.WillBeUnconscious() && !theGame.GetDLCManager().IsEP2Available() )
		return false;
	
	if ( actorVictim.IsKnockedUnconscious() || actorVictim.HasBuff( EET_Knockdown ) || actorVictim.HasBuff( EET_Ragdoll ) || actorVictim.HasBuff( EET_Frozen ) )
		return false;
	
	if ( actorVictim.IsAlive() && !CanPerformFinisherOnAliveTarget(actorVictim) )
		return false;
	
	moveTargets = thePlayer.GetMoveTargets();	
	size = moveTargets.Size();
	playerPos = thePlayer.GetWorldPosition();

	if ( size > 0 )
	{
		areEnemiesAttacking = false;			
		for ( i = 0; i < size; i += 1 )
		{
			npc = (CNewNPC)moveTargets[i];
			if ( npc && VecDistanceSquared(playerPos, moveTargets[i].GetWorldPosition()) < 7 && npc.IsAttacking() && npc != actorVictim )
			{
				areEnemiesAttacking = true;
				break;
			}
		}
	}
	
	victimToPlayerVector = actorVictim.GetWorldPosition() - playerPos;
	
	npc = (CNewNPC)actorVictim;
	if( mutation8Triggered )
	{
		finisherChance = 100;
	}
	else if( !confusionInstakillTested && IsAxiiInstakillTarget() )
	{
		finisherChance = GetAxiiInstakillChance();
		confusionInstakillTested = true;
	}
	else if( !actorVictim.IsAlive() )
	{
		if( actorVictim.HasAbility('ForceFinisher') || GetWitcherPlayer().IsMutationActive(EPMT_Mutation3) )
		{
			finisherChance = 100;
		}
		else if( npc.currentLevel - thePlayer.GetLevel() >= theGame.params.LEVEL_DIFF_DEADLY )
		{
			finisherChance = 0;
		}
		else if( thePlayer.GetLevel() - npc.currentLevel  >= theGame.params.LEVEL_DIFF_DEADLY )
		{
			finisherChance = 100;
		}
		else if( size <= 1 )
		{
			finisherChance = 100;
		}
		else
		{
			finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE;
		}
	}
	else
	{
		finisherChance = 0;
	}
	finisherChance = Clamp(finisherChance, 0, 100);
	
	if ( actorVictim.HasTag('ForceFinisher') )
	{
		finisherChance = 100;
		areEnemiesAttacking = false;
	}
		
	if ( thePlayer.forceFinisher && !thePlayer.forceFinisherKeepConditions )
	{
		res = true;
	}
	else
	{
		res = ( ( RandRange(100) < finisherChance || thePlayer.forceFinisher ) && actorVictim.GetAttitude( thePlayer ) == AIA_Hostile
				&& !areEnemiesAttacking && AbsF( victimToPlayerVector.Z ) < 0.4f
				&& ( theGame.GetWorld().NavigationCircleTest( actorVictim.GetWorldPosition(), 2.f ) || actorVictim.HasTag('ForceFinisher') ) );
	}

	if ( res )
	{
		if ( !actorVictim.IsAlive() && !actorVictim.WillBeUnconscious() )
			actorVictim.AddAbility( 'DisableFinishers', false );
	}
	
	return res;
}

@wrapMethod( W3DamageManagerProcessor ) function ProcessActionBuffs() : bool
{
	var inv : CInventoryComponent;
	var ret : bool;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(!action.victim.IsAlive() || action.WasDodged() || (attackAction && attackAction.IsActionMelee() && !attackAction.ApplyBuffsIfParried() && attackAction.IsParried()) )
		return true;
		
	if( actorAttacker == thePlayer && action.IsActionWitcherSign() && action.IsCriticalHit() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation2 ) && action.HasBuff( EET_Burning ) )
	{
		action.SetBuffSourceName( 'Mutation2ExplosionValid' );
	}

	
	if(actorVictim && action.GetEffectsCount() > 0)
		ret = actorVictim.ApplyActionEffects(action);
	else
		ret = false;
		
	
	if(actorAttacker && actorVictim)
	{
		inv = actorAttacker.GetInventory();
		actorAttacker.ProcessOnHitEffects(actorVictim, inv.IsItemSilverSwordUsableByPlayer(weaponId), inv.IsItemSteelSwordUsableByPlayer(weaponId), action.IsActionWitcherSign() );
	}
	
	return ret;
}

@wrapMethod( W3DamageManagerProcessor ) function ProcessPreHitModifications()
{
	var fireDamage, totalDmg, maxHealth, currHealth : float;
	var attribute, min, max : SAbilityAttributeValue;
	var infusion : ESignType;
	var hack : array< SIgniEffects >;
	var dmgValTemp : float;
	var igni : W3IgniEntity;
	var quen : W3QuenEntity;
	
	if(false) 
	{
		wrappedMethod();
	}

	if( actorVictim.HasAbility( 'HitWindowOpened' ) && !action.IsDoTDamage() )
	{
		if( actorVictim.HasTag( 'fairytale_witch' ) )
		{
			((CNewNPC)actorVictim).SetBehaviorVariable( 'shouldBreakFlightLoop', 1.0 );
		}
		else
		{
			quen = (W3QuenEntity)action.causer; 
		
			if( !quen )
			{
				if( actorVictim.HasTag( 'dettlaff_vampire' ) )
				{
					actorVictim.StopEffect( 'shadowdash' );
				}
				
				action.ClearDamage();
				if( action.IsActionMelee() )
				{
					actorVictim.PlayEffect( 'special_attack_break' );
				}
				actorVictim.SetBehaviorVariable( 'repelType', 0 );
				
				actorVictim.AddEffectDefault( EET_CounterStrikeHit, thePlayer ); 
				action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
			}
		}
		
		((CNewNPC)actorVictim).SetHitWindowOpened( false );
	}
	
	
	
	if(playerAttacker == GetWitcherPlayer() && attackAction && attackAction.IsActionMelee() && GetWitcherPlayer().HasRunewordActive('Runeword 1 _Stats'))
	{
		infusion = GetWitcherPlayer().GetRunewordInfusionType();
		
		switch(infusion)
		{
			case ST_Aard:
				action.AddEffectInfo(EET_KnockdownTypeApplicator);
				action.SetProcessBuffsIfNoDamage(true);
				attackAction.SetApplyBuffsIfParried(true);
				actorVictim.CreateFXEntityAtPelvis( 'runeword_1_aard', false );
				break;
			case ST_Axii:
				attribute = thePlayer.GetAttributeValue('runeword1_confusion_duration');
				action.AddEffectInfo(EET_Confusion, attribute.valueAdditive);
				action.SetProcessBuffsIfNoDamage(true);
				attackAction.SetApplyBuffsIfParried(true);
				break;
			case ST_Igni:
				
				totalDmg = action.GetDamageValueTotal();
				attribute = thePlayer.GetAttributeValue('runeword1_fire_dmg');
				fireDamage = totalDmg * attribute.valueMultiplicative;
				action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, fireDamage);
				
				
				action.SetCanPlayHitParticle(false);					
				action.victim.AddTimer('Runeword1DisableFireFX', 1.f);
				action.SetHitReactionType(EHRT_Heavy);	
				action.victim.PlayEffect('critical_burning');
				break;
			case ST_Yrden:
				attribute = thePlayer.GetAttributeValue('runeword1_yrden_duration');
				action.AddEffectInfo(EET_Slowdown, attribute.valueAdditive);
				action.SetProcessBuffsIfNoDamage(true);
				attackAction.SetApplyBuffsIfParried(true);
				break;
			default:		
				break;
		}
	}
	
	
	if( playerAttacker && actorVictim && (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) && (W3BoltProjectile)action.causer )
	{
		maxHealth = actorVictim.GetMaxHealth();
		currHealth = actorVictim.GetHealth();
		
		
		if( AbsF( maxHealth - currHealth ) < 1.f )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'health_reduction', min, max);
			actorVictim.ForceSetStat( actorVictim.GetUsedHealthType(), maxHealth * ( 1 - min.valueMultiplicative ) );
		}
		
		
		action.AddEffectInfo( EET_KnockdownTypeApplicator, 0.1f, , , , 1.f );
	}
}
