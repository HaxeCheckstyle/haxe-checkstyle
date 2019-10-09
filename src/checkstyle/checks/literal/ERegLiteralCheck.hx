package checkstyle.checks.literal;

/**
	Checks for usage of EReg literals (between ~/ and /) instead of new.
**/
@name("ERegLiteral", "ERegInstantiation")
@desc("Checks for usage of EReg literals (between ~/ and /) instead of new.")
class ERegLiteralCheck extends Check {
	public function new() {
		super(AST);
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		if (checker.ast == null) return;
		checker.ast.walkFile(function(e:Expr) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr) {
				case ENew({pack: [], name: "EReg"}, [{expr: EConst(CString(re)), pos: _}, {expr: EConst(CString(opt)), pos: _}]):
					if (~/\$\{.+\}/.match(re)) return;
					logPos('Bad EReg instantiation, define expression between "~/" and "/"', e.pos);
				default:
			}
		});
	}
}