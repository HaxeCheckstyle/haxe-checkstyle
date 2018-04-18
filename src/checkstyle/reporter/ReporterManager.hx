package checkstyle.reporter;

#if neko
import neko.vm.Mutex;
#elseif cpp
import cpp.vm.Mutex;
#end

import haxe.CallStack;

import checkstyle.CheckMessage;

import checkstyle.checks.Category;

class ReporterManager {
	public static var INSTANCE:ReporterManager = new ReporterManager();

	var reporters:Array<IReporter>;
	var lock:Mutex;

	function new () {
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

	public function addParseError(f:CheckFile, e:Any) {
		lock.acquire();
		for (reporter in reporters) {
			reporter.addMessage(getErrorMessage(e, f.name, "Parsing"));
			reporter.fileFinish(f);
		}
		lock.release();
	}

	public function addCheckError(f:CheckFile, e:Any, name:String) {
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
		return
			message1.fileName == message2.fileName &&
			message1.message == message2.message &&
			message1.line == message2.line &&
			message1.startColumn == message2.startColumn &&
			message1.endColumn == message2.endColumn &&
			message1.severity == message2.severity &&
			message1.moduleName == message2.moduleName;
	}

	function getErrorMessage(e:Any, fileName:String, step:String):CheckMessage {
		return {
			fileName:fileName,
			line:1,
			startColumn:0,
			endColumn:0,
			severity:ERROR,
			moduleName:"Checker",
			categories:[Category.STYLE],
			points:1,
			desc: "",
			message:step + " failed: " + e + "\nStacktrace: " + CallStack.toString(CallStack.exceptionStack())
		};
	}
}

#if (!neko && !cpp)
class Mutex {
	public function new() {}
	public function acquire() {}
	public function release() {}
}
#end