package checkstyle.checks.literal;

/**
	Checks the letter case of hexadecimal literals.
**/
@name("HexadecimalLiteral", "HexadecimalLiterals")
@desc("Checks the letter case of hexadecimal literals.")
class HexadecimalLiteralCheck extends Check {
	/**
		policy for hexadecimal literals
		- upperCase = use uppercase for all letters
		- lowerCase = use lowercase for all letters
	**/
	public var option:HexadecimalLiteralPolicy;

	public function new() {
		super(AST);
		option = UPPER_CASE;
		categories = [Category.STYLE, Category.CLARITY];
		points = 1;
	}

	override function actualRun() {
		if (checker.ast == null) return;
		checker.ast.walkFile(function(e:Expr) {
			switch (e.expr) {
				case EConst(CInt(s)):
					checkString(s, e.pos);
				default:
			}
		});
	}

	function checkString(s:String, p) {
		var prefix = s.substr(0, 2);
		if (prefix.toLowerCase() == "0x") {
			var bodyActual = s.substr(2);
			var bodyExpected = bodyActual;
			if (option == LOWER_CASE) bodyExpected = bodyExpected.toLowerCase();
			else bodyExpected = bodyExpected.toUpperCase();
			if (bodyExpected != bodyActual) logPos("Bad hexadecimal literal, use " + option, p);
		}
	}
}

/**
	policy for hexadecimal literals
	- upperCase = use uppercase for all letters
	- lowerCase = use lowercase for all letters
**/
enum abstract HexadecimalLiteralPolicy(String) {
	var UPPER_CASE = "upperCase";
	var LOWER_CASE = "lowerCase";
}