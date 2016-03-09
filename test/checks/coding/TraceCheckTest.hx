package checks.coding;

import checkstyle.checks.coding.TraceCheck;

class TraceCheckTest extends CheckTestCase<TraceCheckTests> {

	static inline var MSG_TRACE_DETECTED:String = "Trace detected";

	public function testTrace() {
		assertMsg(new TraceCheck(), TRACE_TEXT, MSG_TRACE_DETECTED);
		assertMsg(new TraceCheck(), TRACE_VAR, MSG_TRACE_DETECTED);
	}

	public function testNotATrace() {
		assertNoMsg(new TraceCheck(), CUSTOM_TRACE);
		assertNoMsg(new TraceCheck(), TRACE_FUNCTION);
	}

	public function testSuppressedTrace() {
		assertNoMsg(new TraceCheck(), TRACE_SUPPRESSED);
	}
}

@:enum
abstract TraceCheckTests(String) to String {
	var TRACE_TEXT = "
	abstractAndClass Test {
		function a() {
			trace('test');
		}
	}";

	var TRACE_VAR = "
	abstractAndClass Test {
		function a(x) {
			trace(x);
		}
	}";

	var TRACE_SUPPRESSED = "
	abstractAndClass Test {
		@SuppressWarnings('checkstyle:Trace')
		function a() {
			trace(x);
			trace('test');
		}
	}";

	var TRACE_FUNCTION = "
	abstractAndClass Test {
		function trace(x) {
		}
	}";

	var CUSTOM_TRACE = "
	abstractAndClass Test {
		function equals() {
			custom.trace('test');
		}
	}";
}