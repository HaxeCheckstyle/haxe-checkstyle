package checkstyle.utils;

class StringUtils {

	public static inline function contains(s:String, c:String):Bool {
		return s.indexOf(c) != -1;
	}

	public static function isStringInterpolation(s:String, fileContent:byte.ByteData, pos:Position):Bool {
		var code:Bytes = cast fileContent;
		var quote:String = code.sub(pos.min, 1).toString();
		if (quote != "'") return false;
		var regex:EReg = ~/(^|[^$])\$(\{|[a-zA-Z0-9_]+)/;
		return regex.match(s);
	}
}