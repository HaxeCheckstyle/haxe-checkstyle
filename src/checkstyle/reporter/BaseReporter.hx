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
	var messages:Array<Message>;

	public function new(fileCount:Int, checkCount:Int, usedCheckCount:Int, path:String, ns:Bool) {
		numFiles = fileCount;
		numChecks = checkCount;
		numUsedChecks = usedCheckCount;
		noStyle = ns;
		messages = [];
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

	public function addFile(f:CheckFile) {}

	public function addMessage(m:Message) {
		messages.push(m);
	}

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

	function getMessage(message:Message):StringBuf {
		var sb:StringBuf = new StringBuf();
		sb.add(message.fileName);
		sb.add(":");
		sb.add(message.range.start.line);
		if (message.range.start.column >= 0) {
			var isRange = message.range.start.column != message.range.end.column;
			sb.add(': character${isRange ? "s" : ""} ');
			sb.add(message.range.start.column);
			if (isRange) {
				sb.add("-");
				sb.add(message.range.end.column);
			}
			sb.add(" ");
		}
		sb.add(": ");
		sb.add(message.moduleName);
		sb.add(" - ");
		sb.add(BaseReporter.severityString(message.severity));
		sb.add(": ");
		sb.add(message.message);
		sb.add("\n");
		for (related in message.related) {
			sb.add(' - see also: ${related.fileName}:${related.range.start.line}');
			if (related.range.start.column >= 0) {
				var isRange = related.range.start.column != related.range.end.column;
				sb.add(': character${isRange ? "s" : ""} ');
				sb.add(related.range.start.column);
				if (isRange) {
					sb.add("-");
					sb.add(related.range.end.column);
				}
				sb.add(" ");
			}
			sb.add("\n");
		}

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