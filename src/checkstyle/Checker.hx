package checkstyle;

import haxe.CallStack;
import haxeparser.HaxeParser;
import haxeparser.HaxeLexer;
import sys.io.File;

import checkstyle.checks.Check;

import checkstyle.reporter.ReporterManager;

import checkstyle.token.TokenTreeBuilder;

class Checker {

	public var file:CheckFile;
	public var lines:Array<String>;
	public var tokens:Array<Token>;
	public var ast:Ast;
	public var checks:Array<Check>;
	public var baseDefines:Array<String>;
	public var defineCombinations:Array<Array<String>>;

	var linesIdx:Array<LineIds>;
	var lineSeparator:String;
	var tokenTree:TokenTree;
	public var asts:Array<Ast>;
	public var excludes:Map<String, Array<String>>;

	public function new() {
		checks = [];
		baseDefines = [];
		defineCombinations = [];
	}

	public function addCheck(check:Check) {
		checks.push(check);
	}

	public function getTokenTree():TokenTree {
		if (tokens == null) return null;
		if (tokenTree == null) tokenTree = TokenTreeBuilder.buildTokenTree(tokens, file.content);
		return tokenTree;
	}

	function makePosIndices() {
		var code:Bytes = cast file.content;
		linesIdx = [];

		var last = 0;
		var left = false;

		for (i in 0...code.length) {
			if (code.get(i) == 0x0A) {
				linesIdx.push({l:last, r:i});
				last = i + 1;
				left = false;
			}
			left = true;
		}
		if (left) linesIdx.push({l:last, r:code.length});
	}

	public function getLinePos(off:Int):LinePos {
		for (i in 0...linesIdx.length) {
			if (linesIdx[i].l <= off && linesIdx[i].r >= off) return { line:i, ofs: off - linesIdx[i].l };
		}
		throw "Bad offset";
	}

	public function getString(off:Int, off2:Int):String {
		var code:Bytes = cast file.content;
		var len:Int = off2 - off;
		if ((off >= code.length) || (off + len > code.length)) return "";
		return code.sub(off, off2 - off).toString();
	}

	function findLineSeparator() {
		var codeBytes:Bytes = cast file.content;
		var code:String = codeBytes.toString();

		for (i in 0...code.length) {
			var char = code.charAt(i);
			if (char == "\r" || char == "\n") {
				lineSeparator = char;
				if (char == "\r" && i + 1 < code.length) {
					char = code.charAt(i + 1);
					if (char == "\n") lineSeparator += char;
				}
				return;
			}
		}
		//default
		lineSeparator = "\n";
	}

	function makeLines() {
		var code:Bytes = cast file.content;
		var textCode:String = code.toString();
		lines = textCode.split(lineSeparator);
	}

	function makeTokens() {
		try {
			tokens = [];
			tokenTree = null;
			var lexer = new HaxeLexer(file.content, file.name);
			var t:Token = lexer.token(HaxeLexer.tok);

			while (t.tok != Eof) {
				tokens.push(t);
				t = lexer.token(haxeparser.HaxeLexer.tok);
			}
		}
		catch (e:Any) {
			#if debug
			Sys.println(e);
			Sys.println("Stacktrace: " + CallStack.toString(CallStack.exceptionStack()));
			#end
			#if unittest
			throw e;
			#end
		}
	}

	function makeASTs() {
		asts = [];
		var res = makeAST(baseDefines);
		if (res != null) asts.push(res);
		for (combination in defineCombinations) {
			var res = makeAST(combination.concat(baseDefines));
			if (res != null) asts.push(res);
		}
	}

	function makeAST(defines:Array<String>):Ast {
		var parser = new HaxeParser(file.content, file.name);
		parser.define("cross");
		parser.define("scriptable");
		parser.define("unsafe");
		for (define in defines) {
			var flagValue = define.split("=");
			parser.define(flagValue[0], flagValue[1]);
		}

		try {
			return parser.parse();
		}
		catch (e:Any) {
			#if debug
			Sys.println(e);
			Sys.println("Stacktrace: " + CallStack.toString(CallStack.exceptionStack()));
			#end
			#if unittest
			throw e;
			#end
		}
		return null;
	}

	public function process(files:Array<CheckFile>, excludesMap:Map<String, Array<String>>) {
		excludes = excludesMap;
		var advanceFrame = function() {};
		#if hxtelemetry
		var hxt = new hxtelemetry.HxTelemetry();
		advanceFrame = function() hxt.advance_frame();
		#end

		ReporterManager.INSTANCE.start();
		for (checkFile in files) {
			loadFileContent(checkFile);
			if (createContext(checkFile)) run();
			unloadFileContent(checkFile);
			advanceFrame();
		}
		advanceFrame();
		ReporterManager.INSTANCE.finish();
		advanceFrame();
	}

	public function loadFileContent(checkFile:CheckFile) {
		// unittests set content before running Checker
		// real checks load content here
		if (checkFile.content == null) checkFile.content = cast File.getBytes(checkFile.name);
	}

	public function unloadFileContent(checkFile:CheckFile) {
		checkFile.content = null;
	}

	public function createContext(checkFile:CheckFile):Bool {
		file = checkFile;
		ReporterManager.INSTANCE.fileStart(file);
		try {
			findLineSeparator();
			makeLines();
			makePosIndices();
			makeTokens();
			makeASTs();
			if (asts.length <= 0) return false;
			getTokenTree();
		}
		catch (e:Any) {
			ReporterManager.INSTANCE.addParseError(file, e);
			return false;
		}
		return true;
	}

	public function run() {
		for (check in checks) {
			var messages = [];

			if (check.type == AST) {
				for (ast in asts) {
					this.ast = ast;
					messages = messages.concat(runCheck(check));
				}
			}
			else {
				// non AST-based checks still need the AST for suppression checking
				ast = asts[0];
				messages = messages.concat(runCheck(check));
			}
			ReporterManager.INSTANCE.addMessages(messages);
		}
		ReporterManager.INSTANCE.fileFinish(file);
	}

	function runCheck(check:Check):Array<CheckMessage> {
		try {
			if (checkForExclude(check.getModuleName())) return [];
			return check.run(this);
		}
		catch (e:Any) {
			ReporterManager.INSTANCE.addCheckError(file, e, check.getModuleName());
			return [];
		}
	}

	function checkForExclude(moduleName:String):Bool {
		if (excludes == null) return false;
		var excludesForCheck:Array<String> = excludes.get(moduleName);
		if (excludesForCheck == null || excludesForCheck.length == 0) return false;

		var cls = file.name.substring(0, file.name.indexOf(".hx"));
		if (excludesForCheck.contains(cls)) return true;

		var slashes:EReg = ~/[\/\\]/g;
		cls = slashes.replace(cls, ":");
		for (exclude in excludesForCheck) {
			var r = new EReg(exclude, "i");
			if (r.match(cls)) return true;
		}
		return false;
	}
}

typedef LinePos = {
	var line:Int;
	var ofs:Int;
}

typedef LineIds = {
	var l:Int;
	var r:Int;
}

typedef Ast = {
	var pack:Array<String>;
	var decls:Array<TypeDecl>;
}