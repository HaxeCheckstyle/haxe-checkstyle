package checkstyle;

import haxe.CallStack;
import checkstyle.checks.Check;
import haxeparser.Data.TypeDecl;
import checkstyle.reporter.IReporter;
import haxeparser.HaxeLexer;
import haxeparser.Data.Token;

class Checker {
	var checks:Array<Check>;
	var reporters:Array<IReporter>;
	public var file:LintFile;

	public function new(){
		checks = [];
		reporters = [];
	}

	public function addCheck(check:Check) {
		checks.push(check);
	}

	public function addReporter(r:IReporter):Void{
		reporters.push(r);
	}

	function makePosIndices(){
		var code = file.content;
		linesIdx = [];

		var last = 0;
		var left = false;

		for (i in 0...code.length){
			if (code.charAt(i) == '\n'){
				linesIdx.push({l:last, r:i});
				last = i+1;
				left = false;
			}
			left = true;
		}
		if (left) linesIdx.push({l:last, r:code.length-1});
	}

	var linesIdx:Array<{l:Int,r:Int}>;

	public function getLinePos(off:Int):{line:Int,ofs:Int}{
		for (i in 0...linesIdx.length){
			if (linesIdx[i].l <= off && linesIdx[i].r >= off) return {line:i,ofs:off-linesIdx[i].l};
		}
		throw "Bad offset";
	}

	public var lines:Array<String>;

	var lineSeparator:String;

	function findLineSeparator(){
		var code = file.content;
		for (i in 0 ... code.length){
			var char = code.charAt(i);
			if (char == "\r" || char == "\n"){
				lineSeparator = char;
				if (char == "\r" && i + 1 < code.length){
					char = code.charAt(i+1);
					if (char == "\n") lineSeparator += char;
				}
				return;
			}
		}
		//default
		lineSeparator = "\n";
	}

	function makeLines(){
		var code = file.content;
		var left = false;
		var s = 0;
		lines = code.split(lineSeparator);
	}

	public var tokens:Array<Token>;

	function makeTokens(){
		var code = file.content;
		tokens = [];
		var lexer = new HaxeLexer(byte.ByteData.ofString(code), file.name);
		var t:Token = lexer.token(HaxeLexer.tok);
		while (t.tok != Eof){
			tokens.push(t);

			t = lexer.token(haxeparser.HaxeLexer.tok);
		}
	}

	public var ast:{pack: Array<String>, decls: Array<TypeDecl>};

	function makeAST(){
		var code = file.content;
		var parser = new haxeparser.HaxeParser(byte.ByteData.ofString(code), file.name);
		ast = parser.parse();
	}

	public function process(files:Array<LintFile>):Void{
		for (reporter in reporters) reporter.start();

		for (file in files) run(file);

		for (reporter in reporters) reporter.finish();
	}

	public function run(file:LintFile){
		for (reporter in reporters) reporter.fileStart(file);

		this.file = file;
		try {
			findLineSeparator();
			makeLines();
			makePosIndices();
			makeTokens();
			makeAST();
		}
		catch (e:Dynamic){
			for (reporter in reporters) reporter.addMessage({
				fileName:file.name,
				message:"Parsing failed: " + e + "\nStacktrace: " + CallStack.toString(CallStack.exceptionStack()),
				line:1,
				column:1,
				severity:ERROR,
				moduleName:"Checker"
			});
			for (reporter in reporters) reporter.fileFinish(file);
			return;
		}

		for (check in checks){
			var messages;
			try {
				messages = check.run(this);
				for (reporter in reporters) for (m in messages) reporter.addMessage(m);
			}
			catch (e:Dynamic) {
				for (reporter in reporters) reporter.addMessage({
					fileName:file.name,
					message:"Check " + check.getModuleName() + " failed: " + e + "\nStacktrace: " + CallStack.toString(CallStack.exceptionStack()),
					line:1,
					column:1,
					severity:ERROR,
					moduleName:"Checker"
				});
			}
		}

		for (reporter in reporters) reporter.fileFinish(file);
	}
}