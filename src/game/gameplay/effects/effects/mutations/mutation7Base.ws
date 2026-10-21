/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutation7BaseEffect extends CBaseGameplayEffect
{
	protected var apBonus : float;
	protected var savedFocusPts : int;
	
	public function GetStacks() : int
	{
		return RoundMath( 100 * apBonus * savedFocusPts );
	}
}
