/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_WolfHour extends CBaseGameplayEffect
{
	default effectType = EET_WolfHour;
	
	protected saved var powerStat : ECharacterPowerStats;		
	
	protected var combatRegen, nonCombatRegen : SAbilityAttributeValue;			
	protected var playerTarget : CR4Player;
	
	protected var regenStat : ECharacterRegenStats;			
	protected saved var stat : EBaseCharacterStats;		
	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	public function Init(params : SEffectInitInfo)
	{
		attributeName = PowerStatEnumToName(powerStat);
		super.Init(params);
	}
	
	public function CacheSettings()
	{
		var i,size : int;
		var att : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
		var min, max : SAbilityAttributeValue;
							
		super.CacheSettings();
		
		if(regenStat == CRS_Undefined)
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributes(abilityName, att);
			size = att.Size();
			
			for(i=0; i<size; i+=1)
			{
				regenStat = RegenStatNameToEnum(att[i]);
				if(regenStat != CRS_Undefined)
					break;
			}
		}
		stat = GetStatForRegenStat(regenStat);
		attributeName = RegenStatEnumToName(regenStat);
		
		if(regenStat == CRS_Vitality)
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributes(abilityName, att);
			
			for(i=0; i<att.Size(); i+=1)
			{
				if(att[i] == 'vitalityCombatRegen')
				{
					dm.GetAbilityAttributeValue(abilityName, att[i], min, max);
					combatRegen = GetAttributeRandomizedValue(min, max);
				}
				else if(att[i] == 'vitalityRegen')
				{
					dm.GetAbilityAttributeValue(abilityName, att[i], min, max);
					nonCombatRegen = GetAttributeRandomizedValue(min, max);
					attributeName = att[i];
				}
			}
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var vitality : float;
		var vitAtt, min, max : SAbilityAttributeValue;
		var null : SAbilityAttributeValue;
		
		super.OnEffectAdded(customParams);
		
		if(effectValue == null)
		{
			isActive = false;
		}
		else if(target.GetStatMax(stat) <= 0)
		{
			isActive = false;
		}
		
		playerTarget = (CR4Player)target;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, StatEnumToName(BCS_Vitality), min, max);
		vitAtt = GetAttributeRandomizedValue(min, max);
		vitality = target.GetStatMax(BCS_Vitality) * vitAtt.valueMultiplicative + vitAtt.valueAdditive;
		target.GainStat(BCS_Vitality, vitality);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		playerTarget = (CR4Player)target;
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	event OnUpdate(deltaTime : float)
	{
		var regenPoints : float;
		var canRegen : bool;
		var hpRegenPauseBuff : W3Effect_DoTHPRegenReduce;
		var pauseRegenVal, armorModVal : SAbilityAttributeValue;
		var baseStaminaRegenVal : float;
		
		if(playerTarget.IsInCombat())
			effectValue = combatRegen;
		else
			effectValue = nonCombatRegen;
			
		super.OnUpdate(deltaTime);
		
		if(stat == BCS_Vitality && isOnPlayer && target == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 4 _Stats'))
		{
			canRegen = true;
		}
		else
		{
			canRegen = (target.GetStatPercents(stat) < 1);
		}
		
		if(canRegen)
		{
			
			regenPoints = effectValue.valueAdditive + effectValue.valueMultiplicative * target.GetStatMax(stat);
			
			if (isOnPlayer && regenStat == CRS_Stamina && attributeName == RegenStatEnumToName(regenStat) && GetWitcherPlayer())
			{
				baseStaminaRegenVal = GetWitcherPlayer().CalculatedArmorStaminaRegenBonus();
				
				regenPoints *= 1 + baseStaminaRegenVal;
			}
			
			else if(regenStat == CRS_Vitality || regenStat == CRS_Essence)
			{
				hpRegenPauseBuff = (W3Effect_DoTHPRegenReduce)target.GetBuff(EET_DoTHPRegenReduce);
				if(hpRegenPauseBuff)
				{
					pauseRegenVal = hpRegenPauseBuff.GetEffectValue();
					regenPoints = MaxF(0, regenPoints * (1 - pauseRegenVal.valueMultiplicative) - pauseRegenVal.valueAdditive);
				}
			}
			
			if( regenPoints > 0 )
				effectManager.CacheStatUpdate(stat, regenPoints * deltaTime);
		}
	}
	
	public function GetRegenStat() : ECharacterRegenStats
	{
		return regenStat;
	}
	
	public function UpdateEffectValue()
	{
		SetEffectValue();
	}
}
