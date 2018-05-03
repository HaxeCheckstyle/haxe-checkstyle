import checks.CheckTestCase;
import misc.ThreadTest;
import misc.ConfigTest;
import token.TokenTreeBuilderTest;
import token.TokenTreeBuilderParsingTest;
import token.verify.VerifyTokenTreeTest;

class TestSuite extends massive.munit.TestSuite {

	public function new() {
		super();

		CompileTime.importPackage("checks");
		CompileTime.importPackage("misc");

		add(ConfigTest);
		add(ThreadTest);
		add(TokenTreeBuilderTest);
		add(TokenTreeBuilderParsingTest);
		add(VerifyTokenTreeTest);

		var tests = CompileTime.getAllClasses(CheckTestCase);
		for (testClass in tests) add(testClass);
	}
}