package checkstyle.checks.whitespace;

import checkstyle.checks.whitespace.ListOfEmptyLines.EmptyLineRange;

@name("ExtendedEmptyLines")
@desc("Checks for consecutive empty lines.")
class ExtendedEmptyLinesCheck extends Check {

	public var max:Int;
	public var skipSingleLineTypes:Bool;
	public var beforePackage:EmptyLinesPolicy;
	public var afterPackage:EmptyLinesPolicy;
	public var betweenImports:EmptyLinesPolicy;
	public var beforeUsing:EmptyLinesPolicy;
	public var afterImports:EmptyLinesPolicy;

	public var anywhereInFile:EmptyLinesPolicy;
	public var betweenTypes:EmptyLinesPolicy;
	public var beforeFileEnd:EmptyLinesPolicy;
	public var inFunction:EmptyLinesPolicy;
	public var typeDefinition:EmptyLinesPolicy;

	public var beginClass:EmptyLinesPolicy;
	public var endClass:EmptyLinesPolicy;
	public var afterClassStaticVars:EmptyLinesPolicy;
	public var afterClassVars:EmptyLinesPolicy;
	public var betweenClassStaticVars:EmptyLinesPolicy;
	public var betweenClassVars:EmptyLinesPolicy;
	public var betweenClassMethods:EmptyLinesPolicy;

	public var beginAbstract:EmptyLinesPolicy;
	public var endAbstract:EmptyLinesPolicy;
	public var afterAbstractVars:EmptyLinesPolicy;
	public var betweenAbstractVars:EmptyLinesPolicy;
	public var betweenAbstractMethods:EmptyLinesPolicy;

	public var beginInterface:EmptyLinesPolicy;
	public var endInterface:EmptyLinesPolicy;
	public var betweenInterfaceFields:EmptyLinesPolicy;

	public var beginEnum:EmptyLinesPolicy;
	public var endEnum:EmptyLinesPolicy;
	public var betweenEnumFields:EmptyLinesPolicy;

	public var beginTypedef:EmptyLinesPolicy;
	public var endTypedef:EmptyLinesPolicy;
	public var betweenTypedefFields:EmptyLinesPolicy;

	public var afterSingleLineComment:EmptyLinesPolicy;
	public var afterMultiLineComment:EmptyLinesPolicy;

	public function new() {
		super(TOKEN);
		max = 1;
		skipSingleLineTypes = true;

		beforePackage = NONE;
		afterPackage = EXACT;
		beforeUsing = EXACT;
		betweenImports = UPTO;
		afterImports = EXACT;

		anywhereInFile = UPTO;
		betweenTypes = EXACT;
		beforeFileEnd = NONE;
		inFunction = EXACT;
		typeDefinition = NONE;

		beginClass = EXACT;
		endClass = NONE;
		afterClassStaticVars = EXACT;
		afterClassVars = EXACT;
		betweenClassStaticVars = UPTO;
		betweenClassVars = UPTO;
		betweenClassMethods = EXACT;

		beginAbstract = EXACT;
		endAbstract = NONE;
		afterAbstractVars = EXACT;
		betweenAbstractVars = UPTO;
		betweenAbstractMethods = EXACT;

		beginInterface = EXACT;
		endInterface = NONE;
		betweenInterfaceFields = EXACT;

		beginEnum = NONE;
		endEnum = NONE;
		betweenEnumFields = NONE;

		beginTypedef = NONE;
		endTypedef = NONE;
		betweenTypedefFields = NONE;

		afterSingleLineComment = NONE;
		afterMultiLineComment = NONE;

		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var emptyLines:ListOfEmptyLines = detectEmptyLines();
		if (max <= 0) max = 1;

		checkPackages(emptyLines);
		checkImports(emptyLines);
		checkTypes(emptyLines);

		checkFile(emptyLines);
		checkFunctions(emptyLines);
		checkComments(emptyLines);
	}

	function detectEmptyLines():ListOfEmptyLines {
		var emptyLines:ListOfEmptyLines = new ListOfEmptyLines();
		for (index in 0...checker.lines.length) {
			if (~/^\s*$/.match(checker.lines[index])) emptyLines.add(index);
		}
		return emptyLines;
	}

	function checkPackages(emptyLines:ListOfEmptyLines) {
		var root:TokenTree = checker.getTokenTree();
		var packages:Array<TokenTree> = root.filter([Kwd(KwdPackage)], ALL);

		for (pack in packages) {
			checkBetweenToken(emptyLines, null, pack, beforePackage, "before package");
			checkBetweenToken(emptyLines, pack, pack.nextSibling, afterPackage, "after package");
		}
	}

	function checkImports(emptyLines:ListOfEmptyLines) {
		var root:TokenTree = checker.getTokenTree();
		var imports:Array<TokenTree> = root.filter([Kwd(KwdImport), Kwd(KwdUsing)], ALL);

		if (imports.length <= 0) return;

		var lastImport:TokenTree = imports[imports.length - 1];
		if (lastImport.nextSibling != null) {
			checkBetweenToken(emptyLines, lastImport, lastImport.nextSibling, afterImports, "after imports/using");
		}

		for (index in 1...imports.length) {
			var imp:TokenTree = imports[index];
			if (imp.previousSibling == null) continue;
			if (imp.is(Kwd(KwdUsing)))  {
				if (imp.previousSibling.is(Kwd(KwdImport)))  {
					checkBetweenToken(emptyLines, imp.previousSibling, imp, beforeUsing, "betweeen import and using");
					continue;
				}
			}
			else {
				if (imp.previousSibling.is(Kwd(KwdUsing)))  {
					checkBetweenToken(emptyLines, imp.previousSibling, imp, beforeUsing, "betweeen import and using");
					continue;
				}
			}
			checkBetweenToken(emptyLines, imp.previousSibling, imp, betweenImports, "betweeen imports/using");
		}
	}

	function checkTypes(emptyLines:ListOfEmptyLines) {
		var root:TokenTree = checker.getTokenTree();
		var types:Array<TokenTree> = root.filter([
			Kwd(KwdAbstract),
			Kwd(KwdClass),
			Kwd(KwdEnum),
			Kwd(KwdInterface),
			Kwd(KwdTypedef)
		], ALL);

		if (types.length <= 0) return;

		for (index in 1...types.length) {
			var type:TokenTree = types[index];
			if (type.previousSibling == null) {
				continue;
			}
			var prevPos:Position = type.previousSibling.getPos();
			if (skipSingleLineTypes && (checker.getLinePos(prevPos.min).line - checker.getLinePos(prevPos.max).line == 0)) continue;

			var startLine:Int = checker.getLinePos(prevPos.max).line;
			var endLine:Int = checker.getLinePos(type.getPos().min).line;
			checkBetween(emptyLines, startLine, endLine, betweenTypes, "betweeen types");
		}

		for (type in types) {
			var pos:Position = type.getPos();
			if (skipSingleLineTypes && (checker.getLinePos(pos.min).line - checker.getLinePos(pos.max).line == 0)) continue;
			switch (type.tok) {
				case Kwd(KwdAbstract): checkAbstract(emptyLines, type);
				case Kwd(KwdClass): checkClass(emptyLines, type);
				case Kwd(KwdEnum):
					checkType(emptyLines, type, beginEnum, endEnum, function(child:TokenTree, next:TokenTree):PolicyAndWhat {
						return makePolicyAndWhat(betweenEnumFields, "between type fields");
					});
				case Kwd(KwdInterface):
					checkType(emptyLines, type, beginInterface, endInterface, function(child:TokenTree, next:TokenTree):PolicyAndWhat {
						return makePolicyAndWhat(betweenInterfaceFields, "between type fields");
					});
				case Kwd(KwdTypedef):
					checkType(emptyLines, type, beginTypedef, endTypedef, function(child:TokenTree, next:TokenTree):PolicyAndWhat {
						return makePolicyAndWhat(betweenTypedefFields, "between type fields");
					});
				default:
			}
		}
	}

	function checkAbstract(emptyLines:ListOfEmptyLines, typeToken:TokenTree) {
		checkType(emptyLines, typeToken, beginClass, endClass, function(child:TokenTree, next:TokenTree):PolicyAndWhat {
			var isFuncChild:Bool = child.is(Kwd(KwdFunction));
			var isVarChild:Bool = child.is(Kwd(KwdVar));
			var isFuncNext:Bool = next.is(Kwd(KwdFunction));
			var isVarNext:Bool = next.is(Kwd(KwdVar));

			if (isFuncChild && isFuncNext) return makePolicyAndWhat(betweenAbstractMethods, "between abstract funcitons");
			if (isVarChild && isFuncNext) return makePolicyAndWhat(afterAbstractVars, "after abstract vars");
			if (isFuncChild && isVarNext) return makePolicyAndWhat(afterAbstractVars, "after abstract vars");
			return makePolicyAndWhat(betweenAbstractVars, "between abstract vars");
		});
	}

	function checkClass(emptyLines:ListOfEmptyLines, typeToken:TokenTree) {
		checkType(emptyLines, typeToken, beginClass, endClass, function(child:TokenTree, next:TokenTree):PolicyAndWhat {
			var isFuncChild:Bool = child.is(Kwd(KwdFunction));
			var isVarChild:Bool = child.is(Kwd(KwdVar));
			var isFuncNext:Bool = next.is(Kwd(KwdFunction));
			var isVarNext:Bool = next.is(Kwd(KwdVar));

			if (isFuncChild && isFuncNext) return makePolicyAndWhat(betweenClassMethods, "between class methods");
			if (isVarChild && isFuncNext) return makePolicyAndWhat(afterClassVars, "after class vars");
			if (isFuncChild && isVarNext) return makePolicyAndWhat(afterClassVars, "after class vars");

			var isStaticChild:Bool = (child.filter([Kwd(KwdStatic)], FIRST).length > 0);
			var isStaticNext:Bool = (next.filter([Kwd(KwdStatic)], FIRST).length > 0);

			if (isStaticChild && isStaticNext) return makePolicyAndWhat(betweenClassStaticVars, "between class static vars");
			if (!isStaticChild && !isStaticNext) return makePolicyAndWhat(betweenClassVars, "between class vars");
			return makePolicyAndWhat(afterClassStaticVars, "after class static vars");
		});
	}

	function checkType(emptyLines:ListOfEmptyLines,
						typeToken:TokenTree,
						beginPolicy:EmptyLinesPolicy,
						endPolicy:EmptyLinesPolicy,
						fieldPolicyProvider:FieldPolicyProvider) {
		var brOpen = findTypeBrOpen(typeToken);
		if (brOpen == null) return;
		checkBetweenToken(emptyLines, typeToken, brOpen, typeDefinition, "between type definition and left curly");
		var brClose:TokenTree = brOpen.getLastChild();
		var start:Int = checker.getLinePos(brOpen.pos.max).line;
		var end:Int = checker.getLinePos(brClose.pos.min).line;
		if (start == end) return;
		checkLines(emptyLines, beginPolicy, start + 1, start + 1, "after left curly");
		checkLines(emptyLines, endPolicy, end - 1, end - 1, "before right curly");
		for (child in brOpen.children) {
			switch (child.tok) {
				case Comment(_):
				case CommentLine(_):
				case At:
				default:
					var next:TokenTree = child.nextSibling;
					if (next == null) continue;
					if (next.is(BrClose)) continue;
					var policyAndWhat:PolicyAndWhat = fieldPolicyProvider(child, next);
					if (policyAndWhat == null) continue;
					checkBetweenFullToken(emptyLines, child, next, policyAndWhat.policy, policyAndWhat.whatMsg);
			}
		}
	}

	function findTypeBrOpen(parent:TokenTree):TokenTree {
		if (parent == null) return null;
		var brOpens:Array<TokenTree> = parent.filterCallback(function (tok:TokenTree, depth:Int):FilterResult {
			return switch (tok.tok) {
				case BrOpen: FOUND_SKIP_SUBTREE;
				default: GO_DEEPER;
			}
		});
		if (brOpens.length <= 0) return null;
		return brOpens[0];
	}

	function checkFile(emptyLines:ListOfEmptyLines) {
		var ranges:Array<EmptyLineRange> = emptyLines.getRanges(0, checker.lines.length);
		for (range in ranges) {
			var line:Int = 0;
			switch (range) {
				case NONE:
				case SINGLE(l): line = l;
				case RANGE(start, end): line = end;
			}
			var result:EmptyLineRange = emptyLines.checkRange(anywhereInFile, max, range, line);
			logEmptyRange(anywhereInFile, "anywhere in file", result);
		}

		var range:EmptyLineRange = NONE;
		if (ranges.length >= 0) {
			var lastRange:EmptyLineRange = ranges[ranges.length - 1];
			switch (lastRange) {
				case NONE:
				case SINGLE(line):
					if (line == checker.lines.length - 1) range = lastRange;
				case RANGE(start, end):
					if (end == checker.lines.length - 1) range = lastRange;
			}
			var result:EmptyLineRange = emptyLines.checkRange(beforeFileEnd, max, range, checker.lines.length - 1);
			logEmptyRange(beforeFileEnd, "before file end", result);
		}
	}

	function checkFunctions(emptyLines:ListOfEmptyLines) {
		var root:TokenTree = checker.getTokenTree();
		var funcs:Array<TokenTree> = root.filter([Kwd(KwdFunction)], ALL);

		if (funcs.length <= 0) return;

		for (func in funcs) {
			var pos:Position = func.getPos();
			var start:Int = checker.getLinePos(pos.min).line;
			var end:Int = checker.getLinePos(pos.max).line;

			var ranges:Array<EmptyLineRange> = emptyLines.getRanges(start, end);
			for (range in ranges) {
				var result:EmptyLineRange = emptyLines.checkRange(inFunction, max, range, end);
				logEmptyRange(inFunction, "inside functions", result);
			}
		}
	}

	function checkComments(emptyLines:ListOfEmptyLines) {
		if ((afterMultiLineComment == IGNORE) && (afterSingleLineComment == IGNORE)) return;

		var root:TokenTree = checker.getTokenTree();
		var comments:Array<TokenTree> = root.filterCallback(function (tok:TokenTree, depth:Int):FilterResult {
			return switch (tok.tok) {
				case Comment(_): FOUND_SKIP_SUBTREE;
				case CommentLine(_): FOUND_SKIP_SUBTREE;
				default: GO_DEEPER;
			}
		});
		for (comment in comments) {
			var line:Int = checker.getLinePos(comment.pos.min).line;
			if (!~/^\s*(\/\/|\/\*)/.match(checker.lines[line])) continue;
			line = checker.getLinePos(comment.getPos().max).line + 1;
			switch (comment.tok) {
				case Comment(_):
					checkLines(emptyLines, afterMultiLineComment, line, line, "after comment");
				case CommentLine(_):
					checkLines(emptyLines, afterSingleLineComment, line, line, "after comment");
				default:
			}
		}
	}

	function checkLines(emptyLines:ListOfEmptyLines, policy:EmptyLinesPolicy, start:Int, end:Int, whatMsg:String) {
		var ranges:Array<EmptyLineRange> = emptyLines.getRanges(start, end);
		if (ranges.length <= 0) ranges = [NONE];
		for (range in ranges) {
			var result:EmptyLineRange = emptyLines.checkRange(policy, max, range, end);
			logEmptyRange(policy, whatMsg, result);
		}
	}

	function checkBetweenFullToken(emptyLines:ListOfEmptyLines, firstToken:TokenTree, secondToken:TokenTree, policy:EmptyLinesPolicy, whatMsg:String) {
		var lineStart:Int = 0;
		var lineEnd:Int = checker.lines.length;
		if (firstToken != null) {
			lineStart = checker.getLinePos(firstToken.getPos().max).line;
		}
		if (secondToken != null) {
			lineEnd = checker.getLinePos(secondToken.getPos().min).line;
		}
		checkBetween(emptyLines, lineStart, lineEnd, policy, whatMsg);
	}

	function checkBetweenToken(emptyLines:ListOfEmptyLines, firstToken:TokenTree, secondToken:TokenTree, policy:EmptyLinesPolicy, whatMsg:String) {
		var lineStart:Int = 0;
		var lineEnd:Int = checker.lines.length;
		if (firstToken != null) {
			lineStart = checker.getLinePos(firstToken.pos.max).line;
		}
		if (secondToken != null) {
			lineEnd = checker.getLinePos(secondToken.pos.min).line;
		}
		checkBetween(emptyLines, lineStart, lineEnd, policy, whatMsg);
	}

	function checkBetween(emptyLines:ListOfEmptyLines, lineStart:Int, lineEnd:Int, policy:EmptyLinesPolicy, whatMsg:String) {
		if (lineStart < 0) lineStart = 0;
		if (lineEnd < 0) lineEnd = checker.lines.length;
		var result:EmptyLineRange = emptyLines.checkPolicySingleRange(policy, max, lineStart, lineEnd);
		logEmptyRange(policy, whatMsg, result);
	}

	function makePolicyAndWhat(policy:EmptyLinesPolicy, whatMsg:String):PolicyAndWhat {
		return {
			policy: policy,
			whatMsg: whatMsg
		};
	}

	function logEmptyRange(policy:EmptyLinesPolicy, whatMsg:String, range:EmptyLineRange) {
		switch (range) {
			case NONE:
			case SINGLE(line):
				if (isLineSuppressed(line)) return;
				log(formatMessage(policy, whatMsg), line + 1, 0);
			case RANGE(start, end):
				if (isLineSuppressed(start)) return;
				var length:Int = checker.linesIdx[end].r - checker.linesIdx[start].l;
				log(formatMessage(policy, whatMsg), start + 1, 0, length);
		}
	}

	function formatMessage(policy:EmptyLinesPolicy, what:String):String {
		var line:String = "lines";
		if (max == 1) line = "line";
		return switch (policy) {
			case IGNORE: "ignored empty lines " + what;
			case NONE: "should not have empty line(s) " + what;
			case EXACT: 'should have exactly $max empty $line $what';
			case UPTO: 'should have upto $max empty $line $what';
			case ATLEAST: 'should have at least $max empty $line $what';
		}
	}

	override public function detectableInstances():DetectableInstances {
		var instances:DetectableInstances = [{
			fixed: [{
				propertyName: "max",
				value: 1
			}],
			properties: [{
				"propertyName": "skipSingleLineTypes",
				"values": [false, true]
			}]
		}];

		var props:Array<String> = [
			"beforePackage", "afterPackage", "betweenImports", "beforeUsing", "afterImports",
			"anywhereInFile", "betweenTypes", "beforeFileEnd", "inFunction", "typeDefinition",
			"beginClass", "endClass", "afterClassStaticVars", "afterClassVars", "betweenClassStaticVars",
			"betweenClassVars", "betweenClassMethods", "beginAbstract", "endAbstract",
			"afterAbstractVars", "betweenAbstractVars", "betweenAbstractMethods", "beginInterface",
			"endInterface", "betweenInterfaceFields", "beginEnum", "endEnum", "betweenEnumFields",
			"beginTypedef", "endTypedef", "betweenTypedefFields", "afterSingleLineComment",
			"afterMultiLineComment"
		];

		for (prop in props) {
			instances[0].properties.push({
				propertyName: prop,
				values: ["none", "exact", "upto", "atleast", "ignore"]
			});
		}
		return instances;
	}
}

typedef FieldPolicyProvider = TokenTree -> TokenTree -> PolicyAndWhat;

typedef PolicyAndWhat = {
	var policy:EmptyLinesPolicy;
	var whatMsg:String;
}

@:enum
abstract EmptyLinesPolicy(String) {
	var IGNORE = "ignore";
	var NONE = "none";
	var EXACT = "exact";
	var UPTO = "upto";
	var ATLEAST = "atleast";
}