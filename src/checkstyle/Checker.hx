package checkstyle;

import haxe.CallStack;
import checkstyle.checks.Check;
import haxeparser.Data.TypeDecl;
import haxeparser.HaxeParser;
import checkstyle.reporter.IReporter;
import haxeparser.HaxeLexer;
import haxeparser.Data.Token;

import checkstyle.TokenTree;
import checkstyle.TokenTreeBuilder;

class Checker {

	public var file:LintFile;
	public var lines:Array<String>;
	public var tokens:Array<Token>;
	public var ast:Ast;

	var checks:Array<Check>;
	var reporters:Array<IReporter>;
	var linesIdx:Array<LineIds>;
	var lineSeparator:String;
	var tokenTree:TokenTree;

	public function new() {
		checks = [];
		reporters = [];
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

	function makeAST() {
		var code = file.content;
		var parser = new HaxeParser(byte.ByteData.ofString(code), file.name);
		parser.define("cross");
		parser.define("scriptable");
		parser.define("unsafe");
		ast = parser.parse();
	}

	public function process(files:Array<LintFile>) {
		for (reporter in reporters) reporter.start();
		for (file in files) run(file);
		for (reporter in reporters) reporter.finish();
	}

	@SuppressWarnings(["checkstyle:Dynamic", "checkstyle:MethodLength"])
	public function run(file:LintFile) {
		for (reporter in reporters) reporter.fileStart(file);

		this.file = file;
		try {
			findLineSeparator();
			makeLines();
			makePosIndices();
			makeTokens();
			makeAST();
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
			return;
		}

		for (check in checks) {
			var messages;
			try {
				messages = check.run(this);
				for (reporter in reporters) for (m in messages) reporter.addMessage(m);
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
			}
		}

		for (reporter in reporters) reporter.fileFinish(file);
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