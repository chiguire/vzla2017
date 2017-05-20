package scenario;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxZSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import play.Barrera;
import play.Character;
import play.GameState;
import play.Tanqueta;
import play.enums.DirectionE;
import play.enums.GameStateE;
import play.enums.GameActionE;
import play.enums.PortraitE;
import screen.NewsScreen;

/**
 * ...
 * @author 
 */
class Fajardo extends FlxSpriteGroup implements ScenarioInterface
{
	public static inline var MARCHA_SIZE : Int = 30;
	public static inline var GUARDIA_SIZE :Int = 8;

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
	
	var diputado: Character;
	var marcha : Array<Character>;
	var guardia : Array<Character>;
	var barrera1 : Barrera;
	var barrera2 : Barrera;
	
	var goal : FlxZSprite;
	var lose : FlxZSprite;
	
	public function new() 
	{
		super();
		
		bg = new FlxSprite(0, 0, AssetPaths.bottom_hw__png);
		bg.scrollFactor.set(0.8, 0.8);
		
		guaire = new FlxSprite(59, 0, AssetPaths.river__png);
		guaire2 = new FlxSprite(59, -guaire.height-0.5, AssetPaths.river__png);
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
		
		var marcha_centro = FlxPoint.get(hw.x + (hw.width / 2.0), worldBounds().height / 4.0);
		
		diputado = new Character(marcha_centro.x, marcha_centro.y, PRS, FlxColor.ORANGE);
		marcha = [];
		for (i in 0...MARCHA_SIZE)
		{
			var min_x = (marcha_centro.x - (0.8 * hw.width / 2.0));
			var max_x = (marcha_centro.x + (0.8 * hw.width / 2.0));
			var min_y = (marcha_centro.y - 50);
			var max_y = (marcha_centro.y + 50);
			
			var x = FlxG.random.float(min_x, max_x);
			var y = FlxG.random.float(min_y, max_y);
			
			var which = FlxG.random.int(0, 2);
			var hue = switch (which)
				{
					case 0: FlxG.random.float(   0 - 10,   0 + 10); // red
					case 1: FlxG.random.float(  40 - 10,  40 + 10); // yellow
					case 2: FlxG.random.float( 240 - 10, 240 + 10); // blue
					default: throw "WAT?";
				};
			var saturation = switch (which)
				{
					case 0: FlxG.random.float(0.6, 0.8); // red
					case 1: FlxG.random.float(0.6, 1.8); // yellow
					case 2: FlxG.random.float(0.6, 0.8); // blue
					default: throw "WAT?";
				};
			var brightness = switch (which)
				{
					case 0: FlxG.random.float(0.6, 0.8); // red
					case 1: FlxG.random.float(0.8, 1.0); // yellow
					case 2: FlxG.random.float(0.6, 0.8); // blue
					default: throw "WAT?";
				};
				
			var color = FlxColor.fromHSB(hue, saturation, brightness, 1);
			marcha.push(new Character(x, y, PRS, color));
		}
		
		guardia = [];
		for (i in 0...GUARDIA_SIZE)
		{
			guardia.push(new Character(
				hw.x + 10 + ((hw.width - 20) * i / GUARDIA_SIZE), 
				FlxG.height / 2 - 30, 
				GNB, 
				FlxColor.GREEN)
			);
		}
		barrera1 = new Barrera(hw.x + 30, 40);
		barrera2 = new Barrera(hw.x + 170, 40);
		
		//goal = new FlxZSprite(hw.x + 160, FlxG.height / 2 + 300, 35);
		//goal.makeGraphic(35, 35, FlxColor.RED);
		//goal.immovable = true;
		
		//lose= new FlxZSprite(hw.x + 200, FlxG.height / 2 + 300, 35);
		//lose.makeGraphic(35, 35, FlxColor.YELLOW);
		//lose.immovable = true;
		
		fg = new FlxSpriteGroup();
		entities = new FlxSpriteGroup();
		
		fg.add(border_top);
		fg.add(border_bottom);
		fg.add(border_left);
		fg.add(border_right);
		fg.add(entities);
		
		for (m in marcha) { entities.add(m); m.protest(); }
		entities.add(diputado);
		for (g in guardia) { entities.add(g); }
		entities.add(barrera1);
		entities.add(barrera2);
		//entities.add(goal);
		//entities.add(lose);
		
		add(bg);
		add(guaire);
		add(guaire2);
		add(hw);
		add(fg);
	}
	
	public inline function worldBounds() : FlxRect
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
	
	public function main_character() : FlxSprite
	{
		return diputado;
	}
	
	public function do_char_action(action:Int)
	{
		FlxG.log.notice("Action!: " + action);
	}
	
	public function starting_camera_position() : FlxPoint
	{
		return FlxPoint.get(100, 100);
	}
	
	public function starting_state() : GameState
	{
		return {
			paused : false,
			state : CUTSCENE,
			curtain_alpha : 1.0,
			tv_static_active : false,
			camera_position: FlxPoint.get(hw.x + hw.width / 2.0 - FlxG.width / 2.0, worldBounds().height - FlxG.height),
			//camera_position: FlxPoint.get(diputado.x - FlxG.width / 2.0, diputado.y - FlxG.height / 2.0),
		};
	}
	
	public function timeline() : Iterator<GameActionE>
	{
		return [
			CURTAIN_FADE_IN(0.5),
			DISPLAY_TVSTATIC(0.75),
			DELAY_SECONDS(2),
			//MOVE_CAMERA_TO_POSITION(FlxPoint.get(300, 300), true),
			MOVE_CAMERA_TO_SPRITE_TWEENED(diputado, CENTER, 1.0),
			GO_TO_GAME_STATE(CONTROL_AVATAR(diputado, null, null)),
			DELAY_SECONDS(10),
			GO_TO_GAME_STATE(CUTSCENE),
			ANNOUNCE_NEWS(PortraitE.PORTRAIT_NR, "Nestor Reverol", "Aqui hay juerza"),
			DELAY_SECONDS(NewsScreen.total_news_time()),
			GO_TO_GAME_STATE(CONTROL_AVATAR(diputado, null, null)),
		].iterator();
	}
}