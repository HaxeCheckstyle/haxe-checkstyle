import mcover.coverage.data.Statement;
import haxe.Json;
import sys.io.File;
import sys.io.FileOutput;
import checks.CheckTestCase;
import token.TokenTreeBuilderTest;
import mcover.coverage.client.PrintClient;
import mcover.coverage.data.CoverageResult;
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
		var client:PrintClient = new PrintClient();
		var logger = MCoverage.getLogger();
		logger.addClient(client);
		logger.report();

		var report = {coverage: {}};
		var classes = logger.coverage.getClasses();
		for (cls in classes) {
			var coverageData = [null];
			var results:CoverageResult = cls.getResults();
			for (i in 1 ... results.l) coverageData[i] = 0;
			var c = cls.name.replace(".", "/") + ".hx";
			Reflect.setField(report.coverage, c, coverageData);
		}

		for (stmtId in logger.coverage.statementResultsById.keys()) {
			var stmt:Statement = logger.coverage.getStatementById(stmtId);
			var node = stmt.file;

			var data:Array<Int> = Reflect.field(report.coverage, node);
			var isCovered = stmt.isCovered();
			for (line in stmt.lines) {
				if (isCovered) data[line + 1] = stmt.count;
			}
			Reflect.setField(report.coverage, node, data);
		}

		//To test ci integration
		var file:FileOutput = File.write("coverage.json");
		file.writeString(Json.stringify(report));
		file.close();
	}

	static function main() {
		new TestMain();
	}
}