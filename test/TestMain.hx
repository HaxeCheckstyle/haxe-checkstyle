import checks.CheckTestCase;
import token.TokenTreeBuilderTest;

class TestMain {

	public function new() {
		CompileTime.importPackage("checks");

		var runner = new haxe.unit.TestRunner();
		runner.add(new TokenTreeBuilderTest());

		var tests = CompileTime.getAllClasses(CheckTestCase);
		for (testClass in tests) runner.add(Type.createInstance(testClass, []));

		var success = runner.run();
		Sys.exit(success ? 0 : 1);
	}

	static function main() {
		new TestMain();
	}
}