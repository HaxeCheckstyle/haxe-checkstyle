package checkstyle;

import haxe.CallStack;
import checkstyle.checks.Check;
import haxeparser.Data.TypeDecl;
import haxeparser.HaxeParser;
import checkstyle.reporter.IReporter;
import haxeparser.HaxeLexer;
import haxeparser.Data.Token;
import sys.io.File;

import checkstyle.token.TokenTree;
import checkstyle.token.TokenTreeBuilder;

class Checker {

	public var file:LintFile;
	public var lines:Array<String>;
	public var tokens:Array<Token>;
	public var ast:Ast;
	public var checks:Array<Check>;
	public var defines:Array<String>;
	public var defineCombinations:Array<Array<String>>;

	var reporters:Array<IReporter>;
	var linesIdx:Array<LineIds>;
	var lineSeparator:String;
	var tokenTree:TokenTree;
	var asts:Array<Ast>;

	public function new() {
		checks = [];
		reporters = [];
		defines = [];
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
		if (tokenTree == null) {
			tokenTree = TokenTreeBuilder.buildTokenTree(tokens);
		}
		return tokenTree;
	}

	function makePosIndices() {
		var code = file.content;
		linesIdx = [];

		var last = 0;
		var left = false;

		for (i in 0...code.length) {
			if (code.charAt(i) == '\n') {
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
			if (linesIdx[i].l <= off && linesIdx[i].r >= off) {
				return { line:i, ofs: off - linesIdx[i].l };
			}
		}
		throw "Bad offset";
	}

	function findLineSeparator() {
		var code = file.content;
		for (i in 0 ... code.length) {
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
		var left = false;
		var s = 0;
		lines = code.split(lineSeparator);
	}

	function makeTokens() {
		var code = file.content;
		tokens = [];
		tokenTree = null;
		var lexer = new HaxeLexer(byte.ByteData.ofString(code), file.name);
		var t:Token = lexer.token(HaxeLexer.tok);

		while (t.tok != Eof) {
			tokens.push(t);
			t = lexer.token(haxeparser.HaxeLexer.tok);
		}
	}

	function makeASTs() {
		asts = [makeAST(defines)];
		for (combination in defineCombinations) {
			asts.push(makeAST(combination.concat(defines)));
		}
	}

	@SuppressWarnings("checkstyle:HiddenField")
	function makeAST(defines:Array<String>):Ast {
		var code = file.content;
		var parser = new HaxeParser(byte.ByteData.ofString(code), file.name);
		parser.define("cross");
		parser.define("scriptable");
		parser.define("unsafe");
		for (define in defines) {
			var flagValue = define.split("=");
			if (flagValue.length > 2) throw "Define may only contain = sign / value";
			parser.define(flagValue[0], flagValue[1]);
		}
		return parser.parse();
	}

#if hxtelemetry
	public function process(files:Array<LintFile>) {
		var hxt = new hxtelemetry.HxTelemetry();
		for (reporter in reporters) reporter.start();
		for (lintFile in files) {
			loadFileContent(lintFile);
			if (createContext(lintFile)) run();
			unloadFileContent(lintFile);
			hxt.advance_frame();
		}
		hxt.advance_frame();
		for (reporter in reporters) reporter.finish();
		hxt.advance_frame();
	}
#else
	public function process(files:Array<LintFile>) {
		for (reporter in reporters) reporter.start();
		for (lintFile in files) {
			loadFileContent(lintFile);
			if (createContext(lintFile)) run();
			unloadFileContent(lintFile);
		}
		for (reporter in reporters) reporter.finish();
	}
#end

	function loadFileContent(lintFile:LintFile) {
		// unittests set content before running Checker
		// real checks load content here
		if (lintFile.content == null) {
			lintFile.content = File.getContent(lintFile.name);
		}
	}

	function unloadFileContent(lintFile:LintFile) {
		lintFile.content = null;
	}

	@SuppressWarnings("checkstyle:Dynamic")
	function createContext(lintFile:LintFile):Bool {
		this.file = lintFile;
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
				reporter.addMessage({
					fileName:file.name,
					message: "Parsing failed: " + e + "\nStacktrace: " +
								CallStack.toString(CallStack.exceptionStack()),
					line:1,
					startColumn:0,
					endColumn:0,
					severity:ERROR,
					moduleName:"Checker"
				});
			}
			for (reporter in reporters) reporter.fileFinish(file);
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

	function filterDuplicateMessages(messages:Array<LintMessage>):Array<LintMessage> {
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

	function areMessagesSame(message1:LintMessage, message2:LintMessage):Bool {
		return
			message1.fileName == message2.fileName &&
			message1.message == message2.message &&
			message1.line == message2.line &&
			message1.startColumn == message2.startColumn &&
			message1.endColumn == message2.endColumn &&
			message1.severity == message2.severity &&
			message1.moduleName == message2.moduleName;
	}

	@SuppressWarnings("checkstyle:Dynamic")
	function runCheck(check:Check):Array<LintMessage> {
		try {
			return check.run(this);
		}
		catch (e:Dynamic) {
			for (reporter in reporters) {
				reporter.addMessage({
					fileName:file.name,
					message:"Check " + check.getModuleName() + " failed: " +
								e + "\nStacktrace: " + CallStack.toString(CallStack.exceptionStack()),
					line:1,
					startColumn:0,
					endColumn:0,
					severity:ERROR,
					moduleName:"Checker"
				});
			}
			return [];
		}
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