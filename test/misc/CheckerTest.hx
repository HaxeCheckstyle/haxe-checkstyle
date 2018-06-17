package misc;

import checkstyle.Checker;

class CheckerTest {

	@Test
	public function testEmptyLinesIdx() {
		var checker:Checker = new Checker();

		throwsBadOffset(checker, 0);
		throwsBadOffset(checker, 100);
		throwsBadOffset(checker, -100);
	}

	@Test
	public function testOneLinesIdx() {
		var checker:Checker = new Checker();
		checker.linesIdx.push({l: 0, r: 100});

		checkLinePos(checker, 0, 0, 0);
		checkLinePos(checker, 50, 0, 50);
		checkLinePos(checker, 100, 0, 100);
		throwsBadOffset(checker, 101);
		throwsBadOffset(checker, -100);
	}

	@Test
	public function testMultipleLinesIdx() {
		var checker:Checker = new Checker();
		checker.linesIdx.push({l: 0, r: 100});
		checker.linesIdx.push({l: 101, r: 200});
		checker.linesIdx.push({l: 201, r: 300});
		checker.linesIdx.push({l: 301, r: 400});
		checker.linesIdx.push({l: 401, r: 500});
		checker.linesIdx.push({l: 501, r: 600});
		checker.linesIdx.push({l: 601, r: 700});
		checker.linesIdx.push({l: 701, r: 800});

		checkLinePos(checker, 0, 0, 0);
		checkLinePos(checker, 50, 0, 50);
		checkLinePos(checker, 100, 0, 100);
		checkLinePos(checker, 150, 1, 50);
		checkLinePos(checker, 250, 2, 50);
		checkLinePos(checker, 350, 3, 50);
		checkLinePos(checker, 450, 4, 50);
		checkLinePos(checker, 550, 5, 50);
		checkLinePos(checker, 650, 6, 50);
		checkLinePos(checker, 750, 7, 50);
		throwsBadOffset(checker, 801);
		throwsBadOffset(checker, -100);
	}

	function checkLinePos(checker:Checker, ofs:Int, expectedLine:Int, expectedOfs:Int, ?pos:PosInfos) {
		var linePos:LinePos = checker.getLinePos(ofs);

		Assert.isNotNull(linePos);
		Assert.areEqual(expectedLine, linePos.line);
		Assert.areEqual(expectedOfs, linePos.ofs);
	}

	function throwsBadOffset(checker:Checker, ofs:Int, ?pos:PosInfos) {
		try {
			checker.getLinePos(ofs);
			Assert.fail("line pos calculation should fail");
		}
		catch (e:Any) {
			Assert.areEqual("Bad offset", '$e');
		}
	}
}