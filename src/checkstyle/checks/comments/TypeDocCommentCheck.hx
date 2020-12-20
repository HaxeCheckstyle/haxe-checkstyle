package checkstyle.checks.comments;

/**
	Checks code documentation on type level
**/
@name("TypeDocComment")
@desc("Checks code documentation on type level")
class TypeDocCommentCheck extends Check {
	/**
		matches only comment docs for types specified in tokens list:
		- ABSTRACT_DEF = abstract definition "abstract Test {}"
		- CLASS_DEF = class definition "class Test {}"
		- ENUM_DEF = enum definition "enum Test {}"
		- INTERFACE_DEF = interface definition "interface Test {}"
		- TYPEDEF_DEF = typdef definition "typedef Test = {}"
	**/
	public var tokens:Array<TypeDocCommentToken>;

	public function new() {
		super(TOKEN);
		tokens = [ABSTRACT_DEF, CLASS_DEF, ENUM_DEF, INTERFACE_DEF, TYPEDEF_DEF];
	}

	function hasToken(token:TypeDocCommentToken):Bool {
		return (tokens.length == 0 || tokens.contains(token));
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();

		var docTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
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
				case _:
					GoDeeper;
			}
		});
		for (token in docTokens) {
			if (isPosSuppressed(token.pos)) continue;
			var name:String = getTypeName(token);
			var docToken:Null<TokenTree> = findDocToken(token);
			if (docToken == null) {
				logPos('Type "$name" should have documentation', token.pos);
				continue;
			}
			switch (docToken.tok) {
				case Comment(text):
					checkComment(name, docToken, text);
				default:
			}
		}
	}

	function getTypeName(token:TokenTree):String {
		var nameTok:TokenTree = TokenTreeAccessHelper.access(token).firstChild().token;
		if (nameTok == null) return "<unknown>";
		switch (nameTok.tok) {
			case Const(CIdent(text)):
				return text;
			default:
				return "<unknown>";
		}
	}

	function findDocToken(token:TokenTree):Null<TokenTree> {
		if (token.previousSibling == null) {
			return null;
		}
		var docToken:Null<TokenTree> = token.previousSibling;
		while (docToken != null) {
			switch (docToken.tok) {
				case Sharp(s):
					var notAllowed:Array<TokenTree> = docToken.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
						return switch (token.tok) {
							case Kwd(KwdAbstract) | Kwd(KwdClass) | Kwd(KwdEnum) | Kwd(KwdInterface) | Kwd(KwdTypedef) | Kwd(KwdImport) | Kwd(KwdUsing):
								FoundSkipSubtree;
							default:
								GoDeeper;
						}
					});

					if (notAllowed.length > 0) {
						return null;
					}
					docToken = docToken.previousSibling;
				case Comment(s):
					return docToken;
				default:
					return null;
			}
		}
		return null;
	}

	function checkComment(name:String, token:TokenTree, text:String) {
		if (text == null || StringTools.trim(text).length <= 0) {
			logPos('Documentation for type "$name" should contain text', token.pos);
			return;
		}
		var lines:Array<String> = text.split(checker.lineSeparator);
		if (lines.length < 3) {
			logPos('Documentation for type "$name" should have at least one extra line of text', token.pos);
			return;
		}
		var firstLine:String = StringTools.trim(lines[1]);
		if ((firstLine == "") || (firstLine == "*")) logPos('Documentation for type "$name" should have at least one extra line of text', token.pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "tokens",
				values: [[ABSTRACT_DEF, CLASS_DEF, ENUM_DEF, INTERFACE_DEF, TYPEDEF_DEF]]
			}]
		}];
	}
}

enum abstract TypeDocCommentToken(String) {
	var ABSTRACT_DEF = "ABSTRACT_DEF";
	var CLASS_DEF = "CLASS_DEF";
	var ENUM_DEF = "ENUM_DEF";
	var INTERFACE_DEF = "INTERFACE_DEF";
	var TYPEDEF_DEF = "TYPEDEF_DEF";
}