package checkstyle.checks.comments;

/**
	Checks code documentation style (/** vs /*)
**/
@name("DocCommentStyle")
@desc("Checks code documentation style (/**...**/ vs /*...*/)")
class DocCommentStyleCheck extends Check {
	/**
		Defines how doc comments should start / end:
		- ignore = accepts any start / end
		- onestar = /*
		- twostar = /**
	**/
	public var startStyle:DocCommentStyle;

	/**
		Defines how each doc comments line should start:
		- ignore = accepts any line prefix
		- none =
		- onestar = *
		- twostar = **
	**/
	public var lineStyle:DocCommentStyle;

	public function new() {
		super(TOKEN);
		startStyle = TWO_STARS;
		lineStyle = NONE;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var docTokens = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdAbstract) | Kwd(KwdClass) | Kwd(KwdEnum) | Kwd(KwdInterface) | Kwd(KwdTypedef) | Kwd(KwdVar) | Kwd(KwdFunction):
					FoundGoDeeper;
				case Kwd(KwdFinal):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (token in docTokens) {
			if (isPosSuppressed(token.pos)) continue;
			var prevToken:TokenTree = token.previousSibling;
			if (prevToken == null) continue;
			switch (prevToken.tok) {
				case Comment(text):
					checkCommentStyle(prevToken, text);
				default:
			}
		}
	}

	function checkCommentStyle(token:TokenTree, text:String) {
		if (text.length <= 0) return;
		switch (startStyle) {
			case IGNORE:
			case NONE, ONE_STAR:
				if ((text.indexOf("*") == 0) || (text.lastIndexOf("*") == text.length - 1)) {
					logPos("Comment should use '/*…*/'", token.pos, ONE_STAR_START);
				}
			case TWO_STARS:
				if ((text.indexOf("*") != 0) || (text.lastIndexOf("*") != text.length - 1)) {
					logPos("Comment should use '/**…**/'", token.pos, TWO_STARS_START);
				}
		}
		if (lineStyle == IGNORE) return;
		var lines:Array<String> = text.split(checker.lineSeparator);
		var oneStar:EReg = ~/^\s*\*/;
		var twoStar:EReg = ~/^\s*\*\*/;
		// skip first line
		for (i in 1...lines.length - 1) {
			var line:String = lines[i];
			switch (lineStyle) {
				case IGNORE:
				case NONE:
					if (oneStar.match(line)) logPos("Comment lines should not start with '*'", token.pos, NO_STARS_LINES);
				case ONE_STAR:
					if (!oneStar.match(line)) logPos("Comment lines should start with '*'", token.pos, ONE_STAR_LINES);
				case TWO_STARS:
					if (!twoStar.match(line)) logPos("Comment lines should start with '**'", token.pos, TWO_STARS_LINES);
			}
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "startStyle",
				values: [ONE_STAR, TWO_STARS]
			}, {
				propertyName: "lineStyle",
				values: [NONE, ONE_STAR, TWO_STARS]
			}]
		}];
	}
}

/**
	styles for comment lines and start / stop:
	- ignore = accepts any line prefix
	- none =
	- onestar = *
	- twostar = **
**/
enum abstract DocCommentStyle(String) {
	var IGNORE = "ignore";
	var NONE = "none";
	var ONE_STAR = "onestar";
	var TWO_STARS = "twostars";
}

enum abstract DocCommentStyleCode(String) to String {
	var ONE_STAR_START = "OneStarStart";
	var TWO_STARS_START = "TwoStarsStart";
	var NO_STARS_LINES = "NoStarsLine";
	var ONE_STAR_LINES = "OneStarLine";
	var TWO_STARS_LINES = "TwoStarsLine";
}