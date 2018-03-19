package token;

import haxe.PosInfos;

class TokenTreeBuilderParsingTest extends haxe.unit.TestCase {

	public function testIssues() {
		assertCodeParses(ISSUE_76);
		assertCodeParses(ISSUE_79);
		assertCodeParses(ISSUE_154);
		assertCodeParses(ISSUE_235);
		assertCodeParses(ISSUE_238);
		assertCodeParses(ISSUE_239);
		assertCodeParses(ISSUE_244);
		assertCodeParses(ISSUE_245);
		assertCodeParses(ISSUE_249);
		assertCodeParses(ISSUE_251);
		assertCodeParses(ISSUE_252);
		assertCodeParses(ISSUE_253);
		assertCodeParses(ISSUE_256);
		assertCodeParses(DOLLAR_TOKEN_AS_VAR_NAME);
		assertCodeParses(REFERENCE_CONSTRUCTOR);
		assertCodeParses(SHORT_LAMBDA);
		assertCodeParses(EXPRESSION_METADATA_ISSUE_365);
	}

	public function assertCodeParses(code:String, ?pos:PosInfos) {
		var builder:TestTokenTreeBuilder = null;
		try {
			builder = TestTokenTreeBuilder.parseCode(code);
		}
		catch (e:Any) {
			assertTrue(false, pos);
		}
		assertTrue(builder.isStreamEmpty(), pos);
	}
}

@:enum
abstract TokenTreeBuilderParsingTests(String) to String {
	var ISSUE_154 = "
	#if macro
		private enum PrivateEnum {}
	#end
	";

	var ISSUE_235 = "
	#if def
		#if def2
		#end

		#if def3
		#end
	#end
	";

	var ISSUE_239 = "
	#if def1
		#if def2
		#end
		// comment
	#end
	class Foo
	{
#if def1
		#if def2
		#end
		public var test:Int;
#end
	}
	";

	var ISSUE_244 = "
	class Foo {
		var list = ['screenX' #if def , 'screenY' #end];
	}";

	var ISSUE_245 = "
	class Foo {
		function foo() {
			var a = 4, b;
		}
	}";

	var ISSUE_249 = "
	#if def
	#elseif def2
	    #if def3
		#end
		// comment
	#end
	";

	var ISSUE_251 = "
	class Foo {
		function foo() {
			var array = ['string'];
			for (char in array[0].split('')) {}
		}
	}";

	var ISSUE_253 = "
	class Foo {
		var color = #if def { rgb:0x00FFFFFF, a:0 }; #end
	}";

	var ISSUE_256 = "
	class Foo {
		function foo() {
			for /* comment */ (/* comment */ i /* comment */ in /* comment */ 0...10 /* comment */) /* comment */ {}
		}
	}";

	var ISSUE_238 = "
	class Foo
	{
		function foo()
		{
			#if def
			if (true) {}
			else
			{
			#end

			trace('test');

			#if def
			}
			#end
		}
	}";

	var ISSUE_252 = "
	class Foo {
		var library = new #if haxe3 Map<String, #else Hash <#end String>();
	}";

	var ISSUE_76 = "
	class Base {}

	#if true
	class Test extends Base
	#else
	class Test
	#end
	{
	}";

	var ISSUE_79 = "
	class Test {
		function foo() {
			#if true
			if (true) {
			#else
			if (true) {
			#end

			}
		}
	}";

	var DOLLAR_TOKEN_AS_VAR_NAME = "
	class Test {
		function foo() {
			macro var $componentVarName = new $typePath();
		}
	}";

	var REFERENCE_CONSTRUCTOR = "
	@:allow(SomeClass.new) class Test {}
	class Test {
		var constructor = SomeClass.new;
	}";

	var EXPRESSION_METADATA_ISSUE_365 = "
	@test enum ContextSelectorEnum {
		@test(2) DIRECT_CHILD;
	}

	@test class Test2 {
		@test static function main() {
			@test 5 - @test 2;
		}
	}";

	var SHORT_LAMBDA = "
		class TestArrowFunctions extends Test {

		var f0_0: Void -> Int;
		var f0_1: Void -> W;

		var f1_0: Int->Int;
		var f1_1: ?Int->Int;

		var f2_0: Int->Int;

		var f3_0: Int->Int->Int;
		var f3_1: ?Int->String->Int;
		var f3_2: Int->?Int->Int;

		var f4:   Int->(Int->Int);
		var f5:   Int->Int->(Int->Int);
		var f6_a: Int->(Int->(Int->Int));
		var f6_b: Int->(Int->(Int->Int));
		var f7:   (Int->Int)->(Int->Int);
		var f8:   Int -> String;

		var arr: Array<Int->Int> = [];
		var map: Map<Int,Int->Int> = new Map();
		var obj: { f : Int->Int };

		var v0:   Int;
		var v1:   String;

		var maybe : Void -> Bool;

		function testSyntax(){

			// skipping hl for now due to variance errors:
			// Don't know how to cast ref(i32) to null(i32) see issue #6210
			#if !(hl || as3)

			maybe = () -> Math.random() > 0.5;

			v0 = (123);
			v0 = (123:Int);

			f0_0 = function () return 1;
			f0_0 = () -> 1;

			f0_0 = (() -> 1);
			f0_0 = (() -> 1:Void->Int);
			f0_0 = cast (() -> 1:Void->Int);

			v0 = f0_0();

			f0_1 = function () : W return 1;
			v1 = f0_1();

			f0_1 = () -> (1:W);
			v1 = f0_1();

			f1_0 = function (a:Int) return a;
			f1_1 = function (?a:Int) return a;

			f1_0 = a -> a;
			v0 = f1_0(1);

			f1_1 = (?a) -> a;
			v0 = f1_1(1);

			f1_1 = (?a:Int) -> a;
			v0 = f1_1(1);

			f1_1 = (a:Int=1) -> a;
			v0 = f1_1();

			f1_1 = (?a:Int=1) -> a;
			v0 = f1_1();

			f1_1 = function (a=2) return a;
			eq(f1_1(),2);

			f1_1 = (a=2) -> a;
			eq(f1_1(),2);

			f3_0 = function (a:Int, b:Int) return a + b;
			f3_1 = function (?a:Int, b:String) return a + b.length;
			f3_2 = function (a:Int, ?b:Int) return a + b;

			f3_0 = (a:Int, b:Int)  -> a + b;
			f3_1 = (?a:Int, b:String) -> a + b.length;
			f3_2 = (a:Int, ?b:Int) -> a + b;

			#if !flash
			f3_1 = function (a=1, b:String) return a + b.length;
			eq(f3_1('--'),3);

			f3_1 = function (?a:Int=1, b:String) return a + b.length;
			eq(f3_1('--'),3);

			f3_2 = function (a:Int, b=2) return a + b;
			eq(f3_2(1),3);

			f3_1 = (a=1, b:String) -> a + b.length;
			eq(f3_1('--'),3);

			f3_1 = (a:Int=1, b:String) -> a + b.length;
			eq(f3_1('--'),3);

			f3_1 = (?a:Int=1, b:String) -> a + b.length;
			eq(f3_1('--'),3);

			f3_2 = (a:Int, b=2) -> a + b;
			eq(f3_2(1),3);
			#end

			f4 = function (a) return function (b) return a + b;
			f4 = a -> b -> a + b;

			f5 = function (a,b) return function (c) return a + b + c;
			f5 = (a, b) -> c -> a + b + c;

			f6_a = function (a) return function (b) return function (c) return a + b + c;
			f6_b = a -> b -> c -> a + b + c;
			eq(f6_a(1)(2)(3),f6_b(1)(2)(3));

			f7 = function (f:Int->Int) return f;
			f7 = f -> f;
			f7 = (f:Int->Int) -> f;
			f7 = maybe() ? f -> f : f -> g -> f(g);
			f7 = switch maybe() {
				case true:  f -> f;
				case false: f -> g -> f(g);
			};

			f8 = (a:Int) -> ('$a':String);

			arr = [for (i in 0...5) a -> a * i];
			arr = [a -> a + a, b -> b + b, c -> c + c];
			arr.map( f -> f(2) );

			var arr2:Array<Int->W> = [for (f in arr) x -> f(x)];

			map = [1 => a -> a + a, 2 => a -> a + a, 3 => a -> a + a];

			obj = { f : a -> a + a };

			#end
		}
	}";
}