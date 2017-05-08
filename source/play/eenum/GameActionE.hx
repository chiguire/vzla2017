package play.eenum;

import flixel.FlxState;

/**
 * @author 
 */
enum GameActionE 
{
	NONE;
	MOVE_CURSOR(direction:DirectionE);
	MOVE_CAMERA(direction:DirectionE);
	MOVE_CHARACTER(direction:DirectionE);
	//QUIT;
	PAUSE;
	GO_TO_GAME_STATE(state:GameStateE);
	GO_TO_FLIXEL_STATE(state:Class<FlxState>);
}