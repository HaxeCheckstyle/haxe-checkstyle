package checkstyle.checks.coding;

import checkstyle.checks.coding.CodeSimilarityCheck.HashedCodeBlock;

class CodeSimilarityCheckTest extends CheckTestCase<CodeSimilarityCheckTests> {
	@Test
	public function testSimilarCodeBlocks() {
		var check = newCheck();
		assertNoMsg(check, NOT_SIMILAR_CODE);
		check = newCheck();
		assertMsg(check, SIMILAR_CODE, "Found similar code block - first seen in Test.hx:3");

		check = newCheck();
		assertMsg(check, SIMILAR_CODE_IF, "Found similar code block - first seen in Test.hx:4");

		check = newCheck();
		assertMsg(check, SIMILAR_CODE_WHILE, "Found similar code block - first seen in Test.hx:4");

		check = newCheck();
		assertMsg(check, SIMILAR_CODE_FOR, "Found similar code block - first seen in Test.hx:4");
	}

	@Test
	public function testIdenticalCodeBlocks() {
		var check = newCheck();
		assertMsg(check, IDENTICAL_CODE, "Found identical code block - first seen in Test.hx:4");
	}

	@Test
	public function testThreshold() {
		var check = newCheck();
		check.thresholdSimilar = 100;
		check.thresholdIdentical = 100;
		assertNoMsg(check, NOT_SIMILAR_CODE);
		assertNoMsg(check, SIMILAR_CODE);
		assertNoMsg(check, SIMILAR_CODE_IF);
		assertNoMsg(check, IDENTICAL_CODE);
	}

	@:access(checkstyle.checks.coding.CodeSimilarityCheck)
	function newCheck():CodeSimilarityCheck {
		CodeSimilarityCheck.SIMILAR_HASHES = new Map<String, HashedCodeBlock>();
		CodeSimilarityCheck.IDENTICAL_HASHES = new Map<String, HashedCodeBlock>();
		return new CodeSimilarityCheck();
	}
}

@:enum
abstract CodeSimilarityCheckTests(String) to String {
	var SIMILAR_CODE = "
	class Test {
		function a(param1:String, param2:Int):Int {
			switch (param2) {
				case 1:
					param1 = '111';
				case 2:
					param1 = 1.0;
				case 3: // test
					param1 = '111';
				case 4:
				case 5: /* test 2 */
				case 6:
				case 7:
				case 8:
				case 9:
					param1 = --param2;
			}
			return Std.parseInt(param1);
		}

		function b(paramA:String, paramB:Int):Int {
			switch (paramB) {
				case 10:
					paramA = '222222';
				case 20:
					paramA = 100.0;
				case 30:
					paramA = '111';
				case 40:
				case 50:
				case 60:
				case 70:
				case 80: // comment
				case 90:
					paramA = ++paramB;
			}
			return Std.parseInt(paramA);
		}
	}";
	var SIMILAR_CODE_IF = "
	class Test {
		function a() {
			if (foo == 'abc') {
				switch (param1) {
					case 1:
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 8:
					case 9:
				}
			}
			else{
				trace ('else');
			}

			if (bar == 'xyz') {
				switch (param2) {
					case 1:
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 8:
					case 9:
				}
			}
			else{
				trace ('else');
			}
		}
	}";
	var SIMILAR_CODE_WHILE = "
	class Test {
		function a() {
			while (count < 100) {
				switch (param1) {
					case 1:
						trace ('');
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 8:
					case 9:
					default:
				}
			}

			while (count > 100) {
				switch (param2) {
					case 1:
						trace ('');
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 8:
					case 9:
					default:
				}
			}
		}
	}";
	var SIMILAR_CODE_FOR = "
	class Test {
		function a() {
			for (index in 0...100) {
				switch (param1) {
					case 1:
						trace ('');
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 8:
					case 9:
					default:
				}
			}

			for (index in 10...90) {
				switch (param2) {
					case 1:
						trace ('');
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 8:
					case 9:
					default:
				}
			}
		}
	}";
	var NOT_SIMILAR_CODE = "
	class Test {
		function a(param1:String, param2:Int):Int {
			switch (param2) {
				case 1:
					param1 = '111' + '1';
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
			}
			return Std.parseInt(param1);
		}

		function b(paramA:String, paramB:Int):Int {
			switch (paramB) {
				case 10:
					paramA = '222222';
				case 20:
				case 30:
				case 40:
				case 50:
				case 60:
				case 70:
				case 80:
				case 90:
			}
			return Std.parseInt(paramA);
		}
	}";
	var IDENTICAL_CODE = "
	class Test {
		function a(param1:String, param2:Int):String {
			switch (param2) {
				case 1:
					param1 = '111';
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
			}
			return param1;
		}

		function b(paramA:String, paramB:Int):Int {
			switch (param2) {
				case 1:
					param1 = '111';
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
			}
			return Std.parseInt(paramA);
		}
	}";
}