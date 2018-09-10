package checkstyle;

class CheckerPool {
	var parserQueue:ParserQueue;
	var templateChecker:Checker;
	var threads:Array<CheckerThread>;

	public function new(parserQueue:ParserQueue, templateChecker:Checker) {
		this.parserQueue = parserQueue;
		this.templateChecker = templateChecker;
		threads = [];
	}

	public function start(count:Int) {
		for (i in 0...count) {
			var thread = new CheckerThread(parserQueue);
			threads.push(thread);
			thread.start(templateChecker);
		}
	}

	public function isFinished():Bool {
		if (!parserQueue.isFinished()) return false;
		for (thread in threads) {
			if (!thread.isFinished()) return false;
		}
		return true;
	}
}