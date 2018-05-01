package checkstyle.checks.block;

@name("ConditionalCompilation")
@desc("Checks placement and indentation of conditional compilation flags.")
class ConditionalCompilationCheck extends Check {

	public var policy:ConditionalCompilationPolicy;
	public var allowSingleline:Bool;

	public function new() {
		super(TOKEN);
		policy = ALIGNED;
		allowSingleline = true;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		checkSharpIf(root.filter([Sharp("if")], ALL));
	}

	function checkSharpIf(tokens:Array<TokenTree>) {
		for (tok in tokens) {
			if (isPosSuppressed(tok.pos)) continue;
			var linePos:LinePos = checker.getLinePos(tok.pos.min);
			if (checkSingleLine(tok, linePos.line)) continue;
			checkMultiLine(tok, linePos);
		}
	}

	function checkSingleLine(tok:TokenTree, line:Int):Bool {
		var endTok:TokenTree = null;

		for (child in tok.children) {
			switch (child.tok) {
				case Sharp("end"):
					endTok = child;
					break;
				default:
			}
		}
		if (endTok == null) return true;

		var endPos:LinePos = checker.getLinePos(endTok.pos.min);

		var singleLine:Bool = (endPos.line == line);
		if (!singleLine) return false;
		if (singleLine && allowSingleline) return true;

		logPos("Single line #if…(#else/#elseif)…#end not allowed", tok.pos);
		return true;
	}

	function checkMultiLine(tok:TokenTree, linePos:LinePos) {
		var line:Bytes = Bytes.ofString(checker.lines[linePos.line]);
		var prefix:String = line.sub(0, linePos.ofs).toString();
		if (checkLine(tok, linePos, line)) return;

		switch (policy) {
			case START_OF_LINE:
				if (linePos.ofs != 0) {
					logPos("#if should start at beginning of line", tok.pos);
					return;
				}
			case ALIGNED:
				if (checkIndentation(tok, linePos)) return;
		}
		for (childTok in tok.children) {
			switch (childTok.tok) {
				case Sharp("else"), Sharp("elseif"), Sharp("end"):
					var childLinePos:LinePos = checker.getLinePos(childTok.pos.min);
					var childLine:Bytes = Bytes.ofString(checker.lines[childLinePos.line]);
					var childPrefix:String = childLine.sub(0, childLinePos.ofs).toString();
					if (checkLine(childTok, childLinePos, childLine)) continue;
					if (childPrefix == prefix) continue;
					logPos('Indentation of $childTok must match corresponding #if', childTok.pos);
				default:
			}
		}
	}

	function checkLine(tok:TokenTree, linePos:LinePos, line:Bytes):Bool {
		var r:EReg = ~/^[ \t]*$/;
		var prefix:String = line.sub(0, linePos.ofs).toString();
		if (!r.match(prefix)) {
			logPos('only whitespace allowed before $tok', tok.pos);
			return true;
		}
		var expr:TokenTree = tok.getFirstChild();
		if (expr == null) return false;
		var linePosAfter:LinePos = checker.getLinePos(expr.getPos().max);
		if (linePosAfter.line == linePos.line) {
			var postfix:String = line.sub(linePosAfter.ofs, line.length - linePosAfter.ofs).toString();
			if (!r.match(postfix)) {
				logPos('only whitespace allowed after $tok', tok.pos);
				return true;
			}
		}
		return false;
	}

	function checkIndentation(tok:TokenTree, linePos:LinePos):Bool {
		var prevLen:Int = -1;
		var nextLen:Int = -1;

		var lineIndex:Int = linePos.line - 1;
		while (lineIndex >= 0) {
			var line:String = checker.lines[lineIndex];
			prevLen = getIndentLength(line);
			if (prevLen >= 0) break;
			lineIndex--;
		}
		var lineIndex:Int = linePos.line + 1;
		while (lineIndex < checker.lines.length - 1) {
			var line:String = checker.lines[lineIndex];
			nextLen = getIndentLength(line);
			if (nextLen >= 0) break;
			lineIndex++;
		}
		if (prevLen < 0) prevLen = linePos.ofs;
		if (nextLen < 0) nextLen = linePos.ofs;
		if ((linePos.ofs >= prevLen) && (linePos.ofs <= nextLen)) return false;

		logPos('Indentation of $tok should match surrounding lines', tok.pos);
		return true;
	}

	function getIndentLength(line:String):Int {
		if (~/^[ \t]*$/.match(line)) {
			return -1;
		}
		var r:EReg = ~/^([ \t]*)/;
		if (r.match(line)) {
			var prefix:String = r.matched(1);
			return prefix.length;
		}
		return -1;
	}
}

@:enum
abstract ConditionalCompilationPolicy(String) {
	var START_OF_LINE = "startOfLine";
	var ALIGNED = "aligned";
}