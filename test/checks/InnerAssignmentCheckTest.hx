package checks;

import checkstyle.checks.InnerAssignmentCheck;

class InnerAssignmentCheckTest extends CheckTestCase {

	public function testCorrectAssignment() {
		var check = new InnerAssignmentCheck();
		assertMsg(check, InnerAssignmentCheckTests.IF_EXPR, '');
		assertMsg(check, InnerAssignmentCheckTests.WHILE_COND, '');
		assertMsg(check, InnerAssignmentCheckTests.MEMBER_DEF, '');
		assertMsg(check, InnerAssignmentCheckTests.METHOD_DEF, '');
	}

	public function testIncorrectInnerAssignment() {
		var check = new InnerAssignmentCheck();
		assertMsg(check, InnerAssignmentCheckTests.IF_COND, 'Inner assignment detected');
		assertMsg(check, InnerAssignmentCheckTests.IF_RETURN_EXPR, 'Inner assignment detected');
		assertMsg(check, InnerAssignmentCheckTests.WHILE_COND_RETURN, 'Inner assignment detected');
		assertMsg(check, InnerAssignmentCheckTests.SWITCH, 'Inner assignment detected');
	}
}

class InnerAssignmentCheckTests {
	public static inline var IF_COND:String = "
	abstractAndClass Test {
		public function new() {
			if ((a=b) > 0) return;
		}
	}";

	public static inline var IF_EXPR:String = "
	abstractAndClass Test {
		public function new() {
			if (a==b) a=b;
		}
	}";

	public static inline var IF_RETURN_EXPR:String = "
	abstractAndClass Test {
		public function new() {
			if (a==b) return a=b;
		}
	}";

	public static inline var WHILE_COND:String = "
	abstractAndClass Test {
		public function new() {
			while ((a=b) > 0) {
				b=c;
			}
		}
	}";

	public static inline var WHILE_COND_RETURN:String = "
	abstractAndClass Test {
		public function new() {
			while ((a=b) > 0) {
				return b=c;
			}
		}
	}";

	public static inline var METHOD_DEF:String = "
	abstractAndClass Test {
		public function new(a:Null<Int> = 1, b:String = 'test', c = []) {
		}
	}";

	public static inline var MEMBER_DEF:String = "
	abstractAndClass Test {
		var a:Null<Int> = 1;
		var a(default, null):Null<Int> = 1;
		var b:String = 'test';
		var c = [];
		public function new() {
		}
	}";

	public static inline var SWITCH:String = "
	class Test {
		public function new() {
			var p = 1;
			switch p=1 {
				case 1:
					trace(1);
			}
		}
	}";
}