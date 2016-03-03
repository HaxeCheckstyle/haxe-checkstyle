package checkstyle.reporter;

class ProgressReporter implements IReporter {

	var lineLength:Int;

	public function new() {}

	public function start() {}

	public function finish() {
		clear();
	}

	public function fileStart(f:LintFile) {
		clear();
		lineLength = f.name.length;
		Sys.print('${f.name}');
	}

	function clear() {
		Sys.print('\r');
		for (count in 0...lineLength) Sys.print(' ');
		Sys.print('\r');
	}

	public function fileFinish(f:LintFile) {}

	public function addMessage(m:LintMessage) {}
}