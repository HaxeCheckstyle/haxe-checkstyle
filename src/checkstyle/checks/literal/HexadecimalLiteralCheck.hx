package checkstyle.checks.literal;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("HexadecimalLiteral", "HexadecimalLiterals")
@desc("Checks the letter case of hexadecimal literals")
class HexadecimalLiteralCheck extends Check {

	public var option:String;

	public function new() {
		super();
		option = "upperCase";
	}

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e:Expr) {
			switch (e.expr){
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
			if (option.toLowerCase() == "lowercase") bodyExpected = bodyExpected.toLowerCase();
			else bodyExpected = bodyExpected.toUpperCase();
			if (bodyExpected != bodyActual) logPos('Bad hexademical literal, use ' + option, p, Reflect.field(SeverityLevel, severity));
		}
	}
}