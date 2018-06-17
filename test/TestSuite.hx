import checks.CheckTestCase;
import config.ConfigParserTest;
import config.ExcludeManagerTest;
import detect.DetectCodingStyleTest;
import misc.CheckerTest;
#if !eval
import misc.ThreadTest;
#end

class TestSuite extends massive.munit.TestSuite {

	public function new() {
		super();

		CompileTime.importPackage("checks");
		CompileTime.importPackage("misc");

		add(CheckerTest);
		add(ConfigParserTest);
		add(ExcludeManagerTest);
		add(DetectCodingStyleTest);
		#if !eval
		add(ThreadTest);
		#end

		var tests = CompileTime.getAllClasses(CheckTestCase);
		for (testClass in tests) add(testClass);
	}
}