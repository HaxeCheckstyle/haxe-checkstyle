package checkstyle;

import checkstyle.checks.Check;
import checkstyle.config.ExcludeManager;
import checkstyle.reporter.ReporterManager;
import checkstyle.utils.Thread;

class CheckerThread {
	static inline var SLEEP_TIME:Float = 0.1;

	var parserQueue:ParserQueue;
	var checks:Array<Check>;
	var finished:Bool;

	public function new(parserQueue:ParserQueue) {
		this.parserQueue = parserQueue;
		finished = false;
		checks = [];
	}

	public function start(templateChecker:Checker) {
		cloneChecks(templateChecker.checks);
		Thread.create(runChecker);
	}

	function cloneChecks(templateChecks:Array<Check>) {
		checks = [];

		var propsNotAllowed:Array<String> = [
			"moduleName",
			"type",
			"categories",
			"points",
			"desc",
			"currentState",
			"skipOverStringStart",
			"commentStartRE",
			"commentBlockEndRE",
			"stringStartRE",
			"stringInterpolatedEndRE",
			"stringLiteralEndRE"
		];

		for (check in templateChecks) {
			var newCheck = Type.createInstance(Type.getClass(check), []);

			for (prop in Reflect.fields(check)) {
				if (propsNotAllowed.contains(prop)) continue;
				Reflect.setField(newCheck, prop, Reflect.field(check, prop));
			}
			checks.push(newCheck);
		}
	}

	function runChecker() {
		finished = false;
		var advanceFrame = function() {};
		#if hxtelemetry
		var hxt = new hxtelemetry.HxTelemetry();
		advanceFrame = function() hxt.advance_frame();
		#end
		while (true) {
			if (parserQueue.isFinished()) break;
			var checker:Checker = parserQueue.nextFile();
			if (checker == null) {
				Sys.sleep(SLEEP_TIME);
				advanceFrame();
				continue;
			}
			advanceFrame();
			runAllChecks(checker);
			advanceFrame();
		}
		finished = true;
	}

	function runAllChecks(checker:Checker) {
		for (check in checks) {
			var messages = [];
			if (check.type == AST) {
				for (ast in checker.asts) {
					checker.ast = ast;
					messages = messages.concat(runCheck(check, checker));
				}
			}
			else {
				// non AST-based checks still need the AST for suppression checking
				checker.ast = checker.asts[0];
				var newMess = runCheck(check, checker);
				messages = messages.concat(newMess);
			}
			ReporterManager.INSTANCE.addMessages(messages);
		}
		ReporterManager.INSTANCE.fileFinish(checker.file);
	}

	function runCheck(check:Check, checker:Checker):Array<CheckMessage> {
		try {
			if (ExcludeManager.isExcludedFromCheck(checker.file.name, check.getModuleName())) return [];
			return check.run(checker);
		}
		catch (e:Any) {
			ErrorUtils.handleException(e, checker.file, check.getModuleName());
		}
		return [];
	}

	public function isFinished():Bool {
		return finished;
	}
}