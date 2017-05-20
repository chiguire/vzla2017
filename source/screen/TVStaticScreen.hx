package screen;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;

/**
 * ...
 * @author 
 */
class TVStaticScreen extends FlxSpriteGroup
{
	var tv_static : FlxSprite;
	var positions : Array<FlxPoint>;
	var current_index : Int;
	
	public function new(starting_active : Bool) 
	{
		super();
		tv_static = new FlxSprite(0, 0, AssetPaths.tvstatic__png);
		tv_static.scrollFactor.set();
		positions = [];
		
		var mid_width = tv_static.width / 2.0;
		var mid_height = tv_static.height / 2.0;
		for (i in 0...16)
		{
			positions.push(
				FlxPoint.get(
					-Math.random() * mid_width,
					-Math.random() * mid_height
				)
			);
		}
		current_index = 0;
		
		set_tvstatic_position();
		
		scrollFactor.set();
		setStaticActive(starting_active);
		add(tv_static);
	}
	
	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		current_index = (current_index + 1) % positions.length;
		set_tvstatic_position();
	}
	
	public function setStaticActive(value:Bool)
	{
		active = value;
		visible = value;
	}
	
	private function set_tvstatic_position()
	{
		var p = positions[current_index];
		tv_static.setPosition(p.x, p.y);
	}
}