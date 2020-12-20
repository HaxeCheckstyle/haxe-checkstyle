package checkstyle.checks.comments;

import checkstyle.checks.comments.TypeDocCommentCheck.TypeDocCommentToken;
import checkstyle.utils.PosHelper;

/**
	Checks code documentation on type level
**/
@name("FieldDocComment")
@desc("Checks code documentation on fields")
class FieldDocCommentCheck extends Check {
	/**
		matches only comment docs for types specified in tokens list:
		- ABSTRACT_DEF = abstract definition "abstract Test {}"
		- CLASS_DEF = class definition "class Test {}"
		- ENUM_DEF = enum definition "enum Test {}"
		- INTERFACE_DEF = interface definition "interface Test {}"
		- TYPEDEF_DEF = typdef definition "typedef Test = {}"
	**/
	public var tokens:Array<TypeDocCommentToken>;

	/**
		only check fields of type
		- VARS = only var fields
		- FUNCTIONS = only functions;
		- BOTH = both vars and functions;
	**/
	public var fieldType:FieldDocCommentType;

	/**
		only check fields matching modifier
		- PUBLIC = only public fields
		- PRIVATE = only private fields
		- BOTH = public and private fields
	**/
	public var modifier:FieldDocCommentModifier;

	/**
		ignores requires a `@param` tag for every parameter
	**/
	public var requireParams:Bool;

	/**
		ignores requires a `@return` tag
	**/
	public var requireReturn:Bool;

	/**
		ignores methods marked with override
	**/
	public var ignoreOverride:Bool;

	/**
		exclude field names from check - default: ["new", "toString"]
	**/
	public var excludeNames:Array<String>;

	public function new() {
		super(TOKEN);
		tokens = [ABSTRACT_DEF, CLASS_DEF, ENUM_DEF, INTERFACE_DEF, TYPEDEF_DEF];
		fieldType = BOTH;
		modifier = PUBLIC;
		requireParams = true;
		requireReturn = true;
		excludeNames = ["new", "toString"];
		ignoreOverride = true;
	}

	function hasToken(token:TypeDocCommentToken):Bool {
		return (tokens.length == 0 || tokens.contains(token));
	}

	override function actualRun() {
		var typeTokens:Array<TokenTree> = checker.getTokenTree().filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdAbstract) if (hasToken(ABSTRACT_DEF)):
					FoundSkipSubtree;
				case Kwd(KwdClass) if (hasToken(CLASS_DEF)):
					FoundSkipSubtree;
				case Kwd(KwdEnum) if (hasToken(ENUM_DEF)):
					FoundSkipSubtree;
				case Kwd(KwdInterface) if (hasToken(INTERFACE_DEF)):
					FoundSkipSubtree;
				case Kwd(KwdTypedef) if (hasToken(TYPEDEF_DEF)):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});

		for (typeToken in typeTokens) {
			if (isPosSuppressed(typeToken.pos)) continue;
			var fieldTokens:Array<TokenTree> = typeToken.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
				return switch (token.tok) {
					case Kwd(KwdVar) if ((fieldType == VARS) || (fieldType == BOTH)):
						FoundSkipSubtree;
					case Kwd(KwdFinal) if ((fieldType == VARS) || (fieldType == BOTH)):
						FoundSkipSubtree;
					case Kwd(KwdFunction) if ((fieldType == FUNCTIONS) || (fieldType == BOTH)):
						FoundSkipSubtree;
					default:
						GoDeeper;
				}
			});
			for (token in fieldTokens) {
				checkField(token, isDefaultPublic(typeToken));
			}
		}
	}

	function isDefaultPublic(token:TokenTree):Bool {
		switch (token.tok) {
			case Kwd(KwdAbstract):
				return true;
			case Kwd(KwdInterface):
				return true;
			case Kwd(KwdTypedef):
				return true;
			default:
				return false;
		}
	}

	function checkField(token:TokenTree, defaultPublic:Bool) {
		if (isPosSuppressed(token.pos)) return;
		if (!matchesModifier(token, defaultPublic)) return;
		if (checkIgnoreOverride(token)) return;
		var name:String = getTypeName(token);
		if (excludeNames.indexOf(name) >= 0) return;
		var prevToken:TokenTree = token.previousSibling;

		if (prevToken == null || !prevToken.isComment()) {
			logPos('Field "$name" should have documentation', PosHelper.getReportPos(token));
			return;
		}
		switch (prevToken.tok) {
			case Comment(text):
				checkComment(name, token, prevToken, text);
			default:
		}
	}

	function checkIgnoreOverride(token:TokenTree):Bool {
		if (!ignoreOverride) return false;
		var ignoreTokens:Array<TokenTree> = token.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdOverride):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});
		return (ignoreTokens.length > 0);
	}

	function matchesModifier(token:TokenTree, defaultPublic:Bool):Bool {
		if (modifier == BOTH) return true;

		var modifierList:Array<TokenTree> = token.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdPublic) | Kwd(KwdPrivate):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});
		var isPublic:Bool = defaultPublic;
		for (modToken in modifierList) {
			switch (modToken.tok) {
				case Kwd(KwdPublic):
					isPublic = true;
				case Kwd(KwdPrivate):
					isPublic = false;
				default:
			}
		}
		if (modifier == PUBLIC) return isPublic;
		return !isPublic;
	}

	function getTypeName(token:TokenTree):String {
		var nameTok:TokenTree = TokenTreeAccessHelper.access(token).firstChild().token;
		if (nameTok == null) return "<unknown>";
		switch (nameTok.tok) {
			case Const(CIdent(text)):
				return text;
			case Kwd(KwdNew):
				return "new";
			default:
				return "<unknown>";
		}
	}

	function checkComment(name:String, token:TokenTree, docToken:TokenTree, text:String) {
		if (text == null || StringTools.trim(text).length <= 0) {
			logPos('Documentation for field "$name" should contain text', docToken.pos);
			return;
		}
		var lines:Array<String> = text.split(checker.lineSeparator);
		if (lines.length < 3) {
			logPos('Documentation for field "$name" should have at least one extra line of text', docToken.pos);
			return;
		}
		var firstLine:String = StringTools.trim(lines[1]);
		if ((firstLine == "") || (firstLine == "*")) logPos('Documentation for field "$name" should have at least one extra line of text', docToken.pos);

		switch (token.tok) {
			case Kwd(KwdFunction):
				checkFunctionComment(name, token, docToken, text);
			default:
		}
	}

	function checkFunctionComment(name:String, token:TokenTree, docToken:TokenTree, text:String) {
		if (requireParams) checkParams(name, token, docToken, text);
		if (!requireReturn) return;

		var access:TokenTreeAccessHelper = TokenTreeAccessHelper.access(token).firstChild().firstOf(DblDot);
		var dblDotToken:TokenTree = access.token;
		if (dblDotToken == null) {
			return;
		}
		var identToken:TokenTree = access.firstChild().matches(Const(CIdent("Void"))).token;
		if (identToken != null) return;
		checkReturn(name, docToken, text);
	}

	function checkParams(fieldName:String, token:TokenTree, docToken:TokenTree, text:String) {
		var popenToken:TokenTree = TokenTreeAccessHelper.access(token).firstChild().firstOf(POpen).token;
		if (popenToken == null) return;
		var params:Array<String> = [];
		if (popenToken.children != null) {
			for (child in popenToken.children) {
				switch (child.tok) {
					case Const(CIdent(ident)):
						params.push(ident);
					default:
				}
			}
		}
		checkParamsAndOrder(fieldName, params, docToken, text);
	}

	function checkParamsAndOrder(fieldName:String, params:Array<String>, docToken:TokenTree, text:String) {
		if (params.length <= 0) return;
		var lines:Array<String> = text.split(checker.lineSeparator);
		var paramOrder:Array<Int> = [];
		var missingParams:Array<String> = [];
		for (param in params) {
			var search:String = '@param $param ';
			var index:Int = 0;
			var found:Bool = false;
			while (index < lines.length) {
				var line:String = lines[index++];
				var pos:Int = line.indexOf(search);
				if (pos >= 0) {
					paramOrder.push(index);
					var desc:String = line.substr(pos + search.length);
					found = !~/^[\-\s]*$/.match(desc);
					break;
				}
			}
			if (!found) missingParams.push(param);
		}
		if (missingParams.length > 0) logMissingParams(fieldName, missingParams, docToken);
		else checkParamOrder(fieldName, params, paramOrder, docToken);
	}

	function checkParamOrder(fieldName:String, params:Array<String>, paramOrder:Array<Int>, docToken:TokenTree) {
		var start:Int = 0;
		for (index in 0...paramOrder.length) {
			var value:Int = paramOrder[index];
			if (value > start) {
				start = value;
				continue;
			}
			var param:String = params[index];
			logPos('Incorrect order of documentation for parameter "$param" of field "$fieldName"', docToken.pos);
		}
	}

	function logMissingParams(fieldName:String, params:Array<String>, docToken:TokenTree) {
		for (param in params) logPos('Documentation for parameter "$param" of field "$fieldName" missing', docToken.pos);
	}

	function checkReturn(name:String, docToken:TokenTree, text:String) {
		var search:String = "@return ";
		var pos:Int = text.indexOf(search);
		if (pos < 0) {
			logPos('Documentation for return value of field "$name" missing', docToken.pos);
			return;
		}
		var desc:String = text.substr(pos + search.length);
		var lines:Array<String> = desc.split(checker.lineSeparator);
		if (lines.length < 0) {
			logPos('Documentation for return value of field "$name" missing', docToken.pos);
			return;
		}
		if (!~/^[\-\s]*$/.match(lines[0])) return;
		logPos('Documentation for return value of field "$name" missing', docToken.pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "tokens",
				values: [[ABSTRACT_DEF, CLASS_DEF, ENUM_DEF, INTERFACE_DEF, TYPEDEF_DEF]]
			}, {
				propertyName: "excludeNames",
				values: [["new", "toString"]]
			}, {
				propertyName: "modifier",
				values: [PUBLIC, BOTH, PRIVATE]
			}, {
				propertyName: "fieldType",
				values: [BOTH, FUNCTIONS, VARS]
			}, {
				propertyName: "requireParams",
				values: [true, false]
			}, {
				propertyName: "requireReturn",
				values: [true, false]
			}, {
				propertyName: "ignoreOverride",
				values: [false, true]
			}]
		}];
	}
}

/**
	only check fields of type
	- VARS = only var fields
	- FUNCTIONS = only functions;
	- BOTH = both vars and functions;
**/
enum abstract FieldDocCommentType(String) {
	var VARS = "VARS";
	var FUNCTIONS = "FUNCTIONS";
	var BOTH = "BOTH";
}

/**
	only check fields matching modifier
	- PUBLIC = only public fields
	- PRIVATE = only private fields
	- BOTH = public and private fields
**/
enum abstract FieldDocCommentModifier(String) {
	var PUBLIC = "PUBLIC";
	var PRIVATE = "PRIVATE";
	var BOTH = "BOTH";
}