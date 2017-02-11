package checkstyle.checks.size;

@name("MethodLength")
@desc("Checks for long methods. If a method becomes very long it is hard to understand. Therefore long methods should usually be refactored into several individual methods that focus on a specific task.")
class MethodLengthCheck extends Check {

	static var DEFAULT_MAX_LENGTH:Int = 50;

	public var max:Int;

	public function new() {
		super(AST);
		max = DEFAULT_MAX_LENGTH;
		categories = [Category.COMPLEXITY, Category.CLARITY];
		points = 8;
	}

	override public function actualRun() {
		forEachField(searchField);
	}

	function searchField(f:Field, _) {
		switch (f.kind){
			case FFun(ff):
				checkMethod(f);
			default:
		}

		f.walkField(function(e) {
			switch (e.expr){
				case EFunction(name, ff):
					checkFunction(e);
				default:
			}
		});
	}

	function checkMethod(f:Field) {
		var lp = checker.getLinePos(f.pos.min);
		var lmin = lp.line;
		var lmax = checker.getLinePos(f.pos.max).line;
		var len = lmax - lmin;
		if (len > max) warnFunctionLength(len, f.name, f.pos);
	}

	function checkFunction(f:Expr) {
		var lp = checker.getLinePos(f.pos.min);
		var lmin = lp.line;
		var lmax = checker.getLinePos(f.pos.max).line;
		var fname = "(anonymous)";
		switch (f.expr){
			case EFunction(name, ff):
				if (name != null) fname = name;
			default: throw "EFunction only";
		}

		var len = lmax - lmin;
		if (len > max) warnFunctionLength(len, fname, f.pos);
	}

	function warnFunctionLength(len:Int, name:String, pos:Position) {
		logPos('Method `${name}` length is ${len} lines (max allowed is ${max})', pos);
	}
}