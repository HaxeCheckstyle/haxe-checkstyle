package ;

class TestMain {

	public function new() {
		var runner = new haxe.unit.TestRunner();
		runner.add(new AnonymousCheckTest());
		runner.add(new ArrayInstantiationCheckTest());
		runner.add(new BlockFormatCheckTest());
		runner.add(new EmptyLinesCheckTest());
		runner.add(new ERegInstantiationCheckTest());
		runner.add(new HexadecimalLiteralsCheckTest());
		runner.add(new IndentationCharacterCheckTest());
		runner.add(new LineLengthCheckTest());
		runner.add(new ListenerNameCheckTest());
		runner.add(new MethodLengthCheckTest());
		runner.add(new NamingCheckTest());
		runner.add(new OverrideCheckTest());
		runner.add(new PublicPrivateCheckTest());
		runner.add(new ReturnCheckTest());
		runner.add(new SpacingCheckTest());
		runner.add(new TabForAligningCheckTest());
		runner.add(new TODOCommentCheckTest());
		runner.add(new TrailingWhitespaceCheckTest());
		runner.add(new TypeCheckTest());
		runner.add(new VariableInitialisationCheckTest());

		var success = runner.run();
		Sys.exit(success ? 0 : 1);
	}

	static function main() {
		new TestMain();
	}
}