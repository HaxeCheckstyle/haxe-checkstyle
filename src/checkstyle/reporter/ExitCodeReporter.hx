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

	public function addFile(file:CheckFile) {}

	public function addMessage(message:Message) {
		if (message.severity == ERROR) failCheckCount++;
	}
}