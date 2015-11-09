package checkstyle.checks;

import Array;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxeparser.Data.Definition;
import haxe.macro.Expr.Function;
import haxeparser.Data.ClassFlag;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("ListenerName")
@desc("Checks on naming conventions of event listener methods")
class ListenerNameCheck extends Check {

	public var listeners:Array<String>;
	public var format:String;
	var formatRE:EReg;

	public function new() {
		super();
		listeners = ["addEventListener", "addListener", "on", "once"];
		format = "^_?[a-z]+[a-zA-Z0-9]*$";
	}

	override public function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e) {
			if (isPosSuppressed(e.pos)) return;
			switch(e.expr){
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
		switch(e.expr){
			case EConst(CIdent(ident)): return ident == name;
			case EField(e2, field): return field == name;
			default:return false;
		}
	}

	function searchCallParam(p:Array<Expr>) {
		if (p.length < 2) return;
		var listener = p[1];
		switch(listener.expr){
			case EConst(CIdent(ident)):
				var lp = checker.getLinePos(listener.pos.min);
				checkListenerName(ident, lp.line, lp.ofs);
			default:
		}
	}

	function checkListenerName(name:String, line:Int, col:Int) {
		formatRE = new EReg (format, "");
		var match = formatRE.match(name);
		if (!match) log('Wrong listener name: ' + name + ' (should be ~/${format}/)', line, col, Reflect.field(SeverityLevel, severity));
	}
}