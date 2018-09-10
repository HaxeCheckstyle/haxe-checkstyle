package checkstyle.checks.meta;

/**
	Checks for redundant @:access metadata
**/
@name("RedundantAccessMeta")
@desc("Checks for redundant @:access metadata")
class RedundantAccessMetaCheck extends RedundantAccessMetaBase {
	public function new() {
		super("access");
	}
}