package checkstyle.checks.whitespace;

@name("Indentation")
@desc("Checks correct indentation")
class IndentationCheck extends Check {

	public var character:IndentationCheckCharacter;
	public var ignoreConditionals:Bool;
	public var conditionalPolicy:ConditionalIndentationPolicy;
	public var ignoreComments:Bool;
	public var wrapPolicy:WrappedIndentationPolicy;

	public function new() {
		super(TOKEN);
		character = TAB;
		ignoreConditionals = false;
		ignoreComments = true;
		wrapPolicy = LARGER;
		conditionalPolicy = ALIGNED;
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var lineIndentation:Array<Int> = calcLineIndentation();
		var wrappedStatements:Array<Bool> = calcWrapStatements();
		var tolerateViolations:Array<Bool> = calcIgnoreLineIndentation();

		var ignoreCond:Bool = ignoreConditionals;
		if (conditionalPolicy == IGNORE) ignoreCond = true;

		correctWrappedIndentation(lineIndentation, wrappedStatements);

		var splitChar:String = character;
		if (splitChar == TAB) splitChar = "\t";
		for (i in 0...checker.lines.length) {
			if (isLineSuppressed(i)) continue;
			var line:String = checker.lines[i];

			// skip empty lines
			if (~/^\s*$/.match(line)) continue;
			// skip conditionals
			if (ignoreCond && ~/^\s*#/.match(line)) continue;

			var e = ~/^(\s*)/;
			e.match(line);
			var matched:String = e.matched(0);
			var actual:Int = matched.split(splitChar).length - 1;
			var expected:Int = lineIndentation[i];
			logMsg(expected, actual, tolerateViolations[i], wrappedStatements[i], i);
		}
	}

	function logMsg(expected:Int, actual:Int, tolerate:Bool, wrapped:Bool, line:Int) {
		if (actual == expected) return;
		if (tolerate) return;
		if (wrapped) {
			switch (wrapPolicy) {
				case NONE:
				case EXACT:
				case LARGER:
					if (actual >= expected) return;
			}
		}
		var expectedText:String = buildReadableIndentCount(expected);
		var actualText:String = buildReadableIndentCount(actual);
		log('Indentation mismatch: expected: $expectedText, actual: $actualText', line + 1, 0);
	}

	function buildReadableIndentCount(count:Int):String {
		if (count == 0) return "no indentation";
		var indent:String = "";
		for (i in 0...count) {
			indent += character;
		}
		indent = indent.split("tab").join("\\t");
		return '"$indent"[$count]';
	}

	function correctWrappedIndentation(lineIndentation:Array<Int>, wrappedStatements:Array<Bool>) {
		if (wrapPolicy == NONE) return;
		var currentIndent:Int = 0;
		for (i in 0...lineIndentation.length) {
			if (!wrappedStatements[i]) {
				currentIndent = lineIndentation[i];
				continue;
			}
			if (currentIndent < lineIndentation[i]) {
				currentIndent = -1;
				continue;
			}
			if (currentIndent == lineIndentation[i]) {
				lineIndentation[i]++;
			}
		}
	}

	function calcLineIndentation():Array<Int> {
		var lineIndentation:Array<Int> = [for (i in 0...checker.lines.length) 0];

		var searchFor:Array<TokenDef> = [
			BrOpen,
			BkOpen,
			Sharp("if"),
			Sharp("else"),
			Sharp("elseif"),
			Sharp("end"),
			Sharp("error"),
			Kwd(KwdIf),
			Kwd(KwdElse),
			Kwd(KwdFor),
			Kwd(KwdDo),
			Kwd(KwdWhile),
			Kwd(KwdCase),
			Kwd(KwdDefault)
		];
		var tokenList:Array<TokenTree> = checker.getTokenTree().filter(searchFor, ALL);
		for (token in tokenList) {
			switch (token.tok) {
				case BkOpen:
					calcLineIndentationBkOpen(token, lineIndentation);
				case BrOpen:
					increaseBlockIndent(token, lineIndentation);
				case Kwd(KwdIf), Kwd(KwdElse):
					calcLineIndentationIf(token, lineIndentation);
				case Kwd(KwdFor), Kwd(KwdDo), Kwd(KwdWhile):
					calcLineIndentationLoops(token, lineIndentation);
				case Kwd(KwdCase):
					var child:TokenTree = token.getLastChild();
					if (child == null) continue;
					increaseRangeIndent(child.getPos(), lineIndentation);
				case Kwd(KwdDefault):
					var child:TokenTree = token.getLastChild();
					// getter/setter 'default' has no childs
					if (child == null) continue;
					increaseRangeIndent(child.getPos(), lineIndentation);
				case Sharp(_):
					calcLineIndentationSharp(token, lineIndentation);
				default:
			}
		}
		return lineIndentation;
	}

	function calcLineIndentationBkOpen(token:TokenTree, lineIndentation:Array<Int>) {
		var child:TokenTree = token.getFirstChild();
		if (child == null) return;
		if ((child.is(BrOpen)) || (child.is(BkOpen))) {
			// only indent once, if directly next to each other `[{`
			if (token.pos.min + 1 == child.pos.min) return;
		}
		increaseBlockIndent(token, lineIndentation);
	}

	function calcLineIndentationIf(token:TokenTree, lineIndentation:Array<Int>) {
		switch (token.tok) {
			case Kwd(KwdIf):
				var child:TokenTree = token.getLastChild();
				if (child == null) return;
				if (child.is(Kwd(KwdElse))) {
					child = token.children[token.children.length - 2];
				}
				if (child.is(BrOpen)) return;
				increaseIndentIfNextLine(token, child, lineIndentation);
			case Kwd(KwdElse):
				var child:TokenTree = token.getFirstChild();
				if (child == null) return;
				if (child.is(BrOpen)) return;
				increaseIndentIfNextLine(token, child, lineIndentation);
			default:
		}
	}

	function calcLineIndentationSharp(token:TokenTree, lineIndentation:Array<Int>) {

		var linePos:LinePos = checker.getLinePos(token.pos.min);
		var line:String = checker.lines[linePos.line];
		var prefix:String = line.substr(0, linePos.ofs + 1);
		var isFirst:Bool = ~/^\s*#$/.match(prefix);

		switch (conditionalPolicy) {
			case IGNORE: return;
			case FIXED_ZERO:
				if (!isFirst) return;
				lineIndentation[linePos.line] = 0;
				return;
			case ALIGNED: return;
			case ALIGNED_INCREASE:
		}

		switch (token.tok) {
			case Sharp("if"), Sharp("else"), Sharp("elseif"):
				for (child in token.children) {
					switch (child.tok) {
						case Sharp(_):
							increaseIndentBetween(token, child, lineIndentation);
							return;
						default:
					}
				}
			case Sharp("end"):
			case Sharp("error"):
			default:
		}
	}

	function calcLineIndentationLoops(token:TokenTree, lineIndentation:Array<Int>) {
		switch (token.tok) {
			case Kwd(KwdFor):
				var child:TokenTree = token.getLastChild();
				if (child == null) return;
				if (child.is(BrOpen)) return;
				increaseIndentIfNextLine(token, child, lineIndentation);
			case Kwd(KwdDo):
				var child:TokenTree = token.getFirstChild();
				if (child == null) return;
				if (child.is(BrOpen)) return;
				increaseIndentIfNextLine(token, child, lineIndentation);
			case Kwd(KwdWhile):
				var child:TokenTree = token.getLastChild();
				if (child == null) return;
				if (child.is(BrOpen)) return;
				increaseIndentIfNextLine(token, child, lineIndentation);
			default:
		}
	}

	function calcWrapStatements():Array<Bool> {
		var wrapped:Array<Bool> = [for (i in 0...checker.lines.length) false];

		var searchFor:Array<TokenDef> = [
			POpen,
			Dot,
			Kwd(KwdReturn),
			Kwd(KwdCase),
			Binop(OpAssign),
			Binop(OpAssignOp(OpShr)),
			Binop(OpAssignOp(OpAdd)),
			Binop(OpAssignOp(OpSub)),
			Binop(OpAssignOp(OpMult)),
			Binop(OpAssignOp(OpDiv)),
			Binop(OpAssignOp(OpMod)),
			Binop(OpAssignOp(OpShl)),
			Binop(OpAssignOp(OpShr)),
			Binop(OpAssignOp(OpUShr)),
			Binop(OpAssignOp(OpOr)),
			Binop(OpAssignOp(OpAnd)),
			Binop(OpAssignOp(OpXor))
		];
		var tokenList:Array<TokenTree> = checker.getTokenTree().filter(searchFor, ALL);
		for (token in tokenList) {
			var pos = token.getPos();
			var child:TokenTree = token.getFirstChild();
			if (child == null) continue;
			if (token.is(Dot)) pos = token.parent.getPos();
			if (child.is(BkOpen)) continue;
			ignoreRange(pos, wrapped);
		}
		return wrapped;
	}

	function calcIgnoreLineIndentation():Array<Bool> {
		var ignoreIndentation:Array<Bool> = [for (i in 0...checker.lines.length) false];

		var tokenList:Array<TokenTree> = checker.getTokenTree().filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (token.tok == null) return GO_DEEPER;
			return switch (token.tok) {
				case Comment(_): FOUND_SKIP_SUBTREE;
				case CommentLine(_): FOUND_SKIP_SUBTREE;
				case Const(CString(_)): FOUND_SKIP_SUBTREE;
				default: GO_DEEPER;
			}
		});
		for (token in tokenList) {
			switch (token.tok) {
				case Const(CString(_)):
					ignoreRange(token.getPos(), ignoreIndentation);
				case Comment(_):
					if (ignoreComments) ignoreRange(token.getPos(), ignoreIndentation, false);
				case CommentLine(_):
					if (!ignoreComments) continue;
					var lineIndex:Int = checker.getLinePos(token.pos.min).line;
					var line:String = checker.lines[lineIndex];
					if (~/^\s*\/\//.match(line)) ignoreIndentation[lineIndex] = true;
				default:
			}
		}
		return ignoreIndentation;
	}

	function increaseBlockIndent(blockStart:TokenTree, lineIndentation:Array<Int>) {
		increaseIndentBetween(blockStart, blockStart.getLastChild(), lineIndentation);
	}

	function increaseIndentBetween(blockStart:TokenTree, blockEnd:TokenTree, lineIndentation:Array<Int>) {
		if (blockEnd == null) return;
		var start:Int = checker.getLinePos(blockStart.pos.min).line + 1;
		var end:Int = checker.getLinePos(blockEnd.pos.min).line;
		increaseIndent(lineIndentation, start, end);
	}

	function increaseRangeIndent(pos:Position, lineIndentation:Array<Int>) {
		var start:Int = checker.getLinePos(pos.min).line + 1;
		var end:Int = checker.getLinePos(pos.max).line + 1;
		increaseIndent(lineIndentation, start, end);
	}

	function increaseIndentIfNextLine(parent:TokenTree, child:TokenTree, lineIndentation:Array<Int>) {
		if (child == null) return;
		var parentLine:Int = checker.getLinePos(parent.pos.min).line;
		var childLine:Int = checker.getLinePos(child.pos.min).line;
		if (parentLine == childLine) return;
		lineIndentation[childLine]++;
	}

	function ignoreRange(pos:Position, ignoreIndentation:Array<Bool>, excludeStartLine:Bool = true) {
		var start:Int = checker.getLinePos(pos.min).line;
		if (excludeStartLine) start++;
		var end:Int = checker.getLinePos(pos.max).line + 1;
		for (i in start...end) ignoreIndentation[i] = true;
	}

	function increaseIndent(lineIndentation:Array<Int>, start:Int, end:Int) {
		for (i in start...end) lineIndentation[i]++;
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "character",
				values: [
					TAB,
					EIGHT_SPACES,
					SEVEN_SPACES,
					SIX_SPACES,
					FIVE_SPACES,
					FOUR_SPACES,
					THREE_SPACES,
					TWO_SPACES,
					ONE_SPACE
				]
			},
			{
				propertyName: "conditionalPolicy",
				values: [FIXED_ZERO, ALIGNED, ALIGNED_INCREASE, IGNORE]
			},
			{
				propertyName: "ignoreConditionals",
				values: [true, false]
			},
			{
				propertyName: "ignoreComments",
				values: [true, false]
			},
			{
				propertyName: "wrapPolicy",
				values: [NONE, LARGER, EXACT]
			}]
		}];
	}
}

@:enum
abstract WrappedIndentationPolicy(String) {
	var NONE = "none";
	var EXACT = "exact";
	var LARGER = "larger";
}

@:enum
abstract ConditionalIndentationPolicy(String) {
	var IGNORE = "ignore";
	var FIXED_ZERO = "fixed_zero";
	var ALIGNED = "aligned";
	var ALIGNED_INCREASE = "aligned_increase";
}

@:enum
abstract IndentationCheckCharacter(String) to String {
	var TAB = "tab";
	var ONE_SPACE = " ";
	var TWO_SPACES = "  ";
	var THREE_SPACES = "   ";
	var FOUR_SPACES = "    ";
	var FIVE_SPACES = "     ";
	var SIX_SPACES = "      ";
	var SEVEN_SPACES = "       ";
	var EIGHT_SPACES = "        ";
}