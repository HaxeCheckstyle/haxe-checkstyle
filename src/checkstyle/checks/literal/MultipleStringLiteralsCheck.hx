package checkstyle.checks.literal;

import checkstyle.token.TokenTree;
import checkstyle.token.TokenTreeBuilder;
import checkstyle.utils.StringUtils;

@name("MultipleStringLiterals")
@desc("Checks for multiple occurrences of the same string literal within a single file. Code duplication makes maintenance more difficult, so it's better to replace the multiple occurrences with a constant.")
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
		categories = [Category.STYLE, Category.CLARITY];
		points = 2;
	}

	override function actualRun() {
		ignoreRE = new EReg (ignore, "");
		var root:TokenTree = TokenTreeBuilder.buildTokenTree(checker.tokens, checker.bytes);

		var allLiterals:Map<String, Int> = new Map<String, Int>();
		var allStringLiterals:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (token.tok == null) return GO_DEEPER;
			return switch (token.tok) {
				case Const(CString(_)): FOUND_GO_DEEPER;
				default: GO_DEEPER;
			}
		});

		for (literalToken in allStringLiterals) {
			if (!filterLiteral(literalToken.parent)) continue;
			// skip string object keys issue #116
			if (literalToken.parent.tok.match(BrOpen)) continue;

			switch (literalToken.tok) {
				case Const(CString(s)):
					if (StringUtils.isStringInterpolation(s, checker.file.content, literalToken.pos)) continue;
					if (ignoreRE.match(s)) continue;
					if (s.length < minLength) continue;
					if (checkLiteralCount(s, allLiterals)) {
						if (isPosSuppressed(literalToken.pos)) continue;
						logPos('String "$s" appears ${s.length} times in the file', literalToken.pos);
					}
				default:
			}
		}
	}

	function checkLiteralCount(literal:String, map:Map<String, Int>):Bool {
		if (!map.exists(literal)) map.set(literal, 1);
		else map.set(literal, map.get(literal) + 1);
		return (map.get(literal) > allowDuplicates);
	}

	function filterLiteral(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return true;
		return switch (token.tok) {
			case At: false;
			case Kwd(KwdVar): !(token.filter([Kwd(KwdStatic)], FIRST).length > 0);
			default: filterLiteral(token.parent);
		}
	}

}