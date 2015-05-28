package checkstyle.checks;

import haxe.macro.Expr.Position;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

class Check {

	var _messages:Array<LintMessage>;
	var _moduleName:String;
	var _checker:Checker;

	public function new() {}

	public function run(checker:Checker) {
		_checker = checker;
		_messages = [];
		_actualRun();
		return _messages;
	}

	function _actualRun() {
		throw "Unimplemented";
	}

	public function logPos(msg:String, pos:Position, sev:SeverityLevel) {
		var lp = _checker.getLinePos(pos.min);
		log(msg, lp.line + 1, lp.ofs + 1, sev);
	}

	public function log(msg:String, l:Int, c:Int, sev:SeverityLevel) {
		_messages.push({
			fileName:_checker.file.name,
			message:msg,
			line:l,
			column:c,
			severity:sev,
			moduleName:getModuleName()
		});
	}

	public function getModuleName():String {
		if (_moduleName == null) _moduleName = ChecksInfo.getCheckName(this);
		return _moduleName;
	}

	function isCheckSuppressed(f:Field):Bool {
		if (f == null) return false;
		return isPosSuppressed (f.pos);
	}

	function hasSuppressWarningsMeta(m:Metadata):Bool {
		if (m == null) return false;

		var search = 'checkstyle:${getModuleName ()}';
		for (meta in m) {
			if (meta.name != "SuppressWarnings") continue;
			if (meta.params == null) continue;
			for (param in meta.params) {
				if (checkSuppressionConst (param, search)) return true;
			}
		}
		return false;
	}

	function isLineSuppressed(i:Int):Bool {
		var pos:Int = 0;
		for (j in 0 ... i + 1) {
			pos += _checker.lines[j].length;
		}
		return isCharPosSuppressed (pos);
	}

	function isPosSuppressed(pos:Position):Bool {
		return isCharPosSuppressed (pos.min);
	}

	function isCharPosSuppressed(pos:Int):Bool {
		for (td in _checker.ast.decls) {
			switch (td.decl){
				case EAbstract(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						if (hasSuppressWarningsMeta (d.meta)) return true;
					}
					for (field in d.data) {
						if (pos > field.pos.max) continue;
						if (pos < field.pos.min) continue;
						return hasSuppressWarningsMeta (field.meta);
					}
				case EClass(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						if (hasSuppressWarningsMeta (d.meta)) return true;
					}
					for (field in d.data) {
						if (pos > field.pos.max) continue;
						if (pos < field.pos.min) continue;
						return hasSuppressWarningsMeta (field.meta);
					}
				case EEnum(d):
					if ((pos <= td.pos.max) && (pos >= td.pos.min)) {
						if (hasSuppressWarningsMeta (d.meta)) return true;
					}
					for (item in d.data) {
						if (pos > item.pos.max) continue;
						if (pos < item.pos.min) continue;
						return hasSuppressWarningsMeta (item.meta);
					}
				case ETypedef(d):
					switch (d.data) {
						case TAnonymous(fields):
							for (field in fields) {
								if (pos > field.pos.max) continue;
								if (pos < field.pos.min) continue;
								if (hasSuppressWarningsMeta (field.meta)) return true;
								// typedef pos does not include body
								return hasSuppressWarningsMeta (d.meta);
							}
						default:
					}
				default:
			}
		}
		return false;
	}

	function checkSuppressionConst (e:Expr, search:String):Bool {
		switch (e.expr) {
			case EArrayDecl (a):
				for (e1 in a) {
					if (checkSuppressionConst (e1, search)) return true;
				}
			case EConst (c):
				switch (c) {
					case CString (s):
						if (s == search) return true;
					default:
				}
			default:
		}
		return false;
	}
}
