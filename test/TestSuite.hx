import checks.CheckTestCase;
import detect.DetectCodingStyleTest;
import misc.ThreadTest;
import config.ConfigParserTest;
import token.TokenTreeBuilderTest;
import token.TokenTreeBuilderParsingTest;
import token.verify.VerifyTokenTreeTest;

class TestSuite extends massive.munit.TestSuite {

	public function new() {
		super();

		CompileTime.importPackage("checks");
		CompileTime.importPackage("misc");

		add(ConfigParserTest);
		add(DetectCodingStyleTest);
		add(ThreadTest);
		add(TokenTreeBuilderTest);
		add(TokenTreeBuilderParsingTest);
		add(VerifyTokenTreeTest);

		var tests = CompileTime.getAllClasses(CheckTestCase);
		for (testClass in tests) add(testClass);
	}
}