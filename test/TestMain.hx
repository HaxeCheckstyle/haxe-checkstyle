import mcover.coverage.data.CoverageResult;
import haxe.Json;
import mcover.coverage.client.EMMAPrintClient;
import sys.io.File;
import sys.io.FileOutput;
import checks.CheckTestCase;
import token.TokenTreeBuilderTest;

import mcover.coverage.MCoverage;

using StringTools;

class TestMain {

	public function new() {
		CompileTime.importPackage("checks");

		var runner = new haxe.unit.TestRunner();
		runner.add(new TokenTreeBuilderTest());

		var tests = CompileTime.getAllClasses(CheckTestCase);
		for (testClass in tests) runner.add(Type.createInstance(testClass, []));

		var success = runner.run();
		setupCoverageReport();
		Sys.exit(success ? 0 : 1);
	}

	static function setupCoverageReport() {
		var client:EMMAPrintClient = new EMMAPrintClient();
		var logger = MCoverage.getLogger();
		logger.addClient(client);
		logger.report();
		client.report(logger.coverage);

		Sys.println("\nTest Coverage: " + logger.coverage.getPercentage() + "%\n");

		var report = {coverage: {}};
		var classes = logger.coverage.getClasses();
		for (cls in classes) {
			var results:CoverageResult = cls.getResults();
			var c = cls.name.replace(".", "/") + ".hx";
			Reflect.setField(report.coverage, c, [null, results.s, results.sc, (results.s - results.sc), results.lp, results.b, results.m, cls.getPercentage()]);
			Sys.println(cls.name + ": " + cls.getPercentage() + "%");
		}

		//To test ci integration
		var file:FileOutput;
		file = File.write("coverage.json");
		file.writeString(Json.stringify(report));
		file.close();
	}

	static function main() {
		new TestMain();
	}
}