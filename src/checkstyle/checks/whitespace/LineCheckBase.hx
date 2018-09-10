package checkstyle.checks.whitespace;

/**
	base class for line based whitespace checks
**/
@ignore("base class for line based whitespace checks")
class LineCheckBase extends Check {
	var currentState:RangeType;
	var skipOverInitialQuote:Bool;
	var commentStartRE:EReg;
	var commentBlockEndRE:EReg;
	var stringStartRE:EReg;
	var stringInterpolatedEndRE:EReg;
	var stringLiteralEndRE:EReg;

	public function new() {
		super(LINE);

		commentStartRE = ~/\/([\/*])/;
		commentBlockEndRE = ~/\*\//;
		stringStartRE = ~/['"]/;
		stringInterpolatedEndRE = ~/^(?:[^'\\]|\\\S)*'/;
		stringLiteralEndRE = ~/^(?:[^"\\]|\\\S)*"/;
	}

	override public function reset() {
		super.reset();
		currentState = TEXT;
		skipOverInitialQuote = false;
	}

	function getRanges(line:String):Array<Range> {
		var ranges = [];
		var currentStart = 0;
		while (currentStart < line.length) {
			currentStart = switch (currentState) {
				case TEXT: handleTextState(line, ranges, currentStart);
				case COMMENT(isBlock): handleCommentState(line, ranges, currentStart, isBlock);
				case STRING(isInterpolated): handleStringState(line, ranges, currentStart, isInterpolated);
			};
		}
		if (line.length == 0) ranges.push({type: currentState, start: 0, end: 0});
		return ranges;
	}

	function handleTextState(line:String, ranges:Array<Range>, currentStart:Int):Int {
		var foundCommentStart = commentStartRE.matchSub(line, currentStart);
		var commentStart = foundCommentStart ? commentStartRE.matchedPos().pos : line.length;
		var foundStringStart = stringStartRE.matchSub(line, currentStart);
		var stringStart = foundStringStart ? stringStartRE.matchedPos().pos : line.length;

		if (foundCommentStart && commentStart < stringStart) {
			if (commentStart > currentStart) {
				ranges.push({type: currentState, start: currentStart, end: commentStart});
			}

			currentState = COMMENT(commentStartRE.matched(1) == "*");
			return commentStart;
		}
		else if (foundStringStart && stringStart < commentStart) {
			if (stringStart > currentStart) {
				ranges.push({type: currentState, start: currentStart, end: stringStart});
			}

			skipOverInitialQuote = true;
			currentState = STRING(stringStartRE.matched(0) == "'");
			return stringStart;
		}
		else {
			ranges.push({type: currentState, start: currentStart, end: line.length});

			return line.length;
		}
	}

	function handleCommentState(line:String, ranges:Array<Range>, currentStart:Int, isBlock:Bool):Int {
		if (isBlock && commentBlockEndRE.matchSub(line, currentStart)) {
			var commentEnd = commentBlockEndRE.matchedPos().pos + 2;
			ranges.push({type: currentState, start: currentStart, end: commentEnd});

			currentState = TEXT;
			return commentEnd;
		}
		else {
			ranges.push({type: currentState, start: currentStart, end: line.length});

			if (!isBlock) currentState = TEXT;
			return line.length;
		}
	}

	function handleStringState(line:String, ranges:Array<Range>, currentStart:Int, isInterpolated:Bool):Int {
		var adjustedStart = currentStart + (skipOverInitialQuote ? 1 : 0);
		skipOverInitialQuote = false;
		var re = isInterpolated ? stringInterpolatedEndRE : stringLiteralEndRE;
		if (re.match(line.substring(adjustedStart))) {
			var matchedPos = re.matchedPos();
			var stringEnd = adjustedStart + matchedPos.pos + matchedPos.len;
			ranges.push({type: currentState, start: currentStart, end: stringEnd});

			currentState = TEXT;
			return stringEnd;
		}
		else {
			ranges.push({type: currentState, start: currentStart, end: line.length});

			return line.length;
		}
	}
}

enum RangeType {
	TEXT;
	COMMENT(isBlock:Bool);
	STRING(isInterpolated:Bool);
}

typedef Range = {
	var type:RangeType;
	var start:Int;
	var end:Int;
}