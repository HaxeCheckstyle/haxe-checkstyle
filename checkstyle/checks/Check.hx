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
		if (f == null || f.meta == null) return false;

		var search = 'checkstyle:${getModuleName ()}';
		for (meta in f.meta) {
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
				case EClass(d):
					for (field in d.data) {
						if (pos > field.pos.max) continue;
						if (pos < field.pos.min) continue;
						return isCheckSuppressed (field);
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
