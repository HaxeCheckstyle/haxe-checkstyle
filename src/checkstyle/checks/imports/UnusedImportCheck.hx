package checkstyle.checks.imports;

import checkstyle.token.TokenTree;
import checkstyle.utils.TokenTreeCheckUtils;
import haxe.macro.Expr;
import haxe.macro.Expr;
import haxeparser.Data;

using checkstyle.utils.ArrayUtils;

@name("UnusedImport")
@desc("Checks for unused or duplicate imports")
class UnusedImportCheck extends Check {

	public var ignoreModules:Array<String>;

	public function new() {
		super(TOKEN);
		ignoreModules = [];
		categories = ["Style", "Clarity", "Duplication"];
		points = 1;
	}

	override function actualRun() {
		var seenPackages:Array<String> = [];
		var root:TokenTree = checker.getTokenTree();
		var imports:Array<TokenTree> = root.filter([Kwd(KwdImport)], ALL);
		var idents:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			switch (token.tok) {
				case Const(CIdent(name)):
					if (TokenTreeCheckUtils.isImport(token)) return GO_DEEPER;
					return FOUND_GO_DEEPER;
				default:
			}
			return GO_DEEPER;
		});
		for (imp in imports) {
			var typeName:String = detectTypeName(imp);
			var packageName:String = detectPackageName(imp);
			if ((typeName == null) || (packageName == null)) continue;
			if (ignoreModules.contains(packageName)) continue;

			if (!~/\./.match(packageName)) {
				logPos('Unnecessary toplevel import $packageName detected', imp.pos);
				continue;
			}

			if (seenPackages.contains(packageName)) {
				logPos('Duplicate import $packageName detected', imp.pos);
				continue;
			}
			seenPackages.push(packageName);
			checkUsage(typeName, packageName, imp, idents);
		}
	}

	function detectPackageName(token:TokenTree):String {
		var packageName:StringBuf = new StringBuf();

		var copy:Bool = false;
		while (true) {
			switch (token.tok) {
				case Binop(OpMult): return null;
				case Kwd(KwdImport):
				case Semicolon: return packageName.toString();
				case Kwd(KwdIn):
					if (token.parent.tok.match(Dot)) packageName.add(TokenDefPrinter.print(token.tok));
					else packageName.add(" in ");
				case Const(CIdent("as")):
					if (token.parent.tok.match(Dot)) packageName.add(TokenDefPrinter.print(token.tok));
					else packageName.add(" as ");
				default: packageName.add(TokenDefPrinter.print(token.tok));
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

	function checkUsage(typeName:String, packageName:String, importTok:TokenTree, idents:Array<TokenTree>) {
		for (ident in idents) {
			var name:String = TokenDefPrinter.print(ident.tok);
			if (typeName != name) continue;
			switch (ident.parent.tok) {
				case Kwd(KwdClass), Kwd(KwdInterface), Kwd(KwdAbstract), Kwd(KwdEnum), Kwd(KwdTypedef): continue;
				case Dot: continue;
				default: return;
			}
		}
		logPos('Unused import $packageName detected', importTok.pos);
	}
}