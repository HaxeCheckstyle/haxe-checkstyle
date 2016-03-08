package checkstyle.checks.literal;

import checkstyle.token.TokenTree;
import checkstyle.token.TokenTreeBuilder;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("MultipleStringLiterals")
@desc("Checks for multiple instances of string literals")
class MultipleStringLiteralsCheck extends Check {

	public var allowDuplicates:Int;
	public var minLength:Int;
	public var ignore:String;

	var ignoreRE:EReg;

	public function new() {
		super(TOKEN);
		ignore = "^\\s+$";
		allowDuplicates = 2;
		minLength = 2;
	}

	override function actualRun() {
		ignoreRE = new EReg (ignore, "");
		var root:TokenTree = TokenTreeBuilder.buildTokenTree(checker.tokens);

		var allLiterals:Map<String, Int> = new Map<String, Int>();
		var allStringLiterals:Array<TokenTree> = root.filterCallback(function(token:TokenTree):Bool {
			if (token.tok == null) return false;
			return switch (token.tok) {
				case Const(CString(_)): true;
				default: false;
			}
		},
		ALL);

		for (literalToken in allStringLiterals) {
			if (!filterLiteral(literalToken.parent)) continue;
			// skip string object keys issue #116
			if (literalToken.parent.tok.match(BrOpen)) continue;

			switch (literalToken.tok) {
				case Const(CString(s)):
					if (ignoreRE.match(s)) continue;
					if (s.length < minLength) continue;
					if (checkLiteralCount(s, allLiterals)) {
						if (isPosSuppressed(literalToken.pos)) continue;
						logPos('Multiple string literal "$s" detected - consider using a constant',
						literalToken.pos, severity);
					}
				default:
			}
		}
	}

	function checkLiteralCount(literal:String, map:Map<String, Int>):Bool {
		if (!map.exists(literal)) {
			map.set(literal, 1);
		}
		else {
			map.set(literal, map.get(literal) + 1);
		}
		return (map.get(literal) > allowDuplicates);
	}

	function filterLiteral(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return true;
		return switch (token.tok) {
			case At: false;
			case Kwd(KwdVar):
				if (token.filter([Kwd(KwdStatic)], FIRST).length > 0) false;
				else true;
			default: filterLiteral(token.parent);
		}
	}
}