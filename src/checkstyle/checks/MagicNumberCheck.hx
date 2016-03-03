package checkstyle.checks;

import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("MagicNumber")
@desc("Checks that there are no magic numbers")
class MagicNumberCheck extends Check {
	public var ignoreNumbers:Array<Float>;

	public function new() {
		super();
		ignoreNumbers = [-1, 0, 1, 2];
		severity = "IGNORE";
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();

		var allNumbers:Array<TokenTree> = root.filterCallback(function(token:TokenTree):Bool {
				if (token.tok == null) return false;
				return switch (token.tok) {
					case Const(CInt(_)): true;
					case Const(CFloat(_)): true;
					default: false;
				}
			},
			ALL);
		for (numberToken in allNumbers) {
			if (isPosSuppressed(numberToken.pos)) continue;
			if (!filterNumber(numberToken)) continue;
			switch (numberToken.tok) {
				case Const(CInt(n)):
					var number:Int = Std.parseInt(n);
					if (ignoreNumbers.indexOf(number) >= 0) continue;
					logPos('Magic number "$n" detected - consider using a constant', numberToken.pos, Reflect.field(SeverityLevel, severity));
				case Const(CFloat(n)):
					var number:Float = Std.parseFloat(n);
					if (ignoreNumbers.indexOf(number) >= 0) continue;
					logPos('Magic number "$n" detected - consider using a constant', numberToken.pos, Reflect.field(SeverityLevel, severity));
				default:
			}
		}
	}

	function filterNumber(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return true;
		return switch (token.tok) {
			case At: false;
			case Kwd(KwdVar):
				if (token.filter([Kwd(KwdStatic)], FIRST).length > 0) false;
				else true;
			default: filterNumber(token.parent);
		}
	}
}