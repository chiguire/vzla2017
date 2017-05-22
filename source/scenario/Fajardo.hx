package scenario;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxZSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVelocity;
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
	var borders : FlxSpriteGroup;
	
	var fg : FlxSpriteGroup;
	var entities : FlxSpriteGroup;
	
	var diputado: Character;
	var marcha : FlxTypedGroup<Character>;
	var guardia : FlxTypedGroup<Character>;
	var un_guardia : Character;
	var barrera1 : Barrera;
	var barrera2 : Barrera;
	var vehiculos : FlxTypedGroup<Barrera>;
	
	var goal : FlxZSprite;
	var lose : FlxZSprite;
	
	var flecha : FlxSprite;
	
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
		
		border_bottom = new FlxSprite(hw.x - 10, hw.height - 10);
		border_bottom.makeGraphic(Std.int(hw.width) + 20, 10, FlxColor.TRANSPARENT);
		border_bottom.immovable = true;
		
		border_left = new FlxSprite(hw.x, 0);
		border_left.makeGraphic(10, Std.int(hw.height), FlxColor.TRANSPARENT);
		border_left.immovable = true;
		
		border_right = new FlxSprite(hw.x + hw.width - 10, 0);
		border_right.makeGraphic(10, Std.int(hw.height), FlxColor.TRANSPARENT);
		border_right.immovable = true;
		
		borders = new FlxSpriteGroup();
		borders.add(border_top);
		borders.add(border_bottom);
		borders.add(border_left);
		borders.add(border_right);
		
		var marcha_centro = FlxPoint.get(hw.x + (hw.width / 2.0), world_bounds().height / 4.0);
		
		diputado = new Character(marcha_centro.x, marcha_centro.y, DIP, FlxColor.ORANGE);
		marcha = new FlxTypedGroup<Character>();
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
			marcha.add(new Character(x, y, PRS, color));
		}
		
		guardia = new FlxTypedGroup<Character>();
		for (i in 0...GUARDIA_SIZE)
		{
			guardia.add(new Character(
				hw.x + 30 + ((hw.width - 60) * i / GUARDIA_SIZE), 
				FlxG.height / 2 - 30, 
				GNB, 
				FlxColor.GREEN)
			);
		}
		barrera1 = new Barrera(hw.x + 30, 40);
		barrera2 = new Barrera(hw.x + 170, 40);
		vehiculos = new FlxTypedGroup<Barrera>();
		vehiculos.add(barrera1);
		vehiculos.add(barrera2);
		
		flecha = new FlxSprite(0, 0, AssetPaths.pointer_down__png);
		flecha.color = FlxColor.ORANGE;
		flecha.visible = false;
		
		//goal = new FlxZSprite(hw.x + 160, FlxG.height / 2 + 300, 35);
		//goal.makeGraphic(35, 35, FlxColor.RED);
		//goal.immovable = true;
		
		//lose= new FlxZSprite(hw.x + 200, FlxG.height / 2 + 300, 35);
		//lose.makeGraphic(35, 35, FlxColor.YELLOW);
		//lose.immovable = true;
		
		fg = new FlxSpriteGroup();
		entities = new FlxSpriteGroup();
		
		fg.add(borders);
		fg.add(entities);
		
		marcha.forEach(function(m) { entities.add(m); m.protest(); });
		entities.add(diputado);
		guardia.forEach(function(g) { entities.add(g); });
		entities.add(barrera1);
		entities.add(barrera2);
		//entities.add(goal);
		//entities.add(lose);
		
		add(bg);
		add(guaire);
		add(guaire2);
		add(hw);
		add(fg);
		add(flecha);
	}
	
	public function world_bounds() : FlxRect
	{
		return new FlxRect(0, 0, 1024, 1024);
	}
	
	public function camera_bounds() : FlxRect
	{
		return new FlxRect(100, 100, 1024 - 200, 1024 - 200);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (guaire.y >= 1024)
		{
			guaire.y -= 1024;
			guaire2.y -= 1024;
		}
		FlxG.collide(guardia, marcha);
		FlxG.collide(diputado, guardia, separate_if_dragging);
		FlxG.collide(guardia, borders);
		FlxG.collide(marcha, borders);
		FlxG.collide(diputado, borders);
		FlxG.collide(guardia, vehiculos);
		FlxG.collide(marcha, vehiculos);
		FlxG.collide(diputado, vehiculos);
		entities.sort(FlxZSprite.byZ, FlxSort.ASCENDING);
		
		if (flecha.visible)
		{
			flecha.x = main_character().x + main_character().width/2.0 - flecha.width/2.0;
			flecha.y = main_character().y - 60;
		}
		
		if (un_guardia != null && Type.enumEq(un_guardia.state, OUT))
		{
			un_guardia = null;
		}
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
			//camera_position: FlxPoint.get(hw.x + hw.width / 2.0 - FlxG.width / 2.0, worldBounds().height - FlxG.height),
			camera_position: FlxPoint.get(diputado.x - FlxG.width / 2.0, diputado.y - FlxG.height / 2.0),
		};
	}
	
	public function timeline() : Iterator<GameActionE>
	{
		return [
			CURTAIN_FADE_IN(0.5),
			DISPLAY_TVSTATIC(0.75),
			DELAY_SECONDS(1),
			//MOVE_CAMERA_TO_POSITION(FlxPoint.get(300, 300), true),
			MOVE_CAMERA_TO_SPRITE_TWEENED(diputado, CENTER, 1.0),
			GO_TO_GAME_STATE(CONTROL_AVATAR(diputado, null, null)),
			START_UPDATE_FUNCTION(move_guardia),
			DELAY_SECONDS(8),
			STOP_UPDATE_FUNCTION(move_guardia),
			GO_TO_GAME_STATE(CUTSCENE),
			ANNOUNCE_NEWS(PortraitE.PORTRAIT_NR, "Nestor Reverol", "Aqui hay juerza"),
			DELAY_SECONDS(NewsScreen.total_news_time()),
			GO_TO_GAME_STATE(CONTROL_AVATAR(diputado, null, null)),
			START_UPDATE_FUNCTION(move_guardia),
			DELAY_SECONDS(8),
			STOP_UPDATE_FUNCTION(move_guardia),
			ANNOUNCE_NEWS(PortraitE.PORTRAIT_MP, "Nestor Reverol", "Los muros van a caer"),
		].iterator();
	}
	
	private function move_guardia(elapsed:Float)
	{
		if (un_guardia == null)
		{
			un_guardia = guardia.getRandom();
		}
		
		if (Type.enumEq(un_guardia.state, IDLE))
		{
			var distancias = [];
			for (m in marcha.iterator())
			{
				distancias.push({ dist:FlxMath.distanceBetween(m, un_guardia), spr: m});
			}
			var min_distancia = distancias[0];
			for (dst in distancias)
			{
				if (dst.dist < min_distancia.dist)
				{
					min_distancia = dst;
				}
			}
			un_guardia.state = CHASING(min_distancia.spr, 100);
		}
	}
	
	private function separate_if_dragging(a:Dynamic, b:Dynamic) : Void
	{
		var a_c = cast(a, Character);
		var b_c = cast(b, Character);
		
		var dip = if (Type.enumEq(a_c.char_type, DIP)) a_c else b_c;
		var gnb = if (Type.enumEq(a_c.char_type, GNB)) a_c else b_c;
		
		switch (gnb.state)
		{
		case DRAGGING(sprite):
			var old_gnb_velocity = FlxPoint.get(gnb.velocity.x, gnb.velocity.y);
			gnb.state = FLEEING;
			gnb.velocity.x = old_gnb_velocity.x*3;
			gnb.velocity.y = old_gnb_velocity.y*3;
			
			dip.velocity.x = -old_gnb_velocity.x*3;
			dip.velocity.y = -old_gnb_velocity.y*3;
			
			var prs = sprite;
			prs.state = RESCUED;
			prs.velocity.x = 0;
			prs.velocity.y = 150;
		default:
		}
		
	}
	
	public function point_to_character(spr:FlxSprite)
	{
		flecha.visible = true;
		FlxFlicker.flicker(flecha, 2, 0.04, false);
	}
}