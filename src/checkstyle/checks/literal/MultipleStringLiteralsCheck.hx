package checkstyle.checks.literal;

import checkstyle.utils.StringUtils;

/**
	Checks for multiple occurrences of the same string literal within a single file.
	Code duplication makes maintenance more difficult, so it's better to replace the multiple occurrences with a constant.
**/
@name("MultipleStringLiterals")
@desc("Checks for multiple occurrences of the same string literal within a single file. Code duplication makes maintenance more difficult, so it's better to replace the multiple occurrences with a constant.")
class MultipleStringLiteralsCheck extends Check {
	/**
		number of occurrences to allow
	**/
	public var allowDuplicates:Int;

	/**
		string literals must be "minLength" or more characters before including them
	**/
	public var minLength:Int;

	/**
		ignore string literals matching regex
	**/
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
		ignoreRE = new EReg(ignore, "");
		var root:TokenTree = checker.getTokenTree();

		var allLiterals:Map<String, Int> = new Map<String, Int>();
		var allStringLiterals:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Const(CString(_)): FoundGoDeeper;
				default: GoDeeper;
			}
		});

		for (literalToken in allStringLiterals) {
			if (!filterLiteral(literalToken.parent)) continue;
			// skip string object keys issue #116
			if (literalToken.parent.tok.match(BrOpen)) continue;
			if (isPosSuppressed(literalToken.pos)) continue;

			switch (literalToken.tok) {
				case Const(CString(s)):
					if (StringUtils.isStringInterpolation(s, checker.file.content, literalToken.pos)) continue;
					if (ignoreRE.match(s)) continue;
					if (s.length < minLength) continue;
					if (checkLiteralCount(s, allLiterals)) {
						logPos('String "$s" appears ${allLiterals.get(s)} times in the file', literalToken.pos);
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
		if ((token == null) || (token.tok == Root)) return true;
		return switch (token.tok) {
			case At: false;
			case Kwd(KwdVar): !(token.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
					return switch (token.tok) {
						case Kwd(KwdStatic):
							FoundSkipSubtree;
						default:
							GoDeeper;
					}
				}).length > 0);

			default: filterLiteral(token.parent);
		}
	}
}