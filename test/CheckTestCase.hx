package ;

import haxe.PosInfos;

import checkstyle.LintMessage;
import checkstyle.LintFile;
import checkstyle.reporter.IReporter;
import checkstyle.Checker;
import checkstyle.checks.Check;

class CheckTestCase extends haxe.unit.TestCase {

	static inline var FILE_NAME = "Test.hx";

	var _checker:Checker;
	var _reporter:TestReporter;

	override public function setup() {
	}

	function assertMsg(check:Check, testCase:String, expected:String, ?pos:PosInfos) {
		var msg = checkMessage (testCase, check);
		assertEquals (expected, msg, pos);
	}

	function checkMessage(src, check):String {
		// a fresh Checker and Reporter for every checkMessage
		// to allow multiple indipendant checkMessage calls in a single test
		_checker = new Checker();
		_reporter = new TestReporter();

		_checker.addCheck(check);
		_checker.addReporter(_reporter);
		_checker.process([{name:FILE_NAME, content:src}]);
		return _reporter.message;
	}

	override public function tearDown() {
		_checker = null;
		_reporter = null;
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