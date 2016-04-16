package checkstyle.checks.literal;

import checkstyle.token.TokenTree;
import checkstyle.token.TokenTreeBuilder;
import checkstyle.utils.StringUtils;
import haxe.macro.Expr;

@name("StringLiteral")
@desc("Checks for single or double quote string literals.")
class StringLiteralCheck extends Check {

	public var policy:StringLiteralPolicy;
	public var allowException:Bool;

	public function new() {
		super(TOKEN);
		policy = DOUBLE_AND_INTERPOLATION;
		allowException = true;
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
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
			switch (literalToken.tok) {
				case Const(CString(s)):
					if (isPosSuppressed(literalToken.pos)) continue;
					checkLiteral(s, literalToken.pos);
				default:
			}
		}
	}

	function checkLiteral(s:String, pos:Position) {
		var quote:String = checker.file.content.substr(pos.min, 1);
		var singleQuote:Bool = quote == "'";
		switch (policy) {
			case ONLY_DOUBLE:
				if (!singleQuote) return;
				if (allowException && ~/"/.match(s)) return;
				logPos('String "$s" uses single quotes instead of double quotes', pos);
			case ONLY_SINGLE:
				if (singleQuote) return;
				if (allowException && ~/'/.match(s)) return;
				logPos('String "$s" uses double quotes instead of single quotes', pos);
			case DOUBLE_AND_INTERPOLATION:
				if (!singleQuote) return;
				if (StringUtils.isStringInterpolation(s, checker.file.content, pos)) return;
				if (allowException && ~/"/.match(s)) return;
				logPos('String "$s" uses single quotes instead of double quotes', pos);
		}
	}
}

@:enum
abstract StringLiteralPolicy(String) {
	var ONLY_SINGLE = "onlySingle";
	var ONLY_DOUBLE = "onlyDouble";
	var DOUBLE_AND_INTERPOLATION = "doubleAndInterpolation";
}