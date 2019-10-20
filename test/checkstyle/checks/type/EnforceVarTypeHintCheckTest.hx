package checkstyle.checks.type;

class EnforceVarTypeHintCheckTest extends CheckTestCase<EnforceVarTypeHintCheckTests> {
	@Test
	public function testCorrectTypeHints() {
		var check = new EnforceVarTypeHintCheck();
		assertNoMsg(check, CORRECT_TYPE_HINTS);
		assertNoMsg(check, ABSTRACT_ENUM);
		assertNoMsg(check, ABSTRACT_ENUM2);
		assertMsg(check, TYPEDEF, 'Variable "risk" has no type hint');
		#if haxe4
		assertNoMsg(check, FINAL_FUNCTION);
		assertMsg(check, FINAL_VAR, 'Variable "a" has no type hint');
		assertMsg(check, DOLLAR_VAR, 'Variable "$$a" has no type hint');
		#end

		check.ignoreEnumAbstractValues = false;
		assertMsg(check, ABSTRACT_ENUM, 'Variable "STYLE" has no type hint');
		assertMsg(check, ABSTRACT_ENUM2, 'Variable "STYLE" has no type hint');
	}
}

@:enum
abstract EnforceVarTypeHintCheckTests(String) to String {
	var CORRECT_TYPE_HINTS = "
	abstractAndClass Test {
		var a:Int;
		var $a:Int;

		@SuppressWarnings('checkstyle:EnforceVarTypeHint')
		var _b;
	}";
	var ABSTRACT_ENUM = "
	@:enum abstract Category(String) {
		var STYLE = 'Style';
	}";
	var ABSTRACT_ENUM2 = "
	enum abstract Category(String) {
		var STYLE = 'Style';
	}";
	var TYPEDEF = "
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
}