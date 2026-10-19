class W3Effect_PhantomWeapon extends CBaseGameplayEffect
{
	default effectType 				= EET_PhantomWeapon;
	default isPositive 				= true;

	private var xml_dmg_bonus_prc			: float;
	private var xml_hitsToCharge			: int;
	private var xml_stackDrainDelay			: float;

	private var currCount					: int;
	private var drainDelay					: float;

	private var chargedLoopedFxName			: name;
	private var chargedSingleFxName			: name;
	default chargedLoopedFxName = 'special_attack_charged';
	default chargedSingleFxName = 'special_attack_ready';

	private var inv							: CInventoryComponent;
	private var itemId						: SItemUniqueId;
	
	private function InitXmlValues()
	{
		var defMgr : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var min, max : SAbilityAttributeValue;
	
		defMgr.GetAbilityAttributeValue(abilityName, 'dmg_bonus_prc', min, max);
		xml_dmg_bonus_prc = CalculateAttributeValue(min);
		defMgr.GetAbilityAttributeValue(abilityName, 'hitsToCharge', min, max);
		xml_hitsToCharge = RoundMath(CalculateAttributeValue(min));
		defMgr.GetAbilityAttributeValue(abilityName, 'stackDrainDelay', min, max);
		xml_stackDrainDelay = CalculateAttributeValue(min);
	}
	
	private function InitWeapon()
	{
		var itemIds : array<SItemUniqueId>;
		
		inv = target.GetInventory();
		itemIds = inv.GetItemsByTag('PhantomWeapon');
		
		if(itemIds.Size())
			itemId = itemIds[0];
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		InitXmlValues();
		InitWeapon();
		ResetCharges();
		super.OnEffectAdded( customParams );
	}
	
	event OnEffectRemoved()
	{
		ResetCharges();
		super.OnEffectRemoved();
	}
	
	protected function OnPaused()
	{
		super.OnPaused();
		
		SetShowOnHUD(false);
		ResetCharges();
	}
	
	protected function OnResumed()
	{
		super.OnResumed();
		
		SetShowOnHUD(true);
		ResetCharges();
	}
	
	protected function StopTargetFX()
	{
		super.StopTargetFX();
		StopChargedFX();
	}
	
	event OnUpdate( deltaTime : float )
	{
		drainDelay -= deltaTime;
		
		if(drainDelay <=0)
			RemoveCharge();
		
		super.OnUpdate(deltaTime);
	}
	
	private function PlayChargedFX()
	{
		inv.PlayItemEffect( itemId, chargedLoopedFxName );
		inv.PlayItemEffect( itemId, chargedSingleFxName );
	}
	
	private function StopChargedFX()
	{
		inv.StopItemEffect( itemId, chargedLoopedFxName );
		inv.StopItemEffect( itemId, chargedSingleFxName );
	}
	
	public function RemoveCharge()
	{
		drainDelay = xml_stackDrainDelay;
		
		if(currCount <= 0)
			return;
		
		if(IsWeaponCharged())
			ResetCharges();
		else
		{
			currCount -= 1;
			if(currCount == 0)
				StopChargedFX();
		}
	}
	
	public function AddCharge()
	{
		drainDelay = xml_stackDrainDelay;
		
		if(IsWeaponCharged())
			return;
		
		currCount += 1;
		if(currCount == xml_hitsToCharge)
			PlayChargedFX();
	}
	
	public function ResetCharges()
	{
		currCount = 0;
		StopChargedFX();
	}
	
	public function DischargePhantomWeapon()
	{
		ResetCharges();
		target.RemoveAbility('ForceDismemberment');
	}
	
	public function GetDamageBoost() : float
	{
		var bonus : float;
		
		bonus = target.GetMaxHealth() * xml_dmg_bonus_prc;
		bonus = MinF(bonus, target.GetCurrentHealth());
		
		return bonus;
	}
	
	public function DrainAttackerHealth()
	{
		var hpToDrain : float;
		
		hpToDrain = GetDamageBoost();
		hpToDrain = MinF(hpToDrain, target.GetCurrentHealth() - 1);
		hpToDrain = ClampF(hpToDrain, 0, target.GetMaxHealth() - 1);
		
		if(hpToDrain > 0)
			target.DrainVitality(hpToDrain);
	}
	
	public function IsWeaponCharged() : bool
	{
		return currCount == xml_hitsToCharge;
	}
	
	public function GetCurrentCount() : int
	{
		return currCount;
	}
	
	public function GetMaxCount() : int
	{
		return xml_hitsToCharge;
	}

	public function IncrementHitCounter()
	{
		
	}

	public function DischargeWeapon( optional afterHit : bool )
    {
		
	}
}
