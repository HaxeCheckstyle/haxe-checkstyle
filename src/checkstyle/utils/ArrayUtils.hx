package checkstyle.utils;

class ArrayUtils {

	public static inline function contains<T>(a:Array<T>, el:T):Bool {
		return a.indexOf(el) != -1;
	}
}