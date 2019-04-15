package checkstyle.utils;

class StringUtils {
	public static function isStringInterpolation(s:String, fileContent:byte.ByteData, pos:Position):Bool {
		var code:Bytes = cast fileContent;
		var quote:String = code.sub(pos.min, 1).toString();
		if (quote != "'") return false;
		var regex:EReg = ~/(^|[^$])\$(\{|[a-zA-Z0-9_]+)/;
		return regex.match(s);
	}

	public static function isEmpty(s:Null<String>):Bool {
		return (s == null) || (s.length <= 0);
	}
}