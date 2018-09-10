package misc;

import byte.ByteData;
import checkstyle.CheckFile;
import checkstyle.reporter.ReporterManager;
import checkstyle.Checker;
import checkstyle.ParserQueue;
import checkstyle.CheckerPool;
import checkstyle.checks.whitespace.IndentationCheck;
import checks.whitespace.IndentationCheckTest.IndentationCheckTests;
import checks.CheckTestCase.TestReporter;

class ThreadTest {
	static inline var FILE_NAME:String = "Test.hx";

	var checker:Checker;
	var reporter:TestReporter;

	@Before
	public function setup() {
		checker = setupChecker();
		reporter = new TestReporter();
		ReporterManager.INSTANCE.clear();
		ReporterManager.INSTANCE.addReporter(reporter);
	}

	@Test
	public function testParserQueue() {
		var files:Array<CheckFile> = setupFiles(13);

		var parseQueue = new ParserQueue(files, checker);
		parseQueue.start(1);
		Assert.isFalse(parseQueue.isFinished());

		Sys.sleep(1);
		var failCount:Int = 0;
		var count:Int = 0;
		Assert.isFalse(parseQueue.isFinished());
		while (true) {
			if (failCount > 8) Assert.fail("parsing failed");
			var newChecker = parseQueue.nextFile();
			if (newChecker == null) {
				failCount++;
				Sys.sleep(1.0);
				continue;
			}
			count++;
			if (count == 13) break;
		}
		Assert.isTrue(parseQueue.isFinished());
		Assert.areEqual(13, count);
		Assert.isNull(parseQueue.nextFile());
	}

	@Test
	public function testCheckerPool() {
		var files:Array<CheckFile> = setupFiles(13);

		var parseQueue = new ParserQueue(files, checker);
		parseQueue.start(1);

		var checkerPool = new CheckerPool(parseQueue, checker);
		checkerPool.start(5);
		Assert.isFalse(parseQueue.isFinished());
		Assert.isFalse(checkerPool.isFinished());

		Sys.sleep(1);
		var failCount:Int = 0;
		while (true) {
			if (failCount > 5) Assert.fail("parsing failed");
			if (parseQueue.isFinished() && checkerPool.isFinished()) break;
			failCount++;
			Sys.sleep(1.0);
		}
		Assert.isTrue(parseQueue.isFinished());
		Assert.isTrue(checkerPool.isFinished());
		Assert.isNull(parseQueue.nextFile());
	}

	function setupFiles(count:Int):Array<CheckFile> {
		var files:Array<CheckFile> = [];
		var content:ByteData = ByteData.ofString(IndentationCheckTests.CORRECT_TAB_INDENT);
		for (i in 0...count) {
			files.push({
				name: 'test_$i.hx',
				content: content,
				index: i
			});
		}
		return files;
	}

	function setupChecker():Checker {
		var newChecker:Checker = new Checker();
		newChecker.addCheck(new IndentationCheck());

		return newChecker;
	}

	@After
	public function tearDown() {
		checker = null;
		reporter = null;
	}
}