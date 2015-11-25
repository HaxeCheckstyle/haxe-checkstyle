package checkstyle.checks;

import haxe.macro.Expr;
import haxeparser.Data.TokenDef;
import checkstyle.LintMessage.SeverityLevel;

@name("InnerAssignment")
@desc("Checks for assignments in subexpressions")
class InnerAssignmentCheck extends Check {

	public function new() {
		super();
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();

		var allAssignments:Array<TokenTree> = root.filter([
				Binop(OpAssign),
				Binop(OpAssignOp(OpAdd)),
				Binop(OpAssignOp(OpSub)),
				Binop(OpAssignOp(OpMult)),
				Binop(OpAssignOp(OpDiv)),
				Binop(OpAssignOp(OpAnd)),
				Binop(OpAssignOp(OpOr)),
				Binop(OpAssignOp(OpXor)),
				Binop(OpAssignOp(OpLte)),
				Binop(OpAssignOp(OpGte)), // currently not supported by HaxeLexer
				Binop(OpAssignOp(OpShl)),
				Binop(OpAssignOp(OpShr)), // currently not supported by HaxeLexer
				Binop(OpAssignOp(OpUShr)) // currently not supported by HaxeLexer
				], ALL);
		var x:Int = 0;
		for (assignToken in allAssignments) {
			if (isPosSuppressed(assignToken.pos)) continue;
			if (!filterAssignment(assignToken)) continue;
			logPos('Inner assignment detected', assignToken.pos, Reflect.field(SeverityLevel, severity));
		}
	}

	function filterAssignment(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return false;
		if (token.previousSibling != null) {
			// tokenizer does not treat >= as OpGte
			// creates OpGt and OpAssign instead
			if (token.previousSibling.is(Binop(OpGt))) return false;
		}
		return switch (token.tok) {
			case Kwd(KwdVar):
				false;
			case Kwd(KwdFunction):
				false;
			case Kwd(KwdReturn):
				true;
			case BrOpen:
				false;
			case DblDot:
				false;
			case POpen:
				filterPOpen(token.parent);
			default: filterAssignment(token.parent);
		}
	}
	function filterPOpen(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return false;
		return switch (token.tok) {
			case Kwd(KwdFunction):
				false;
			case Kwd(KwdVar):
				false;
			case Kwd(KwdNew):
				if (Type.enumEq(Kwd(KwdFunction), token.parent.tok)) false;
				else true;
			case Kwd(KwdReturn):
				true;
			case Kwd(KwdWhile):
				false;
			case POpen, Const(_):
				filterPOpen(token.parent);
			default: true;
		}
	}
}