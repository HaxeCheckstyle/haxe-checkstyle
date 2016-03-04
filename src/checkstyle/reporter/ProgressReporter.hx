package checkstyle.reporter;

class ProgressReporter implements IReporter {

	var lineLength:Int;
	var numFiles:Int;

	public function new(numFiles:Int) {
		this.numFiles = numFiles;
	}

	public function start() {}

	public function finish() {
		clear();
	}

	public function fileStart(f:LintFile) {
		clear();
		lineLength = f.name.length;
		var percentage = Math.floor((f.index + 1) / numFiles * 100);
		Sys.print('${percentage}% - ${f.name}');
	}

	function clear() {
		Sys.print('\r');
		for (count in 0...lineLength) Sys.print(' ');
		Sys.print('\r');
	}

	public function fileFinish(f:LintFile) {}

	public function addMessage(m:LintMessage) {}
}