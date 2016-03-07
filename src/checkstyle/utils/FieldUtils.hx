package checkstyle.utils;

import haxe.macro.Expr.Access;
import haxe.macro.Expr.Field;
import haxeparser.Data.TypeDecl;
import haxeparser.Data.TypeDef;

using checkstyle.utils.ExprUtils;
using StringTools;

class FieldUtils {

	public static inline function hasPublic(f:Field):Bool {
		return has(f, APublic);
	}

	public static inline function hasPrivate(f:Field):Bool {
		return has(f, APrivate);
	}

	public static inline function hasStatic(f:Field):Bool {
		return has(f, AStatic);
	}

	public static inline function hasInline(f:Field):Bool {
		return has(f, AInline);
	}

	static inline function has(f:Field, a:Access):Bool {
		return f.access.indexOf(a) != -1;
	}

	public static function isPublic(f:Field, p:ParentType):Bool {
		if (hasPublic(f)) return true;
		if (hasPrivate(f)) return false;
		return !isDefaultPrivate(f, p);
	}

	public static function isPrivate(f:Field, p:ParentType):Bool {
		if (hasPrivate(f)) return true;
		if (hasPublic(f)) return false;
		return isDefaultPrivate(f, p);
	}

	public static function isInline(f:Field, p:ParentType):Bool {
		return (hasInline(f) || p.kind == ENUM_ABSTRACT);
	}

	public static function isStatic(f:Field, p:ParentType):Bool {
		return hasStatic(f);
	}

	public static function isDefaultPrivate(f:Field, p:ParentType):Bool {
		if (p.kind == INTERFACE) return false;
		if (p.kind == ENUM_ABSTRACT && !hasStatic(f) && f.kind.match(FVar(_, _))) return false;
		switch (p.decl) {
			case EClass(d):
				if (d.meta.hasMeta(":publicFields")) return false;
			case _:
		}
		return true;
	}

	public static inline function isGetter(f:Field):Bool {
		return f.name.startsWith("get_");
	}

	public static inline function isSetter(f:Field):Bool {
		return f.name.startsWith("set_");
	}

	public static inline function isConstructor(f:Field):Bool {
		return f.name == "new";
	}

	public static function toParentType(decl:TypeDef):ParentType {
		switch (decl) {
			case EClass(d):
				var kind = (d.flags.indexOf(HInterface) < 0) ? CLASS : INTERFACE;
				return {decl:decl, kind:kind};
			case EAbstract(a):
				var kind = a.meta.hasMeta(":kwdenum") ? ENUM_ABSTRACT : ABSTRACT;
				return {decl:decl, kind:kind};
			case ETypedef(d):
				return return {decl:decl, kind:TYPEDEF};
			default:
				return null;
		}
	}
}

@SuppressWarnings('checkstyle:MemberName')
enum FieldParentKind {
	CLASS;
	INTERFACE;
	ABSTRACT;
	ENUM_ABSTRACT;
	TYPEDEF;
}

typedef ParentType = {
	var decl:TypeDef;
	var kind:FieldParentKind;
}