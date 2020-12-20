package checkstyle.utils;

class ComplexTypeUtils {
	public static function walkFile(file:{pack:Array<String>, decls:Array<TypeDecl>}, cb:ComplexTypeCallback) {
		for (decl in file.decls) walkTypeDecl(decl, cb);
	}

	public static function walkTypeDecl(td:TypeDecl, cb:ComplexTypeCallback) {
		switch (td.decl) {
			case EClass(d):
				walkClass(d, td.pos, cb);
			case EEnum(d):
				walkEnum(d, td.pos, cb);
			case EAbstract(a):
				walkAbstract(a, td.pos, cb);
			case EImport(sl, mode):
				walkImport(sl, mode, cb);
			case ETypedef(d):
				walkTypedef(d, td.pos, cb);
			case EUsing(path):
				walkTypePath(path, path.name, td.pos, cb);
			case EStatic(s):
				walkStatic(s, td.pos, cb);
		}
	}

	static function walkMeta(meta:Metadata, cb:ComplexTypeCallback) {
		for (m in meta) for (p in m.params) walkExpr(p, cb);
	}

	static function walkCommonDefinition<A, B>(d:Definition<A, B>, pos:Position, cb:ComplexTypeCallback) {
		for (p in d.params) walkTypeParamDecl(p, pos, cb);
		walkMeta(d.meta, cb);
	}

	public static function walkClass(d:Definition<ClassFlag, Array<Field>>, pos:Position, cb:ComplexTypeCallback) {
		walkCommonDefinition(d, pos, cb);
		for (f in d.flags) {
			switch (f) {
				case HExtends(t) | HImplements(t):
					walkTypePath(t, d.name, pos, cb);
				default:
			}
		}
		for (f in d.data) walkField(f, cb);
	}

	public static function walkEnum(d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position, cb:ComplexTypeCallback) {
		walkCommonDefinition(d, pos, cb);
		for (ec in d.data) {
			walkMeta(ec.meta, cb);
			for (arg in ec.args) walkComplexType(arg.type, ec.name, ec.pos, cb);
			for (param in ec.params) walkTypeParamDecl(param, ec.pos, cb);
			if (ec.type != null) walkComplexType(ec.type, ec.name, ec.pos, cb);
		}
	}

	public static function walkAbstract(d:Definition<AbstractFlag, Array<Field>>, pos:Position, cb:ComplexTypeCallback) {
		walkCommonDefinition(d, pos, cb);
		for (f in d.flags) {
			switch (f) {
				case AFromType(ct) | AToType(ct) | AIsType(ct):
					walkComplexType(ct, f.getName(), pos, cb);
				default:
			}
		}
		for (f in d.data) walkField(f, cb);
	}

	public static function walkImport(sl, mode, cb:ComplexTypeCallback) {}

	public static function walkTypedef(d:Definition<EnumFlag, ComplexType>, pos:Position, cb:ComplexTypeCallback) {
		walkCommonDefinition(d, pos, cb);
		walkComplexType(d.data, d.name, pos, cb);
	}

	public static function walkTypePath(tp:TypePath, name:String, pos:Position, cb:ComplexTypeCallback) {
		if (tp.params != null) {
			for (p in tp.params) {
				switch (p) {
					case TPType(t):
						walkComplexType(t, name, pos, cb);
					case TPExpr(e):
						walkExpr(e, cb);
				}
			}
		}
	}

	public static function walkStatic(s:Definition<StaticFlag, FieldType>, pos:Position, cb:ComplexTypeCallback) {
		walkField(cast s, cb);
	}

	public static function walkVar(v:Var, pos:Position, cb:ComplexTypeCallback) {
		if (v.type != null) walkComplexType(v.type, v.name, pos, cb);
		if (v.expr != null) walkExpr(v.expr, cb);
	}

	public static function walkTypeParamDecl(tp:TypeParamDecl, pos:Position, cb:ComplexTypeCallback) {
		if (tp.constraints != null) for (c in tp.constraints) walkComplexType(c, tp.name, pos, cb);
		if (tp.params != null) for (t in tp.params) walkTypeParamDecl(t, pos, cb);
	}

	public static function walkFunction(f:Function, name:String, pos:Position, cb:ComplexTypeCallback) {
		for (a in f.args) {
			if (a.type != null) walkComplexType(a.type, a.name, pos, cb);
			if (a.value != null) walkExpr(a.value, cb);
		}
		if (f.ret != null) walkComplexType(f.ret, name, pos, cb);
		if (f.expr != null) walkExpr(f.expr, cb);
		if (f.params != null) for (tp in f.params) walkTypeParamDecl(tp, pos, cb);
	}

	public static function walkCase(c:Case, cb:ComplexTypeCallback) {
		for (v in c.values) walkExpr(v, cb);
		if (c.guard != null) walkExpr(c.guard, cb);
		if (c.expr != null) walkExpr(c.expr, cb);
	}

	public static function walkCatch(c:Catch, cb:ComplexTypeCallback) {
		walkComplexType(c.type, c.name, c.expr.pos, cb);
		walkExpr(c.expr, cb);
	}

	public static function walkField(f:Field, cb:ComplexTypeCallback) {
		switch (f.kind) {
			case FVar(t, e):
				if (t != null) walkComplexType(t, f.name, f.pos, cb);
				if (e != null) walkExpr(e, cb);
			case FFun(fun):
				walkFunction(fun, f.name, f.pos, cb);
			case FProp(get, set, t, e):
				if (t != null) walkComplexType(t, f.name, f.pos, cb);
				if (e != null) walkExpr(e, cb);
		}
	}

	public static function walkComplexType(t:ComplexType, name:String, pos:Position, cb:ComplexTypeCallback) {
		cb(t, name, pos);
		if (t == null) return;
		switch (t) {
			case TPath(p):
				walkTypePath(p, name, pos, cb);
			case TFunction(args, ret):
				for (a in args) walkComplexType(a, name, pos, cb);
				walkComplexType(ret, name, pos, cb);
			case TAnonymous(fields):
				for (f in fields) walkField(f, cb);
			case TParent(t):
				walkComplexType(t, name, pos, cb);
			case TExtend(p, fields):
				for (tp in p) walkTypePath(tp, name, pos, cb);
				for (f in fields) walkField(f, cb);
			case TOptional(t):
				walkComplexType(t, name, pos, cb);
			case TNamed(n, t):
				walkComplexType(t, n, pos, cb);
			case TIntersection(types):
				for (t in types) walkComplexType(t, name, pos, cb);
		}
	}

	public static function walkExpr(e:Expr, cb:ComplexTypeCallback) {
		switch (e.expr) {
			case EConst(c):
			case EArray(e1, e2):
				walkExpr(e1, cb);
				walkExpr(e2, cb);
			case EBinop(op, e1, e2):
				walkExpr(e1, cb);
				walkExpr(e2, cb);
			case EField(e, field):
				walkExpr(e, cb);
			case EParenthesis(e):
				walkExpr(e, cb);
			case EObjectDecl(fields):
				for (f in fields) walkExpr(f.expr, cb);
			case EArrayDecl(values):
				for (v in values) walkExpr(v, cb);
			case ECall(e, params):
				walkExpr(e, cb);
				for (p in params) walkExpr(p, cb);
			case ENew(t, params):
				walkTypePath(t, "", e.pos, cb);
				for (p in params) walkExpr(p, cb);
			case EUnop(op, postFix, e):
				walkExpr(e, cb);
			case EVars(vars):
				for (v in vars) walkVar(v, e.pos, cb);
			case EFunction(kind, f):
				var name:Null<String> = switch (kind) {
					case null: null;
					case FAnonymous: null;
					case FNamed(name, inlined): name;
					case FArrow: null;
				}
				walkFunction(f, name, e.pos, cb);
			case EBlock(exprs):
				for (e in exprs) walkExpr(e, cb);
			case EFor(it, expr):
				walkExpr(it, cb);
				walkExpr(expr, cb);
			case EIf(econd, eif, eelse):
				walkExpr(econd, cb);
				walkExpr(eif, cb);
				if (eelse != null) walkExpr(eelse, cb);
			case EWhile(econd, e, normalWhile):
				walkExpr(econd, cb);
				walkExpr(e, cb);
			case ESwitch(e, cases, edef):
				walkExpr(e, cb);
				for (c in cases) walkCase(c, cb);
				if (edef != null && edef.expr != null) walkExpr(edef, cb);
			case ETry(e, catches):
				walkExpr(e, cb);
				for (c in catches) walkCatch(c, cb);
			case EReturn(e):
				if (e != null) walkExpr(e, cb);
			case EBreak:
			case EContinue:
			case EUntyped(e):
				walkExpr(e, cb);
			case EThrow(e):
				walkExpr(e, cb);
			case ECast(e, t):
				walkExpr(e, cb);
				if (t != null) walkComplexType(t, "", e.pos, cb);
			case EDisplay(e, displayKind):
				walkExpr(e, cb);
			case EDisplayNew(t):
				walkTypePath(t, t.name, e.pos, cb);
			case ETernary(econd, eif, eelse):
				walkExpr(econd, cb);
				walkExpr(eif, cb);
				walkExpr(eelse, cb);
			case ECheckType(e, t):
				walkExpr(e, cb);
				walkComplexType(t, "", e.pos, cb);
			case EMeta(s, e):
				if (s.params != null) for (mp in s.params) walkExpr(mp, cb);
				walkExpr(e, cb);
			#if (haxe >= version("4.2.0-rc.1"))
			case EIs(e, t):
				walkExpr(e, cb);
				walkComplexType(t, "", e.pos, cb);
			#end
		}
	}
}

typedef ComplexTypeCallback = ComplexType -> String -> Position -> Void;