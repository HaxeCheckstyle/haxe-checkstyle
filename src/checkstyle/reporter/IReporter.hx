package checkstyle.reporter;

interface IReporter {
	// Before any file checked
	function start():Void;
	// After all files checked
	function finish():Void;
	// Before file checked
	function addFile(file:CheckFile):Void;
	// When issue found
	function addMessage(message:Message):Void;
}