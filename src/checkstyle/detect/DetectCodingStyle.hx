package checkstyle.detect;

import checkstyle.Checker;
import checkstyle.checks.Check;
import checkstyle.config.CheckConfig;
import checkstyle.reporter.ReporterManager;
import checkstyle.utils.ConfigUtils;
import haxe.ds.ArraySort;

class DetectCodingStyle {
	public static function detectCodingStyle(checks:Array<Check>, fileList:Array<CheckFile>):Array<CheckConfig> {
		var detectedChecks:Array<CheckConfig> = [];
		ArraySort.sort(checks, ConfigUtils.checkSort);
		for (check in checks) detectCheck(check, detectedChecks, fileList);

		return detectedChecks;
	}

	static function detectCheck(check:Check, detectedChecks:Array<CheckConfig>, fileList:Array<CheckFile>) {
		var detectableInstances:DetectableInstances = check.detectableInstances();
		if (detectableInstances.length <= 0) return;
		printProgress(check.getModuleName() + ": ");

		if (check.severity == IGNORE) check.severity = INFO;

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
		var detectedValue:Any = null;
		for (file in fileList) {
			var result:DetectionResult = iterateProperty(check, property, file);
			switch (result) {
				case NO_CHANGE:
				case CHANGE_DETECTED(value):
					check.configureProperty(property.propertyName, value);
					return true;
				case REDUCED_VALUE_LIST(value):
					detectedValue = value;
			}
		}
		if (detectedValue != null) {
			check.configureProperty(property.propertyName, detectedValue);
			return true;
		}
		return false;
	}

	static function iterateProperty(check:Check, property:DetectablePropertyList, file:CheckFile):DetectionResult {
		if (property.values.length <= 0) {
			return DetectionResult.NO_CHANGE;
		}
		if (property.values.length == 1) {
			return DetectionResult.CHANGE_DETECTED(property.values[0]);
		}

		var checker:Checker = new Checker();
		checker.addCheck(check);
		checker.loadFileContent(file);
		if (!checker.createContext(file)) return DetectionResult.NO_CHANGE;

		var lastCount:Int = -1;
		var lowestCountValue:Any = null;
		var changed:Bool = false;
		for (value in property.values) {
			check.configureProperty(property.propertyName, value);
			var count:Int = runCheck(checker, [file]);
			if (lastCount == -1) {
				lastCount = count;
				lowestCountValue = value;
				continue;
			}
			if (count == lastCount) continue;
			printProgress(".");
			if (count < lastCount) {
				lastCount = count;
				lowestCountValue = value;
			}
			changed = true;
		}
		if (changed) {
			var index:Int = property.values.indexOf(lowestCountValue);
			if (index <= 0) return DetectionResult.CHANGE_DETECTED(lowestCountValue);
			property.values = property.values.slice(index);
			if (property.values.length > 2) {
				return DetectionResult.REDUCED_VALUE_LIST(lowestCountValue);
			}
			return DetectionResult.CHANGE_DETECTED(lowestCountValue);
		}
		return DetectionResult.NO_CHANGE;
	}

	static function runCheck(checker:Checker, fileList:Array<CheckFile>):Int {
		ReporterManager.INSTANCE.clear();
		var reporter:DetectionReporter = new DetectionReporter();
		ReporterManager.INSTANCE.addReporter(reporter);
		checker.run();
		return reporter.messageCount;
	}

	static function printProgress(text:String, nl:Bool = false) {
		#if unittest
		return;
		#end
		if (nl) Sys.println(text);
		else Sys.print(text);
	}
}