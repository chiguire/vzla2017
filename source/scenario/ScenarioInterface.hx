package scenario;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import play.GameState;
import play.enums.GameStateE;
import play.enums.GameActionE;

/**
 * @author 
 */
interface ScenarioInterface 
{
	public function world_bounds() : FlxRect;
	public function camera_bounds() : FlxRect;
	public function starting_state() : GameState;
	public function starting_camera_position() : FlxPoint;
	public function timeline() : Iterator<GameActionE>;
}