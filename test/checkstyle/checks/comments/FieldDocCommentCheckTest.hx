package checkstyle.checks.comments;

class FieldDocCommentCheckTest extends CheckTestCase<FieldDocCommentCheckTests> {
	static inline var MSG_DOC_FUNC8:String = 'Field "func8" should have documentation';
	static inline var MSG_DOC_FUNC4:String = 'Field "func4" should have documentation';
	static inline var MSG_DOC_PARAM1_FUNC8:String = 'Documentation for parameter "param1" of field "func8" missing';
	static inline var MSG_DOC_RETURN_FUNC8:String = 'Documentation for return value of field "func8" missing';

	@Test
	public function testDefault() {
		var check = new FieldDocCommentCheck();
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ABSTRACT);
		assertNoMsg(check, ENUM);
		assertNoMsg(check, INTERFACE);
		assertNoMsg(check, TYPEDEF);

		assertMsg(check, ONLY_PRIVATE_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC8);
		assertMsg(check, NO_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC8);

		assertMsg(check, MISSING_PARAM, MSG_DOC_PARAM1_FUNC8);
		assertMsg(check, MISSING_RETURN, MSG_DOC_RETURN_FUNC8);

		assertMsg(check, EMPTY_COMMENT, 'Documentation for field "func8" should contain text');
		assertMsg(check, EMPTY_COMMENT_2, 'Documentation for field "func8" should have at least one extra line of text');
		assertMsg(check, EMPTY_COMMENT_3, 'Documentation for field "func8" should have at least one extra line of text');
	}

	@Test
	public function testTokens() {
		var check = new FieldDocCommentCheck();
		check.tokens = [CLASS_DEF];
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ABSTRACT);
		assertNoMsg(check, ENUM);
		assertNoMsg(check, INTERFACE);
		assertNoMsg(check, TYPEDEF);

		assertMsg(check, ONLY_PRIVATE_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC8);
		assertMsg(check, NO_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC8);

		assertMsg(check, MISSING_PARAM, MSG_DOC_PARAM1_FUNC8);
		assertMsg(check, MISSING_RETURN, MSG_DOC_RETURN_FUNC8);

		check.tokens = [INTERFACE_DEF];
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ABSTRACT);
		assertNoMsg(check, ENUM);
		assertNoMsg(check, INTERFACE);
		assertNoMsg(check, TYPEDEF);

		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PRIVATE_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, NO_CLASS_FIELDS_COMMENTED);
	}

	@Test
	public function testModifier() {
		var check = new FieldDocCommentCheck();
		check.modifier = PUBLIC;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertMsg(check, ONLY_PRIVATE_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC8);
		assertMsg(check, MISSING_PARAM, MSG_DOC_PARAM1_FUNC8);
		assertMsg(check, MISSING_RETURN, MSG_DOC_RETURN_FUNC8);

		check.modifier = PRIVATE;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC4);
		assertNoMsg(check, ONLY_PRIVATE_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, MISSING_PARAM);
		assertNoMsg(check, MISSING_RETURN);

		check.modifier = BOTH;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC4);
		assertMsg(check, ONLY_PRIVATE_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC8);
		assertMsg(check, MISSING_PARAM, MSG_DOC_PARAM1_FUNC8);
		assertMsg(check, MISSING_RETURN, MSG_DOC_RETURN_FUNC8);
	}

	@Test
	public function testType() {
		var check = new FieldDocCommentCheck();
		check.fieldType = VARS;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertMsg(check, ONLY_PRIVATE_CLASS_FIELDS_COMMENTED, 'Field "field2" should have documentation');
		assertNoMsg(check, MISSING_PARAM);
		assertNoMsg(check, MISSING_RETURN);

		check.fieldType = FUNCTIONS;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertMsg(check, ONLY_PRIVATE_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC8);
		assertMsg(check, MISSING_PARAM, MSG_DOC_PARAM1_FUNC8);
		assertMsg(check, MISSING_RETURN, MSG_DOC_RETURN_FUNC8);

		check.fieldType = BOTH;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertMsg(check, ONLY_PRIVATE_CLASS_FIELDS_COMMENTED, MSG_DOC_FUNC8);
		assertMsg(check, MISSING_PARAM, MSG_DOC_PARAM1_FUNC8);
		assertMsg(check, MISSING_RETURN, MSG_DOC_RETURN_FUNC8);
	}

	@Test
	public function testRequireParams() {
		var check = new FieldDocCommentCheck();
		check.requireParams = false;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, MISSING_PARAM);
		assertMsg(check, MISSING_RETURN, MSG_DOC_RETURN_FUNC8);
		assertNoMsg(check, WRONG_PARAM_ORDER);
		assertNoMsg(check, NO_PARAM_TEXT);

		check.requireParams = true;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertMsg(check, MISSING_PARAM, MSG_DOC_PARAM1_FUNC8);
		assertMsg(check, MISSING_RETURN, MSG_DOC_RETURN_FUNC8);
		assertMsg(check, WRONG_PARAM_ORDER, 'Incorrect order of documentation for parameter "param2" of field "func8"');
		assertMsg(check, NO_PARAM_TEXT, MSG_DOC_PARAM1_FUNC8);
	}

	@Test
	public function testRequireReturn() {
		var check = new FieldDocCommentCheck();
		check.requireReturn = false;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, MISSING_RETURN);
		assertNoMsg(check, EMPTY_RETURN);

		check.requireReturn = true;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);
		assertNoMsg(check, ONLY_PUBLIC_CLASS_FIELDS_COMMENTED);
		assertMsg(check, MISSING_RETURN, MSG_DOC_RETURN_FUNC8);
		assertMsg(check, EMPTY_RETURN, MSG_DOC_RETURN_FUNC8);
	}

	@Test
	public function testOverride() {
		var check = new FieldDocCommentCheck();
		check.ignoreOverride = true;
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);

		check.ignoreOverride = false;
		assertMsg(check, ALL_CLASS_FIELDS_COMMENTED, 'Field "func9" should have documentation');
	}

	@Test
	public function testExcludeNames() {
		var check = new FieldDocCommentCheck();
		check.excludeNames = ["new", "toString"];
		assertNoMsg(check, ALL_CLASS_FIELDS_COMMENTED);

		check.excludeNames = ["toString"];
		assertMsg(check, ALL_CLASS_FIELDS_COMMENTED, 'Field "new" should have documentation');
	}
}

@:enum
abstract FieldDocCommentCheckTests(String) to String {
	var ALL_CLASS_FIELDS_COMMENTED = "
	class Test1 {}
	class Test2 {
		/**
			comment
		 **/
		var field1:String;
		/**
			comment
		 **/
		public var field2:String;
		/**
			comment
		 **/
		function func1():Void {}
		/**
			comment
			@param param1 - param1
			@param param2 - param2
		 **/
		function func2(param1:String, param2:String):Void {}
		/**
			comment
			@return value
		 **/
		function func3():String {}
		/**
			comment
			@param param1 - param1
			@return value
		 **/
		function func4(param1:String):String {}
		/**
			comment
		 **/
		public function func5():Void {}
		/**
			comment
		 **/
		public function func5a() {}
		/**
			comment
			@param param1 - param1
			@param param2 - param2
		 **/
		public function func6(param1:String, param2:String):Void {}
		/**
			comment
			@return value
		 **/
		public function func7():String {}
		/**
			comment
			@param param1 - param1
			@return value
		 **/
		public function func8(param1:String):String {}
		override public function func9(param1:String):String {}
		public function new(param1:String):String {}
		public function toString():String {}
	}
	";
	var NO_CLASS_FIELDS_COMMENTED = "
	class Test2 {
		var field1:String;
		public var field2:String;
		function func1():Void {}
		function func2(param1:String, param2:String):Void {}
		function func3():String {}
		function func4(param1:String):String {}
		public function func5():Void {}
		public function func5a() {}
		public function func6(param1:String, param2:String):Void {}
		public function func7():String {}
		public function func8(param1:String):String {}
		override public function func9(param1:String):String {}
	}
	";
	var ONLY_PUBLIC_CLASS_FIELDS_COMMENTED = "
	class Test2 {
		var field1:String;
		/**
			comment
		 **/
		public var field2:String;
		function func4(param1:String):String {}
		/**
			comment
			@param param1 - param1
			@return value
		 **/
		public function func8(param1:String):String {}
	}
	";
	var ONLY_PRIVATE_CLASS_FIELDS_COMMENTED = "
	class Test2 {
		/**
			comment
		 **/
		var field1:String;
		public var field2:String;
		/**
			comment
			@param param1 - param1
			@return value
		 **/
		function func4(param1:String):String {}
		public function func8(param1:String):String {}
	}
	";
	var EMPTY_COMMENT = "
	class Test2 {
		/*
		 */
		public function func8():Void {}
	}
	";
	var EMPTY_COMMENT_2 = "
	class Test2 {
		/**
		 **/
		public function func8():Void {}
	}
	";
	var EMPTY_COMMENT_3 = "
	class Test2 {
		/**
		 *
		 **/
		public function func8():Void {}
	}
	";
	var MISSING_RETURN = "
	class Test2 {
		/**
			comment
			@param param1 - param1
		 **/
		public function func8(param1:String):String {}
	}
	";
	var MISSING_PARAM = "
	class Test2 {
		/**
			comment
			@return value
		 **/
		public function func8(param1:String):String {}
	}
	";
	var ABSTRACT = "
	abstract Test(String) {
		/**
			comment
			@param param1 - param1
			@return value
		 **/
		public function func8(param1:String):String {}
	}
	";
	var ENUM = "
	enum Test {
		/**
			comment
		 **/
		FIELD1;
	}
	";
	var INTERFACE = "
	interface Test {
		/**
			comment
			@param param1 - param1
			@return value
		 **/
		public function func8(param1:String):String;
	}
	";
	var TYPEDEF = "
	typedef Test = {
		/**
			comment
		 **/
		var field1:String;
	}
	";
	var WRONG_PARAM_ORDER = "
	class Test2 {
		/**
			comment
			@param param2 - param2
			@param param1 - param1
			@return value
		 **/
		public function func8(param1:String, param2:String):String {}
	}
	";
	var NO_PARAM_TEXT = "
	class Test2 {
		/**
			comment
			@param param1 -
			@return value
		 **/
		public function func8(param1:String):String {}
	}
	";
	var EMPTY_RETURN = "
	class Test2 {
		/**
			comment
			@param param1 - param1
			@return
		 **/
		public function func8(param1:String):String {}
	}
	";
}