package checkstyle.checks;

import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("AvoidStarImport")
@desc("Checks for .* import and using directives.")
class AvoidStarImportCheck extends Check {

	public var allowStarImports:Bool;
	public var allowStarUsing:Bool;

	public function new() {
		super();
		allowStarImports = false;
		allowStarUsing = false;
	}

	override function actualRun() {
		if (allowStarUsing && allowStarImports) return;
		var root:TokenTree = TokenTreeBuilder.buildTokenTree(checker.tokens);

		checkImports(root.filter([Kwd(KwdImport)], All));
		checkUsing(root.filter([Kwd(KwdUsing)], All));
	}

	function checkImports(importEntries:Array<TokenTree>) {
		if (allowStarImports) return;

		for (entry in importEntries) {
			var stars:Array<TokenTree> = entry.filter([Binop(OpMult)], All);
			if (stars.length <= 0) continue;
			logPos("Import line uses a star (.*) import - consider using full type names", entry.pos, Reflect.field(SeverityLevel, severity));
		}
	}

	function checkUsing(usingEntries:Array<TokenTree>) {
		if (allowStarUsing) return;

		for (entry in usingEntries) {
			var stars:Array<TokenTree> = entry.filter([Binop(OpMult)], All);
			if (stars.length <= 0) continue;
			logPos("Using line uses a star (.*) import - consider using full type names", entry.pos, Reflect.field(SeverityLevel, severity));
		}
	}
}