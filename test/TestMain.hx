package ;

class TestMain {

	public function new() {
		var runner = new haxe.unit.TestRunner();
		runner.add(new AnonymousCheckTest());
		runner.add(new ArrayInstantiationCheckTest());
		runner.add(new BlockFormatCheckTest());
		runner.add(new EmptyLinesCheckTest());

		runner.add(new ListenerNameCheckTest());

		var success = runner.run();
		Sys.exit(success ? 0 : 1);
	}

	static function main() {
		new TestMain();
	}
}