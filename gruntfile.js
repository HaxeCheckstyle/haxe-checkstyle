module.exports = function (grunt) {

	grunt.initConfig({
		pkg: grunt.file.readJSON("package.json"),

		shell: {
			libs: {
				command: "haxelib install haxeparser 3.2.0 && " +
				"haxelib git hxargs https://github.com/Simn/hxargs && " +
				"haxelib install compiletime 2.6.0 && " +
				"haxelib install mcover 2.1.1"
			}
		},

		haxe: {
			project: {
				hxml: "build.hxml"
			}
		},

		zip: {
			"checkstyle.zip": ["src/**", "resources/sample-config.json", "resources/logo.png", "haxelib.json", "run.n", "README.md"]
		}
	});

	grunt.loadNpmTasks("grunt-haxe");
	grunt.loadNpmTasks("grunt-zip");
	grunt.loadNpmTasks("grunt-shell");
	grunt.registerTask("default", ["shell", "haxe"]);
};