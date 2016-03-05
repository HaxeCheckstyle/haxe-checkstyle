package checkstyle.checks;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr.Position;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;

class Check {

	public var severity:SeverityLevel;

	var messages:Array<LintMessage>;
	var moduleName:String;
	var checker:Checker;

	public function new() {
		severity = SeverityLevel.INFO;
	}

	public function run(checker:Checker):Array<LintMessage> {
		this.checker = checker;
		messages = [];
		if (severity != SeverityLevel.IGNORE) {
			try {
				actualRun();
			}
			catch (e:String) {
				//exception
			}
		}
		return messages;
	}

	function actualRun() {
		throw "Unimplemented";
	}

	public function logPos(msg:String, pos:Position, sev:SeverityLevel) {
		logRange(msg, pos.min, pos.max, sev);
	}

	public function logRange(msg:String, startPos:Int, endPos:Int, sev:SeverityLevel) {
		var lp = checker.getLinePos(startPos);
		var length = endPos - startPos;
		log(msg, lp.line + 1, lp.ofs, lp.ofs + length, sev);
	}

	public function log(msg:String, l:Int, startColumn:Int, ?endColumn:Int, sev:SeverityLevel) {
		if (endColumn == null) endColumn = startColumn;
		messages.push({
			fileName:checker.file.name,
			message:msg,
			line:l,
			startColumn:startColumn,
			endColumn:endColumn,
			severity:sev,
			moduleName:getModuleName()
		});
	}

	public function getModuleName():String {
		if (moduleName == null) moduleName = ChecksInfo.getCheckName(this);
		return moduleName;
	}

	@SuppressWarnings('checkstyle:AvoidInlineConditionals')
	function forEachField(cb:Field -> ParentType -> Void) {
		for (td in checker.ast.decls) {
			var fields:Array<Field> = null;
			var kind:FieldParentKind = null;
			switch (td.decl) {
				case EClass(d):
					fields = d.data;
					kind = (d.flags.indexOf(HInterface) < 0) ? CLASS : INTERFACE;
				case EAbstract(a):
					fields = a.data;
					kind = ExprUtils.hasMeta(a.meta, ":kwdenum") ? ENUM_ABSTRACT : ABSTRACT;
				default:
			}

			if (fields == null) continue;
			for (field in fields) {
				if (!isCheckSuppressed(field)) cb(field, {decl:td.decl, kind:kind});
			}
		}
	}

	function isCheckSuppressed(f:Field):Bool {
		if (f == null) return false;
		if (hasSuppressWarningsMeta(f.meta)) return true;
		return isPosSuppressed(f.pos);
	}

	function hasSuppressWarningsMeta(m:Metadata):Bool {
		if (m == null) return false;
		var search = 'checkstyle:${getModuleName()}';
		for (meta in m) {
			if (meta.name != "SuppressWarnings") continue;
			if (meta.params == null) continue;
			for (param in meta.params) {
				if (checkSuppressionConst(param, search)) return true;
			}
		}
		return false;
	}

	function isLineSuppressed(i:Int):Bool {
		var pos:Int = 0;
		for (j in 0 ... i + 1) {
			pos += checker.lines[j].length;
		}
		return isCharPosSuppressed(pos);
	}

	function isPosExtern(pos:Position):Bool {
		return isCharPosExtern(pos.min);
	}

	function isPosSuppressed(pos:Position):Bool {
		return isCharPosSuppressed(pos.min);
	}

	@SuppressWarnings('checkstyle:CyclomaticComplexity')
	function isCharPosSuppressed(pos:Int):Bool {
		for (td in checker.ast.decls) {
			switch (td.decl){
				case EAbstract(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						if (hasSuppressWarningsMeta(d.meta)) return true;
					}
					for (field in d.data) {
						if (pos > field.pos.max) continue;
						if (pos < field.pos.min) continue;
						return hasSuppressWarningsMeta(field.meta);
					}
				case EClass(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						if (hasSuppressWarningsMeta(d.meta)) return true;
					}
					for (field in d.data) {
						if (pos > field.pos.max) continue;
						if (pos < field.pos.min) continue;
						return hasSuppressWarningsMeta(field.meta);
					}
				case EEnum(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						if (hasSuppressWarningsMeta(d.meta)) return true;
					}
					for (item in d.data) {
						if (pos > item.pos.max) continue;
						if (pos < item.pos.min) continue;
						return hasSuppressWarningsMeta(item.meta);
					}
				case ETypedef(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						if (hasSuppressWarningsMeta(d.meta)) return true;
					}
					switch (d.data) {
						case TAnonymous(fields):
							for (field in fields) {
								if (pos > field.pos.max) continue;
								if (pos < field.pos.min) continue;
								if (hasSuppressWarningsMeta(field.meta)) return true;
								// typedef pos does not include body
								return hasSuppressWarningsMeta(d.meta);
							}
						default:
					}
				default:
			}
		}
		return false;
	}

	function isCharPosExtern(pos:Int):Bool {
		for (td in checker.ast.decls) {
			switch (td.decl){
				case EAbstract(d):
				case EClass(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						return d.flags.indexOf(HExtern) > -1;
					}
				case EEnum(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						return d.flags.indexOf(EExtern) > -1;
					}
				case ETypedef(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						return d.flags.indexOf(EExtern) > -1;
					}
					switch (d.data) {
						case TAnonymous(fields):
							for (field in fields) {
								if (pos > field.pos.max) continue;
								if (pos < field.pos.min) continue;
								return d.flags.indexOf(EExtern) > -1;
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
}

@SuppressWarnings('checkstyle:MemberName')
enum FieldParentKind {
	CLASS;
	INTERFACE;
	ABSTRACT;
	ENUM_ABSTRACT;
}

typedef ParentType = {
	var decl:TypeDef;
	var kind:FieldParentKind;
}