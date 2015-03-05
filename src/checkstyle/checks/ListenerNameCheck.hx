package checkstyle.checks;

import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxeparser.Data.Definition;
import haxe.macro.Expr.Function;
import haxeparser.Data.ClassFlag;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("ListenerName")
class ListenerNameCheck extends Check {
	public function new(){
		super();
	}

	override public function actualRun() {
		ExprUtils.walkFile(_checker.ast,function(e) {
			switch(e.expr){
				case ECall(e, params):
					searchCall(e, params);
				default:
			}
		});
	}

	function searchCall(e,p){
		if (! searchLeftCall(e)) return;
		searchCallParam(p);
	}

	function searchLeftCall(e){
		var name = "addEventListener";
		switch(e.expr){
		case EConst(CIdent(ident)): return ident == name;
		case EField(e2,field): return field == name;
		default:return false;
		}
	}

	function searchCallParam(p:Array<Expr>){
		if (p.length < 2) return;
		var listener = p[1];
		switch(listener.expr){
		case EConst(CIdent(ident)):
			var lp = _checker.getLinePos(listener.pos.min);
			checkListenerName(ident, lp.line, lp.ofs);
		default:
		}
	}

	function checkListenerName(name:String, line:Int, col:Int){
		var re = ~/^_?on.*/;
		var match = re.match(name);
		if (!match) log("Wrong listener name: " + name, line, col, SeverityLevel.ERROR);
	}
}
