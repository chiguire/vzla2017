package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;

using com.roxstudio.i18n.I18n;

/**
 * ...
 * @author 
 */
class CreditsState extends FlxState
{

	public override function create() 
	{
		super.create();
		
		var programacion_txt = new FlxText(10, 100, FlxG.width - 20, "PROGRAMMING: Ciro Durán".i18n());
		programacion_txt.wordWrap = true;
		programacion_txt.alignment = FlxTextAlign.CENTER;
		var graficos_txt = new FlxText(10, 120, FlxG.width - 20, "GRAPHICS: Ciro Durán".i18n());
		graficos_txt.wordWrap = true;
		graficos_txt.alignment = FlxTextAlign.CENTER;
		var writing_txt = new FlxText(10, 140, FlxG.width - 20, "WRITING: César Sánchez".i18n());
		writing_txt.wordWrap = true;
		writing_txt.alignment = FlxTextAlign.CENTER;
		var press_txt = new FlxText(10, FlxG.height - 20, FlxG.width - 20, "Press any key to return to menu".i18n());
		press_txt.wordWrap = true;
		press_txt.alignment = FlxTextAlign.CENTER;
		
		add(programacion_txt);
		add(graficos_txt);
		add(writing_txt);
		add(press_txt);
	}
	
	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([FlxKey.SPACE]))
		{
			FlxG.switchState(new MenuState());
		}
	}
	
	
}