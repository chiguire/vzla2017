package play.enums;
import scenario.ScenarioCondition;
import flixel.FlxSprite;

/**
 */
enum GameStateE 
{
	PROTEST_IDLE;
	ARRIVE_MURCIELAGOS;
	CONTROL_AVATAR(character:FlxSprite, winning_condition:ScenarioCondition, losing_condition:ScenarioCondition);
	ANNOUNCE_NEWS(portrait:PortraitE, name:String, dialogue:String);
}