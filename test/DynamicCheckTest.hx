package ;

import checkstyle.checks.DynamicCheck;

class DynamicCheckTest extends CheckTestCase {

	public function testNoDynamic() {
		var check = new DynamicCheck ();
		assertMsg(check, DynamicTests.TEST, '');
	}

	public function testDetectDynamic() {
		var check = new DynamicCheck ();
		assertMsg(check, DynamicTests.TEST1, 'Dynamic type used: Count');
		assertMsg(check, DynamicTests.TEST2, 'Dynamic type used: test');
		assertMsg(check, DynamicTests.TEST3, 'Dynamic type used: Count');
		assertMsg(check, DynamicTests.TEST4, 'Dynamic type used: param');
		assertMsg(check, DynamicTests.TEST5, 'Dynamic type used: test');
		assertMsg(check, DynamicTests.TEST6, 'Dynamic type used: Test');
	}
}

class DynamicTests {
	public static inline var TEST:String = "
	class Test {
		public var a:Int;
		private var b:Int;
		static var COUNT:Int = 1;
		static inline var COUNT2:Int = 1;
		var count5:Int = 1;

		@SuppressWarnings('checkstyle:Dynamic')
		var count6:Dynamic;

		@SuppressWarnings('checkstyle:Dynamic')
		function calc(val:Dynamic, val2:Dynamic):Dynamic {
			return null;
		}
	}

	enum Test2 {
		count;
		a;
	}
	
	typedef Test3 = {
		var count1:Int;
		var count2:String;
	}";

	public static inline var TEST1:String = "
	class Test {
		public var Count:Dynamic = 1;
		public function test() {
		}
	}";

	public static inline var TEST2:String = "
	class Test {
		var Count:Int = 1;
		public function test():Dynamic {
		}
	}";

	public static inline var TEST3:String =
	"typedef Test = {
		var Count:Dynamic;
	}";

	public static inline var TEST4:String =
	"extern class Test {
		var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test(param:Dynamic) {
		}
	}";

	public static inline var TEST5:String = "
	class Test {
		var Count:Int = 1;
		public function test() {
			var test:Dynamic = null;
		}
	}";

	public static inline var TEST6:String =
	"typedef Test = String -> Dynamic;";

}
