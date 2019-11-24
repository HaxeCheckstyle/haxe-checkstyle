import massive.munit.TestRunner;
import mcover.coverage.MCoverage;
import mcover.coverage.munit.client.MCoverPrintClient;
#if (neko || cpp || hl)
import haxe.EntryPoint;
#end
#if codecov_json
import mcover.coverage.client.CodecovJsonPrintClient;
#else
import mcover.coverage.client.LcovPrintClient;
#end

class TestMain {
	public function new() {
		var suites:Array<Class<massive.munit.TestSuite>> = [TestSuite];

		var client:MCoverPrintClient = new MCoverPrintClient();
		#if codecov_json
		MCoverage.getLogger().addClient(new CodecovJsonPrintClient());
		#else
		MCoverage.getLogger().addClient(new LcovPrintClient("Checkstyle Unittests"));
		#end
		var runner:TestRunner = new TestRunner(client);
		runner.completionHandler = completionHandler;
		#if (neko || cpp || hl)
		EntryPoint.addThread(function() {
			while (true) Sys.sleep(1.0);
		});
		#end
		runner.run(suites);
	}

	function completionHandler(success:Bool) {
		// setupCoverageReport();
		#if eval
		if (!success) {
			Sys.exit(1);
		}
		#else
		Sys.exit(success ? 0 : 1);
		#end
	}

	static function main() {
		new TestMain();
	}
}