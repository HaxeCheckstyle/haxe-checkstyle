import haxe.Json;
import haxe.io.Path;
import sys.io.File;

class SchemaGenerator {
	public static function main() {
		var exludeConfig = CheckstyleSchemaGenerator.generate("checkstyle.config.ExcludeConfig",
			"https://raw.githubusercontent.com/HaxeCheckstyle/haxe-checkstyle/dev/resources/checkstyle-excludes-schema.json");
		File.saveContent(Path.join(["resources", "checkstyle-excludes-schema.json"]), Json.stringify(exludeConfig, "    "));

		var config = CheckstyleSchemaGenerator.generate("checkstyle.config.Config",
			"https://raw.githubusercontent.com/HaxeCheckstyle/haxe-checkstyle/dev/resources/checkstyle-schema.json");
		File.saveContent(Path.join(["resources", "checkstyle-schema.json"]), Json.stringify(config, "    "));
	}
}