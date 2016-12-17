package token;

import haxe.PosInfos;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

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
	}

	public function assertCodeParses(code:String, ?pos:PosInfos) {
		var builder:TestTokenTreeBuilder = null;
		try {
			builder = TestTokenTreeBuilder.parseCode(code);
		}
		catch (e:Dynamic) {
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

}