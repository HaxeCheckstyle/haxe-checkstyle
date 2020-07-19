package checkstyle.checks.size;

import checkstyle.checks.whitespace.ListOfEmptyLines;
import checkstyle.utils.PosHelper;

/**
	Checks for long methods. If a method becomes very long it is hard to understand.
	Therefore long methods should usually be refactored into several individual methods that focus on a specific task.
**/
@name("MethodLength")
@desc("Checks for long methods. If a method becomes very long it is hard to understand. Therefore long methods should usually be refactored into several individual methods that focus on a specific task.")
class MethodLengthCheck extends Check {
	static var DEFAULT_MAX_LENGTH:Int = 50;

	/**
		maximum number of lines per method (default: 50)
	**/
	public var max:Int;

	/**
		ignores or includes empty lines when counting method length
	**/
	public var ignoreEmptyLines:Bool;

	public function new() {
		super(TOKEN);
		max = DEFAULT_MAX_LENGTH;
		ignoreEmptyLines = true;
		categories = [Category.COMPLEXITY, Category.CLARITY];
		points = 8;
	}

	override public function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var functions:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdFunction):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});

		var emptyLines:ListOfEmptyLines = ListOfEmptyLines.detectEmptyLines(checker);
		for (func in functions) {
			if (isPosSuppressed(func.pos)) continue;
			checkMethod(func, emptyLines);
		}
	}

	function checkMethod(token:TokenTree, emptyLines:ListOfEmptyLines) {
		var pos:Position = token.getPos();
		var lmin:Int = checker.getLinePos(pos.min).line;
		var lmax:Int = checker.getLinePos(pos.max).line;
		var len:Int = getLineCount(lmin, lmax, emptyLines);
		var name:String = "(anonymous)";
		var nameTok:Null<TokenTree> = token.access().firstChild().token;
		if (nameTok != null) {
			switch (nameTok.tok) {
				case Const(CIdent(text)):
					name = text;
				case Kwd(KwdNew):
					name = "new";
				case _:
			}
		}
		if (len > max) warnFunctionLength(len, name, PosHelper.getReportPos(token));
	}

	function getLineCount(lmin:Int, lmax:Int, emptyLines:ListOfEmptyLines):Int {
		var emptyLineCount = 0;
		if (ignoreEmptyLines) {
			emptyLineCount = emptyLines.countEmptylinesBetween(lmin, lmax);
		}
		return lmax - lmin - emptyLineCount;
	}

	function warnFunctionLength(len:Int, name:String, pos:Position) {
		logPos('Method `${name}` length is ${len} lines (max allowed is ${max})', pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "max",
				values: [for (i in 0...17) 20 + i * 5]
			}, {
				propertyName: "ignoreEmptyLines",
				values: [true, false]
			}]
		}];
	}
}