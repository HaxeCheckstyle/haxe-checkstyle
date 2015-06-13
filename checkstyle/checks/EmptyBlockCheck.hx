package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxe.macro.Expr;

@name("EmptyBlock")
@desc("Checks empty blocks / object declarations")
class EmptyBlockCheck extends Check {

	// require comment in empty block / object decl
	public static inline var TEXT:String = "text";
	// empty block / object decl can be empty or have comments
	// if block has no comments, enforces {} notation
	public static inline var EMPTY:String = "empty";

	public var option:String;

	public function new() {
		super();
		option = EMPTY;
	}

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e) {
			if (isPosSuppressed(e.pos)) return;
			switch(e.expr){
				case EBlock([]) | EObjectDecl([]):
					checkEmptyBlock(e);
				default:
			}
		});
	}

	function checkEmptyBlock(e:Expr) {
		if ((e == null) || (e.expr == null)) return;

		var block:String = checker.file.content.substring(e.pos.min, e.pos.max);
		var containsOnlyWS:Bool = (~/\{\s+\}/m.match(block));
		var containsText:Bool = (~/\{\s*\S.*\S\s*\}/m.match(block));

		if (option == TEXT) {
			if (!containsText) {
				logPos("Empty block should contain a comment", e.pos, Reflect.field(SeverityLevel, severity));
			}
			return;
		}
		if (containsOnlyWS) {
			logPos("Empty block should be written as {}", e.pos, Reflect.field(SeverityLevel, severity));
		}
	}
}