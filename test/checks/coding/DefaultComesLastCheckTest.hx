package checks.coding;

import checkstyle.checks.coding.DefaultComesLastCheck;

class DefaultComesLastCheckTest extends CheckTestCase<DefaultComesLastCheckTests> {

	static inline var MSG:String = 'Default should be last label in the "switch"';

	public function testFirstDefault() {
		assertMsg(new DefaultComesLastCheck(), TEST1, MSG);
	}

	public function testMiddleDefault() {
		assertMsg(new DefaultComesLastCheck(), TEST2, MSG);
	}

	public function testLastDefault() {
		assertNoMsg(new DefaultComesLastCheck(), TEST3);
	}
}

@:enum
abstract DefaultComesLastCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {

		function test() {
			var a =1;
        	switch(a) {
        		default: trace('test');
				case 1:
                case 4:
        	}
		}
	}";

	var TEST2 = "
	abstractAndClass Test {

		function test() {
			var a =1;
        	switch(a) {
				case 1:
				default: trace('test');
                case 4:
        	}
		}
	}";

	var TEST3 = "
	abstractAndClass Test {

		function test() {
			var a =1;
        	switch(a) {
				case 1:
                case 4:
                default: trace('test');
        	}
		}
	}";
}