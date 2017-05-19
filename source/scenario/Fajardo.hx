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
	
	var goal : FlxZSprite;
	var lose : FlxZSprite;
	
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
		
		goal = new FlxZSprite(hw.x + 160, FlxG.height / 2 + 300, 35);
		goal.makeGraphic(35, 35, FlxColor.RED);
		goal.immovable = true;
		
		lose= new FlxZSprite(hw.x + 200, FlxG.height / 2 + 300, 35);
		lose.makeGraphic(35, 35, FlxColor.YELLOW);
		lose.immovable = true;
		
		
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
		entities.add(goal);
		entities.add(lose);
		
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
	
	public function main_character() : FlxSprite
	{
		return char1;
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
			camera_position: FlxPoint.get(100, 100),
		};
	}
	
	public function timeline() : Iterator<GameActionE>
	{
		return [
			CURTAIN_FADE_IN(1),
			DELAY_SECONDS(3),
			DISPLAY_TVSTATIC(0.25),
			//MOVE_CAMERA_TO_POSITION(FlxPoint.get(300, 300), true),
			MOVE_CAMERA_TO_SPRITE_TWEENED(char1, CENTER, 1.0),
			GO_TO_GAME_STATE(CONTROL_AVATAR(char1, null, null)),
			DELAY_SECONDS(10),
			GO_TO_GAME_STATE(CUTSCENE),
			ANNOUNCE_NEWS(PortraitE.PORTRAIT_NR, "Nestor Reverol", "Aqui hay juerza"),
			DELAY_SECONDS(NewsScreen.total_news_time()),
			GO_TO_GAME_STATE(CONTROL_AVATAR(char1, null, null)),
		].iterator();
	}
}