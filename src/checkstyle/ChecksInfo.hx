package checkstyle;

import checkstyle.checks.Check;

@SuppressWarnings("checkstyle:Dynamic")
class ChecksInfo {

	var name2info:Map<String, CheckInfo>;

	@SuppressWarnings('checkstyle:AvoidInlineConditionals')
	public function new() {
		name2info = new Map();

		CompileTime.importPackage("checkstyle.checks"); // must be string constant
		CompileTime.importPackage("checkstyle.checks.block");
		CompileTime.importPackage("checkstyle.checks.naming");
		CompileTime.importPackage("checkstyle.checks.size");
		CompileTime.importPackage("checkstyle.checks.whitespace");
		var checksClasses = CompileTime.getAllClasses(Check);

		for (cl in checksClasses) {
			if (ignoreClass(cl)) continue;
			var names:Array<Dynamic> = getCheckNameFromClass(cl);
			for (i in 0 ... names.length) {
				var desc = getCheckDescription(cl);
				name2info[names[i]] = {
					name: names[i],
					description: (i == 0) ? desc : desc + " [DEPRECATED, use " + names[0] + " instead]",
					clazz: cl
				};
			}
		}
	}

	static function ignoreClass(cl:Class<Check>):Bool {
		var meta = haxe.rtti.Meta.getType(cl);
		return (meta.ignore != null);
	}

	static function getCheckNameFromClass(cl:Class<Check>):Array<Dynamic> {
		var meta = haxe.rtti.Meta.getType(cl);
		if (meta.name == null) throw '${Type.getClassName(cl)} have no @name meta.';
		return meta.name;
	}

	public static function getCheckName(check:Check):String {
		return getCheckNameFromClass(Type.getClass(check))[0];
	}

	function getCheckDescription(cl:Class<Check>):String {
		return haxe.rtti.Meta.getType(cl).desc[0];
	}

	@SuppressWarnings('checkstyle:Dynamic')
	public function checks():Iterator<Dynamic> {
		return name2info.iterator();
	}

	@SuppressWarnings('checkstyle:Dynamic')
	public function build(name:String):Dynamic {
		if (!name2info.exists(name)) return null;
		var cl = name2info[name].clazz;
		return Type.createInstance(cl, []);
	}
}

typedef CheckInfo = {
	var name:String;
	var description:String;
	var clazz:Class<Check>;
}