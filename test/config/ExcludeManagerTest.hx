package config;

import checkstyle.checks.type.DynamicCheck;
import checkstyle.checks.type.ReturnCheck;
import checkstyle.config.ConfigParser;
import checkstyle.config.ExcludeManager;
import checkstyle.config.ExcludePath;
import checks.CheckTestCase;

class ExcludeManagerTest extends CheckTestCase<ExcludeManagerTests> {
	static inline var LOCAL_PATH:String = "./";
	static inline var CHECKSINFO_FILE_NAME:String = "src/checkstyle/checks/ChecksInfo.hx";
	static inline var CHECK_FILE_NAME:String = "src/checkstyle/checks/Check.hx";
	static inline var CHECKER_FILE_NAME:String = "src/checkstyle/checks/Checker.hx";
	static inline var TEST_CHECK_FILE_NAME:String = "test/checkstyle/checks/Check.hx";
	static inline var DYNAMIC:String = "Dynamic";

	@Before
	override public function setup() {
		ExcludeManager.INSTANCE.clear();
	}

	@Test
	public function testExcludeAllConfig() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseExcludes({
			version: 1,
			path: ExcludePath.RELATIVE_TO_PROJECT,
			all: ["checkstyle.checks.Check$"]
		});

		Assert.isTrue(ExcludeManager.isExcludedFromAll(CHECK_FILE_NAME));
		Assert.isFalse(ExcludeManager.isExcludedFromAll(CHECKER_FILE_NAME));
		Assert.isTrue(ExcludeManager.isExcludedFromAll(TEST_CHECK_FILE_NAME));
	}

	@Test
	public function testExcludeAllConfig2() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.paths = ["src", "test"];

		configParser.parseExcludes({
			version: 1,
			path: ExcludePath.RELATIVE_TO_SOURCE,
			all: ["checkstyle/checks/Check$"]
		});

		Assert.isTrue(ExcludeManager.isExcludedFromAll(CHECK_FILE_NAME));
		Assert.isFalse(ExcludeManager.isExcludedFromAll(CHECKER_FILE_NAME));
		Assert.isTrue(ExcludeManager.isExcludedFromAll(TEST_CHECK_FILE_NAME));
	}

	@Test
	public function testExcludeConfigDynamic() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseExcludes(cast {
			version: 1,
			path: ExcludePath.RELATIVE_TO_PROJECT,
			Dynamic: ["src/checkstyle/checks/Check$", "test/checkstyle/checks/Check$"]
		});

		Assert.isTrue(ExcludeManager.isExcludedFromCheck(CHECK_FILE_NAME, DYNAMIC));
		Assert.isFalse(ExcludeManager.isExcludedFromCheck(CHECKER_FILE_NAME, DYNAMIC));
		Assert.isTrue(ExcludeManager.isExcludedFromCheck(TEST_CHECK_FILE_NAME, DYNAMIC));

		Assert.isFalse(ExcludeManager.isExcludedFromCheck(CHECK_FILE_NAME, "NotDynamic"));
		Assert.isFalse(ExcludeManager.isExcludedFromCheck(TEST_CHECK_FILE_NAME, "NotDynamic"));
	}

	@Test
	public function testExcludeConfigDynamicRange() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseExcludes(cast {
			version: 1,
			path: ExcludePath.RELATIVE_TO_PROJECT,
			Dynamic: [
				"src/checkstyle/checks/ChecksInfo$:10",
				"src/checkstyle/checks/ChecksInfo$:14-16",
				"src/checkstyle/checks/ChecksInfo$:usesDynamic",
				"src/checkstyle/checks/ChecksInfo$:DynamicUsingType"
			]
		});

		assertNoMsg(new DynamicCheck(), CHECKSINFO, CHECKSINFO_FILE_NAME);
	}

	@Test
	public function testExcludeConfigAllRange() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseExcludes(cast {
			version: 1,
			path: ExcludePath.RELATIVE_TO_PROJECT,
			all: [
				"src/checkstyle/checks/ChecksInfo$:10",
				"src/checkstyle/checks/ChecksInfo$:14-16",
				"src/checkstyle/checks/ChecksInfo$:usesDynamic",
				"src/checkstyle/checks/ChecksInfo$:DynamicUsingType"
			]
		});

		assertNoMsg(new DynamicCheck(), CHECKSINFO, CHECKSINFO_FILE_NAME);
		assertNoMsg(new ReturnCheck(), CHECKSINFO, CHECKSINFO_FILE_NAME);
	}
}

@:enum
abstract ExcludeManagerTests(String) to String {
	var CHECKSINFO = "\n
	class ChecksInfo {
		public function new() {
		}

		public function usesDynamic(param1:Dynamic):Void {
		}

		public function alsoUsesDynamic(value:Dynamic):Void {
		}

		public function hasDynamicLocalVars() {
			var value1:Dynamic;
			var value2:Dynamic;
			var value3:Dynamic;
			call(value1, value2, value3);
		}
	}

	typedef DynamicUsingType = {
		var x:Dynamic;
		var y:Dynamic;
		@:optional var z:Dynamic;
	}";
}