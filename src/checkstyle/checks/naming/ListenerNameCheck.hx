package checkstyle.checks.naming;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Function;

@name("ListenerName")
@desc("Checks on naming conventions of event listener methods")
class ListenerNameCheck extends Check {

	public var listeners:Array<String>;
	public var format:String;
	var formatRE:EReg;

	public function new() {
		super(AST);
		listeners = ["addEventListener", "addListener", "on", "once"];
		format = "^_?[a-z][a-zA-Z0-9]*$";
	}

	override public function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr){
				case ECall(e, params):
					searchCall(e, params);
				default:
			}
		});
	}

	function searchCall(e, p) {
		for (listener in listeners) if (searchLeftCall(e, listener)) searchCallParam(p);
	}

	function searchLeftCall(e, name):Bool {
		switch (e.expr){
			case EConst(CIdent(ident)): return ident == name;
			case EField(e2, field): return field == name;
			default:return false;
		}
	}

	function searchCallParam(p:Array<Expr>) {
		if (p.length < 2) return;
		var listener = p[1];
		switch (listener.expr){
			case EConst(CIdent(ident)):
				checkListenerName(ident, listener.pos);
			default:
		}
	}

	function checkListenerName(name:String, pos:Position) {
		formatRE = new EReg (format, "");
		var match = formatRE.match(name);
		if (!match) logPos('Wrong listener name: ' + name + ' (should be ~/${format}/)', pos);
	}
}