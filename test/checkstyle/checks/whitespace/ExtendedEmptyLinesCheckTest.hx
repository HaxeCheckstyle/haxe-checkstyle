package checkstyle.checks.whitespace;

import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck.EmptyLinesPlace;
import haxe.PosInfos;

class ExtendedEmptyLinesCheckTest extends CheckTestCase<ExtendedEmptyLinesCheckTests> {
	static inline var MSG_NONE:String = "should not have empty line(s)";
	static inline var MSG_EXACT_1:String = "should have exactly 1 empty line";
	static inline var MSG_EXACT_2:String = "should have exactly 2 empty lines";
	static inline var MSG_UPTO_1:String = "should have upto 1 empty line";
	static inline var MSG_UPTO_2:String = "should have upto 2 empty lines";
	static inline var MSG_ATLEAST_1:String = "should have at least 1 empty line";
	static inline var MSG_ATLEAST_2:String = "should have at least 2 empty lines";

	@Test
	public function testBeforePackage() {
		runChecks(BEFORE_PACKAGE, " before package");
	}

	@Test
	public function testAfterPackage() {
		runChecks(AFTER_PACKAGE, " after package");
	}

	@Test
	public function testBetweenImports() {
		runChecks(BETWEEN_IMPORTS, " between imports/using", 2);
	}

	@Test
	public function testBeforeUsing() {
		runChecks(BEFORE_USING, " between import and using", 2);
	}

	@Test
	public function testAfterImports() {
		runChecks(AFTER_IMPORTS, " after imports/using");
	}

	@Test
	public function testAnywhereInFile() {
		runChecks(ANYWHERE_IN_FILE, " anywhere in file", false, 67);
	}

	@Test
	public function testBetweenTypes() {
		runChecks(BETWEEN_TYPES, " between types", 4);
	}

	@Test
	public function testBeforeFileEnd() {
		runChecks(BEFORE_FILE_END, " before file end");
	}

	@Test
	public function testInFunction() {
		runChecks(IN_FUNCTION, " inside functions", false, 15);
	}

	@Test
	public function testAfterLeftCurly() {
		runChecks(AFTER_LEFT_CURLY, " after left curly", 7);
	}

	@Test
	public function testBeforeRightCurly() {
		runChecks(BEFORE_RIGHT_CURLY, " before right curly", 7);
	}

	@Test
	public function testTypeDefinition() {
		runChecks(TYPE_DEFINITION, " between type definition and left curly", 5);
	}

	@Test
	public function testBeginClass() {
		runChecks(BEGIN_CLASS, " after left curly");
	}

	@Test
	public function testEndClass() {
		runChecks(END_CLASS, " before right curly");
	}

	@Test
	public function testAfterClassStaticVars() {
		runChecks(AFTER_CLASS_STATIC_VARS, " after class static vars");
	}

	@Test
	public function testAfterClassVars() {
		runChecks(AFTER_CLASS_VARS, " after class vars");
	}

	@Test
	public function testBetweenClassStaticVars() {
		runChecks(BETWEEN_CLASS_STATIC_VARS, " between class static vars");
	}

	@Test
	public function testBetweenClassVars() {
		runChecks(BETWEEN_CLASS_VARS, " between class vars");
	}

	@Test
	public function testBetweenClassMethods() {
		runChecks(BETWEEN_CLASS_METHODS, " between class methods");
	}

	@Test
	public function testBeginInterface() {
		runChecks(BEGIN_INTERFACE, " after left curly");
	}

	@Test
	public function testEndInterface() {
		runChecks(END_INTERFACE, " before right curly");
	}

	@Test
	public function testBetweenInterfaceFields() {
		runChecks(BETWEEN_INTERFACE_FIELDS, " between type fields", false);
	}

	@Test
	public function testBeginEnum() {
		runChecks(BEGIN_ENUM, " after left curly");
	}

	@Test
	public function testEndEnum() {
		runChecks(END_ENUM, " before right curly");
	}

	@Test
	public function testBetweenEnumFields() {
		runChecks(BETWEEN_ENUM_FIELDS, " between type fields", false);
	}

	@Test
	public function testBeginTypedef() {
		runChecks(BEGIN_TYPEDEF, " after left curly");
	}

	@Test
	public function testEndTypedef() {
		runChecks(END_TYPEDEF, " before right curly");
	}

	@Test
	public function testBetweenTypedefFields() {
		runChecks(BETWEEN_TYPEDEF_FIELDS, " between type fields", false, 2);
	}

	@Test
	public function testBeginAbstract() {
		runChecks(BEGIN_ABSTRACT, " after left curly");
	}

	@Test
	public function testEndAbstract() {
		runChecks(END_ABSTRACT, " before right curly");
	}

	@Test
	public function testAfterAbstractVArs() {
		runChecks(AFTER_ABSTRACT_VARS, " after abstract vars");
	}

	@Test
	public function testBetweenAbstractVars() {
		runChecks(BETWEEN_ABSTRACT_VARS, " between abstract vars");
	}

	@Test
	public function testBetweenAbstractMethods() {
		runChecks(BETWEEN_ABSTRACT_METHODS, " between abstract functions");
	}

	@Test
	public function testBeforeSingleLineComment() {
		runChecks(BEFORE_SINGLELINE_COMMENT, " before comment", 5);
	}

	@Test
	public function testBeforeMultiLineComment() {
		runChecks(BEFORE_MULTILINE_COMMENT, " before comment");
	}

	@Test
	public function testAfterSingleLineComment() {
		runChecks(AFTER_SINGLELINE_COMMENT, " after comment", 5);
	}

	@Test
	public function testAfterMultiLineComment() {
		runChecks(AFTER_MULTILINE_COMMENT, " after comment");
	}

	function runChecks(fieldName:EmptyLinesPlace, postfix:String, hasFixedPosition:Bool = true, msgCount:Int = 1, ?pos:PosInfos) {
		var check:ExtendedEmptyLinesCheck = makeIgnoredCheck(1);
		assertNoMsg(check, TEST_EXACT_1);
		assertNoMsg(check, TEST_EXACT_2);
		assertNoMsg(check, TEST_NONE);

		runChecksMax1(check, fieldName, postfix, hasFixedPosition, msgCount, pos);
		runChecksMax2(check, fieldName, postfix, hasFixedPosition, msgCount, pos);
	}

	function runChecksMax1(check:ExtendedEmptyLinesCheck, fieldName:EmptyLinesPlace, postfix:String, hasFixedPosition:Bool = true, msgCount:Int = 1,
			?pos:PosInfos) {
		check.max = 1;
		check.exact = [fieldName];
		assertNoMsg(check, TEST_EXACT_1);
		var messages:Array<String> = [for (i in 0...msgCount) MSG_EXACT_1 + postfix];
		assertMessages(check, TEST_EXACT_2, messages);
		if (hasFixedPosition) assertMessages(check, TEST_NONE, messages);

		check.exact = [];
		check.none = [fieldName];
		messages = [for (i in 0...msgCount) MSG_NONE + postfix];
		assertMessages(check, TEST_EXACT_1, messages);
		assertMessages(check, TEST_EXACT_2, messages);
		assertNoMsg(check, TEST_NONE);

		check.none = [];
		check.upto = [fieldName];
		messages = [for (i in 0...msgCount) MSG_UPTO_1 + postfix];
		assertNoMsg(check, TEST_EXACT_1);
		assertMessages(check, TEST_EXACT_2, messages);
		assertNoMsg(check, TEST_NONE);

		check.upto = [];
		check.atleast = [fieldName];
		assertNoMsg(check, TEST_EXACT_1);
		assertNoMsg(check, TEST_EXACT_2);

		messages = [for (i in 0...msgCount) MSG_ATLEAST_1 + postfix];
		if (hasFixedPosition) assertMessages(check, TEST_NONE, messages);
	}

	function runChecksMax2(check:ExtendedEmptyLinesCheck, fieldName:EmptyLinesPlace, postfix:String, hasFixedPosition:Bool = true, msgCount:Int = 1,
			?pos:PosInfos) {
		check.max = 2;
		check.atleast = [];
		check.exact = [fieldName];
		var messages:Array<String> = [for (i in 0...msgCount) MSG_EXACT_2 + postfix];
		assertMessages(check, TEST_EXACT_1, messages);
		assertNoMsg(check, TEST_EXACT_2);
		if (hasFixedPosition) assertMessages(check, TEST_NONE, messages);

		check.exact = [];
		check.none = [fieldName];
		messages = [for (i in 0...msgCount) MSG_NONE + postfix];
		assertMessages(check, TEST_EXACT_1, messages);
		assertMessages(check, TEST_EXACT_2, messages);
		assertNoMsg(check, TEST_NONE);

		check.none = [];
		check.upto = [fieldName];
		assertNoMsg(check, TEST_EXACT_1);
		assertNoMsg(check, TEST_EXACT_2);
		assertNoMsg(check, TEST_NONE);

		check.upto = [];
		check.atleast = [fieldName];
		messages = [for (i in 0...msgCount) MSG_ATLEAST_2 + postfix];
		assertMessages(check, TEST_EXACT_1, messages);
		assertNoMsg(check, TEST_EXACT_2);
		if (hasFixedPosition) assertMessages(check, TEST_NONE, messages);
	}

	function makeIgnoredCheck(max:Int, skipSingleLineTypes:Bool = true):ExtendedEmptyLinesCheck {
		var check:ExtendedEmptyLinesCheck = new ExtendedEmptyLinesCheck();
		check.max = max;
		check.skipSingleLineTypes = skipSingleLineTypes;
		check.defaultPolicy = IGNORE;
		check.ignore = [];
		check.none = [];
		check.exact = [];
		check.upto = [];
		check.atleast = [];
		return check;
	}
}

@:enum
abstract ExtendedEmptyLinesCheckTests(String) to String {
	var TEST_NONE = "package checkstyle;
	import checkstyle.Checker;
	import checkstyle.SeverityLevel;
	using checkstyle.utils.StringUtils;
	using checkstyle.utils.ExprUtils;
	import checkstyle.SeverityLevel;
	class Test {
		static var s1:Int = 1;
		static var s2:String = 'xx';
		var a:Int;
		var b:String = 'x';
		// var c:Int = 5;
		var c:String = 'y';
		function a() {
			callA();
			callB();
			if (test()) {
				callC();
			}
		}
		function b() {
			callA();
			callB();
		}
		// test comment
		// test comment
		function c() {
			callA();
			callB();
		}
		// test comment
	}
	interface ITest {
		function a();
		function b();
	}
	/* long comment
	 * longer
	 */
	enum Test {
		VALUE1;
		VALUE2;
	}
	@:enum
	abstract Test(String) {
		var val1 = 'test';
		var val2 = 'test2';
		// var val3 = 'test3';
		var val4 = 'test4';
		function test() {
		}
		function test2() {
		}
		// comment
		function test3() {
		}
	}
	abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}
	typedef Any = Dynamic;
	typedef Struct = {
		var fieldA:String;
		var fieldB:Int;
		var fieldC:Any;
	}";
	var TEST_EXACT_1 = "
	package checkstyle;

	import checkstyle.Checker;

	import checkstyle.SeverityLevel;

	using checkstyle.utils.StringUtils;

	using checkstyle.utils.ExprUtils;

	import checkstyle.SeverityLevel;

	class Test

	{

		static var s1:Int = 1;

		static var s2:String = 'xx';

		var a:Int;

		var b:String = 'x';

		// var c:Int = 5;

		var c:String = 'y';

		function a() {

			callA();

			callB();

			if (test()) {

				callC();

			}

		}

		function b() {

			callA();

			callB();

		}

		// test comment

		// test comment

		function c() {

			callA();

			callB();

		}

		// test comment

	}

	interface ITest

	{

		function a();

		function b();

	}

	/* long comment
	 * longer
	 */

	enum Test

	{

		VALUE1;

		VALUE2;

	}

	@:enum
	abstract Test(String)

	{

		var val1 = 'test';

		var val2 = 'test';

		// var val3 = 'test3';

		var val4 = 'test4';

		function test() {

		}

		function test2() {

		}

		// comment

		function test3() {

		}

	}

	abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}

	typedef Any = Dynamic;

	typedef Struct =

	{

		var fieldA:String;

		var fieldB:Int;

		var fieldC:Any;

	}
	";
	var TEST_EXACT_2 = "

	package checkstyle;


	import checkstyle.Checker;


	import checkstyle.SeverityLevel;


	using checkstyle.utils.StringUtils;


	using checkstyle.utils.ExprUtils;


	import checkstyle.SeverityLevel;


	class Test


	{


		static var s1:Int = 1;


		static var s2:String = 'xx';


		var a:Int;


		var b:String = 'x';


		// var c:Int = 5;


		var c:String = 'y';


		function a() {


			callA();


			callB();


			if (test()) {


				callC();


			}


		}


		function b() {


			callA();


			callB();


		}


		// test comment


		// test comment


		function c() {


			callA();


			callB();


		}


		// test comment


	}


	interface ITest


	{


		function a();


		function b();


	}


	/* long comment
	 * longer
	 */


	enum Test


	{


		VALUE1;


		VALUE2;


	}


	@:enum
	abstract Test(String)


	{


		var val1 = 'test';


		var val2 = 'test';


		// var val3 = 'test3';


		var val4 = 'test4';


		function test() {


		}


		function test2() {


		}


		// comment


		function test3() {


		}


	}


	abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}


	typedef Any = Dynamic;


	typedef Struct =


	{


		var fieldA:String;


		var fieldB:Int;


		var fieldC:Any;


	}

	";
}