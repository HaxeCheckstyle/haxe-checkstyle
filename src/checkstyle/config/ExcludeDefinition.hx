package checkstyle.config;

enum ExcludeDefinition {
	FULL(filter:String);
	LINE(filter:String, line:Int);
	RANGE(filter:String, lineStart:Int, lineEnd:Int);
	IDENTIFIER(filter:String, name:String);
}