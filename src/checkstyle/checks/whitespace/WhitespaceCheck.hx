package checkstyle.checks.whitespace;

import checkstyle.Checker.LinePos;
import checkstyle.token.TokenTree;
import checkstyle.utils.TokenTreeCheckUtils;
import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.ArrayUtils;

@name("Whitespace")
@desc("Checks that is present or absent around a token.")
class WhitespaceCheck extends Check {

	public var mode:WhitespaceMode;
	public var tokens:Array<WhitespaceToken>;
	public var contexts:Array<WhitespaceContext>;

	public function new() {
		super(TOKEN);
		tokens = [
			ARROW,
		];
		mode = AROUND;
		contexts = [OBJECT_DECL, FUNCTION, FIELD, SWITCH, TRY_CATCH, ARRAY_ACCESS, BLOCK, CLASS, INTERFACE, TYPEDEF, ABSTRACT, ENUM];

		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var tokenList:Array<TokenDef> = [];

		for (token in tokens) {
			switch (token) {
				case ARROW:
					tokenList.push(Arrow);
				case COMMA:
					tokenList.push(Comma);
				case SEMICOLON:
					tokenList.push(Semicolon);
				case POPEN:
					tokenList.push(POpen);
				case PCLOSE:
					tokenList.push(PClose);
				case BROPEN:
					tokenList.push(BrOpen);
				case BRCLOSE:
					tokenList.push(BrClose);
				case BKOPEN:
					tokenList.push(BkOpen);
				case BKCLOSE:
					tokenList.push(BkClose);
				case DBLDOT:
					tokenList.push(DblDot);
				case DOT:
					tokenList.push(Dot);
			}
		}

		if (tokenList.length <= 0) return;
		checkTokens(tokenList);
	}

	function checkTokens(tokenList:Array<TokenDef>) {
		var root:TokenTree = checker.getTokenTree();
		var allTokens:Array<TokenTree> = root.filter(tokenList, ALL);

		for (tok in allTokens) {
			if (isPosSuppressed(tok.pos)) continue;
			if (!checkContext(tok)) continue;

			checkWhitespace(tok);
		}
	}

	function checkWhitespace(tok:TokenTree) {
		var linePos:LinePos = checker.getLinePos(tok.pos.min);
		var line:String = checker.lines[linePos.line];
		var before:String = line.substr(0, linePos.ofs);
		var tokLen:Int = TokenDefPrinter.print(tok.tok).length;
		var after:String = line.substr(linePos.ofs + tokLen);

		var whitespaceBefore:Bool = ~/^(.*\s|)$/.match(before);
		var whitespaceAfter:Bool = ~/^(\s.*|)$/.match(after);

		switch (mode) {
			case BEFORE:
				if (whitespaceBefore && !whitespaceAfter) return;
			case AFTER:
				if (!whitespaceBefore && whitespaceAfter) return;
			case NONE:
				if (!whitespaceBefore && !whitespaceAfter) return;
			case AROUND:
				if (whitespaceBefore && whitespaceAfter) return;
		}

		logPos('Whitespace mode "$mode" violated by "${TokenDefPrinter.print(tok.tok)}"', tok.pos);
	}

	function checkContext(token:TokenTree):Bool {
		// TODO also handle package and using
		if (TokenTreeCheckUtils.isImportMult(token)) return false;
		if (TokenTreeCheckUtils.filterOpSub(token)) return false;

		var currentContext:WhitespaceContext = determineContext(token);
		if (currentContext == null || !hasContext(currentContext)) return false;

		//if (TokenTreeCheckUtils.isTypeParameter(token)) {
		//    return hasContext(TYPE_PARAMETER);
		//}
		//if (!hasContext(FUNCTION)) {
		//    if (isFunctionContext(token)) return true;
		//}
		switch (token.tok) {
			case Dot:
			case DblDot:
			default:
		}
		// TODO check contexts

		return true;
	}

	function isFunctionContext(tok:TokenTree):Bool {
		switch (tok.tok) {
			case POpen, PClose, DblDot, Dot, Comma, BrOpen, BrClose:
			case Binop(OpGt), Binop(OpLt), Binop(OpAssign):
			default: return false;
		}
		var parent:TokenTree = tok.parent;
		while (parent.tok != null) {
			switch (parent.tok) {
				case Kwd(KwdFunction): return true;
				case Kwd(_): return false;
				default:
			}
			parent = parent.parent;
		}
		return false;
	}

	function determineContext(token:TokenTree):WhitespaceContext {
		while (token.tok != null) {
			switch (token.tok) {
				case At: return META;
				case Dollar(_): return REIFICATION;
				case Kwd(KwdClass): return CLASS;
				case Kwd(KwdInterface): return INTERFACE;
				case Kwd(KwdEnum): return ENUM;
				case Kwd(KwdAbstract): return ABSTRACT;
				case Kwd(KwdTypedef): return TYPEDEF;
				case Kwd(KwdCase), Kwd(KwdDefault), Kwd(KwdSwitch): return SWITCH;
				case Kwd(KwdCatch): return TRY_CATCH;

				case Kwd(KwdIf), Kwd(KwdElse): return SINGLELINE;
				case Kwd(KwdDo): return SINGLELINE;
				case Kwd(KwdFor): return SINGLELINE;
				case Kwd(KwdWhile): return SINGLELINE;
				case Kwd(KwdFunction): return SINGLELINE;
				case BkOpen: return ARRAY_ACCESS;
				case BrOpen: return contextOfBrOpen(token.parent);
				case POpen: return contextOfPOpen(token.parent);
				case Binop(OpLt):
					if (TokenTreeCheckUtils.isTypeParameter(token)) return TYPE_PARAMETER;
				default:
			}
			token = token.parent;
		}

		return null;
	}

	function contextOfBrOpen(token:TokenTree):WhitespaceContext {
		while (token.tok != null) {
			switch (token.tok) {
				case Kwd(_): return BLOCK;
				case POpen: return OBJECT_DECL;
				case Comma: return OBJECT_DECL;
				case BrOpen: return contextOfBrOpen(token.parent);
				case Binop(OpAssign), Binop(OpAssignOp(_)): return OBJECT_DECL;
				default:
			}
			token = token.parent;
		}
		return null;
	}

	function contextOfPOpen(token:TokenTree):WhitespaceContext {
		while (token.tok != null) {
			switch (token.tok) {
				case Kwd(KwdFunction): return FUNCTION;
				case POpen: return contextOfPOpen(token);
				case Binop(OpAssign), Binop(OpAssignOp(_)): return COND;
				case Kwd(KwdVar): return PROPERTY;
				case Kwd(KwdIf), Kwd(KwdFor), Kwd(KwdWhile), Kwd(KwdSwitch), Kwd(KwdCase): return COND;
				default:
			}
			token = token.parent;
		}
		return null;
	}

	function hasContext(context:WhitespaceContext):Bool {
		return contexts.contains(context);
	}
}

@:enum
abstract WhitespaceMode(String) {
	var BEFORE = "before";
	var AFTER = "after";
	var AROUND = "around";
	var NONE = "none";
}

@:enum
abstract WhitespaceContext(String) {
	var OBJECT_DECL = "Object";
	var CLASS = "Class";
	var INTERFACE = "Interface";
	var TYPEDEF = "Typedef";
	var ABSTRACT = "Abstract";
	var ENUM = "Enum";
	var FUNCTION = "Function";
	var FIELD = "Field";
	var PROPERTY = "Property";
	var BLOCK = "Block";
	var IF = "If";
	var COND = "Condition";
	var SWITCH = "Switch";
	var TRY_CATCH = "Switch";
	var ARRAY_ACCESS = "Array";
	var REIFICATION = "Reification";
	var TYPE_PARAMETER = "TypeParameter";
	var META = "Meta";
	var SINGLELINE = "Singleline";
}

@:enum
abstract WhitespaceToken(String) {
	var ARROW = "=>";
	var COMMA = ",";
	var SEMICOLON = ";";
	var POPEN = "(";
	var PCLOSE = ")";
	var BROPEN = "{";
	var BRCLOSE = "}";
	var BKOPEN = "[";
	var BKCLOSE = "]";
	var DBLDOT = ":";
	var DOT = ".";
}

@:enum
abstract WhitespacePolicy(String) {
	var BEFORE = "before";
	var AFTER = "after";
	var AROUND = "around";
	var NONE = "none";
	var IGNORE = "ignore";
}

@:enum
abstract WhitespaceUnaryPolicy(String) {
	var INNER = "inner";
	var NONE = "none";
	var IGNORE = "ignore";
}