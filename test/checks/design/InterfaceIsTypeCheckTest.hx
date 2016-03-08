package checks.design;

import checkstyle.checks.design.InterfaceIsTypeCheck;

class InterfaceIsTypeCheckTest extends CheckTestCase {

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

class InterfaceIsTypeCheckTests {
	public static inline var TEST1:String = "
	interface IComponentController {
		var a:Int = 1;
	}";

	public static inline var TEST2:String = "
	interface IComponentController {}";

	public static inline var TEST3:String = "
	interface IComponentController {
		function init():Void;
	}";
}