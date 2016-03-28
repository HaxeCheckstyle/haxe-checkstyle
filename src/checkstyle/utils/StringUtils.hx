package checkstyle.utils;

import haxe.macro.Expr;

class StringUtils {

	public static inline function contains(s:String, c:String):Bool {
		return s.indexOf(c) != -1;
	}

	public static function isStringInterpolation(s:String, fileContent:String, pos:Position):Bool {
		var quote:String = fileContent.substr(pos.min, 1);
		if (quote != "'") return false;
		var regex:EReg = ~/(^|[^$])\$(\{|[a-zA-Z0-9_]+)/;
		return regex.match(s);
	}
}