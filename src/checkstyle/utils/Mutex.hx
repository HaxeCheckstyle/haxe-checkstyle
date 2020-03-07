package checkstyle.utils;

#if haxe4
#if (neko || macro || eval || cpp || hl || java)
typedef Mutex = sys.thread.Mutex;
#else
typedef Mutex = DummyMutex;
#end
#elseif neko
typedef Mutex = neko.vm.Mutex;
#elseif cpp
typedef Mutex = cpp.vm.Mutex;
#elseif java
typedef Mutex = java.vm.Mutex;
#else
typedef Mutex = DummyMutex;
#end