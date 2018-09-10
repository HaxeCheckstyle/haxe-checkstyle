package checkstyle.utils;

import haxe.ds.ArraySort;

class ArrayUtils {
	public static inline function contains<T>(a:Array<T>, el:T):Bool {
		return a.indexOf(el) != -1;
	}

	public static inline function sortStrings(texts:Array<String>) {
		ArraySort.sort(texts, function(a:String, b:String):Int {
			if (a > b) return 1;
			if (a < b) return -1;
			return 0;
		});
	}
}