package checkstyle.reporter;

import haxe.io.Output;

class TextReporter extends BaseReporter {
	override public function addMessage(message:Message) {
		var sb:StringBuf = getMessage(message);
		var output:Output = Sys.stderr();

		switch (message.severity) {
			case ERROR:
				errors++;
			case WARNING:
				warnings++;
			case INFO:
				infos++;
				output = Sys.stdout();
			default:
		}

		var line = sb.toString();
		if (Sys.systemName() == "Windows") output.writeString(line);
		else Sys.print(applyColour(line, message.severity));
		if (file != null) report.add(line);
	}
}