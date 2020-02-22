import haxe.Timer;

/**
	helper class to build everything, avoids `--next`
**/
class Build {
	private static var exitCode:Int = 0;

	/**
		run all build files
	**/
	public static function main() {
		callLix("build.hxml", "run.n");
		callLix("buildDebug.hxml", "runD.n");
		callLix("buildJS.hxml", "run.js");
		callLix("buildSchema.hxml", "Json schema");
		callLix("buildTest.hxml", "Unittests");
		Sys.exit(exitCode);
	}

	/**
		perform lix call and take build times

		@param buildFile HXML build file
		@param title description to use when printing build time
	**/
	public static function callLix(buildFile:String, title:String) {
		var startTime = Timer.stamp();
		var result:Int = Sys.command("npx", ["haxe", buildFile]);
		Sys.println('building $title (${Timer.stamp() - startTime})');
		if (result != 0) {
			exitCode = result;
		}
	}
}