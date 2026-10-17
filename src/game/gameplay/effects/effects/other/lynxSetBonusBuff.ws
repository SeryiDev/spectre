/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_LynxSetBonus extends CBaseGameplayEffect
{
	default effectType = EET_LynxSetBonus;
	default isPositive = true;
	
	var bonus, curBonus, maxBonus : float;
	var decay : float;
	const var DECAY_DELAY : float; default DECAY_DELAY = 3.f;
	
	public function GetLynxBonus(isHeavy : bool) : float
	{
		if(isHeavy)
			return curBonus * 2;
		return curBonus;
	}
	
	public function ManageLynxBonus(isHeavy : bool)
	{
		if(isHeavy && curBonus > 0)
			Discharge();
		else if(!isHeavy)
			Accumulate();
	}
	
	private function Discharge()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		
		if(inv.GetCurrentlyHeldSwordEntity(swEnt))
		{
			swEnt.StopEffectIfActive('fast_attack_buff');
			swEnt.PlayEffectSingle('fast_attack_buff_hit');
		}
		
		curBonus = 0;
		decay = 0;
	}
	
	private function Accumulate()
	{
		var inv			: CInventoryComponent;
		var swEnt		: CItemEntity;
		
		inv = target.GetInventory();
		
		if(inv.GetCurrentlyHeldSwordEntity(swEnt) && !swEnt.IsEffectActive('fast_attack_buff'))
		{
			swEnt.PlayEffect('fast_attack_buff');
		}
		
		if(curBonus < maxBonus)
		{
			curBonus += bonus * ((W3PlayerWitcher)target).GetSetPartsEquipped(EIST_Lynx);
			curBonus = MinF(curBonus, maxBonus);
		}
		
		decay = DECAY_DELAY;
	}
	
	public function ResetDecay()
	{
		decay = DECAY_DELAY;
	}
	
	public final function GetStacks() : int
	{
		return RoundMath(curBonus * 100);
	}
	
	public final function GetMaxStacks() : int
	{
		return RoundMath(maxBonus * 100);
	}
	
	event OnEffectAdded(customParams : W3BuffCustomParams)
	{
		var dm			: CDefinitionsManagerAccessor;
		var min, max 	: SAbilityAttributeValue;
		
		dm = theGame.GetDefinitionsManager();
		
		dm.GetAbilityAttributeValue('LynxSetBonusEffect', 'lynx_ap_boost', min, max);
		bonus = min.valueAdditive;
		dm.GetAbilityAttributeValue('LynxSetBonusEffect', 'lynx_boost_max', min, max);
		maxBonus = min.valueAdditive;
		
		super.OnEffectAdded(customParams);
	}

	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		if(decay > 0 && !thePlayer.IsDoingSpecialAttack(true))
			decay -= dt;
		
		if(decay < 0 && curBonus > 0)
			Discharge();
	}
	
	event OnEffectRemoved()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		
		if(inv.GetCurrentlyHeldSwordEntity(swEnt))
		{
			swEnt.StopEffectIfActive('fast_attack_buff');
		}
		
		super.OnEffectRemoved();
	}
	
	protected function OnPaused()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		if(inv.GetCurrentlyHeldSwordEntity(swEnt))
		{
			swEnt.StopEffectIfActive('fast_attack_buff');
		}
		
		super.OnPaused();
	}
	
	protected function OnResumed()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		if(inv.GetCurrentlyHeldSwordEntity(swEnt) && curBonus > 0)
		{
			swEnt.PlayEffect('fast_attack_buff');
		}
	
		super.OnResumed();
	}
};
