package checks.design;

import checkstyle.checks.design.InterfaceIsTypeCheck;

class InterfaceIsTypeCheckTest extends CheckTestCase<InterfaceIsTypeCheckTests> {

	public function testWithJustVars() {
		assertMsg(new InterfaceIsTypeCheck(), TEST1, "Interfaces should describe a type and hence have methods");
	}

	public function testMarkerInterface() {
		assertNoMsg(new InterfaceIsTypeCheck(), TEST2);
	}

	public function testNoMarkerInterface() {
		var chk = new InterfaceIsTypeCheck();
		chk.allowMarkerInterfaces = false;
		assertMsg(chk, TEST2, "Interfaces should describe a type and hence have methods");
	}

	public function testCorrectInterface() {
		assertNoMsg(new InterfaceIsTypeCheck(), TEST3);
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