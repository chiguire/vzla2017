package screen;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using com.roxstudio.i18n.I18n;

/**
 * ...
 * @author 
 */
class NewsScreen extends FlxSpriteGroup
{
	var title_bg : FlxSprite;
	var portrait : FlxSprite;
	var title_text : FlxText;
	
	public function new() 
	{
		super();
		I18n.init();
		
		title_bg = new FlxSprite(0, 0);
		title_bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 168), false);
		
		title_text  = new FlxText(60.5, 50, FlxG.width - 60, "ASDF GHJK".i18n());
		
		add(portrait);
		add(title_bg);
		add(title_text);
		
		scrollFactor.set();
	}	
}