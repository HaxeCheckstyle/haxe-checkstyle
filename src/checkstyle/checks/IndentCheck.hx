package checkstyle.checks;

import haxeparser.Data.Token;

@name("Indent")
class IndentCheck extends Check {
	public function new() {
		super();
	}

	var tabWidth = 4;
	var indentStep = 4;

	function isWhitespace(c:String) {
		return switch(c){
			case " " | "\t" : true;
			default : false;
		}
	}

	function whitespaceIndent(c:String):Int {
		return switch(c){
			case " " : return 1;
			case "\t": return tabWidth;
			default : throw false;
		}
	}

	function getLineIndent(l:Int):Int {
		if (l >= _checker.lines.length) {
			throw "Bad line number: " + l + " when total is " + _checker.lines.length;
		}
		var ls = _checker.lines[l];
		var indent = 0;
		for (i in 0...ls.length) {
			var c = ls.charAt(i);
			if (isWhitespace(c)) {
				indent += whitespaceIndent(c);
			}
			else return indent;
		}
		return indent;
	}

	override function actualRun() {
		var desiredIndent = 0;
		var first = false;
		var lastLine = 0;

		for (tk in _checker.tokens) {
			switch(tk.tok){
				case Comment(_): continue;
				case CommentLine(_): continue;
				default:
			}

			if (tk.tok == BrClose) desiredIndent -= indentStep;

			var lp = _checker.getLinePos(tk.pos.min);
			if (first || lastLine != lp.line) {
				//if (getLineIndent(lp.line) != desiredIndent) log('Bad indentation on token : $tk', lp.line+1, lp.ofs+1, INFO);

				lastLine = lp.line;
				first = false;
			}

			if (tk.tok == BrOpen) desiredIndent += indentStep;
		}
	}
}