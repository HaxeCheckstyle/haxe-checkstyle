#if macro
import haxe.DynamicAccess;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using StringTools;

typedef ExtendedFieldsCB = Array<ObjectDeclField> -> String -> Position -> DynamicAccess<Expr> -> Void;
#end

// adapted from https://github.com/nadako/haxe-type-to-json-schema
class JsonSchemaGenerator {
	macro public static function generate(type:String, id:String):Expr {
		return generateWithCallback(type, id, null);
	}

	#if macro
	public static function generateWithCallback(type:String, id:String, extendedFieldsCB:ExtendedFieldsCB):Expr {
		var refs = new DynamicAccess();

		var main:Expr = genSchema(Context.getType(type), type, Context.currentPos(), null, refs, -1, extendedFieldsCB);

		var refList:Array<ObjectDeclField> = [];
		for (name in refs.keys()) {
			refList.push({field: name, expr: refs.get(name)});
		}

		var definitions:Expr = SchemaUtils.makeObjectDecl(refList, null, -1, Context.currentPos());
		switch (main.expr) {
			case EObjectDecl(fields):
				fields.push({field: "definitions", expr: definitions});
				fields.push({field: DollarName.DollarSchema, expr: macro "http://json-schema.org/schema#"});
				if (id != null) {
					fields.push({field: "id", expr: macro '$id'});
				}
			default:
		}
		return main;
	}

	public static function getAbstractEnumValues(typePath:Expr):Expr {
		// Get the type from a given expression converted to string.
		// This will work for identifiers and field access which is what we need,
		// it will also consider local imports. If expression is not a valid type path or type is not found,
		// compiler will give a error here.
		var type = Context.getType(typePath.toString());

		// Switch on the type and check if it's an abstract with @:enum metadata
		// switch (type.follow(false)) {
		switch (type) {
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

	public static function genSchema(type:Type, typeName:String, pos:Position, structInfo:Null<StructInfo>, refs:DynamicAccess<Expr>, order:Int,
			extendCB:ExtendedFieldsCB):Expr {
		switch (type) {
			case TType(_.get() => dt, params):
				return switch [dt, params] {
					case [{pack: [], name: "Null"}, [realT]]:
						genSchema(realT, typeName, pos, structInfo, refs, order, extendCB);
					default:
						if (!refs.exists(dt.name)) {
							refs[dt.name] = null;
							var doc:StructInfo = SchemaUtils.makeStructInfo(dt.name, dt.doc);
							var schema = genSchema(dt.type.applyTypeParameters(dt.params, params), dt.name, dt.pos, doc, refs, -1, extendCB);
							refs[dt.name] = schema;
						}
						return SchemaUtils.makeObjectDecl([{field: DollarName.DollarRef, expr: macro '#/definitions/${dt.name}'}], structInfo, order, pos);
				}

			case TInst(_.get() => cl, params):
				switch [cl, params] {
					case [{pack: [], name: "String"}, []]:
						return SchemaUtils.makeObjectDecl([{field: "type", expr: macro "string"}], structInfo, order, pos);
					case [{pack: [], name: "Array"}, [elemType]]:
						var fields:Array<ObjectDeclField> = [
							{field: "type", expr: macro "array"},
							{field: "items", expr: genSchema(elemType, typeName + ".items", pos, null, refs, -1, extendCB)}
						];
						if (extendCB != null) extendCB(fields, typeName, pos, refs);
						return SchemaUtils.makeObjectDecl(fields, structInfo, order, pos);
					default:
						var fields:Array<ObjectDeclField> = [];
						if (extendCB != null) extendCB(fields, typeName, pos, refs);
						if (fields.length > 0) return SchemaUtils.makeObjectDecl(fields, structInfo, order, pos);
				}

			case TAbstract(_.get() => ab, params):
				switch [ab, params] {
					case [{pack: [], name: "Int"}, []]:
						var fields:Array<ObjectDeclField> = [{field: "type", expr: macro "integer"}];
						if (extendCB != null) extendCB(fields, typeName, pos, refs);
						return SchemaUtils.makeObjectDecl(fields, structInfo, order, pos);
					case [{pack: [], name: "Float"}, []]:
						return SchemaUtils.makeObjectDecl([{field: "type", expr: macro "number"}], structInfo, order, pos);
					case [{pack: [], name: "Bool"}, []]:
						return SchemaUtils.makeObjectDecl([{field: "type", expr: macro "boolean"}], structInfo, order, pos);
					case [{pack: [], name: "Any"}, []]:
						return SchemaUtils.makeObjectDecl([{field: "type", expr: macro "object"}], structInfo, order, pos);
					case [{pack: [], name: "Null"}, [t]]:
						return genSchema(t, typeName, pos, null, refs, -1, extendCB);
					default:
						if (ab.meta.has(":enum")) {
							if (structInfo == null) structInfo = SchemaUtils.makeStructInfo(ab.name, ab.doc);
							var pack:Array<String> = ab.module.split(".");
							if (pack[pack.length - 1] != ab.name) pack.push(ab.name);
							return SchemaUtils.makeEnum(getAbstractEnumValues(macro $p{pack}), structInfo, order, pos);
						}
				}

			case TAnonymous(_.get() => anon):
				var required = [];
				// sort by declaration position
				anon.fields.sort(function(a, b) return a.pos.getInfos().min - b.pos.getInfos().min);
				var props:Array<ObjectDeclField> = [];
				for (i in 0...anon.fields.length) {
					var f = anon.fields[i];
					var doc:StructInfo = SchemaUtils.makeStructInfo(f.name, f.doc);
					props.push({field: f.name, expr: genSchema(f.type, typeName + "." + f.name, f.pos, doc, refs, i, extendCB)});
					if (!f.meta.has(":optional")) {
						required.push(f.name);
					}
				}
				if (extendCB != null) {
					extendCB(props, typeName, pos, refs);
				}
				return SchemaUtils.makeObject({pos: pos, expr: EObjectDecl(props)}, structInfo, required, order, pos);

			default:
		}
		throw new Error("Cannot generate Json schema for type " + type, pos); // + type.toString(), pos);
	}
	#end
}