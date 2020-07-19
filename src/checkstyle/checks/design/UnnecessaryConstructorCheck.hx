package checkstyle.checks.design;

/**
	Checks for unnecessary constructor in classes that contain only static methods or fields.
**/
@name("UnnecessaryConstructor")
@desc("Checks for unnecessary constructor in classes that contain only static methods or fields.")
class UnnecessaryConstructorCheck extends Check {
	public function new() {
		super(TOKEN);
		categories = [Category.BUG_RISK];
		points = 3;
	}

	override function actualRun() {
		var classes:Array<TokenTree> = findClasses();
		for (cls in classes) {
			if (extendsBaseClass(cls)) continue;
			if (isPosSuppressed(cls.pos)) continue;

			var acceptableTokens:Array<TokenTree> = cls.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
				return switch (token.tok) {
					case Kwd(KwdFunction) | Kwd(KwdVar):
						FoundSkipSubtree;
					default:
						GoDeeper;
				}
			});

			var haveConstructor:Bool = false;
			var staticTokens:Int = 0;
			var constructorPos = null;
			for (token in acceptableTokens) {
				if (token.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
					if (depth > 2) return SkipSubtree;
					return switch (token.tok) {
						case Kwd(KwdNew):
							FoundSkipSubtree;
						default:
							GoDeeper;
					}
				}).length > 0) {
					haveConstructor = true;
					constructorPos = token.getPos();
					continue;
				}

				if (token.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
					if (depth > 2) return SkipSubtree;
					return switch (token.tok) {
						case Kwd(KwdStatic):
							FoundSkipSubtree;
						default:
							GoDeeper;
					}
				}).length > 0) {
					staticTokens++;
					continue;
				}
			}

			if (haveConstructor && acceptableTokens.length > 1 && acceptableTokens.length == staticTokens + 1) {
				logPos("Unnecessary constructor found", constructorPos);
			}
		}
	}

	function findClasses():Array<TokenTree> {
		return checker.getTokenTree().filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdClass):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
	}

	function extendsBaseClass(cls:TokenTree):Bool {
		var clsName:TokenTree = cls.getFirstChild();
		for (child in clsName.children) {
			if (child.matches(Kwd(KwdExtends))) {
				return true;
			}
		}
		return false;
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: [SeverityLevel.INFO]
			}]
		}];
	}
}