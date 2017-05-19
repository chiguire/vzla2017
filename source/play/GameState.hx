package play;

import flixel.math.FlxPoint;
import play.enums.GameStateE;

/**
 * @author 
 */
typedef GameState =
{
	paused : Bool,
	state : GameStateE,
	curtain_alpha : Float,
	tv_static_active : Bool,
	camera_position: FlxPoint,
}