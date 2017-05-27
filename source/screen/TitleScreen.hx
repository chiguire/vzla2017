package screen;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import screen.NewsScreen.NewsScreenState;

using com.roxstudio.i18n.I18n;

/**
 * ...
 * @author 
 */
class TitleScreen extends FlxSpriteGroup
{
	var bg : FlxSprite;
	var content_text : FlxText;
	
	private static inline var active_time = 12;
	private static inline var transition_time = 0.3;
	
	public static inline var BORDER_TOP    : Int = 30;
	public static inline var BORDER_BOTTOM : Int = 30;
	public static inline var BORDER_LEFT   : Int = 20;
	public static inline var BORDER_RIGHT  : Int = 20;
	
	public static inline var PADDING_TOP : Int = 20;
	public static inline var PADDING_LEFT : Int = 20;
	public static inline var PADDING_RIGHT : Int = 20;
	
	private var state : NewsScreenState;
	public var finished (get, null) : Bool;
	
	public function new() 
	{
		super();
		I18n.init();
		
		bg = new FlxSprite(BORDER_LEFT, BORDER_TOP);
		bg.makeGraphic(
			FlxG.width - BORDER_LEFT - BORDER_RIGHT, 
			FlxG.height - BORDER_TOP - BORDER_BOTTOM, 
			FlxColor.fromRGB(0, 0, 0, 168), 
			false
		);
		
		content_text  = new FlxText(
			BORDER_LEFT + PADDING_LEFT,
			BORDER_TOP + PADDING_TOP, 
			FlxG.width - BORDER_LEFT - BORDER_RIGHT - PADDING_LEFT - PADDING_RIGHT, 
			"RETURN TO GAME".i18n());
		content_text.wordWrap = true;
		
		add(bg);
		add(content_text);
		
		visible = false;
		state = FINISHED;
		scrollFactor.set();
	}
	
	public function display_segment(txt:String)
	{
		if (!Type.enumEq(state, FINISHED))
		{
			var error_msg = "Cannot call title segment to appear again while showing something";
			FlxG.log.error(error_msg);
			throw error_msg;
		}
		visible = true;
		
		var tween_options_states_between : NewsScreenState -> NewsScreenState -> TweenOptions = function (st_start, st_end) {
			return {
				onStart: function(t) { switch_to_state(st_start); },
				onComplete: function(t) { switch_to_state(st_end); },
			}
		};
		
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 1.0}, transition_time)
			.wait(active_time)
			.then(
				FlxTween.tween(bg, {alpha: 0.0}, transition_time)
			);
		
		content_text.text = txt;
		content_text.alpha = 0;
		FlxTween.tween(content_text, {alpha:1.0}, transition_time, tween_options_states_between(APPEARING, VISIBLE))
			.wait(active_time)
			.then(
				FlxTween.tween(content_text, {alpha:0.0}, transition_time, tween_options_states_between(DISAPPEARING, FINISHED))
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