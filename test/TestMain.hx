package ;

class TestMain {

	public function new() {
		var runner = new haxe.unit.TestRunner();
		runner.add(new AnonymousCheckTest());
		runner.add(new ListenerNameCheckTest());
		runner.add(new ArrayInstantiationCheckTest());

		var success = runner.run();
		Sys.exit(success ? 0 : 1);
	}

	static function main() {
		new TestMain();
	}
}