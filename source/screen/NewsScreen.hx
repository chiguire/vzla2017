package screen;

import flash.errors.Error;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.util.FlxFSM.StatePool;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.ds.EnumValueMap;
import play.enums.PortraitE;

using com.roxstudio.i18n.I18n;

/**
 * ...
 * @author 
 */
class NewsScreen extends FlxSpriteGroup
{
	
	private var portraits : EnumValueMap<PortraitE, FlxSprite>;
	
	private var title_bg : FlxSprite;
	private var portrait : FlxSprite;
	private var title_text : FlxText;
	private var dialogue_bg : FlxSprite;
	private var dialogue_text : FlxText;
	
	private var state : NewsScreenState;
	public var finished (get, null) : Bool;
	
	private static inline var title_left_margin = 10;
	private static inline var dialogue_left_margin = 10;
	private static inline var dialogue_top_margin = 10;
	private static inline var active_time = 6;
	private static inline var transition_time = 0.3;
	
	public function initiliase_portraits()
	{
		return [
			PORTRAIT_DS  => new FlxSprite(0, 0, AssetPaths.portrait_ds__png),
			PORTRAIT_FG  => new FlxSprite(0, 0, AssetPaths.portrait_fg__png),
			PORTRAIT_LOD => new FlxSprite(0, 0, AssetPaths.portrait_lod__png),
			PORTRAIT_MCM => new FlxSprite(0, 0, AssetPaths.portrait_mcm__png),
			PORTRAIT_MP  => new FlxSprite(0, 0, AssetPaths.portrait_mp__png),
			PORTRAIT_NMM => new FlxSprite(0, 0, AssetPaths.portrait_nmm__png),
			PORTRAIT_NR  => new FlxSprite(0, 0, AssetPaths.portrait_nr__png),
			PORTRAIT_TWS => new FlxSprite(0, 0, AssetPaths.portrait_tws__png),
		];
	}
	
	public function new() 
	{
		super();
		I18n.init();
		
		portraits = initiliase_portraits();
		
		portrait = null;
		
		title_bg = new FlxSprite(0, FlxG.height - 40);
		title_bg.makeGraphic(FlxG.width, 30, FlxColor.fromRGB(0, 0, 0, 168), false);
		
		title_text  = new FlxText(title_left_margin, FlxG.height - 36, FlxG.width - 60, "");
		
		dialogue_bg = new FlxSprite(dialogue_left_margin, dialogue_top_margin);
		dialogue_bg.makeGraphic(FlxG.width - (2 * dialogue_left_margin), 100, FlxColor.fromRGB(0, 0, 0, 127));
		
		dialogue_text = new FlxText(dialogue_left_margin, dialogue_top_margin, FlxG.width - (2 * dialogue_left_margin), "", 8);
		dialogue_text.wordWrap = true;
		
		for (p in portraits)
		{
			p.visible = false;
			add(p);
		}
		add(title_bg);
		add(title_text);
		add(dialogue_bg);
		add(dialogue_text);
		
		visible = false;
		state = FINISHED;
		scrollFactor.set();
	}
	
	public function display_segment(new_portrait:PortraitE, name:String, dialogue:String)
	{
		if (!Type.enumEq(state, FINISHED))
		{
			var error_msg = "Cannot call news segment to appear again while showing something";
			FlxG.log.error(error_msg);
			throw error_msg;
		}
		visible = true;
		Lambda.foreach(portraits, function (p:FlxSprite) { p.visible = false; return true; });
		portrait = portraits.get(new_portrait);
		portrait.visible = true;
		portrait.x = (FlxG.width - portrait.width) / 2.0;
		portrait.y = FlxG.height;
		FlxTween.linearMotion(portrait, portrait.x, portrait.y, portrait.x, FlxG.height - portrait.height, transition_time)
			.wait(active_time)
			.then(
				FlxTween.linearMotion(portrait, portrait.x, FlxG.height - portrait.height, portrait.x, portrait.y, transition_time)
			);
		
		title_bg.x = -title_bg.width;
		FlxTween.linearMotion(title_bg, title_bg.x, title_bg.y, 0, title_bg.y, transition_time)
			.wait(active_time)
			.then(
				FlxTween.linearMotion(title_bg, 0, title_bg.y, title_bg.x, title_bg.y, transition_time)
			);
		
		title_text.text = name;
		title_text.x = -title_bg.width + title_left_margin;
		FlxTween.linearMotion(title_text, title_text.x, title_text.y, title_left_margin, title_text.y, transition_time)
			.wait(active_time)
			.then(
				FlxTween.linearMotion(title_text, title_left_margin, title_text.y, title_text.x, title_text.y, transition_time)
			);
		
		var tween_options_states_between : NewsScreenState -> NewsScreenState -> TweenOptions = function (st_start, st_end) {
			return {
				onStart: function(t) { switch_to_state(st_start); },
				onComplete: function(t) { switch_to_state(st_end); },
			}
		};
		
		dialogue_bg.alpha = 0;
		FlxTween.tween(dialogue_bg, {alpha: 1.0}, transition_time)
			.wait(active_time)
			.then(
				FlxTween.tween(dialogue_bg, {alpha: 0.0}, transition_time)
			);
		
		dialogue_text.text = dialogue;
		dialogue_text.alpha = 0;
		FlxTween.tween(dialogue_text, {alpha:1.0}, transition_time, tween_options_states_between(APPEARING, VISIBLE))
			.wait(active_time)
			.then(
				FlxTween.tween(dialogue_text, {alpha:0.0}, transition_time, tween_options_states_between(DISAPPEARING, FINISHED))
			);
	}
	
	public function get_finished()
	{
		return Type.enumEq(state, FINISHED);
	}
	
	private function switch_to_state(new_state:NewsScreenState)
	{
		state = new_state;
		if (Type.enumEq(state, FINISHED))
		{
			visible = false;
		}
	}
	
	public static function total_news_time()
	{
		return 2 * transition_time + active_time;
	}
}


enum NewsScreenState {
	APPEARING;
	VISIBLE;
	DISAPPEARING;
	FINISHED;
}