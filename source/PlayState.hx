package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
//import flixel.ui.FlxVirtualPad;

import play.GameKeyboardInputs;
import play.GameState;
import play.PauseScreen;
import play.eenum.DirectionE;
import play.eenum.GameActionE;
import play.eenum.GameStateE;
import scenario.Fajardo;

class PlayState extends FlxState
{
	var scenario : Fajardo;
	var pause_screen : PauseScreen;
	//var virtual_pad : FlxVirtualPad;
	var gameState : GameState;
	
	var stateDebugText : FlxText;
	
	var messageQueue : Array<GameActionE>;
	
	var GAME_KEYBOARD_INPUTS : GameKeyboardInputs = {
		//quit:  [FlxKey.Q],
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
		
		messageQueue = [];
		gameState = {
			paused: false,
			state: GameStateE.CONTROL_AVATAR,
		};
		
		scenario = new Fajardo();
		add(scenario);
		
		pause_screen = new PauseScreen(gameState.paused);
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
		FlxG.log.error("right: "+ scenarioBounds.right + ". bottom: "+scenarioBounds.bottom);
		FlxG.worldBounds.set(
			scenarioBounds.left   - 100, 
			scenarioBounds.top    - 100, 
			scenarioBounds.right  + 100,
			scenarioBounds.bottom + 100
		);
		
		dealTransition(null, gameState.state);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		var gameActions = getGameActions();
		while (messageQueue.length > 0)
		{
			gameActions.push(messageQueue.pop());
		}
		updateGameState(gameActions);
		updateRender(gameActions);
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
			
			scenario.active = false;
		}
		else
		{
			Lambda.foreach(gameActions, function (ga)
			{
				gameScreenProcessAction(ga);
				return true;
			});
			
			scenario.active = true;
		}
	}
	
	private function pauseScreenProcessAction(gameAction:GameActionE)
	{
		switch (gameAction)
		{
			default: // noop
			case PAUSE:
				gameState.paused = !gameState.paused;
				pause_screen.visible = gameState.paused;
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
				gameState.paused = !gameState.paused;
				pause_screen.visible = gameState.paused;
				
			case MOVE_CAMERA(direction):
				moveCameraDirection(FlxG.camera, direction, 20);
			case MOVE_CAMERA_TO_POSITION(position, tweened):
				if (tweened)
				{
					FlxTween.tween(FlxG.camera.scroll, {x:position.x, y:position.y}, 1);
				}
				else
				{
					FlxG.camera.setPosition(position.x, position.y);
				}
			case FOLLOW_CAMERA(entity):
				camera.follow(entity);
			case MOVE_CHARACTER(direction):
				scenario.move_char(direction);
			case DO_CHARACTER_ACTION(action):
				scenario.do_char_action(action);
				
			case GO_TO_GAME_STATE(state):
				dealTransition(gameState.state, state);
				gameState.state = state;
			case GO_TO_FLIXEL_STATE(state):
				FlxG.switchState(cast Type.createInstance(state, []));
			case DELAY(duration):
				FlxG.log.notice("Delaying for " + duration + "ms");
				
			// noop
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
	
	private function updateRender(gameActions:Array<GameActionE>)
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
				case GameStateE.CONTROL_AVATAR:
					return moveCharacter().concat(justAppActions());
				default:
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
				case PROTEST_IDLE:
					result.push(GO_TO_GAME_STATE(CONTROL_AVATAR));
				case CONTROL_AVATAR:
					result.push(MOVE_CHARACTER(NONE));
					result.push(GO_TO_GAME_STATE(PROTEST_IDLE));
					result.push(MOVE_CAMERA_TO_POSITION(FlxPoint.get(500, 500), true));
				default: // noop
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
			result.push(GameActionE.MOVE_CHARACTER(DirectionE.UPLEFT));
		}
		else if (up && right)
		{
			result.push(GameActionE.MOVE_CHARACTER(DirectionE.UPRIGHT));
		}
		else if (up && !left && !right)
		{
			result.push(GameActionE.MOVE_CHARACTER(DirectionE.UP));
		}
		else if (left && !up && !down)
		{
			result.push(GameActionE.MOVE_CHARACTER(DirectionE.LEFT));
		}
		else if (right && !up && !down)
		{
			result.push(GameActionE.MOVE_CHARACTER(DirectionE.RIGHT));
		}
		else if (down && left)
		{
			result.push(GameActionE.MOVE_CHARACTER(DirectionE.DOWNLEFT));
		}
		else if (down && right)
		{
			result.push(GameActionE.MOVE_CHARACTER(DirectionE.DOWNRIGHT));
		}
		else if (down && !left && !right)
		{
			result.push(GameActionE.MOVE_CHARACTER(DirectionE.DOWN));
		}
		else
		{
			result.push(GameActionE.MOVE_CHARACTER(DirectionE.NONE));
		}
		
		return result;
	}
	
	private function dealTransition(oldState:Null<GameStateE>, newState:GameStateE)
	{
		switch (newState)
		{
			case CONTROL_AVATAR:
				camera.follow(scenario.main_char());
			case PROTEST_IDLE:
				camera.follow(null);
			default:
				// noop
		}
	}
	
	override public function onFocus():Void 
	{
		super.onFocus();
	}
	
	override public function onFocusLost() : Void
	{
		super.onFocusLost();
		messageQueue.push(PAUSE);
	}
}
