package checkstyle.checks.whitespace;

import checkstyle.checks.whitespace.WhitespaceCheckBase.WhitespacePolicy;

/**
	Checks that whitespace is present or absent around a separators.
**/
@name("SeparatorWhitespace")
@desc("Checks that whitespace is present or absent around a separators.")
class SeparatorWhitespaceCheck extends WhitespaceCheckBase {
	/**
		policy for "."
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	**/
	public var dotPolicy:WhitespacePolicy;

	/**
		policy for ","
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	**/
	public var commaPolicy:WhitespacePolicy;

	/**
		no violoation for missing whitespace after trailing commas
	**/
	public var allowTrailingComma:Bool;

	/**
		policy for ";"
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	**/
	public var semicolonPolicy:WhitespacePolicy;

	public function new() {
		super();
		dotPolicy = NONE;
		commaPolicy = AFTER;
		semicolonPolicy = AFTER;
		allowTrailingComma = false;

		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();

		checkTokens(root, [Dot], dotPolicy);
		checkTokens(root, [Comma], commaPolicy);
		checkTokens(root, [Semicolon], semicolonPolicy);
	}

	override function adjustPolicy(token:TokenTree, policy:WhitespacePolicy):WhitespacePolicy {
		switch (token.tok) {
			case Comma:
				if (allowTrailingComma) {
					var contentAfter:String = checker.getString(token.pos.max, token.pos.max + 1);
					switch (contentAfter) {
						case "]", ")", "}":
							switch (policy) {
								case AFTER:
									return NONE;
								case AROUND:
									return BEFORE;
								case BEFORE, NONE, IGNORE:
									return policy;
							}
						default:
					}
				}
			default:
		}
		return policy;
	}

	override function violation(tok:TokenTree, policy:String) {
		if (isWrapped(tok, cast(policy, WhitespacePolicy))) return;
		logPos('SeparatorWhitespace policy "$policy" violated by "$tok"', tok.pos);
	}

	function isWrapped(tok:TokenTree, policy:WhitespacePolicy):Bool {
		if (tok.tok.match(Semicolon)) return false;
		if (policy == AROUND) return false;

		var index:Int = tok.index;
		var tokPos:LinePos = checker.getLinePos(tok.pos.min);

		var prevTok:Token = checker.tokens[index - 1];
		var nextTok:Token = checker.tokens[index + 1];
		var prevTokPos:LinePos = checker.getLinePos(prevTok.pos.max);
		var nextTokPos:LinePos = checker.getLinePos(nextTok.pos.min);

		var wrapBefore:Bool = prevTokPos.line != tokPos.line;
		var wrapAfter:Bool = tokPos.line != nextTokPos.line;

		switch (policy) {
			case AFTER:
				if (wrapBefore) return true;
			case BEFORE:
				if (wrapAfter) return true;
			case NONE:
				if (wrapBefore || wrapAfter) return true;
			default:
		}
		return false;
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "dotPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			}, {
				propertyName: "commaPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			}, {
				propertyName: "semicolonPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			}]
		}];
	}
}