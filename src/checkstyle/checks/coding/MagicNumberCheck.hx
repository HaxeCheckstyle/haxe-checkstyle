package checkstyle.checks.coding;

/**
	Checks that there are no magic numbers. By default, -1, 0, 1, and 2 are not considered to be magic numbers.
**/
@name("MagicNumber")
@desc("Checks that there are no magic numbers. By default, -1, 0, 1, and 2 are not considered to be magic numbers.")
class MagicNumberCheck extends Check {
	/**
		list of magic numbers to ignore during checks
	**/
	public var ignoreNumbers:Array<Float>;

	public function new() {
		super(TOKEN);
		ignoreNumbers = [-1, 0, 1, 2];
		categories = [Category.CLARITY, Category.COMPLEXITY];
		points = 3;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var allTypes:Array<TokenTree> = root.filter([
			Kwd(KwdAbstract),
			Kwd(KwdClass),
			Kwd(KwdEnum),
			Kwd(KwdInterface),
			Kwd(KwdTypedef)
		], First);
		for (type in allTypes) {
			if (TokenTreeCheckUtils.isTypeEnumAbstract(type)) continue;
			checkForNumbers(type);
		}
	}

	function checkForNumbers(parent:TokenTree) {
		var allNumbers:Array<TokenTree> = parent.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Const(CInt(_)): FoundGoDeeper;
				case Const(CFloat(_)): FoundGoDeeper;
				default: GoDeeper;
			}
		});

		for (numberToken in allNumbers) {
			if (isPosSuppressed(numberToken.pos)) continue;
			if (filterNumber(numberToken)) continue;
			switch (numberToken.tok) {
				case Const(CInt(n)):
					var number:Int = Std.parseInt(n);
					if (ignoreNumbers.contains(number)) continue;
					logPos('"$n" is a magic number', numberToken.pos);
				case Const(CFloat(n)):
					var number:Float = Std.parseFloat(n);
					if (ignoreNumbers.contains(number)) continue;
					logPos('"$n" is a magic number', numberToken.pos);
				default:
			}
		}
	}

	function filterNumber(token:TokenTree):Bool {
		if ((token == null) || (token.tok == Root)) return false;
		return switch (token.tok) {
			case At: true;
			#if haxe4
			case Kwd(KwdFinal): true;
			#else
			case Const(CIdent("final")): true;
			#end
			case BrOpen: false;
			case Kwd(KwdVar): if (token.filter([Kwd(KwdStatic)], First).length > 0) true; else false;
			default: filterNumber(token.parent);
		}
	}
}