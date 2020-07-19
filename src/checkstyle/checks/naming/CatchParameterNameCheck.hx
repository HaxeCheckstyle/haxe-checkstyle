package checkstyle.checks.naming;

/**
	Checks that catch parameter names conform to a format specified by the "format" property.
**/
@name("CatchParameterName")
@desc("Checks that catch parameter names conform to a format specified by the `format` property.")
class CatchParameterNameCheck extends Check {
	/**
		regex name format
	**/
	public var format:String;

	public function new() {
		super(TOKEN);
		format = "^(e|t|ex|[a-z][a-z][a-zA-Z]+)$";
	}

	override function actualRun() {
		var formatRE = new EReg(format, "");
		var root:TokenTree = checker.getTokenTree();
		var catchTokens = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdCatch):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (tkn in catchTokens) {
			for (item in tkn.children) {
				var child:TokenTree = item.getFirstChild();
				if (child == null) continue;
				switch (child.tok) {
					case Const(CIdent(name)):
						if (item.matches(POpen)) {
							if (!formatRE.match(name)) logPos('"$name" must match pattern "~/${format}/"', item.pos);
							continue;
						}
					default:
				}
			}
		}
	}
}