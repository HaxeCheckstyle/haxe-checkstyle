package checkstyle.detect;

import checkstyle.ChecksInfo;
import checkstyle.Checker;
import checkstyle.checks.Check;
import checkstyle.utils.ConfigUtils;
import checkstyle.reporter.ReporterManager;

#if neko
import neko.Lib;
#elseif cpp
import cpp.Lib;
#else
#end

class DetectCodingStyle {

	public static function detectCodingStyle(info:ChecksInfo, fileList:Array<CheckFile>, fileName:String) {

		var checks:Array<Check> = [];

		// build default check list
		for (checkInfo in info.checks()) {
			if (checkInfo.isAlias) continue;
			var check:Check = info.build(checkInfo.name);
			checks.push(check);
		}

		var detectedChecker:Checker = new Checker();
		for (check in checks) {
			var result:DetectionResult = iterateOptions(check, fileList);
			switch (result) {
				case NO_CHANGE:
				case CHANGE_DETECTED:
					check.reset();
					detectedChecker.addCheck(check);
			}
		}
		if (detectedChecker.checks.length <= 0) return;

		ConfigUtils.saveConfig(detectedChecker, fileName);
	}

	static function iterateOptions(check:Check, fileList:Array<CheckFile>):DetectionResult {

		var detectableProperties:DetectableProperties = check.detectableProperties();
		if (detectableProperties.length <= 0) {
			return NO_CHANGE;
		}
		printProgress(check.getModuleName() + ": ");

		var checker:Checker = new Checker();
		checker.addCheck(check);
		if (check.severity == IGNORE) check.severity = INFO;

		var hasChanges:Bool = false;

		for (prop in detectableProperties) {
			var lastCount:Int = -1;
			var lowestCountValue:Any = null;
			var changed:Bool = false;
			for (value in prop.values) {
				check.configureProperty(prop.propertyName, value);
				printProgress(".");
				var count:Int = runCheck(checker, fileList);
				if (lastCount == -1) {
					lastCount = count;
					lowestCountValue = value;
					continue;
				}
				if (count == lastCount) continue;
				if (count < lastCount) {
					lastCount = count;
					lowestCountValue = value;
				}
				changed = true;
			}
			if (changed) {
				check.configureProperty(prop.propertyName, lowestCountValue);
				hasChanges = true;
				printProgress("*");
			}
		}
		if (hasChanges) {
			printProgress(" ok", true);
			return CHANGE_DETECTED;
		}
		printProgress(" ignored", true);
		return NO_CHANGE;
	}

	static function runCheck(checker:Checker, fileList:Array<CheckFile>):Int {

		ReporterManager.INSTANCE.clear();
		var reporter:DetectionReporter = new DetectionReporter();
		ReporterManager.INSTANCE.addReporter(reporter);
		checker.process(fileList, null);

		return reporter.messageCount;
	}

	static function printProgress(text:String, nl:Bool = false) {
		#if (neko || cpp)
		if (nl) Lib.println(text);
		else Lib.print(text);
		#end
	}
}