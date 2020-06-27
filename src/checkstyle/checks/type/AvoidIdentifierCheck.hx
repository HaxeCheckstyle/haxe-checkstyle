package checkstyle.checks.type;

/**
	Checks for identifiers to avoid.
**/
@name("AvoidIdentifier")
@desc("Checks for identifiers to avoid.")
class AvoidIdentifierCheck extends Check {
	/**
		list of identifiers to avoid
	**/
	public var avoidIdentifiers:Array<String>;

	public function new() {
		super(TOKEN);
		avoidIdentifiers = [];
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			switch (token.tok) {
				case Const(CIdent(ident)):
					checkIdent(ident, token);
				default:
			}
			return GoDeeper;
		});
	}

	function checkIdent(ident:String, token:TokenTree) {
		if (isPosSuppressed(token.pos)) return;
		if (avoidIdentifiers.indexOf(ident) < 0) return;
		error(ident, token.pos);
	}

	function error(name:String, pos:Position) {
		logPos('Identifier "${name}" should be avoided', pos);
	}
}