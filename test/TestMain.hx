import haxe.Json;
import sys.io.File;
import sys.io.FileOutput;
import checks.CheckTestCase;
import token.TokenTreeBuilderTest;
import mcover.coverage.client.PrintClient;
import mcover.coverage.data.CoverageResult;
import mcover.coverage.data.Statement;
import mcover.coverage.data.Branch;
import mcover.coverage.MCoverage;

using StringTools;

class TestMain {

	public function new() {
		CompileTime.importPackage("checks");
		CompileTime.importPackage("misc");

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

		var report = { coverage: {} };
		var classes = logger.coverage.getClasses();
		for (cls in classes) {
			var coverageData:Array<LineCoverageResult> = [null];
			var results:CoverageResult = cls.getResults();
			for (i in 1...results.l) coverageData[i] = 1;
			var c = cls.name.replace(".", "/") + ".hx";

			var missingStatements:Array<Statement> = cls.getMissingStatements();
			for (stmt in missingStatements) {
				for (line in stmt.lines) coverageData[line] = 0;
			}
			var missingBranches:Array<Branch> = cls.getMissingBranches();
			for (branch in missingBranches) {
				if (branch.lines.length <= 0) continue;
				var count:Int = 0;
				if (branch.trueCount > 0) count++;
				if (branch.falseCount > 0) count++;
				var line:Int = branch.lines[branch.lines.length - 1];
				coverageData[line] = count + "/2";
			}

			Reflect.setField(report.coverage, c, coverageData);
		}

		var file:FileOutput = File.write("coverage.json");
		file.writeString(Json.stringify(report));
		file.close();
	}

	static function main() {
		new TestMain();
	}
}

typedef LineCoverageResult = Dynamic;