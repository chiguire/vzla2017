package flixel;
import flixel.util.FlxSort;

/**
 * ...
 * @author Ciro Duran
 */
class FlxZSprite extends FlxSprite
{
	public var baseline(default, null) : Float = 0.0;
	
	public function new(X:Float=0, Y:Float=0, Baseline:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);
		this.baseline = Baseline;
	}
	
	public var z(get, set) : Float;
	
	private function get_z()
	{
		return y + baseline;
	}
	
	private function set_z(value:Float)
	{
		y = value - baseline;
		return value;
	}
	
	public static inline function byZ(Order:Int, Obj1:FlxBasic, Obj2:FlxBasic):Int
	{
		return FlxSort.byValues(Order, cast(Obj1, FlxZSprite).z, cast(Obj2, FlxZSprite).z);
	}
}