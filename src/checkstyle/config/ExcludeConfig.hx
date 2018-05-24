package checkstyle.config;

typedef ExcludeConfig = {
	@:optional var path:ExcludePath;
	@:optional var all:Array<String>;
	@:optional var version:Int;
}