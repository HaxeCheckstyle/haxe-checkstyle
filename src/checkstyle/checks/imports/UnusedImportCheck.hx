package checkstyle.checks.imports;

import checkstyle.utils.TokenTreeCheckUtils;
import haxe.io.Path;

@name("UnusedImport")
@desc("Checks for unused or duplicate imports.")
class UnusedImportCheck extends Check {

	public var ignoreModules:Array<String>;
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
		var imports:Array<TokenTree> = root.filter([Kwd(KwdImport)], ALL);
		var idents:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			switch (token.tok) {
				case Const(CIdent(_)):
					if (TokenTreeCheckUtils.isImport(token)) return GO_DEEPER;
					return FOUND_GO_DEEPER;
				default:
			}
			return GO_DEEPER;
		});
		var stringLiterals:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			switch (token.tok) {
				case Const(CString(text)):
					if (checker.getString(token.pos.min, token.pos.min + 1) != "'") return GO_DEEPER;
					if (~/\$\{[^\}]+\.[^\}]+\}/.match (text)) return FOUND_GO_DEEPER;
				default:
			}
			return GO_DEEPER;
		});
		for (imp in imports) {
			var typeName:String = detectTypeName(imp);
			var moduleName:String = detectModuleName(imp);
			if ((typeName == null) || (moduleName == null)) continue;
			if (ignoreModules.contains(moduleName)) continue;

			if ((packageName != null) && (!hasMapping(moduleName)) && ('$packageName.$typeName' == moduleName)) {
				logPos('Detected import "$moduleName" from same package "$packageName"', imp.pos);
				continue;
			}

			if (!~/\./.match(moduleName)) {
				logPos('Unnecessary toplevel import "$moduleName" detected', imp.pos);
				continue;
			}

			if (seenModules.contains(moduleName)) {
				logPos('Duplicate import "$moduleName" detected', imp.pos);
				continue;
			}
			seenModules.push(moduleName);
			checkUsage(typeName, moduleName, imp, idents, stringLiterals);
		}
	}

	function isImportHx():Bool {
		var fileName:String = Path.withoutDirectory(checker.file.name);
		return fileName == "import.hx";
	}

	function detectPackageName(root:TokenTree):String {
		var packageToken:Array<TokenTree> = root.filter([Kwd(KwdPackage)], ALL);
		if ((packageToken == null) || (packageToken.length <= 0)) return null;

		var packageName:String = detectModuleName(packageToken[0]);
		if (packageName == "") packageName = null;
		if (packageToken.length > 1) {
			logPos("Multiple package declarations found", packageToken[1].pos);
		}
		return packageName;
	}

	function detectModuleName(token:TokenTree):String {
		var moduleName:StringBuf = new StringBuf();

		while (true) {
			switch (token.tok) {
				case Binop(OpMult): return null;
				case Kwd(KwdImport):
				case Kwd(KwdPackage):
				case Semicolon: return moduleName.toString();
				#if (haxe_ver < 4.0)
				case Kwd(KwdIn):
					if (token.parent.tok.match(Dot)) moduleName.add(token.toString());
					else moduleName.add(" in ");
				#else
				case Binop(OpIn):
					if (token.parent.tok.match(Dot)) moduleName.add(token.toString());
					else moduleName.add(" in ");
				#end
				case Const(CIdent("as")):
					if (token.parent.tok.match(Dot)) moduleName.add(token.toString());
					else moduleName.add(" as ");
				default: moduleName.add(token.toString());
			}
			token = token.getFirstChild();
		}
		return null;
	}

	function detectTypeName(token:TokenTree):String {
		var lastName:String = null;
		while (true) {
			switch (token.tok) {
				case Binop(OpMult): return null;
				case Const(CIdent(name)):
					lastName = name;
				case Semicolon: return lastName;
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
				case Kwd(KwdClass), Kwd(KwdInterface), Kwd(KwdAbstract), Kwd(KwdEnum), Kwd(KwdTypedef): continue;
				case Dot: continue;
				default: return;
			}
		}
		for (literal in stringLiterals) {
			var names:Array<String> = extractLiteralNames(literal.toString());
			for (name in names) {
				if (checkName(typeName, moduleName, name)) return;
			}
		}
		logPos('Unused import "$moduleName" detected', importTok.pos);
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
}