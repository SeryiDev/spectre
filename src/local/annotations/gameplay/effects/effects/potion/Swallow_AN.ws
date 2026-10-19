@addMethod(W3Potion_Swallow) function OnTimeUpdated(deltaTime : float)
{
	var freezeTime : bool;

	if( isActive && pauseCounters.Size() == 0)
	{
		timeActive += deltaTime;	
		if( duration != -1 )
		{
			freezeTime = false;

			if(target.GetStatPercents(BCS_Vitality) == 1.0f )
			freezeTime = true;
			
			if(!freezeTime)
			{
				timeLeft -= deltaTime;
			}
				
			if( timeLeft <= 0 )
			{
				isActive = false;		
			}
		}

		super.OnUpdate(deltaTime);	
	}
}
