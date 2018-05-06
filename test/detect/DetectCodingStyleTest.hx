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
import checkstyle.checks.modifier.RedundantModifierCheck;
import checkstyle.checks.naming.ConstantNameCheck;
import checkstyle.checks.type.TypeCheck;
import checkstyle.checks.whitespace.IndentationCharacterCheck;
import checkstyle.checks.whitespace.IndentationCheck;
import checkstyle.checks.whitespace.SeparatorWrapCheck;
import checkstyle.checks.whitespace.TrailingWhitespaceCheck;
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

	function buildCheckFile(src:String):CheckFile {
		return {name:"Test.hx", content:ByteData.ofString(src), index:0};
	}
}

@:enum
abstract DetectCodingStyleTests(String) to String {
	var SAMPLE_CODING_STYLE = "
class Test {
	static inline var INDENTATION_CHARACTER_CHECK_TEST:Int = 100;
	public function new() {}

	public function test() {
		var values =  [
			1,
			2,
			3
		];
		#if php
		// comment
		doSomething()
			.withData(data);
		#end

		#if true doNothing(); #end
	}
	function test2() {
		// comment
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