package checkstyle.checks.block;

class BlockBreakingConditionalCheckTest extends CheckTestCase<BlockBreakingConditionalCheckTests> {
	static inline var MSG_RIGHT_CURLY:String = "Right curly has no matching left curly";

	@Test
	public function testCorrectBlocks() {
		var check:BlockBreakingConditionalCheck = new BlockBreakingConditionalCheck();

		assertNoMsg(check, CORRECT_BLOCKS);
		assertNoMsg(check, CONDITIONAL_IF_SUPPRESSED);
	}

	@Test
	public function testBlockBreakingConditionals() {
		var check:BlockBreakingConditionalCheck = new BlockBreakingConditionalCheck();
		assertMsg(check, CONDITIONAL_IF, MSG_RIGHT_CURLY);
		assertMsg(check, CONDITIONAL_IF_2, MSG_RIGHT_CURLY);
		assertMsg(check, CONDITIONAL_IF_ELSE, MSG_RIGHT_CURLY);
		assertMsg(check, CONDITIONAL_NESTED, MSG_RIGHT_CURLY);
		assertMsg(check, CONDITIONAL_NESTED_2, MSG_RIGHT_CURLY);
	}
}

@:enum
abstract BlockBreakingConditionalCheckTests(String) to String {
	var CORRECT_BLOCKS = "
	class Main {
		public function main () {
			if (true) {
			}
			else{
			}
		}
	}";
	var CONDITIONAL_IF_SUPPRESSED = "
	class Main {
		@SuppressWarnings('checkstyle:BlockBreakingConditional')
		static function main() {
			#if defined
			if (true) {
				trace(' foo ');
			#end
				doSomething(' ');
			#if defined
			}
			#end
	}
	static function main() {}
	}";
	var CONDITIONAL_IF = "
	class Main {
		static function main() {
			#if defined
			if (true) {
				trace(' foo ');
			#end
				doSomething(' ');
			#if defined
			}
			#end
	}
	static function main() {}
	}";
	var CONDITIONAL_IF_2 = "
	class Main {
		static function main() {
			#if defined
			if (true) {
				trace('foo');
			#end
				doSomething('');
			#if defined
			}
			#end
	}
	static function main() {}
	}";
	var CONDITIONAL_IF_ELSE = "
	class Main {
		static function main() {
			#if defined
			if (true) {
			#else
			if (false) {
			#end
				doSomething('');
			}
	}
	static function main() {}
	}";
	var CONDITIONAL_NESTED = "
	#if (!lime_doc_gen || lime_opengl || lime_opengles)
	#if (lime_doc_gen || (sys && lime_cffi && !doc_gen))
	#if (lime_doc_gen)
	abstract OpenGLES3RenderContext(NativeOpenGLRenderContext) from NativeOpenGLRenderContext
	{
	#else
	abstract OpenGLES3RenderContext(OpenGLRenderContext) from OpenGLRenderContext
	{
	#end
	private static var __extensions:String;
	}
	#end
	#end";
	var CONDITIONAL_NESTED_2 = "
	#if (lime_webgl && !doc_gen)

	@:access(lime.graphics.RenderContext)
	#if !doc_gen
	abstract WebGL2RenderContext(OpenGLRenderContext) from OpenGLRenderContext to OpenGLRenderContext
	{
	#else
	abstract WebGL2RenderContext(Dynamic) from Dynamic to Dynamic
	{
	#end

		@:noCompletion private inline function get_BLEND_EQUATION_RGB():Int
		{
			return this.BLEND_EQUATION_RGB;
		}

		#if !lime_webgl
		public function bufferData(target:Int, srcData:ArrayBufferView, usage:Int, srcOffset:Int = 0, length:Int = 0):Void
		{
		#else
		public inline function bufferData(target:Int, srcData:Dynamic, usage:Int, ?srcOffset:Int, ?length:Int):Void
		{
		#end

			var size = (srcData != null) ? srcData.byteLength : 0;

			__tempPointer.set(srcData, srcOffset);
			this.bufferData(target, size, __tempPointer, usage);
			}
			#if !lime_webgl
			public inline function bufferSubData(target:Int, offset:Int, srcData:ArrayBufferView, srcOffset:Int = 0, ?length:Int):Void
			{
			#else
			public inline function bufferSubData(target:Int, offset:Int, srcData:Dynamic, ?srcOffset:Int, ?length:Int):Void
			{
			#end

				var size = (length != null) ? length : (srcData != null) ? srcData.byteLength : 0;

				__tempPointer.set(srcData, srcOffset);
				this.bufferSubData(target, offset, size, __tempPointer);
				} public inline function checkFramebufferStatus(target:Int):Int
				{
					return this.checkFramebufferStatus(target);
				}

	}
	#end";
}