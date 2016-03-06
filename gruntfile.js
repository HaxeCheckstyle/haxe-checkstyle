module.exports = function (grunt) {

	grunt.initConfig({
		pkg: grunt.file.readJSON("package.json"),

		shell: {
			libs: {
				command: "haxelib install haxeparser 3.2.0 && " +
				 		 "haxelib install compiletime 2.6.0 && " +
				 		 "haxelib install hxargs 3.0.0"
			},
		},

		haxe: {
			project: {
				hxml: "build.hxml"
			}
		},

		zip: {
			"checkstyle.zip": ["src/**", "resources/sample-config.json", "haxelib.json", "run.n", "README.md"]
		}
	});

	grunt.loadNpmTasks("grunt-haxe");
	grunt.loadNpmTasks("grunt-zip");
	grunt.loadNpmTasks("grunt-shell");
	grunt.registerTask("default", ["shell", "haxe"]);
};