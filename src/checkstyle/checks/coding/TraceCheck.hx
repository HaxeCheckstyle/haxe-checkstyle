package checkstyle.checks.coding;

/**
	Checks for trace calls in code.
**/
@name("Trace")
@desc("Checks for trace calls in code.")
class TraceCheck extends Check {
	public function new() {
		super(TOKEN);
		severity = SeverityLevel.IGNORE;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var traces = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Const(CIdent("trace")):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
		for (tr in traces) {
			if (!tr.getFirstChild().tok.match(POpen)) continue;
			if (filterTrace(tr.parent)) continue;
			if (isPosSuppressed(tr.pos)) continue;

			logPos("Trace detected", tr.getPos());
		}
	}

	function filterTrace(token:TokenTree):Bool {
		return switch (token.tok) {
			case Dot: true;
			case Kwd(KwdFunction): true;
			default: false;
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: [SeverityLevel.INFO]
			}]
		}];
	}
}