package checkstyle.checks.coding;

/**
	Checks for instance variables that are initialised at class level.
**/
@name("VariableInitialisation")
@desc("Checks for instance variables that are initialised at class level.")
class VariableInitialisationCheck extends Check {
	/**
		final fields must be initialised either immediately or in constructor
		when allowFinal is true then VariableInitialisation won't complain about initialisation at class level for final fields
	**/
	public var allowFinal:Bool;

	public function new() {
		super(AST);
		categories = [Category.STYLE, Category.CLARITY];
		points = 2;
		allowFinal = false;
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, p:ParentType) {
		if (f.isConstructor() || p.kind == INTERFACE || p.kind == ENUM_ABSTRACT) return;

		var isPrivate = false;
		var isPublic = false;
		var isInline = f.access.contains(AInline);
		var isStatic = f.access.contains(AStatic);
		var isFinal = false;

		if (isInline || isStatic) return;

		if (f.access.contains(APublic)) isPublic = true;
		else isPrivate = true;

		if (f.access.contains(AFinal)) isFinal = true;
		if (allowFinal && isFinal) return;

		if (isPrivate || isPublic) {
			switch (f.kind) {
				case FVar(t, e):
					if (e == null) return;
					warnVarInit(f.name, f.pos);
				case _:
			}
		}
	}

	function warnVarInit(name:String, pos:Position) {
		logPos('Invalid variable initialisation for "${name}" (move initialisation to constructor or function)', pos);
	}
}