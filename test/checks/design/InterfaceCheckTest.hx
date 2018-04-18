package checks.design;

import checkstyle.checks.design.InterfaceCheck;

class InterfaceCheckTest extends CheckTestCase<InterfaceCheckTests> {

	static inline var PROPERTIES_MSG:String = "Properties are not allowed in interfaces";
	static inline var MARKER_MSG:String = "Marker interfaces are not allowed";

	@Test
	public function testWithJustProperties() {
		assertMsg(new InterfaceCheck(), TEST1, PROPERTIES_MSG);
	}

	@Test
	public function testMarkerInterface() {
		assertNoMsg(new InterfaceCheck(), TEST2);
	}

	@Test
	public function testNoMarkerInterface() {
		var check = new InterfaceCheck();
		check.allowMarkerInterfaces = false;
		assertMsg(check, TEST2, MARKER_MSG);
	}

	@Test
	public function testCorrectInterface() {
		assertNoMsg(new InterfaceCheck(), TEST3);
	}

	@Test
	public function testAllowProperties() {
		var check = new InterfaceCheck();
		check.allowProperties = true;
		assertNoMsg(check, TEST4);
	}
}

@:enum
abstract InterfaceCheckTests(String) to String {
	var TEST1 = "
	interface IComponentController {
		var a:Int = 1;
	}";

	var TEST2 = "
	interface IComponentController {}";

	var TEST3 = "
	interface IComponentController {
		function init():Void;
	}";

	var TEST4 = "
	interface IComponentController {
		var a:Int;
		var b:String;
		function init():Void;
	}";
}