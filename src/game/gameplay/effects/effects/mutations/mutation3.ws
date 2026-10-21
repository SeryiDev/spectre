/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Mutation3 extends CBaseGameplayEffect
{
	private var stacks : int;
	private var maxCap : int;
	private var apBonus : float;
	
	default effectType = EET_Mutation3;
	default isPositive = true;
	default stacks = 0;

	default dontAddAbilityOnTarget = true;
	
	private var mutationAbilityName : name;
	private var buffRateSword : int;
	private var buffRateOther : int;
	private var buffRateKill : int;
	private var debuffRate : int;
	private var maxStacks : int;
	
	private function InitVars()
	{
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var min, max : SAbilityAttributeValue;
	
		mutationAbilityName = 'Mutation3';
		dm.GetAbilityAttributeValue(mutationAbilityName, 'attack_power', min, max);
		apBonus = min.valueMultiplicative;
		dm.GetAbilityAttributeValue(mutationAbilityName, 'mutation3_maxcap', min, max);
		maxCap = RoundMath(min.valueAdditive);
		dm.GetAbilityAttributeValue(mutationAbilityName, 'mutation3_buff_rate_sword', min, max);
		buffRateSword = RoundMath(min.valueAdditive);
		dm.GetAbilityAttributeValue(mutationAbilityName, 'mutation3_buff_rate_other', min, max);
		buffRateOther = RoundMath(min.valueAdditive);
		dm.GetAbilityAttributeValue(mutationAbilityName, 'mutation3_buff_rate_kill', min, max);
		buffRateKill = RoundMath(min.valueAdditive);
		dm.GetAbilityAttributeValue(mutationAbilityName, 'mutation3_debuff_rate', min, max);
		debuffRate = RoundMath(min.valueAdditive);
	}
	
	private function CalcInitialNumAbl() : int
	{
		var skillSlots : array <SSkillSlot>;
		var pathType : ESkillPath;
		var i, ablNum : int;
		
		ablNum = 0;
		skillSlots = thePlayer.GetSkillSlots();
		for(i = 0; i < skillSlots.Size(); i += 1)
		{
			if(skillSlots[i].unlocked)
			{
				pathType = GetWitcherPlayer().GetSkillPathType(skillSlots[i].socketedSkill);
				if(pathType != ESP_NotSet)
				{
					if(pathType == ESP_Sword)
						ablNum += buffRateSword;
					else
						ablNum += buffRateOther;
				}
			}
		}
		
		return ablNum;
	}
	
	private function RemoveAllAbls()
	{
		thePlayer.RemoveAbilityAll(mutationAbilityName);
		stacks = 0;
	}
	
	private function SetAbls(num : int)
	{
		var abilityCount : int;
		
		if(num > maxCap)
			num = maxCap;
		
		abilityCount = thePlayer.GetAbilityCount(mutationAbilityName);
		
		if(abilityCount < num)
		{
			thePlayer.AddAbilityMultiple(mutationAbilityName, num - abilityCount);
			PlayFX();
		}
		else if(abilityCount > num)
		{
			thePlayer.RemoveAbilityMultiple(mutationAbilityName, abilityCount - num);
		}
		stacks = thePlayer.GetAbilityCount(mutationAbilityName);
	}
	
	private function AddAbls(num : int)
	{
		var abilityCount : int;
		
		abilityCount = thePlayer.GetAbilityCount(mutationAbilityName);
		
		if(abilityCount + num > maxCap)
			num = maxCap - abilityCount;
		
		thePlayer.AddAbilityMultiple(mutationAbilityName, num);
		stacks = thePlayer.GetAbilityCount(mutationAbilityName);
		PlayFX();
	}
	
	private function RemoveAbls(num : int)
	{
		var abilityCount : int;
		
		abilityCount = thePlayer.GetAbilityCount(mutationAbilityName);
		
		if(abilityCount - num <= 0)
			thePlayer.RemoveAbilityAll(mutationAbilityName);
		
		thePlayer.RemoveAbilityMultiple(mutationAbilityName, num);
		stacks = thePlayer.GetAbilityCount(mutationAbilityName);
	}
	
	public function ManageMutation3Bonus(damageAction : W3DamageAction)
	{
		var attackAction : W3Action_Attack;
		
		attackAction = (W3Action_Attack)damageAction;
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			if(damageAction.attacker == thePlayer && !damageAction.victim.IsAlive()
				&& (attackAction && attackAction.IsActionMelee() && attackAction.DealsAnyDamage() && !thePlayer.GetInventory().IsItemFists(attackAction.GetWeaponId())
				|| damageAction.GetBuffSourceName() == "Kill" || damageAction.GetBuffSourceName() == "Finisher"))
			{
				maxStacks += buffRateKill;
				if(maxStacks > maxCap)
					maxStacks = maxCap;
				SetAbls(maxStacks);
			}
			else if(damageAction.victim == thePlayer && damageAction.DealsAnyDamage()
				&& !(damageAction.IsDoTDamage() && (CBaseGameplayEffect)damageAction.causer))
			{
				RemoveAbls(RoundMath(debuffRate * damageAction.GetDamageDealt() / thePlayer.GetMaxHealth() * 100));
			}
		}
		else
		{
			RemoveAllAbls();
		}
	}
	
	private function PlayFX()
	{
		var sword : CItemEntity;
		thePlayer.GetInventory().GetCurrentlyHeldSwordEntity( sword );
		sword.PlayEffect( 'instant_fx' );
	}
	
	event OnEffectAddedPost()
	{
		var min, max : SAbilityAttributeValue;
		var sword : CItemEntity;
		
		super.OnEffectAddedPost();
		
		InitVars();
		maxStacks = CalcInitialNumAbl();
		SetAbls(maxStacks);
		
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}

	public function GetStacks() : int
	{
		return RoundMath( stacks * apBonus * 100 );
	}
	
	event OnEffectRemoved()
	{
		RemoveAllAbls();
		
		theGame.MutationHUDFeedback( MFT_PlayHide );
		
		super.OnEffectRemoved();
	}
}
