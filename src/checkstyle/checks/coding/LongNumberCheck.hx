package checkstyle.checks.coding;

/**
	Checks that long decimal numbers include underscores as a separator.
**/
@name("LongNumber")
@desc("Checks that there are no long decimal numbers without separators.")
class LongNumberCheck extends Check {

	/**
		the separator used for long numbers
		this isn't configurable because it's part of the Haxe language syntax
	**/
	static final SEPARATOR:String = "_";

	/**
		the separator used for the fractional part of floating point numbers
	**/
	static final FRACTIONAL_SEPARATOR:String = ".";

	/**
		regular expression used to validate decimal numbers for separators
		`n` is replaced with the value of `decimalGroupSize`
	**/
	static final DECIMAL_GROUP_REGEX:String = "^\\d{1,n}(_\\d{n})*(\\.\\d*?)?$";

	/**
		regular expression used to validate decimal numbers for separators
		`n` is replaced with the value of `decimalGroupSize`
		`m` is replaced with the value of `fractionalGroupSize`
	**/
	static final DECIMAL_FRACTIONAL_GROUP_REGEX:String = "^\\d{1,n}(_\\d{n})*(\\.(\\d{1,m}(_\\d{m})*)?)?$";

	/**
		the prefix used to identify hexadecimal numbers
	**/
	static final HEXADECIMAL_PREFIX:String = "0x";

	/**
		regular expression used to validate hexadecimal numbers for separators
		`n` is replaced with the value of `hexadecimalGroupSize`
	**/
	static final HEXADECIMAL_GROUP_REGEX:String = "^0x[0-9A-Fa-f]{1,n}(_[0-9A-Fa-f]{n})*$";

	/**
		the prefix used to identify binary numbers
	**/
	static final BINARY_PREFIX:String = "0b";

	/**
		regular expression used to validate binary numbers for separators
		`n` is replaced with the value of `binaryGroupSize`
	**/
	static final BINARY_GROUP_REGEX:String = "^0b[0-1]{1,n}(_[0-1]{n})*$";

	/**
		for decimal numbers, the number of consecutive digits before it's a long number
		defaults to `3`, where `1000` is a long number but `1_000` is valid
		use `-1` to disable the check entirely
	**/
	public var decimalGroupSize(default, set):Int;

	function set_decimalGroupSize(value:Int):Int {
		decimalGroupSize = value;
		if (initialized) updateRegex();
		return decimalGroupSize;
	}

	/**
		for decimal numbers, the minimum quantity before it's a long number
		for example, if set to `1000000`, `999999` requires no separators but `1_000_000` does
		defaults to `0` to disable the check
	**/
	public var decimalMinimum:Int;

	/**
		for floating point decimal numbers, the number of consecutive digits after the decimal pointbefore it's a long number
		for example, where `1000` is a long number but `1_000` is valid
		defaults to `-1` to disable the check
		use `-1` to disable the check entirely
	**/
	public var fractionalGroupSize(default, set):Int;

	function set_fractionalGroupSize(value:Int):Int {
		fractionalGroupSize = value;
		if (initialized) updateRegex();
		return fractionalGroupSize;
	}

	/**
	 	for hexadecimal numbers, the number of consecutive digits before it's a long number
		defaults to `8`, where `0x123456789` is a long number but `0x1_2345678` is valid
		use `-1` to disable the check entirely
	**/
	public var hexadecimalGroupSize(default, set):Int;

	function set_hexadecimalGroupSize(value:Int):Int {
		hexadecimalGroupSize = value;
		if (initialized) updateRegex();
		return hexadecimalGroupSize;
	}

	/**
		for hexadecimal numbers, the minimum quantity before it's a long number
		for example, if set to `0x1000000000`, `0x123456789` requires no separators but `0x12_34567890` does
		defaults to `0` to disable the check
	**/
	public var hexadecimalMinimum:Int;

	/**
	 	for binary numbers, the number of consecutive digits before it's a long number
		defaults to `8`, where `0b101010101` is a long number but `0b1_01010101` is valid
		use `-1` to disable the check entirely
	**/
	public var binaryGroupSize(default, set):Int;

	function set_binaryGroupSize(value:Int):Int {
		binaryGroupSize = value;
		if (initialized) updateRegex();
		return binaryGroupSize;
	}

	/**
		the regular expression used to validate decimal numbers are properly separated
		`null` if the decimal group size is `-1` to indicate grouping is disabled
	**/
	var decimalGroupRegex:Null<EReg>;

	/**
		the regular expression used to validate decimal numbers are properly separated
		`null` if the hexadecimal group size is `-1` to indicate grouping is disabled
	**/
	var hexadecimalGroupRegex:Null<EReg>;

	/**
		the regular expression used to validate decimal numbers are properly separated
		`null` if the binary group size is `-1` to indicate grouping is disabled
	**/
	var binaryGroupRegex:Null<EReg>;

	public function new() {
		super(TOKEN);
		categories = [Category.CLARITY, Category.COMPLEXITY];
		points = 3;

		// default group sizes
		decimalGroupSize = 3;
		fractionalGroupSize = -1;
		hexadecimalGroupSize = 8;
		binaryGroupSize = 8;

		// minimum quantity
		decimalMinimum = 0;
		hexadecimalMinimum = 0;

		initialized = true;

		updateRegex();
	}

	/**
		first time regex generation happens only after every group size is initialized
	**/
	var initialized:Bool;

	function updateRegex() {
		if (decimalGroupSize > 0) {
			if (fractionalGroupSize <= 0) {
				decimalGroupRegex = new EReg(DECIMAL_GROUP_REGEX.replace("n", Std.string(decimalGroupSize)), "");
			}
			else {
				decimalGroupRegex = new EReg(DECIMAL_FRACTIONAL_GROUP_REGEX.replace("n", Std.string(decimalGroupSize)).replace("m", Std.string(fractionalGroupSize)), "");
			}
		}
		else {
			decimalGroupRegex = null;
		}

		if (hexadecimalGroupSize > 0) {
			hexadecimalGroupRegex = new EReg(HEXADECIMAL_GROUP_REGEX.replace("n", Std.string(hexadecimalGroupSize)), "");
		}
		else {
			hexadecimalGroupRegex = null;
		}

		if (binaryGroupSize > 0) {
			binaryGroupRegex = new EReg(BINARY_GROUP_REGEX.replace("n", Std.string(binaryGroupSize)), "");
		}
		else {
			binaryGroupRegex = null;
		}
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
				case Const(CInt(n, s)):
					queryInteger(n, s ?? "", numberToken.pos);

				case Const(CFloat(n, s)):
					queryFloat(n, s ?? "", numberToken.pos);

				default:
			}
		}
	}

	function queryInteger(n:String, suffix:String, pos:Position) {
		if (n.startsWith(HEXADECIMAL_PREFIX)) {
			if (hexadecimalGroupRegex == null) return;
			if (Std.parseInt(n) < hexadecimalMinimum) return;
			if (hexadecimalGroupRegex.match(n)) return;

			if (n.contains(SEPARATOR)) {
				// improper use of separators on a hexadecimal number
				logPos('"$n$suffix" uses separators improperly, use _ every $hexadecimalGroupSize digits', pos);
			}
			else {
				// missing separators on a hexadecimal number
				logPos('"$n$suffix" is a long hexadecimal number, use _ as a separator', pos);
			}
		}
		else if (n.startsWith(BINARY_PREFIX)) {
			if (binaryGroupRegex == null) return;
			if (binaryGroupRegex.match(n)) return;

			if (n.contains(SEPARATOR)) {
				// improper use of separators on a binary number
				logPos('"$n$suffix" uses separators improperly, use _ every $binaryGroupSize digits', pos);
			}
			else {
				// missing separators on a binary number
				logPos('"$suffix$n" is a long binary number, use _ as a separator', pos);
			}
		}
		else {
			if (decimalGroupRegex == null) return;
			if (Std.parseInt(n) < decimalMinimum) return;
			if (decimalGroupRegex.match(n)) return;

			if (n.contains(SEPARATOR)) {
				// improper use of separators on a decimal number
				logPos('"$n$suffix" uses separators improperly, use _ every $decimalGroupSize digits', pos);
			}
			else {
				// missing separators on a decimal number
				logPos('"$n$suffix" is a long number, use _ as a separator', pos);
			}
		}
	}

	function queryFloat(n:String, suffix:String, pos:Position) {
		if (decimalGroupSize <= 0) return;
		if (decimalGroupRegex.match(n)) return;

		var f = Std.parseFloat(n);
		if (Math.isNaN(f)) return;
		if (f < decimalMinimum) return;

		if (n.contains(SEPARATOR)) {
			if (n.contains(FRACTIONAL_SEPARATOR) && fractionalGroupSize <= 0) {
				// improper use of separators on a float with fractional part
				logPos('"$n$suffix" uses separators improperly, use _ every $decimalGroupSize digits before the . and $fractionalGroupSize after the .', pos);
			}
			else {
				// improper use of separators on a float with no fractional part
				logPos('"$n$suffix" uses separators improperly, use _ every $decimalGroupSize digits', pos);
			}
		}
		else {
			if (n.contains(FRACTIONAL_SEPARATOR) && fractionalGroupSize <= 0) {
				// missing separators on a float with fractional part
				logPos('"$n$suffix" is a long number, use _ as a separator before the fractional part', pos);
			}
			else {
				// missing separators on a float with no fractional part
				logPos('"$n$suffix" is a long number, use _ as a separator', pos);
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