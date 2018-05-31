package checks.whitespace;

import haxe.PosInfos;

import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck;
import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck.EmptyLinesPolicy;

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
		runChecks("beforePackage", " before package");
	}

	@Test
	public function testAfterPackage() {
		runChecks("afterPackage", " after package");
	}

	@Test
	public function testBetweenImports() {
		runChecks("betweenImports", " between imports/using");
	}

	@Test
	public function testBeforeUsing() {
		runChecks("beforeUsing", " between import and using");
	}

	@Test
	public function testAfterImports() {
		runChecks("afterImports", " after imports/using");
	}

	@Test
	public function testAnywhereInFile() {
		runChecks("anywhereInFile", " anywhere in file", false);
	}

	@Test
	public function testBetweenTypes() {
		runChecks("betweenTypes", " between types");
	}

	@Test
	public function testBeforeFileEnd() {
		runChecks("beforeFileEnd", " before file end");
	}

	@Test
	public function testInFunction() {
		runChecks("inFunction", " inside functions", false);
	}

	@Test
	public function testAfterLeftCurly() {
		runChecks("afterLeftCurly", " after left curly");
	}

	@Test
	public function testBeforeRightCurly() {
		runChecks("beforeRightCurly", " before right curly");
	}

	@Test
	public function testTypeDefinition() {
		runChecks("typeDefinition", " between type definition and left curly");
	}

	@Test
	public function testBeginClass() {
		runChecks("beginClass", " after left curly");
	}

	@Test
	public function testEndClass() {
		runChecks("endClass", " before right curly");
	}

	@Test
	public function testAfterClassStaticVars() {
		runChecks("afterClassStaticVars", " after class static vars");
	}

	@Test
	public function testAfterClassVars() {
		runChecks("afterClassVars", " after class vars");
	}

	@Test
	public function testBetweenClassStaticVars() {
		runChecks("betweenClassStaticVars", " between class static vars");
	}

	@Test
	public function testBetweenClassVars() {
		runChecks("betweenClassVars", " between class vars");
	}

	@Test
	public function testBetweenClassMethods() {
		runChecks("betweenClassMethods", " between class methods");
	}

	@Test
	public function testBeginInterface() {
		runChecks("beginInterface", " after left curly");
	}

	@Test
	public function testEndInterface() {
		runChecks("endInterface", " before right curly");
	}

	@Test
	public function testBetweenInterfaceFields() {
		runChecks("betweenInterfaceFields", " between type fields", false);
	}

	@Test
	public function testBeginEnum() {
		runChecks("beginEnum", " after left curly");
	}

	@Test
	public function testEndEnum() {
		runChecks("endEnum", " before right curly");
	}

	@Test
	public function testBetweenEnumFields() {
		runChecks("betweenEnumFields", " between type fields", false);
	}

	@Test
	public function testBeginTypedef() {
		runChecks("beginTypedef", " after left curly");
	}

	@Test
	public function testEndTypedef() {
		runChecks("endTypedef", " before right curly");
	}

	@Test
	public function testBetweenTypedefFields() {
		runChecks("betweenTypedefFields", " between type fields", false);
	}

	@Test
	public function testBeginAbstract() {
		runChecks("beginAbstract", " after left curly");
	}

	@Test
	public function testEndAbstract() {
		runChecks("endAbstract", " before right curly");
	}

	@Test
	public function testAfterAbstractVArs() {
		runChecks("afterAbstractVars", " after abstract vars");
	}

	@Test
	public function testBetweenAbstractVars() {
		runChecks("betweenAbstractVars", " between abstract vars");
	}

	@Test
	public function testBetweenAbstractMethods() {
		runChecks("betweenAbstractMethods", " between abstract functions");
	}

	@Test
	public function testsingleLineComment() {
		runChecks("afterSingleLineComment", " after comment");
	}

	@Test
	public function testAfterMultiLineComment() {
		runChecks("afterMultiLineComment", " after comment");
	}

	function runChecks(fieldName:String, postfix:String, hasFixedPosition:Bool = true, ?pos:PosInfos) {
		var check:ExtendedEmptyLinesCheck = makeIgnoredCheck(1);
		assertNoMsg(check, TEST_EXACT_1);
		assertNoMsg(check, TEST_EXACT_2);
		assertNoMsg(check, TEST_NONE);

		Reflect.setField(check, fieldName, EXACT);
		assertNoMsg(check, TEST_EXACT_1);
		assertMsg(check, TEST_EXACT_2, MSG_EXACT_1 + postfix);
		if (hasFixedPosition) assertMsg(check, TEST_NONE, MSG_EXACT_1 + postfix);

		Reflect.setField(check, fieldName, NONE);
		assertMsg(check, TEST_EXACT_1, MSG_NONE + postfix);
		assertMsg(check, TEST_EXACT_2, MSG_NONE + postfix);
		assertNoMsg(check, TEST_NONE);

		Reflect.setField(check, fieldName, UPTO);
		assertNoMsg(check, TEST_EXACT_1);
		assertMsg(check, TEST_EXACT_2, MSG_UPTO_1 + postfix);
		assertNoMsg(check, TEST_NONE);

		Reflect.setField(check, fieldName, ATLEAST);
		assertNoMsg(check, TEST_EXACT_1);
		assertNoMsg(check, TEST_EXACT_2);
		if (hasFixedPosition) assertMsg(check, TEST_NONE, MSG_ATLEAST_1 + postfix);

		check.max = 2;
		Reflect.setField(check, fieldName, EXACT);
		assertMsg(check, TEST_EXACT_1, MSG_EXACT_2 + postfix);
		assertNoMsg(check, TEST_EXACT_2);
		if (hasFixedPosition) assertMsg(check, TEST_NONE, MSG_EXACT_2 + postfix);

		Reflect.setField(check, fieldName, NONE);
		assertMsg(check, TEST_EXACT_1, MSG_NONE + postfix);
		assertMsg(check, TEST_EXACT_2, MSG_NONE + postfix);
		assertNoMsg(check, TEST_NONE);

		Reflect.setField(check, fieldName, UPTO);
		assertNoMsg(check, TEST_EXACT_1);
		assertNoMsg(check, TEST_EXACT_2);
		assertNoMsg(check, TEST_NONE);

		Reflect.setField(check, fieldName, ATLEAST);
		assertMsg(check, TEST_EXACT_1, MSG_ATLEAST_2 + postfix);
		assertNoMsg(check, TEST_EXACT_2);
		if (hasFixedPosition) assertMsg(check, TEST_NONE, MSG_ATLEAST_2 + postfix);
	}

	function makeIgnoredCheck(max:Int, skipSingleLineTypes:Bool = true):ExtendedEmptyLinesCheck {
		var check:ExtendedEmptyLinesCheck = new ExtendedEmptyLinesCheck();
		check.max = max;
		check.skipSingleLineTypes = skipSingleLineTypes;

		var policies:Array<String> = [
			"beforePackage", "afterPackage", "betweenImports", "beforeUsing", "afterImports",
			"anywhereInFile", "betweenTypes", "beforeFileEnd", "inFunction", "afterLeftCurly", "beforeRightCurly", "typeDefinition",
			"beginClass", "endClass", "afterClassStaticVars", "afterClassVars", "betweenClassStaticVars",
			"betweenClassVars", "betweenClassMethods", "beginAbstract", "endAbstract",
			"afterAbstractVars", "betweenAbstractVars", "betweenAbstractMethods", "beginInterface",
			"endInterface", "betweenInterfaceFields", "beginEnum", "endEnum", "betweenEnumFields",
			"beginTypedef", "endTypedef", "betweenTypedefFields", "afterSingleLineComment",
			"afterMultiLineComment"
		];
		for (policy in policies) {
			Reflect.setField(check, policy, EmptyLinesPolicy.IGNORE);
		}
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
		function a() {
			callA();
			callB();
			if (test()) {
				callC();
			}
		}
		// test comment
		function b() {
			callA();
			callB();
		}
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
		var val2 = 'test';
		function test() {
		}
		function test2() {
		}
	}
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

		function a() {

			callA();

			callB();

			if (test()) {

				callC();

			}

		}

		// test comment

		function b() {

			callA();

			callB();

		}

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

		function test() {

		}

		function test2() {

		}

	}

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


		function a() {


			callA();


			callB();


			if (test()) {


				callC();


			}


		}


		// test comment


		function b() {


			callA();


			callB();


		}


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


		function test() {


		}


		function test2() {


		}


	}


	typedef Any = Dynamic;


	typedef Struct =


	{


		var fieldA:String;


		var fieldB:Int;


		var fieldC:Any;


	}

	";
}