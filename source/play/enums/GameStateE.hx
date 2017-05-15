package play.enums;
import flixel.FlxBasic;

/**
 * @author 
 */
enum GameStateE 
{
	PROTEST_IDLE;
	ARRIVE_MURCIELAGOS;
	CONTROL_AVATAR;//(character:FlxBasic, winning_condition:Void->Bool, losing_condition:Void->Bool, time_secs:Int);
	ANNOUNCE_NEWS;
}