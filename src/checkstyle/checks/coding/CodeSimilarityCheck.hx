package checkstyle.checks.coding;

#if ((haxe_ver >= 4.0) && (neko || macro || eval || cpp || hl || java))
import sys.thread.Mutex;
#elseif neko
import neko.vm.Mutex;
#elseif cpp
import cpp.vm.Mutex;
#elseif java
import java.vm.Mutex;
#else
import checkstyle.utils.Mutex;
#end

/**
	Checks for identical or similar code.
**/
@name("CodeSimilarity")
@desc("Checks for identical or similar code.")
class CodeSimilarityCheck extends Check {
	static var SIMILAR_HASHES:Map<String, HashedCodeBlock> = new Map<String, HashedCodeBlock>();
	static var IDENTICAL_HASHES:Map<String, HashedCodeBlock> = new Map<String, HashedCodeBlock>();
	static var LOCK:Mutex = new Mutex();

	/**
		severity level for identical code blocks
	**/
	public var severityIdentical:SeverityLevel;

	/**
		threshold for identical code blocks
	**/
	public var thresholdIdentical:Int;

	/**
		threshold for similar code blocks
	**/
	public var thresholdSimilar:Int;

	public function new() {
		super(TOKEN);
		severityIdentical = WARNING;
		thresholdIdentical = 8;
		thresholdSimilar = 12;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			var skipSubTree:Bool = false;
			switch (token.tok) {
				case Kwd(KwdFunction):
					skipSubTree = checkFunctionSimilarity(token);
				case Kwd(KwdIf):
					skipSubTree = checkFunctionSimilarity(token);
				case Kwd(KwdFor):
					skipSubTree = checkFunctionSimilarity(token);
				case Kwd(KwdDo):
					skipSubTree = checkFunctionSimilarity(token);
				case Kwd(KwdWhile):
					if ((token.parent != null) && (token.parent.is(Kwd(KwdDo)))) return SKIP_SUBTREE;
					skipSubTree = checkFunctionSimilarity(token);
				case Kwd(KwdTry):
					skipSubTree = checkFunctionSimilarity(token);
				case Kwd(KwdSwitch):
					skipSubTree = checkFunctionSimilarity(token);
				case BrOpen:
					skipSubTree = checkFunctionSimilarity(token);
				default:
			}
			if (skipSubTree) {
				return SKIP_SUBTREE;
			}
			return GO_DEEPER;
		});
	}

	function checkFunctionSimilarity(token:TokenTree):Bool {
		var pos:Position = token.getPos();
		if (isPosSuppressed(pos)) return true;

		var lineStart:LinePos = checker.getLinePos(pos.min);
		var lineEnd:LinePos = checker.getLinePos(pos.max);
		var lines:Int = lineEnd.line - lineStart.line;
		if (lines <= Math.min(thresholdIdentical, thresholdSimilar)) return false;

		var hashes:CodeHashes = makeCodeHashes(token);
		var codeBlock:HashedCodeBlock = {
			token: token,
			lineStart: lineStart,
			lineEnd: lineEnd,
			startColumn: offsetToColumn(lineStart),
			endColumn: offsetToColumn(lineEnd)
		}

		if (lines > thresholdIdentical) {
			var existing:Null<HashedCodeBlock> = checkOrAddHash(hashes.identicalHash, codeBlock, IDENTICAL_HASHES);
			if (existing != null) {
				logRange("Found identical code block - " + formatFirstFound(existing), pos.min, pos.max, SIMILAR_BLOCK, ERROR);
				return true;
			}
		}

		if (lines > thresholdSimilar) {
			var existing:Null<HashedCodeBlock> = checkOrAddHash(hashes.similarHash, codeBlock, SIMILAR_HASHES);
			if (existing == null) return false;
			logRange("Found similar code block - " + formatFirstFound(existing), pos.min, pos.max, SIMILAR_BLOCK);
			return true;
		}
		return false;
	}

	function formatFirstFound(existing:HashedCodeBlock):String {
		return 'first seen in ${existing.token.pos.file}:${existing.lineStart.line + 1}';
	}

	function checkOrAddHash(hash:String, codeBlock:HashedCodeBlock, hashTable:Map<String, HashedCodeBlock>):Null<HashedCodeBlock> {
		LOCK.acquire();
		var existing:Null<HashedCodeBlock> = hashTable.get(hash);
		if (existing == null) hashTable.set(hash, codeBlock);
		LOCK.release();
		return existing;
	}

	function makeCodeHashes(token:TokenTree):CodeHashes {
		var similar:StringBuf = new StringBuf();
		var identical:StringBuf = new StringBuf();
		makeCodeHashesRecursive(token, similar, identical);
		return {
			identicalHash: identical.toString(),
			similarHash: similar.toString()
		};
	}

	function makeCodeHashesRecursive(token:TokenTree, similar:StringBuf, identical:StringBuf) {
		similar.add(similarTokenText(token));
		identical.add(identicalTokenText(token));
		if (token.children != null) {
			for (child in token.children) makeCodeHashesRecursive(child, similar, identical);
		}
	}

	function similarTokenText(token:TokenTree):String {
		switch (token.tok) {
			case Const(CFloat(_)):
				return "const_float";
			case Const(CString(_)):
				return "const_string";
			case Const(CIdent(_)):
				return "identifier";
			case Const(CRegexp(_)):
				return "regex";
			case Const(CInt(_)):
				return "const_int";
			case Dollar(_):
				return "$name";
			case Unop(_):
				return "unop";
			case Binop(_):
				return "binop";
			case Comment(_):
				return "";
			case CommentLine(_):
				return "";
			case IntInterval(_):
				return "...";
			case Kwd(KwdTrue), Kwd(KwdFalse):
				return "const_bool";
			default:
				return '${token.tok}';
		}
	}

	function identicalTokenText(token:TokenTree):String {
		switch (token.tok) {
			case Const(CFloat(f)):
				return '$f';
			case Const(CString(s)):
				return '"$s"';
			case Const(CIdent(i)):
				return '$i';
			case Const(CRegexp(r, op)):
				return '$r,$op';
			case Const(CInt(i)):
				return '$i';
			case Dollar(n):
				return '$n';
			case Unop(op):
				return '$op';
			case Binop(op):
				return '$op';
			case Comment(_):
				return "";
			case CommentLine(_):
				return "";
			case IntInterval(i):
				return '...$i';
			default:
				return '${token.tok}';
		}
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

@:enum
abstract CodeSimilarityCode(String) to String {
	var SIMILAR_BLOCK = "SimilarBlock";
	var IDENTICAL_BLOCK = "IdenticalBlock";
}

typedef HashedCodeBlock = {
	var token:TokenTree;
	var lineStart:LinePos;
	var lineEnd:LinePos;
	var startColumn:Int;
	var endColumn:Int;
}

typedef CodeHashes = {
	var identicalHash:String;
	var similarHash:String;
}