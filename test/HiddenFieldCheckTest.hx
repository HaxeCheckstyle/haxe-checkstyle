package ;

import checkstyle.checks.HiddenFieldCheck;

class HiddenFieldCheckTest extends CheckTestCase {

	public function testCorrectHidden() {
		var check = new HiddenFieldCheck();
		assertMsg(check, HiddenFieldCheckTests.NO_HIDDEN_FIELDS, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_CONSTRUCTOR, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_CONSTRUCTOR_VAR, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_SETTER, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_MAIN, '');
	}

	public function testDetectHiddenFields() {
		var check = new HiddenFieldCheck();
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_FUNC, 'Parameter definition of "field1" masks member of same name');
	}

	public function testDetectHiddenFieldsInConstructor() {
		var check = new HiddenFieldCheck();
		check.ignoreConstructorParameter = false;
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_SETTER, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_MAIN, '');
		assertMsg(check, HiddenFieldCheckTests.NO_HIDDEN_FIELDS, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_CONSTRUCTOR, 'Parameter definition of "field1" masks member of same name');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_CONSTRUCTOR_VAR, 'Variable definition of "field2" masks member of same name');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_FUNC, 'Parameter definition of "field1" masks member of same name');
	}

	public function testDetectHiddenFieldsInSetter() {
		var check = new HiddenFieldCheck();
		check.ignoreSetter = false;
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_MAIN, '');
		assertMsg(check, HiddenFieldCheckTests.NO_HIDDEN_FIELDS, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_CONSTRUCTOR, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_CONSTRUCTOR_VAR, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_SETTER, 'Parameter definition of "field2" masks member of same name');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_FUNC, 'Parameter definition of "field1" masks member of same name');
	}

	public function testDetectHiddenFieldsiRegEx() {
		var check = new HiddenFieldCheck();
		check.ignoreFormat = "^test$";
		assertMsg(check, HiddenFieldCheckTests.NO_HIDDEN_FIELDS, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_CONSTRUCTOR, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_CONSTRUCTOR_VAR, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_SETTER, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_FUNC, '');
		assertMsg(check, HiddenFieldCheckTests.HIDDEN_FIELDS_MAIN, 'Variable definition of "field2" masks member of same name');
	}
}

class HiddenFieldCheckTests {
	public static inline var NO_HIDDEN_FIELDS:String = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function new(field3:String) {
			var field4:Float = 1.0;
		}
		public function set_field1(fieldVal:Int) {
			field1 = fieldVal;
		}
		public function setField1(fieldVal:Int) {
			field1 = fieldVal;
		}
		public function test(fieldVal:Int) {
			var field5:String = '';
		}
	}";

	public static inline var HIDDEN_FIELDS_CONSTRUCTOR:String = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function new(field1:String) {
			this.field1 = field1;
		}
	}";

	public static inline var HIDDEN_FIELDS_CONSTRUCTOR_VAR:String = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function new(fieldVal:String) {
			this.field1 = fieldVal;
			var field2:String = 'test';
		}
	}";

	public static inline var HIDDEN_FIELDS_SETTER:String = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function set_field1(field1:Int) {
			field1 = field1;
		}
		public function setField2(field2:Int) {
			field2 = field2;
		}
	}";

	public static inline var HIDDEN_FIELDS_FUNC:String = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function test(field1:Int) {
			field2 = field1;
		}
	}";

	public static inline var HIDDEN_FIELDS_MAIN:String = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public static function main() {
			var field2:String = 'test';
		}
	}";
}