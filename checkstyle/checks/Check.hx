package checkstyle.checks;

import haxe.macro.Expr.Position;
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
}