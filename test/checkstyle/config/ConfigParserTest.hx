package checkstyle.config;

import checkstyle.utils.ConfigUtils;

class ConfigParserTest implements ITest {
	static inline var LOCAL_PATH:String = "./";
	static inline var TEST_COUNT:Int = 81;

	public function new() {}

	@Test
	public function testCheckstyleConfig() {
		var configParser:ConfigParser = new ConfigParser(reportConfigParserFailure);

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.loadConfig("checkstyle.json");

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length > 0);
		Assert.isTrue(configParser.checker.checks.length != configParser.getCheckCount());
	}

	@Test
	public function testExtendsConfigPath() {
		var configParser:ConfigParser = new ConfigParser(reportConfigParserFailure);

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseAndValidateConfig({
			extendsConfigPath: "checkstyle.json"
		}, LOCAL_PATH);

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length > 0);
	}

	@Test
	public function testValidateParserThread() {
		var configParser:ConfigParser = new ConfigParser(reportConfigParserFailure);
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 0}, "");
		Assert.equals(5, configParser.numberOfCheckerThreads);
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 10}, "");
		Assert.equals(10, configParser.numberOfCheckerThreads);
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 50}, "");
		Assert.equals(15, configParser.numberOfCheckerThreads);

		configParser.overrideCheckerThreads = 13;
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 14}, "");
		Assert.equals(13, configParser.numberOfCheckerThreads);

		configParser.overrideCheckerThreads = 18;
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 14}, "");
		Assert.equals(15, configParser.numberOfCheckerThreads);
	}

	@Test
	public function testCheckCount() {
		var configParser:ConfigParser = new ConfigParser(reportConfigParserFailure);

		Assert.equals(TEST_COUNT, configParser.getCheckCount());
	}

	@Test
	public function testUnusedChecks() {
		var configParser:ConfigParser = new ConfigParser(reportConfigParserFailure);

		Assert.equals(0, configParser.getUsedCheckCount());
		configParser.addAllChecks();
		Assert.equals(TEST_COUNT, configParser.getUsedCheckCount());
	}

	@Test
	public function testConfig() {
		var configParser:ConfigParser = new ConfigParser(reportConfigParserFailure);

		configParser.addAllChecks();
		var config:Config = ConfigUtils.makeConfigFromChecker(configParser.checker);
		config.numberOfCheckerThreads = 11;

		configParser = new ConfigParser(reportConfigParserFailure);
		configParser.parseAndValidateConfig(config, "");
		Assert.equals(configParser.getCheckCount(), configParser.getUsedCheckCount());
		Assert.equals(11, configParser.numberOfCheckerThreads);
	}

	@Test
	public function testConfigVersion1() {
		var configParser:ConfigParser = new ConfigParser(reportConfigParserFailure);

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseAndValidateConfig({
			version: 1
		}, LOCAL_PATH);

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);
	}

	@Test
	public function testConfigWrongVersion() {
		var failMessage:String = "";
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			failMessage = message;
		});

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseAndValidateConfig({
			version: 0
		}, LOCAL_PATH);

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);
		Assert.equals("configuration file has unknown version: 0", failMessage);
	}

	@Test
	public function testExcludeConfigVersion1() {
		var configParser:ConfigParser = new ConfigParser(reportConfigParserFailure);

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseExcludes({
			version: 1
		});
	}

	@Test
	public function testExcludeConfigWrongVersion() {
		var failMessage:String = "";
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			failMessage = message;
		});

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseExcludes({
			version: 0
		});

		Assert.equals("exclude configuration file has unknown version: 0", failMessage);
	}

	@Test
	public function testValidateMode() {
		var failMessage:String = "";
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			failMessage = message;
		});
		configParser.validateMode = RELAXED;

		Assert.notNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		var config:Config = {
			version: 0,
			checks: [{
				"type": "non existing check name"
			}, {
				"type": "Trace",
				"props": {
					"non_existing_property": 100
				}
			}]
		};
		configParser.parseAndValidateConfig(config, LOCAL_PATH);

		Assert.equals("", failMessage);

		configParser.validateMode = STRICT;
		configParser.parseAndValidateConfig(config, LOCAL_PATH);
		Assert.equals("Check Trace has no property named 'non_existing_property'", failMessage);
	}

	function reportConfigParserFailure(message:String) {
		Assert.fail(message);
	}
}