package checkstyle.checks.whitespace;

import checkstyle.checks.whitespace.ListOfEmptyLines.EmptyLineRange;

/**
	Checks for consecutive empty lines.
**/ @name("ExtendedEmptyLines")
@desc("Checks for consecutive empty lines.")
class ExtendedEmptyLinesCheck extends Check {
	/**
		number of empty lines to allow / enforce (used by "exact", "upto" and "atleast" policies)
	**/
	public var max:Int;

	/**
		skips single line type definitions
	**/
	public var skipSingleLineTypes:Bool;

	/**
		"defaultPolicy" applies to all places not in "ignore", "none", "exact", "upto" or "atleast"
	**/
	public var defaultPolicy:EmptyLinesPolicy;

	/**
		list of places to ignore
	**/
	public var ignore:Array<EmptyLinesPlace>;

	/**
		list of places where no empty line is permitted
	**/
	public var none:Array<EmptyLinesPlace>;

	/**
		list of places where exactly "max" empty lines are required
	**/
	public var exact:Array<EmptyLinesPlace>;

	/**
		list of places where up to "max" empty lines are permitted
	**/
	public var upto:Array<EmptyLinesPlace>;

	/**
		list of places where at least "max" empty lines are required
	**/
	public var atleast:Array<EmptyLinesPlace>;

	var placemap:Map<EmptyLinesPlace, EmptyLinesPolicy>;

	public function new() {
		super(TOKEN);
		max = 1;
		skipSingleLineTypes = true;

		defaultPolicy = UPTO;
		ignore = [];
		none = [];
		exact = [];
		upto = [];
		atleast = [];

		categories = [Category.STYLE, Category.CLARITY];
	}

	function buildPolicyMap() {
		placemap = new Map<EmptyLinesPlace, EmptyLinesPolicy>();
		for (place in ignore) placemap.set(place, IGNORE);
		for (place in none) placemap.set(place, NONE);
		for (place in exact) placemap.set(place, EXACT);
		for (place in upto) placemap.set(place, UPTO);
		for (place in atleast) placemap.set(place, ATLEAST);
	}

	function getPolicy(place:EmptyLinesPlace):EmptyLinesPolicy {
		if (placemap.exists(place)) return placemap.get(place);
		return defaultPolicy;
	}

	function isIgnored(places:Array<EmptyLinesPlace>):Bool {
		for (place in places) {
			if (getPolicy(place) != IGNORE) return false;
		}
		return true;
	}

	override function actualRun() {
		buildPolicyMap();
		var emptyLines:ListOfEmptyLines = ListOfEmptyLines.detectEmptyLines(checker);
		if (max <= 0) max = 1;
		checkPackages(emptyLines);
		checkImports(emptyLines);
		checkTypes(emptyLines);

		checkFile(emptyLines);
		checkFunctions(emptyLines);
		checkComments(emptyLines);
	}

	function checkPackages(emptyLines:ListOfEmptyLines) {
		if (isIgnored([BEFORE_PACKAGE, AFTER_PACKAGE])) return;

		var root:TokenTree = checker.getTokenTree();
		var packages:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdPackage):
					FoundSkipSubtree;
				case Kwd(_):
					SkipSubtree;
				default:
					GoDeeper;
			}
		});

		for (pack in packages) {
			checkBetweenToken(emptyLines, null, pack, getPolicy(BEFORE_PACKAGE), "before package");
			checkBetweenToken(emptyLines, pack, pack.nextSibling, getPolicy(AFTER_PACKAGE), "after package");
		}
	}

	function checkImports(emptyLines:ListOfEmptyLines) {
		if (isIgnored([AFTER_IMPORTS, BEFORE_USING, BETWEEN_IMPORTS])) return;

		var root:TokenTree = checker.getTokenTree();
		var imports:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdImport) | Kwd(KwdUsing):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});

		if (imports.length <= 0) return;

		var lastImport:TokenTree = imports[imports.length - 1];
		if (lastImport.nextSibling != null) {
			switch (lastImport.nextSibling.tok) {
				case Kwd(KwdAbstract), Kwd(KwdClass), Kwd(KwdEnum), Kwd(KwdInterface), Kwd(KwdTypedef):
					checkBetweenToken(emptyLines, lastImport, lastImport.nextSibling, getPolicy(AFTER_IMPORTS), "after imports/using");
				default:
			}
		}

		for (index in 1...imports.length) {
			var imp:TokenTree = imports[index];
			var prev:TokenTree = imp.previousSibling;
			if (prev == null) continue;
			if (imp.matches(Kwd(KwdUsing))) {
				if (prev.matches(Kwd(KwdImport))) {
					checkBetweenToken(emptyLines, prev, imp, getPolicy(BEFORE_USING), "between import and using");
					continue;
				}
			}
			else {
				if (prev.matches(Kwd(KwdUsing))) {
					checkBetweenToken(emptyLines, prev, imp, getPolicy(BEFORE_USING), "between import and using");
					continue;
				}
			}
			switch (prev.tok) {
				case Kwd(KwdImport), Kwd(KwdUsing), Comment(_), CommentLine(_):
					checkBetweenToken(emptyLines, prev, imp, getPolicy(BETWEEN_IMPORTS), "between imports/using");
				default:
			}
		}
	}

	function checkTypes(emptyLines:ListOfEmptyLines) {
		var root:TokenTree = checker.getTokenTree();
		var types:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdAbstract) | Kwd(KwdClass) | Kwd(KwdEnum) | Kwd(KwdInterface) | Kwd(KwdTypedef):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});

		if (types.length <= 0) return;

		checkBetweenTypes(emptyLines, types);
		for (type in types) {
			var pos:Position = type.getPos();
			if (skipSingleLineTypes && (checker.getLinePos(pos.min).line - checker.getLinePos(pos.max).line == 0)) continue;
			switch (type.tok) {
				case Kwd(KwdAbstract):
					checkAbstract(emptyLines, type);
				case Kwd(KwdClass):
					checkClass(emptyLines, type);
				case Kwd(KwdEnum):
					if (isIgnored([BEGIN_ENUM, END_ENUM, BETWEEN_ENUM_FIELDS, TYPE_DEFINITION])) continue;
					checkType(emptyLines, type, getPolicy(BEGIN_ENUM), getPolicy(END_ENUM), function(child:TokenTree, next:TokenTree):PolicyAndWhat {
						if (hasDocComment(child)) {
							return makePolicyAndWhat(getPolicy(AFTER_DOC_COMMENT_FIELD), "between type fields");
						}
						return makePolicyAndWhat(getPolicy(BETWEEN_ENUM_FIELDS), "between type fields");
					});
				case Kwd(KwdInterface):
					if (isIgnored([BEGIN_INTERFACE, END_INTERFACE, BETWEEN_INTERFACE_FIELDS, TYPE_DEFINITION])) continue;
					checkType(emptyLines, type, getPolicy(BEGIN_INTERFACE), getPolicy(END_INTERFACE), function(child:TokenTree, next:TokenTree):PolicyAndWhat {
						if (hasDocComment(child)) {
							return makePolicyAndWhat(getPolicy(AFTER_DOC_COMMENT_FIELD), "between type fields");
						}
						return makePolicyAndWhat(getPolicy(BETWEEN_INTERFACE_FIELDS), "between type fields");
					});
				case Kwd(KwdTypedef):
					if (isIgnored([BEGIN_TYPEDEF, END_TYPEDEF, BETWEEN_TYPEDEF_FIELDS, TYPE_DEFINITION])) continue;
					checkType(emptyLines, type, getPolicy(BEGIN_TYPEDEF), getPolicy(END_TYPEDEF), function(child:TokenTree, next:TokenTree):PolicyAndWhat {
						if (hasDocComment(child)) {
							return makePolicyAndWhat(getPolicy(AFTER_DOC_COMMENT_FIELD), "between type fields");
						}
						return makePolicyAndWhat(getPolicy(BETWEEN_TYPEDEF_FIELDS), "between type fields");
					});
				default:
			}
		}
	}

	function hasDocComment(token:TokenTree):Bool {
		var docToken:TokenTree = TokenTreeCheckUtils.getDocComment(token);
		return (docToken != null);
	}

	function checkBetweenTypes(emptyLines:ListOfEmptyLines, types:Array<TokenTree>) {
		if (isIgnored([BETWEEN_TYPES])) return;
		for (index in 1...types.length) {
			var type:TokenTree = types[index];
			var sibling:TokenTree = type.previousSibling;
			var prevType:TokenTree = types[index - 1];
			if (sibling == null) {
				continue;
			}
			if (sibling != prevType) {
				switch (sibling.tok) {
					case Comment(_):
						type = sibling;
					case CommentLine(_):
						type = sibling;
					case Sharp(_):
						continue;
					default:
				}
			}
			var prevPos:Position = prevType.getPos();
			if (skipSingleLineTypes && (checker.getLinePos(prevPos.min).line - checker.getLinePos(prevPos.max).line == 0)) continue;
			var startLine:Int = checker.getLinePos(prevPos.max).line;
			var endLine:Int = checker.getLinePos(type.getPos().min).line;
			checkBetween(emptyLines, startLine, endLine, getPolicy(BETWEEN_TYPES), "between types");
		}
	}

	function checkAbstract(emptyLines:ListOfEmptyLines, typeToken:TokenTree) {
		if (isIgnored([
			BEGIN_ABSTRACT,
			END_ABSTRACT,
			BETWEEN_ABSTRACT_METHODS,
			AFTER_ABSTRACT_VARS,
			BETWEEN_ABSTRACT_VARS,
			TYPE_DEFINITION
		])) {
			return;
		}

		checkType(emptyLines, typeToken, getPolicy(BEGIN_ABSTRACT), getPolicy(END_ABSTRACT), function(child:TokenTree, next:TokenTree):PolicyAndWhat {
			if (hasDocComment(child)) {
				return makePolicyAndWhat(getPolicy(AFTER_DOC_COMMENT_FIELD), "between type fields");
			}
			var isFuncChild:Bool = child.matches(Kwd(KwdFunction));
			var isVarChild:Bool = child.matches(Kwd(KwdVar));
			if (!isVarChild && !isFuncChild) return null;
			var type:EmptyLinesFieldType = detectNextFieldType(next);
			if (type == OTHER) return null;
			if (isFuncChild && (type == FUNCTION)) return makePolicyAndWhat(getPolicy(BETWEEN_ABSTRACT_METHODS), "between abstract functions");
			if (isVarChild && (type == FUNCTION)) return makePolicyAndWhat(getPolicy(AFTER_ABSTRACT_VARS), "after abstract vars");
			if (isFuncChild && (type == VAR)) return makePolicyAndWhat(getPolicy(AFTER_ABSTRACT_VARS), "after abstract vars");
			return makePolicyAndWhat(getPolicy(BETWEEN_ABSTRACT_VARS), "between abstract vars");
		});
	}

	function checkClass(emptyLines:ListOfEmptyLines, typeToken:TokenTree) {
		var places:Array<EmptyLinesPlace> = [
			BEGIN_CLASS,
			END_CLASS,
			BETWEEN_CLASS_METHODS,
			AFTER_CLASS_VARS,
			BETWEEN_CLASS_STATIC_VARS,
			BETWEEN_CLASS_VARS,
			AFTER_CLASS_STATIC_VARS,
			TYPE_DEFINITION
		];
		if (isIgnored(places)) return;

		checkType(emptyLines, typeToken, getPolicy(BEGIN_CLASS), getPolicy(END_CLASS), function(child:TokenTree, next:TokenTree):PolicyAndWhat {
			if (hasDocComment(child)) {
				return makePolicyAndWhat(getPolicy(AFTER_DOC_COMMENT_FIELD), "between type fields");
			}
			while (next != null) {
				if (!next.isComment()) break;
				next = next.nextSibling;
			}
			if (next == null) return null;

			var isFuncChild:Bool = child.matches(Kwd(KwdFunction));
			var isVarChild:Bool = child.matches(Kwd(KwdVar));
			if (!isVarChild && !isFuncChild) return null;
			var type:EmptyLinesFieldType = detectNextFieldType(next);
			if (type == OTHER) return null;
			if (isFuncChild && (type == FUNCTION)) return makePolicyAndWhat(getPolicy(BETWEEN_CLASS_METHODS), "between class methods");
			if (isVarChild && (type == FUNCTION)) return makePolicyAndWhat(getPolicy(AFTER_CLASS_VARS), "after class vars");
			if (isFuncChild && (type == VAR)) return makePolicyAndWhat(getPolicy(AFTER_CLASS_VARS), "after class vars");

			var isStaticChild:Bool = (child.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
				return switch (token.tok) {
					case Kwd(KwdStatic):
						FoundSkipSubtree;
					default:
						GoDeeper;
				}
			}).length > 0);
			var isStaticNext:Bool = (next.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
				return switch (token.tok) {
					case Kwd(KwdStatic):
						FoundSkipSubtree;
					default:
						GoDeeper;
				}
			}).length > 0);

			if (isStaticChild && isStaticNext) return makePolicyAndWhat(getPolicy(BETWEEN_CLASS_STATIC_VARS), "between class static vars");
			if (!isStaticChild && !isStaticNext) return makePolicyAndWhat(getPolicy(BETWEEN_CLASS_VARS), "between class vars");
			return makePolicyAndWhat(getPolicy(AFTER_CLASS_STATIC_VARS), "after class static vars");
		});
	}

	function detectNextFieldType(field:TokenTree):EmptyLinesFieldType {
		if (field.matches(Kwd(KwdFunction))) return FUNCTION;
		if (field.matches(Kwd(KwdVar))) return VAR;
		if (!field.isComment()) return OTHER;

		var after:TokenTree = field.nextSibling;
		while (after != null) {
			if (after.matches(Kwd(KwdFunction))) return FUNCTION;
			if (after.matches(Kwd(KwdVar))) return VAR;
			if (after.isComment()) {
				after = after.nextSibling;
				continue;
			}
			return OTHER;
		}
		return OTHER;
	}

	function checkType(emptyLines:ListOfEmptyLines, typeToken:TokenTree, beginPolicy:EmptyLinesPolicy, endPolicy:EmptyLinesPolicy,
			fieldPolicyProvider:FieldPolicyProvider) {
		var brOpen = findTypeBrOpen(typeToken);
		if (brOpen == null) return;
		checkBetweenToken(emptyLines, typeToken, brOpen, getPolicy(TYPE_DEFINITION), "between type definition and left curly");
		var brClose:Null<TokenTree> = brOpen.getLastChild();
		if (brClose == null) return;
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
					switch (next.tok) {
						case BrClose:
							continue;
						case CommentLine(_):
							continue;
						case Comment(_):
							continue;
						default:
					}
					var policyAndWhat:PolicyAndWhat = fieldPolicyProvider(child, next);
					if (policyAndWhat == null) continue;
					checkBetweenFullToken(emptyLines, child, next, policyAndWhat.policy, policyAndWhat.whatMsg);
			}
		}
	}

	function findTypeBrOpen(parent:TokenTree):TokenTree {
		if (parent == null) return null;
		var brOpens:Array<TokenTree> = parent.filterCallback(function(tok:TokenTree, depth:Int):FilterResult {
			return switch (tok.tok) {
				case BrOpen: FoundSkipSubtree;
				default: GoDeeper;
			}
		});
		if (brOpens.length <= 0) return null;
		return brOpens[0];
	}

	function checkFile(emptyLines:ListOfEmptyLines) {
		if (isIgnored([ANYWHERE_IN_FILE, BEFORE_FILE_END])) return;

		var ranges:Array<EmptyLineRange> = emptyLines.getRanges(0, checker.lines.length);
		for (range in ranges) {
			var line:Int = 0;
			switch (range) {
				case NONE:
				case SINGLE(l):
					line = l;
				case RANGE(start, end):
					line = end;
			}
			var result:EmptyLineRange = emptyLines.checkRange(getPolicy(ANYWHERE_IN_FILE), max, range, line);
			logEmptyRange(getPolicy(ANYWHERE_IN_FILE), "anywhere in file", result);
		}

		var range:EmptyLineRange = NONE;
		if (ranges.length > 0) {
			var lastRange:EmptyLineRange = ranges[ranges.length - 1];
			switch (lastRange) {
				case NONE:
				case SINGLE(line):
					if (line == checker.lines.length - 1) range = lastRange;
				case RANGE(start, end):
					if (end == checker.lines.length - 1) range = lastRange;
			}
		}
		var result:EmptyLineRange = emptyLines.checkRange(getPolicy(BEFORE_FILE_END), max, range, checker.lines.length - 1);
		logEmptyRange(getPolicy(BEFORE_FILE_END), "before file end", result);
	}

	function checkFunctions(emptyLines:ListOfEmptyLines) {
		if (isIgnored([IN_FUNCTION, AFTER_LEFT_CURLY, BEFORE_RIGHT_CURLY])) return;

		var root:TokenTree = checker.getTokenTree();
		var funcs:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdFunction):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		if (funcs.length <= 0) return;

		for (func in funcs) {
			var pos:Position = func.getPos();
			var start:Int = checker.getLinePos(pos.min).line;
			var end:Int = checker.getLinePos(pos.max).line;
			checkLines(emptyLines, getPolicy(IN_FUNCTION), start, end, "inside functions", true);

			var brOpen:Array<TokenTree> = func.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
				return switch (token.tok) {
					case BrOpen:
						FoundGoDeeper;
					default:
						GoDeeper;
				}
			});
			for (open in brOpen) {
				var close:TokenTree = open.getLastChild();
				if (close == null) continue;
				var start:Int = checker.getLinePos(open.pos.max).line;
				var end:Int = checker.getLinePos(close.pos.min).line;
				if (start == end) continue;
				checkLines(emptyLines, getPolicy(AFTER_LEFT_CURLY), start + 1, start + 1, "after left curly");
				checkLines(emptyLines, getPolicy(BEFORE_RIGHT_CURLY), end - 1, end - 1, "before right curly");
			}
		}
	}

	function checkComments(emptyLines:ListOfEmptyLines) {
		if (isIgnored([
			AFTER_MULTILINE_COMMENT,
			AFTER_SINGLELINE_COMMENT,
			BEFORE_MULTILINE_COMMENT,
			BEFORE_SINGLELINE_COMMENT
		])) {
			return;
		}

		var root:TokenTree = checker.getTokenTree();
		var comments:Array<TokenTree> = root.filterCallback(function(tok:TokenTree, depth:Int):FilterResult {
			return switch (tok.tok) {
				case Comment(_): FoundSkipSubtree;
				case CommentLine(_): FoundSkipSubtree;
				default: GoDeeper;
			}
		});
		for (comment in comments) {
			var line:Int = checker.getLinePos(comment.pos.min).line;
			if (!~/^\s*(\/\/|\/\*)/.match(checker.lines[line])) continue;
			var prevLine:Int = checker.getLinePos(comment.getPos().min).line - 1;
			var nextLine:Int = checker.getLinePos(comment.getPos().max).line + 1;
			switch (comment.tok) {
				case Comment(_):
					if (checkPreviousSiblingComment(comment.previousSibling)) {
						checkLines(emptyLines, getPolicy(BEFORE_MULTILINE_COMMENT), prevLine, prevLine, "before comment");
					}
					if ((comment.nextSibling == null) || (!comment.nextSibling.isComment())) {
						checkLines(emptyLines, getPolicy(AFTER_MULTILINE_COMMENT), nextLine, nextLine, "after comment");
					}

				case CommentLine(_):
					if (checkPreviousSiblingComment(comment.previousSibling)) {
						checkLines(emptyLines, getPolicy(BEFORE_SINGLELINE_COMMENT), prevLine, prevLine, "before comment");
					}
					if ((comment.nextSibling == null) || (!comment.nextSibling.isComment())) {
						checkLines(emptyLines, getPolicy(AFTER_SINGLELINE_COMMENT), nextLine, nextLine, "after comment");
					}
				default:
			}
		}
	}

	function checkPreviousSiblingComment(token:TokenTree):Bool {
		if ((token == null) || (token.tok == Root)) {
			return false;
		}
		switch (token.tok) {
			case Comment(_), CommentLine(_):
				return false;
			case Sharp(_):
				return false;
			case POpen, Const(CIdent(_)):
				var parent:Null<TokenTree> = token.parent;
				if (parent != null) {
					switch (parent.tok) {
						case Sharp(_):
							return false;
						default:
					}
				}

			default:
		}
		return true;
	}

	function checkLines(emptyLines:ListOfEmptyLines, policy:EmptyLinesPolicy, start:Int, end:Int, whatMsg:String, tolerateEmptyRange:Bool = false) {
		var ranges:Array<EmptyLineRange> = emptyLines.getRanges(start, end);
		if (!tolerateEmptyRange && (ranges.length <= 0)) ranges = [NONE];
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
		if (range == null) return;
		switch (range) {
			case NONE:
			case SINGLE(line):
				if (isLineSuppressed(line)) return;
				log(formatMessage(policy, whatMsg), line + 1, 0, line + 1, 0);
			case RANGE(start, end):
				if (isLineSuppressed(start)) return;
				log(formatMessage(policy, whatMsg), start + 1, 0, end + 1, 0);
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
		return [{
			fixed: [{
				propertyName: "max",
				value: 1
			}],
			properties: [{
				"propertyName": "skipSingleLineTypes",
				"values": [false, true]
			}, {
				"propertyName": "defaultPolicy",
				"values": ["none", "exact", "upto", "atleast", "ignore"]
			}, {
				"propertyName": "none",
				"values": [[
					BEFORE_PACKAGE,
					BETWEEN_IMPORTS,
					BEFORE_USING,
					TYPE_DEFINITION,
					AFTER_LEFT_CURLY,
					BEFORE_RIGHT_CURLY
				]]
			}]
		}];
	}
}

typedef FieldPolicyProvider = TokenTree -> TokenTree -> PolicyAndWhat;

typedef PolicyAndWhat = {
	var policy:EmptyLinesPolicy;
	var whatMsg:String;
}

/**
	policy for empty lines
	- ignore = ignores all entries
	- none = no empty line permitted
	- exact = exactly "max" empty line(s) required
	- upto = up to "max" empty line(s) allowed (0 - "max")
	- atleast = at least "max" empty lines required
**/
enum abstract EmptyLinesPolicy(String) {
	var IGNORE = "ignore";
	var NONE = "none";
	var EXACT = "exact";
	var UPTO = "upto";
	var ATLEAST = "atleast";
}

enum EmptyLinesFieldType {
	VAR;
	FUNCTION;
	OTHER;
}

/**
	empty line check supports the following places
	- afterAbstractVars = after abstract var block
	- afterClassStaticVars = after static class var block
	- afterClassVars = after class var block
	- afterImports = after all imports/usings
	- afterLeftCurly = after left curly
	- afterMultiLineComment = after multi line comment
	- afterPackage = after package
	- afterSingleLineComment = after single line comment
	- anywhereInFile = anywhere in file
	- beforePackage = before package
	- beforeRightCurly = before right curly
	- beforeUsing = before using block
	- beginAbstract = after abstract left curly
	- beginClass = after class left curly
	- beginEnum = after enum left curly
	- beforeFileEnd = before EOF
	- beginInterface = after interface left curly
	- beginTypedef = after typedef left curly
	- betweenAbstractMethods = between abstract methods
	- betweenAbstractVars = between abstract vars
	- betweenClassMethods = between class methods
	- betweenClassStaticVars = between static class vars
	- betweenClassVars = between class vars
	- betweenEnumFields = between enum fields
	- betweenImports = between imports/usings
	- betweenInterfaceFields = between interface fields
	- betweenTypedefFields = between typedef fields
	- betweenTypes = betgween two types
	- endClass = before class right curly
	- endAbstract = before abstract right curly
	- endInterface = before interface right curly
	- endEnum = before enum right curly
	- endTypedef = before typedef right curly
	- inFunction = anywhere inside function body
	- typeDefinition = between type and left curly
**/
enum abstract EmptyLinesPlace(String) {
	var BEFORE_PACKAGE = "beforePackage";
	var AFTER_PACKAGE = "afterPackage";
	var BETWEEN_IMPORTS = "betweenImports";
	var BEFORE_USING = "beforeUsing";
	var AFTER_IMPORTS = "afterImports";
	var ANYWHERE_IN_FILE = "anywhereInFile";
	var BETWEEN_TYPES = "betweenTypes";
	var BEFORE_FILE_END = "beforeFileEnd";
	var IN_FUNCTION = "inFunction";
	var AFTER_LEFT_CURLY = "afterLeftCurly";
	var BEFORE_RIGHT_CURLY = "beforeRightCurly";
	var TYPE_DEFINITION = "typeDefinition";
	var BEGIN_CLASS = "beginClass";
	var END_CLASS = "endClass";
	var AFTER_CLASS_STATIC_VARS = "afterClassStaticVars";
	var AFTER_CLASS_VARS = "afterClassVars";
	var BETWEEN_CLASS_STATIC_VARS = "betweenClassStaticVars";
	var BETWEEN_CLASS_VARS = "betweenClassVars";
	var BETWEEN_CLASS_METHODS = "betweenClassMethods";
	var BEGIN_ABSTRACT = "beginAbstract";
	var END_ABSTRACT = "endAbstract";
	var AFTER_ABSTRACT_VARS = "afterAbstractVars";
	var BETWEEN_ABSTRACT_VARS = "betweenAbstractVars";
	var BETWEEN_ABSTRACT_METHODS = "betweenAbstractMethods";
	var BEGIN_INTERFACE = "beginInterface";
	var END_INTERFACE = "endInterface";
	var BETWEEN_INTERFACE_FIELDS = "betweenInterfaceFields";
	var BEGIN_ENUM = "beginEnum";
	var END_ENUM = "endEnum";
	var BETWEEN_ENUM_FIELDS = "betweenEnumFields";
	var BEGIN_TYPEDEF = "beginTypedef";
	var END_TYPEDEF = "endTypedef";
	var BETWEEN_TYPEDEF_FIELDS = "betweenTypedefFields";
	var AFTER_SINGLELINE_COMMENT = "afterSingleLineComment";
	var AFTER_MULTILINE_COMMENT = "afterMultiLineComment";
	var BEFORE_SINGLELINE_COMMENT = "beforeSingleLineComment";
	var BEFORE_MULTILINE_COMMENT = "beforeMultiLineComment";
	var AFTER_DOC_COMMENT_FIELD = "afterDocCommentField";
}