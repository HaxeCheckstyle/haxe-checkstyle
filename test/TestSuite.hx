import checks.CheckTestCase;
import detect.DetectCodingStyleTest;
#if !eval
import misc.ThreadTest;
#end
import config.ConfigParserTest;
import config.ExcludeManagerTest;
import token.TokenTreeBuilderTest;
import token.TokenTreeBuilderParsingTest;
import token.verify.VerifyTokenTreeTest;

class TestSuite extends massive.munit.TestSuite {

	public function new() {
		super();

		CompileTime.importPackage("checks");
		CompileTime.importPackage("misc");

		add(ConfigParserTest);
		add(ExcludeManagerTest);
		add(DetectCodingStyleTest);
		#if !eval
		add(ThreadTest);
		#end
		add(TokenTreeBuilderTest);
		add(TokenTreeBuilderParsingTest);
		add(VerifyTokenTreeTest);

		var tests = CompileTime.getAllClasses(CheckTestCase);
		for (testClass in tests) add(testClass);
	}
}