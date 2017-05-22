package play.enums;
import flixel.FlxSprite;
import play.Character;

/**
 * @author 
 */
enum CharacterStateE 
{
	IDLE; 
	CHASING(sprite:Character, speed : Float); 
	DRAGGING(sprite:Character); 
	DRAGGED(bySprite:Character); 
	FLEEING;
	RESCUED;
	OUT;
}