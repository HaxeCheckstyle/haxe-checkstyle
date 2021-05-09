package checkstyle.detect;

import checkstyle.reporter.IReporter;

class DetectionReporter implements IReporter {
	public var messageCount:Int;

	public function new() {
		messageCount = 0;
	}

	public function start() {}

	public function finish() {}

	public function addFile(f:CheckFile) {}

	public function addMessage(m:Message) {
		messageCount++;
	}
}