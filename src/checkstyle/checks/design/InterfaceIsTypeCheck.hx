package checkstyle.checks.design;

import checkstyle.token.TokenTree;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("InterfaceIsType")
@desc("Checks for interfaces that does not contain any methods but only constants")
class InterfaceIsTypeCheck extends Check {

	public var allowMarkerInterfaces:Bool;

	public function new() {
		super(TOKEN);
		allowMarkerInterfaces = true;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var interfaces:Array<TokenTree> = root.filter([Kwd(KwdInterface)], ALL);
		for (intr in interfaces) {
			var functions:Array<TokenTree> = intr.filter([Kwd(KwdFunction)], ALL);
			var vars:Array<TokenTree> = intr.filter([Kwd(KwdVar)], ALL);

			if (allowMarkerInterfaces && functions.length == 0 && vars.length == 0) continue;

			if (functions.length == 0) logPos("Interfaces should describe a type and hence have methods", intr.pos, severity);
		}
	}
}