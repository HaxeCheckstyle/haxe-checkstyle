package checkstyle.detect;

import checkstyle.reporter.IReporter;

class DetectionReporter implements IReporter {
	public var messageCount:Int;

	public function new() {
		messageCount = 0;
	}

	public function start() {}

	public function finish() {}

	public function fileStart(f:CheckFile) {}

	public function fileFinish(f:CheckFile) {}

	public function addMessage(m:CheckMessage) {
		messageCount++;
	}
}