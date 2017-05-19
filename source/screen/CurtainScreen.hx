package screen;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

/**
 * Simple black rectangle sprite for fade in/out
 */
class CurtainScreen extends FlxSprite
{
	public function new(starting_alpha : Float) 
	{
		super();
		makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		alpha = starting_alpha;
		scrollFactor.set();
	}
}