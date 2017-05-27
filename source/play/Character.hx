package play;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxZSprite;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.math.FlxVelocity;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import play.enums.CharacterStateE;
import play.enums.CharacterTypeE;
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
	private static inline var TRAPPED        = "trapped";
	private static inline var PROTEST        = "protest";
	private static inline var PICKUP         = "pickup";
	
	public var char_type (default, null) : CharacterTypeE;
	public var protesting : Bool = false;
	
	public var state (default, set): CharacterStateE;
	
	public function new(?X:Float=0, ?Y:Float=0, char_type:CharacterTypeE, ?_color:FlxColor) 
	{
		super(X, Y, 3);
		
		this.char_type = char_type;
		
		var asset_path = switch (char_type)
		{
		case DIP: AssetPaths.prs__png;
		case PRS: AssetPaths.prs__png;
		case GNB: AssetPaths.gnb__png;
		};
		
		loadGraphic(asset_path, true, 35, 35);
		setFacingFlip(FlxObject.LEFT,  false, false);
		setFacingFlip(FlxObject.RIGHT, false,  false);
		setFacingFlip(FlxObject.UP,    false, false);
		setFacingFlip(FlxObject.DOWN,  false, false);
		
		switch (char_type)
		{
		case DIP:
			animation.add(IDLE_UPDOWN, [0], 30, true);
			animation.add(WALK_UPDOWN, [6, 7, 8, 9, 10], 30, true);
			animation.add(IDLE_LEFTRIGHT, [1], 30, true);
			animation.add(WALK_LEFT, [2, 3, 4, 5], 30, true, true);
			animation.add(WALK_RIGHT, [2, 3, 4, 5], 30, true);
			animation.add(TRAPPED, [3], 30, true);
			animation.add(PROTEST, [11, 12, 13, 14, 15, 14, 13, 12], 30, true);
			animation.add(PICKUP, [16, 16, 13, 12, 11], 30, true);
			mass = 100.0;
		case PRS:
			animation.add(IDLE_UPDOWN, [0], 30, true);
			animation.add(WALK_UPDOWN, [6, 7, 8, 9, 10], 30, true);
			animation.add(IDLE_LEFTRIGHT, [1], 30, true);
			animation.add(WALK_LEFT, [2, 3, 4, 5], 30, true, true);
			animation.add(WALK_RIGHT, [2, 3, 4, 5], 30, true);
			animation.add(TRAPPED, [3], 30, true);
			animation.add(PROTEST, [11, 12, 13, 14, 15, 14, 13, 12], 30, true);
			animation.add(PICKUP, [16, 16, 13, 12, 11], 30, true);
			mass = 100.0;
		case GNB:
			animation.add(IDLE_UPDOWN, [0], 30, true);
			animation.add(WALK_UPDOWN, [1,2,1,0,3,4,3,0], 30);
			animation.add(IDLE_LEFTRIGHT, [0], 30, true);
			animation.add(WALK_LEFT, [1,2,1,0,3,4,3,0], 30, true);
			animation.add(WALK_RIGHT, [1, 2, 1, 0, 3, 4, 3, 0], 30, true);
			mass = 300.0;
		}
		
		animation.play(IDLE_UPDOWN);
		
		color = _color != null? _color: FlxG.random.color();
		
		state = IDLE;
		bounds = new FlxRect(10, 33, 14, 4);
		drag.set(1, 1);
		offset.x = bounds.x;
		offset.y = bounds.y;
		width = bounds.width;
		height = bounds.height;
		flx_bounds = new FlxObject(bounds.x, bounds.y, bounds.width, bounds.height);
		flx_bounds.solid = false;
		protesting = false;
	}
	
	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		switch (state)
		{
		case IDLE:
			if (Type.enumEq(state, IDLE))
			{
				if (!protesting)
				{
					move_animations();
				}
			}
			
		case CHASING(sprite, speed):
			FlxVelocity.moveTowardsObject(this, sprite, speed);
			move_animations();
			if (FlxG.overlap(this, sprite))
			{
				this.set_state(DRAGGING(sprite));
				sprite.set_state(DRAGGED(this));
			}
			
		case DRAGGING(sprite):
			// check out of screen
			move_animations();
			if (y < 100)
			{
				this.set_state(OUT);
				sprite.set_state(OUT);
			}
		
		case DRAGGED(bySprite):
			// check out of screen
			setPosition(bySprite.x, bySprite.y + 5);
			
		case FLEEING:
			velocity.y = -120;
			move_animations();
			if (y < 100)
			{
				this.set_state(OUT);
			}
			
		case RESCUED:
			move_animations();
			
		case OUT:
			// noop
		}
	}
	
	public function protest()
	{
		animation.play(PROTEST, true, false, -1);
		flipX = FlxG.random.bool();
		protesting = true;
	}
	
	public function stop_protest()
	{
		protesting = false;
	}
	
	public function set_state(st:CharacterStateE)
	{
		var old_state = this.state;
		var new_state = st;
		
		switch (new_state)
		{
		case IDLE:
			velocity.set();
		case CHASING(sprite, speed):
			FlxVelocity.moveTowardsObject(this, sprite, speed);
		case DRAGGING(_):
			velocity.set(FlxG.random.sign() * 60, -60);
		case DRAGGED(bySprite):
			stop_protest();
			velocity.set();
			animation.play(TRAPPED, true);
			solid = false;
			
		case FLEEING:
			solid = true;
			
		case RESCUED:
			
		case OUT:
			solid = true;
			kill();
		}
		
		return this.state = st;
	}
	
	private function move_animations()
	{
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