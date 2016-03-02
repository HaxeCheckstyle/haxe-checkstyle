module.exports = function (grunt) {

    grunt.initConfig({
         pkg: grunt.file.readJSON("package.json"),

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
    grunt.registerTask("default", ["haxe"]);
};