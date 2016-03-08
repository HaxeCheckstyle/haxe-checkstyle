package checks.design;

import checkstyle.checks.design.InterfaceIsTypeCheck;

class InterfaceIsTypeCheckTest extends CheckTestCase<InterfaceIsTypeCheckTests> {

	public function testWithJustVars() {
		assertMsg(new InterfaceIsTypeCheck(), InterfaceIsTypeCheckTests.TEST1, "Interfaces should describe a type and hence have methods");
	}

	public function testMarkerInterface() {
		assertNoMsg(new InterfaceIsTypeCheck(), InterfaceIsTypeCheckTests.TEST2);
	}

	public function testNoMarkerInterface() {
		var chk = new InterfaceIsTypeCheck();
		chk.allowMarkerInterfaces = false;
		assertMsg(chk, InterfaceIsTypeCheckTests.TEST2, "Interfaces should describe a type and hence have methods");
	}

	public function testCorrectInterface() {
		assertNoMsg(new InterfaceIsTypeCheck(), InterfaceIsTypeCheckTests.TEST3);
	}
}

@:enum
abstract InterfaceIsTypeCheckTests(String) to String {
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
}