package checkstyle.utils;

#if debug
import haxe.CallStack;
#end
import checkstyle.reporter.ReporterManager;

class ErrorUtils {
	public static function handleException(e:Any, file:CheckFile, name:String) {
		#if debug
		Sys.println(e);
		Sys.println("File: " + file.name);
		Sys.println("Stacktrace: " + CallStack.toString(CallStack.exceptionStack()));
		#end
		#if unittest
		throw e;
		#end
		ReporterManager.INSTANCE.addError(file, e, name);
	}
}