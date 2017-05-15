package scenario;

import flixel.math.FlxPoint;
import play.enums.GameStateE;
import play.enums.GameActionE;

/**
 * @author 
 */
interface ScenarioInterface 
{
	public function starting_state() : GameStateE;
	public function starting_camera_position() : FlxPoint;
	public function timeline() : Iterator<GameActionE>;
}