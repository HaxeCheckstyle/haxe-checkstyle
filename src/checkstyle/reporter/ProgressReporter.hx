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

	@SuppressWarnings("checkstyle:MagicNumber")
	public function fileStart(f:LintFile) {
		clear();
		var percentage = Math.floor((f.index + 1) / numFiles * 100);
		var line = '${percentage}% - ${f.name}';
		lineLength = line.length;
		Sys.print(line);

		if (f.index == numFiles - 1) {
			Sys.print("\n");
		}
	}

	function clear() {
		Sys.print('\r');
		for (count in 0...lineLength) Sys.print(' ');
		Sys.print('\r');
	}

	public function fileFinish(f:LintFile) {}

	public function addMessage(m:LintMessage) {}
}