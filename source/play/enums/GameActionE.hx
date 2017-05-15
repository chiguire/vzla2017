package play.enums;

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
	DELAY_AFTER_ACTION(time:Float,action:GameActionE);
	SEQUENCE(seq:Array<GameActionE>);
	SPAWN(seq:Array<GameActionE>);
	
	MOVE_CHARACTER_DIRECTION(direction:DirectionE);
	MOVE_CHARACTER_TO_POS(pos:FlxPoint);
	DO_CHARACTER_ACTION(action_num:Int);
	
	PAUSE;
	GO_TO_GAME_STATE(state:GameStateE);
	GO_TO_FLIXEL_STATE(state:Class<FlxState>);
}