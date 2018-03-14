package checks.coding;

import checkstyle.checks.coding.HiddenFieldCheck;

class HiddenFieldCheckTest extends CheckTestCase<HiddenFieldCheckTests> {

	public function testCorrectHidden() {
		var check = new HiddenFieldCheck();
		assertNoMsg(check, NO_HIDDEN_FIELDS);
		assertNoMsg(check, HIDDEN_FIELDS_CONSTRUCTOR);
		assertNoMsg(check, HIDDEN_FIELDS_CONSTRUCTOR_VAR);
		assertNoMsg(check, HIDDEN_FIELDS_SETTER);
		assertNoMsg(check, HIDDEN_FIELDS_MAIN);
		assertNoMsg(check, HIDDEN_FIELDS_CONSTRUCTOR_VAR_WITH_COMMENT);
	}

	public function testDetectHiddenFields() {
		var check = new HiddenFieldCheck();
		assertMsg(check, HIDDEN_FIELDS_FUNC, 'Parameter definition of "field1" masks member of same name');
		assertMsg(check, HIDDEN_FIELDS_FUNC_WITH_COMMENT, 'Parameter definition of "field1" masks member of same name');
		assertMsg(check, HIDDEN_FIELDS_FOR, 'For loop definition of "field1" masks member of same name');
	}

	public function testDetectHiddenFieldsInConstructor() {
		var check = new HiddenFieldCheck();
		check.ignoreConstructorParameter = false;
		assertNoMsg(check, HIDDEN_FIELDS_SETTER);
		assertNoMsg(check, HIDDEN_FIELDS_MAIN);
		assertNoMsg(check, NO_HIDDEN_FIELDS);
		assertMsg(check, HIDDEN_FIELDS_CONSTRUCTOR, 'Parameter definition of "field1" masks member of same name');
		assertMsg(check, HIDDEN_FIELDS_CONSTRUCTOR_VAR, 'Variable definition of "field2" masks member of same name');
		assertMsg(check, HIDDEN_FIELDS_FUNC, 'Parameter definition of "field1" masks member of same name');
		assertMsg(check, HIDDEN_FIELDS_FUNC_WITH_COMMENT, 'Parameter definition of "field1" masks member of same name');
		assertMsg(check, HIDDEN_FIELDS_CONSTRUCTOR_VAR_WITH_COMMENT, 'Variable definition of "field2" masks member of same name');
	}

	public function testDetectHiddenFieldsInSetter() {
		var check = new HiddenFieldCheck();
		check.ignoreSetter = false;
		assertNoMsg(check, HIDDEN_FIELDS_MAIN);
		assertNoMsg(check, NO_HIDDEN_FIELDS);
		assertNoMsg(check, HIDDEN_FIELDS_CONSTRUCTOR);
		assertNoMsg(check, HIDDEN_FIELDS_CONSTRUCTOR_VAR);
		assertNoMsg(check, HIDDEN_FIELDS_CONSTRUCTOR_VAR_WITH_COMMENT);
		assertMsg(check, HIDDEN_FIELDS_SETTER, 'Parameter definition of "field2" masks member of same name');
		assertMsg(check, HIDDEN_FIELDS_FUNC, 'Parameter definition of "field1" masks member of same name');
		assertMsg(check, HIDDEN_FIELDS_FUNC_WITH_COMMENT, 'Parameter definition of "field1" masks member of same name');
	}

	public function testDetectHiddenFieldsiRegEx() {
		var check = new HiddenFieldCheck();
		check.ignoreFormat = "^test$";
		assertNoMsg(check, NO_HIDDEN_FIELDS);
		assertNoMsg(check, HIDDEN_FIELDS_CONSTRUCTOR);
		assertNoMsg(check, HIDDEN_FIELDS_CONSTRUCTOR_VAR);
		assertNoMsg(check, HIDDEN_FIELDS_CONSTRUCTOR_VAR_WITH_COMMENT);
		assertNoMsg(check, HIDDEN_FIELDS_SETTER);
		assertNoMsg(check, HIDDEN_FIELDS_FUNC);
		assertNoMsg(check, HIDDEN_FIELDS_FUNC_WITH_COMMENT);
		assertMsg(check, HIDDEN_FIELDS_MAIN, 'Variable definition of "field2" masks member of same name');
	}
}

@:enum
abstract HiddenFieldCheckTests(String) to String {
	var NO_HIDDEN_FIELDS = "
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
		@SuppressWarnings('checkstyle:HiddenField')
		public function test(field1:Int) {
			var field2:String = '';
		}
	}";

	var HIDDEN_FIELDS_CONSTRUCTOR = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function new(field1:String) {
			this.field1 = field1;
		}
	}";

	var HIDDEN_FIELDS_CONSTRUCTOR_VAR = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function new(fieldVal:String) {
			this.field1 = fieldVal;
			var field2:String = 'test';
		}
	}";

	var HIDDEN_FIELDS_SETTER = "
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

	var HIDDEN_FIELDS_FUNC = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function test(field1:Int) {
			field2 = field1;
		}
	}";

	var HIDDEN_FIELDS_MAIN = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public static function main() {
			var field2:String = 'test';
		}
	}";

	var HIDDEN_FIELDS_FOR = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function test() {
			for (field1 in []) trace(field1);
		}
	}";

	var HIDDEN_FIELDS_FUNC_WITH_COMMENT = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function test(/* comment */field1/* comment */:/* comment */Int/* comment */)/* comment */ {
			field2 = field1;
		}
	}";

	var HIDDEN_FIELDS_CONSTRUCTOR_VAR_WITH_COMMENT = "
	class Test {
		var field1:Int;
		var field2:Int = 1;
		public function new(fieldVal:String) {
			this.field1 = fieldVal;
			var field2:String='test';
			var /* comment */field2/* comment */:/* comment */String/* comment */ = /* comment */'test'/* comment */;
		}
	}";
}
