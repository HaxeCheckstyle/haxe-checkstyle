package checkstyle.checks.naming;

import checkstyle.token.TokenTree;
import haxe.macro.Expr;

@name("CatchParameterName")
@desc("Checks that catch parameter names conform to a format specified by the `format` property.")
class CatchParameterNameCheck extends Check {

	public var format:String;

	public function new() {
		super(TOKEN);
		format = "^(e|t|ex|[a-z][a-z][a-zA-Z]+)$";
	}

	override function actualRun() {
		var formatRE = new EReg(format, "");
		var root:TokenTree = checker.getTokenTree();
		var catchTokens = root.filter([Kwd(KwdCatch)], ALL);

		for (tkn in catchTokens) {
			for (item in tkn.childs) {
				switch (item.getFirstChild().tok) {
					case Const(CIdent(name)):
						if (item.is(POpen)) {
							if (!formatRE.match(name)) logPos('$name must match pattern ~/${format}/', item.pos);
							continue;
						}
					default:
				}
			}
		}
	}
}