package checkstyle.checks.size;

class MethodCountCheckTest extends CheckTestCase<MethodCountCheckTests> {
	@Test
	public function testTotal() {
		var check = new MethodCountCheck();
		assertMsg(check, TEST1, "Total number of methods is 101 (max allowed is 100)");
	}

	@Test
	public function testPrivate() {
		var check = new MethodCountCheck();
		check.maxPrivate = 5;
		assertMsg(check, TEST2, "Number of private methods is 8 (max allowed is 5)");
	}

	@Test
	public function testPublic() {
		var check = new MethodCountCheck();
		check.maxPublic = 5;
		assertMsg(check, TEST3, "Number of public methods is 7 (max allowed is 5)");
	}

	@Test
	public function testCorrectCount() {
		assertNoMsg(new MethodCountCheck(), TEST3);
	}
}

enum abstract MethodCountCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		public function test1() {}
		public function test2() {}
		public function test3() {}
		public function test4() {}
		public function test5() {}
		public function test6() {}
		public function test7() {}
		public function test8() {}
		public function test9() {}
		public function test10() {}
		public function test11() {}
		public function test12() {}
		public function test13() {}
		public function test14() {}
		public function test15() {}
		public function test16() {}
		public function test17() {}
		public function test28() {}
		public function test19() {}
		public function test20() {}
		public function test21() {}
		public function test22() {}
		public function test23() {}
		public function test24() {}
		public function test25() {}
		function test26() {}
		public function test27() {}
		public function test28() {}
		public function test29() {}
		public function test30() {}
		public function test31() {}
		public function test32() {}
		public function test33() {}
		public function test34() {}
		public function test35() {}
		public function test36() {}
		public function test37() {}
		public function test38() {}
		static function test39() {}
		public function test40() {}
		public function test41() {}
		public function test42() {}
		public function test43() {}
		public function test44() {}
		function test45() {}
		public function test46() {}
		public function test47() {}
		public function test48() {}
		public function test49() {}
		public function test50() {}
		public function test51() {}
		public function test52() {}
		public function test53() {}
		public function test54() {}
		public function test55() {}
		public function test56() {}
		public static function test57() {}
		public function test58() {}
		public function test59() {}
		public function test60() {}
		public function test61() {}
		public function test62() {}
		public function test63() {}
		public function test64() {}
		public function test65() {}
		public function test66() {}
		public function test67() {}
		public function test68() {}
		public function test69() {}
		public function test70() {}
		public function test71() {}
		public function test72() {}
		public function test73() {}
		public function test74() {}
		public function test75() {}
		public function test76() {}
		public function test77() {}
		public function test78() {}
		public function test79() {}
		public function test80() {}
		public function test81() {}
		function test82() {}
		public function test83() {}
		public function test84() {}
		public function test85() {}
		public function test86() {}
		public function test87() {}
		public function test88() {}
		public function test89() {}
		public function test90() {}
		public function test91() {}
		public function test92() {}
		public function test93() {}
		public function test94() {}
		public function test95() {}
		public function test96() {}
		public function test97() {}
		public function test98() {}
		public function test99() {}
		public function test100() {}
		public function test101() {}
	}";
	var TEST2 = "
	abstractAndClass Test {
		function test1() {}
		function test2() {}
		function test3() {}
		function test4() {}
		function test5() {}
		static function test6() {}
		function test7() {}
		static inline function test8() {}
		public static inline function test9() {}
	}";
	var TEST3 = "
	abstractAndClass Test {
		public function test1() {}
		public function test2() {}
		public function test3() {}
		public function test4() {}
		public function test5() {}
		public static function test6() {}
		static inline function test8() {}
		public static inline function test9() {}
	}";
}