#if macro
import haxe.DynamicAccess;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import haxe.io.Path;
import haxe.ds.ArraySort;

using StringTools;

typedef CheckName = {
	var name:String;
	var path:String;
}
#end

class CheckstyleSchemaGenerator {
	macro public static function generate(type:String, id:String):Expr {
		return JsonSchemaGenerator.generateWithCallback(type, id, checkstyleFieldsCallback);
	}

	#if macro
	static function checkstyleFieldsCallback(fields:Array<ObjectDeclField>, name:String, pos:Position, refs:DynamicAccess<Expr>):Void {
		switch (name) {
			case "ExcludeConfig":
				var checkList:Array<CheckName> = collectAllChecks(Path.join(["src", "checkstyle", "checks"]));
				sortStrings(checkList);
				var order:Int = fields.length;
				for (check in checkList) {
					var filterListType = Context.getType("checkstyle.config.ExcludeConfig.ExcludeFilterList");
					fields.push({
						field: check.name,
						expr: JsonSchemaGenerator.genSchema(filterListType, "ExcludeFilterList", pos, null, refs, order++, null)
					});
				}
			case "Config.checks":
				fields.pop();
				fields.pop();
				refs.remove("CheckConfig");
				var checkExprs:Array<Expr> = [];
				var checkList:Array<CheckName> = collectAllChecks(Path.join(["src", "checkstyle", "checks"]));
				sortStrings(checkList);
				for (check in checkList) {
					if (check.name == "") continue;
					var type:String = check.path.substr(4);
					checkExprs.push(genCheckSchema(Context.getType(type), check.name, pos, null, refs, -1));
				}
				fields.push({field: "type", expr: macro "array"});
				var anyFields:Array<ObjectDeclField> = [];
				anyFields.push({field: "anyOf", expr: macro $a{checkExprs}});
				fields.push({field: "items", expr: SchemaUtils.makeObjectDecl(anyFields, null, -1, pos)});
			case "Config.numberOfCheckerThreads":
				fields.push({field: "minimum", expr: macro 1});
				fields.push({field: "maximum", expr: macro 15});
			case "Config.version":
				fields.push({field: "minimum", expr: macro 1});
				fields.push({field: "maximum", expr: macro 1});
			case "ExcludeConfig.version":
				fields.push({field: "minimum", expr: macro 1});
				fields.push({field: "maximum", expr: macro 1});
			case "ConstantName.tokens.items":
				makeAnyOfAbstract(fields, "checkstyle.checks.naming.ConstantNameCheck.ConstantNameCheckToken", pos);
			case "LocalVariableName.tokens.items":
				fields.push({field: "type", expr: macro "string"});
			case "MemberName.tokens.items":
				makeAnyOfAbstract(fields, "checkstyle.checks.naming.MemberNameCheck.MemberNameCheckToken", pos);
			case "MethodName.tokens.items":
				makeAnyOfAbstract(fields, "checkstyle.checks.naming.MethodNameCheck.MethodNameCheckToken", pos);
			case "ParameterName.tokens.items":
				fields.push({field: "type", expr: macro "string"});
			case "TypeName.tokens.items":
				makeAnyOfAbstract(fields, "checkstyle.checks.naming.TypeNameCheck.TypeNameCheckToken", pos);

			default:
		}
	}

	static inline function sortStrings(texts:Array<CheckName>) {
		ArraySort.sort(texts, function(a:CheckName, b:CheckName):Int {
			if (a.name > b.name) return 1;
			if (a.name < b.name) return -1;
			return 0;
		});
	}

	static function collectAllChecks(path:String):Array<CheckName> {
		var items:Array<String> = FileSystem.readDirectory(path);
		var checks:Array<CheckName> = [];
		for (item in items) {
			if (item == "." || item == "..") continue;
			var fileName = Path.join([path, item]);
			if (FileSystem.isDirectory(fileName)) {
				checks = checks.concat(collectAllChecks(fileName));
				continue;
			}
			if (!StringTools.endsWith(item, "Check.hx")) {
				continue;
			}
			var name = item.substr(0, item.length - 3);
			if (name.length <= 0) {
				continue;
			}
			var fullPath:String = ~/[\/\\]/g.replace(Path.join([path, name]), ".");
			name = name.substr(0, name.length - 5);
			checks.push({name: name, path: fullPath});
		}
		return checks;
	}

	public static function genCheckSchema(type:Type, typeName:String, pos:Position, structInfo:Null<StructInfo>, refs:DynamicAccess<Expr>, order:Int):Expr {
		switch (type) {
			case TInst(_.get() => cl, params):
				switch [cl, params] {
					case [{name: name, fields: fields}, []]:
						if (!refs.exists(name)) {
							refs[name] = null;
							var classFields:Array<ObjectDeclField> = [];
							addSuperClassFields(typeName, classFields, cl.superClass, pos, refs);
							addClassFields(typeName, classFields, fields.get(), pos, refs);
							classFields.push({
								field: "severity",
								expr: JsonSchemaGenerator.genSchema(Context.getType("checkstyle.SeverityLevel"), typeName + ".severity", pos, null, refs,
									classFields.length,
									null)
							});

							var doc:StructInfo = {name: name, doc: getDescMeta(cl.meta)};
							var props = SchemaUtils.makeObject(SchemaUtils.makeObjectDecl(classFields, null, -1, pos), doc, [], -1, pos);
							var checkName:Array<Expr> = [macro '$typeName'];
							var typeExpr:Expr = macro $a{checkName};
							var type = SchemaUtils.makeEnum(typeExpr, doc, -1, pos);
							var checkFields:Array<ObjectDeclField> = [{field: "type", expr: type}, {field: "props", expr: props}];
							var classExpr:Expr = SchemaUtils.makeObject(SchemaUtils.makeObjectDecl(checkFields, null, -1, pos), doc, [], -1, pos);
							refs[name] = classExpr;
						}
						return SchemaUtils.makeObjectDecl([{field: "@$__hx__$ref", expr: macro '#/definitions/${name}'}], null, order, pos);
					default:
				}
			default:
		}
		throw new Error("Cannot generate Json schema for type " + type, pos); // + type.toString(), pos);
	}

	static function addClassFields(typeName:String, classFields:Array<ObjectDeclField>, fields:Array<ClassField>, pos:Position, refs:DynamicAccess<Expr>) {
		for (field in fields) {
			switch (field.kind) {
				case FVar(_):
					if (field.isPublic) {
						var doc:StructInfo = SchemaUtils.makeStructInfo(field.name, field.doc);
						classFields.push({
							field: field.name,
							expr: JsonSchemaGenerator.genSchema(field.type, typeName + "." + field.name, pos, doc, refs, classFields.length,
								checkstyleFieldsCallback)
						});
					}
				default:
			}
		}
	}

	static function addSuperClassFields(typeName:String, classFields:Array<ObjectDeclField>, superClass:Null<{t:Ref<ClassType>, params:Array<Type>}>,
			pos:Position, refs:DynamicAccess<Expr>) {
		if (superClass == null) return;
		if (superClass.t.get().name == "Check") return;
		addClassFields(typeName, classFields, superClass.t.get().fields.get(), pos, refs);
	}

	static function makeAnyOfAbstract(fields:Array<ObjectDeclField>, type:String, pos:Position) {
		var values:Expr = JsonSchemaGenerator.getAbstractEnumValues(macro $p{type.split(".")});
		fields.push({field: "type", expr: macro "string"});
		fields.push({field: "enum", expr: values});

		var abstractType = Context.getType(type);

		// Switch on the type and check if it's an abstract with @:enum metadata
		// switch (type.follow(false)) {
		switch (abstractType) {
			case TAbstract(_.get() => ab, _) if (ab.meta.has(":enum")):
				var doc:StructInfo = SchemaUtils.makeStructInfo(ab.name, ab.doc);
				if (doc != null) fields.push({field: "description", expr: macro $v{StringTools.trim(doc.doc)}});
			default:
		}
	}

	static function getDescMeta(meta:MetaAccess):String {
		var desc:Array<MetadataEntry> = meta.extract("desc");
		if (desc == null) return null;
		if (desc.length <= 0) return null;
		return switch (desc[0].params[0].expr) {
			case EConst(CString(doc)): doc;
			default: null;
		}
	}
	#end
}