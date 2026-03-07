package checkstyle.checks.comments;

/**
	Checks code documentation style (/** vs /*)
**/
@name("DocCommentStyle")
@desc("Checks code documentation style (/**...**/ vs /*...*/)")
class DocCommentStyleCheck extends Check {
	/**
		Defines how doc comments should start:
		- ignore = accepts any start
		- onestar = /*
		- twostar = /**
	**/
	public var startStyle:DocCommentStyle;

	/**
		Defines how doc comments should end:
		- ignore = accepts any end
		- onestar = * /
		- twostar = ** /
	**/
	public var endStyle:DocCommentStyle;

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
		endStyle = NONE;
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
		// This is a list of lines that EXCLUDES the initial /* and */.
		// Thus, on a one-star, the first line will be empty,
		// and on a two-star, the first line will be `*`.
		var lines:Array<String> = text.split(checker.lineSeparator);

		var firstLine:String = lines[0];
		var lastLine:String = lines[lines.length - 1];
		var middleLines:Array<String> = lines.slice(1, lines.length - 1);

		checkStartStyle(token, firstLine);
		checkLineStyle(token, middleLines);
		checkEndStyle(token, lastLine);
	}

	function checkStartStyle(token:TokenTree, line:String) {
		switch (startStyle) {
			case NONE, IGNORE:
				return;
			case ONE_STAR:
				var oneStar:EReg = ~/^\s*$/;
				if (!oneStar.match(line)) logPos("Comment should start with '/*…'", token.pos, ONE_STAR_START);
			case TWO_STARS:
				var twoStar:EReg = ~/^\*+$/;
				if (!twoStar.match(line)) logPos("Comment should start with '/**…'", token.pos, TWO_STARS_START);
		}
	}

	function checkLineStyle(token:TokenTree, lines:Array<String>) {
		var oneStar:EReg = ~/^\s*\*[^*]/;
		var twoStar:EReg = ~/^\s*\*+/;
		for (line in lines) {
			switch (lineStyle) {
				case IGNORE:
					return;
				case NONE:
					if (oneStar.match(line) || twoStar.match(line)) logPos("Comment lines should not start with '*'", token.pos, NO_STARS_LINES);
				case ONE_STAR:
					if (!oneStar.match(line)) logPos("Comment lines should start with '*'", token.pos, ONE_STAR_LINES);
				case TWO_STARS:
					if (!twoStar.match(line)) logPos("Comment lines should start with '**'", token.pos, TWO_STARS_LINES);
			}
		}
	}

	function checkEndStyle(token:TokenTree, line:String) {
		switch (endStyle) {
			case NONE, IGNORE:
				return;
			case ONE_STAR:
				var oneStar:EReg = ~/^\s*$/;
				if (!oneStar.match(line)) logPos("Comment should end with '…*/'", token.pos, ONE_STAR_START);
			case TWO_STARS:
				var twoStars:EReg = ~/^\s*\*+$/;
				if (!twoStars.match(line)) logPos("Comment should end with '…**/'", token.pos, TWO_STARS_START);
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "startStyle",
				values: [ONE_STAR, TWO_STARS]
			}, {
				propertyName: "endStyle",
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