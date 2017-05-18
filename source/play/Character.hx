package play;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxZSprite;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import play.enums.DirectionE;

/**
 * ...
 * @author 
 */
class Character extends FlxZSprite
{
	public var bounds : FlxRect;
	public var flx_bounds : FlxObject;
	
	private static inline var IDLE_UPDOWN    = "idle_updown";
	private static inline var IDLE_LEFTRIGHT = "idle_leftright";
	private static inline var WALK_UPDOWN    = "walk_updown";
	private static inline var WALK_LEFT      = "walk_left";
	private static inline var WALK_RIGHT     = "walk_right";
	
	public function new(?X:Float=0, ?Y:Float=0, ?_color:FlxColor) 
	{
		super(X, Y, 3);
		
		loadGraphic(AssetPaths.prs__png, true, 35, 35);
		setFacingFlip(FlxObject.LEFT,  false, false);
		setFacingFlip(FlxObject.RIGHT, false,  false);
		setFacingFlip(FlxObject.UP,    false, false);
		setFacingFlip(FlxObject.DOWN,  false, false);
		
		animation.add(IDLE_UPDOWN, [0], 30, true);
		animation.add(WALK_UPDOWN, [6, 7, 8, 9, 10], 30, true);
		animation.add(IDLE_LEFTRIGHT, [1], 30, true);
		animation.add(WALK_LEFT, [2, 3, 4, 5], 30, true, true);
		animation.add(WALK_RIGHT, [2, 3, 4, 5], 30, true);
		
		animation.play(IDLE_UPDOWN);
		
		color = _color != null? _color: FlxG.random.color();
		
		bounds = new FlxRect(10, 34, 14, 3);
		offset.x = bounds.x;
		offset.y = bounds.y;
		width = bounds.width;
		height = bounds.height;
		flx_bounds = new FlxObject(bounds.x, bounds.y, bounds.width, bounds.height);
		flx_bounds.solid = false;
	}
	
	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var x_quiet = velocity.x == 0;
		var x_right = velocity.x > 0;
		var y_quiet = velocity.y == 0;
		var y_down  = velocity.y > 0;
		
		animation.play(
			if (x_quiet)
			{
				if (y_quiet)
				{
					if (facing & FlxObject.UP != 0 || facing & FlxObject.DOWN != 0)
					{
						IDLE_UPDOWN;
					}
					else
					{
						IDLE_LEFTRIGHT;
					}
				}
				else
				{
					WALK_UPDOWN;
				}
			}
			else
			{
				if (x_right)
				{
					WALK_RIGHT;
				}
				else
				{
					WALK_LEFT;
				}
			}
		);
	}
}