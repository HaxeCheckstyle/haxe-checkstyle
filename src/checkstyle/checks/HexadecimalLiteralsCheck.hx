package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("HexadecimalLiterals")
class HexadecimalLiteralsCheck extends Check {

	public static inline var DESC:String = "Checks Hexadecimal Literals";

	public function new() {
		super();
	}

	override function actualRun() {
		ExprUtils.walkFile(_checker.ast, function(e) {
			switch(e.expr){
				case EConst(CInt(s)):
					checkString(s, e.pos);
				default:
			}
		});
	}

	var lowerPrefix = true;
	var lowerBody = false;

	function checkString(s:String, p) {
		var prefix = s.substr(0, 2);
		if (prefix.toLowerCase() == "0x") {
			var prefixExpected = prefix;
			if (lowerPrefix) prefixExpected = prefixExpected.toLowerCase();
			else prefixExpected = prefixExpected.toUpperCase();
			if (prefix != prefixExpected) logPos('Bad hexademical literal', p, SeverityLevel.INFO);

			var bodyActual = s.substr(2);
			var bodyExpected = bodyActual;
			if (lowerBody) bodyExpected = bodyExpected.toLowerCase();
			else bodyExpected = bodyExpected.toUpperCase();
			if (bodyExpected != bodyActual) logPos('Bad hexademical literal', p, SeverityLevel.INFO);
		}
	}
}