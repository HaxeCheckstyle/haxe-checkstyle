package checkstyle;

class CheckerPool {

	var parserQueue:ParserQueue;
	var templateChecker:Checker;
	var threads:Array<CheckerThread>;
	var excludesMap:Map<String, Array<String>>;

	public function new(parserQueue:ParserQueue, templateChecker:Checker, excludesMap:Map<String, Array<String>>) {
		this.parserQueue = parserQueue;
		this.excludesMap = excludesMap;
		this.templateChecker = templateChecker;
		threads = [];
	}

	public function start(count:Int) {
		for (i in 0...count) {
			var thread = new CheckerThread(parserQueue);
			threads.push(thread);
			thread.start(templateChecker, excludesMap);
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