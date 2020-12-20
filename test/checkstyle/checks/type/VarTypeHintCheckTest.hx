package checkstyle.checks.type;

class VarTypeHintCheckTest extends CheckTestCase<VarTypeHintCheckTests> {
	@Test
	public function testEnforceTypeHints() {
		var check = new VarTypeHintCheck();
		check.typeHintPolicy = ENFORCE_ALL;
		assertNoMsg(check, SUPPRESSED_LOCAL_VARS);

		var messages:Array<String> = [for (t in [
			 "test1",  "test2",  "test3",  "test6",  "test9",
			"test10", "test11", "test12", "test13", "test14",
			"test15", "test26", "test27", "test28", "test31",
			"test32", "test33", "test34", "test39", "test41"
		]) {
			'"$t" should have a type hint';
		}];

		assertMessages(check, LOCAL_VARS, messages);
		assertMessages(check, LOCAL_FINALS, messages);

		messages = [for (t in ["test1", "test9", "test13", "test26", "test32", "test39"]) {
			'"$t" should have a type hint';
		}];
		assertMessages(check, MODULE_LEVEL_VARS, messages);
		assertMessages(check, MODULE_LEVEL_FINALS, messages);
		assertMessages(check, TYPEDEF, ['"test0" should have a type hint', '"test1" should have a type hint']);

		assertNoMsg(check, ENUM);
		assertMessages(check, INTERFACE, ['"test0" should have a type hint']);
	}

	@Test
	public function testInferConstAndNewTypeHints() {
		var check = new VarTypeHintCheck();
		check.typeHintPolicy = INFER_NEW_OR_CONST;
		assertNoMsg(check, SUPPRESSED_LOCAL_VARS);

		var messages:Array<String> = [for (t in ["test1", "test2", "test3", "test6", "test12"]) {
			'"$t" should have a type hint';
		}];
		messages = messages.concat([
			for (t in ["test16", "test17", "test20", "test21", "test22", "test29", "test30"]) {
				'"$t" type hint not needed';
			}
		]);
		messages = messages.concat([for (t in ["test32", "test33", "test34"]) {
			'"$t" should have a type hint';
		}]);
		messages.push('"test40" type hint not needed');

		assertMessages(check, LOCAL_VARS, messages);
		assertMessages(check, LOCAL_FINALS, messages);

		messages = [
			'"test1" should have a type hint',
			'"test16" type hint not needed',
			'"test29" type hint not needed',
			'"test32" should have a type hint'
		];
		assertMessages(check, MODULE_LEVEL_VARS, messages);
		assertMessages(check, MODULE_LEVEL_FINALS, messages);
		assertMessages(check, TYPEDEF, ['"test0" should have a type hint', '"test1" should have a type hint']);
		assertNoMsg(check, ENUM);
		assertMessages(check, INTERFACE, ['"test0" should have a type hint']);
	}

	@Test
	public function testInferAllTypeHints() {
		var check = new VarTypeHintCheck();
		check.typeHintPolicy = INFER_ALL;
		assertNoMsg(check, SUPPRESSED_LOCAL_VARS);
		var messages:Array<String> = [for (t in ["test1", "test2", "test3", "test6", "test12"]) {
			'"$t" should have a type hint';
		}];
		messages = messages.concat([for (t in [
			"test16", "test17", "test20", "test21", "test22", "test29",
			"test30", "test35", "test36", "test37", "test38", "test40"
		]) {
			'"$t" type hint not needed';
		}]);

		assertMessages(check, LOCAL_VARS, messages);
		assertMessages(check, LOCAL_FINALS, messages);

		messages = [
			'"test1" should have a type hint',
			'"test16" type hint not needed',
			'"test29" type hint not needed',
			'"test35" type hint not needed',
			'"test38" type hint not needed'
		];
		assertMessages(check, MODULE_LEVEL_VARS, messages);
		assertMessages(check, MODULE_LEVEL_FINALS, messages);
		assertMessages(check, TYPEDEF, ['"test0" should have a type hint', '"test1" should have a type hint']);
		assertNoMsg(check, ENUM);
		assertMessages(check, INTERFACE, ['"test0" should have a type hint']);
	}

	@Test
	public function testCorrectTypeHints() {
		var check = new VarTypeHintCheck();
		check.typeHintPolicy = ENFORCE_ALL;

		assertNoMsg(check, CORRECT_TYPE_HINTS);
		assertNoMsg(check, ABSTRACT_ENUM);
		assertNoMsg(check, ABSTRACT_ENUM2);
		assertMsg(check, TYPEDEF_OLD, '"risk" should have a type hint');
		assertNoMsg(check, FINAL_FUNCTION);
		assertMsg(check, FINAL_VAR, '"a" should have a type hint');

		assertNoMsg(check, DOLLAR_VAR_CORRECT);
		assertMsg(check, DOLLAR_VAR, '"$$a" should have a type hint');

		check.ignoreEnumAbstractValues = false;
		assertMsg(check, ABSTRACT_ENUM, '"STYLE" should have a type hint');
		assertMsg(check, ABSTRACT_ENUM2, '"STYLE" should have a type hint');
	}
}

enum abstract VarTypeHintCheckTests(String) to String {
	var MODULE_LEVEL_VARS = "
	var test0:Int;
	var test1;
	var test9 = 10;
	var test13 = '10';
	var test16:Int = 10;

	var test26 = new Test();
	var test29:Test = new Test();
	var test32 = call();
	var test35:Test = call();
	var test38:Test = /** **/ call();

	var test39 = true;
	";
	var MODULE_LEVEL_FINALS = "
	final test0:Int;
	final test1;
	final test9 = 10;
	final test13 = '10';
	final test16:Int = 10;

	final test26 = new Test();
	final test29:Test = new Test();
	final test32 = call();
	final test35:Test = call();
	final test38:Test = /** **/ call();

	final test39 = true;
	";
	var LOCAL_VARS = "
	abstractAndClass Test {
		function test() {
			var test0:Int;
			var test1, test2;
			var test3, test4:Int;
			var test5:Int, test6;
			var test7:Int, test8:Int;

			var test9 = 10;
			var test10 = 10, test11 = '10';
			var test12, test13 = '10';
			var test14 = 10, test15 = '12';

			var test16:Int = 10;
			var test17:Int = 10, test18:String;
			var test19:Int, test20:String = '14';
			var test21:Int = 10, test22:String = '14';

			// var @:meta test23:Int = 10;
			// var @:meta test24:Int = 10, @:meta test25:Int = 10;

			var test26 = new Test();
			var test27 = new Test(), test28 = new Test2();

			var test29:Test = new Test();
			var test30:Test = new Test(), test31 = new Test2();

			var test32 = call();
			var test33 = call(), test34 = call();

			var test35:Test = call();
			var test36:Test = call(), test37:Test = call();

			var test38:Test = /** **/ call();

			var test39 = true;
			var test40:Bool = true, test41 = false;
		};
	}
	";
	var LOCAL_FINALS = "
	abstractAndClass Test {
		function test() {
			final test0:Int;
			final test1, test2;
			final test3, test4:Int;
			final test5:Int, test6;
			final test7:Int, test8:Int;

			final test9 = 10;
			final test10 = 10, test11 = '10';
			final test12, test13 = '10';
			final test14 = 10, test15 = '12';

			final test16:Int = 10;
			final test17:Int = 10, test18:String;
			final test19:Int, test20:String = '14';
			final test21:Int = 10, test22:String = '14';

			// final @:meta test23:Int = 10;
			// final @:meta test24:Int = 10, @:meta test25:Int = 10;

			final test26 = new Test();
			final test27 = new Test(), test28 = new Test2();

			final test29:Test = new Test();
			final test30:Test = new Test(), test31 = new Test2();

			final test32 = call();
			final test33 = call(), test34 = call();

			final test35:Test = call();
			final test36:Test = call(), test37:Test = call();

			final test38:Test = /** **/ call();

			final test39 = true;
			final test40:Bool = true, test41 = false;
		};
	}
	";
	var SUPPRESSED_LOCAL_VARS = "
	abstractAndClass Test {
		@SuppressWarnings('checkstyle:VarTypeHint')
		function test() {
			var test0:Int;
			var test1, test2;
			var test3, test4:Int;
			var test5:Int, test6;
			var test7:Int, test8:Int;

			var test9 = 10;
			var test10 = 10, test11 = '10';
			var test12, test13 = '10';
			var test14 = 10, test15 = '12';

			var test16:Int = 10;
			var test17:Int = 10, test18:String;
			var test19:Int, test20:String = '14';
			var test21:Int = 10, test22:String = '14';

			// var @:meta test23:Int = 10;
			// var @:meta test24:Int = 10, @:meta test25:Int = 10;

			var test26 = new Test();
			var test27 = new Test(), test28 = new Test2();

			var test29:Test = new Test();
			var test30:Test = new Test(), test31 = new Test2();

			var test32 = call();
			var test33 = call(), test34 = call();

			var test35:Test = call();
			var test36:Test = call(), test37:Test = call();

			var test38:Test = /** **/ call();
		};
	}
	";
	var ENUM = "
	enum abstract Category(String) {
		var STYLE = 'Style';
	}
	enum abstract Category(String) {
		var STYLE = 'Style';
	}
	enum Category {
		STYLE;
	}
	";
	var TYPEDEF = "
	typedef Category = {
		var test0;
		var ?test1;
		var test2:Int;
		var ?test3:Int;
	}
	";
	var INTERFACE = "
	interface Category {
		var test0;
		var test1:Int;
	}
	";
	var CORRECT_TYPE_HINTS = "
	abstractAndClass Test {
		var a:Int;

		@SuppressWarnings('checkstyle:VarTypeHint')
		var _b;
	}";
	var ABSTRACT_ENUM = "
	enum abstract Category(String) {
		var STYLE = 'Style';
	}";
	var ABSTRACT_ENUM2 = "
	enum abstract Category(String) {
		var STYLE = 'Style';
	}";
	var TYPEDEF_OLD = "
	typedef Category = {
		var risk;
	}";
	var FINAL_VAR = "
	abstractAndClass Test {
		final a;
	}";
	var FINAL_FUNCTION = "
	abstractAndClass Test {
		final function test() {};
	}";
	var DOLLAR_VAR = "
	abstractAndClass Test {
		var $a;
	}";
	var DOLLAR_VAR_CORRECT = "
	abstractAndClass Test {
		var $a:Int;
	}";
}