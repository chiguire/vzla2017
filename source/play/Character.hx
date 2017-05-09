package play;

import flixel.FlxObject;
import flixel.FlxZSprite;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author 
 */
class Character extends FlxZSprite
{
	public var bounds : FlxRect;
	public var flx_bounds : FlxObject;
	
	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, 3, SimpleGraphic);
		
		bounds = new FlxRect(0, 34, 14, 3);
		offset.x = bounds.x;
		offset.y = bounds.y;
		width = bounds.width;
		height = bounds.height;
		flx_bounds = new FlxObject(bounds.x, bounds.y, bounds.width, bounds.height);
		flx_bounds.solid = false;
	}
	
}