package checkstyle.utils;

#if (neko || macro || eval || cpp || hl || java)
typedef Mutex = sys.thread.Mutex;
#else
typedef Mutex = DummyMutex;
#end