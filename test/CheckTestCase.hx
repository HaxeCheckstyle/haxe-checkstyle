package ;

import checkstyle.LintMessage;
import checkstyle.LintFile;
import checkstyle.reporter.IReporter;
import checkstyle.Checker;

class CheckTestCase extends haxe.unit.TestCase {

	static inline var FILE_NAME = "Test.hx";

	function messageEquals(expected:LintMessage, actual:LintMessage) {
		assertEquals(expected.fileName, actual.fileName);
		assertEquals(expected.moduleName, actual.moduleName);
		assertEquals(expected.line, actual.line);
		assertEquals(expected.column, actual.column);
		assertEquals(expected.severity, actual.severity);
		assertEquals(expected.message, actual.message);
	}

	function checkMessage(src, check):String {
		var checker = new Checker();
		var rep = new TestReporter();
		checker.addCheck(check);
		checker.addReporter(rep);
		checker.process([{name:FILE_NAME, content:src}]);
		return rep.message;
	}
}

class TestReporter implements IReporter {

	public var message:String;

	public function new() {
		message = "";
	}

	public function start() {}

	public function finish() {}

	public function fileStart(f:LintFile) {}

	public function fileFinish(f:LintFile) {}

	public function addMessage(m:LintMessage) {
		message = m.message;
	}
}