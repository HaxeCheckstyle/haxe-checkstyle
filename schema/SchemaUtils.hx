#if macro
import haxe.macro.Expr;

class SchemaUtils {

	public static function makeObjectDecl(fields:Array<ObjectDeclField>, order:Int, pos:Position):Expr {
		if (order >= 0) fields.push({field: "propertyOrder", expr: macro $v{order}});
		return {pos: pos, expr: EObjectDecl(fields)};
	}

	public static function makeObject(props:Expr, structInfo:Null<StructInfo>, required:Array<String>, order:Int, pos:Position):Expr {
		var fields:Array<ObjectDeclField> = [
			{field: "type", expr: macro "object"},
			{field: "properties", expr: props},
			{field: "additionalProperties", expr: macro false}
		];

		if (structInfo != null && structInfo.doc != null) {
			fields.push({field: "description", expr: macro structInfo.doc.trim()});
		}
		if (required.length > 0) {
			var exprs:Array<Expr> = [for (req in required) macro $v{req}];
			fields.push({field: "required", expr: macro $a{exprs}});
		}
		return makeObjectDecl(fields, order, pos);
	}

	public static function makeEnum(enumList:Expr, order:Int, pos:Position):Expr {
		return makeObjectDecl([
					{field: "type", expr: macro "string"},
					{field: "enum", expr: enumList}
				], order, pos);
	}
}
#end