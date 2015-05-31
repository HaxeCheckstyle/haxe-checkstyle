package checkstyle;

import checkstyle.checks.Check;

class ChecksInfo {

	var name2info:Map<String, CheckInfo>;

	public function new() {
		name2info = new Map();

		CompileTime.importPackage("checkstyle.checks"); // must be string constant
		var checksClasses = CompileTime.getAllClasses(Check);

		for (cl in checksClasses) {
			if (ignoreClass(cl)) continue;
			var name = getCheckNameFromClass(cl);
			var desc = getCheckDescription(cl);
			name2info[name] = {
				name: name,
				description: desc,
				clazz: cl
			};
		}
	}

	static function ignoreClass(cl:Class<Check>):Bool {
		var meta = haxe.rtti.Meta.getType(cl);
		return (meta.ignore != null);
	}

	static function getCheckNameFromClass(cl:Class<Check>):String {
		var meta = haxe.rtti.Meta.getType(cl);
		if (meta.name == null) throw '${Type.getClassName(cl)} have no @name meta.';
		if (meta.name.length != 1) throw '${Type.getClassName(cl)} @name meta should have exactly one argument';
		return meta.name[0];
	}

	public static function getCheckName(check:Check):String {
		return getCheckNameFromClass(Type.getClass(check));
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
		if (!name2info.exists(name)) throw 'Unknown check: $name';
		var cl = name2info[name].clazz;
		return Type.createInstance(cl, []);
	}
}

typedef CheckInfo = {
	var name:String;
	var description:String;
	var clazz:Class<Check>;
}
