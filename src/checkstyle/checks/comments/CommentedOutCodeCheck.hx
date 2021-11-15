package checkstyle.checks.comments;

import byte.ByteData;
import haxe.Exception;
import haxeparser.HaxeParser;

/**
	Checks sections of commented out code
**/
@name("CommentedOutCode")
@desc("Checks sections of commented out code")
class CommentedOutCodeCheck extends Check {
	static inline final COMMENTED_OUT_CODE:String = "This block of commented-out lines of code should be removed";

	public function new() {
		super(TOKEN);
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var comments = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case CommentLine(_):
					FoundSkipSubtree;
				case Comment(_):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});

		var currentRun:Array<TokenTree> = [];
		var lastIndex:Int = -1;
		for (token in comments) {
			if (isPosSuppressed(token.pos)) continue;

			switch (token.tok) {
				case Comment(text):
					while (text.startsWith("*")) {
						text = text.substr(1);
					}
					while (text.endsWith("*")) {
						text = text.substr(0, text.length - 1);
					}
					checkForCommentedCode(text, token.pos);
				case CommentLine(_):
					if ((lastIndex == -1) || (lastIndex + 1 == token.index)) {
						currentRun.push(token);
						lastIndex = token.index;
						continue;
					}
					checkTokenRunIterations(currentRun);
					currentRun = [token];
					lastIndex = token.index;
				default:
			}
		}
		if (currentRun.length > 0) {
			checkTokenRunIterations(currentRun);
		}
	}

	function checkTokenRunIterations(run:Array<TokenTree>) {
		if (run.length <= 0) return;
		var runCopy:Array<TokenTree> = run.copy();
		var removedTokens:Array<TokenTree> = [];

		while (runCopy.length > 0) {
			if (checkTokenRun(runCopy)) {
				checkTokenRunIterations(removedTokens);
				return;
			}
			var lastToken:TokenTree = runCopy.pop();
			if (runCopy.length > 1) {
				removedTokens.unshift(lastToken);
			}
		}
		checkTokenRunIterations(removedTokens);
	}

	function checkTokenRun(run:Array<TokenTree>):Bool {
		if (run.length <= 0) return false;
		var text:String = run.map(token -> switch (token.tok) {
			case CommentLine(text):
				text;
			default:
				"";
		}).join("\n");
		var first:TokenTree = run[0];
		var last:TokenTree = run[run.length - 1];
		var pos:Position = {
			file: first.pos.file,
			min: first.pos.min,
			max: last.pos.max
		};
		return checkForCommentedCode(text, pos);
	}

	function checkForCommentedCode(text:String, pos:Position):Bool {
		if (text.trim().length <= 0) return false;
		try {
			var parser = new HaxeParser(ByteData.ofString(text), checker.file.name);
			parser.parse();
			logPos(COMMENTED_OUT_CODE, pos, "CommentedOutCode");
			return true;
		}
		catch (e:Exception) {}
		try {
			var parser = new HaxeParser(ByteData.ofString("function code () {" + text + "}"), checker.file.name);
			parser.parse();
			logPos(COMMENTED_OUT_CODE, pos, "CommentedOutCode");
			return true;
		}
		catch (e:Exception) {}
		try {
			var parser = new HaxeParser(ByteData.ofString("class Code {" + text + "}"), checker.file.name);
			parser.parse();
			logPos(COMMENTED_OUT_CODE, pos, "CommentedOutCode");
			return true;
		}
		catch (e:Exception) {}
		return false;
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: [SeverityLevel.INFO]
			}]
		}];
	}
}