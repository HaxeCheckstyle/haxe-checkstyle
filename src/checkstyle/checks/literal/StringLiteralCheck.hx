package checkstyle.checks.literal;

import checkstyle.utils.StringUtils;

/**
	Checks for single or double quote string literals.
**/
@name("StringLiteral")
@desc("Checks for single or double quote string literals.")
class StringLiteralCheck extends Check {
	/**
		policy for string literal use
		- onlySingle = enforce single quotes
		- onlyDouble = enforce double quotes, no interpolation allowed
		- doubleAndInterpolation = enforce double quotes, allow single quotes for interpolation
	**/
	public var policy:StringLiteralPolicy;

	/**
		"allowException" allows using single quotes in "onlyDouble" and "doubleAndInterpolation" mode, when string contains a double quote character.
		Or double quotes in "onlySingle" mode when string contains a single quote character, reducing the need to escape quotation marks.
	**/
	public var allowException:Bool;

	public function new() {
		super(TOKEN);
		policy = DOUBLE_AND_INTERPOLATION;
		allowException = true;
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();

		var allStringLiterals:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Const(CString(_)): FoundGoDeeper;
				default: GoDeeper;
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
		var quote:String = checker.getString(pos.min, pos.min + 1);
		var singleQuote:Bool = quote == "'";
		switch (policy) {
			case ONLY_DOUBLE:
				if (!singleQuote) return;
				if (allowException && ~/"/.match(s)) return;
				logPos('String "$s" uses single quotes instead of double quotes', pos, USE_DOUBLE_QUOTES);
			case ONLY_SINGLE:
				if (singleQuote) return;
				if (allowException && ~/'/.match(s)) return;
				logPos('String "$s" uses double quotes instead of single quotes', pos, USE_SINGLE_QUOTES);
			case DOUBLE_AND_INTERPOLATION:
				if (!singleQuote) return;
				if (StringUtils.isStringInterpolation(s, checker.file.content, pos)) return;
				if (allowException && ~/"/.match(s)) return;
				logPos('String "$s" uses single quotes instead of double quotes', pos, USE_DOUBLE_QUOTES);
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "policy",
				values: [DOUBLE_AND_INTERPOLATION, ONLY_SINGLE, ONLY_DOUBLE]
			}, {
				propertyName: "allowException",
				values: [false, true]
			}]
		}];
	}
}

enum abstract StringLiteralPolicy(String) {
	var ONLY_SINGLE = "onlySingle";
	var ONLY_DOUBLE = "onlyDouble";
	var DOUBLE_AND_INTERPOLATION = "doubleAndInterpolation";
}

enum abstract StringLiteralCode(String) to String {
	var USE_DOUBLE_QUOTES = "UseDoubleQuotes";
	var USE_SINGLE_QUOTES = "UseSingleQuotes";
}