package checkstyle.detect;

import byte.ByteData;
import checkstyle.CheckFile;
import checkstyle.SeverityLevel;
import checkstyle.checks.block.BlockBreakingConditionalCheck;
import checkstyle.checks.block.ConditionalCompilationCheck;
import checkstyle.checks.block.LeftCurlyCheck;
import checkstyle.checks.block.RightCurlyCheck;
import checkstyle.checks.coding.ArrowFunctionCheck;
import checkstyle.checks.coding.CodeSimilarityCheck;
import checkstyle.checks.coding.HiddenFieldCheck;
import checkstyle.checks.coding.InnerAssignmentCheck;
import checkstyle.checks.coding.NestedControlFlowCheck;
import checkstyle.checks.coding.NestedForDepthCheck;
import checkstyle.checks.coding.NestedIfDepthCheck;
import checkstyle.checks.coding.NestedTryDepthCheck;
import checkstyle.checks.coding.NullableParameterCheck;
import checkstyle.checks.coding.ReturnCountCheck;
import checkstyle.checks.coding.TraceCheck;
import checkstyle.checks.coding.UnusedLocalVarCheck;
import checkstyle.checks.comments.CommentedOutCodeCheck;
import checkstyle.checks.comments.DocCommentStyleCheck;
import checkstyle.checks.comments.FieldDocCommentCheck;
import checkstyle.checks.comments.TODOCommentCheck;
import checkstyle.checks.comments.TypeDocCommentCheck;
import checkstyle.checks.design.EmptyPackageCheck;
import checkstyle.checks.design.InterfaceCheck;
import checkstyle.checks.design.UnnecessaryConstructorCheck;
import checkstyle.checks.imports.AvoidStarImportCheck;
import checkstyle.checks.imports.UnusedImportCheck;
import checkstyle.checks.literal.StringLiteralCheck;
import checkstyle.checks.meta.RedundantAccessMetaCheck;
import checkstyle.checks.meta.RedundantAllowMetaCheck;
import checkstyle.checks.metrics.CyclomaticComplexityCheck;
import checkstyle.checks.modifier.FinalCheck;
import checkstyle.checks.modifier.RedundantModifierCheck;
import checkstyle.checks.naming.ConstantNameCheck;
import checkstyle.checks.naming.FileNameCaseCheck;
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
import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck;
import checkstyle.checks.whitespace.IndentationCharacterCheck;
import checkstyle.checks.whitespace.IndentationCheck;
import checkstyle.checks.whitespace.OperatorWhitespaceCheck;
import checkstyle.checks.whitespace.OperatorWrapCheck;
import checkstyle.checks.whitespace.SeparatorWhitespaceCheck;
import checkstyle.checks.whitespace.SeparatorWrapCheck;
import checkstyle.checks.whitespace.SpacingCheck;
import checkstyle.checks.whitespace.TrailingWhitespaceCheck;
import checkstyle.checks.whitespace.WhitespaceCheckBase.WhitespacePolicy;
import checkstyle.checks.whitespace.WrapCheckBase.WrapCheckBaseOption;
import checkstyle.config.CheckConfig;

class DetectCodingStyleTest implements ITest {
	public function new() {}

	// checkstyle.checks.block
	@Test
	public function testBlockBreakingConditional() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new BlockBreakingConditionalCheck()],
			[buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("BlockBreakingConditional", detectedChecks[0].type);
	}

	@Test
	public function testDetectConditionalCompilation() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ConditionalCompilationCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("ConditionalCompilation", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("aligned", props.policy);
		Assert.isTrue(props.allowSingleline);
	}

	@Test
	public function testDetectLeftCurly() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new LeftCurlyCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(2, detectedChecks.length);
		Assert.equals("LeftCurly", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("eol", props.option);
		Assert.isTrue(props.ignoreEmptySingleline);
		Assert.equals("LeftCurly", detectedChecks[1].type);
		props = cast detectedChecks[1].props;
		Assert.equals("nl", props.option);
		Assert.isTrue(props.ignoreEmptySingleline);
	}

	@Test
	public function testDetectRightCurly() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new RightCurlyCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(2, detectedChecks.length);
		Assert.equals("RightCurly", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("aloneorsingle", props.option);
		Assert.equals("RightCurly", detectedChecks[1].type);
		var props = cast detectedChecks[1].props;
		Assert.equals("same", props.option);
	}

	// checkstyle.checks.coding
	@Test
	public function testDetectArrowFunction() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ArrowFunctionCheck()], [buildCheckFile(SAMPLE_CODING_STYLE_HAXE_4)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("ArrowFunction", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(true, props.allowReturn);
		Assert.equals(true, props.allowFunction);
		Assert.equals(true, props.allowCurlyBody);
		Assert.equals(true, props.allowSingleArgParens);
	}

	@Test
	public function testDetectCodeSimilarity() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new CodeSimilarityCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("CodeSimilarity", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(60, props.thresholdIdentical);
		Assert.equals(120, props.thresholdSimilar);
	}

	@Test
	public function testDetectHiddenField() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new HiddenFieldCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("HiddenField", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.ignoreSetter);
		Assert.isTrue(props.ignoreConstructorParameter);
	}

	@Test
	public function testDetectInnerAssignment() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new InnerAssignmentCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.equals(0, detectedChecks.length);
	}

	@Test
	public function testDetectNestedControlFlowC() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new NestedControlFlowCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("NestedControlFlow", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(3, props.max);
	}

	@Test
	public function testDetectNestedForDepth() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new NestedForDepthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("NestedForDepth", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(2, props.max);
	}

	@Test
	public function testDetectNestedIfDepth() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new NestedIfDepthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("NestedIfDepth", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(2, props.max);
	}

	@Test
	public function testDetectNestedTryDepth() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new NestedTryDepthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("NestedTryDepth", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(2, props.max);
	}

	@Test
	public function testDetectNullableParameter() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new NullableParameterCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("NullableParameter", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("questionMark", props.option);
	}

	@Test
	public function testDetectReturnCount() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ReturnCountCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("ReturnCount", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(10, props.max);
	}

	@Test
	public function testDetectTrace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TraceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("Trace", detectedChecks[0].type);
	}

	@Test
	public function testDetectUnusedLocalVar() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new UnusedLocalVarCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("UnusedLocalVar", detectedChecks[0].type);
	}

	// checkstyle.checks.comments
	@Test
	public function testCommentedOutCode() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new CommentedOutCodeCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("CommentedOutCode", detectedChecks[0].type);
	}

	@Test
	public function testDetectDocCommentStyle() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new DocCommentStyleCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("DocCommentStyle", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("twostars", props.startStyle);
		Assert.equals("none", props.lineStyle);
	}

	@Test
	public function testDetectFieldDocComment() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new FieldDocCommentCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("FieldDocComment", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.notNull(props.tokens);
		Assert.equals(5, untyped props.tokens.length);
		Assert.isFalse(props.requireParams);
		Assert.isFalse(props.requireReturn);
		Assert.notNull(props.excludeNames);
		Assert.equals(2, untyped props.excludeNames.length);
		Assert.equals(FUNCTIONS, props.fieldType);
		Assert.equals(PUBLIC, props.modifier);
	}

	@Test
	public function testDetectTODOComment() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TODOCommentCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("TODOComment", detectedChecks[0].type);
	}

	@Test
	public function testDetectTypeDocComment() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TypeDocCommentCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("TypeDocComment", detectedChecks[0].type);
		var props = detectedChecks[0].props;
		Assert.notNull(untyped props.tokens);
		Assert.equals(5, untyped props.tokens.length);
	}

	// checkstyle.checks.design
	@Test
	public function testDetectEmptyPackage() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new EmptyPackageCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("EmptyPackage", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isTrue(props.enforceEmptyPackage);
	}

	@Test
	public function testDetectInterface() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new InterfaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("Interface", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.allowProperties);
		Assert.isTrue(props.allowMarkerInterfaces);
	}

	@Test
	public function testDetectUnnecessaryConstructor() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new UnnecessaryConstructorCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("UnnecessaryConstructor", detectedChecks[0].type);
	}

	// checkstyle.checks.imports
	@Test
	public function testDetectAvoidStarImport() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new AvoidStarImportCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("AvoidStarImport", detectedChecks[0].type);
	}

	@Test
	public function testDetectUnusedImport() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new UnusedImportCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("UnusedImport", detectedChecks[0].type);
	}

	// checkstyle.checks.literal
	@Test
	public function testDetectStringLiteral() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new StringLiteralCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("StringLiteral", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("onlySingle", props.policy);
		Assert.isTrue(props.allowException);
	}

	// checkstyle.checks.meta
	@Test
	public function testDetectRedundantAccessMeta() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new RedundantAccessMetaCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("RedundantAccessMeta", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.prohibitMeta);
	}

	@Test
	public function testDetectRedundantAllowMeta() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new RedundantAllowMetaCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("RedundantAllowMeta", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.prohibitMeta);
	}

	// checkstyle.checks.metrics
	@Test
	public function testDetectCyclomaticComplexity() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new CyclomaticComplexityCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("CyclomaticComplexity", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(11, props.thresholds[0].complexity);
		Assert.equals(SeverityLevel.WARNING, props.thresholds[0].severity);
		Assert.equals(21, props.thresholds[1].complexity);
		Assert.equals(SeverityLevel.ERROR, props.thresholds[1].severity);
	}

	// checkstyle.checks.modifier
	@Test
	public function testDetectInlineFinal() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new FinalCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("Final", detectedChecks[0].type);
	}

	@Test
	public function testDetectRedundantModifier() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new RedundantModifierCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("RedundantModifier", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.enforcePublicPrivate);
		Assert.isTrue(props.enforcePublic);
		Assert.isFalse(props.enforcePrivate);
	}

	// checkstyle.checks.naming
	@Test
	public function testDetectConstantName() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ConstantNameCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("ConstantName", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$", props.format);
	}

	@Test
	public function testDetectFileNameCase() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new FileNameCaseCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("FileNameCase", detectedChecks[0].type);
	}

	// checkstyle.checks.size
	@Test
	public function testDetectFileLength() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new FileLengthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.equals(0, detectedChecks.length);
	}

	@Test
	public function testDetectLineLength() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new LineLengthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("LineLength", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(100, props.max);
	}

	@Test
	public function testDetectMethodCount() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new MethodCountCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.equals(0, detectedChecks.length);
	}

	@Test
	public function testDetectMethodLength() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new MethodLengthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("MethodLength", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(35, props.max);
		Assert.isFalse(props.ignoreEmptyLines);
	}

	@Test
	public function testDetectParameterNumber() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ParameterNumberCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("ParameterNumber", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(6, props.max);
		Assert.isFalse(props.ignoreOverriddenMethods);
	}

	// checkstyle.checks.type
	@Test
	public function testDetectAnonymous() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new AnonymousCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("Anonymous", detectedChecks[0].type);
	}

	@Test
	public function testDetectDynamic() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new DynamicCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("Dynamic", detectedChecks[0].type);
	}

	@Test
	public function testDetectReturn() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ReturnCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("Return", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.enforceReturnTypeForAnonymous);
		Assert.isTrue(props.allowEmptyReturn);
		Assert.isFalse(props.enforceReturnType);
	}

	@Test
	public function testDetectType() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TypeCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("Type", detectedChecks[0].type);
	}

	// checkstyle.checks.whitespace
	@Test
	public function testDetectArrayAccess() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ArrayAccessCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("ArrayAccess", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isTrue(props.spaceBefore);
		Assert.isTrue(props.spaceInside);
	}

	@Test
	public function testDetectEmptyLines() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new EmptyLinesCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("EmptyLines", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.requireEmptyLineAfterPackage);
		Assert.isFalse(props.requireEmptyLineAfterInterface);
		Assert.isFalse(props.requireEmptyLineAfterAbstract);
		Assert.isTrue(props.allowEmptyLineAfterSingleLineComment);
		Assert.equals(1, props.max);
		Assert.isFalse(props.requireEmptyLineAfterClass);
		Assert.isTrue(props.allowEmptyLineAfterMultiLineComment);
	}

	@Test
	public function testDetectExtendedEmptyLines() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ExtendedEmptyLinesCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("ExtendedEmptyLines", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(1, props.max);
		Assert.equals(true, props.skipSingleLineTypes);
		Assert.equals(EmptyLinesPolicy.UPTO, props.defaultPolicy);
	}

	@Test
	public function testDetectIndentationCharacter() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new IndentationCharacterCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("IndentationCharacter", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("tab", props.character);
	}

	@Test
	public function testDetectIndentation() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new IndentationCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("Indentation", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("tab", props.character);
		Assert.isFalse(props.ignoreConditionals);
		Assert.isFalse(props.ignoreComments);
		Assert.equals("exact", props.wrapPolicy);
	}

	@Test
	public function testDetectOperatorWhitespace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new OperatorWhitespaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("OperatorWhitespace", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(WhitespacePolicy.IGNORE, props.ternaryOpPolicy);
		Assert.equals(WhitespacePolicy.IGNORE, props.unaryOpPolicy);
		Assert.equals(WhitespacePolicy.IGNORE, props.boolOpPolicy);
		Assert.equals(WhitespacePolicy.IGNORE, props.intervalOpPolicy);
		Assert.equals(WhitespacePolicy.AROUND, props.assignOpPolicy);
		Assert.equals(WhitespacePolicy.IGNORE, props.oldFunctionTypePolicy);
		Assert.equals(WhitespacePolicy.IGNORE, props.newFunctionTypePolicy);
		Assert.equals(WhitespacePolicy.IGNORE, props.arrowFunctionPolicy);
		Assert.equals(WhitespacePolicy.IGNORE, props.bitwiseOpPolicy);
		Assert.equals(WhitespacePolicy.AROUND, props.arithmeticOpPolicy);
		Assert.equals(WhitespacePolicy.AROUND, props.compareOpPolicy);
		Assert.equals(WhitespacePolicy.IGNORE, props.arrowPolicy);
	}

	@Test
	public function testDetectOperatorWrap() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new OperatorWrapCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("OperatorWrap", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(WrapCheckBaseOption.EOL, props.option);
	}

	@Test
	public function testDetectSeparatorWhitespace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new SeparatorWhitespaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("SeparatorWhitespace", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals("after", props.commaPolicy);
		Assert.equals("after", props.semicolonPolicy);
		Assert.equals("before", props.dotPolicy);
	}

	@Test
	public function testDetectSeparatorWrap() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new SeparatorWrapCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("SeparatorWrap", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(WrapCheckBaseOption.EOL, props.option);
	}

	@Test
	public function testDetectSpacing() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new SpacingCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("Spacing", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.equals(SpacingPolicy.SHOULD, props.spaceIfCondition);
		Assert.isFalse(props.spaceAroundBinop);
		Assert.equals(SpacingPolicy.SHOULD, props.spaceForLoop);
		Assert.isFalse(props.ignoreRangeOperator);
		Assert.equals(SpacingPolicy.SHOULD, props.spaceWhileLoop);
		Assert.equals(SpacingPolicy.SHOULD_NOT, props.spaceCatch);
		Assert.equals(SpacingPolicy.SHOULD, props.spaceSwitchCase);
		Assert.isFalse(props.noSpaceAroundUnop);
	}

	@Test
	public function testDetectTrailingWhitespace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TrailingWhitespaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.equals(1, detectedChecks.length);
		Assert.equals("TrailingWhitespace", detectedChecks[0].type);
	}

	function buildCheckFile(src:String):CheckFile {
		return {name: "Test.hx", content: ByteData.ofString(src), index: 0};
	}
}

enum abstract DetectCodingStyleTests(String) to String {
	var SAMPLE_CODING_STYLE = "
package;

import checkstyle.checks.Check;

/**
	code documentation
 **/
class Test {
	static inline var INDENTATION_CHARACTER_CHECK_TEST:Int = 100;
	var param1:Int;
	/**
		code documentation
	 **/
	public var param2:Int;
	public var param3:Int;
	public var param4:Int;

	/**
		code documentation
	 **/
	public function new(param1:Int, param2:String) {}

	/**
		code documentation
	 **/
	public function test(param1:Int, param2:String) {
		var values =  [
			1,
			2,
			3
		];
		var x = values [ 1 ] +
			values [ 2 ];
		if (value) {
			doSomething();
		} else {
			doSomethingElse();
		}
	}
	/**
		code documentation
	 **/
	function test2(p1:Int, p2:String, p3:String, p4:Int = 1, ?p5:String, p6:String) {
		// comment
	}

	/**
		code documentation
	 **/
	function test3() {
		switch (value) {
			case 1: return;
			case 2: return;
			case 3: return;
			case 4: return;
			case 5: return;
			case 6: return;
			case 7: return;
			case 8: return;
			case 9: return;
		}
		return;
	}

	function test4():Void {
		return 'test';
	}

	function test5() {
		if (value == 1) {
			if (true) {
				if (false) {
					doSomething();
				}
			}
		}
		for (i in items) {
			for (j in items) {
				while ((a = b) > 1) {
					run(i, j);
				}
			}
		}
		try {
			try {
				try {
					doSomethingRisky();
				}
				catch(e) {
					tryAgain();
				}
			}
			catch(e) {
				tryAgain();
			}
		}
		catch(e) {
			giveUp();
		}
		return 1;
	}

	function test6() {
		if ((a = b) > 0) return;
	}
}

interface ITest {
	/**
		code documentation
	 **/
	public function test();
}

interface IMarker {}

typedef Test2 =
{
	var name:String;
	var index:Int;
}

typedef Test2 = {}

class Test {
	public function new() {
		return b = c;
	}
	/**
		code documentation
	 **/
	public function test(param1:Int, param2:String) {
		#if php
		// comment
		doSomething()
			.withData(data);
		#end

		#if true doNothing(); #end
	}
}
";
	var SAMPLE_CODING_STYLE_HAXE_4 = "
package;

import checkstyle.checks.Check;

/**
	code documentation
 **/
class Test {
	var f:()->Void;
	var f = (args) -> { return trace(''); };
}
";
}