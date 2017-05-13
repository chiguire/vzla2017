package play.eenum;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;

/**
 * @author 
 */
enum GameActionE 
{
	NONE;
	MOVE_CURSOR(direction:DirectionE);
	MOVE_CAMERA(direction:DirectionE);
	MOVE_CAMERA_TO_POSITION(position:FlxPoint, tweened:Bool);
	FOLLOW_CAMERA(?entity:FlxSprite);
	DELAY(time:Float);
	MOVE_CHARACTER(direction:DirectionE);
	DO_CHARACTER_ACTION(action_num:Int);
	//EXECUTE_TV_NEWS_SECTION(portrait:FlxSprite, name:String, 
	//QUIT;
	PAUSE;
	GO_TO_GAME_STATE(state:GameStateE);
	GO_TO_FLIXEL_STATE(state:Class<FlxState>);
}