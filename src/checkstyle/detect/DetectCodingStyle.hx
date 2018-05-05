package checkstyle.detect;

import checkstyle.ChecksInfo;
import checkstyle.Config;
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

		for (checkInfo in info.checks()) {
			if (checkInfo.isAlias) continue;
			var check:Check = info.build(checkInfo.name);
			checks.push(check);
		}

		var detectedChecks:Array<CheckConfig> = [];
		for (check in checks) detectCheck(check, detectedChecks, fileList);

		if (detectedChecks.length <= 0) return;

		ConfigUtils.saveCheckConfigList(detectedChecks, fileName);
	}

	static function detectCheck(check:Check, detectedChecks:Array<CheckConfig>, fileList:Array<CheckFile>) {
		var detectableInstances:DetectableInstances = check.detectableInstances();
		if (detectableInstances.length <= 0) return;
		printProgress(check.getModuleName() + ": ");

		for (instance in detectableInstances) {
			for (fixedProp in instance.fixed) {
				check.configureProperty(fixedProp.propertyName, fixedProp.value);
			}
			var checkConfig:CheckConfig = detectPropertyIterations(check, instance.properties, fileList);
			if (checkConfig != null) detectedChecks.push(checkConfig);
		}
	}

	static function detectPropertyIterations(check:Check, detectableProperties:DetectableProperties, fileList:Array<CheckFile>):CheckConfig {
		var ignored:Bool = true;
		for (property in detectableProperties) {
			check.reset();
			if (detectInFiles(check, property, fileList)) ignored = false;
		}
		if (ignored) {
			printProgress(" ignored", true);
			return null;
		}
		else {
			printProgress(" ok", true);
			return ConfigUtils.makeCheckConfig(check);
		}
	}

	static function detectInFiles(check:Check, property:DetectablePropertyList, fileList:Array<CheckFile>):Bool {
		for (file in fileList) {
			var result:DetectionResult = iterateProperty(check, property, file);
			switch (result) {
				case NO_CHANGE:
				case CHANGE_DETECTED(value):
					check.configureProperty(property.propertyName, value);
					return true;
			}
		}
		return false;
	}

	static function iterateProperty(check:Check, property:DetectablePropertyList, file:CheckFile):DetectionResult {
		if (property.values.length <= 0) {
			return NO_CHANGE;
		}
		if (property.values.length == 1) {
			return CHANGE_DETECTED(property.values[0]);
		}

		var checker:Checker = new Checker();
		checker.addCheck(check);

		var lastCount:Int = -1;
		var lowestCountValue:Any = null;
		var changed:Bool = false;
		for (value in property.values) {
			check.configureProperty(property.propertyName, value);
			printProgress(".");
			var count:Int = runCheck(checker, [file]);
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
		if (changed) return CHANGE_DETECTED(lowestCountValue);
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