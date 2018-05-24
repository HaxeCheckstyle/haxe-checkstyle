#if macro
import haxe.DynamicAccess;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import Type as HaxeType;
using haxe.macro.Tools;
using StringTools;

private typedef StructInfo = {
	name:String,
	doc:String,
}
#end

class JsonSchemaGenerator {

	macro public static function generate(type):Expr {
		var refs = new DynamicAccess();
		var schema = genSchema(Context.getType(type.toString()), type.pos, null, refs);
		// Reflect.setField(schema, "@$__hx__$schema", "http://json-schema.org/draft-04/schema#");
		schema.definitions = refs;
		trace (schema);
		trace (Context.parse(Std.string(schema) + ";", type.pos));
		return null;
		// return macro $v{schema};
	}

	macro public static function getValues(typePath:Expr):Expr {
		trace (typePath);
		// Get the type from a given expression converted to string.
		// This will work for identifiers and field access which is what we need,
		// it will also consider local imports. If expression is not a valid type path or type is not found,
		// compiler will give a error here.
		var type = Context.getType(typePath.toString());

		// Switch on the type and check if it's an abstract with @:enum metadata
		switch (type.follow(false)) {
			case TAbstract(_.get() => ab, _) if (ab.meta.has(":enum")):
				// @:enum abstract values are actually static fields of the abstract implementation class,
				// marked with @:enum and @:impl metadata. We generate an array of expressions that access those fields.
				// Note that this is a bit of implementation detail, so it can change in future Haxe versions, but it's been
				// stable so far.
				var valueExprs = [];
				for (field in ab.impl.get().statics.get()) {
					if (field.meta.has(":enum") && field.meta.has(":impl")) {
						var fieldName = field.name;
						valueExprs.push(macro $typePath.$fieldName);
					}
				}
				// Return collected expressions as an array declaration.
				return macro $a{valueExprs};
			default:
				// The given type is not an abstract, or doesn't have @:enum metadata, show a nice error message.
				throw new Error(type.toString() + " should be @:enum abstract", typePath.pos);
		}
	}

	#if macro

	static function getValues2(typePath:Expr):Expr {
		trace (typePath);
		// Get the type from a given expression converted to string.
		// This will work for identifiers and field access which is what we need,
		// it will also consider local imports. If expression is not a valid type path or type is not found,
		// compiler will give a error here.
		var type = Context.getType(typePath.toString());

		// Switch on the type and check if it's an abstract with @:enum metadata
		switch (type.follow(false)) {
			case TAbstract(_.get() => ab, _) if (ab.meta.has(":enum")):
				// @:enum abstract values are actually static fields of the abstract implementation class,
				// marked with @:enum and @:impl metadata. We generate an array of expressions that access those fields.
				// Note that this is a bit of implementation detail, so it can change in future Haxe versions, but it's been
				// stable so far.
				var valueExprs = [];
				for (field in ab.impl.get().statics.get()) {
					if (field.meta.has(":enum") && field.meta.has(":impl")) {
						var fieldName = field.name;
						valueExprs.push(macro $typePath.$fieldName);
					}
				}
				// Return collected expressions as an array declaration.
				return macro $a{valueExprs};
			default:
				// The given type is not an abstract, or doesn't have @:enum metadata, show a nice error message.
				throw new Error(type.toString() + " should be @:enum abstract", typePath.pos);
		}
	}

	static function genSchema(type:Type, pos:Position, structInfo:Null<StructInfo>, refs:DynamicAccess<JsonSchema>):JsonSchema {
		switch (type) {
			case TType(_.get() => dt, params):
				return switch [dt, params] {
					case [{pack: [], name: "Null"}, [realT]]:
						genSchema(realT, pos, null, refs);
					default:
						if (!refs.exists(dt.name)) {
							refs[dt.name] = null;
							var schema = genSchema(dt.type.applyTypeParameters(dt.params, params), dt.pos, {name: dt.name, doc: dt.doc}, refs);
							refs[dt.name] = schema;
						}
						return {"@$__hx__$ref": '#/definitions/${dt.name}'};
					}

			case TInst(_.get() => cl, params):
				switch [cl, params] {
					case [{pack: [], name: "String"}, []]:
						return {type: "string"};
					case [{pack: [], name: "Array"}, [elemType]]:
						return {
							type: "array",
							items: genSchema(elemType, pos, null, refs)
							};
					default:
				}

			case TAbstract(_.get() => ab, params):
				switch [ab, params] {
					case [{pack: [], name: "Int"}, []]:
						return {type: "integer"};
					case [{pack: [], name: "Float"}, []]:
						return {type: "number"};
					case [{pack: [], name: "Bool"}, []]:
						return {type: "boolean"};
					default:
						if (ab.meta.has(":enum")) {
							var values:Array<String> = [];
							for (field in ab.impl.get().statics.get()) {
								if (field.meta.has(":enum") && field.meta.has(":impl")) {
									var fieldName = field.name;
									values.push(ab.module + "." + fieldName);
								}
							}
							return {type: "string", _enum: values.join (",")};

							// var valueExprs:Expr;

							// // // 		// trace (ab.module);
							// var pack:Array<String> = ab.module.split(".");
							// trace (JsonSchemaGenerator.getValues2(macro $p{pack}));

							// valueExprs = null;
							// trace ($e{JsonSchemaGenerator.getValues2(macro $p{pack})});
							// trace (macro $e{JsonSchemaGenerator.getValues2(macro $p{pack})});
							// return  {type: "string", _enum: macro $e{JsonSchemaGenerator.getValues2(macro $p{pack})}};
						// trace (macro $p{pack});
						// var xx:String = Std.string(macro $p{pack});
						// trace(xx);
						// valueExprs = JsonSchemaGenerator.getValues2(xx);
						// // for (field in ab.impl.get().statics.get()) {
						// // 	if (field.meta.has(":enum") && field.meta.has(":impl")) {
						// // 		var fieldName = field.name;
						// // 		// trace (fieldName);
						// // 		// trace (field);
						// // 		// trace (ab);
						// // 		// trace (ab.impl.get());
						// // 		trace (field);
						// // 		// trace (ab.impl.get().statics.toString());
						// // 		// trace (type);
						// // 		// trace (ab.module);
						// // 		var pack:Array<String> = ab.module.split(".");
						// // 		pack.push(fieldName);
						// // 		// var name = pack.pop();
						// // 		// var tp:TypePath = {
						// // 		// 	pack: pack,
						// // 		// 	name: name
						// // 		// };
						// // 		// trace(tp);

						// // 		// trace ($p{[tp, fieldName]});

						// // 		// trace(macro $tp.$fieldName);
						// // 		// trace ($v{[ab.module,fieldName]});
						// // 		// var val = marco : $i{ab.module};
						// // 		// trace (val);
						// // 		// var expr = Context.makeExpr(type, pos);
						// // 		// trace (expr);
						// // 		// trace($p{[field]});
						// // 		trace (macro $p{pack});
						// // 		trace ($p{pack});
						// // 		var module = ab.module;
						// // 		// trace (macro new $type());
						// // 		// trace (macro $type.$fieldName);
						// // 		// trace ($v{macro $realType.$fieldName});
						// // 		trace (macro $p{[module, fieldName]});
						// // 		var field = macro $p{[module, fieldName]};
						// // 		// trace(field);

						// // 		// valueExprs.push($v{[ab.module, fieldName]});
						// // 		valueExprs.push(macro $p{pack});
						// // 		// expr.$fieldName
						// // 	}
						// }
						// trace(valueExprs);
						// return valueExprs;
						}
					// trace(ab);
					// trace(params);
				}

			case TAnonymous(_.get() => anon):
				var props = new DynamicAccess();
				var required = [];

				// sort by declaration position
				anon.fields.sort(function(a, b) return a.pos.getInfos().min - b.pos.getInfos().min);

				for (i in 0...anon.fields.length) {
					var f = anon.fields[i];
					var schema = genSchema(f.type, f.pos, null, refs);
					schema.propertyOrder = i;
					if (f.doc != null) {
						schema.description = f.doc.trim();
					}
					props[f.name] = schema;
					if (!f.meta.has(":optional")) {
						required.push(f.name);
					}
				}
				var schema:JsonSchema = {
					type: "object",
					properties: props,
					additionalProperties: false,
				}
				if (required.length > 0) {
					schema.required = required;
				}
				if (structInfo != null) {
					if (structInfo.doc != null) {
						schema.description = structInfo.doc.trim();
					}
				}
				return schema;

			default:
		}
		trace (type);
		throw new Error("Cannot generate Json schema for type ", pos); // + type.toString(), pos);
	}
	#end
}
