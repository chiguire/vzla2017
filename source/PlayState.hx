package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

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
	
	var gameState : GameState;
	
	override public function create():Void
	{
		super.create();
		
		gameState = {
			paused: false,
			state: GameStateE.PROTEST_IDLE,
		};
		
		scenario = new Fajardo();
		add(scenario);
		
		pause_screen = new PauseScreen(gameState.paused);
		add(pause_screen);
		
		camera.minScrollX = 0;
		camera.maxScrollX = 1000;
		camera.minScrollY = 0;
		camera.maxScrollY = 1000;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		var gameActions = getGameActions();
		updateGameState(gameActions);
		updateRender(gameActions);
	}
	
	private function updateGameState(gameActions:Array<GameActionE>) : Void
	{
		if (gameState.paused)
		{
			Lambda.foreach(gameActions, function (ga)
			{
				switch (ga)
				{
					case NONE: // noop
					case PAUSE:
						gameState.paused = !gameState.paused;
						pause_screen.visible = gameState.paused;
					case GO_TO_GAME_STATE(state):
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
					case MOVE_CAMERA(_): // noop
				}
				return true;
			});
		}
		else
		{
			Lambda.foreach(gameActions, function (ga)
			{
				switch (ga)
				{
					case NONE: // noop
					case PAUSE:
						gameState.paused = !gameState.paused;
						pause_screen.visible = gameState.paused;
					case MOVE_CAMERA(direction):
						moveCameraDirection(FlxG.camera, direction, 20);
					case GO_TO_GAME_STATE(state):
						gameState.state = state;
					case GO_TO_FLIXEL_STATE(state):
						FlxG.switchState(cast Type.createInstance(state, []));
					case MOVE_CURSOR(direction): // noop
				}
				return true;
			});
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
				default:
			}
		}
		return [];
#if (web || desktop)
#end
	}
	
	private function justAppActions() : Array<GameActionE>
	{
		var result = [];
		
		// pause
		if (FlxG.keys.anyJustPressed(GAME_KEYBOARD_INPUTS.pause))
		{
			result.push(GameActionE.PAUSE);
		}
		
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
		
		return result;
	}
}
