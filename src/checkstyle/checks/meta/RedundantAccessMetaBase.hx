package checkstyle.checks.meta;

/**
	Checks for redundant @:allow metadata
**/
@ignore("Base class for name checks")
class RedundantAccessMetaBase extends Check {
	/**
		switches behaviour of check to
		- false = look for redundant access modifications
		- true = to discourage its use everywhere
	**/
	public var prohibitMeta:Bool;

	var metaName:String;

	public function new(metaName:String) {
		super(TOKEN);
		this.metaName = metaName;
		prohibitMeta = false;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var docTokens = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case At:
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		var infos:Array<RedundantAccessMetaInfo> = [];

		for (token in docTokens) {
			if (isPosSuppressed(token.pos)) continue;
			var target:TokenTree = TokenTreeAccessHelper.access(token)
				.firstChild()
				.matches(DblDot)
				.firstChild()
				.matches(Const(CIdent(metaName)))
				.firstChild()
				.matches(POpen)
				.firstChild()
				.token;

			if (target == null) continue;
			if (prohibitMeta) {
				logForbidden(token, getTargetName(target));
				continue;
			}
			var parent:TokenTree = token.parent;
			if (parent == null) continue;
			var info:RedundantAccessMetaInfo = {
				name: getTargetName(target),
				ident: parent.toString(),
				token: token,
				pos: parent.getPos()
			};
			if (filerParent(parent, info)) continue;
			checkAndAdd(infos, info);
		}
	}

	function filerParent(parent:TokenTree, info:RedundantAccessMetaInfo):Bool {
		return false;
	}

	function checkAndAdd(infos:Array<RedundantAccessMetaInfo>, newInfo:RedundantAccessMetaInfo) {
		for (info in infos) {
			if ((info.pos.min >= newInfo.pos.max) || (info.pos.max <= newInfo.pos.min)) continue;
			if ((newInfo.name == info.name) || (StringTools.startsWith(newInfo.name, '${info.name}.'))) {
				logPos('Redundant "@:$metaName(${newInfo.name})" for field "${newInfo.ident}" detected', newInfo.token.getPos());
				break;
			}
		}
		infos.push(newInfo);
	}

	function logForbidden(token:TokenTree, name:String) {
		logPos('Consider removing "@:$metaName($name)"', token.getPos());
	}

	function getTargetName(token:TokenTree):String {
		var result:String = "";
		while (token != null) {
			result += token.toString();
			token = token.getFirstChild();
		}
		return result;
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