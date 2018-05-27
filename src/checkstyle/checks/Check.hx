package checkstyle.checks;

import checkstyle.config.ExcludeRange;

class Check {

	public var severity:SeverityLevel;
	public var type(default, null):CheckType;
	public var categories:Array<Category>;
	public var points:Int;
	public var desc:String;

	var messages:Array<CheckMessage>;
	var moduleName:String;
	var checker:Checker;

	public function new(type:CheckType) {
		this.type = type;
		severity = SeverityLevel.INFO;
		categories = [Category.STYLE];

		points = 1;
		desc = haxe.rtti.Meta.getType(Type.getClass(this)).desc[0];
	}

	public function reset() {
		messages = [];
	}

	public function configureProperty(name:String, value:Any) {
		Reflect.setField(this, name, value);
	}

	public function run(checker:Checker):Array<CheckMessage> {
		reset();
		this.checker = checker;
		if (severity != SeverityLevel.IGNORE) {
			try {
				actualRun();
			}
			catch (e:String) {
				ErrorUtils.handleException(e, checker.file, getModuleName());
			}
		}
		return messages;
	}

	function actualRun() {
		throw "Unimplemented";
	}

	public function logPos(msg:String, pos:Position, ?sev:SeverityLevel) {
		logRange(msg, pos.min, pos.max, sev);
	}

	public function logRange(msg:String, startPos:Int, endPos:Int, ?sev:SeverityLevel) {
		var lp = checker.getLinePos(startPos);
		var length = endPos - startPos;
		log(msg, lp.line + 1, lp.ofs, lp.ofs + length, sev);
	}

	public function log(msg:String, l:Int, startColumn:Int, ?endColumn:Int, ?sev:SeverityLevel) {
		if (endColumn == null) endColumn = startColumn;
		if (sev == null) sev = severity;
		messages.push({
			fileName:checker.file.name,
			message:msg,
			desc:desc,
			line:l,
			startColumn:startColumn,
			endColumn:endColumn,
			severity:sev,
			moduleName:getModuleName(),
			categories:categories,
			points:points
		});
	}

	public function getModuleName():String {
		if (moduleName == null) moduleName = ChecksInfo.getCheckName(this);
		return moduleName;
	}

	function forEachField(cb:Field -> ParentType -> Void) {
		if (checker.ast.decls == null) return;
		for (td in checker.ast.decls) {
			var fields:Array<Field> = switch (td.decl) {
				case EClass(d): d.data;
				case EAbstract(a): a.data;
				default: null;
			}

			if (fields == null) continue;
			for (field in fields) {
				if (!isCheckSuppressed(field)) cb(field, td.decl.toParentType());
			}
		}
	}

	function isCheckSuppressed(f:Field):Bool {
		if (f == null) return false;
		return isPosSuppressed(f.pos);
	}

	function isLineSuppressed(i:Int):Bool {
		var pos:Int = 0;
		for (j in 0...i + 1) pos += checker.lines[j].length;
		return isCharPosSuppressed(pos);
	}

	function isPosExtern(pos:Position):Bool {
		return isCharPosExtern(pos.min);
	}

	function isPosSuppressed(pos:Position):Bool {
		return isCharPosSuppressed(pos.min);
	}

	function isCharPosSuppressed(pos:Int):Bool {
		var ranges:Array<ExcludeRange> = checker.excludesRanges.get(getModuleName());
		if (ranges == null) return false;
		if (ranges.length <= 0) return false;
		for (range in ranges) {
			if ((range.charPosStart <= pos) && (range.charPosEnd >= pos)) return true;
		}
		return false;
	}

	function isCharPosExtern(pos:Int):Bool {
		if (checker.ast.decls == null) return false;
		for (td in checker.ast.decls) {
			switch (td.decl){
				case EAbstract(d):
				case EClass(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) return d.flags.contains(HExtern);
				case EEnum(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) return d.flags.contains(EExtern);
				case ETypedef(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) return d.flags.contains(EExtern);
					switch (d.data) {
						case TAnonymous(fields):
							for (field in fields) {
								if (pos > field.pos.max) continue;
								if (pos < field.pos.min) continue;
								return d.flags.contains(EExtern);
							}
						default:
					}
				default:
			}
		}
		return false;
	}

	function checkSuppressionConst(e:Expr, search:String):Bool {
		switch (e.expr) {
			case EArrayDecl(a):
				for (e1 in a) {
					if (checkSuppressionConst(e1, search)) return true;
				}
			case EConst(c):
				switch (c) {
					case CString(s):
						if (s == search) return true;
					default:
				}
			default:
		}
		return false;
	}

	public function detectableInstances():DetectableInstances {
		return [];
	}
}

enum CheckType {
	AST;
	TOKEN;
	LINE;
}