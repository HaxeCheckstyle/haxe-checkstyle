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

	public function fileStart(f:CheckFile) {}

	public function fileFinish(f:CheckFile) {}

	public function addMessage(m:CheckMessage) {
		if (m.severity == ERROR) failCheckCount++;
	}
}