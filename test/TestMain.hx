package;

class TestMain {

	public function new() {
		var runner = new haxe.unit.TestRunner();

		runner.add(new AccessOrderCheckTest());
		runner.add(new AnonymousCheckTest());
		runner.add(new ArrayInstantiationCheckTest());
		runner.add(new AvoidStarImportCheckTest());
		runner.add(new BlockFormatCheckTest());
		runner.add(new ConstantNameCheckTest());
		runner.add(new CyclomaticComplexityCheckTest());
		runner.add(new DynamicCheckTest());
		runner.add(new EmptyLinesCheckTest());
		runner.add(new ERegInstantiationCheckTest());
		runner.add(new FileLengthCheckTest());
		runner.add(new HexadecimalLiteralsCheckTest());
		runner.add(new HiddenFieldCheckTest());
		runner.add(new IndentationCharacterCheckTest());
		runner.add(new InnerAssignmentCheckTest());
		runner.add(new LeftCurlyCheckTest());
		runner.add(new LineLengthCheckTest());
		runner.add(new ListenerNameCheckTest());
		runner.add(new LocalVariableNameCheckTest());
		runner.add(new MagicNumberCheckTest());
		runner.add(new MemberNameCheckTest());
		runner.add(new MethodLengthCheckTest());
		runner.add(new MethodNameCheckTest());
		runner.add(new MultipleStringLiteralsCheckTest());
		runner.add(new NeedBracesCheckTest());
		runner.add(new NestedForDepthCheckTest());
		runner.add(new NestedIfDepthCheckTest());
		runner.add(new NestedTryDepthCheckTest());
		runner.add(new NullParameterCheckTest());
		runner.add(new ParameterNameCheckTest());
		runner.add(new ParameterNumberCheckTest());
		runner.add(new PublicPrivateCheckTest());
		runner.add(new ReturnCheckTest());
		runner.add(new RightCurlyCheckTest());
		runner.add(new SpacingCheckTest());
		runner.add(new TabForAligningCheckTest());
		runner.add(new TODOCommentCheckTest());
		runner.add(new TokenTreeBuilderTest());
		runner.add(new TrailingWhitespaceCheckTest());
		runner.add(new TypeCheckTest());
		runner.add(new TypeNameCheckTest());
		runner.add(new VariableInitialisationCheckTest());

		var success = runner.run();
		Sys.exit(success ? 0 : 1);
	}

	static function main() {
		new TestMain();
	}
}