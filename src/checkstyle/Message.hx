package checkstyle;

import checkstyle.checks.Category;

typedef Message = MessageLocation & {
	var message:String;
	@:optional var code:String;
	var desc:String;
	var severity:SeverityLevel;
	var moduleName:String;
	var categories:Array<Category>;
	var points:Int;
	var related:Array<MessageLocation>;
};

typedef MessageLocation = {
	var fileName:String;
	var range:MessageRange;
};

typedef MessageRange = {
	var start:MessagePosition;
	var end:MessagePosition;
};

typedef MessagePosition = {
	var line:Int;
	var column:Int;
};