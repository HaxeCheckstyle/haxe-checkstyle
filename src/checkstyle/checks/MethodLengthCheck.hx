package checkstyle.checks;

import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxeparser.Data.Definition;
import haxe.macro.Expr.Function;
import haxeparser.Data.ClassFlag;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("MethodLength")
class MethodLengthCheck extends Check {
	public function new(){
		super();
	}

	var maxFunctionLines = 50;

	override public function actualRun() {
		for (td in _checker.ast.decls){
			switch(td.decl){
			case EClass(d): searchFields(d.data);
			case EAbstract(a): searchFields(a.data);

			case EEnum(d): //trace("Enum");
			case EImport(sl, mode): //trace("Import");
			case ETypedef(d): //trace("typedef");
			case EUsing(path): //trace("Using");
			}
		}
	}

	function searchFields(fs:Array<Field>){
		for (f in fs) {
			switch(f.kind){
			case FFun(ff):
				checkMethod(f);
			default:
			}

			ExprUtils.walkField(f, function(e) {
				switch(e.expr){
					case EFunction(name, ff):
						checkFunction(e);
					default:
				}
			});
		}
	}

	function checkMethod(f:Field){
		var lp = _checker.getLinePos(f.pos.min);
		var lmin = lp.line;
		var lmax = _checker.getLinePos(f.pos.max).line;
		if (lmax - lmin > maxFunctionLines) _warnFunctionLength(f.name, lp.line+1, lp.ofs+1);
	}

	function checkFunction(f:Expr){
		var lp = _checker.getLinePos(f.pos.min);
		var lmin = lp.line;
		var lmax = _checker.getLinePos(f.pos.max).line;
		var fname = "(anonymous)";
		switch(f.expr){
		case EFunction(name, ff):
			if (name != null) fname = name;
		default: throw "EFunction only";
		}

		if (lmax - lmin > maxFunctionLines) _warnFunctionLength(fname, lp.line+1, lp.ofs+1);
	}

	function _warnFunctionLength(name:String, pos:Int, ofs:Int) {
		log('Function is too long: ${name} (try splitting into multiple functions)', pos, ofs, SeverityLevel.ERROR);
	}
}