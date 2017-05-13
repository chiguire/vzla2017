package play;

import flixel.FlxObject;
import flixel.FlxZSprite;
import flixel.math.FlxRect;

/**
 * ...
 * @author 
 */
class Barrera extends FlxZSprite
{
	public var bounds : FlxRect;
	public var flx_bounds : FlxObject;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y, 30, AssetPaths.barrera_antimotin__png);
		
		bounds = new FlxRect(0, 38, 131, 80);
		offset.x = bounds.x;
		offset.y = bounds.y;
		width = bounds.width;
		height = bounds.height;
		flx_bounds = new FlxObject(bounds.x, bounds.y, bounds.width, bounds.height);
		flx_bounds.solid = false;
		
		immovable = false;
	}	
}