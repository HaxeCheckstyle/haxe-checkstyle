package checkstyle.checks.meta;

/**
	Checks for redundant @:allow metadata
**/
@name("RedundantAllowMeta")
@desc("Checks for redundant @:allow metadata")
class RedundantAllowMetaCheck extends RedundantAccessMetaBase {
	public function new() {
		super("allow");
	}

	override function filerParent(parent:TokenTree, info:RedundantAccessMetaInfo):Bool {
		var access:TokenTreeAccessHelper = TokenTreeAccessHelper.access(parent).firstOf(Kwd(KwdPublic));
		if (access.token == null) {
			return false;
		}
		logPos('Redundant "@:allow(${info.name})" for public field "${info.ident}" detected', info.token.getPos());
		return true;
	}
}