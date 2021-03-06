package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.ds.GenericStack;
import iterators.AbstractIterator;
import play.enums.AnchorE;
import play.enums.PortraitE;
import screen.CurtainScreen;
import screen.TVStaticScreen;
import flixel.MyFlxVirtualPad;
import screen.TitleScreen;

import play.GameKeyboardInputs;
import play.GameState;
import screen.PauseScreen;
import screen.NewsScreen;
import play.enums.DirectionE;
import play.enums.GameActionE;
import play.enums.GameStateE;
import scenario.Fajardo;

using haxe.EnumTools.EnumValueTools;

class PlayState extends FlxState
{
	public static inline var DEBUG_MOVE_CAMERA = false;
	
	var scenario : Fajardo;
	var pause_screen : PauseScreen;
	var news_screen : NewsScreen;
	var title_screen : TitleScreen;
	var static_screen : TVStaticScreen;
	var curtain_screen : CurtainScreen;
	var virtual_pad : MyFlxVirtualPad;
	var gameState : GameState;
	
	//var stateDebugText : FlxText;
	
	var inputQueue : Array<GameActionE>;
	var messageStack : GenericStack<AbstractIterator<GameActionE>>;
	var blockingTimers : Array<FlxTimer>;
	var blockingTweens : Array<FlxTween>;
	var updateFunctions : Array<Float->Void>;
	
	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;
		//FlxG.autoPause = false;
		
		virtual_pad = new MyFlxVirtualPad(FlxDPadMode.FULL, FlxActionMode.A_B);
		scenario = new Fajardo();
		gameState = scenario.starting_state();
		news_screen = new NewsScreen();
		title_screen = new TitleScreen();
		static_screen = new TVStaticScreen(gameState.tv_static_active);
		curtain_screen = new CurtainScreen(gameState.curtain_alpha);
		pause_screen = new PauseScreen(gameState.paused);
		
		//stateDebugText = new FlxText(5, FlxG.height - 15, FlxG.width - 10, "State:");
		//stateDebugText.scrollFactor.set();
		
		add(scenario);
		add(news_screen);
		add(static_screen);
		add(curtain_screen);
		add(pause_screen);
		add(title_screen);
		add(virtual_pad);
		//add(stateDebugText);

		var cameraBounds = scenario.camera_bounds();
		
		camera.minScrollX = cameraBounds.left;
		camera.maxScrollX = cameraBounds.right;
		camera.minScrollY = cameraBounds.top;
		camera.maxScrollY = cameraBounds.bottom;
		camera.scroll.set(gameState.camera_position.x, gameState.camera_position.y);

		var scenarioBounds = scenario.world_bounds();
		//FlxG.log.error("right: "+ scenarioBounds.right + ". bottom: "+scenarioBounds.bottom);
		FlxG.worldBounds.set(
			scenarioBounds.left   - 1000, 
			scenarioBounds.top    - 1000, 
			scenarioBounds.right  + 1000,
			scenarioBounds.bottom + 1000
		);
		
		inputQueue = [];
		blockingTimers = [];
		blockingTweens = [];
		updateFunctions = [];
		messageStack = new GenericStack();
		messageStack.add(new AbstractIterator(scenario.timeline()));
		
		dealTransition(null, gameState.state);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		virtual_pad.visible = Reg.virtualpad_visible;
		virtual_pad.active = Reg.virtualpad_visible;
		updateTimers();
		var inputActions = getGameActions();
		while (inputQueue.length > 0)
		{
			inputActions.push(inputQueue.pop());
		}
		switch (gameState.state)
		{
		case CONTROL_AVATAR(_, _, _):
			Lambda.foreach(updateFunctions, function (f) { f(elapsed); return true; });
		default: // noop
		}
		updateGameState(inputActions);
		updateRender();
	}
	
	private function updateTimers()
	{
		var timersToRemove = [];
		for (timer in blockingTimers)
		{
			if (timer.finished)
			{
				timersToRemove.push(timer);
			}
		}
		for (timer in timersToRemove)
		{
			blockingTimers.remove(timer);
		}
		
		var tweensToRemove = [];
		for (tween in blockingTweens)
		{
			if (tween.finished)
			{
				tweensToRemove.push(tween);
			}
		}
		for (tween in tweensToRemove)
		{
			blockingTweens.remove(tween);
		}
	}
	
	private function updateGameState(gameActions:Array<GameActionE>) : Void
	{
		//virtual_pad.releaseAll();
		if (gameState.paused)
		{
			Lambda.foreach(gameActions, function (ga)
			{
				pauseScreenProcessAction(ga);
				return true;
			});
		}
		else
		{
			Lambda.foreach(gameActions, function (ga)
			{
				gameScreenProcessAction(ga);
				return true;
			});
			
			executeMessageStack();
		}
	}
	
	private function executeMessageStack()
	{
		while (canStepMessageStack())
		{
			var messageSequence = messageStack.first();
			if (messageSequence.hasNext())
			{
				executeMessageStackNextAction(messageSequence.next());
			}
			else
			{
				messageStack.pop();
			}
		}
	}
	
	private function canStepMessageStack()
	{
		return 
			blockingTimers.length == 0 &&
			blockingTweens.length == 0 &&
			!messageStack.isEmpty();
	}
	
	private function executeMessageStackNextAction(action:Null<GameActionE>)
	{
		switch (action)
		{
			case DELAY_SECONDS(time):
				var timer = new FlxTimer();
				timer.start(time);
				blockingTimers.push(timer);
			case SEQUENCE(seq):
				messageStack.add(new AbstractIterator(seq.iterator())); // Will be executed in next update
			case SPAWN(seq):
				for (a in seq)
				{
					executeMessageStackNextAction(a);
				}
			default:
				gameScreenProcessAction(action);
		}
	}
	
	/**
	 * Process game actions when the game is paused
	 * @param	gameAction
	 */
	private function pauseScreenProcessAction(gameAction:GameActionE)
	{
		switch (gameAction)
		{
			default: // noop
			case PAUSE:
				pauseToggle();
			case GO_TO_GAME_STATE(state):
				dealTransition(gameState.state, state);
				gameState.state = state;
			case GO_TO_FLIXEL_STATE(state):
				FlxG.switchState(cast Type.createInstance(state, []));
			case MOVE_CURSOR(direction):
				switch (direction)
				{
					case UP: pause_screen.go_up();
					case DOWN: pause_screen.go_down();
					default: // noop
				}
		}
	}
	
	/**
	 * Process game actions when the game is NOT paused
	 * @param	gameAction
	 */
	private function gameScreenProcessAction(gameAction:GameActionE)
	{
		switch (gameAction)
		{
			case PAUSE:
				pauseToggle();
				
			case MOVE_CAMERA(direction):
				moveCameraDirection(FlxG.camera, direction, 20);
				
			case MOVE_CAMERA_TO_POSITION_DIRECT(position, anchor):
				moveCameraToPosition(position.x, position.y, anchor, false);
				
			case MOVE_CAMERA_TO_POSITION_TWEENED(position, anchor, time):
				moveCameraToPosition(position.x, position.y, anchor, true, time);
				
			case MOVE_CAMERA_TO_SPRITE_DIRECT(sprite, anchor):
				moveCameraToPosition(sprite.x, sprite.y, anchor, false);
				
			case MOVE_CAMERA_TO_SPRITE_TWEENED(sprite, anchor, time):
				moveCameraToPosition(sprite.x, sprite.y, anchor, true, time);

			case START_UPDATE_FUNCTION(fn):
				updateFunctions.push(fn);
				
			case STOP_UPDATE_FUNCTION(fn):
				updateFunctions.remove(fn);
				
			case FOLLOW_CAMERA(entity):
				camera.follow(entity);
				
			case CURTAIN_FADE_IN(time):
				FlxTween.tween(curtain_screen, {alpha: 0}, time);
				
			case CURTAIN_FADE_OUT(time):
				FlxTween.tween(curtain_screen, {alpha: 1}, time);
				
			case MOVE_SPRITE_DIRECTION(sprite, direction):
				move_sprite(sprite, direction);
				
			case DO_CHARACTER_ACTION(action):
				scenario.do_char_action(action);
			
			case DISPLAY_TVSTATIC(time):
				static_screen.setStaticActive(true);
				var timer = new FlxTimer();
				timer.start(time, function (t:FlxTimer) { static_screen.setStaticActive(false); });
				blockingTimers.push(timer);
				
			case ANNOUNCE_NEWS(portrait, name, dialogue):
				move_sprite(scenario.main_character(), NONE);
				news_screen.display_segment(portrait, name, dialogue);
			
			case ANNOUNCE_TITLE(text):
				move_sprite(scenario.main_character(), NONE);
				title_screen.display_segment(text);
			
			case GO_TO_GAME_STATE(state):
				dealTransition(gameState.state, state);
				gameState.state = state;
				
			case GO_TO_FLIXEL_STATE(state):
				FlxG.switchState(cast Type.createInstance(state, []));
				
			// noop
			case SEQUENCE(_):
			case SPAWN(_):
			case MOVE_SPRITE_TO_POS(_):
			case DELAY_SECONDS(_):
			case MOVE_CURSOR(_):
			case NONE:
		}
	}
	
	private function moveCameraDirection(camera:FlxCamera, dir:DirectionE, magnitude:Int)
	{
		var x = 0;
		var y = 0;
		switch (dir)
		{
			case UPLEFT:
				x = -magnitude;
				y = -magnitude;
			case UPRIGHT:
				x = magnitude;
				y = -magnitude;
			case UP:
				x = 0;
				y = -magnitude;
			case LEFT:
				x = -magnitude;
				y = 0;
			case RIGHT:
				x = magnitude;
				y = 0;
			case DOWNLEFT:
				x = -magnitude;
				y = magnitude;
			case DOWNRIGHT:
				x = magnitude;
				y = magnitude;
			case DOWN:
				x = 0;
				y = magnitude;
			case NONE:
				x = 0;
				y = 0;
		}
		camera.scroll.x += x;
		camera.scroll.y += y;
	}
	
	private function moveCameraToPosition(x:Float, y:Float, anchor:AnchorE, tweened:Bool, ?time:Float)
	{
		var offset = FlxPoint.get(
			switch(anchor)
			{
				case TOPLEFT: 0;
				case CENTER: FlxG.width / 2.0;
			},
			switch(anchor)
			{
				case TOPLEFT: 0;
				case CENTER: FlxG.height/ 2.0;
			}
		);
		if (tweened)
		{
			blockingTweens.push(FlxTween.tween(FlxG.camera.scroll, {x:x - offset.x, y:y - offset.y}, time));
		}
		else
		{
			FlxG.camera.setPosition(x - offset.x, y - offset.y);
		}
	}
	
	private function updateRender()
	{
		gameState.camera_position.x = camera.scroll.x;
		gameState.camera_position.y = camera.scroll.y;
		//stateDebugText.text = "State: " + Std.string(gameState.state);
	}
	
	private function getGameActions() : Array<GameActionE>
	{
		if (gameState.paused)
		{
			if (FlxG.keys.anyJustPressed(Reg.GAME_KEYBOARD_INPUTS.up) ||
				virtual_pad.buttonUp.justReleased)
			{
				//virtual_pad.buttonUp.status = FlxButton.PRESSED;
				return [MOVE_CURSOR(UP)];
			}
			else if (FlxG.keys.anyJustPressed(Reg.GAME_KEYBOARD_INPUTS.down) ||
				virtual_pad.buttonDown.justReleased)
			{
				//virtual_pad.buttonDown.status = FlxButton.PRESSED;
				return [MOVE_CURSOR(DOWN)];
			}
			else if (FlxG.keys.anyJustPressed(Reg.GAME_KEYBOARD_INPUTS.a) ||
				virtual_pad.buttonA.justReleased)
			{
				//virtual_pad.buttonA.status = FlxButton.PRESSED;
				return [pause_screen.get_action()];
			}
			else if (FlxG.keys.anyJustPressed(Reg.GAME_KEYBOARD_INPUTS.pause) ||
				virtual_pad.buttonB.justReleased)
			{
				return [PAUSE];
			}
		}
		else
		{
			switch (gameState.state)
			{
				case GameStateE.CUTSCENE:
					//no player op, just pause or quit
					return justAppActions();
				case GameStateE.CONTROL_AVATAR(_,_,_):
					return moveCharacterActions()
						.concat(justAppActions());
			}
		}
		return [];
	}
	
	private function justAppActions() : Array<GameActionE>
	{
		var result = [];
		
		// pause
		if (FlxG.keys.anyJustPressed(Reg.GAME_KEYBOARD_INPUTS.pause) ||
			virtual_pad.buttonB.justReleased)
		{
			result.push(GameActionE.PAUSE);
		}
		
		// DEBUG: change mode
		if (FlxG.keys.anyJustPressed([FlxKey.SPACE]))
		{
			switch (gameState.state)
			{
				case CUTSCENE:
					result.push(GO_TO_GAME_STATE(CONTROL_AVATAR(scenario.main_character(), null, null)));
				case CONTROL_AVATAR(character, winning_condition, losing_condition):
					result.push(ANNOUNCE_NEWS(PortraitE.PORTRAIT_MP, "Miguel Pizarro", "Los muros van a caer"));
			}
		}
		else
		{
			if (DEBUG_MOVE_CAMERA)
			{
				// move camera
				var up    = FlxG.keys.anyPressed(Reg.GAME_KEYBOARD_INPUTS.up) ||
					virtual_pad.buttonUp.pressed;
				var down  = FlxG.keys.anyPressed(Reg.GAME_KEYBOARD_INPUTS.down) ||
					virtual_pad.buttonDown.pressed;
				var left  = FlxG.keys.anyPressed(Reg.GAME_KEYBOARD_INPUTS.left) ||
					virtual_pad.buttonLeft.pressed;
				var right = FlxG.keys.anyPressed(Reg.GAME_KEYBOARD_INPUTS.right) ||
					virtual_pad.buttonRight.pressed;
				
				//if (up) { virtual_pad.buttonUp.status = FlxButton.PRESSED; }
				//if (down) { virtual_pad.buttonDown.status = FlxButton.PRESSED; }
				//if (left) { virtual_pad.buttonLeft.status = FlxButton.PRESSED; }
				//if (right) { virtual_pad.buttonRight.status = FlxButton.PRESSED; }
				
				if (up && left)
				{
					result.push(GameActionE.MOVE_CAMERA(DirectionE.UPLEFT));
				}
				else if (up && right)
				{
					result.push(GameActionE.MOVE_CAMERA(DirectionE.UPRIGHT));
				}
				else if (up && !left && !right)
				{
					result.push(GameActionE.MOVE_CAMERA(DirectionE.UP));
				}
				else if (left && !up && !down)
				{
					result.push(GameActionE.MOVE_CAMERA(DirectionE.LEFT));
				}
				else if (right && !up && !down)
				{
					result.push(GameActionE.MOVE_CAMERA(DirectionE.RIGHT));
				}
				else if (down && left)
				{
					result.push(GameActionE.MOVE_CAMERA(DirectionE.DOWNLEFT));
				}
				else if (down && right)
				{
					result.push(GameActionE.MOVE_CAMERA(DirectionE.DOWNRIGHT));
				}
				else if (down && !left && !right)
				{
					result.push(GameActionE.MOVE_CAMERA(DirectionE.DOWN));
				}
			}
		}
		
		return result;
	}
	
	private function moveCharacterActions() : Array<GameActionE>
	{
		// move character
		var up    = FlxG.keys.anyPressed(Reg.GAME_KEYBOARD_INPUTS.up) ||
			virtual_pad.buttonUp.pressed;
		var down  = FlxG.keys.anyPressed(Reg.GAME_KEYBOARD_INPUTS.down) ||
			virtual_pad.buttonDown.pressed;
		var left  = FlxG.keys.anyPressed(Reg.GAME_KEYBOARD_INPUTS.left) ||
			virtual_pad.buttonLeft.pressed;
		var right = FlxG.keys.anyPressed(Reg.GAME_KEYBOARD_INPUTS.right) ||
			virtual_pad.buttonRight.pressed;
		var character = scenario.main_character();
		
		//if (up) { virtual_pad.buttonUp.status = FlxButton.PRESSED; }
		//if (down) { virtual_pad.buttonDown.status = FlxButton.PRESSED; }
		//if (left) { virtual_pad.buttonLeft.status = FlxButton.PRESSED; }
		//if (right) { virtual_pad.buttonRight.status = FlxButton.PRESSED; }
		
		return [GameActionE.MOVE_SPRITE_DIRECTION(
			character, 
			if (up && left) { DirectionE.UPLEFT; }
			else if (up && right) { DirectionE.UPRIGHT; }
			else if (up && !left && !right) { DirectionE.UP; }
			else if (left && !up && !down) { DirectionE.LEFT; }
			else if (right && !up && !down) { DirectionE.RIGHT; }
			else if (down && left) { DirectionE.DOWNLEFT; }
			else if (down && right) { DirectionE.DOWNRIGHT; }
			else if (down && !left && !right) { DirectionE.DOWN; }
			else { DirectionE.NONE; }
		)];
	}
	
	private function dealTransition(oldState:Null<GameStateE>, newState:GameStateE)
	{
		switch (newState)
		{
			case CONTROL_AVATAR(character, winning_condition, losing_condition):
				scenario.point_to_character(character);
				camera.follow(character);
			case CUTSCENE:
				camera.follow(null);
		}
	}
	
	private function pauseToggle()
	{
		var newPauseState    = !gameState.paused;
		gameState.paused     = newPauseState;
		pause_screen.visible = newPauseState;
		scenario.active      = !newPauseState;
		FlxTimer.globalManager.active = !newPauseState;
		FlxTween.globalManager.active = !newPauseState;
	}
	
	override public function onFocus():Void 
	{
		super.onFocus();
	}
	
	override public function onFocusLost() : Void
	{
		super.onFocusLost();
		inputQueue.push(PAUSE);
	}
	
	private function move_sprite(sprite:FlxSprite, direction:DirectionE)
	{
		var magnitude : Int = 100;
		switch (direction)
		{
			case UPLEFT:
				sprite.velocity.set( -magnitude, -magnitude);
				sprite.facing = FlxObject.UP | FlxObject.LEFT;
			case UPRIGHT:
				sprite.velocity.set( magnitude, -magnitude);
				sprite.facing = FlxObject.UP | FlxObject.RIGHT;
			case UP:
				sprite.velocity.set( 0, -magnitude);
				sprite.facing = FlxObject.UP;
			case LEFT:
				sprite.velocity.set( -magnitude, 0);
				sprite.facing = FlxObject.LEFT;
			case RIGHT:
				sprite.velocity.set( magnitude, 0);
				sprite.facing = FlxObject.RIGHT;
			case DOWNLEFT:
				sprite.velocity.set( -magnitude, magnitude);
				sprite.facing = FlxObject.DOWN | FlxObject.LEFT;
			case DOWNRIGHT:
				sprite.velocity.set( magnitude, magnitude);
				sprite.facing = FlxObject.DOWN| FlxObject.RIGHT;
			case DOWN:
				sprite.velocity.set( 0, magnitude);
				sprite.facing = FlxObject.DOWN;
			case NONE:
				sprite.velocity.set( 0, 0);
		}
	}
}
