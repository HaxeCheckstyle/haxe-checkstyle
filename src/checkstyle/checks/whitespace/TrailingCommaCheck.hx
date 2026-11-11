package checkstyle.checks.whitespace;

/**
	Requires trailing comma in multiline object and array literals.
**/
@name("TrailingComma", "DanglingComma")
@desc("Requires trailing comma in multiline object and array literals.")
class TrailingCommaCheck extends Check {
	public var enforceObjectLiterals:Bool;
	public var enforceArrayLiterals:Bool;
	public var enforceArrayComprehension:Bool;

	public function new() {
		super(AST);
		enforceObjectLiterals = false;
		enforceArrayLiterals = false;
		enforceArrayComprehension = false;
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		if (checker.ast == null) return;

		checker.ast.walkFile(function(e:Expr) {
			switch (e.expr) {
				case EObjectDecl(fields):
					if (!enforceObjectLiterals || fields.length <= 0) return;
					checkDelimited(e.pos, "{", "}", "object literal", true);
				case EArrayDecl(values):
					if (values.length <= 0) return;
					if (isArrayComprehension(values)) {
						if (enforceArrayComprehension)
							checkNoTrailingComma(e.pos, "[", "]", "array comprehension");
						return;
					}
					if (enforceArrayLiterals)
						checkDelimited(e.pos, "[", "]", "array literal");
				default:
			}
		});
	}

	function isArrayComprehension(values:Array<Expr>):Bool {
		for (v in values) {
			switch (v.expr) {
				case EFor(_, _) | EWhile(_, _, _):
					return true;
				default:
			}
		}
		return false;
	}

	function checkNoTrailingComma(pos:Position, open:String, close:String, label:String) {
		if (isPosSuppressed(pos)) return;

		var source = checker.getString(pos.min, pos.max);
		if (source == null || source.length == 0) return;

		var openIndex = source.indexOf(open);
		var closeIndex = source.lastIndexOf(close);
		if (openIndex < 0 || closeIndex <= openIndex) return;

		var inside = source.substring(openIndex + 1, closeIndex);
		if (!hasTrailingComma(inside)) return;

		var closePos = pos.min + closeIndex;
		logRange('Trailing comma changes semantics in $label', closePos, closePos + 1, FORBIDDEN_TRAILING_COMMA);
	}

	function checkDelimited(pos:Position, open:String, close:String, label:String, enforceObjectContext:Bool = false) {
		if (isPosSuppressed(pos)) return;

		var source = checker.getString(pos.min, pos.max);
		if (source == null || source.length == 0) return;

		var openIndex = source.indexOf(open);
		var closeIndex = source.lastIndexOf(close);
		if (openIndex < 0 || closeIndex <= openIndex) return;

		var inside = source.substring(openIndex + 1, closeIndex);
		if (inside.indexOf("\n") < 0 && inside.indexOf("\r") < 0) return;
		if (inside.trim().length == 0) return;
		if (enforceObjectContext && !isObjectLiteralContext(pos, openIndex)) return;
		if (hasTrailingComma(inside)) return;

		var closePos = pos.min + closeIndex;
		logRange('Missing trailing comma in multiline $label', closePos, closePos + 1, MISSING_TRAILING_COMMA);
	}

	function hasTrailingComma(inside:String):Bool {
		var tail = trimTrailingIgnoredTail(inside);
		return tail.length > 0 && tail.charAt(tail.length - 1) == ",";
	}

	static function trimRight(value:String):String {
		var end = value.length;
		while (end > 0 && StringTools.isSpace(value, end - 1)) {
			end -= 1;
		}
		return value.substring(0, end);
	}

	function isObjectLiteralContext(pos:Position, openIndex:Int):Bool {
		var root:TokenTree = checker.getTokenTree();
		if (root == null) return true;

		var openPos = pos.min + openIndex;
		var openBrace = findOpenBraceToken(root, openPos);
		if (openBrace == null || openBrace.parent == null) return true;

		return !isBlockBraceParent(openBrace.parent.tok);
	}

	function findOpenBraceToken(root:TokenTree, offset:Int):TokenTree {
		var matches = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (token.pos.min > offset) return SkipSubtree;
			return switch (token.tok) {
				case BrOpen if (token.pos.min == offset):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});
		return (matches.length > 0) ? matches[0] : null;
	}

	function isBlockBraceParent(tok:TokenTreeDef):Bool {
		return switch (tok) {
			case Const(CIdent(_))
				| Kwd(KwdIf)
				| Kwd(KwdElse)
				| Kwd(KwdFor)
				| Kwd(KwdWhile)
				| Kwd(KwdDo)
				| Kwd(KwdTry)
				| Kwd(KwdCatch)
				| Kwd(KwdSwitch)
				| Kwd(KwdMacro)
				| Arrow
				| Dollar(_):
				true;
			default:
				false;
		}
	}

	function trimTrailingIgnoredTail(value:String):String {
		var tail = trimRight(value);
		while (tail.length > 0) {
			var lineComment = ~/\/\/[^\n\r]*$/;
			if (lineComment.match(tail)) {
				tail = trimRight(tail.substring(0, lineComment.matchedPos().pos));
				continue;
			}

			if (tail.length >= 2 && tail.substr(tail.length - 2, 2) == "*/") {
				var blockStart = tail.lastIndexOf("/*");
				if (blockStart >= 0) {
					tail = trimRight(tail.substring(0, blockStart));
					continue;
				}
			}

			var lineStart = tail.lastIndexOf("\n");
			var carriageLineStart = tail.lastIndexOf("\r");
			if (carriageLineStart > lineStart) {
				lineStart = carriageLineStart;
			}
			var lastLine = (lineStart >= 0) ? tail.substring(lineStart + 1) : tail;
			if (isConditionalDirective(lastLine)) {
				tail = (lineStart >= 0) ? trimRight(tail.substring(0, lineStart)) : "";
				continue;
			}

			break;
		}
		return tail;
	}

	function isConditionalDirective(line:String):Bool {
		var trimmed = line.trim();
		if (trimmed.length == 0) return false;
		return ~/^#(if|elseif|else|end)\b/.match(trimmed);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "enforceObjectLiterals",
				values: [true, false]
			}, {
				propertyName: "enforceArrayLiterals",
				values: [true, false]
			}, {
				propertyName: "enforceArrayComprehension",
				values: [true, false]
			}]
		}];
	}
}

enum abstract TrailingCommaCode(String) to String {
	var MISSING_TRAILING_COMMA = "MissingTrailingComma";
	var FORBIDDEN_TRAILING_COMMA = "ForbiddenTrailingComma";
}
