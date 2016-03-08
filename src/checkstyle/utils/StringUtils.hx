package checkstyle.utils;

class StringUtils {

	public static inline function contains(s:String, c:String):Bool {
		return s.indexOf(c) != -1;
	}
}