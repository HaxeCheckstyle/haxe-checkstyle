package checkstyle.reporter;

import checkstyle.CheckMessage;
import checkstyle.checks.Category;
import checkstyle.utils.Mutex;

class ReporterManager {
	public static var INSTANCE:ReporterManager = new ReporterManager();
	public static var SHOW_PARSE_ERRORS:Bool = false;

	var reporters:Array<IReporter>;
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
	}

	public function addReporter(r:IReporter) {
		reporters.push(r);
	}

	public function start() {
		for (reporter in reporters) reporter.start();
	}

	public function finish() {
		for (reporter in reporters) reporter.finish();
	}

	public function fileStart(f:CheckFile) {
		lock.acquire();
		for (reporter in reporters) reporter.fileStart(f);
		lock.release();
	}

	public function fileFinish(f:CheckFile) {
		lock.acquire();
		for (reporter in reporters) reporter.fileFinish(f);
		lock.release();
	}

	public function addError(f:CheckFile, e:Any, name:String) {
		if (!SHOW_PARSE_ERRORS) return;
		lock.acquire();
		for (reporter in reporters) reporter.addMessage(getErrorMessage(e, f.name, "Check " + name));
		lock.release();
	}

	public function addMessages(messages:Array<CheckMessage>) {
		if ((messages == null) || (messages.length <= 0)) return;
		lock.acquire();
		messages = filterDuplicateMessages(messages);
		for (reporter in reporters) for (m in messages) reporter.addMessage(m);
		lock.release();
	}

	function filterDuplicateMessages(messages:Array<CheckMessage>):Array<CheckMessage> {
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

	function areMessagesSame(message1:CheckMessage, message2:CheckMessage):Bool {
		return (message1.fileName == message2.fileName
			&& message1.message == message2.message
			&& message1.code == message2.code
			&& message1.startLine == message2.startLine
			&& message1.startColumn == message2.startColumn
			&& message1.endLine == message2.endLine
			&& message1.endColumn == message2.endColumn
			&& message1.severity == message2.severity
			&& message1.moduleName == message2.moduleName);
	}

	function getErrorMessage(e:Any, fileName:String, step:String):CheckMessage {
		return {
			fileName: fileName,
			startLine: 1,
			endLine: 1,
			startColumn: 0,
			endColumn: 0,
			severity: ERROR,
			moduleName: "Checker",
			categories: [Category.STYLE],
			points: 1,
			desc: "",
			code: '$e',
			message: '$step failed: $e\nPlease file a github issue at https://github.com/HaxeCheckstyle/haxe-checkstyle/issues'
		};
	}
}