package play.eenum;

/**
 * @author 
 */
enum GameActionE 
{
	MOVE_CAMERA(direction:DirectionE);
	//QUIT;
	PAUSE;
	GO_TO_STATE(state:GameStateE);
}