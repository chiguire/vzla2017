package play.enums;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import play.Character;

/**
 * @author 
 */
enum GameActionE 
{
	NONE;
	MOVE_CURSOR(direction:DirectionE);
	
	MOVE_CAMERA(direction:DirectionE);
	MOVE_CAMERA_TO_POSITION_DIRECT(position:FlxPoint, anchor:AnchorE);
	MOVE_CAMERA_TO_POSITION_TWEENED(position:FlxPoint, anchor:AnchorE, time:Float);
	MOVE_CAMERA_TO_SPRITE_DIRECT(sprite:FlxObject, anchor:AnchorE);
	MOVE_CAMERA_TO_SPRITE_TWEENED(sprite:FlxObject, anchor:AnchorE, time:Float);
	
	FOLLOW_CAMERA(?entity:FlxSprite);
	DELAY_SECONDS(time:Float);
	SEQUENCE(seq:Array<GameActionE>);
	SPAWN(seq:Array<GameActionE>);

	CURTAIN_FADE_IN(time:Float);
	CURTAIN_FADE_OUT(time:Float);
	
	DISPLAY_TVSTATIC(time:Float);
	ANNOUNCE_NEWS(portrait:PortraitE, name:String, dialogue:String);
	
	MOVE_SPRITE_DIRECTION(sprite:FlxSprite, direction:DirectionE);
	MOVE_SPRITE_TO_POS(sprite:FlxSprite, pos:FlxPoint);
	DO_CHARACTER_ACTION(action_num:Int);
	
	PAUSE;
	GO_TO_GAME_STATE(state:GameStateE);
	GO_TO_FLIXEL_STATE(state:Class<FlxState>);
}