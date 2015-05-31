package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("NestedForDepth")
@desc("Max number of nested for blocks (default 1)")
class NestedForDepthCheck extends Check {

	public var severity:String;
	public var max:Int;

	public function new() {
		super();
		severity = "ERROR";
		max = 1;
	}

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
			if (isCheckSuppressed (field)) continue;
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
			_warnNestedForDepth(depth, e.pos);
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
				case EFor(_, expr):
					scanBlock(expr, depth + 1);
				case EWhile(_, expr, _):
					scanBlock(expr, depth + 1);
				default:
			}
		}
	}

	function _warnNestedForDepth(depth:Int, pos:Position) {
		logPos('Nested for depth is $depth (max allowed is ${max})',
			pos, Reflect.field(SeverityLevel, severity));
	}
}
