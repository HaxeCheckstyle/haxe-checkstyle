package checkstyle.utils;

#if haxe4
#if (neko || macro || eval || cpp || hl || java)
typedef Thread = sys.thread.Thread;
#else
typedef Thread = DummyThread;
#end
#elseif neko
typedef Thread = neko.vm.Thread;
#elseif cpp
typedef Thread = cpp.vm.Thread;
#elseif java
typedef Thread = java.vm.Thread;
#else
typedef Thread = DummyThread;
#end

class DummyThread {
	public static function create(f:Void -> Void) {
		f();
	}
}