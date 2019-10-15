import haxe.Timer;

/**
	helper class to build everything, avoids `--next`
**/
class Build {
	/**
		run all build files
	**/
	public static function main() {
		callLix("build.hxml", "run.n");
		callLix("buildDebug.hxml", "runD.n");
		callLix("buildJS.hxml", "run.js");
		callLix("buildSchema.hxml", "Json schema");
		callLix("buildTest.hxml", "Unittests");
	}

	/**
		perform lix call and take build times

		@param buildFile HXML build file
		@param title description to use when printing build time
	**/
	public static function callLix(buildFile:String, title:String) {
		var startTime = Timer.stamp();
		Sys.command("npx", ["haxe", buildFile]);
		Sys.println('building $title (${Timer.stamp() - startTime})');
	}
}