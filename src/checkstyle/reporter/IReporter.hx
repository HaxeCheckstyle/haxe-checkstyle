package checkstyle.reporter;

import checkstyle.LintMessage;

interface IReporter {
	// Before any file checked
	function start():Void;

	// After all files checked
	function finish():Void;

	// Before file checked
	function fileStart(f:LintFile):Void;

	// After file checked
	function fileFinish(f:LintFile):Void;

	// When issue found
	function addMessage(m:LintMessage):Void;
}
