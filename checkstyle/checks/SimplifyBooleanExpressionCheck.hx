package checkstyle.checks;

import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("SimplifyBooleanExpression")
@desc("Checks for over-complicated boolean expressions")
class SimplifyBooleanExpressionCheck extends Check {

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var acceptableTokens:Array<TokenTree> = root.filter([
			Kwd(KwdTrue),
			Kwd(KwdFalse),
			Binop(OpEq),
			Binop(OpNotEq),
			Unop(OpNot),
			Binop(OpOr),
			Binop(OpAnd),
			Binop(OpBoolOr),
			Binop(OpBoolAnd)
		], ALL);

		for (token in acceptableTokens) {
			if (token.is(Kwd(KwdTrue)) || token.is(Kwd(KwdFalse))) check(token);
		}
	}

	function check(token:TokenTree) {
		var parent = token.parent;
		if (parent.is(Binop(OpEq)) || parent.is(Binop(OpNotEq)) || parent.is(Unop(OpNot)) ||
		parent.is(Binop(OpOr)) || parent.is(Binop(OpAnd)) || parent.is(Binop(OpBoolOr)) ||
		parent.is(Binop(OpBoolAnd))) {
			logPos('Boolean expression can be simplified', token.pos, Reflect.field(SeverityLevel, severity));
		}
	}
}