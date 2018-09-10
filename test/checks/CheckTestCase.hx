package checks;

import byte.ByteData;
import checkstyle.CheckMessage;
import checkstyle.CheckFile;
import checkstyle.reporter.IReporter;
import checkstyle.reporter.ReporterManager;
import checkstyle.Checker;
import checkstyle.checks.Check;

class CheckTestCase<T:String> {
	static inline var FILE_NAME:String = "Test.hx";

	var checker:Checker;
	var reporter:TestReporter;

	@Before
	public function setup() {}

	function assertMsg(check:Check, testCase:T, expected:String, ?defines:Array<Array<String>>, ?fileName:String, ?pos:PosInfos) {
		var re = ~/abstractAndClass ([a-zA-Z0-9]*)/g;
		if (re.match(testCase)) {
			actualAssertMsg(check, re.replace(testCase, "class $1"), expected, fileName, pos);
			actualAssertMsg(check, re.replace(testCase, "abstract $1(Int)"), expected, fileName, pos);
		}
		else actualAssertMsg(check, testCase, expected, defines, fileName, pos);
	}

	function assertNoMsg(check:Check, testCase:T, ?fileName:String, ?pos:PosInfos) {
		assertMsg(check, testCase, "", null, fileName, pos);
	}

	function actualAssertMsg(check:Check, testCase:String, expected:String, ?defines:Array<Array<String>>, ?fileName:String, ?pos:PosInfos) {
		var msg = checkMessage(testCase, check, defines, fileName, pos);
		Assert.areEqual(expected, msg, pos);
	}

	function checkMessage(src:String, check:Check, defines:Array<Array<String>>, fileName:String = FILE_NAME, ?pos:PosInfos):String {
		// a fresh Checker and Reporter for every checkMessage
		// to allow multiple independent checkMessage calls in a single test
		checker = new Checker();
		reporter = new TestReporter();

		if (defines != null) checker.defineCombinations = defines;
		checker.addCheck(check);

		ReporterManager.INSTANCE.clear();
		ReporterManager.INSTANCE.addReporter(reporter);
		checker.process([{name: fileName, content: ByteData.ofString(src), index: 0}]);
		return reporter.message;
	}

	@After
	public function tearDown() {
		checker = null;
		reporter = null;
	}
}

class TestReporter implements IReporter {
	public var message:String;

	public function new() {
		message = "";
	}

	public function start() {}

	public function finish() {}

	public function fileStart(f:CheckFile) {}

	public function fileFinish(f:CheckFile) {}

	public function addMessage(m:CheckMessage) {
		message = m.message;
	}
}