package checks.type;

import checkstyle.checks.type.DynamicCheck;

class DynamicCheckTest extends CheckTestCase<DynamicCheckTests> {

	public function testNoDynamic() {
		var check = new DynamicCheck();
		assertNoMsg(check, TEST);
	}

	public function testDetectDynamic() {
		var check = new DynamicCheck();
		assertMsg(check, TEST1, '"Count" type is "Dynamic"');
		assertMsg(check, TEST2, '"test" type is "Dynamic"');
		assertMsg(check, TEST3, '"Count" type is "Dynamic"');
		assertMsg(check, TEST4, '"param" type is "Dynamic"');
		assertMsg(check, TEST5, '"test" type is "Dynamic"');
		assertMsg(check, TEST6, '"Test" type is "Dynamic"');

		assertNoMsg(check, ISSUE_43);
	}
}

@:enum
abstract DynamicCheckTests(String) to String {
	var TEST = "
	import checkstyle.check.type.DynamicCheck;

	using StringTools;

	class Test {
		public var a:Int;
		private var b:Int;
		static var COUNT:Int = 1;
		static inline var COUNT2:Int = 1;
		var count5:Int = 1;

		@SuppressWarnings('checkstyle:Dynamic')
		var count6:Dynamic;

		@SuppressWarnings('checkstyle:Dynamic')
		function calc(?val:Dynamic, val2:Dynamic):Dynamic {
			return 'value';
		}
	}

	abstract Test(String) {
		public var a:Int;
	}

	class Test extends Parent implements Interface {
		function calc(?value:{x:Int, y:Int}, value2:Map<Int, String>) {
			try {
				return [1 + 2, 3];
			}
			catch (e:String) {
				print(e);
			}
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