package checkstyle.checks.modifier;

import checkstyle.utils.PosHelper;

/**
	Checks for redundant modifiers.
	Omitting the visibility modifier usually defaults the visibility to "private" in normal classes and "public" in interfaces and externs.
**/
@name("RedundantModifier", "PublicPrivate")
@desc("Checks for redundant modifiers.")
class RedundantModifierCheck extends Check {
	/**
		enforce use of "public" and "private" modifiers
		implies enforcePublic and enforcePrivate
	**/
	public var enforcePublicPrivate:Bool;

	/**
		enforce use of "public" modifiers
	**/
	public var enforcePublic:Bool;

	/**
		enforce use of "private" modifiers
	**/
	public var enforcePrivate:Bool;

	public function new() {
		super(AST);
		enforcePublicPrivate = false;
		enforcePublic = false;
		enforcePrivate = false;
		categories = [Category.STYLE, Category.CLARITY];
		points = 1;
	}

	override function actualRun() {
		var forcePrivate:Bool = enforcePrivate;
		var forcePublic:Bool = enforcePublic;
		if (enforcePublicPrivate) {
			forcePrivate = true;
			forcePublic = true;
		}
		forEachField(function(f:Field, p:ParentType) {
			checkField(f, p, forcePrivate, forcePublic);
		});
	}

	function checkField(f:Field, p:ParentType, forcePrivate:Bool, forcePublic:Bool) {
		var isDefaultPrivate = f.isDefaultPrivate(p);
		var implicitAccess = isDefaultPrivate ? "private" : "public";
		var missingCode:String = isDefaultPrivate ? MISSING_PRIVATE : MISSING_PUBLIC;
		var redundantCode:String = isDefaultPrivate ? REDUNDANT_PRIVATE : REDUNDANT_PUBLIC;
		if (!f.access.contains(APublic) && !f.access.contains(APrivate)) {
			if ((!isDefaultPrivate && forcePublic) || (isDefaultPrivate && forcePrivate)) {
				logPos('Missing "$implicitAccess" keyword for "${f.name}"', PosHelper.makeFieldSignaturePosition(f), missingCode);
			}
		}

		if ((!forcePrivate && isDefaultPrivate && f.access.contains(APrivate))
			|| (!forcePublic && !isDefaultPrivate && f.access.contains(APublic))) {
			logPos('"$implicitAccess" keyword is redundant for "${f.name}"', PosHelper.makeFieldSignaturePosition(f), redundantCode);
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "enforcePrivate",
				values: [true, false]
			}, {
				propertyName: "enforcePublic",
				values: [true, false]
			}, {
				propertyName: "enforcePublicPrivate",
				values: [true, false]
			}]
		}];
	}
}

enum abstract RedundantModifierCode(String) to String {
	var MISSING_PUBLIC = "MissingPublic";
	var MISSING_PRIVATE = "MissingPrivate";
	var REDUNDANT_PUBLIC = "RedundantPublic";
	var REDUNDANT_PRIVATE = "RedundantPrivate";
}