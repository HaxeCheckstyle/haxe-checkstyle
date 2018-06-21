#if macro
import haxe.macro.Expr;

#if (haxe_ver < 4.0)
typedef ObjectDeclField = {
	var field:String;
	var expr:Expr;
}

#else
typedef ObjectDeclField = haxe.macro.ObjectField;
#end

#end