package checkstyle.reporter;

interface IReporter {
	// Before any file checked
	function start():Void;
	// After all files checked
	function finish():Void;
	// Before file checked
	function fileStart(f:CheckFile):Void;
	// After file checked
	function fileFinish(f:CheckFile):Void;
	// When issue found
	function addMessage(m:CheckMessage):Void;
}