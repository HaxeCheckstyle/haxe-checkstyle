module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON("package.json"),

        shell: {
            libs: {
                command: "haxelib install haxeparser 3.3.0 && " +
                    "haxelib install hxargs 3.0.2 && " +
                    "haxelib install compiletime 2.6.0 && " +
                    "haxelib install mcover 2.1.1 && " +
                    "haxelib install munit && " +
                    "haxelib install tokentree"
            }
        },
        haxe: haxeOptions(),
        zip: zipIt()
    });

    grunt.loadNpmTasks("grunt-haxe");
    grunt.loadNpmTasks("grunt-zip");
    grunt.loadNpmTasks("grunt-shell");
    grunt.registerTask("default", ["shell", "haxe:all"]);
};

function haxeOptions() {
    return {
        all: {
            hxml: "buildAll.hxml"
        },
        build: {
            hxml: "build.hxml"
        },
        test: {
            hxml: "buildTest.hxml"
        },
        debug: {
            hxml: "buildDebug.hxml"
        },
        telemetry: {
            hxml: "buildTelemetry.hxml"
        }
    };
}

function zipIt() {
    return {
        release: {
            src: [
                "src/**",
                "resources/sample-config.json", "resources/logo.png", "resources/codeclimate_pr.png",
                "haxelib.json", "run.n", "haxecheckstyle.js", "README.md", "CHANGELOG.md", "LICENSE.md"
            ],
            dest: "haxe-checkstyle.zip",
            compression: "DEFLATE",
        }
    };
}