package checkstyle.detect;

import byte.ByteData;
import checkstyle.config.CheckConfig;
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
import checkstyle.checks.coding.NestedForDepthCheck;
import checkstyle.checks.coding.NestedIfDepthCheck;
import checkstyle.checks.coding.NestedTryDepthCheck;
import checkstyle.checks.coding.NullableParameterCheck;
import checkstyle.checks.coding.ReturnCountCheck;
import checkstyle.checks.coding.TraceCheck;
import checkstyle.checks.coding.UnusedLocalVarCheck;
import checkstyle.checks.design.EmptyPackageCheck;
import checkstyle.checks.design.InterfaceCheck;
import checkstyle.checks.design.UnnecessaryConstructorCheck;
import checkstyle.checks.comments.DocCommentStyleCheck;
import checkstyle.checks.comments.FieldDocCommentCheck;
import checkstyle.checks.comments.TODOCommentCheck;
import checkstyle.checks.comments.TypeDocCommentCheck;
import checkstyle.checks.imports.AvoidStarImportCheck;
import checkstyle.checks.imports.UnusedImportCheck;
import checkstyle.checks.literal.StringLiteralCheck;
import checkstyle.checks.meta.RedundantAccessMetaCheck;
import checkstyle.checks.meta.RedundantAllowMetaCheck;
import checkstyle.checks.metrics.CyclomaticComplexityCheck;
import checkstyle.checks.modifier.InlineFinalCheck;
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
import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck;
import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck.EmptyLinesPolicy;
import checkstyle.checks.whitespace.IndentationCharacterCheck;
import checkstyle.checks.whitespace.IndentationCheck;
import checkstyle.checks.whitespace.OperatorWhitespaceCheck;
import checkstyle.checks.whitespace.OperatorWrapCheck;
import checkstyle.checks.whitespace.SeparatorWrapCheck;
import checkstyle.checks.whitespace.SeparatorWhitespaceCheck;
import checkstyle.checks.whitespace.SpacingCheck;
import checkstyle.checks.whitespace.SpacingCheck.SpacingPolicy;
import checkstyle.checks.whitespace.TrailingWhitespaceCheck;
import checkstyle.checks.whitespace.WhitespaceCheckBase.WhitespacePolicy;
import checkstyle.checks.whitespace.WrapCheckBase.WrapCheckBaseOption;

class DetectCodingStyleTest {
	// checkstyle.checks.block
	@Test
	public function testBlockBreakingConditional() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new BlockBreakingConditionalCheck()],
			[buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("BlockBreakingConditional", detectedChecks[0].type);
	}

	@Test
	public function testDetectConditionalCompilation() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ConditionalCompilationCheck()],
			[buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("ConditionalCompilation", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("aligned", props.policy);
		Assert.isTrue(props.allowSingleline);
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
		Assert.areEqual(2, detectedChecks.length);
		Assert.areEqual("RightCurly", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("aloneorsingle", props.option);
		Assert.areEqual("RightCurly", detectedChecks[1].type);
		var props = cast detectedChecks[1].props;
		Assert.areEqual("same", props.option);
	}

	// checkstyle.checks.coding
	@Test
	public function testDetectArrowFunction() {
		#if haxe4
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ArrowFunctionCheck()], [buildCheckFile(SAMPLE_CODING_STYLE_HAXE_4)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("ArrowFunction", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(true, props.allowReturn);
		Assert.areEqual(true, props.allowFunction);
		Assert.areEqual(true, props.allowCurlyBody);
		Assert.areEqual(true, props.allowSingleArgParens);
		#end
	}

	@Test
	public function testDetectCodeSimilarity() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new CodeSimilarityCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("CodeSimilarity", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(8, props.thresholdIdentical);
		Assert.areEqual(12, props.thresholdSimilar);
	}

	@Test
	public function testDetectHiddenField() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new HiddenFieldCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("HiddenField", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.ignoreSetter);
		Assert.isTrue(props.ignoreConstructorParameter);
	}

	@Test
	public function testDetectInnerAssignment() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new InnerAssignmentCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.areEqual(0, detectedChecks.length);
	}

	@Test
	public function testDetectNestedForDepth() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new NestedForDepthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("NestedForDepth", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(2, props.max);
	}

	@Test
	public function testDetectNestedIfDepth() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new NestedIfDepthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("NestedIfDepth", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(2, props.max);
	}

	@Test
	public function testDetectNestedTryDepth() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new NestedTryDepthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("NestedTryDepth", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(2, props.max);
	}

	@Test
	public function testDetectNullableParameter() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new NullableParameterCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("NullableParameter", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("questionMark", props.option);
	}

	@Test
	public function testDetectReturnCount() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ReturnCountCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("ReturnCount", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(10, props.max);
	}

	@Test
	public function testDetectTrace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TraceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Trace", detectedChecks[0].type);
	}

	@Test
	public function testDetectUnusedLocalVar() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new UnusedLocalVarCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("UnusedLocalVar", detectedChecks[0].type);
	}

	// checkstyle.checks.comments
	@Test
	public function testDetectDocCommentStyle() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new DocCommentStyleCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("DocCommentStyle", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("twostars", props.startStyle);
		Assert.areEqual("none", props.lineStyle);
	}

	@Test
	public function testDetectFieldDocComment() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new FieldDocCommentCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("FieldDocComment", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isNotNull(props.tokens);
		Assert.areEqual(5, props.tokens.length);
		Assert.isFalse(props.requireParams);
		Assert.isFalse(props.requireReturn);
		Assert.isNotNull(props.excludeNames);
		Assert.areEqual(2, props.excludeNames.length);
		Assert.areEqual(FUNCTIONS, props.fieldType);
		Assert.areEqual(PUBLIC, props.modifier);
	}

	@Test
	public function testDetectTODOComment() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TODOCommentCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("TODOComment", detectedChecks[0].type);
	}

	@Test
	public function testDetectTypeDocComment() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TypeDocCommentCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("TypeDocComment", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isNotNull(props.tokens);
		Assert.areEqual(5, props.tokens.length);
	}

	// checkstyle.checks.design
	@Test
	public function testDetectEmptyPackage() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new EmptyPackageCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("EmptyPackage", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isTrue(props.enforceEmptyPackage);
	}

	@Test
	public function testDetectInterface() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new InterfaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Interface", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.allowProperties);
		Assert.isTrue(props.allowMarkerInterfaces);
	}

	@Test
	public function testDetectUnnecessaryConstructor() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new UnnecessaryConstructorCheck()],
			[buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("UnnecessaryConstructor", detectedChecks[0].type);
	}

	// checkstyle.checks.imports
	@Test
	public function testDetectAvoidStarImport() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new AvoidStarImportCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("AvoidStarImport", detectedChecks[0].type);
	}

	@Test
	public function testDetectUnusedImport() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new UnusedImportCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("UnusedImport", detectedChecks[0].type);
	}

	// checkstyle.checks.literal
	@Test
	public function testDetectStringLiteral() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new StringLiteralCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("StringLiteral", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("onlySingle", props.policy);
		Assert.isTrue(props.allowException);
	}

	// checkstyle.checks.meta
	@Test
	public function testDetectRedundantAccessMeta() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new RedundantAccessMetaCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("RedundantAccessMeta", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.prohibitMeta);
	}

	@Test
	public function testDetectRedundantAllowMeta() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new RedundantAllowMetaCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("RedundantAllowMeta", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.isFalse(props.prohibitMeta);
	}

	// checkstyle.checks.metrics
	@Test
	public function testDetectCyclomaticComplexity() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new CyclomaticComplexityCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("CyclomaticComplexity", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(11, props.thresholds[0].complexity);
		Assert.areEqual(SeverityLevel.WARNING, props.thresholds[0].severity);
		Assert.areEqual(21, props.thresholds[1].complexity);
		Assert.areEqual(SeverityLevel.ERROR, props.thresholds[1].severity);
	}

	// checkstyle.checks.modifier
	#if haxe4
	@Test
	public function testDetectInlineFinal() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new InlineFinalCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("InlineFinal", detectedChecks[0].type);
	}
	#end

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

	// checkstyle.checks.naming
	@Test
	public function testDetectConstantName() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ConstantNameCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("ConstantName", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$", props.format);
	}

	// checkstyle.checks.size
	@Test
	public function testDetectFileLength() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new FileLengthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.areEqual(0, detectedChecks.length);
	}

	@Test
	public function testDetectLineLength() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new LineLengthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("LineLength", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(100, props.max);
	}

	@Test
	public function testDetectMethodCount() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new MethodCountCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		// ignored not enough data points
		Assert.areEqual(0, detectedChecks.length);
	}

	@Test
	public function testDetectMethodLength() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new MethodLengthCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("MethodLength", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(35, props.max);
		Assert.isFalse(props.countEmpty);
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

	// checkstyle.checks.type
	@Test
	public function testDetectAnonymous() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new AnonymousCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Anonymous", detectedChecks[0].type);
	}

	@Test
	public function testDetectDynamic() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new DynamicCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Dynamic", detectedChecks[0].type);
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
	public function testDetectType() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TypeCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Type", detectedChecks[0].type);
	}

	// checkstyle.checks.whitespace
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
	public function testDetectExtendedEmptyLines() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new ExtendedEmptyLinesCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("ExtendedEmptyLines", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(1, props.max);
		Assert.areEqual(true, props.skipSingleLineTypes);
		Assert.areEqual(EmptyLinesPolicy.UPTO, props.defaultPolicy);
	}

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
		Assert.areEqual(WhitespacePolicy.IGNORE, props.oldFunctionTypePolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.newFunctionTypePolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.arrowFunctionPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.bitwiseOpPolicy);
		Assert.areEqual(WhitespacePolicy.AROUND, props.arithmeticOpPolicy);
		Assert.areEqual(WhitespacePolicy.AROUND, props.compareOpPolicy);
		Assert.areEqual(WhitespacePolicy.IGNORE, props.arrowPolicy);
	}

	@Test
	public function testDetectOperatorWrap() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new OperatorWrapCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("OperatorWrap", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(WrapCheckBaseOption.EOL, props.option);
	}

	@Test
	public function testDetectSeparatorWhitespace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new SeparatorWhitespaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("SeparatorWhitespace", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual("after", props.commaPolicy);
		Assert.areEqual("after", props.semicolonPolicy);
		Assert.areEqual("before", props.dotPolicy);
	}

	@Test
	public function testDetectSeparatorWrap() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new SeparatorWrapCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("SeparatorWrap", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(WrapCheckBaseOption.EOL, props.option);
	}

	@Test
	public function testDetectSpacing() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new SpacingCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("Spacing", detectedChecks[0].type);
		var props = cast detectedChecks[0].props;
		Assert.areEqual(SpacingPolicy.SHOULD, props.spaceIfCondition);
		Assert.isFalse(props.spaceAroundBinop);
		Assert.areEqual(SpacingPolicy.SHOULD, props.spaceForLoop);
		Assert.isFalse(props.ignoreRangeOperator);
		Assert.areEqual(SpacingPolicy.SHOULD, props.spaceWhileLoop);
		Assert.areEqual(SpacingPolicy.SHOULD_NOT, props.spaceCatch);
		Assert.areEqual(SpacingPolicy.SHOULD, props.spaceSwitchCase);
		Assert.isFalse(props.noSpaceAroundUnop);
	}

	@Test
	public function testDetectTrailingWhitespace() {
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle([new TrailingWhitespaceCheck()], [buildCheckFile(SAMPLE_CODING_STYLE)]);
		Assert.areEqual(1, detectedChecks.length);
		Assert.areEqual("TrailingWhitespace", detectedChecks[0].type);
	}

	function buildCheckFile(src:String):CheckFile {
		return {name: "Test.hx", content: ByteData.ofString(src), index: 0};
	}
}

@:enum
abstract DetectCodingStyleTests(String) to String {
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