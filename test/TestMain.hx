import checks.coding.SimplifyBooleanExpressionCheckTest;
import checks.coding.NestedTryDepthCheckTest;
import checks.coding.NestedForDepthCheckTest;
import checks.coding.NestedIfDepthCheckTest;
import checks.coding.MultipleVariableDeclarationsCheckTest;
import checks.coding.MultipleStringLiteralsCheckTest;
import checks.coding.HiddenFieldCheckTest;
import checks.coding.AvoidInlineConditionalsCheckTest;
import checks.AccessOrderCheckTest;
import checks.AnonymousCheckTest;
import checks.ArrayInstantiationCheckTest;
import checks.AvoidStarImportCheckTest;
import checks.CyclomaticComplexityCheckTest;
import checks.DynamicCheckTest;
import checks.ERegInstantiationCheckTest;
import checks.HexadecimalLiteralsCheckTest;
import checks.InnerAssignmentCheckTest;
import checks.MagicNumberCheckTest;
import checks.PublicPrivateCheckTest;
import checks.ReturnCheckTest;
import checks.TODOCommentCheckTest;
import checks.TypeCheckTest;
import checks.VariableInitialisationCheckTest;
import checks.block.EmptyBlockCheckTest;
import checks.block.LeftCurlyCheckTest;
import checks.block.NeedBracesCheckTest;
import checks.block.RightCurlyCheckTest;
import checks.naming.ConstantNameCheckTest;
import checks.naming.ListenerNameCheckTest;
import checks.naming.LocalVariableNameCheckTest;
import checks.naming.MemberNameCheckTest;
import checks.naming.MethodNameCheckTest;
import checks.naming.ParameterNameCheckTest;
import checks.naming.TypeNameCheckTest;
import checks.size.FileLengthCheckTest;
import checks.size.LineLengthCheckTest;
import checks.size.MethodLengthCheckTest;
import checks.size.ParameterNumberCheckTest;
import checks.whitespace.EmptyLinesCheckTest;
import checks.whitespace.IndentationCharacterCheckTest;
import checks.whitespace.SeparatorWrapCheckTest;
import checks.whitespace.SpacingCheckTest;
import checks.whitespace.TabForAligningCheckTest;
import checks.whitespace.TrailingWhitespaceCheckTest;
import checks.whitespace.WhitespaceAfterCheckTest;
import checks.whitespace.WhitespaceAroundCheckTest;
import token.TokenTreeBuilderTest;

class TestMain {

	public function new() {
		var runner = new haxe.unit.TestRunner();

		runner.add(new AccessOrderCheckTest());
		runner.add(new AnonymousCheckTest());
		runner.add(new ArrayInstantiationCheckTest());
		runner.add(new AvoidInlineConditionalsCheckTest());
		runner.add(new AvoidStarImportCheckTest());
		runner.add(new ConstantNameCheckTest());
		runner.add(new CyclomaticComplexityCheckTest());
		runner.add(new DynamicCheckTest());
		runner.add(new EmptyBlockCheckTest());
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
		runner.add(new MultipleVariableDeclarationsCheckTest());
		runner.add(new NeedBracesCheckTest());
		runner.add(new NestedForDepthCheckTest());
		runner.add(new NestedIfDepthCheckTest());
		runner.add(new NestedTryDepthCheckTest());
		runner.add(new ParameterNameCheckTest());
		runner.add(new ParameterNumberCheckTest());
		runner.add(new PublicPrivateCheckTest());
		runner.add(new ReturnCheckTest());
		runner.add(new RightCurlyCheckTest());
		runner.add(new SeparatorWrapCheckTest());
		runner.add(new SimplifyBooleanExpressionCheckTest());
		runner.add(new SpacingCheckTest());
		runner.add(new TabForAligningCheckTest());
		runner.add(new TODOCommentCheckTest());
		runner.add(new TokenTreeBuilderTest());
		runner.add(new TrailingWhitespaceCheckTest());
		runner.add(new TypeCheckTest());
		runner.add(new TypeNameCheckTest());
		runner.add(new VariableInitialisationCheckTest());
		runner.add(new WhitespaceAfterCheckTest());
		runner.add(new WhitespaceAroundCheckTest());

		var success = runner.run();
		Sys.exit(success ? 0 : 1);
	}

	static function main() {
		new TestMain();
	}
}