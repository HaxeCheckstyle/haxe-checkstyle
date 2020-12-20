package checkstyle.reporter;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

class BaseReporter implements IReporter {
	var errors:Int;
	var warnings:Int;
	var infos:Int;
	var total:Int;
	var report:StringBuf;
	var file:FileOutput;
	var numFiles:Int;
	var numChecks:Int;
	var numUsedChecks:Int;
	var noStyle:Bool;

	public function new(fileCount:Int, checkCount:Int, usedCheckCount:Int, path:String, ns:Bool) {
		numFiles = fileCount;
		numChecks = checkCount;
		numUsedChecks = usedCheckCount;
		noStyle = ns;
		if (path != null) {
			var folder = Path.directory(path);
			if (folder.length > 0 && !FileSystem.exists(folder)) FileSystem.createDirectory(folder);
			file = File.write(path);
			report = new StringBuf();
		}
	}

	public function start() {
		errors = 0;
		warnings = 0;
		infos = 0;
		total = 0;

		var version = CheckstyleVersion.getCheckstyleVersion();

		Sys.println("");
		var fileString = (numFiles == 1) ? "file" : "files";
		Sys.println(styleText('Running Checkstyle v$version using $numUsedChecks/$numChecks checks on $numFiles source $fileString...', Style.BOLD));
		Sys.println("");
	}

	public function finish() {
		if (file != null) {
			file.writeString(report.toString());
			file.close();
		}

		total = errors + warnings + infos;

		if (total > 0) {
			// @formatter:off
			Sys.println(
				styleText("\nTotal Issues: " + total + " (", Style.BOLD)
				+ styleText("Errors: " + errors, Style.RED)
				+ styleText(", ", Style.BOLD)
				+ styleText("Warnings: " + warnings, Style.MAGENTA)
				+ styleText(", ", Style.BOLD)
				+ styleText("Infos: " + infos, Style.BLUE)
				+ styleText(")", Style.BOLD));
			// @formatter:on
		}
		else Sys.println(styleText("No issues found.", Style.BOLD));
	}

	public function fileStart(f:CheckFile) {}

	public function fileFinish(f:CheckFile) {}

	public function addMessage(m:CheckMessage) {}

	function styleText(s:String, style:Style):String {
		if (Sys.systemName() == "Windows" || noStyle) return s;
		return '\033[${style}m${s}\033[0m';
	}

	function applyColour(msg:String, s:SeverityLevel):String {
		return switch (s) {
			case ERROR: styleText(msg, Style.RED);
			case WARNING: styleText(msg, Style.MAGENTA);
			case INFO: styleText(msg, Style.BLUE);
			case IGNORE: styleText(msg, Style.BLUE);
		}
	}

	function getMessage(m:CheckMessage):StringBuf {
		var sb:StringBuf = new StringBuf();
		sb.add(m.fileName);
		sb.add(":");
		sb.add(m.startLine);
		if (m.startColumn >= 0) {
			var isRange = m.startColumn != m.endColumn;
			sb.add(': character${isRange ? "s" : ""} ');
			sb.add(m.startColumn);
			if (isRange) {
				sb.add("-");
				sb.add(m.endColumn);
			}
			sb.add(" ");
		}
		sb.add(": ");
		sb.add(m.moduleName);
		sb.add(" - ");
		sb.add(BaseReporter.severityString(m.severity));
		sb.add(": ");
		sb.add(m.message);
		sb.add("\n");

		return sb;
	}

	static function severityString(s:SeverityLevel):String {
		return switch (s) {
			case INFO: "Info";
			case WARNING: "Warning";
			case ERROR: "Error";
			case IGNORE: "Ignore";
		}
	}
}

enum abstract Style(Int) {
	var BOLD = 1;
	var RED = 91;
	var BLUE = 94;
	var MAGENTA = 95;
}