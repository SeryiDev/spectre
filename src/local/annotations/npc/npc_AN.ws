@addField(CNewNPC)
var currentNGPLevel		: int;

@addField(CNewNPC)
private saved var savedRandomLevel				: int;

@addField(CNewNPC)
private var animSpeedMult						: int;

@wrapMethod(CNewNPC) function OnLevelUpscalingChanged()
{
	if(false) 
	{
		wrappedMethod();
	}
}

@wrapMethod(CNewNPC) function OnPreAttackEvent(animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo )
{
	var witcher : W3PlayerWitcher;

	if(false) 
	{
		wrappedMethod(animEventName, animEventType, data, animInfo );
	}

	super.OnPreAttackEvent(animEventName, animEventType, data, animInfo);
	
	if(animEventType == AET_DurationStart )
	{
		
		
		witcher = GetWitcherPlayer();
		
		
		
		if(GetTarget() == witcher )
		{
			this.SetDodgeFeedback( true );
		}

		// 5.01 tree: Frenzy as in 5.01.
		if( spectreVanillaSkills() && IsCountering() && GetTarget() == witcher && ( thePlayer.IsActionAllowed(EIAB_Dodge) || thePlayer.IsActionAllowed(EIAB_Roll) ) && witcher.GetStat(BCS_Toxicity) > 0 && witcher.CanUseSkill(S_Alchemy_s16) )
			witcher.StartFrenzy();

		return ((spectreAbilityManager)GetWitcherPlayer().abilityManager).ApplyHeightenedReflexes(this);
		if(GetTarget() == witcher && witcher.CanUseSkill(S_Alchemy_s16) && witcher.GetStat(BCS_Toxicity) > 0)
		{
			if(IsCountering())
				witcher.StartFrenzy();
		}
	}
	else if(animEventType == AET_DurationEnd )
	{
		witcher = GetWitcherPlayer();
		
		if(GetTarget() == witcher )
		{		
			this.SetDodgeFeedback( false );
		}
	}
}

@wrapMethod(CNewNPC) function OnSpawned(spawnData : SEntitySpawnData )
{
	var npcPath : string;

	wrappedMethod(spawnData);

	if((IsAnimal() || spectreIsBeast()) )
	{
		AddAbility('NPCDoNotGainBoost');
		AddAbility('NoAdaptBalance');
	}
	else
	{
		RemoveAbility('NPCDoNotGainBoost');
		RemoveAbility('NoAdaptBalance');
	}
	
	currentNGPLevel = 0;

	if( !HasAbility('NoAdaptBalance') && !((W3ReplacerCiri)thePlayer) )
	{
		if( theGame.IsActive() )
		{
			if( ( ( FactsQuerySum("NewGamePlus") > 0 ) && !HasTag('animal') ) )
			{
				if( !HasAbility('NPCDoNotGainBoost') )
				{
					currentNGPLevel = theGame.params.GetNewGamePlusLevel();
					currentLevel = level + currentNGPLevel;
				}
			}
		}
	}

	levelFakeAddon = 0;
	newGamePlusFakeLevelAddon = false;

	if ( npcGroupType == ENGT_Guard )
	{
		SetImmortalityMode(AIM_None, AIC_Default);	
	}
}

@wrapMethod(CNewNPC) function SetLevel ( _level : int )
{
	if(false) 
	{
		wrappedMethod(_level);
	}

	currentLevel = _level;
	savedRandomLevel = -1;
	levelBonusesComputedAtPlayerLevel = 0;
	AddTimer('AddLevelBonuses', 0.1, true, false, , true);
}

@addMethod(CNewNPC) function ResetLevel()
{
	levelBonusesComputedAtPlayerLevel = -1;
	AddTimer('AddLevelBonuses', RandRangeF(0.05,0.2), true, false, , true);
}

@wrapMethod(CNewNPC) function OnProcessActionPost(action : W3DamageAction)
{
	var actorVictim : CActor;
	var time, maxTox, toxToAdd : float;
	var gameplayEffect : CBaseGameplayEffect;
	var template : CEntityTemplate;
	var fxEnt : CEntity;
	var toxicity : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(action);
	}
	
	super.OnProcessActionPost(action);
	
	actorVictim = (CActor)action.victim;
	
	if(HasBuff(EET_AxiiGuardMe) && GetWitcherPlayer().HasGlyphwordActive('Glyphword 18 _Stats') && action.DealtDamage())
	{
		time = CalculateAttributeValue(thePlayer.GetAttributeValue('increas_duration'));
		gameplayEffect = GetBuff(EET_AxiiGuardMe);
		gameplayEffect.SetTimeLeft( gameplayEffect.GetTimeLeft() + time );
		
		template = (CEntityTemplate)LoadResource('glyphword_10_18');
		
		if(GetBoneIndex('head') != -1)
		{				
			fxEnt = theGame.CreateEntity(template, GetBoneWorldPosition('head'), GetWorldRotation(), , , true);
			fxEnt.CreateAttachmentAtBoneWS(this, 'head', GetBoneWorldPosition('head'), GetWorldRotation());
		}
		else
		{
			fxEnt = theGame.CreateEntity(template, GetBoneWorldPosition('k_head_g'), GetWorldRotation(), , , true);
			fxEnt.CreateAttachmentAtBoneWS(this, 'k_head_g', GetBoneWorldPosition('k_head_g'), GetWorldRotation());
			
		}
		
		fxEnt.PlayEffect('axii_extra_time');
		fxEnt.DestroyAfter(5);
	}
	
	
	if( action.victim && action.victim == GetWitcherPlayer() && action.DealtDamage() )
	{
		toxicity = GetAttributeValue( 'toxicity_increase_on_hit' );
		if( toxicity.valueAdditive > 0.f || toxicity.valueMultiplicative > 0.f )
		{
			maxTox = GetWitcherPlayer().GetStatMax( BCS_Toxicity );
			toxToAdd = maxTox * toxicity.valueMultiplicative + toxicity.valueAdditive;
			GetWitcherPlayer().GainStat( BCS_Toxicity, toxToAdd );
		}
	}
}

@addMethod(CNewNPC) function RemoveAllLevelBonuses()
{
	var savedHealthPerc : float;

	if(GetStatMax( BCS_Vitality ) > 0)
		savedHealthPerc = GetStatPercents( BCS_Vitality );
	else if(GetStatMax( BCS_Essence ) > 0)
		savedHealthPerc = GetStatPercents( BCS_Essence );

	RemoveAbilityAll('modSpectreAdditionalEssence');
	RemoveAbilityAll('modSpectreAdditionalVitality');
	RemoveAbilityAll('modSpectreAdditionalEssenceNegative');
	RemoveAbilityAll('modSpectreAdditionalVitalityNegative');

	RemoveAbilityAll('modSpectreAdditionalHealth');
	RemoveAbilityAll('modSpectreAdditionalHealthNegative');
	RemoveAbilityAll('modSpectreMaxHealthNegative');
	
	RemoveAbilityAll('modSpectreAdditionalDamage');
	RemoveAbilityAll('modSpectreAdditionalDamageNegative');

	RemoveAbility(theGame.params.ENEMY_BONUS_DEADLY);
	RemoveBuffImmunity(EET_Blindness, 'DeadlyEnemy');
	RemoveBuffImmunity(EET_WraithBlindness, 'DeadlyEnemy');
	RemoveAbility(theGame.params.ENEMY_BONUS_HIGH);
	RemoveAbility(theGame.params.ENEMY_BONUS_LOW);
	RemoveAbility(theGame.params.MONSTER_BONUS_DEADLY);
	RemoveBuffImmunity(EET_Blindness, 'DeadlyEnemy');
	RemoveBuffImmunity(EET_WraithBlindness, 'DeadlyEnemy');
	RemoveAbility(theGame.params.MONSTER_BONUS_HIGH);
	RemoveAbility(theGame.params.MONSTER_BONUS_LOW);
	RemoveAbilityAll('AnimalLevelBonus');
	RemoveAbilityAll(theGame.params.ENEMY_BONUS_PER_LEVEL);
	RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED);
	RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED);
	RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP);
	RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL);

	RemoveAbilityAll('DisplayedLevelAbl');

	RemoveAbility('CiriHardcoreDebuffHuman');
	RemoveAbility('CiriHardcoreDebuffMonster');
	

	if(GetStatMax( BCS_Vitality ) > 0)
	{
		UpdateStatMax(BCS_Vitality);
		ForceSetStat(BCS_Vitality, GetStatMax(BCS_Vitality)*savedHealthPerc);
	}
	else if(GetStatMax( BCS_Essence ) > 0)
	{
		UpdateStatMax(BCS_Essence);
		ForceSetStat(BCS_Essence, GetStatMax(BCS_Essence)*savedHealthPerc);
	}
}

@addMethod(CNewNPC) function CheckConstitutionAbility()
{
	if( HasAbility('ConHumanoidMonster') )
	{
		RemoveAbility('ConDefault');
		RemoveAbility('ConAthletic');
	}
	else if( HasAbility('ConAthletic') && HasAbility('ConDefault') )
	{
		RemoveAbility('ConDefault');
	}
}

@addMethod(CNewNPC) function modSpectreAddBonuses()
{
	var ablNum : int;
	var savedHealthPerc, healthMult, damageMult : float;
	
	if(GetStatMax( BCS_Vitality ) > 0)
		savedHealthPerc = GetStatPercents( BCS_Vitality );
	else if(GetStatMax( BCS_Essence ) > 0)
		savedHealthPerc = GetStatPercents( BCS_Essence );

	if (this.IsMonster())
	{
		healthMult = spectre_Settings_Main_Float('spectreScalingOptions','spectreMonsterHealthMultiplier', 1);
	}
	else if (this.IsHuman())
	{
		healthMult = spectre_Settings_Main_Float('spectreScalingOptions','spectreHumanHealthMultiplier', 1);
	}
	else if (this.IsAnimal())
	{
		healthMult = spectre_Settings_Main_Float('spectreScalingOptions','spectreAnimalHealthMultiplier', 1);
	}
	else
	{
		healthMult = 1;
	}

	if(HasTag('HideHealthBarModule'))
	{
		healthMult += spectre_Settings_Main_Float('spectreScalingOptions','spectreBossHealthMultiplier', 1);
	}

	if(healthMult > 0)
	{
		ablNum = RoundMath(healthMult * 10);
		AddAbilityMultiple('modSpectreAdditionalHealth', ablNum);
	}
	else if(healthMult < 0)
	{
		ablNum = RoundMath(-1 * healthMult * 10);
		if(ablNum > 9)
			AddAbility('modSpectreMaxHealthNegative');
		else
			AddAbilityMultiple('modSpectreAdditionalHealthNegative', ablNum);
	}

	if(GetStatMax( BCS_Vitality ) > 0)
	{
		UpdateStatMax(BCS_Vitality);
		ForceSetStat(BCS_Vitality, GetStatMax(BCS_Vitality)*savedHealthPerc);
	}
	else if(GetStatMax( BCS_Essence ) > 0)
	{
		UpdateStatMax(BCS_Essence);
		ForceSetStat(BCS_Essence, GetStatMax(BCS_Essence)*savedHealthPerc);
	}

	damageMult = spectre_Settings_Main_Float('spectreScalingOptions','spectreDamageMultiplier', 1);

	if(HasTag('HideHealthBarModule'))
	{
		damageMult += spectre_Settings_Main_Float('spectreScalingOptions','spectreBossDamageMultiplier', 1);
	}
	if(damageMult > 0)
	{
		ablNum = RoundMath(damageMult * 10);
		AddAbilityMultiple('modSpectreAdditionalDamage', ablNum);
	}
	else if(damageMult < 0)
	{
		ablNum = RoundMath(-1 * damageMult * 10);
		AddAbilityMultiple('modSpectreAdditionalDamageNegative', ablNum);
	}
}

@addMethod(CNewNPC) function InternalAddLevelBonuses()
{
	var numAbls, lvlDiff : int;
	var ciriEntity  : W3ReplacerCiri;
	var savedHealthPerc, dLvl, dAbs : float;

	lvlDiff = currentLevel - thePlayer.GetLevel();
	ciriEntity = (W3ReplacerCiri)thePlayer;
	if(GetStatMax( BCS_Vitality ) > 0)
	{
		savedHealthPerc = GetStatPercents( BCS_Vitality );
	}
	else if(GetStatMax( BCS_Essence ) > 0)
	{
		savedHealthPerc = GetStatPercents( BCS_Essence );
	}

	AddAbilityMultiple('DisplayedLevelAbl', currentLevel - 1);

	if(spectre_Settings_Main_Bool('spectreScalingOptions','spectreNonlinearLevelup', true))
	{
		dLvl = spectre_Settings_Main_Int('spectreScalingOptions','spectreNonlinearLevelDelta', 10);
		dAbs = spectre_Settings_Main_Int('spectreScalingOptions','spectreNonlinearAbilitiesDelta', 5);
		if(dLvl > 0 && currentLevel > dLvl)
			numAbls = RoundMath((1 + dAbs/dLvl) * currentLevel - dAbs);
		else
			numAbls = currentLevel;
		numAbls -= 1;
	}
	else
		numAbls = currentLevel - 1;

	if ( ( HasAbility('mon_wolf_base') || HasAbility('mon_boar_base') || HasAbility('mon_boar_ep2_base') ) && GetStatMax( BCS_Vitality ) > 0 )
	{
		AddAbilityMultiple('AnimalLevelBonus', numAbls);
	}
	else if ( GetStatMax( BCS_Vitality ) > 0 ) 
	{
		AddAbilityMultiple(theGame.params.ENEMY_BONUS_PER_LEVEL, numAbls);
		if ( ciriEntity )
		{
			if(theGame.GetDifficultyMode() == EDM_Hardcore) AddAbility('CiriHardcoreDebuffHuman');
		}
		else if ( GetAttitudeBetween(this, thePlayer) == AIA_Hostile )
		{
			if( !HasTag('HideHealthBarModule') )
			{
				if( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY )
					AddAbility(theGame.params.ENEMY_BONUS_DEADLY, true);
				else if( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )
					AddAbility(theGame.params.ENEMY_BONUS_HIGH, true);
			}
		}
	}
	else if ( GetStatMax( BCS_Essence ) > 0 )
	{
		if ( CalculateAttributeValue(GetTotalArmor()) > 0.f )
		{
			if ( GetIsMonsterTypeGroup() )
			{
				AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED, numAbls);
			}
			else
			{
				AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED, numAbls);
			}
		}
		else
		{
			if ( GetIsMonsterTypeGroup() )
			{
				AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP, numAbls);
			}
			else
			{
				AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL, numAbls);
			}
		}
		if ( ciriEntity )
		{
			if ( theGame.GetDifficultyMode() == EDM_Hardcore ) AddAbility('CiriHardcoreDebuffMonster');
		}
		else if ( GetAttitudeBetween(this, thePlayer) == AIA_Hostile )
		{
			
			if( !HasTag('HideHealthBarModule') )
			{
				if( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY )
					AddAbility(theGame.params.MONSTER_BONUS_DEADLY, true);
				else if( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )
					AddAbility(theGame.params.MONSTER_BONUS_HIGH, true);
			}
		}
	}
	if(GetStatMax( BCS_Vitality ) > 0)
	{
		UpdateStatMax(BCS_Vitality);
		ForceSetStat(BCS_Vitality, GetStatMax(BCS_Vitality)*savedHealthPerc);
	}
	else if(GetStatMax( BCS_Essence ) > 0)
	{
		UpdateStatMax(BCS_Essence);
		ForceSetStat(BCS_Essence, GetStatMax(BCS_Essence)*savedHealthPerc);
	}
}

@wrapMethod(CNewNPC) function AddLevelBonuses (dt : float, id : int)
{
	var playerLevel, scalingType, minLevel, maxLevel, minOffset, maxOffset: int;
	var savedHealthPerc : float;
	var templatePath : string;
	
	if(false) 
	{
		wrappedMethod(dt, id);
	}

	if(theGame.GetLoadGameProgress() > 0 || !thePlayer)
		return;

	RemoveTimer('AddLevelBonuses');
	
	playerLevel = thePlayer.GetLevel();
	
	if(levelBonusesComputedAtPlayerLevel == playerLevel && !fistFightForcedFromQuest)
		return;
	
	if(levelBonusesComputedAtPlayerLevel == -1 || fistFightForcedFromQuest)
	{
		currentLevel = level + currentNGPLevel;
		savedRandomLevel = -1;
	}

	levelBonusesComputedAtPlayerLevel = playerLevel;
	fistFightForcedFromQuest = false;
	
	if( HasAbility('mon_cyclops') && HasAbility('ablIgnoreSigns') )
		RemoveAbilityAll('ablIgnoreSigns');
	
	if( HasAbility('mon_arachas_base') )
		animSpeedMult = SetAnimationSpeedMultiplier(0.75, animSpeedMult);
	
	if( HasTag('sq107_monster_heavy') )
	{
		level = 8;
		currentLevel = level + currentNGPLevel;
	}
	
	templatePath = GetReadableName();
	
	if( IsHuman() && ( StrEndsWith( templatePath, "nilfgaardian_deserter_bow.w2ent" ) || StrEndsWith( templatePath, "nilfgaardian_deserter_shield.w2ent" ) || StrEndsWith( templatePath, "nilfgaardian_deserter_sword_hard.w2ent" ) ) )
	{
		if( spectreIsAtLWGR13( this ) )
		{
			level = 7;
			currentLevel = level + currentNGPLevel;
		}
	}
	
	CheckConstitutionAbility(); 
	
	RemoveAllLevelBonuses();
	
	spectreArmorFix(this);

	modSpectreAddBonuses(); 
	
	if ( HasAbility('NPCDoNotGainBoost') )
	{
		return;
	}
	
	if( GetNPCType() == ENGT_Guard )
		currentLevel = playerLevel;

	if((W3PlayerWitcher)thePlayer)
	{
		scalingType = spectre_Settings_Main_Int('spectreScalingOptions','Virtual_spectreScaling', 1);
		
		if(HasAbility('banshee_summons'))
		{
			scalingType = -1;
		}
		
		if(spectre_Settings_Main_Bool('spectreScalingOptions','spectreNoAnimalUpscaling', false) && (IsAnimal() || spectreIsBeast()) && GetStat( BCS_Vitality, true ) > 0)
		{
			if(currentLevel*2 > playerLevel && scalingType > 0)
				currentLevel = Max(1, playerLevel/2);
			scalingType = -1;
		}

		switch(scalingType)
		{
			case 1:
				if(currentLevel <  playerLevel)
					currentLevel = playerLevel;
				break;
			case 2:
				if(currentLevel != playerLevel)
					currentLevel = playerLevel;
				break;
			case 3:
				if(currentLevel < playerLevel - 6)
					currentLevel = playerLevel - 6;
				break;
			case 4:
			case 5: 
				minOffset = spectre_Settings_Main_IntSigned('spectreScalingOptions','spectreRandomScalingMinLevel', 0);
				maxOffset = spectre_Settings_Main_IntSigned('spectreScalingOptions','spectreRandomScalingMaxLevel', 0);
				if( maxOffset < minOffset )
				{
					savedRandomLevel = playerLevel;
					currentLevel = playerLevel;
				}
				else
				{
					minLevel = Max(1, playerLevel + minOffset);
					maxLevel = Max(minLevel, playerLevel + maxOffset);
					if( savedRandomLevel == -1 || savedRandomLevel < minLevel || savedRandomLevel > maxLevel )
					{
						savedRandomLevel = RandRange(maxLevel + 1, minLevel);
						if( scalingType == 5 && savedRandomLevel < currentLevel )
							savedRandomLevel = currentLevel;
					}
					currentLevel = savedRandomLevel;
				}
				break;
			default:
				break;
		}
	}

	if( GetNPCType() == ENGT_Guard )
	{
		if( currentLevel < playerLevel )
		{
			currentLevel = playerLevel;
		}
			
		if( !spectre_Settings_Main_Bool('spectreScalingOptions','spectreNoAddLevelsGuards', false) )
		{
			currentLevel += theGame.params.LEVEL_DIFF_DEADLY + 1;
		}
	}

	currentLevel = Max(1, currentLevel);

	if( currentLevel < 2 )
	{
		return;
	}

	InternalAddLevelBonuses();
}

@wrapMethod(CNewNPC) function GainStat( stat : EBaseCharacterStats, amount : float )
{
	if(false) 
	{
		wrappedMethod(stat, amount);
	}

	
	super.GainStat(stat, amount);
}

@wrapMethod(CNewNPC) function ForceSetStat(stat : EBaseCharacterStats, val : float)
{
	
	if(false) 
	{
		wrappedMethod(stat, val);
	}
	
	super.ForceSetStat(stat, val);
}

@wrapMethod(CNewNPC) function OnStartFistfightMinigame()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	super.OnStartFistfightMinigame();
	
	thePlayer.ProcessLockTarget( this );
	SignalGameplayEventParamInt('ChangePreferedCombatStyle',(int)EBG_Combat_Fists );
	SetTemporaryAttitudeGroup( 'fistfight_opponent', AGP_Fistfight );
	ForceVulnerableImmortalityMode();
	if ( !thePlayer.IsFistFightMinigameToTheDeath() )
		SetImmortalityMode(AIM_Unconscious, AIC_Fistfight);
	ValidateFistfighterAbilities();
	FistFightHealthSetup();
	RemoveFistFightLevelDiff();
}

@addMethod(CNewNPC) function ValidateFistfighterAbilities()
{
	if( HasAbility( 'SkillFistsEasy' ) )
	{
		RemoveAbilityAll( 'SkillFistsMedium' );
		RemoveAbilityAll( 'SkillFistsHard' );
	}
	else if( HasAbility( 'SkillFistsMedium' ) )
	{
		RemoveAbilityAll( 'SkillFistsHard' );
	}
	
	if( HasAbility( 'StatsFistsTutorial' ) )
	{
		RemoveAbilityAll( 'StatsFistsEasy' );
		RemoveAbilityAll( 'StatsFistsMedium' );
		RemoveAbilityAll( 'StatsFistsHard' );
	}
	else if( HasAbility( 'StatsFistsEasy' ) )
	{
		RemoveAbilityAll( 'StatsFistsMedium' );
		RemoveAbilityAll( 'StatsFistsHard' );
	}
	else if( HasAbility( 'StatsFistsMedium' ) )
	{
		RemoveAbilityAll( 'StatsFistsHard' );
	}
	if(HasAbility('qSergeantFistFIght'))
	{
		if(HasAbility('SkillBrigand') && HasAbility('SkillOfficer'))
			RemoveAbilityAll('SkillBrigand');
		if(HasAbility('NPCDoNotGainBoost'))
		{
			RemoveAbilityAll('NPCDoNotGainBoost');
			ResetLevel();
		}
	}
}

@wrapMethod(CNewNPC) function FistFightNewGamePlusSetup()
{
	if(false) 
	{
		wrappedMethod();
	}
}

@wrapMethod(CNewNPC) function ApplyFistFightLevelDiff()
{
	if(false) 
	{
		wrappedMethod();
	}
}

@wrapMethod(CNewNPC) function RemoveFistFightLevelDiff()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	RemoveAbilityAll(theGame.params.ENEMY_BONUS_FISTFIGHT_LOW);
	RemoveAbilityAll(theGame.params.ENEMY_BONUS_FISTFIGHT_HIGH);
}

@wrapMethod(CNewNPC) function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool
{
	var ret 							: bool;
	var percentageLoss					: float;
	var totalHealth						: float;
	var damaveValue						: float;
	var healthLossToForceLand_perc		: SAbilityAttributeValue;
	var witcher							: W3PlayerWitcher;
	var boltCauser						: W3ArrowProjectile;
	var yrdenCauser 					: W3YrdenEntityStateYrdenShock;
	var burningCauser					: W3Effect_Burning;
	var bombCauser						: W3Petard;
	var attackAction					: W3Action_Attack;
	
	if(false) 
	{
		wrappedMethod(damageAction, buffNotApplied);
	}
	
	damaveValue 				 = damageAction.GetDamageDealt();
	totalHealth 				 = GetMaxHealth();
	percentageLoss 			 	= damaveValue / totalHealth;
	healthLossToForceLand_perc 	 = GetAttributeValue( 'healthLossToForceLand_perc' );
	
	
	boltCauser = (W3ArrowProjectile)( damageAction.causer );
	yrdenCauser = (W3YrdenEntityStateYrdenShock)( damageAction.causer );
	burningCauser = (W3Effect_Burning)( damageAction.causer );
	
	if( IsFlying() && ( ( damageAction.DealsAnyDamage() && !damageAction.IsDoTDamage() ) || boltCauser || yrdenCauser || burningCauser ) )
	{
		damageAction.AddEffectInfo(	EET_KnockdownTypeApplicator );
		damageAction.SetProcessBuffsIfNoDamage( true );
	}

	if( boltCauser || yrdenCauser )
	{
		if( HasAbility( 'AdditiveHits' ) )
		{
			SetUseAdditiveHit( true, GetCriticalCancelAdditiveHit(), true );
			ret = super.ReactToBeingHit(damageAction, buffNotApplied);
			
			if( ret || damageAction.DealsAnyDamage())
				SignalGameplayDamageEvent('BeingHit', damageAction );
		}
		else if( HasAbility( 'mon_wild_hunt_default' ) )
		{
			ret = false;
		}
		else if( !boltCauser.HasTag( 'bodkinbolt' ) || this.IsUsingHorse() || RandRange(100) < 75.f ) 
		{
			ret = super.ReactToBeingHit(damageAction, buffNotApplied);
			
			if( ret || damageAction.DealsAnyDamage())
				SignalGameplayDamageEvent('BeingHit', damageAction );
		}
		else
		{
			ret = false;
		}
	}
	else
	{
		ret = super.ReactToBeingHit(damageAction, buffNotApplied);
		
		if( ret || damageAction.DealsAnyDamage() )
			SignalGameplayDamageEvent('BeingHit', damageAction );
	}

	bombCauser = (W3Petard)( damageAction.causer );
	if ( bombCauser )
		SignalGameplayDamageEvent('BombHit', damageAction );
	
	if( damageAction.additiveHitReactionAnimRequested == true )
		SetHitReaction( damageAction );
	
	if(((CPlayer)damageAction.attacker || !((CNewNPC)damageAction.attacker)) && damageAction.DealsAnyDamage())
		theTelemetry.LogWithLabelAndValue( TE_FIGHT_ENEMY_GETS_HIT, damageAction.victim.ToString(), (int)damageAction.processedDmg.vitalityDamage + (int)damageAction.processedDmg.essenceDamage );
	
	
	witcher = GetWitcherPlayer();

	// 5.01 tree: hitting a puppet frees it unless Puppet is at rank 3, as in 5.01.
	if ( spectreVanillaSkills() && damageAction.attacker == witcher && HasBuff( EET_AxiiGuardMe ) )
	{
		if(!witcher.CanUseSkill(S_Magic_s05) || witcher.GetSkillLevel(S_Magic_s05) < 3)
			RemoveBuff(EET_AxiiGuardMe, true);
		if( !witcher.CanUseSkill( S_Magic_s31 ) || witcher.GetSkillLevel( S_Magic_s31 ) < 3 )
			RemoveBuff(EET_AxiiGuardMe, true);
	}

	if(damageAction.attacker == thePlayer && damageAction.DealsAnyDamage() && !damageAction.IsDoTDamage())
	{
		attackAction = (W3Action_Attack) damageAction;
		
		
		
		if(SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
			theGame.VibrateControllerLight();
		
		
		if(attackAction && attackAction.UsedZeroStaminaPerk())
		{
			ForceSetStat(BCS_Stamina, 0.f);
		}
	}
	
	return ret;
}

@wrapMethod(CNewNPC) function GetExperienceDifferenceLevelName( out strLevel : string ) : string
{
	var lvlDiff : int;
	var currentLevel : int;
	var ciriEntity  : W3ReplacerCiri;
	
	if(false) 
	{
		wrappedMethod(strLevel);
	}
	
	currentLevel = GetLevel();

	lvlDiff = currentLevel - thePlayer.GetLevel();
		
	if( GetAttitude( thePlayer ) != AIA_Hostile )
	{
		if( ( GetAttitudeGroup() != 'npc_charmed' ) )
		{
			strLevel = "";
			return "none";
		}
	}
	
	ciriEntity = (W3ReplacerCiri)thePlayer;

	if (theGame.GetDLCManager().IsDLCAvailable('dlcvhud') 
	&& theGame.GetDLCManager().IsDLCEnabled('dlcvhud') 
	)
	{
		if ( ciriEntity )
		{
			strLevel = "<font size=\"15\" face=\"$BoldFont\" color=\"#FFFFFF\">" + currentLevel + "</font>";
			return "normalLevel";
		}

		if ( lvlDiff >= theGame.params.LEVEL_DIFF_DEADLY )
		{
			strLevel = "";
			return "deadlyLevel";
		}	
		else if ( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )
		{
			strLevel = "<font size=\"15\" face=\"$BoldFont\" color=\"#FF1919\">" + currentLevel + "</font>";
			return "highLevel";
		}
		else if ( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH )
		{
			strLevel = "<font size=\"15\" face=\"$BoldFont\" color=\"#FFFFFF\">" + currentLevel + "</font>";
			return "normalLevel";
		}
		else
		{
			strLevel = "<font size=\"15\" color=\"#E6E6E6\">" + currentLevel + "</font>";
			return "lowLevel";
		}
	}
	else
	{
		if ( ciriEntity )
		{
			strLevel = "<font color=\"#66FF66\">" + currentLevel + "</font>"; 
			return "normalLevel";
		}

		if ( lvlDiff >= theGame.params.LEVEL_DIFF_HIGH )
		{
			strLevel = "<font color=\"#FF1919\">" + currentLevel + "</font>"; 
			return "highLevel";
		}
		else if ( lvlDiff > -theGame.params.LEVEL_DIFF_HIGH )
		{
			strLevel = "<font color=\"#66FF66\">" + currentLevel + "</font>"; 
			return "normalLevel";
		}
		else
		{
			strLevel = "<font color=\"#E6E6E6\">" + currentLevel + "</font>"; 
			return "lowLevel";
		}
	}
	
	return "none";
}

@wrapMethod(CNewNPC) function CalculateExperiencePoints(optional skipLog : bool) : int
{
	var finalExp				: int;
	var exp, expModifier		: float;
	var lvlDiff, playerLevel	: int;
	var enemyType				: EEnemyType;
	
	if(false) 
	{
		wrappedMethod(skipLog);
	}
	
	if(grantNoExperienceAfterKill || HasAbility('Zero_XP'))
		return 0;
	
	if(GetNPCType() == ENGT_Guard)
	{
		GetWitcherPlayer().IncKills(EENT_HUMAN);
		return 0;
	}

	enemyType = spectreGetEnemyTypeByAbility(this);
	exp = (float)spectreGetExpByEnemyType(enemyType);
	
	if((W3MonsterHuntNPC)this)
		exp = 15;
	
	expModifier = 1.0f;
	playerLevel = thePlayer.GetLevel();
	if(FactsQuerySum("NewGamePlus") > 0)
	{
		playerLevel -= theGame.params.GetNewGamePlusLevel();
		currentLevel -= theGame.params.GetNewGamePlusLevel();
	}
	if(!spectre_Settings_Main_Bool('spectreExpOptions','spectreUseXMLExp', false))
	{
		lvlDiff = currentLevel - thePlayer.GetLevel();
		expModifier = 1 + lvlDiff * theGame.params.LEVEL_DIFF_XP_MOD;
		expModifier = ClampF(expModifier, 0, theGame.params.MAX_XP_MOD);
		expModifier *= GetWitcherPlayer().GetExpModifierByEnemyType(enemyType);
	}
	
	finalExp = RoundF( exp * expModifier );
	finalExp = Max(1, finalExp);
	
	GetWitcherPlayer().IncKills(enemyType);
	
	return finalExp;
}

@replaceMethod(CNewNPC) function OnDeath( damageAction : W3DamageAction  )
{		
	var inWater, fists, tmpBool, addAbility, isFinisher : bool;		
	var expPoints, npcLevel, lvlDiff, i, j 				: int;
	var abilityName, tmpName 							: name;
	var abilityCount, maxStack, minDist					: float;
	var itemExpBonus, radius							: float;
	var allItems 										: array<SItemUniqueId>;
	var damages 										: array<SRawDamage>;
	var atts 											: array<name>;
	var entities  										: array< CGameplayEntity >;
	var params											: SCustomEffectParams;
	var dmg 											: SRawDamage;
	var weaponID 										: SItemUniqueId;
	var min, max, bonusExp 								: SAbilityAttributeValue;
	var monsterCategory 								: EMonsterCategory;
	var attitudeToPlayer 								: EAIAttitude;
	var actor , targetEntity							: CActor;
	var gameplayEffect 									: CBaseGameplayEffect;
	var fxEnt 											: CEntity;
	var attackAction 									: W3Action_Attack;	
	var ciriEntity  									: W3ReplacerCiri;
	var witcher											: W3PlayerWitcher;
	var blizzard 										: W3Potion_Blizzard;
	var act 											: W3DamageAction;
	var burningCauser 									: W3Effect_Burning;
	var vfxEnt 											: W3VisualFx;
	var arrInt											: array<int>;
	var pts, prc										: float;
	
	ciriEntity = (W3ReplacerCiri)thePlayer;
	witcher = GetWitcherPlayer();
	
	deathTimestamp = theGame.GetEngineTimeAsSeconds();

	if(damageAction.attacker == GetWitcherPlayer() && (damageAction.IsActionMelee() || damageAction.IsActionRanged() || damageAction.IsActionWitcherSign() || damageAction.GetBuffSourceName() == "Kill" || damageAction.GetBuffSourceName() == "Finisher" || damageAction.GetBuffSourceName() == "AutoFinisher"))
	{
		if(thePlayer.CanUseSkill(S_Perk_21))
		{
			GetWitcherPlayer().GainAdrenalineFromPerk21('kill');
		}

		if(GetWitcherPlayer().HasRunewordActive('Runeword 10 _Stats'))
			GetWitcherPlayer().Runeword10Triggerred();
		if(GetWitcherPlayer().HasRunewordActive('Runeword 12 _Stats'))
			GetWitcherPlayer().Runeword12Triggerred();

		if(thePlayer.HasBuff(EET_Mutation3))
			((W3Effect_Mutation3)thePlayer.GetBuff(EET_Mutation3)).ManageMutation3Bonus(damageAction);
	}
	
	
	if( damageAction.GetBuffSourceName() == "Mutation 6" )
	{
		PlayEffect( 'critical_frozen' );
		AddTimer( 'StopMutation6FX', 3.f );
	}
	
	if ( GetWitcherPlayer().HasGlyphwordActive('Glyphword 18 _Stats') && (HasBuff(EET_AxiiGuardMe) || HasBuff(EET_Confusion)) )
	{
		abilityName = 'Glyphword 18 _Stats';
			
		min = thePlayer.GetAbilityAttributeValue(abilityName, 'glyphword_range');
		FindGameplayEntitiesInRange(entities, this, CalculateAttributeValue(min), 10,, FLAG_OnlyAliveActors + FLAG_ExcludeTarget, this); 	
		
		minDist = 10000;
		for (i = 0; i < entities.Size(); i += 1)
		{
			if ( entities[i] == thePlayer.GetHorseWithInventory() || entities[i] == thePlayer || !IsRequiredAttitudeBetween(thePlayer, entities[i], true) )
				continue;
			
			if ( ((CActor)entities[i]).HasBuff(EET_AxiiGuardMe) || ((CActor)entities[i]).HasBuff(EET_Confusion) )
				continue;
			
			if ( HasBuff(EET_AxiiGuardMe) && ((CActor)entities[i]).IsImmuneToBuff(EET_AxiiGuardMe) || HasBuff(EET_Confusion) && ((CActor)entities[i]).IsImmuneToBuff(EET_Confusion) )
				continue;

			((CActor)entities[i]).GetResistValue(CDS_WillRes, pts, prc);
			if ( prc >= 1.0 )
				continue;
				
			if ( VecDistance2D(this.GetWorldPosition(), entities[i].GetWorldPosition()) < minDist )
			{
				minDist = VecDistance2D(this.GetWorldPosition(), entities[i].GetWorldPosition());
				targetEntity = (CActor)entities[i];
			}
		}
		
		if ( targetEntity )
		{
			if ( HasBuff(EET_AxiiGuardMe) )
				gameplayEffect = GetBuff(EET_AxiiGuardMe);
			else if ( HasBuff(EET_Confusion) )
				gameplayEffect = GetBuff(EET_Confusion);
			
			params.effectType 				= gameplayEffect.GetEffectType();
			params.creator 					= gameplayEffect.GetCreator();
			params.sourceName 				= gameplayEffect.GetSourceName();
			params.duration 				= gameplayEffect.GetDurationLeft();
			if ( params.duration < 5.0f ) 	params.duration = 5.0f;
			params.effectValue 				= gameplayEffect.GetEffectValue();
			params.customAbilityName 		= gameplayEffect.GetAbilityName();
			params.customFXName 			= gameplayEffect.GetTargetEffectName();
			params.isSignEffect 			= gameplayEffect.IsSignEffect();
			params.customPowerStatValue 	= gameplayEffect.GetCreatorPowerStat();
			params.vibratePadLowFreq 		= gameplayEffect.GetVibratePadLowFreq();
			params.vibratePadHighFreq		= gameplayEffect.GetVibratePadHighFreq();
			
			targetEntity.AddEffectCustom(params);
			gameplayEffect = targetEntity.GetBuff(params.effectType);
			gameplayEffect.SetTimeLeft(params.duration);
			
			fxEnt = CreateFXEntityAtPelvis( 'glyphword_10_18', true );
			fxEnt.PlayEffect('out');
			fxEnt.DestroyAfter(5);
			
			fxEnt = targetEntity.CreateFXEntityAtPelvis( 'glyphword_10_18', true );
			fxEnt.PlayEffect('in');
			fxEnt.DestroyAfter(5);
		}
	}
	
	super.OnDeath( damageAction );
	
	if (!IsHuman() && damageAction.attacker == thePlayer && !ciriEntity && !HasTag('NoBestiaryEntry') ) AddBestiaryKnowledge();
	
	if ( !WillBeUnconscious() && !HasTag( 'NoHitFx' ) )
	{
		if ( theGame.GetWorld().GetWaterDepth( this.GetWorldPosition() ) > 0 )
		{
			if ( this.HasEffect( 'water_death' ) ) this.PlayEffectSingle( 'water_death' );
		}
		else
		{
			if ( this.HasEffect( 'blood_spill' ) && !HasAbility ( 'NoBloodSpill' ) ) this.PlayEffectSingle( 'blood_spill' );
		}
	}
	
	
	if ( ( ( CMovingPhysicalAgentComponent ) this.GetMovingAgentComponent() ).HasRagdoll() )
	{
		SetBehaviorVariable('HasRagdoll', 1 );
	}
	
	
	if ( (W3AardProjectile)( damageAction.causer ) )
	{
		DropItemFromSlot( 'r_weapon' );
		DropItemFromSlot( 'l_weapon' );
		this.BreakAttachment();
	}
	
	SignalGameplayEventParamObject( 'OnDeath', damageAction );
	theGame.GetBehTreeReactionManager().CreateReactionEvent( this, 'BattlecryGroupDeath', 1.0f, 20.0f, -1.0f, 1 );
	
	attackAction = (W3Action_Attack)damageAction;
	
	
	if ( ((CMovingPhysicalAgentComponent)GetMovingAgentComponent()).GetSubmergeDepth() < 0 )
	{
		inWater = true;
		DisableAgony();
	}
	
	
	if( IsUsingHorse() )
	{
		SoundEvent( "cmb_play_hit_heavy" );
		SoundEvent( "grunt_vo_death" );
	}
					
	if(damageAction.attacker == thePlayer && ((W3PlayerWitcher)thePlayer) && thePlayer.GetStat(BCS_Toxicity) > 0 && thePlayer.CanUseSkill(S_Alchemy_s17))
	{
		thePlayer.AddAbilityMultiple( SkillEnumToName(S_Alchemy_s17), thePlayer.GetSkillLevel(S_Alchemy_s17) );
	}
	
	OnChangeDyingInteractionPriorityIfNeeded();
	
	actor = (CActor)damageAction.attacker;
	
	
	if(ShouldGiveExp(damageAction.attacker))
	{
		npcLevel = (int)CalculateAttributeValue(GetAttributeValue('level',,true));
		lvlDiff = npcLevel - witcher.GetLevel();
		expPoints = CalculateExperiencePoints();
		
		
		if(expPoints > 0)
		{				
			theGame.GetMonsterParamsForActor(this, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
			if(MonsterCategoryIsMonster(monsterCategory))
			{
				bonusExp = thePlayer.GetAttributeValue('nonhuman_exp_bonus_when_fatal');
			}
			else
			{
				bonusExp = thePlayer.GetAttributeValue('human_exp_bonus_when_fatal');
			}				
			
			expPoints = RoundMath( expPoints * (1 + CalculateAttributeValue(bonusExp)) * theGame.expGlobalMod_kills );
			expPoints = Max(1, expPoints);
			
			if( spectre_Settings_Main_Float('spectreExpOptions','spectreMonsterExpModifier', 0) != 0 )
				expPoints = RoundMath(expPoints * (1 + spectre_Settings_Main_Float('spectreExpOptions','spectreMonsterExpModifier', 0)));
			GetWitcherPlayer().AddPoints(EExperiencePoint, expPoints, false );

			arrInt.PushBack(expPoints);
			theGame.witcherLog.AddMessage( GetLocStringByKeyExtWithParams("hud_combat_log_gained_experience", arrInt) );
		}			
	}
			
	
	attitudeToPlayer = GetAttitudeBetween(this, thePlayer);
	
	if(attitudeToPlayer == AIA_Hostile && !HasTag('AchievementKillDontCount'))
	{
		
		if(actor && actor.HasBuff(EET_AxiiGuardMe))
		{
			theGame.GetGamerProfile().IncStat(ES_CharmedNPCKills);
			FactsAdd("statistics_cerberus_sign");
		}
		
		
		if( aardedFlight && damageAction.GetBuffSourceName() == "FallingDamage" )
		{
			theGame.GetGamerProfile().IncStat(ES_AardFallKills);
		}
			
		
		if(damageAction.IsActionEnvironment())
		{
			theGame.GetGamerProfile().IncStat(ES_EnvironmentKills);
			FactsAdd("statistics_cerberus_environment");
		}
	}
	
	
	if(HasTag('cow'))
	{
		if( (damageAction.attacker == thePlayer) ||
			((W3SignEntity)damageAction.attacker && ((W3SignEntity)damageAction.attacker).GetOwner() == thePlayer) ||
			((W3SignProjectile)damageAction.attacker && ((W3SignProjectile)damageAction.attacker).GetCaster() == thePlayer) ||
			( (W3Petard)damageAction.attacker && ((W3Petard)damageAction.attacker).GetOwner() == thePlayer)
		){
			theGame.GetGamerProfile().IncStat(ES_KilledCows);
		}
	}
	
	
	if ( damageAction.attacker == thePlayer )
	{
		theGame.GetMonsterParamsForActor(this, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
		
		if(thePlayer.HasBuff(EET_Mutagen13))
			((W3Mutagen13_Effect)thePlayer.GetBuff(EET_Mutagen13)).ManageMutagen13Bonus();
		
		if(thePlayer.HasBuff(EET_Mutagen18))
		{
			((W3Mutagen18_Effect)thePlayer.GetBuff(EET_Mutagen18)).ManageMutagen18Bonus();
		}
		
		
		if (thePlayer.HasBuff(EET_Mutagen06))
		{
			
			if(monsterCategory != MC_Animal || IsRequiredAttitudeBetween(this, thePlayer, true))
			{	
				gameplayEffect = thePlayer.GetBuff(EET_Mutagen06);
				thePlayer.AddAbility( gameplayEffect.GetAbilityName(), true);
			}
		}
		
		
		if(IsRequiredAttitudeBetween(this, thePlayer, true))
		{
			blizzard = (W3Potion_Blizzard)thePlayer.GetBuff(EET_Blizzard);
			if(blizzard)
				blizzard.KilledEnemy();
		}
		
		if(!HasTag('AchievementKillDontCount'))
		{
			if (damageAction.GetIsHeadShot() && monsterCategory == MC_Human )		
				theGame.GetGamerProfile().IncStat(ES_HeadShotKills);
				
			
			if( (W3SignEntity)damageAction.causer || (W3SignProjectile)damageAction.causer)
			{
				FactsAdd("statistics_cerberus_sign");
			}
			else if( (CBaseGameplayEffect)damageAction.causer && ((CBaseGameplayEffect)damageAction.causer).IsSignEffect())
			{
				FactsAdd("statistics_cerberus_sign");
			}
			else if( (W3Petard)damageAction.causer )
			{
				FactsAdd("statistics_cerberus_petard");
			}
			else if( (W3BoltProjectile)damageAction.causer )
			{
				FactsAdd("statistics_cerberus_bolt");
			}				
			else
			{
				if(!attackAction)
					attackAction = (W3Action_Attack)damageAction;
					
				fists = false;
				if(attackAction)
				{
					weaponID = attackAction.GetWeaponId();
					if(damageAction.attacker.GetInventory().IsItemFists(weaponID))
					{
						FactsAdd("statistics_cerberus_fists");
						fists = true;
					}						
				}
				
				if(!fists && damageAction.IsActionMelee())
				{
					FactsAdd("statistics_cerberus_melee");
				}
			}
		}
		
		
		if( expPoints > 0 && !HasTag( 'AchievementKillDontCount' ) && thePlayer.inv.HasItem( 'q705_tissue_extractor' ) )
		{
			thePlayer.TissueExtractorIncCharge();
		}
		
		
		if( (W3BoltProjectile)damageAction.causer && damageAction.GetWasFrozen() && !WillBeUnconscious() )
		{
			theGame.GetGamerProfile().AddAchievement( EA_HastaLaVista );
			thePlayer.PlayVoiceset( 100, "HastaLaVista", true );
		}
					
		
		
	}
	
	
	if( damageAction.attacker == thePlayer || !((CNewNPC)damageAction.attacker) )
	{
		theTelemetry.LogWithLabelAndValue(TE_FIGHT_ENEMY_DIES, this.ToString(), GetLevel());
	}
	
	
	if(damageAction.attacker == thePlayer && !HasTag('AchievementKillDontCount'))
	{
		if ( attitudeToPlayer == AIA_Hostile )
		{
			
			if(!HasTag('AchievementSwankDontCount'))
			{
				if(FactsQuerySum("statistic_killed_in_10_sec") >= 4)
					theGame.GetGamerProfile().AddAchievement(EA_Swank);
				else
					FactsAdd("statistic_killed_in_10_sec", 1, 10);
			}
			
			
			if( witcher && !thePlayer.ReceivedDamageInCombat() && !witcher.UsedQuenInCombat())
			{
				theGame.GetGamerProfile().IncStat(ES_FinesseKills);
			}
		}
		
		
		if((W3PlayerWitcher)thePlayer)
		{
			if(!thePlayer.DidFailFundamentalsFirstAchievementCondition() && HasTag(theGame.params.MONSTER_HUNT_ACTOR_TAG) && !HasTag('failedFundamentalsAchievement'))
			{
				theGame.GetGamerProfile().IncStat(ES_FundamentalsFirstKills);
			}
		}
	}
				
	
	if(!inWater && (W3IgniProjectile)damageAction.causer)
	{
		
		if(RandF() < 0.3 && !WillBeUnconscious() )
		{
			AddEffectDefault(EET_Burning, this, 'IgniKill', true);
			EnableAgony();
			SignalGameplayEvent('ForceAgony');			
		}
	}
	
	
	OnDeathMutation2( damageAction );		
	
	
	if(damageAction.attacker == thePlayer && GetWitcherPlayer().HasGlyphwordActive('Glyphword 20 _Stats') && damageAction.GetBuffSourceName() != "Glyphword 20")
	{
		burningCauser = (W3Effect_Burning)damageAction.causer;			
		
		if(IsRequiredAttitudeBetween(thePlayer, damageAction.victim, true, false, false) && ((burningCauser && burningCauser.IsSignEffect()) || (W3IgniProjectile)damageAction.causer))
		{
			damageAction.SetForceExplosionDismemberment();
			
			
			radius = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Glyphword 20 _Stats', 'radius'));
			
			
			theGame.GetDefinitionsManager().GetAbilityAttributes('Glyphword 20 _Stats', atts);
			for(i=0; i<atts.Size(); i+=1)
			{
				if(IsDamageTypeNameValid(atts[i]))
				{
					dmg.dmgType = atts[i];
					dmg.dmgVal = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Glyphword 20 _Stats', dmg.dmgType));
					damages.PushBack(dmg);
				}
			}
			
			
			FindGameplayEntitiesInSphere(entities, GetWorldPosition(), radius, 1000, , FLAG_OnlyAliveActors);
			
			
			for(i=0; i<entities.Size(); i+=1)
			{
				if(IsRequiredAttitudeBetween(thePlayer, entities[i], true, false, false))
				{
					act = new W3DamageAction in this;
					act.Initialize(thePlayer, entities[i], damageAction.causer, "Glyphword 20", EHRT_Heavy, CPS_SpellPower, false, false, true, false);
					
					for(j=0; j<damages.Size(); j+=1)
					{
						act.AddDamage(damages[j].dmgType, damages[j].dmgVal);
					}
					
					act.AddEffectInfo(EET_Burning);
					
					theGame.damageMgr.ProcessAction(act);
					delete act;
				}
			}
			
			CreateFXEntityAtPelvis( 'glyphword_20_explosion', false );				
		}
	}
	
	
	if(attackAction && IsWeaponHeld('fist') && damageAction.attacker == thePlayer && !thePlayer.ReceivedDamageInCombat() && !HasTag('AchievementKillDontCount'))
	{
		weaponID = attackAction.GetWeaponId();
		if(thePlayer.inv.IsItemFists(weaponID))
			theGame.GetGamerProfile().AddAchievement(EA_FistOfTheSouthStar);
	}
	
	
	if(damageAction.IsActionRanged() && damageAction.IsBouncedArrow())
	{
		theGame.GetGamerProfile().IncStat(ES_SelfArrowKills);
	}
	
	
	isFinisher = ( damageAction.GetBuffSourceName() == "Finisher" || damageAction.GetBuffSourceName() == "AutoFinisher" );
	if( damageAction.attacker == thePlayer && ( damageAction.IsActionMelee() || isFinisher ) )
	{			
		weaponID = attackAction.GetWeaponId();
		
		if( isFinisher && !thePlayer.inv.IsIdValid( weaponID ) )
		{
			weaponID = thePlayer.inv.GetCurrentlyHeldSword();
		}
	}		
}

@wrapMethod(CNewNPC) function IsImmuneToMutation8Finisher() : bool
{
	var min, max : SAbilityAttributeValue;
	var str : string;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if( !IsAlive() || !IsRequiredAttitudeBetween( thePlayer, this, true ) )
	{
		return true;
	}
	
	if( WillBeUnconscious() )
	{
		return true;
	}
	
	str = GetName();
	if( StrStartsWith( str, "rosa_var_attre" ) )
	{
		return true;
	}
			
	theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation8', 'hp_perc_trigger', min, max );
	if( GetHealthPercents() > min.valueMultiplicative )
	{
		return true;
	}
	
	return false;
}

@addMethod(CNewNPC) function Mutation8RepelToFinisherImmune() : bool
{
	if( !IsHuman() || !IsAlive() || !IsRequiredAttitudeBetween( thePlayer, this, true ) )
	{
		return true;
	}
	
	if( HasAbility( 'SkillBoss' ) )
	{
		return true;
	}
	if( HasAbility( 'Boss' ) )
	{
		return true;
	}
	if( HasAbility( 'InstantKillImmune' ) )
	{
		return true;
	}
	if( HasTag( 'olgierd_gpl' ) )
	{
		return true;
	}
	if( HasAbility( 'DisableFinishers' ) )
	{
		return true;
	}
	if( HasTag( 'Mutation8CounterImmune' ) )
	{
		return true;
	}
	
	return IsImmuneToMutation8Finisher();
}

@addField(CNewNPC)
public var haklandMageHack : float;
	
@addMethod(CNewNPC) function HaklandMageDebuffProjectileHack() : bool
{
	var ret : bool;
	if(HasAbility('HaklandMage'))
	{
		if(theGame.GetEngineTimeAsSeconds() - haklandMageHack < 3.0)
			ret = true;
		haklandMageHack = theGame.GetEngineTimeAsSeconds();
	}
	return ret;
}

@wrapMethod(CNewNPC) function OnFireHit(source : CGameplayEntity)
{	
	wrappedMethod(source);
	
	if ( HasAbility( 'IceArmor') )
	{
		this.RemoveAbility( 'IceArmor' );
		this.StopEffect( 'ice_armor' );
		this.PlayEffect( 'ice_armor_hit' );
	}
}

@wrapMethod(CNewNPC) function OnAardHit( sign : W3AardProjectile )
{
	if(false) 
	{
		wrappedMethod(sign);
	}
	
	if( !sign.GetOwner().GetPlayer() || SignDRGetAardTier() == 1 )
	{
		SignalGameplayEvent( 'AardHitReceived' );
		aardedFlight = true;
	}
	
	if( !sign.GetOwner().GetPlayer() || !GetWitcherPlayer().IsMutationActive( EPMT_Mutation6 ) )
	{
		RemoveAllBuffsOfType(EET_Frozen);
	}
	
	super.OnAardHit(sign);
	
	if ( HasTag('small_animal') )
	{
		Kill( 'Small Animal Aard Hit' );
	}
	if ( IsShielded(sign.GetCaster()) )
	{
		ToggleEffectOnShield('aard_cone_hit', true);
	}
	else if ( HasAbility('ablIgnoreSigns') )
	{
		this.SignalGameplayEvent( 'IgnoreSigns' );
		this.SetBehaviorVariable( 'bIgnoreSigns',1.f );
		AddTimer('IgnoreSignsTimeOut',0.2,false);
	}
	
	if ( !IsAlive() && deathTimestamp + 0.2 < theGame.GetEngineTimeAsSeconds() )
	{
		SignalGameplayEvent('AbandonAgony');
		
		if( !HasAbility( 'mon_bear_base' )
			&& !HasAbility( 'mon_golem_base' )
			&& !HasAbility( 'mon_endriaga_base' )
			&& !HasAbility( 'mon_gryphon_base' )
			&& !HasAbility( 'q604_shades' )
			&& !IsAnimal()	)
		{			
			SetKinematic( false );
		}
	}
}

@wrapMethod(CNewNPC) function RemoveMutation4BloodDebuff( dt : float, id : int )
{
	if(false) 
	{
		wrappedMethod(dt, id);
	}
}

@wrapMethod(CNewNPC) function OnTakeDamage( action : W3DamageAction )
{
	var i : int;
	var min, max : SAbilityAttributeValue;
	var witcher : W3PlayerWitcher;
	var attackAction : W3Action_Attack;
	var gameplayEffects : array<CBaseGameplayEffect>;
	var template : CEntityTemplate;
	var hud : CR4ScriptedHud;
	var ent : CEntity;
	var weaponId : SItemUniqueId;
	var dur : float;
	var updHUD : bool;
	
	if(false) 
	{
		wrappedMethod(action);
	}

	super.OnTakeDamage(action);
	
	
	if(action.IsActionMelee() && action.DealsAnyDamage())
	{
		witcher = (W3PlayerWitcher)action.attacker;
		
		attackAction = (W3Action_Attack)action;
	}
	
	if(action.IsActionMelee())
		lastMeleeHitTime = theGame.GetEngineTime();
	
	
	if( (W3PlayerWitcher)action.attacker && action.IsActionRanged() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
	{
		attackAction = (W3Action_Attack)action;
		if( attackAction )
		{
			weaponId = attackAction.GetWeaponId();
			if( thePlayer.inv.IsItemCrossbow( weaponId ) || thePlayer.inv.IsItemBolt( weaponId ) )
			{
				theGame.MutationHUDFeedback( MFT_PlayOnce );
			}
		}
	}

	if( (W3PlayerWitcher)action.attacker && action.DealsAnyDamage() && !(action.IsDoTDamage() && (CBaseGameplayEffect)action.causer) )
	{
		if( HasBuff(EET_YrdenHealthDrain) )
			((W3Effect_YrdenHealthDrain)GetBuff(EET_YrdenHealthDrain)).PlayFX();
	}
}
