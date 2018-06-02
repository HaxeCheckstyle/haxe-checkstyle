package checks.whitespace;

import haxe.PosInfos;

import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck;
import checkstyle.checks.whitespace.ExtendedEmptyLinesCheck.EmptyLinesPlace;

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
		runChecks(BEFOREPACKAGE, " before package");
	}

	@Test
	public function testAfterPackage() {
		runChecks(AFTERPACKAGE, " after package");
	}

	@Test
	public function testBetweenImports() {
		runChecks(BETWEENIMPORTS, " between imports/using");
	}

	@Test
	public function testBeforeUsing() {
		runChecks(BEFOREUSING, " between import and using");
	}

	@Test
	public function testAfterImports() {
		runChecks(AFTERIMPORTS, " after imports/using");
	}

	@Test
	public function testAnywhereInFile() {
		runChecks(ANYWHEREINFILE, " anywhere in file", false);
	}

	@Test
	public function testBetweenTypes() {
		runChecks(BETWEENTYPES, " between types");
	}

	@Test
	public function testBeforeFileEnd() {
		runChecks(BEFOREFILEEND, " before file end");
	}

	@Test
	public function testInFunction() {
		runChecks(INFUNCTION, " inside functions", false);
	}

	@Test
	public function testAfterLeftCurly() {
		runChecks(AFTERLEFTCURLY, " after left curly");
	}

	@Test
	public function testBeforeRightCurly() {
		runChecks(BEFORERIGHTCURLY, " before right curly");
	}

	@Test
	public function testTypeDefinition() {
		runChecks(TYPEDEFINITION, " between type definition and left curly");
	}

	@Test
	public function testBeginClass() {
		runChecks(BEGINCLASS, " after left curly");
	}

	@Test
	public function testEndClass() {
		runChecks(ENDCLASS, " before right curly");
	}

	@Test
	public function testAfterClassStaticVars() {
		runChecks(AFTERCLASSSTATICVARS, " after class static vars");
	}

	@Test
	public function testAfterClassVars() {
		runChecks(AFTERCLASSVARS, " after class vars");
	}

	@Test
	public function testBetweenClassStaticVars() {
		runChecks(BETWEENCLASSSTATICVARS, " between class static vars");
	}

	@Test
	public function testBetweenClassVars() {
		runChecks(BETWEENCLASSVARS, " between class vars");
	}

	@Test
	public function testBetweenClassMethods() {
		runChecks(BETWEENCLASSMETHODS, " between class methods");
	}

	@Test
	public function testBeginInterface() {
		runChecks(BEGININTERFACE, " after left curly");
	}

	@Test
	public function testEndInterface() {
		runChecks(ENDINTERFACE, " before right curly");
	}

	@Test
	public function testBetweenInterfaceFields() {
		runChecks(BETWEENINTERFACEFIELDS, " between type fields", false);
	}

	@Test
	public function testBeginEnum() {
		runChecks(BEGINENUM, " after left curly");
	}

	@Test
	public function testEndEnum() {
		runChecks(ENDENUM, " before right curly");
	}

	@Test
	public function testBetweenEnumFields() {
		runChecks(BETWEENENUMFIELDS, " between type fields", false);
	}

	@Test
	public function testBeginTypedef() {
		runChecks(BEGINTYPEDEF, " after left curly");
	}

	@Test
	public function testEndTypedef() {
		runChecks(ENDTYPEDEF, " before right curly");
	}

	@Test
	public function testBetweenTypedefFields() {
		runChecks(BETWEENTYPEDEFFIELDS, " between type fields", false);
	}

	@Test
	public function testBeginAbstract() {
		runChecks(BEGINABSTRACT, " after left curly");
	}

	@Test
	public function testEndAbstract() {
		runChecks(ENDABSTRACT, " before right curly");
	}

	@Test
	public function testAfterAbstractVArs() {
		runChecks(AFTERABSTRACTVARS, " after abstract vars");
	}

	@Test
	public function testBetweenAbstractVars() {
		runChecks(BETWEENABSTRACTVARS, " between abstract vars");
	}

	@Test
	public function testBetweenAbstractMethods() {
		runChecks(BETWEENABSTRACTMETHODS, " between abstract functions");
	}

	@Test
	public function testsingleLineComment() {
		runChecks(AFTERSINGLELINECOMMENT, " after comment");
	}

	@Test
	public function testAfterMultiLineComment() {
		runChecks(AFTERMULTILINECOMMENT, " after comment");
	}

	function runChecks(fieldName:EmptyLinesPlace, postfix:String, hasFixedPosition:Bool = true, ?pos:PosInfos) {
		var check:ExtendedEmptyLinesCheck = makeIgnoredCheck(1);
		assertNoMsg(check, TEST_EXACT_1);
		assertNoMsg(check, TEST_EXACT_2);
		assertNoMsg(check, TEST_NONE);

		runChecksMax1(check, fieldName, postfix, hasFixedPosition, pos);
		runChecksMax2(check, fieldName, postfix, hasFixedPosition, pos);
	}

	function runChecksMax1(check:ExtendedEmptyLinesCheck, fieldName:EmptyLinesPlace, postfix:String, hasFixedPosition:Bool = true, ?pos:PosInfos) {
		check.max = 1;
		check.exact = [fieldName];
		assertNoMsg(check, TEST_EXACT_1);
		assertMsg(check, TEST_EXACT_2, MSG_EXACT_1 + postfix);
		if (hasFixedPosition) assertMsg(check, TEST_NONE, MSG_EXACT_1 + postfix);

		check.exact = [];
		check.none = [fieldName];
		assertMsg(check, TEST_EXACT_1, MSG_NONE + postfix);
		assertMsg(check, TEST_EXACT_2, MSG_NONE + postfix);
		assertNoMsg(check, TEST_NONE);

		check.none = [];
		check.upto = [fieldName];
		assertNoMsg(check, TEST_EXACT_1);
		assertMsg(check, TEST_EXACT_2, MSG_UPTO_1 + postfix);
		assertNoMsg(check, TEST_NONE);

		check.upto = [];
		check.atleast = [fieldName];
		assertNoMsg(check, TEST_EXACT_1);
		assertNoMsg(check, TEST_EXACT_2);
		if (hasFixedPosition) assertMsg(check, TEST_NONE, MSG_ATLEAST_1 + postfix);
	}

	function runChecksMax2(check:ExtendedEmptyLinesCheck, fieldName:EmptyLinesPlace, postfix:String, hasFixedPosition:Bool = true, ?pos:PosInfos) {
		check.max = 2;
		check.atleast = [];
		check.exact = [fieldName];
		assertMsg(check, TEST_EXACT_1, MSG_EXACT_2 + postfix);
		assertNoMsg(check, TEST_EXACT_2);
		if (hasFixedPosition) assertMsg(check, TEST_NONE, MSG_EXACT_2 + postfix);

		check.exact = [];
		check.none = [fieldName];
		assertMsg(check, TEST_EXACT_1, MSG_NONE + postfix);
		assertMsg(check, TEST_EXACT_2, MSG_NONE + postfix);
		assertNoMsg(check, TEST_NONE);

		check.none = [];
		check.upto = [fieldName];
		assertNoMsg(check, TEST_EXACT_1);
		assertNoMsg(check, TEST_EXACT_2);
		assertNoMsg(check, TEST_NONE);

		check.upto = [];
		check.atleast = [fieldName];
		assertMsg(check, TEST_EXACT_1, MSG_ATLEAST_2 + postfix);
		assertNoMsg(check, TEST_EXACT_2);
		if (hasFixedPosition) assertMsg(check, TEST_NONE, MSG_ATLEAST_2 + postfix);
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


	typedef Any = Dynamic;


	typedef Struct =


	{


		var fieldA:String;


		var fieldB:Int;


		var fieldC:Any;


	}

	";
}