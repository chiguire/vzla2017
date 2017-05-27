package;
import play.GameKeyboardInputs;
import flixel.input.keyboard.FlxKey;

/**
 * ...
 * @author 
 */
class Reg
{
	public static function changeLocale() {
		return Reg.locale = (Reg.locale == "en" || Reg.locale == "default"? "es": "en");
	}
	
	public static var locale (default, null) : String = "en";
	
	public static var sound_on : Bool = true;
	
	public static var virtualpad_visible : Bool = true;
	
	public static var GAME_KEYBOARD_INPUTS : GameKeyboardInputs = {
		pause: [FlxKey.P, FlxKey.ESCAPE],
		up:    [FlxKey.UP, FlxKey.W],
		down:  [FlxKey.DOWN, FlxKey.S],
		left:  [FlxKey.LEFT, FlxKey.A],
		right: [FlxKey.RIGHT, FlxKey.D],
		a:     [FlxKey.ONE, FlxKey.ENTER],
		b:     [FlxKey.TWO, FlxKey.SHIFT],
	};
}