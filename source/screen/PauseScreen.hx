package screen;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import play.enums.GameActionE;

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
	
	var selected_cursor : FlxSprite;
	var selected_item : Int;
	
	private static inline var num_items : Int = 5;
	private static inline var starting_y : Int = 50;
	private static inline var spacing_y : Int = 20;
	private static function order_item_y(ix:Int) { return starting_y + ix * spacing_y; }
	
	public function new(paused:Bool) 
	{
		super();
		I18n.init();
		
		pause_bg = new FlxSprite(0, 0);
		pause_bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 168), false);
		
		return_text  = new FlxText(60.5, order_item_y(0), FlxG.width - 60, "RETURN TO GAME".i18n());
		restart_text = new FlxText(60.5, order_item_y(1), FlxG.width - 60, "RESTART GAME".i18n());
		sound_text   = new FlxText(60.5, order_item_y(2), FlxG.width - 60, sound_txt());
		control_text = new FlxText(60.5, order_item_y(3), FlxG.width - 60, control_txt());
		quit_text    = new FlxText(60.5, order_item_y(4), FlxG.width - 60, "RETURN TO MENU".i18n());
		
		selected_cursor = new FlxSprite(30, 30);
		selected_cursor.makeGraphic(12, 12, FlxColor.RED);
		
		add(pause_bg);
		add(return_text);
		add(restart_text);
		add(sound_text);
		add(control_text);
		add(quit_text);
		add(selected_cursor);
		
		selected_item = 0;
		
		scrollFactor.set();
		this.visible = paused;
	}
	
	public function toggle() : Void
	{
		this.visible = !this.visible;
		
		if (this.visible)
		{
			selected_item = 0;
		}
	}
	
	public function go_down() : Void
	{
		selected_item = (selected_item + 1) % num_items;
	}
	
	public function go_up() : Void
	{
		selected_item = (num_items + selected_item - 1) % num_items;
	}
	
	public function get_action() : GameActionE
	{
		switch (selected_item)
		{
			case 0:
				return PAUSE;
			case 1:
				return GO_TO_FLIXEL_STATE(PlayState);
			case 2:
				Reg.sound_on = !Reg.sound_on;
				sound_text.text = sound_txt();
				return NONE;
			case 3:
				Reg.virtualpad_visible = !Reg.virtualpad_visible;
				control_text.text = control_txt();
				return NONE;
			case 4:
				return GO_TO_FLIXEL_STATE(MenuState); // MenuState when done
			default:
				throw "Invalid index selected";
		}
	}
	
	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (this.visible)
		{
			selected_cursor.setPosition(30, order_item_y(selected_item));
		}
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