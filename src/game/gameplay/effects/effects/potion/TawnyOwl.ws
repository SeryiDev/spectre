/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/



class W3Potion_TawnyOwl extends CBaseGameplayEffect
{
	default effectType = EET_TawnyOwl;
	
	public function OnTimeUpdated(deltaTime : float)
	{
		var currentHour, level : int;
		//var toxicityThreshold : float;
		var freezeTime : bool; //modSpectre
		var runeword11Bonus : float; //modSpectre
		
		if( isActive && pauseCounters.Size() == 0)
		{
			timeActive += deltaTime;	
			if( duration != -1 )
			{
				freezeTime = false;

				if(target.GetStatPercents(BCS_Vitality) == 1.0f )
				freezeTime = true;
				
				level = GetBuffLevel();				
				currentHour = GameTimeHours(theGame.GetGameTime());
				if(level > 2 && (currentHour < GetHourForDayPart(EDP_Dawn) || currentHour >= GetHourForDayPart(EDP_Dusk)))
					freezeTime = true;
				
				if(!freezeTime)
				{
					if(isOnPlayer && thePlayer.HasBuff(EET_Runeword11))
					{
						runeword11Bonus = ((W3Effect_Runeword11)thePlayer.GetBuff(EET_Runeword11)).GetExpirationBonus();
						if(runeword11Bonus > 0)
							timeLeft -= deltaTime * (1 - runeword11Bonus);
					}
					else
						timeLeft -= deltaTime;
				}
					
				if( timeLeft <= 0 )
				{
					isActive = false;
				}
			}
			OnUpdate(deltaTime);	
		}
	}
}
