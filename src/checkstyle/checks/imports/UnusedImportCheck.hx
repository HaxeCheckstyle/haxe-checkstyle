package checkstyle.checks.imports;

import haxe.io.Path;
import tokentree.utils.TokenTreeCheckUtils;

/**
	Checks for unused or duplicate imports.
**/
@name("UnusedImport")
@desc("Checks for unused or duplicate imports.")
class UnusedImportCheck extends Check {
	/**
		list of module names to ignore, any module from "ignoreModules" won't show up as unused in any file during a run
	**/
	public var ignoreModules:Array<String>;

	/**
		modules that define multiple types may show up as unused, unless "moduleTypeMap" contains a mapping for it
		e.g. "haxe.macro.Expr": ["ExprDef", "ComplexType"] - would allow "import haxe.macro.Expr;" even though you just use "ComplexType"
	**/
	public var moduleTypeMap:Any;

	public function new() {
		super(TOKEN);
		ignoreModules = [];
		moduleTypeMap = {};
		categories = [Category.STYLE, Category.CLARITY, Category.DUPLICATION];
		points = 1;
	}

	override function actualRun() {
		var seenModules:Array<String> = [];
		if (isImportHx()) return;
		var root:TokenTree = checker.getTokenTree();
		var packageName:String = detectPackageName(root);
		var imports:Array<TokenTree> = findImports(root);
		var idents:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			switch (token.tok) {
				case Const(CIdent(_)):
					if (TokenTreeCheckUtils.isImport(token)) return GoDeeper;
					return FoundGoDeeper;
				default:
			}
			return GoDeeper;
		});
		var stringLiterals:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			switch (token.tok) {
				case Const(CString(text)):
					if (checker.getString(token.pos.min, token.pos.min + 1) != "'") return GoDeeper;
					if (~/\$\{[^\}]+\.[^\}]+\}/.match(text)) return FoundGoDeeper;
				default:
			}
			return GoDeeper;
		});
		for (imp in imports) {
			var typeName:String = detectTypeName(imp);
			var moduleName:String = detectModuleName(imp);
			if ((typeName == null) || (moduleName == null)) continue;
			if (ignoreModules.contains(moduleName)) continue;

			if ((packageName != null) && (!hasMapping(moduleName)) && ('$packageName.$typeName' == moduleName)) {
				logPos('Detected import "$moduleName" from same package "$packageName"', imp.getPos(), SAME_PACKAGE);
				continue;
			}

			if (!~/\./.match(moduleName)) {
				logPos('Unnecessary toplevel import "$moduleName" detected', imp.getPos(), TOPLEVEL_IMPORT);
				continue;
			}

			if (seenModules.contains(moduleName)) {
				logPos('Duplicate import "$moduleName" detected', imp.getPos(), DUPLICATE_IMPORT);
				continue;
			}
			seenModules.push(moduleName);
			checkUsage(typeName, moduleName, imp, idents, stringLiterals);
		}
	}

	function findImports(root:TokenTree):Array<TokenTree> {
		return root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdImport):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
	}

	function isImportHx():Bool {
		var fileName:String = Path.withoutDirectory(checker.file.name);
		return fileName == "import.hx";
	}

	function detectPackageName(root:TokenTree):String {
		var packageToken:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdPackage):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
		if ((packageToken == null) || (packageToken.length <= 0)) return null;

		var packageName:String = detectModuleName(packageToken[0]);
		if (packageName == "") packageName = null;
		if (packageToken.length > 1) {
			logPos("Multiple package declarations found", packageToken[1].getPos(), MULTIPLE_PACKAGE);
		}
		return packageName;
	}

	function detectModuleName(token:TokenTree):String {
		var moduleName:StringBuf = new StringBuf();

		while (true) {
			switch (token.tok) {
				case Binop(OpMult):
					return null;
				case Kwd(KwdImport):
				case Kwd(KwdPackage):
				case Semicolon:
					return moduleName.toString();
				case Binop(OpIn):
					if (token.parent.tok.match(Dot)) moduleName.add(token.toString());
					else moduleName.add(" in ");
				case Const(CIdent("as")):
					if (token.parent.tok.match(Dot)) moduleName.add(token.toString());
					else moduleName.add(" as ");
				default:
					moduleName.add(token.toString());
			}
			token = token.getFirstChild();
		}
		return null;
	}

	function detectTypeName(token:TokenTree):String {
		var lastName:String = null;
		while (true) {
			switch (token.tok) {
				case Binop(OpMult):
					return null;
				case Const(CIdent(name)):
					lastName = name;
				case Semicolon:
					return lastName;
				default:
			}
			token = token.getFirstChild();
		}
		return null;
	}

	function checkUsage(typeName:String, moduleName:String, importTok:TokenTree, idents:Array<TokenTree>, stringLiterals:Array<TokenTree>) {
		for (ident in idents) {
			var name:String = ident.toString();
			if (!checkName(typeName, moduleName, name)) continue;
			switch (ident.parent.tok) {
				case Kwd(KwdClass), Kwd(KwdInterface), Kwd(KwdAbstract), Kwd(KwdEnum), Kwd(KwdTypedef):
					continue;
				case Dot:
					continue;
				default:
					return;
			}
		}
		for (literal in stringLiterals) {
			var names:Array<String> = extractLiteralNames(literal.toString());
			for (name in names) {
				if (checkName(typeName, moduleName, name)) return;
			}
		}
		logPos('Unused import "$moduleName" detected', importTok.getPos(), UNUSED_IMPORT);
	}

	function extractLiteralNames(text:String):Array<String> {
		var names:Array<String> = [];
		var interpols:Array<String> = [];
		var interpolRegEx:EReg = ~/\$\{([^\}]+)\}/g;
		while (true) {
			if (!interpolRegEx.match(text)) break;
			interpols.push(interpolRegEx.matched(1));
			text = interpolRegEx.matchedRight();
		}
		var namesRegEx:EReg = ~/([A-Z][A-Za-z0-9_]*)/g;
		for (interpol in interpols) {
			while (true) {
				if (!namesRegEx.match(interpol)) break;
				names.push(namesRegEx.matched(1));
				interpol = namesRegEx.matchedRight();
			}
		}
		return names;
	}

	function hasMapping(moduleName:String):Bool {
		var mappedTypes:Array<String> = Reflect.field(moduleTypeMap, moduleName);
		return ((mappedTypes != null) && (mappedTypes.length > 0));
	}

	function checkName(typeName:String, moduleName:String, identName:String):Bool {
		var mappedTypes:Array<String> = Reflect.field(moduleTypeMap, moduleName);
		if ((mappedTypes == null) || (mappedTypes.length <= 0)) {
			return typeName == identName;
		}
		for (mappedType in mappedTypes) {
			if (mappedType == identName) return true;
		}
		return typeName == identName;
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: [SeverityLevel.INFO]
			}]
		}];
	}
}

enum abstract UnusedImportCode(String) to String {
	var UNUSED_IMPORT = "UnusedImport";
	var TOPLEVEL_IMPORT = "ToplevelImport";
	var SAME_PACKAGE = "SamePackage";
	var DUPLICATE_IMPORT = "DuplicateImport";
	var MULTIPLE_PACKAGE = "MultiplePackage";
}