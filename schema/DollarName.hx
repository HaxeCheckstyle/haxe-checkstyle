#if haxe4
enum abstract DollarName(String) to String {
	var DollarSchema = "$schema";
	var DollarRef = "$ref";
}
#else
@:enum abstract DollarName(String) to String {
	var DollarSchema = "@$__hx__$schema";
	var DollarRef = "@$__hx__$ref";
}
#end