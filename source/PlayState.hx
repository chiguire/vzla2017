package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import haxe.ds.GenericStack;
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

class PlayState extends FlxState
{
	var scenario : Fajardo;
	var pause_screen : PauseScreen;
	var news_screen : NewsScreen;
	//var virtual_pad : FlxVirtualPad;
	var gameState : GameState;
	
	var stateDebugText : FlxText;
	
	var inputQueue : Array<GameActionE>;
	var messageStack : GenericStack<Iterator<GameActionE>>;
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
		messageStack.add(scenario.timeline());
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
		return blockingTimers.length == 0 &&
			!messageStack.isEmpty();
	}
	
	private function executeMessageStackNextAction(action:Null<GameActionE>)
	{
		switch (action)
		{
			case DELAY_AFTER_ACTION(time, action):
				var timer = new FlxTimer();
				timer.start(time);
				blockingTimers.push(timer);
				gameScreenProcessAction(action);
			case SEQUENCE(seq):
				messageStack.add(seq.iterator()); // Will be executed in next update
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
			case MOVE_CAMERA_TO_POSITION(position, tweened):
				if (tweened)
				{
					blockingTweens.push(FlxTween.tween(FlxG.camera.scroll, {x:position.x, y:position.y}, 1));
				}
				else
				{
					FlxG.camera.setPosition(position.x, position.y);
				}
			case FOLLOW_CAMERA(entity):
				camera.follow(entity);
			case MOVE_CHARACTER_DIRECTION(direction):
				scenario.move_char(direction);
			case DO_CHARACTER_ACTION(action):
				scenario.do_char_action(action);
			case GO_TO_GAME_STATE(state):
				dealTransition(gameState.state, state);
				gameState.state = state;
			case GO_TO_FLIXEL_STATE(state):
				FlxG.switchState(cast Type.createInstance(state, []));
				
			// noop
			case SEQUENCE(_):
			case SPAWN(_):
			case MOVE_CHARACTER_TO_POS(_):
			case DELAY_AFTER_ACTION(_,_):
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
				case GameStateE.PROTEST_IDLE:
					//no player op, just pause or quit
					return justAppActions();
				case GameStateE.CONTROL_AVATAR(_,_,_):
					return moveCharacter().concat(justAppActions());
				case ARRIVE_MURCIELAGOS:
				case ANNOUNCE_NEWS(_,_,_):
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
				case ARRIVE_MURCIELAGOS: // TODO	
				case PROTEST_IDLE:
					result.push(GO_TO_GAME_STATE(CONTROL_AVATAR(scenario.main_character(), null, null)));
					
				case CONTROL_AVATAR(character, winning_condition, losing_condition):
					result.push(MOVE_CHARACTER_DIRECTION(NONE));
					result.push(GO_TO_GAME_STATE(ANNOUNCE_NEWS(PortraitE.PORTRAIT_MP, "Miguel Pizarro", "Los muros van a caer")));
					//result.push(MOVE_CAMERA_TO_POSITION(FlxPoint.get(500, 500), true));
				case ANNOUNCE_NEWS(portrait, name, dialogue):
			}
		}
		else
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
		
		return result;
	}
	
	private function moveCharacter() : Array<GameActionE>
	{
		var result = [];
		
		// move character
		var up    = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.up);
		var down  = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.down);
		var left  = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.left);
		var right = FlxG.keys.anyPressed(GAME_KEYBOARD_INPUTS.right);
		if (up && left)
		{
			result.push(GameActionE.MOVE_CHARACTER_DIRECTION(DirectionE.UPLEFT));
		}
		else if (up && right)
		{
			result.push(GameActionE.MOVE_CHARACTER_DIRECTION(DirectionE.UPRIGHT));
		}
		else if (up && !left && !right)
		{
			result.push(GameActionE.MOVE_CHARACTER_DIRECTION(DirectionE.UP));
		}
		else if (left && !up && !down)
		{
			result.push(GameActionE.MOVE_CHARACTER_DIRECTION(DirectionE.LEFT));
		}
		else if (right && !up && !down)
		{
			result.push(GameActionE.MOVE_CHARACTER_DIRECTION(DirectionE.RIGHT));
		}
		else if (down && left)
		{
			result.push(GameActionE.MOVE_CHARACTER_DIRECTION(DirectionE.DOWNLEFT));
		}
		else if (down && right)
		{
			result.push(GameActionE.MOVE_CHARACTER_DIRECTION(DirectionE.DOWNRIGHT));
		}
		else if (down && !left && !right)
		{
			result.push(GameActionE.MOVE_CHARACTER_DIRECTION(DirectionE.DOWN));
		}
		else
		{
			result.push(GameActionE.MOVE_CHARACTER_DIRECTION(DirectionE.NONE));
		}
		
		return result;
	}
	
	private function dealTransition(oldState:Null<GameStateE>, newState:GameStateE)
	{
		switch (newState)
		{
			case CONTROL_AVATAR(character, winning_condition, losing_condition):
				camera.follow(character);
			case PROTEST_IDLE:
				camera.follow(null);
			case ARRIVE_MURCIELAGOS: // TODO
			case ANNOUNCE_NEWS(portrait, name, dialogue):
				news_screen.display_segment(portrait, name, dialogue);
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
}
