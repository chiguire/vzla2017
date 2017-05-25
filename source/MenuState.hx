package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using com.roxstudio.i18n.I18n;

/**
 * ...
 * @author 
 */
class MenuState extends FlxState
{

	var pause_bg : FlxSprite;
	var return_text : FlxText;
	var language_text : FlxText;
	var sound_text : FlxText;
	//var control_text : FlxText;
	var credits_text : FlxText;
	
	var selected_cursor : FlxSprite;
	var selected_item : Int;
	
	private static inline var num_items : Int = 4;
	private static inline var starting_y : Int = 50;
	private static inline var spacing_y : Int = 20;
	private static function order_item_y(ix:Int) { return starting_y + ix * spacing_y; }
	
	override public function create():Void
	{
		super.create();
		
		I18n.init();
		//FlxG.debugger.visible = true;
		//FlxG.mouse.visible = false;
		FlxG.autoPause = false;
		
		pause_bg = new FlxSprite(0, 0);
		//pause_bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 168), false);
		
		return_text  = new FlxText(60.5, order_item_y(0), FlxG.width - 60, "START".i18n());
		language_text = new FlxText(60.5, order_item_y(1), FlxG.width - 60, language_txt());
		sound_text   = new FlxText(60.5, order_item_y(2), FlxG.width - 60, sound_txt());
		//control_text = new FlxText(60.5, order_item_y(3), FlxG.width - 60, control_txt());
		credits_text    = new FlxText(60.5, order_item_y(3), FlxG.width - 60, "CREDITS".i18n());
		
		selected_cursor = new FlxSprite(30, 30);
		selected_cursor.makeGraphic(12, 12, FlxColor.RED);
		
		add(pause_bg);
		add(return_text);
		add(language_text);
		add(sound_text);
		//add(control_text);
		add(credits_text);
		add(selected_cursor);
		
		selected_item = 0;
	}
	
	public override function update(elapsed:Float) : Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.anyJustPressed(Reg.GAME_KEYBOARD_INPUTS.up))
		{
			go_up();
		}
		else if (FlxG.keys.anyJustPressed(Reg.GAME_KEYBOARD_INPUTS.down))
		{
			go_down();
		}
		else if (FlxG.keys.anyJustPressed(Reg.GAME_KEYBOARD_INPUTS.a) ||
			FlxG.keys.anyJustPressed(Reg.GAME_KEYBOARD_INPUTS.b))
		{
			execute_action();
		}
		
		selected_cursor.setPosition(30, order_item_y(selected_item));
		
	}
	
	public function go_down() : Void
	{
		selected_item = (selected_item + 1) % num_items;
	}
	
	public function go_up() : Void
	{
		selected_item = (num_items + selected_item - 1) % num_items;
	}
	
	public function execute_action() : Void
	{
		switch (selected_item)
		{
			case 0:
				FlxG.switchState(new PlayState());
			case 1:
				//I18n.locale = 
				language_text.text = language_txt();
				
			case 2:
				Reg.sound_on = !Reg.sound_on;
				sound_text.text = sound_txt();
				
			//case 3:
			//	Reg.virtualpad_visible = !Reg.virtualpad_visible;
			//	control_text.text = control_txt();
			//	return NONE;
			case 3:
				FlxG.switchState(new CreditsState());
			default:
				throw "Invalid index selected";
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
	
	public static function language_txt()
	{
		return "CAMBIAR A ESPAÑOL".i18n();
	}
	
	override public function onFocus():Void 
	{
		super.onFocus();
	}
	
	override public function onFocusLost() : Void
	{
		super.onFocusLost();
	}
}