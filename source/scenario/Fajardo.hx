package scenario;
import flixel.FlxG;
import flixel.FlxZSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import play.Barrera;
import play.Character;
import play.Tanqueta;
import play.enums.DirectionE;

/**
 * ...
 * @author 
 */
class Fajardo extends FlxSpriteGroup
{

	var bg : FlxSprite;
	var guaire : FlxSprite;
	var guaire2 : FlxSprite;
	var hw : FlxSprite;
	
	var border_top : FlxSprite;
	var border_bottom : FlxSprite;
	var border_right : FlxSprite;
	var border_left : FlxSprite;
	
	var fg : FlxSpriteGroup;
	var entities : FlxSpriteGroup;
	
	var char1 : Character;
	var char2 : Character;
	var tanqueta : Tanqueta;
	var vehiculo2 : FlxZSprite;
	
	public function new() 
	{
		super();
		
		bg = new FlxSprite(0, 0, AssetPaths.bottom_hw__png);
		bg.scrollFactor.set(0.8, 0.8);
		
		guaire = new FlxSprite(59, 0, AssetPaths.river__png);
		guaire2 = new FlxSprite(59, -guaire.height, AssetPaths.river__png);
		guaire.velocity.y = 100;
		guaire2.velocity.y = 100;
		
		hw = new FlxSprite(248, 0, AssetPaths.top_hw__png);
		
		border_top = new FlxSprite(hw.x - 10, -10);
		border_top.makeGraphic(Std.int(hw.width) + 20, 10, FlxColor.TRANSPARENT);
		border_top.immovable = true;
		
		border_bottom = new FlxSprite(hw.x - 10, hw.height - 40);
		border_bottom.makeGraphic(Std.int(hw.width) + 20, 10, FlxColor.TRANSPARENT);
		border_bottom.immovable = true;
		
		border_left = new FlxSprite(hw.x, 0);
		border_left.makeGraphic(10, Std.int(hw.height), FlxColor.TRANSPARENT);
		border_left.immovable = true;
		
		border_right = new FlxSprite(hw.x + hw.width - 10, 0);
		border_right.makeGraphic(10, Std.int(hw.height), FlxColor.TRANSPARENT);
		border_right.immovable = true;
		
		char1 = new Character(hw.x + 160, FlxG.height / 2);
		char2 = new Character(hw.x + 140, FlxG.height / 2 - 30, FlxColor.GREEN);
		tanqueta = new Tanqueta(hw.x + 120, 40);
		vehiculo2 = new Barrera(hw.x + 170, 60);
		
		fg = new FlxSpriteGroup();
		entities = new FlxSpriteGroup();
		
		fg.add(border_top);
		fg.add(border_bottom);
		fg.add(border_left);
		fg.add(border_right);
		fg.add(entities);
		
		entities.add(char1);
		entities.add(char2);
		entities.add(tanqueta);
		entities.add(vehiculo2);
		
		add(bg);
		add(guaire);
		add(guaire2);
		add(hw);
		add(fg);
	}
	
	public function worldBounds() : FlxRect
	{
		return new FlxRect(0, 0, 1024, 1024);
	}
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (guaire.y >= 1024)
		{
			guaire.y -= 1024;
			guaire2.y -= 1024;
		}
		
		FlxG.collide(fg);
		entities.sort(FlxZSprite.byZ, FlxSort.ASCENDING);
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
	
	public function do_char_action(action:Int)
	{
		FlxG.log.notice("Action!: " + action);
	}
	
	public function main_char() : FlxSprite
	{
		return char1;
	}
}
