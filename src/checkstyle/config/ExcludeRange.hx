package checkstyle.config;

import checkstyle.Checker.LinePos;

typedef ExcludeRange = {
	var checkName:String;
	var linePosStart:LinePos;
	var linePosEnd:LinePos;
	var charPosStart:Int;
	var charPosEnd:Int;
}