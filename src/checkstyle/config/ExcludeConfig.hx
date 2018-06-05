package checkstyle.config;

typedef ExcludeConfig = {
	@:optional var path:ExcludePath;
	@:optional var all:ExcludeFilterList;
	@:optional var version:Int;
}

typedef ExcludeFilterList = Array<String>;