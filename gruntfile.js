module.exports = function (grunt) {

    grunt.initConfig({
         pkg: grunt.file.readJSON("package.json"),

         haxe: {
             project: {
                 hxml: "build.hxml"
             }
         },

         zip: {
             "pixi.zip": ["checkstyle/**", "haxelib.json", "run.n"]
         }
     });

    grunt.loadNpmTasks("grunt-haxe");
    grunt.loadNpmTasks("grunt-zip");
    grunt.loadNpmTasks("grunt-exec");
    grunt.registerTask("default", ["haxe", "exec"]);
};