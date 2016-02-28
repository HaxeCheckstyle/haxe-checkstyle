package checkstyle.reporter;

class ExitCodeReporter implements IReporter {

	var failCheckCount:Int;

	public function new() {
		failCheckCount = 0;
	}

	public function start() {}

	public function finish() {
		Main.setExitCode(failCheckCount);
	}

	public function fileStart(f:LintFile) {}

	public function fileFinish(f:LintFile) {}

	public function addMessage(m:LintMessage) {
		failCheckCount++;
	}
}