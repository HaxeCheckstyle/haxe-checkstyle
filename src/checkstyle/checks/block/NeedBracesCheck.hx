package checkstyle.checks.block;

/**
	Checks for braces on function, if, for and while statements. It has an option to allow single line statements without
	braces using property "allowSingleLineStatement" like "if (b) return 10;".
**/
@name("NeedBraces")
@desc("Checks for braces on function, if, for and while statements. It has an option to allow single line statements without braces using property `allowSingleLineStatement` like `if (b) return 10;`.")
class NeedBracesCheck extends Check {
	/**
		matches only statements specified in tokens list:

		- FUNCTION = function body "funnction test () {}"
		- FOR = for body "for (i in 0..10) {}"
		- IF = if body "if (test) {} else {}"
		- ELSE_IF = if body "if (test) {} else if {}"
		- WHILE = while body "while (test) {}"
		- DO_WHILE = do…while body "do {} while (test)"
		- CATCH = catch body "catch (e:Dynamic) {}"
	**/
	public var tokens:Array<NeedBracesCheckToken>;

	/**
		allow / disallow use of single line statements without braces
	**/
	public var allowSingleLineStatement:Bool;

	public function new() {
		super(TOKEN);
		tokens = [FOR, IF, ELSE_IF, WHILE, DO_WHILE];
		allowSingleLineStatement = true;
	}

	function hasToken(token:NeedBracesCheckToken):Bool {
		return (tokens.length == 0 || tokens.contains(token));
	}

	override function actualRun() {
		var wantFunction = hasToken(FUNCTION);
		var wantFor = hasToken(FOR);
		var wantIf = hasToken(IF);
		var wantWhile = hasToken(WHILE);
		var wantDoWhile = hasToken(DO_WHILE);
		var wantCatch = hasToken(CATCH);

		if (!(wantFunction || wantFor || wantIf || wantWhile || wantDoWhile || wantCatch)) return;

		var root:TokenTree = checker.getTokenTree();
		var allTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdFunction) if (wantFunction):
					FoundGoDeeper;
				case Kwd(KwdFor) if (wantFor):
					FoundGoDeeper;
				case Kwd(KwdIf) | Kwd(KwdElse) if (wantIf):
					FoundGoDeeper;
				case Kwd(KwdWhile) if (wantWhile):
					FoundGoDeeper;
				case Kwd(KwdDo) if (wantDoWhile):
					FoundGoDeeper;
				case Kwd(KwdCatch) if (wantCatch):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (tok in allTokens) {
			if (isPosSuppressed(tok.pos)) continue;
			switch (tok.tok) {
				case Kwd(KwdIf):
					checkIfChild(tok);
				case Kwd(KwdElse):
					var firstChild = tok.getFirstChild();
					if (firstChild == null) continue;
					if (firstChild.matches(Kwd(KwdIf))) checkIfChild(firstChild);
					else checkLastChild(tok);
				case Kwd(KwdFunction):
					checkFunctionChild(tok);
				case Kwd(KwdDo):
					checkLastChild(tok);
				case Kwd(KwdWhile):
					checkWhileChild(tok);
				default:
					checkLastChild(tok);
			}
		}
	}

	function checkIfChild(token:TokenTree) {
		if (token == null || !token.hasChildren()) return;

		var lastChild:TokenTree = token.getLastChild();
		if (Type.enumEq(lastChild.tok, Kwd(KwdElse))) {
			lastChild = lastChild.previousSibling;
		}
		switch (lastChild.tok) {
			case POpen, BrOpen:
				return;
			default:
				checkNoBraces(token, lastChild);
		}
	}

	function checkFunctionChild(token:TokenTree) {
		if (token == null || !token.hasChildren()) return;

		var body:TokenTree = token;
		if (token.children.length == 1) {
			body = token.getFirstChild();
		}
		body = TokenTreeAccessHelper.access(body).firstOf(POpen).token;
		if ((body == null) || (body.nextSibling == null)) {
			return;
		}
		body = body.nextSibling;
		if (body.matches(DblDot)) {
			var lastChild:TokenTree = TokenTreeCheckUtils.getLastToken(token);
			if (lastChild.matches(Semicolon)) {
				return;
			}
			body = body.nextSibling;
		}
		if ((body == null) || (body.matches(BrOpen))) {
			return;
		}
		checkNoBraces(token, body);
	}

	function checkWhileChild(token:TokenTree) {
		if (token == null || !token.hasChildren() || Type.enumEq(token.parent.tok, Kwd(KwdDo))) return;
		checkLastChild(token);
	}

	function checkLastChild(token:TokenTree) {
		if (token == null || !token.hasChildren()) return;
		var lastChild:TokenTree = TokenTreeAccessHelper.access(token).firstOf(BrOpen).token;
		if (lastChild != null) return;
		lastChild = TokenTreeAccessHelper.access(token).lastChild().token;
		checkNoBraces(token, lastChild);
	}

	function checkNoBraces(parent:TokenTree, child:TokenTree) {
		if ((parent == null) || (child == null)) return;
		var minLine:LinePos = checker.getLinePos(parent.pos.min);
		var maxLine:LinePos = checker.getLinePos(child.getPos().max);
		var singleLine:Bool = (minLine.line == maxLine.line);

		if (allowSingleLineStatement) {
			if (singleLine) return;
			if (checkIfElseSingleline(parent, child)) return;
		}
		else {
			if (singleLine) {
				logPos('Body of "$parent" on same line', child.getPos());
				return;
			}
		}
		logPos('No braces used for body of "$parent"', child.getPos());
	}

	function checkIfElseSingleline(parent:TokenTree, child:TokenTree):Bool {
		if (!hasToken(ELSE_IF)) return false;
		switch (parent.tok) {
			case Kwd(KwdElse):
			default:
				return false;
		}
		switch (child.tok) {
			case Kwd(KwdIf):
			default:
				return false;
		}
		var minLine:LinePos = checker.getLinePos(parent.pos.min);
		var maxLine:LinePos = checker.getLinePos(child.getFirstChild().getPos().max);
		return (minLine.line == maxLine.line);
	}
}

enum abstract NeedBracesCheckToken(String) {
	var FUNCTION = "FUNCTION";
	var FOR = "FOR";
	var IF = "IF";
	var ELSE_IF = "ELSE_IF";
	var WHILE = "WHILE";
	var DO_WHILE = "DO_WHILE";
	var CATCH = "CATCH";
}