package checks.type;

import checkstyle.checks.type.DynamicCheck;

class DynamicCheckTest extends CheckTestCase<DynamicCheckTests> {

	public function testNoDynamic() {
		var check = new DynamicCheck();
		assertNoMsg(check, TEST);
	}

	public function testDetectDynamic() {
		var check = new DynamicCheck();
		assertMsg(check, TEST1, 'Dynamic type used: Count');
		assertMsg(check, TEST2, 'Dynamic type used: test');
		assertMsg(check, TEST3, 'Dynamic type used: Count');
		assertMsg(check, TEST4, 'Dynamic type used: param');
		assertMsg(check, TEST5, 'Dynamic type used: test');
		assertMsg(check, TEST6, 'Dynamic type used: Test');

		assertNoMsg(check, ISSUE_43);
	}
}

@:enum
abstract DynamicCheckTests(String) to String {
	var TEST = "
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

	@SuppressWarnings('checkstyle:Dynamic')
	class Testa {
		public var a:Int;
		private var b:Int;
		static var COUNT:Int = 1;
		var count6:Dynamic;

		function calc(val:Dynamic, val2:Dynamic):Dynamic {
			return null;
		}
	}

	enum Test2 {
		count;
		@SuppressWarnings('checkstyle:Dynamic')
		a(field:Dynamic);
	}

	@SuppressWarnings('checkstyle:Dynamic')
	enum Test2a {
		count;
		a(field:Dynamic);
	}

	typedef Test3 = {
		var count1:Int;
		@SuppressWarnings('checkstyle:Dynamic')
		var count2:Dynamic;
	}

	@SuppressWarnings('checkstyle:Dynamic')
	typedef Test3a = {
		var count1:Int;
		var count2:Dynamic;
	}

	@SuppressWarnings('checkstyle:Dynamic')
	typedef Test3b = Array<Dynamic>;";

	var TEST1 = "
	class Test {
		public var Count:Dynamic = 1;
		public function test() {
		}
	}";

	var TEST2 = "
	class Test {
		var Count:Int = 1;
		public function test():Dynamic {
		}
	}";

	var TEST3 =
	"typedef Test = {
		var Count:Dynamic;
	}";

	var TEST4 =
	"extern class Test {
		var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test(param:Dynamic) {
		}
	}";

	var TEST5 = "
	class Test {
		var Count:Int = 1;
		public function test() {
			var test:Dynamic = null;
		}
	}";

	var TEST6 =
	"typedef Test = String -> Dynamic;";

	var ISSUE_43 =
	"class Test {
		function test() {
			cast (Type.createInstance(Array, []));
		}
	}";
}