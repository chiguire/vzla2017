package play.enums;
import scenario.ScenarioCondition;
import flixel.FlxSprite;

/**
 */
enum GameStateE 
{
	CUTSCENE;
	CONTROL_AVATAR(character:FlxSprite, winning_condition:ScenarioCondition, losing_condition:ScenarioCondition);
}