package checkstyle.checks.coding;

import checkstyle.token.TokenTree;

using checkstyle.utils.ArrayUtils;

@name("MagicNumber")
@desc("Checks that there are no magic numbers. By default, -1, 0, 1, and 2 are not considered to be magic numbers.")
class MagicNumberCheck extends Check {

	public var ignoreNumbers:Array<Float>;

	public function new() {
		super(TOKEN);
		ignoreNumbers = [-1, 0, 1, 2];
		categories = [Category.CLARITY, Category.COMPLEXITY];
		points = 3;
	}

	override function actualRun() {
		var ignore = false;
		forEachField(function(field, parent) {
			ignore = (parent.kind == ENUM_ABSTRACT);
			return;
		});

		if (ignore) return;

		var root:TokenTree = checker.getTokenTree();
		var allNumbers:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (token.tok == null) return GO_DEEPER;
			return switch (token.tok) {
				case Const(CInt(_)): FOUND_GO_DEEPER;
				case Const(CFloat(_)): FOUND_GO_DEEPER;
				default: GO_DEEPER;
			}
		});

		for (numberToken in allNumbers) {
			if (isPosSuppressed(numberToken.pos)) continue;
			if (!filterNumber(numberToken)) continue;
			switch (numberToken.tok) {
				case Const(CInt(n)):
					var number:Int = Std.parseInt(n);
					if (ignoreNumbers.contains(number)) continue;
					logPos('Magic number "$n" detected - consider using a constant', numberToken.pos);
				case Const(CFloat(n)):
					var number:Float = Std.parseFloat(n);
					if (ignoreNumbers.contains(number)) continue;
					logPos('Magic number "$n" detected - consider using a constant', numberToken.pos);
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