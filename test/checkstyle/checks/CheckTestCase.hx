package checkstyle.checks;

import byte.ByteData;
import checkstyle.CheckFile;
import checkstyle.CheckMessage;
import checkstyle.Checker;
import checkstyle.reporter.IReporter;
import checkstyle.reporter.ReporterManager;

class CheckTestCase<T:String> {
	static inline var FILE_NAME:String = "Test.hx";

	var checker:Checker;
	var reporter:TestReporter;

	@Before
	public function setup() {}

	function assertMsg(check:Check, testCase:T, expected:String, ?defines:Array<Array<String>>, ?fileName:String, allowFailingAST:Bool = false,
			?pos:PosInfos) {
		var re = ~/abstractAndClass ([a-zA-Z0-9]*)/g;
		if (re.match(testCase)) {
			actualAssertMsg(check, re.replace(testCase, "class $1"), expected, fileName, allowFailingAST, pos);
			actualAssertMsg(check, re.replace(testCase, "abstract $1(Int)"), expected, fileName, allowFailingAST, pos);
		}
		else actualAssertMsg(check, testCase, expected, defines, fileName, allowFailingAST, pos);
	}

	function assertNoMsg(check:Check, testCase:T, ?fileName:String, allowFailingAST:Bool = false, ?pos:PosInfos) {
		assertMsg(check, testCase, "", null, fileName, allowFailingAST, pos);
	}

	function actualAssertMsg(check:Check, testCase:String, expected:String, ?defines:Array<Array<String>>, ?fileName:String, allowFailingAST:Bool = false,
			?pos:PosInfos) {
		var msg = checkMessage(testCase, check, defines, fileName, allowFailingAST, pos);
		Assert.areEqual(expected, msg, pos);
	}

	function checkMessage(src:String, check:Check, defines:Array<Array<String>>, fileName:String = FILE_NAME, allowFailingAST:Bool = false,
			?pos:PosInfos):String {
		// a fresh Checker and Reporter for every checkMessage
		// to allow multiple independent checkMessage calls in a single test
		checker = new Checker(allowFailingAST);
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