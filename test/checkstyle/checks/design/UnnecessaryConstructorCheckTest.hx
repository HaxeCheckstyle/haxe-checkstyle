package checkstyle.checks.design;

class UnnecessaryConstructorCheckTest extends CheckTestCase<UnnecessaryConstructorCheckTests> {
	@Test
	public function testWithConstructor() {
		assertMsg(new UnnecessaryConstructorCheck(), TEST1, "Unnecessary constructor found");
	}

	@Test
	public function testWithoutConstructor() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST2);
	}

	@Test
	public function testWithConstructorAndInstanceVar() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST3);
	}

	@Test
	public function testWithConstructorAndInstanceFunction() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST4);
	}

	@Test
	public function testJustVarsWithConstructor() {
		assertMsg(new UnnecessaryConstructorCheck(), TEST5, "Unnecessary constructor found");
	}

	@Test
	public function testJustWithConstructor() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST6);
	}

	@Test
	public function testStaticOnlyWithNew() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST_STATIC_ONLY_WITH_NEW);
	}

	@Test
	public function testChildClass() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST_CHILD_CLASS);
	}

	@Test
	public function testSuppression() {
		assertNoMsg(new UnnecessaryConstructorCheck(), SUPPRESS);
		assertNoMsg(new UnnecessaryConstructorCheck(), SUPPRESS_WITH_CONDITIONALS);
	}
}

@:enum
abstract UnnecessaryConstructorCheckTests(String) to String {
	var TEST1 = "
	class Test {
		public function new() {}

		static var a:Int = 1;
		static inline var b:Int = 1;
		public static function walkFile() {}
		static function test() {}
	}";
	var TEST2 = "
	class Test {
		static var a:Int = 1;
		static inline var b:Int = 1;
		public static function walkFile() {}
		static function test() {}
	}";
	var TEST3 = "
	class Test {
		var loc:Float;
		static var a:Int = 1;
		static inline var b:Int = 1;

		public function new() {}

		public static function walkFile() {}

		static function test() {}
	}";
	var TEST4 = "
	class Test {
		var loc:Float;
		static var a:Int = 1;
		static inline var b:Int = 1;

		public function new() {}

		public static function walkFile() {}

		static function test() {}

		public function test2(){}
	}";
	var TEST5 = "
	class Test {
		public function new() {}

		static var a:Int = 1;
		static inline var b:Int = 1;
	}";
	var TEST6 = "
	class Test {
		public function new() {}
	}";
	var TEST_STATIC_ONLY_WITH_NEW = "
	class Test
	{
		public static var VAR1(default, null):String;

		public static function init():Void
		{
			VAR1 = new String();
		}
	}";
	var TEST_CHILD_CLASS = "
	class Test extends Base
	{
		public static var VAR1:String = 'test';

		public function new()
		{
			super(VAR1);
		}
	}";
	var SUPPRESS = "
	@SuppressWarnings('checkstyle:UnnecessaryConstructor')
	class Test {
		public function new() {}

		static var a:Int = 1;
		static inline var b:Int = 1;
		public static function walkFile() {}
		static function test() {}
	}";
	var SUPPRESS_WITH_CONDITIONALS = "
#if !flash
/**
	sandbox
**/
#if !openfl_debug
@:fileXml('tags=haxe,release')
@:noDebug
#end
@SuppressWarnings('checkstyle:UnnecessaryConstructor')
class SecurityDomain
{
	/**
		Gets the current security domain.
	**/
	public static var currentDomain(default, null) = new SecurityDomain();

	// @:noCompletion @:dox(hide) @:require(flash11_3) public var domainID (default, null):String;
	@:noCompletion private function new() {}
}
#else
typedef SecurityDomain = flash.system.SecurityDomain;
#end
	";
}