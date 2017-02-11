package checkstyle;

import byte.ByteData;
import haxe.CallStack;
import checkstyle.checks.Check;
import haxeparser.HaxeParser;
import checkstyle.reporter.IReporter;
import haxeparser.HaxeLexer;
import sys.io.File;

import checkstyle.checks.Category;
import checkstyle.token.TokenTreeBuilder;

class Checker {

	public var file:CheckFile;
	public var bytes:ByteData;
	public var lines:Array<String>;
	public var tokens:Array<Token>;
	public var ast:Ast;
	public var checks:Array<Check>;
	public var baseDefines:Array<String>;
	public var defineCombinations:Array<Array<String>>;

	var reporters:Array<IReporter>;
	var linesIdx:Array<LineIds>;
	var lineSeparator:String;
	var tokenTree:TokenTree;
	var asts:Array<Ast>;
	var excludes:Map<String, Array<String>>;

	public function new() {
		checks = [];
		reporters = [];
		baseDefines = [];
		defineCombinations = [];
	}

	public function addCheck(check:Check) {
		checks.push(check);
	}

	public function addReporter(r:IReporter) {
		reporters.push(r);
	}

	public function getTokenTree():TokenTree {
		if (tokens == null) return null;
		if (tokenTree == null) tokenTree = TokenTreeBuilder.buildTokenTree(tokens, bytes);
		return tokenTree;
	}

	function makePosIndices() {
		var code = file.content;
		linesIdx = [];

		var last = 0;
		var left = false;

		for (i in 0...code.length) {
			if (code.charAt(i) == "\n") {
				linesIdx.push({l:last, r:i});
				last = i + 1;
				left = false;
			}
			left = true;
		}
		if (left) linesIdx.push({l:last, r:code.length - 1});
	}

	public function getLinePos(off:Int):LinePos {
		for (i in 0...linesIdx.length) {
			if (linesIdx[i].l <= off && linesIdx[i].r >= off) return { line:i, ofs: off - linesIdx[i].l };
		}
		throw "Bad offset";
	}

	public function getString(off:Int, off2:Int):String {
		return file.content.substr(off, off2 - off);
	}

	function findLineSeparator() {
		var code = file.content;
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
		var code = file.content;
		lines = code.split(lineSeparator);
	}

	function makeTokens() {
		try {
			tokens = [];
			tokenTree = null;
			var lexer = new HaxeLexer(bytes, file.name);
			var t:Token = lexer.token(HaxeLexer.tok);

			while (t.tok != Eof) {
				tokens.push(t);
				t = lexer.token(haxeparser.HaxeLexer.tok);
			}
		}
		catch (e:Dynamic) {
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
		asts = [makeAST(baseDefines)];
		for (combination in defineCombinations) {
			var res = makeAST(combination.concat(baseDefines));
			if (res != null) asts.push(res);
		}
	}

	function makeAST(defines:Array<String>):Ast {
		var code = file.content;
		var parser = new HaxeParser(byte.ByteData.ofString(code), file.name);
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
		catch (e:Dynamic) {
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

		for (reporter in reporters) reporter.start();
		for (checkFile in files) {
			loadFileContent(checkFile);
			if (createContext(checkFile)) run();
			unloadFileContent(checkFile);
			advanceFrame();
		}
		advanceFrame();
		for (reporter in reporters) reporter.finish();
		advanceFrame();
	}

	function loadFileContent(checkFile:CheckFile) {
		// unittests set content before running Checker
		// real checks load content here
		if (checkFile.content == null) checkFile.content = File.getContent(checkFile.name);
	}

	function unloadFileContent(checkFile:CheckFile) {
		checkFile.content = null;
	}

	function createContext(checkFile:CheckFile):Bool {
		file = checkFile;
		bytes = byte.ByteData.ofString(file.content);
		for (reporter in reporters) reporter.fileStart(file);
		try {
			findLineSeparator();
			makeLines();
			makePosIndices();
			makeTokens();
			makeASTs();
		}
		catch (e:Dynamic) {
			for (reporter in reporters) {
				reporter.addMessage(getErrorMessage(e, file.name, "Parsing"));
				reporter.fileFinish(file);
			}
			return false;
		}
		return true;
	}

	function run() {
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

			messages = filterDuplicateMessages(messages);
			for (reporter in reporters) for (m in messages) reporter.addMessage(m);
		}
		for (reporter in reporters) reporter.fileFinish(file);
	}

	function filterDuplicateMessages(messages:Array<CheckMessage>):Array<CheckMessage> {
		var filteredMessages = [];
		for (message in messages) {
			var anyDuplicates = false;
			for (filteredMessage in filteredMessages) {
				if (areMessagesSame(message, filteredMessage)) {
					anyDuplicates = true;
					break;
				}
			}
			if (!anyDuplicates) filteredMessages.push(message);
		}
		return filteredMessages;
	}

	function areMessagesSame(message1:CheckMessage, message2:CheckMessage):Bool {
		return
			message1.fileName == message2.fileName &&
			message1.message == message2.message &&
			message1.line == message2.line &&
			message1.startColumn == message2.startColumn &&
			message1.endColumn == message2.endColumn &&
			message1.severity == message2.severity &&
			message1.moduleName == message2.moduleName;
	}

	function runCheck(check:Check):Array<CheckMessage> {
		try {
			if (checkForExclude(check.getModuleName())) return [];
			return check.run(this);
		}
		catch (e:Dynamic) {
			for (reporter in reporters) reporter.addMessage(getErrorMessage(e, file.name, "Check " + check.getModuleName()));
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
			var regStr:String = slashes.replace(exclude, ":") + ":.*?" + cls.substring(cls.lastIndexOf(":") + 1, cls.length) + "$";
			var r = new EReg(regStr, "i");
			if (r.match(cls)) return true;
		}
		return false;
	}

	function getErrorMessage(e:Dynamic, fileName:String, step:String):CheckMessage {
		return {
			fileName:fileName,
			line:1,
			startColumn:0,
			endColumn:0,
			severity:ERROR,
			moduleName:"Checker",
			categories:[Category.STYLE],
			points:1,
			desc: "",
			message:step + " failed: " + e + "\nStacktrace: " + CallStack.toString(CallStack.exceptionStack())
		};
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