/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/




enum EAlchemyExceptions
{
	EAE_NoException,	
	EAE_MissingIngredient,
	EAE_NotEnoughIngredients,	
	EAE_NoRecipe,
	EAE_CannotCookMore,
	EAE_CookNotAllowed,
	EAE_InCombat,
	EAE_Mounted, //modSpectre
	EAE_Preparations //modSpectre
}


struct SAlchemyRecipe
{
	var cookedItemName : name;							
	var cookedItemType : EAlchemyCookedItemType;		
	var cookedItemIconPath : string;
	var cookedItemQuantity : int;						
	var cookedItemSubstance : name; //modSpectre
	var recipeName : name;								
	var recipeIconPath : string;
	var typeName : name;								
	var level : int;									
	var status : EAlchemyExceptions; //modSpectre
	var spectreKey : name; //modSpectre: the entry of Spectre's alchemy menu (the item of its level, or the recipe)
	var spectreLevel : int; //modSpectre: 1 normal, 2 enhanced, 3 superior; 0 for a recipe without levels
	var requiredIngredients : array<SItemParts>;
};

enum EAlchemyCookedItemType 
{
	EACIT_Undefined,
	EACIT_Potion,
	EACIT_Bomb,
	EACIT_Oil,
EACIT_Substance,		
	EACIT_Bolt,
	EACIT_MutagenPotion,
	EACIT_Alcohol,
	EACIT_Quest,
	EACIT_Dye,
	EACIT_Edibles, //modSpectre
	EACIT_MutagenFused, //modSpectre
	EACIT_MutagenTrans, //modSpectre
	EACIT_Other //modSpectre
}

struct SCookable
{
	var type : EAlchemyCookedItemType;
	var cnt : int;
};

function AlchemyCookedItemTypeStringToEnum(nam : string) : EAlchemyCookedItemType
{
	switch(nam)
	{
		case "potion" 			: return EACIT_Potion;
		case "petard"   		: return EACIT_Bomb;
		case "oil"    			: return EACIT_Oil;
		case "Substance" 		: return EACIT_Substance;
		case "bolt"				: return EACIT_Bolt;
		case "mutagen_potion" 	: return EACIT_MutagenPotion;
		case "alcohol"			: return EACIT_Alcohol;
		case "quest"			: return EACIT_Quest;
		case "dye"				: return EACIT_Dye;
		default	     			: return EACIT_Undefined;
	}
}

function AlchemyCookedItemTypeEnumToName( type : EAlchemyCookedItemType) : name
{
	switch (type)
	{
		case EACIT_Potion			: return 'potion';
		case EACIT_Bomb				: return 'petard';
		case EACIT_Oil				: return 'oil';
		case EACIT_Substance		: return 'Substance';
		case EACIT_Bolt				: return 'bolt';
		case EACIT_MutagenPotion 	: return 'mutagen_potion';
		case EACIT_Alcohol 			: return 'alcohol';
		case EACIT_Quest			: return 'quest';
		case EACIT_Dye				: return 'dye';
		default	     				: return '___'; 
	}
}

function AlchemyCookedItemTypeToLocKey( type : EAlchemyCookedItemType ) : string
{
	switch (type)
	{
		case EACIT_Potion			: return "panel_alchemy_tab_potions";
		case EACIT_Bomb				: return "panel_alchemy_tab_bombs";
		case EACIT_Oil				: return "panel_alchemy_tab_oils";
		case EACIT_Substance		: return "item_category_Substance";
		case EACIT_Bolt				: return "item_category_bolt";
		case EACIT_MutagenPotion 	: return "panel_inventory_filter_type_decoctions";
		case EACIT_Alcohol 			: return "panel_inventory_filter_type_alcohols";
		case EACIT_Quest 			: return "panel_button_worldmap_showquests";
		case EACIT_Dye				: return "item_category_dye";
		default	     				: return "";
	}
}

function AlchemyExceptionToString( result : EAlchemyExceptions ) : string
{
	//modSpectre: alchemy 5.01 variant, the 5.01 texts.
	if ( spectreAlchemy501() )
	{
		switch ( result )
		{
			case EAE_NoException:			return "panel_alchemy_exception_item_cooked";
			case EAE_CannotCookMore:		return "panel_alchemy_exception_already_cooked";
			case EAE_CookNotAllowed:		return "panel_alchemy_exception_cook_not_allowed";
		}
	}
	switch ( result )
	{
		//case EAE_NoException:			return "panel_alchemy_exception_item_cooked"; //modSpectre
		case EAE_MissingIngredient:		return "panel_alchemy_exception_missing_ingridient";
		case EAE_NotEnoughIngredients:	return "panel_alchemy_exception_missing_ingridients";
		case EAE_NoRecipe:				return "panel_alchemy_exception_no_recipie";
		case EAE_CannotCookMore:		return "spectre_item_limit";	//modSpectre
		case EAE_CookNotAllowed:		return "spectre_fire_no_src"; //modSpectre
		case EAE_Preparations:			return "spectre_preparation"; //modSpectre
		case EAE_InCombat:				return "panel_hud_message_actionnotallowed_combat";
		case EAE_Mounted:				return "menu_cannot_perform_action_now";
	}
	return "";
}

function IsAlchemyRecipe(recipeName : name) : bool
{
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var i : int;

	if(!IsNameValid(recipeName))
		return false;

	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('alchemy_recipes');
		
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		if ( dm.GetSubNodeByAttributeValueAsCName( main.subNodes[i], 'alchemy_recipes', 'name_name', recipeName ) && recipeName == recipeName )
		{
			return true;
		}
	}
	
	return false;
}
