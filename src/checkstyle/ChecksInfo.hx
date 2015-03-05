package checkstyle;

import checkstyle.checks.Check;

typedef CheckInfo = {
	var name:String;
	var description:String;
	var clazz:Class<Check>;
}

class ChecksInfo {
	var name2info:Map<String, CheckInfo>;

	public function new(){
		name2info = new Map();

		CompileTime.importPackage("checkstyle.checks"); // must be string constant
		var checksClasses = CompileTime.getAllClasses(Check);

		for (cl in checksClasses){
			var name = getCheckNameFromClass(cl);
			var desc = getCheckDescription(cl);
			name2info[name] = {
				name: name,
				description: desc,
				clazz: cl
			};
		}
	}

	static function getCheckNameFromClass(cl:Class<Check>){
		var meta = haxe.rtti.Meta.getType(cl);
		if (meta.name == null) throw '${Type.getClassName(cl)} have no @name meta.';
		if (meta.name.length != 1) throw '${Type.getClassName(cl)} @name meta should have exactly one argument';
		return meta.name[0];
	}

	public static function getCheckName(check:Check){
		return getCheckNameFromClass(Type.getClass(check));
	}

	function getCheckDescription(cl){
		// FIXME
		return "some check";
	}

	public function checks(){
		return name2info.iterator();
	}

	public function build(name:String){
		if (! name2info.exists(name)) throw 'Unknown check: $name';
		var cl = name2info[name].clazz;
		return Type.createInstance(cl,[]);
	}
}