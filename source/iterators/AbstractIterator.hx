package iterators;
import play.enums.GameActionE;

/**
 * A workaround for limitations for using an Iterator as a generic type parameter.
 * @author 
 */
@:forward(hasNext, next)
abstract AbstractIterator<T>(Iterator<T>)
{
	inline public function new(iterator:Iterator<T>) 
	{
		this = iterator;
	}
}