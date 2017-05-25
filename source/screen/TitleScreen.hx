package screen;

import flixel.group.FlxSpriteGroup;

using com.roxstudio.i18n.I18n;

/**
 * ...
 * @author 
 */
class TitleScreen extends FlxSpriteGroup
{
	var bg : FlxSprite;
	var content_text : FlxText;
	
	public function new(vsble:Bool) 
	{
		super();
		I18n.init();
		
		bg = new FlxSprite(0, 0);
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 168), false);
		
		content_text  = new FlxText(60.5, 30, FlxG.width - 60, "RETURN TO GAME".i18n());
		
		add(bg);
		add(content_text);
		
		scrollFactor.set();
		this.visible = vsble;
	}
}