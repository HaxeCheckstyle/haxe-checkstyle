import checkstyle.checks.CheckTestCase;
import checkstyle.config.ConfigParserTest;
import checkstyle.config.ExcludeManagerTest;
import checkstyle.detect.DetectCodingStyleTest;
import misc.CheckerTest;
import misc.ThreadTest;
import sys.io.File;
import utest.Runner;
import utest.ui.text.DiagnosticsReport;

class TestMain {
	public function new() {
		var runner:Runner = new Runner();

		var failed = false;
		runner.onProgress.add(r -> {
			if (!r.result.allOk()) {
				failed = true;
			}
		});
		runner.onComplete.add(_ -> {
			completionHandler(!failed);
		});

		new DiagnosticsReport(runner);

		var testClasses = CompileTime.getAllClasses(CheckTestCase);
		for (test in testClasses) {
			runner.addCase(Type.createInstance(test, []));
		}

		runner.addCase(new CheckerTest());
		runner.addCase(new ConfigParserTest());
		runner.addCase(new DetectCodingStyleTest());
		runner.addCase(new ThreadTest());

		runner.run();
	}

	function completionHandler(success:Bool) {
		#if instrument
		instrument.coverage.Coverage.endCoverage();
		#end
	}

	static function main() {
		new TestMain();
	}
}