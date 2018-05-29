package checkstyle.checks.whitespace;

import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck.EmptyLinesPolicy;

class ListOfEmptyLines {
	var lines:Array<Int>;
	var lineRanges:Array<EmptyLineRange>;

	public function new() {
		lines = [];
		lineRanges = null;
	}

	public function add(line:Int) {
		lines.push(line);
	}

	public function checkRange(policy:EmptyLinesPolicy, max:Int, range:EmptyLineRange, line:Int):EmptyLineRange {
		switch (policy) {
			case IGNORE: return NONE;
			case NONE: return range;
			case EXACT: return checkRangeExact(range, max, line);
			case UPTO: return checkRangeUpto(range, max, line);
			case ATLEAST: return checkRangeAtLeast(range, max, line);
		}
		return range;
	}

	function checkRangeExact(range:EmptyLineRange, max:Int, line:Int):EmptyLineRange {
		switch (range) {
			case NONE: return SINGLE(line);
			case SINGLE(l): if (max == 1) return NONE;
			case RANGE(rangeStart, rangeEnd): if (1 + rangeEnd - rangeStart == max) return NONE;
		}
		return range;
	}

	function checkRangeUpto(range:EmptyLineRange, max:Int, line:Int):EmptyLineRange {
		switch (range) {
			case NONE: return NONE;
			case SINGLE(l): if (max == 1) return NONE;
			case RANGE(rangeStart, rangeEnd): if (1 + rangeEnd - rangeStart <= max) return NONE;
		};
		return range;
	}

	function checkRangeAtLeast(range:EmptyLineRange, max:Int, line:Int):EmptyLineRange {
		switch (range) {
			case NONE: return SINGLE(line);
			case SINGLE(l): if (max == 1) return NONE;
			case RANGE(rangeStart, rangeEnd): if (1 + rangeEnd - rangeStart >= max) return NONE;
		};
		return range;
	}

	public function checkPolicySingleRange(policy:EmptyLinesPolicy, max:Int, start:Int, end:Int):EmptyLineRange {
		if (start > end) throw "*** wrong order!! *** " + start + " " + end;
		var range:Array<EmptyLineRange> = getRanges(start, end);

		switch (policy) {
			case IGNORE: return NONE;
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
				results.push (SINGLE(start));
			}
			else {
				results.push (RANGE(start, current));
			}
			start = val;
			current = val;
		}
		if (current == start) {
			results.push (SINGLE(start));
		}
		else {
			results.push (RANGE(start, current));
		}
		return results;
	}

	public function toString():String {
		return lines.toString();
	}
}

enum EmptyLineRange {
	NONE;
	SINGLE(line:Int);
	RANGE(start:Int, end:Int);
}