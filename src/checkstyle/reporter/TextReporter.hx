package checkstyle.reporter;

import checkstyle.LintMessage.SeverityLevel;
import sys.io.FileOutput;
import haxe.io.Output;

class TextReporter extends BaseReporter {

	override public function addMessage(m:LintMessage) {
		var sb:StringBuf = getMessage(m);

		var output:Output = Sys.stderr();

		switch (m.severity) {
			case ERROR: errors++;
			case WARNING: warnings++;
			case INFO:
				infos++;
				output = Sys.stdout();
			default:
		}

		var line = sb.toString();
		output.writeString(line);
		if (file != null) report.add(line);
	}
}