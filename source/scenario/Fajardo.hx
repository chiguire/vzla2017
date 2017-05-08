package scenario;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import play.eenum.DirectionE;

/**
 * ...
 * @author 
 */
class Fajardo extends FlxSpriteGroup
{

	var bg : FlxSprite;
	var hw : FlxSprite;
	
	var border_top : FlxSprite;
	var border_bottom : FlxSprite;
	var border_right : FlxSprite;
	var border_left : FlxSprite;
	
	var fg : FlxSpriteGroup;
	
	var char1 : FlxSprite;
	var char2 : FlxSprite;
	
	public function new() 
	{
		super();
		
		bg = new FlxSprite(0, 0, AssetPaths.bottom_hw__png);
		bg.scrollFactor.set(0.8, 0.8);
		
		hw = new FlxSprite(248, 0, AssetPaths.top_hw__png);
		
		border_top = new FlxSprite(238, -10);
		border_top.makeGraphic(360, 10, FlxColor.TRANSPARENT);
		border_top.immovable = true;
		
		border_bottom = new FlxSprite(238, FlxG.height);
		border_bottom.makeGraphic(360, 10, FlxColor.TRANSPARENT);
		border_bottom.immovable = true;
		
		border_left = new FlxSprite(238, 0);
		border_left.makeGraphic(10, FlxG.height, FlxColor.TRANSPARENT);
		border_left.immovable = true;
		
		border_right = new FlxSprite(248 + 340, 0);
		border_right.makeGraphic(10, FlxG.height, FlxColor.TRANSPARENT);
		border_right.immovable = true;
		
		char1 = new FlxSprite(238 + 160, FlxG.height / 2, AssetPaths.prs__png);
		char2 = new FlxSprite(238 + 160, FlxG.height / 2 - 50, AssetPaths.gnb__png);
		
		
		fg = new FlxSpriteGroup();
		
		fg.add(border_top);
		fg.add(border_bottom);
		fg.add(border_left);
		fg.add(border_right);
		fg.add(char1);
		fg.add(char2);
		
		add(bg);
		add(hw);
		add(fg);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		FlxG.collide(fg);
	}
	
	public function move_char(direction:DirectionE)
	{
		var magnitude : Int = 100;
		switch (direction)
		{
			case UPLEFT:
				char1.velocity.set( -magnitude, -magnitude);
			case UPRIGHT:
				char1.velocity.set( magnitude, -magnitude);
			case UP:
				char1.velocity.set( 0, -magnitude);
			case LEFT:
				char1.velocity.set( -magnitude, 0);
			case RIGHT:
				char1.velocity.set( magnitude, 0);
			case DOWNLEFT:
				char1.velocity.set( -magnitude, magnitude);
			case DOWNRIGHT:
				char1.velocity.set( magnitude, magnitude);
			case DOWN:
				char1.velocity.set( 0, magnitude);
			case NONE:
				char1.velocity.set( 0, 0);
		}
	}
	
	public function main_char() : FlxSprite
	{
		return char1;
	}
}
