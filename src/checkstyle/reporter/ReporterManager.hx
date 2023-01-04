package checkstyle.reporter;

import checkstyle.Message;
import checkstyle.checks.Category;
import checkstyle.utils.Mutex;

class ReporterManager {
	public static var INSTANCE:ReporterManager = new ReporterManager();
	public static var SHOW_PARSE_ERRORS:Bool = false;

	var reporters:Array<IReporter>;
	var delayedMessageCallbacks:Array<DelayedMessageCallback>;
	var lock:Mutex;

	function new() {
		#if (debug || unittest)
		SHOW_PARSE_ERRORS = true;
		#end
		clear();
		lock = new Mutex();
	}

	public function clear() {
		reporters = [];
		delayedMessageCallbacks = [];
	}

	public function addDelayedMessageCallback(callback:DelayedMessageCallback) {
		delayedMessageCallbacks.push(callback);
	}

	public function addReporter(r:IReporter) {
		reporters.push(r);
	}

	public function start() {
		for (reporter in reporters) reporter.start();
	}

	public function finish() {
		for (delayedMessage in delayedMessageCallbacks) {
			addMessages(delayedMessage());
		}
		for (reporter in reporters) reporter.finish();
	}

	public function addFile(f:CheckFile) {
		lock.acquire();
		for (reporter in reporters) reporter.addFile(f);
		lock.release();
	}

	public function addError(f:CheckFile, e:Any, name:String) {
		if (!SHOW_PARSE_ERRORS) return;
		lock.acquire();
		for (reporter in reporters) reporter.addMessage(getErrorMessage(e, f.name, "Check " + name));
		lock.release();
	}

	public function addMessages(messages:Array<Message>) {
		if ((messages == null) || (messages.length <= 0)) return;
		lock.acquire();
		messages = filterDuplicateMessages(messages);
		for (reporter in reporters) for (m in messages) reporter.addMessage(m);
		lock.release();
	}

	function filterDuplicateMessages(messages:Array<Message>):Array<Message> {
		var filteredMessages = [];
		for (message in messages) {
			var anyDuplicates = false;
			for (filteredMessage in filteredMessages) {
				if (areMessagesSame(message, filteredMessage)) {
					anyDuplicates = true;
					break;
				}
			}
			if (!anyDuplicates) filteredMessages.push(message);
		}
		return filteredMessages;
	}

	function areMessagesSame(a:Message, b:Message):Bool {
		if (a.message != b.message || a.severity != b.severity || a.moduleName != b.moduleName || !messageLocationSame(a, b)) {
			return false;
		}
		if ((a.code == null && b.code != null) || (a.code != null && b.code == null) || (a.code != b.code)) {
			return false;
		}
		if (a.related == null && b.related == null) {
			return true;
		}
		if (a.related == null || b.related == null) {
			return false;
		}
		if (a.related.length != b.related.length) {
			return false;
		}
		for (index in 0...a.related.length) {
			if (!messageLocationSame(a.related[index], b.related[index])) {
				return false;
			}
		}
		return true;
	}

	function messageLocationSame(a:MessageLocation, b:MessageLocation):Bool {
		return (a.fileName == b.fileName && messageRangeSame(a.range, b.range));
	}

	function messageRangeSame(a:MessageRange, b:MessageRange):Bool {
		return ((a.start.line == b.start.line) && (a.start.column == b.start.column) && (a.end.line == b.end.line) && (a.end.column == b.end.column));
	}

	function getErrorMessage(e:Any, fileName:String, step:String):Message {
		return {
			fileName: fileName,
			range: {
				start: {
					line: 1,
					column: 0
				},
				end: {
					line: 1,
					column: 0
				}
			},
			severity: ERROR,
			moduleName: "Checker",
			categories: [Category.STYLE],
			points: 1,
			desc: "",
			code: '$e',
			message: '$step failed: $e\nPlease file a github issue at https://github.com/HaxeCheckstyle/haxe-checkstyle/issues',
			related: []
		};
	}
}

typedef DelayedMessageCallback = () -> Array<Message>;