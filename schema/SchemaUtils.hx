#if macro
import haxe.macro.Expr;

class SchemaUtils {

	public static function makeObjectDecl(fields:Array<ObjectDeclField>, structInfo:Null<StructInfo>, order:Int, pos:Position):Expr {
		if (order >= 0) fields.push({field: "propertyOrder", expr: macro $v{order}});
		if (structInfo != null && structInfo.doc != null) {
			fields.push({field: "description", expr: macro $v{StringTools.trim(structInfo.doc)}});
		}
		return {pos: pos, expr: EObjectDecl(fields)};
	}

	public static function makeObject(props:Expr, structInfo:Null<StructInfo>, required:Array<String>, order:Int, pos:Position):Expr {
		var fields:Array<ObjectDeclField> = [
			{field: "type", expr: macro "object"},
			{field: "properties", expr: props},
			{field: "additionalProperties", expr: macro false}
		];
		if (required.length > 0) {
			var exprs:Array<Expr> = [for (req in required) macro $v{req}];
			fields.push({field: "required", expr: macro $a{exprs}});
		}
		return makeObjectDecl(fields, structInfo, order, pos);
	}

	public static function makeEnum(enumList:Expr, structInfo:Null<StructInfo>, order:Int, pos:Position):Expr {
		var fields:Array<ObjectDeclField> = [
			{field: "type", expr: macro "string"},
			{field: "enum", expr: enumList}
		];
		return makeObjectDecl(fields, structInfo, order, pos);
	}

	public static function makeStructInfo(name:String, doc:String):Null<StructInfo> {
		if (doc == null) return null;
		doc = StringTools.trim(doc);
		if (doc.length <= 0) return null;
		return {name:name, doc:StringTools.trim(doc)};
	}
}
#end