package checkstyle.checks.coding;

import checkstyle.SeverityLevel;

class TraceCheckTest extends CheckTestCase<TraceCheckTests> {
	static inline var MSG_TRACE_DETECTED:String = "Trace detected";

	@Test
	public function testTrace() {
		var check = new TraceCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TRACE_TEXT, MSG_TRACE_DETECTED);
		assertMsg(check, TRACE_VAR, MSG_TRACE_DETECTED);
	}

	@Test
	public function testNotATrace() {
		var check = new TraceCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, CUSTOM_TRACE);
		assertNoMsg(check, TRACE_FUNCTION);
	}

	@Test
	public function testSuppressedTrace() {
		var check = new TraceCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, TRACE_SUPPRESSED);
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