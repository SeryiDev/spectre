/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_Mutation7Debuff extends W3Mutation7BaseEffect
{
	default effectType = EET_Mutation7Debuff;
	default isNegative = true;

	event OnEffectAdded( optional customParams : W3BuffCustomParams )
	{
		var fxEntity : CEntity;
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAdded( customParams );

		savedFocusPts = ((W3Mutation7DebuffParams)customParams).savedFocusPts;
		target.AddAbilityMultiple( 'Mutation7Debuff', savedFocusPts );
		
		fxEntity = target.CreateFXEntityAtPelvis( 'mutation7_flash', false );
		fxEntity.PlayEffect( 'debuff' );
		fxEntity.DestroyAfter( 10.f );
		target.PlayEffect( 'mutation_7_debaff' );
		target.SoundEvent( 'ep2_mutations_07_berserk_debuff' );
	}

	event OnEffectAddedPost()
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAddedPost();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation7Debuff', 'attack_power', min, max );
		apBonus = -min.valueMultiplicative;
	}

	event OnEffectRemoved()
	{
		target.RemoveAbilityAll( 'Mutation7Debuff' );

		target.StopEffect( 'mutation_7_debaff' );
		
		if( target.IsInCombat() )
		{
			target.AddEffectDefault( EET_Mutation7Buff, target, "Mutation 7 buff phase" );
		}
		
		super.OnEffectRemoved();
	}
}

class W3Mutation7DebuffParams extends W3BuffCustomParams
{
	var savedFocusPts : int;
}
