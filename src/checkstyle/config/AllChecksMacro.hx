package checkstyle.config;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import sys.FileSystem;
import haxe.io.Path;
import haxe.ds.ArraySort;

import checkstyle.utils.ArrayUtils;

class AllChecksMacro {
	macro public static function build():Array<Field> {
		var fields:Array<Field> = [];
		var checkList:Array<String> = collectAllChecks(Path.join ([Sys.getCwd(), "src", "checkstyle", "checks"]));

		ArrayUtils.sortStrings(checkList);
		for (check in checkList) {
			var field:Field = {
				name:  check,
				kind: FieldType.FVar(null, macro $v{check}),
				pos: Context.currentPos()
			};
			fields.push(field);
		}
		return fields;
	}

	static function collectAllChecks(path:String):Array<String> {
		var items:Array<String> = FileSystem.readDirectory(path);
		var checks:Array<String> = [];
		for (item in items) {
			if (item == "." || item == "..") continue;
			var fileName = Path.join([path, item]);
			if (FileSystem.isDirectory(fileName)) {
				checks = checks.concat(collectAllChecks(fileName));
				continue;
			}
			if (!StringTools.endsWith(item, "Check.hx")) {
				continue;
			}
			var name = item.substr(0, item.length - 8);
			if (name.length <= 0) {
				continue;
			}
			checks.push(name);
		}
		return checks;
	}

}
