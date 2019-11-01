package checkstyle.checks.whitespace;

import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck.EmptyLinesPolicy;

/**
	holds list of empty lines and provides some helper functions
	line numbers start at 0
**/
class ListOfEmptyLines {
	var lineRanges:Array<EmptyLineRange>;

	/**
		list of empty line indexes
	**/
	public var lines:Array<Int>;

	public function new() {
		lines = [];
		lineRanges = null;
	}

	/**
		detects empty lines and constructs a ListOfEmptyLines object

		@param checker - checker holding lines of current file
		@return populated ListOfEmptyLines instance
	**/
	public static function detectEmptyLines(checker:Checker):ListOfEmptyLines {
		var emptyLines:ListOfEmptyLines = new ListOfEmptyLines();
		for (index in 0...checker.lines.length) {
			if (~/^\s*$/.match(checker.lines[index])) emptyLines.add(index);
		}
		return emptyLines;
	}

	/**
		adds a new empty line number
		@param line - line number of empty line
	**/
	public function add(line:Int) {
		lines.push(line);
	}

	/**
		checks policy on a single empty line range
		@param policy - empty line policy to check
		@param max - maximum number of empty lines
		@param range - range to check
		@param line - line to check
		@return EmptyLineRange returns matching range or NONE
	**/
	public function checkRange(policy:EmptyLinesPolicy, max:Int, range:EmptyLineRange, line:Int):EmptyLineRange {
		switch (policy) {
			case IGNORE:
				return NONE;
			case NONE:
				return range;
			case EXACT:
				return checkRangeExact(range, max, line);
			case UPTO:
				return checkRangeUpto(range, max, line);
			case ATLEAST:
				return checkRangeAtLeast(range, max, line);
		}
		return range;
	}

	function checkRangeExact(range:EmptyLineRange, max:Int, line:Int):EmptyLineRange {
		switch (range) {
			case NONE:
				return SINGLE(line);
			case SINGLE(l):
				if (max == 1) return NONE;
			case RANGE(rangeStart, rangeEnd):
				if (1 + rangeEnd - rangeStart == max) return NONE;
		}
		return range;
	}

	function checkRangeUpto(range:EmptyLineRange, max:Int, line:Int):EmptyLineRange {
		switch (range) {
			case NONE:
				return NONE;
			case SINGLE(l):
				if (max >= 1) return NONE;
			case RANGE(rangeStart, rangeEnd):
				if (1 + rangeEnd - rangeStart <= max) return NONE;
		};
		return range;
	}

	function checkRangeAtLeast(range:EmptyLineRange, max:Int, line:Int):EmptyLineRange {
		switch (range) {
			case NONE:
				return SINGLE(line);
			case SINGLE(l):
				if (max == 1) return NONE;
			case RANGE(rangeStart, rangeEnd):
				if (1 + rangeEnd - rangeStart >= max) return NONE;
		};
		return range;
	}

	/**
		checks for empty lines between start and end using a policy
		@param policy - policy to use
		@param max - maximum number of empty lines
		@param start - start line number (inclusive)
		@param end - end line number (inclusive)
		@return EmptyLineRange matching range or NONE
	**/
	public function checkPolicySingleRange(policy:EmptyLinesPolicy, max:Int, start:Int, end:Int):EmptyLineRange {
		if (start > end) throw "*** wrong order!! *** " + start + " " + end;
		var range:Array<EmptyLineRange> = getRanges(start, end);

		switch (policy) {
			case IGNORE:
				return NONE;
			case NONE:
				if (range.length == 0) return NONE;
				return range[0];
			case EXACT:
				if (range.length <= 0) return SINGLE(end);
				if (range.length != 1) return range[0];
				return checkRangeExact(range[0], max, end);
			case UPTO:
				if (range.length <= 0) return NONE;
				if (range.length > 1) return range[0];
				return checkRangeUpto(range[0], max, end);
			case ATLEAST:
				if (range.length <= 0) return SINGLE(start);
				if (range.length > 1) return range[0];
				return checkRangeAtLeast(range[0], max, start);
		}
		if (range.length <= 0) return SINGLE(start);
		return range[0];
	}

	/**
		returns all emtpy line ranges between start and end line numbers
		@param startLine - start line number (inclusive)
		@param endLine - end line number (inclusive)
		@return Array<EmptyLineRange> list of emtpy line ranges
	**/
	public function getRanges(startLine:Int, endLine:Int):Array<EmptyLineRange> {
		if (lineRanges == null) lineRanges = makeRanges();
		var results:Array<EmptyLineRange> = [];
		for (range in lineRanges) {
			switch (range) {
				case NONE:
				case SINGLE(line):
					if ((startLine <= line) && (line <= endLine)) results.push(range);
				case RANGE(start, end):
					if ((end >= startLine) && (start <= endLine)) results.push(range);
			}
		}
		return results;
	}

	function makeRanges():Array<EmptyLineRange> {
		var results:Array<EmptyLineRange> = [];

		if (lines.length <= 0) return [];
		var start:Int = lines[0];
		var current:Int = start;
		for (index in 1...lines.length) {
			var val:Int = lines[index];
			if (val == current + 1) {
				current = val;
				continue;
			}
			if (current == start) {
				results.push(SINGLE(start));
			}
			else {
				results.push(RANGE(start, current));
			}
			start = val;
			current = val;
		}
		if (current == start) {
			results.push(SINGLE(start));
		}
		else {
			results.push(RANGE(start, current));
		}
		return results;
	}

	/**
		counts empty lines between starting and ending line
		@param startLine first line of range
		@param endLine last line of range
		@return Int number of empty lines inbetween start and end line
	**/
	public function countEmptylinesBetween(startLine:Int, endLine:Int):Int {
		var count:Int = 0;
		for (line in lines) {
			if (line < startLine) continue;
			if (line > endLine) continue;
			count++;
		}
		return count;
	}

	public function toString():String {
		return lineRanges.toString();
	}
}

enum EmptyLineRange {
	NONE;
	SINGLE(line:Int);
	RANGE(start:Int, end:Int);
}