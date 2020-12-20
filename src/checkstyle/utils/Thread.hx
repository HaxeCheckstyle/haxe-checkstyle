package checkstyle.utils;

#if (neko || macro || eval || cpp || hl || java)
typedef Thread = sys.thread.Thread;
#else
typedef Thread = DummyThread;
#end