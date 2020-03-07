package checkstyle;

import checkstyle.utils.Mutex;
import checkstyle.utils.Thread;

class ParserQueue {
	static inline var SLEEP_TIME:Float = 0.1;

	var files:Array<CheckFile>;
	var checkers:Array<Checker>;
	var finished:Bool;
	var lock:Mutex;
	var templateChecker:Checker;
	var maxPreparse:Int;

	public function new(files:Array<CheckFile>, templateChecker:Checker) {
		this.files = files;
		this.templateChecker = templateChecker;
		lock = new Mutex();
	}

	public function start(max:Int) {
		if (max <= 0) max = 1;
		maxPreparse = max;
		checkers = [];
		Thread.create(runParser);
	}

	function runParser() {
		finished = false;
		while (files.length > 0) {
			if (checkers.length > maxPreparse) {
				Sys.sleep(SLEEP_TIME);
				continue;
			}
			var file = files.shift();
			var checker:Checker = new Checker();
			checker.baseDefines = templateChecker.baseDefines;
			checker.defineCombinations = templateChecker.defineCombinations;
			checker.loadFileContent(file);
			if (!checker.createContext(file)) {
				checker.unloadFileContent(file);
				continue;
			}

			lock.acquire();
			checkers.push(checker);
			lock.release();
		}
		finished = true;
	}

	public function isFinished():Bool {
		if (checkers.length > 0) return false;
		return finished;
	}

	public function nextFile():Checker {
		var checkFile:Checker = null;
		lock.acquire();
		if (checkers.length > 0) {
			checkFile = checkers.shift();
		}
		lock.release();
		return checkFile;
	}
}