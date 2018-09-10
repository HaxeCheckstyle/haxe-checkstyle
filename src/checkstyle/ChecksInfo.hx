package checkstyle;

import checkstyle.checks.Check;

class ChecksInfo {
	var checkInfos:Map<String, CheckInfo>;

	public function new() {
		checkInfos = new Map();

		CompileTime.importPackage("checkstyle.checks");
		var checksClasses = CompileTime.getAllClasses(Check);

		for (cl in checksClasses) {
			if (ignoreClass(cl)) continue;
			var names:Array<Dynamic> = getCheckNameFromClass(cl);
			for (i in 0...names.length) {
				var desc = getCheckDescription(cl);
				checkInfos[names[i]] = {
					name: names[i],
					clazz: cl,
					isAlias: i > 0,
					description: (i == 0) ? desc : desc + " [DEPRECATED, use " + names[0] + " instead]"
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
		if (meta.name == null) throw '${Type.getClassName(cl)} has no @name meta.';
		return meta.name;
	}

	public static function getCheckName(check:Check):String {
		return getCheckNameFromClass(Type.getClass(check))[0];
	}

	function getCheckDescription(cl:Class<Check>):String {
		return haxe.rtti.Meta.getType(cl).desc[0];
	}

	public function checks():Iterator<CheckInfo> {
		return checkInfos.iterator();
	}

	public function build(name:String):Check {
		if (!checkInfos.exists(name)) return null;
		var cl = checkInfos[name].clazz;
		return cast Type.createInstance(cl, []);
	}
}

typedef CheckInfo = {
	var name:String;
	var description:String;
	var clazz:Class<Check>;
	var isAlias:Bool;
}