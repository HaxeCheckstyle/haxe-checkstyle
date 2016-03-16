package checkstyle.checks;

import haxe.macro.Expr.Position;
import haxe.macro.Expr;
import checkstyle.CheckMessage.SeverityLevel;
import haxeparser.Data;

using checkstyle.utils.ArrayUtils;
using checkstyle.utils.FieldUtils;

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

	public function run(checker:Checker):Array<CheckMessage> {
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
		for (j in 0 ... i + 1) pos += checker.lines[j].length;
		return isCharPosSuppressed(pos);
	}

	function isPosExtern(pos:Position):Bool {
		return isCharPosExtern(pos.min);
	}

	function isPosSuppressed(pos:Position):Bool {
		return isCharPosSuppressed(pos.min);
	}

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
}

enum CheckType {
	AST;
	TOKEN;
	LINE;
}