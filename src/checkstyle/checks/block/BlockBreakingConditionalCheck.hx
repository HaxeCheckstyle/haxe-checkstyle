package checkstyle.checks.block;

/**
	Checks for block breaking conditionals
**/
@name("BlockBreakingConditional")
@desc("Checks for block breaking conditionals.")
class BlockBreakingConditionalCheck extends Check {
	public function new() {
		super(TOKEN);
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var allBrs:Array<TokenTree> = root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case BrOpen | BrClose:
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (br in allBrs) {
			if (isPosSuppressed(br.pos)) continue;
			switch (br.tok) {
				case BrOpen:
					if (br.access().firstOf(BrClose).exists()) continue;
					logPos("Left curly has no matching right curly", br.pos);
				case BrClose:
					if (br.access().parent().matches(BrOpen).exists()) continue;
					logPos("Right curly has no matching left curly", br.pos);
				default:
					continue;
			}
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