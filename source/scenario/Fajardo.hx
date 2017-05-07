package scenario;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

/**
 * ...
 * @author 
 */
class Fajardo extends FlxSpriteGroup
{

	var bg : FlxSprite;
	var hw : FlxSprite;
	
	public function new() 
	{
		super();
		
		bg = new FlxSprite(0, 0, AssetPaths.bottom_hw__png);
		bg.scrollFactor.set(0.8, 0.8);
		add(bg);
		
		hw = new FlxSprite(0, 0, AssetPaths.top_hw__png);
		add(hw);
		
	}
	
}