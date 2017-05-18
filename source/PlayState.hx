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
import flixel.util.FlxTimer;
import haxe.ds.GenericStack;
import iterators.AbstractIterator;
import play.enums.AnchorE;
import play.enums.PortraitE;
//import flixel.ui.FlxVirtualPad;

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
	//var virtual_pad : FlxVirtualPad;
	var gameState : GameState;
	
	var stateDebugText : FlxText;
	
	var inputQueue : Array<GameActionE>;
	var messageStack : GenericStack<AbstractIterator<GameActionE>>;
	var blockingTimers : Array<FlxTimer>;
	var blockingTweens : Array<FlxTween>;
	
	var GAME_KEYBOARD_INPUTS : GameKeyboardInputs = {
		pause: [FlxKey.P, FlxKey.ESCAPE],
		up:    [FlxKey.UP, FlxKey.W],
		down:  [FlxKey.DOWN, FlxKey.S],
		left:  [FlxKey.LEFT, FlxKey.A],
		right: [FlxKey.RIGHT, FlxKey.D],
		a:     [FlxKey.ONE, FlxKey.ENTER],
		b:     [FlxKey.TWO, FlxKey.SHIFT],
	};
	
	override public function create():Void
	{
		super.create();
		
		var startPaused = false;
		
		scenario = new Fajardo();
		add(scenario);
		
		news_screen = new NewsScreen();
		add(news_screen);
		
		pause_screen = new PauseScreen(startPaused);
		add(pause_screen);
		
		//virtual_pad = new FlxVirtualPad(FlxDPadMode.FULL, FlxActionMode.A_B);
		//virtual_pad.x = 5;
		//virtual_pad.y = FlxG.height - 160;
		//add(virtual_pad);
		
		stateDebugText = new FlxText(5, FlxG.height - 15, FlxG.width - 10, "State:");
		stateDebugText.scrollFactor.set();
		add(stateDebugText);
		
		var scenarioBounds = scenario.worldBounds();
		
		camera.minScrollX = scenarioBounds.left;
		camera.maxScrollX = scenarioBounds.right;
		camera.minScrollY = scenarioBounds.top;
		camera.maxScrollY = scenarioBounds.bottom;
		//FlxG.log.error("right: "+ scenarioBounds.right + ". bottom: "+scenarioBounds.bottom);
		FlxG.worldBounds.set(
			scenarioBounds.left   - 100, 
			scenarioBounds.top    - 100, 
			scenarioBounds.right  + 100,
			scenarioBounds.bottom + 100
		);
		
		inputQueue = [];
		blockingTimers = [];
		blockingTweens = [];
		messageStack = new GenericStack();
		messageStack.add(new AbstractIterator(scenario.timeline()));
		gameState = {
			paused: startPaused,
			state: scenario.starting_state()
		};
		
		dealTransition(null, gameState.state);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		updateTimers();
		var inputActions = getGameActions();
		while (inputQueue.length > 0)
		{
			inputActions.push(inputQueue.pop());
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
			case FOLLOW_CAMERA(entity):
				camera.follow(entity);
			case MOVE_SPRITE_DIRECTION(sprite, direction):
				move_sprite(sprite, direction);
			case DO_CHARACTER_ACTION(action):
				scenario.do_char_action(action);
			case ANNOUNCE_NEWS(portrait, name, dialogue):
				move_sprite(scenario.main_character(), NONE);
				news_screen.display_segment(portrait, name, dialogue);
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
		stateDebugText.text = "State: " + Std.string(gameState.state);
	}
	
	private function getGameActions() : Array<GameActionE>
	{
		if (gameState.paused)
		{
			if (FlxG.keys.anyJustPressed(GAME_KEYBOARD_INPUTS.up))
			{
				return [MOVE_CURSOR(UP)];
				
			}
			else if (FlxG.keys.anyJustPressed(GAME_KEYBOARD_INPUTS.down))
			{
				return [MOVE_CURSOR(DOWN)];
			}
			else if (FlxG.keys.anyJustPressed(GAME_KEYBOARD_INPUTS.a))
			{
				return [pause_screen.get_action()];
			}
			else if (FlxG.keys.anyJustPressed(GAME_KEYBOARD_INPUTS.pause))
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
		if (FlxG.keys.anyJustPressed(GAME_KEYBOARD_INPUTS.pause))
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
				var up    = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.up);
				var down  = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.down);
				var left  = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.left);
				var right = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.right);
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
		var up    = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.up);
		var down  = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.down);
		var left  = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.left);
		var right = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.right);
		var character = scenario.main_character();
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
				camera.follow(character);
			case CUTSCENE:
				camera.follow(null);
		}
	}
	
	private function pauseToggle()
	{
		var newPauseState = !gameState.paused;
		gameState.paused = newPauseState;
		pause_screen.visible = !newPauseState;
		scenario.active = newPauseState;
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
