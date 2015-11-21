package checkstyle.checks;

import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("MultipleStringLiterals")
@desc("Checks for multiple instances of string literals")
class MultipleStringLiteralsCheck extends Check {

	public var allowDuplicates:Int;
	public var minLength:Int;

	public function new() {
		super();
		allowDuplicates = 1;
		minLength = 2;
	}

	override function actualRun() {
		var root:TokenTree = TokenTreeBuilder.buildTokenTree(checker.tokens);

		var allLiterals:Map<String, Int> = new Map<String, Int>();
		var allStringLiterals:Array<TokenTree> = root.filterConstString(All);
		for (literalToken in allStringLiterals) {
			if (!filterLiteral(literalToken)) continue;

			switch (literalToken.tok) {
				case Const(CString(s)):
					if (s.length <  minLength) continue;
					if (!allLiterals.exists(s)) {
						allLiterals.set(s, 1);
					}
					else {
						allLiterals.set(s, allLiterals.get(s) + 1);
					}
					if (allLiterals.get(s) > allowDuplicates) {
						if (isPosSuppressed(literalToken.pos)) continue;
						logPos('Multiple string literal "$s" detected - consider using a constant', literalToken.pos, Reflect.field(SeverityLevel, severity));
					}
				default:
			}
		}
	}

	function filterLiteral(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return true;
		return switch (token.tok) {
			case At:
				false;
			case Kwd(KwdVar):
				if (token.filter([Kwd(KwdStatic)], FirstLevel).length > 0) false;
				true;
			default:
				filterLiteral(token.parent);
		}
	}
}