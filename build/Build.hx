import haxe.Timer;

class Build {
	public static function main() {
		callLix("build.hxml", "run.n");
		callLix("buildDebug.hxml", "runD.n");
		callLix("buildJS.hxml", "run.js");
		callLix("buildSchema.hxml", "Json schema");
		callLix("buildTest.hxml", "Unittests");
	}

	public static function callLix(buildFile:String, title:String) {
		var startTime = Timer.stamp();
		Sys.command("npx", ["haxe", buildFile]);
		Sys.println('building $title (${Timer.stamp() - startTime})');
	}
}