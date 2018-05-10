package detect;

import byte.ByteData;

import checkstyle.Config;
import checkstyle.CheckFile;
import checkstyle.checks.block.ConditionalCompilationCheck;
import checkstyle.checks.block.LeftCurlyCheck;
import checkstyle.checks.block.RightCurlyCheck;
import checkstyle.checks.coding.TraceCheck;
import checkstyle.checks.comments.TODOCommentCheck;
import checkstyle.checks.imports.AvoidStarImportCheck;
import checkstyle.checks.literal.StringLiteralCheck;
import checkstyle.checks.metrics.CyclomaticComplexityCheck;
import checkstyle.checks.modifier.RedundantModifierCheck;
import checkstyle.checks.naming.ConstantNameCheck;
import checkstyle.checks.size.FileLengthCheck;
import checkstyle.checks.size.LineLengthCheck;
import checkstyle.checks.size.MethodCountCheck;
import checkstyle.checks.size.MethodLengthCheck;
import checkstyle.checks.size.ParameterNumberCheck;
import checkstyle.checks.type.AnonymousCheck;
import checkstyle.checks.type.DynamicCheck;
import checkstyle.checks.type.ReturnCheck;
import checkstyle.checks.type.TypeCheck;
import checkstyle.checks.whitespace.ArrayAccessCheck;
import checkstyle.checks.whitespace.EmptyLinesCheck;
import checkstyle.checks.whitespace.IndentationCharacterCheck;
import checkstyle.checks.whitespace.IndentationCheck;
import checkstyle.checks.whitespace.OperatorWhitespaceCheck;
import checkstyle.checks.whitespace.SeparatorWrapCheck;
import checkstyle.checks.whitespace.SeparatorWhitespaceCheck;
import checkstyle.checks.whitespace.SpacingCheck;
import checkstyle.checks.whitespace.SpacingCheck.SpacingPolicy;
import checkstyle.checks.whitespace.TrailingWhitespaceCheck;
import checkstyle.checks.whitespace.WhitespaceCheckBase.WhitespacePolicy;
import checkstyle.detect.DetectCodingStyle;

import massive.munit.Assert;

class DetectCodingStyleTest {

	@Test
	public function testDetectIndentationCharacter() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new IndentationCharacterCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("IndentationCharacter", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("tab", props.character);
	}

	@Test
	public function testDetectIndentation() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new IndentationCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Indentation", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("tab", props.character);
		Assert.isFalse(props.ignoreConditionals);
		Assert.isFalse(props.ignoreComments);
		Assert.areEqual("exact", props.wrapPolicy);
	}

	@Test
	public function testDetectLeftCurly() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new LeftCurlyCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(2, detectedChecks.length);
		Assert.areEqual("LeftCurly", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("eol", props.option);
		Assert.isTrue(props.ignoreEmptySingleline);
		Assert.areEqual("LeftCurly", detectedChecks[1].type);
		props = cast detectedChecks[1].props;
		Assert.areEqual("nl", props.option);
		Assert.isTrue(props.ignoreEmptySingleline);
	}

	@Test
	public function testDetectRightCurly() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new RightCurlyCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("RightCurly", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("aloneorsingle", props.option);
	}

	@Test
	public function testDetectConditionalCompilation() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ConditionalCompilationCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("ConditionalCompilation", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("aligned", props.policy);
		Assert.isTrue(props.allowSingleline);
	}

	@Test
	public function testDetectRedundantModifier() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new RedundantModifierCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("RedundantModifier", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.enforcePublicPrivate);
		Assert.isTrue(props.enforcePublic);
		Assert.isFalse(props.enforcePrivate);
	}

	@Test
	public function testDetectSeparatorWrap() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new SeparatorWrapCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("SeparatorWrap", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("eol", props.option);
	}

	@Test
	public function testDetectConstantName() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ConstantNameCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("ConstantName", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$", props.format);
	}

	@Test
	public function testDetectTrace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TraceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Trace", detectedChecks[0].type);
	}

	@Test
	public function testDetectTODOComment() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TODOCommentCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("TODOComment", detectedChecks[0].type);
	}

	@Test
	public function testDetectAvoidStarImport() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new AvoidStarImportCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("AvoidStarImport", detectedChecks[0].type);
	}

	@Test
	public function testDetectType() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TypeCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Type", detectedChecks[0].type);
	}

	@Test
	public function testDetectTrailingWhitespace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TrailingWhitespaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("TrailingWhitespace", detectedChecks[0].type);
	}

	@Test
	public function testDetectSpacing() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new SpacingCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Spacing", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(SpacingPolicy.ANY, props.spaceIfCondition);
		Assert.isFalse(props.spaceAroundBinop);
		Assert.areEqual(SpacingPolicy.ANY, props.spaceForLoop);
		Assert.isFalse(props.ignoreRangeOperator);
		Assert.areEqual(SpacingPolicy.ANY, props.spaceWhileLoop);
		Assert.areEqual(SpacingPolicy.ANY, props.spaceCatch);
		Assert.areEqual(SpacingPolicy.SHOULD, props.spaceSwitchCase);
		Assert.isFalse(props.noSpaceAroundUnop);
	}

	@Test
	public function testDetectSeparatorWhitespace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new SeparatorWhitespaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("SeparatorWhitespace", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("after", props.commaPolicy);
		Assert.areEqual("after", props.semicolonPolicy);
		Assert.areEqual("none", props.dotPolicy);
	}

	@Test
	public function testDetectOperatorWhitespace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new OperatorWhitespaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("OperatorWhitespace", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(WhitespacePolicy.IGNORE, props.ternaryOpPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.unaryOpPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.boolOpPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.intervalOpPolicy);
		Assert.areEqual(WhitespacePolicy.AROUND, props.assignOpPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.functionArgPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.bitwiseOpPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.arithmeticOpPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.compareOpPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.arrowPolicy);
	}

	@Test
	public function testDetectEmptyLines() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new EmptyLinesCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("EmptyLines", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.requireEmptyLineAfterPackage);
		Assert.isFalse(props.requireEmptyLineAfterInterface);
		Assert.isFalse(props.requireEmptyLineAfterAbstract);
		Assert.isTrue(props.allowEmptyLineAfterSingleLineComment);
		Assert.areEqual(1, props.max);
		Assert.isFalse(props.requireEmptyLineAfterClass);
		Assert.isTrue(props.allowEmptyLineAfterMultiLineComment);
	}

	@Test
	public function testDetectArrayAccess() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ArrayAccessCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("ArrayAccess", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isTrue(props.spaceBefore);
		Assert.isTrue(props.spaceInside);
	}

	@Test
	public function testDetectReturn() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ReturnCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Return", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.enforceReturnTypeForAnonymous);
		Assert.isTrue(props.allowEmptyReturn);
		Assert.isFalse(props.enforceReturnType);
	}

	@Test
	public function testDetectDynamic() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new DynamicCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Dynamic", detectedChecks[0].type);
	}

	@Test
	public function testDetectAnonymous() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new AnonymousCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Anonymous", detectedChecks[0].type);
	}

	@Test
	public function testDetectParameterNumber() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ParameterNumberCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("ParameterNumber", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(6, props.max);
		Assert.isFalse(props.ignoreOverriddenMethods);
	}

	@Test
	public function testDetectMethodLength() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new MethodLengthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.areEqual(0, detectedChecks.length);
	}

	@Test
	public function testDetectMethodCount() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new MethodCountCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.areEqual(0, detectedChecks.length);
	}

	@Test
	public function testDetectLineLength() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new LineLengthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.areEqual(0, detectedChecks.length);
	}

	@Test
	public function testDetectFileLength() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new FileLengthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.areEqual(0, detectedChecks.length);
	}

	@Test
	public function testDetectCyclomaticComplexity() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new CyclomaticComplexityCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("CyclomaticComplexity", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(11, props.thresholds[0].complexity);
		Assert.areEqual("WARNING", props.thresholds[0].severity);
		Assert.areEqual(21, props.thresholds[1].complexity);
		Assert.areEqual("ERROR", props.thresholds[1].severity);
	}

	@Test
	public function testDetectStringLiteral() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new StringLiteralCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("StringLiteral", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("onlySingle", props.policy);
		Assert.isTrue(props.allowException);
	}

	function buildCheckFile(src:String):CheckFile {
		return {name:"Test.hx", content:ByteData.ofString(src), index:0};
	}
}

@:enum
abstract DetectCodingStyleTests(String) to String {
	var SAMPLE_CODING_STYLE = "
package checkstyle.test;

import checkstyle.checks.Check;

class Test {
	static inline var INDENTATION_CHARACTER_CHECK_TEST:Int = 100;
	public function new(param1:Int, param2:String) {}

	public function test(param1:Int, param2:String) {
		var values =  [
			1,
			2,
			3
		];
		var x = values [ 10 ];
		#if php
		// comment
		doSomething()
			.withData(data);
		#end

		#if true doNothing(); #end
	}
	function test2(p1:Int, p2:String, p3:String, p4:Int, p5:String, p6:String) {
		// comment
	}

	function test3() {
		switch (value) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
		}
		return;
	}

	function test4():Void {
		return 'test';
	}

	function test5() {
		return 1;
	}
}

interface ITest {
	public function test();
}

typedef Test2 =
{
	var name:String;
	var index:Int;
}

typedef Test2 = {}
";
}