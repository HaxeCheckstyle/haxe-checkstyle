package checkstyle.checks.coding;

/**
	Checks that long decimal numbers include underscores as a separator.
**/
@name("LongNumber")
@desc("Checks that there are no long decimal numbers without separators.")
class LongNumberCheck extends Check {
	/**
		list of long numbers to ignore during checks
	**/
	public var ignoreNumbers:Array<Float>;

	/**
	 	whether to check hexadecimal (`0x12345678`) numbers
	**/
	public var checkHexadecimal:Bool;

	/**
	 	whether to check binary (`0b10001001`) numbers
	**/
	public var checkBinary:Bool;

	public function new() {
		super(TOKEN);
		categories = [Category.CLARITY, Category.COMPLEXITY];
		points = 3;

		ignoreNumbers = [];
		checkHexadecimal = false;
		checkBinary = false;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var allTypes:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdAbstract) | Kwd(KwdClass) | Kwd(KwdEnum) | Kwd(KwdInterface) | Kwd(KwdTypedef):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});
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

		var longNumber:EReg = ~/[0-9]{4,}/;

		for (numberToken in allNumbers) {
			if (isPosSuppressed(numberToken.pos)) continue;
			if (filterNumber(numberToken)) continue;
			switch (numberToken.tok) {
				case Const(CInt(n, s)):
					var number:Int = Std.parseInt(n.replace("_", ""));
					if (ignoreNumbers.contains(number)) continue;
					if (s == null) s = "";

					if (!checkHexadecimal && n.startsWith("0x")) continue;
					if (!checkBinary && n.startsWith("0b")) continue;

					if (longNumber.match(n)) logPos('"$n${s ?? ''}" is a long number, use _ as a separator', numberToken.pos);
				case Const(CFloat(n, s)):
					var number:Float = Std.parseFloat(n.replace("_", ""));
					if (ignoreNumbers.contains(number)) continue;
					if (s == null) s = "";

					if (longNumber.match(n)) logPos('"$n${s ?? ''}" is a long number, use _ as a separator', numberToken.pos);
				default:
			}
		}
	}

	function filterNumber(token:TokenTree):Bool {
		if ((token == null) || (token.tok == Root)) return false;
		return switch (token.tok) {
			case At: true;
			case Kwd(KwdFinal): true;
			case BrOpen: false;
			case Kwd(KwdVar): if (token.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
					return switch (token.tok) {
						case Kwd(KwdStatic):
							FoundSkipSubtree;
						default:
							GoDeeper;
					}
				}).length > 0) {
					true;
				}
				else {
					false;
				}
			default: filterNumber(token.parent);
		}
	}
}