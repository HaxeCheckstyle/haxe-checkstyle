package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("NestedIfDepth")
@desc("Max number of nested if-else blocks (default 1)")
class NestedIfDepthCheck extends Check {

	public var severity:String = "ERROR";
	public var max:Int = 1;

	override function _actualRun() {
		for (td in _checker.ast.decls) {
			switch (td.decl) {
				case EClass(d):
					checkFields(d);
				default:
			}
		}
	}

	function checkFields(d:Definition<ClassFlag, Array<Field>>) {
		for (field in d.data) {
			checkField(field);
		}
	}

	function checkField(f:Field) {
		switch (f.kind) {
			case FFun(fun):
				scanBlock(fun.expr, -1);
			default:
		}
	}

	function scanBlock(e:Expr, depth:Int) {
		if (e == null) return;
		if (depth > max) {
			_warnNestedIfDepth(depth, e.pos);
			return;
		}
		switch(e.expr) {
			case EBlock(exprs):
				scanExprs(exprs, depth);
			default:
		}
	}

	function scanExprs(exprs:Array<Expr>, depth:Int) {
		for (e in exprs) {
			switch(e.expr) {
				case EIf(_, ifPart,elsePart):
					scanBlock(ifPart, depth + 1);
					scanBlock(elsePart, depth + 1);
				default:
			}
		}
	}

	function _warnNestedIfDepth(depth:Int, pos:Position) {
		logPos('Nested if-else depth is $depth (max allowed is ${max})', pos, Reflect.field(SeverityLevel, severity));
	}
}
