package checkstyle.checks.coding;

import checkstyle.token.TokenTree;

@name("Trace")
@desc("Checks for trace calls in code.")
class TraceCheck extends Check {

	public function new() {
		super(TOKEN);
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var traces = root.filter([Const(CIdent("trace"))], ALL);
		for (tr in traces) {
			if (!tr.getFirstChild().tok.match(POpen)) continue;
			if (filterTrace(tr.parent)) continue;
			if (isPosSuppressed(tr.pos)) continue;

			logPos("Trace detected", tr.pos);
		}
	}

	function filterTrace(token:TokenTree):Bool {
		return switch (token.tok) {
			case Dot: true;
			case Kwd(KwdFunction): true;
			default: false;
		}
	}
}