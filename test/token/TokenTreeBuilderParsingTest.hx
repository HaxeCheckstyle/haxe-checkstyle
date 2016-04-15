package token;

import haxe.PosInfos;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

class TokenTreeBuilderParsingTest extends haxe.unit.TestCase {

	public function testIssues() {
		assertCodeParses(ISSUE_154);
		assertCodeParses(ISSUE_235);
		assertCodeParses(ISSUE_239);
		assertCodeParses(ISSUE_244);
		assertCodeParses(ISSUE_245);
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
}