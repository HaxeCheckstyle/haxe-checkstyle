package checks.coding;

import checkstyle.checks.coding.InnerAssignmentCheck;

class InnerAssignmentCheckTest extends CheckTestCase<InnerAssignmentCheckTests> {

	static inline var MSG_INNER_ASSIGNMENT:String = 'Inner assignment detected';

	public function testCorrectAssignment() {
		var check = new InnerAssignmentCheck();
		assertNoMsg(check, IF_EXPR);
		assertNoMsg(check, WHILE_COND);
		assertNoMsg(check, MEMBER_DEF);
		assertNoMsg(check, METHOD_DEF);
	}

	public function testIncorrectInnerAssignment() {
		var check = new InnerAssignmentCheck();
		assertMsg(check, IF_COND, MSG_INNER_ASSIGNMENT);
		assertMsg(check, IF_RETURN_EXPR, MSG_INNER_ASSIGNMENT);
		assertMsg(check, WHILE_COND_RETURN, MSG_INNER_ASSIGNMENT);
		assertMsg(check, SWITCH, MSG_INNER_ASSIGNMENT);
	}
}

@:enum
abstract InnerAssignmentCheckTests(String) to String {
	var IF_COND = "
	abstractAndClass Test {
		public function new() {
			if ((a=b) > 0) return;
		}
	}";

	var IF_EXPR = "
	abstractAndClass Test {
		public function new() {
			if (a==b) a=b;
		}
	}";

	var IF_RETURN_EXPR = "
	abstractAndClass Test {
		public function new() {
			if (a==b) return a=b;
		}
	}";

	var WHILE_COND = "
	abstractAndClass Test {
		public function new() {
			while ((a=b) > 0) {
				b=c;
			}
		}
	}";

	var WHILE_COND_RETURN = "
	abstractAndClass Test {
		public function new() {
			while ((a=b) > 0) {
				return b=c;
			}
		}
	}";

	var METHOD_DEF = "
	abstractAndClass Test {
		public function new(a:Null<Int> = 1, b:String = 'test', c = []) {
		}
	}";

	var MEMBER_DEF = "
	abstractAndClass Test {
		var a:Null<Int> = 1;
		var a(default, null):Null<Int> = 1;
		var b:String = 'test';
		var c = [];
		public function new() {
		}
	}";

	var SWITCH = "
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