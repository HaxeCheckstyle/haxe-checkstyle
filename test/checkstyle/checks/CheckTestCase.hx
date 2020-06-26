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
		assertMessages(check, testCase, [expected], defines, fileName, allowFailingAST, pos);
	}

	function assertMessages(check:Check, testCase:T, expected:Array<String>, ?defines:Array<Array<String>>, ?fileName:String, allowFailingAST:Bool = false,
			?pos:PosInfos) {
		var re = ~/abstractAndClass ([a-zA-Z0-9]*)/g;
		if (re.match(testCase)) {
			actualAssertMsg(check, re.replace(testCase, "class $1"), expected, fileName, allowFailingAST, pos);
			actualAssertMsg(check, re.replace(testCase, "abstract $1(Int)"), expected, fileName, allowFailingAST, pos);
		}
		else actualAssertMsg(check, testCase, expected, defines, fileName, allowFailingAST, pos);
	}

	function assertNoMsg(check:Check, testCase:T, ?fileName:String, allowFailingAST:Bool = false, ?pos:PosInfos) {
		assertMessages(check, testCase, [], null, fileName, allowFailingAST, pos);
	}

	function actualAssertMsg(check:Check, testCase:String, expected:Array<String>, ?defines:Array<Array<String>>, ?fileName:String,
			allowFailingAST:Bool = false, ?pos:PosInfos) {
		var messages:Array<CheckMessage> = checkMessages(testCase, check, defines, fileName, allowFailingAST, pos);
		if ((expected.length == 1) && (expected.length != messages.length)) {
			for (i in 0...messages.length) {
				Assert.areEqual(expected[0], messages[i].message, pos);
			}
		}

		Assert.areEqual(expected.length, messages.length, pos);
		for (i in 0...expected.length) {
			Assert.areEqual(expected[i], messages[i].message, pos);
		}
	}

	function checkMessages(src:String, check:Check, defines:Array<Array<String>>, fileName:String = FILE_NAME, allowFailingAST:Bool = false,
			?pos:PosInfos):Array<CheckMessage> {
		// a fresh Checker and Reporter for every checkMessage
		// to allow multiple independent checkMessage calls in a single test
		checker = new Checker(allowFailingAST);
		reporter = new TestReporter();

		if (defines != null) checker.defineCombinations = defines;
		checker.addCheck(check);

		ReporterManager.INSTANCE.clear();
		ReporterManager.INSTANCE.addReporter(reporter);
		checker.process([{name: fileName, content: ByteData.ofString(src), index: 0}]);
		return reporter.messages;
	}

	@After
	public function tearDown() {
		checker = null;
		reporter = null;
	}
}

class TestReporter implements IReporter {
	public var messages:Array<CheckMessage>;

	public function new() {
		messages = [];
	}

	public function start() {}

	public function finish() {}

	public function fileStart(f:CheckFile) {}

	public function fileFinish(f:CheckFile) {}

	public function addMessage(m:CheckMessage) {
		messages.push(m);
	}
}