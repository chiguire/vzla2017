package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(Math.round(480/2), Math.round(640/2), MenuState, 2, 60, 60, true, false));
	}
}
