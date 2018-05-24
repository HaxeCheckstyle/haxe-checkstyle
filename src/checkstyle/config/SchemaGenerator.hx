package checkstyle.config;

import haxe.Json;
import sys.io.File;

import checkstyle.checks.Check;

// import JsonSchemaGenerator;

class SchemaGenerator {

	public function new() {

		// var x:AsllChecks = cast "";

		// trace (JsonSchemaGenerator.getValues(AllCheck));

		// trace (JsonSchemaGenerator.getValues(checkstyle.SeverityLevel));
		// trace (JsonSchemaGenerator.generate(ExcludeConfig));
		// trace (JsonSchemaGenerator.generate(Config));
		// generateExcludesSchema();
		// generateConfigSchema();
	}

	// "checks": {
	//     "type": "array",
	//     "items": {
	//         "anyOf": [
	//             { "$ref": "#/definitions/EmptyBlock" },
	//             { "$ref": "#/definitions/Indentation" }
	//         ]
	//     },
	//     "minItems": 1
	// },


	// function generateConfigSchema() {
	// 	var root:SchemaRootObject = {
	// 		_schema: "http://json-schema.org/schema#",
	// 		id:"http://kewbeetodo.kewbee.home/checkstyle-excludes-schema.json",
	// 		definitions: {
	// 		},
	// 		type: OBJECT,
	// 		properties: {
	// 			checks: {
	// 				type: ARRAY,
	// 				items: {
	// 					anyOf: [
	// 					]
	// 				},
	// 				minItems: 1
	// 			},
	// 			defaultSeverity: {
	// 				type: STRING,
	// 				_enum: [
	// 					SeverityLevel.INFO,
	// 					SeverityLevel.WARNING,
	// 					SeverityLevel.ERROR,
	// 					SeverityLevel.IGNORE
	// 				]
	// 			},
	// 			extendsConfigPath: {
	// 				type: STRING
	// 			},
	// 			baseDefines: {
	// 				type: ARRAY,
	// 				items: {
	// 					type: STRING
	// 				}
	// 			},
	// 			defineCombinations: {
	// 				type: ARRAY,
	// 				items: {
	// 					type: ARRAY,
	// 					items: {
	// 						type: STRING
	// 					}
	// 				}
	// 			},
	// 			numberOfCheckerThreads: {
	// 				type: INTEGER,
	// 				minimum: 1,
	// 				maximum: 15
	// 			},
	// 			exclude : { _ref: "checkstyle-excludes-schema.json" }
	// 		},
	// 		additionalProperties: false
	// 	};
	// 	CompileTime.importPackage("checkstyle.checks");

	// 	var rootProps:Dynamic = root.properties;

	// 	var checks:List<Class<Check>> = CompileTime.getAllClasses(Check);
	// 	for (checkClass in checks) {
	// 		var meta = haxe.rtti.Meta.getType(checkClass);
	// 		if (meta.name == null) continue;
	// 		var checkProperties:SchemaObject = {
	// 			type: OBJECT,
	// 			properties: {
	// 				type: {
	// 					type: STRING,
	// 					_enum: meta.name
	// 				},
	// 				props: {
	// 				}
	// 			}
	// 		};

	// 		var props:Dynamic = checkProperties.properties;

	// 		var propsNotAllowed:Array<String> = [
	// 			"moduleName", "type", "categories",
	// 			"points", "desc", "currentState", "skipOverStringStart",
	// 			"commentStartRE", "commentBlockEndRE", "stringStartRE",
	// 			"stringInterpolatedEndRE", "stringLiteralEndRE", "formatRE",
	// 			"skipOverInitialQuote", "messages", "checker"
	// 		];

	// 		var check = Type.createInstance(checkClass, []);

	// 		for (field in Reflect.fields(check)) {
	// 			if (propsNotAllowed.contains(field)) continue;

	// 			var value = Reflect.field(check, field);
	// 			var f = Type.typeof(value);
	// 			switch (f) {
	// 				case TBool:
	// 					Reflect.setField(props.props, field, {
	// 						type: BOOLEAN,
	// 						_default: value
	// 					});
	// 				case TInt:
	// 					Reflect.setField(props.props, field, {
	// 						type: INTEGER,
	// 						_default: value
	// 					});
	// 				case TFloat:
	// 					Reflect.setField(props.props, field, {
	// 						type: NUMBER,
	// 						_default: value
	// 					});
	// 				case TClass(String):
	// 					Reflect.setField(props.props, field, {
	// 						type: STRING,
	// 						_default: value
	// 					});
	// 				default:
	// 					trace (field);
	// 					trace (f);
	// 			}
	// 		}

	// 		rootProps.checks.items.anyOf.push(checkProperties);
	// 	}

	// 	File.saveContent("checkstyle-schema_gen.json", replaceSpecialNames(Json.stringify(root, "    ")));
	// }

	// function generateExcludesSchema() {
	// 	var root:SchemaRootObject = {
	// 		_schema: "http://json-schema.org/schema#",
	// 		id:"http://kewbeetodo.kewbee.home/checkstyle-excludes-schema.json",
	// 		definitions: {
	// 			excludes: {
	// 				type: ARRAY,
	// 				items: {
	// 					type: STRING
	// 				}
	// 			}
	// 		},
	// 		type: OBJECT,
	// 		properties: {
	// 			path: {
	// 				type: STRING
	// 			},
	// 			all: { _ref: "#/definitions/excludes" }
	// 		},
	// 		additionalProperties: false
	// 	};
	// 	CompileTime.importPackage("checkstyle.checks");
	// 	var checks:List<Class<Check>> = CompileTime.getAllClasses(Check);
	// 	for (checkClass in checks) {
	// 		var meta = haxe.rtti.Meta.getType(checkClass);
	// 		if (meta.name == null) continue;
	// 		Reflect.setField(root.properties, meta.name[0], { _ref: "#/definitions/excludes" });
	// 	}

	// 	File.saveContent("checkstyle-excludes-schema.json", replaceSpecialNames(Json.stringify(root, "    ")));
	// }

	// function replaceSpecialNames(content:String):String {
	// 	content = ~/"_schema"/g.replace(content, "\"$schema\"");
	// 	content = ~/"_ref"/g.replace(content, "\"$ref\"");
	// 	content = ~/"_default"/g.replace(content, "\"default\"");
	// 	content = ~/"_enum"/g.replace(content, "\"enum\"");
	// 	return content;
	// }

	public static function main() {
		new SchemaGenerator();
	}
}

typedef SchemaRootObject = {
	> SchemaObject,

    var _schema:String;
    var id:String;
	var definitions:SchemaDefinitions;
}

typedef SchemaObject = {
	var type:SchemaFieldType;
	var properties:SchemaProperties;
	@:optional var title:String;
	@:optional var description:String;
	@:optional var _default:Any;
	@:optional var _enum:Array<Any>;
	@:optional var additionalItems:Bool;
	@:optional var additionalProperties:Bool;
	@:optional var minItems:Int;
	@:optional var maxItems:Int;
	@:optional var minimum:Int;
	@:optional var maximum:Int;
}

typedef SchemaDefinitions = {}

typedef SchemaProperties = {}

@:enum
abstract SchemaFieldType(String) {
	var OBJECT = "object";
	var ARRAY = "array";
	var BOOLEAN = "boolean";
	var STRING = "string";
	var INTEGER = "integer";
	var NUMBER = "number";
}
