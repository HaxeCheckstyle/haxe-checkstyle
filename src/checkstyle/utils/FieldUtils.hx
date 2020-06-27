package checkstyle.utils;

class FieldUtils {
	public static function isPublic(f:Field, p:ParentType):Bool {
		if (f.access.contains(APublic)) return true;
		if (f.access.contains(APrivate)) return false;
		return !isDefaultPrivate(f, p);
	}

	public static function isPrivate(f:Field, p:ParentType):Bool {
		if (f.access.contains(APrivate)) return true;
		if (f.access.contains(APublic)) return false;
		return isDefaultPrivate(f, p);
	}

	public static function isInline(f:Field, p:ParentType):Bool {
		return f.access.contains(AInline) || p.kind == ENUM_ABSTRACT;
	}

	public static function isStatic(f:Field, p:ParentType):Bool {
		return f.access.contains(AStatic);
	}

	public static function isDefaultPrivate(f:Field, p:ParentType):Bool {
		if (p.kind == INTERFACE) return false;
		if (p.kind == ENUM_ABSTRACT && !f.access.contains(AStatic) && f.kind.match(FVar(_, _))) return false;
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
				var kind = d.flags.contains(HInterface) ? INTERFACE : CLASS;
				return {decl: decl, kind: kind};
			case EAbstract(a):
				var metaName = #if (haxeparser > "3.2.0") ":enum" #else ":kwdenum" #end;
				var kind = a.meta.hasMeta(metaName) ? ENUM_ABSTRACT : ABSTRACT;
				return {decl: decl, kind: kind};
			case ETypedef(d):
				return {decl: decl, kind: TYPEDEF};
			default:
				return null;
		}
	}
}

enum FieldParentKind {
	CLASS;
	INTERFACE;
	ABSTRACT;
	ENUM_ABSTRACT;
	TYPEDEF;
}

typedef ParentType = {
	var decl:haxeparser.Data.TypeDef;
	var kind:FieldParentKind;
}