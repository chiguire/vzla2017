package play;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using com.roxstudio.i18n.I18n;

/**
 * ...
 * @author 
 */
class PauseScreen extends FlxSpriteGroup
{
	var pause_bg : FlxSprite;
	var return_text : FlxText;
	var restart_text : FlxText;
	var sound_text : FlxText;
	var control_text : FlxText;
	var quit_text : FlxText;
	
	public function new() 
	{
		super();
		I18n.init();
		//I18n.locale(Reg.locale);
		
		pause_bg = new FlxSprite(0, 0);
		pause_bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 168), false);
		pause_bg.scrollFactor.set();
		
		return_text = new FlxText(60, 30, FlxG.width - 60, "RETURN TO GAME".i18n());
		add(return_text);
		
		restart_text = new FlxText(60, 50, FlxG.width - 60, "RESTART GAME".i18n());
		add(restart_text);
		
		sound_text = new FlxText(60, 50, FlxG.width - 60, sound_txt());
		add(sound_text);
		
		control_text = new FlxText(60, 50, FlxG.width - 60, control_txt());
		add(control_text);
		
		quit_text = new FlxText(60, 70, FlxG.width - 60, "RETURN TO MENU".i18n());
		add(quit_text);
	}
	
	public static function sound_txt()
	{
		if (Reg.sound_on)
		{
			return "SOUND: ON".i18n();
		}
		else
		{
			return "SOUND: OFF".i18n();
		}
	}
	
	public static function control_txt()
	{
		if (Reg.virtualpad_visible)
		{
			return "CONTROL: SHOWN".i18n();
		}
		else
		{
			return "CONTROL: HIDDEN".i18n();
		}
	}
}