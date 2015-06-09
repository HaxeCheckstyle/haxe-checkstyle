package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("PublicPrivate")
@desc("Check for explicit use of private in classes and public in interfaces/externs")
class PublicPrivateCheck extends Check {

	public var enforcePublicPrivate:Bool;

	public function new() {
		super();
		enforcePublicPrivate = false;
	}

	override function actualRun() {
		for (td in checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					checkFields(d);
				default:
			}
		}
	}

	function checkFields(d:Definition<ClassFlag, Array<Field>>) {
		for (field in d.data) {
			if (isCheckSuppressed (field)) continue;
			if (field.name != "new") {
				if (d.flags.indexOf(HInterface) > -1) checkInterfaceField(field);
				else checkField(field);
			}
		}
	}

	function checkInterfaceField(f:Field) {
		if (enforcePublicPrivate) {
			if (f.access.indexOf(APublic) < 0) {
				warnPublicKeywordMissing(f.name, f.pos);
				return;
			}
		}
		else {
			if (f.access.indexOf(APublic) > -1) {
				warnPublicKeyword(f.name, f.pos);
				return;
			}
		}
	}

	function checkField(f:Field) {
		if (isCheckSuppressed (f)) return;
		if (enforcePublicPrivate) {
			if ((f.access.indexOf(APublic) < 0) && (f.access.indexOf(APrivate) < 0)) {
				warnPrivateKeywordMissing(f.name, f.pos);
				return;
			}
		}
		else {
			if (f.access.indexOf(APrivate) > -1) {
				warnPrivateKeyword(f.name, f.pos);
				return;
			}
		}
	}

	function warnPrivateKeyword(name:String, pos:Position) {
		logPos('No need of private keyword: ${name} (fields are by default private in classes)', pos, Reflect.field(SeverityLevel, severity));
	}

	function warnPublicKeyword(name:String, pos:Position) {
		logPos('No need of public keyword: ${name} (fields are by default public in interfaces)', pos, Reflect.field(SeverityLevel, severity));
	}

	function warnPrivateKeywordMissing(name:String, pos:Position) {
		logPos('Missing private keyword: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}

	function warnPublicKeywordMissing(name:String, pos:Position) {
		logPos('Missing public keyword: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}
}