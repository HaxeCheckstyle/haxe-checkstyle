package checkstyle.checks.coding;

import checkstyle.utils.Mutex;

/**
	Checks for identical or similar code.
**/
@name("CodeSimilarity")
@desc("Checks for identical or similar code.")
class CodeSimilarityCheck extends Check {
	static var SIMILAR_HASHES:Map<String, HashedCodeBlock> = new Map<String, HashedCodeBlock>();
	static var IDENTICAL_HASHES:Map<String, HashedCodeBlock> = new Map<String, HashedCodeBlock>();
	static var LOCK:Mutex = new Mutex();
	#if use_similarity_ringbuffer
	static var FILE_RINGBUFFER:Array<String> = [];
	static var FILE_HASHES:Map<String, Array<CodeHashes>> = new Map<String, Array<CodeHashes>>();
	#end

	/**
		severity level for identical code blocks
	**/
	public var severityIdentical:SeverityLevel;

	/**
		maximum number of tokens allowed before detecting identical code blocks
	**/
	public var thresholdIdentical:Int;

	/**
		maximum number of tokens allowed before detecting similar code blocks
	**/
	public var thresholdSimilar:Int;

	public function new() {
		super(TOKEN);
		severityIdentical = WARNING;
		thresholdIdentical = 60;
		thresholdSimilar = 120;
		categories = [STYLE, DUPLICATION];
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
					if ((token.parent != null) && (token.parent.matches(Kwd(KwdDo)))) return SkipSubtree;
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
				return SkipSubtree;
			}
			return GoDeeper;
		});
	}

	function checkFunctionSimilarity(token:TokenTree):Bool {
		var pos:Position = token.getPos();
		if (isPosSuppressed(pos)) return true;

		var lineStart:LinePos = checker.getLinePos(pos.min);
		var lineEnd:LinePos = checker.getLinePos(pos.max);

		var hashes:CodeHashes = makeCodeHashes(token);
		if (hashes.tokenCount <= Math.min(thresholdIdentical, thresholdSimilar)) return false;
		var codeBlock:HashedCodeBlock = {
			fileName: token.pos.file,
			lineStart: lineStart,
			lineEnd: lineEnd,
			startColumn: offsetToColumn(lineStart),
			endColumn: offsetToColumn(lineEnd)
		}
		#if use_similarity_ringbuffer
		recordFileHashes(hashes, codeBlock);
		#end

		if (hashes.tokenCount > thresholdIdentical) {
			var existing:Null<HashedCodeBlock> = checkOrAddHash(hashes.identicalHash, codeBlock, IDENTICAL_HASHES);
			if (existing != null) {
				logRange("Found identical code block - " + formatFirstFound(existing), pos.min, pos.max, SIMILAR_BLOCK, severityIdentical);
				return true;
			}
		}

		if (hashes.tokenCount > thresholdSimilar) {
			var existing:Null<HashedCodeBlock> = checkOrAddHash(hashes.similarHash, codeBlock, SIMILAR_HASHES);
			if (existing == null) return false;
			logRange("Found similar code block - " + formatFirstFound(existing), pos.min, pos.max, SIMILAR_BLOCK);
			return true;
		}
		return false;
	}

	function formatFirstFound(existing:HashedCodeBlock):String {
		return 'first seen in ${existing.fileName}:${existing.lineStart.line + 1}';
	}

	function checkOrAddHash(hash:String, codeBlock:HashedCodeBlock, hashTable:Map<String, HashedCodeBlock>):Null<HashedCodeBlock> {
		LOCK.acquire();
		var existing:Null<HashedCodeBlock> = hashTable.get(hash);
		if (existing == null) {
			hashTable.set(hash, codeBlock);
		}
		LOCK.release();
		return existing;
	}

	#if use_similarity_ringbuffer
	function recordFileHashes(hashes:CodeHashes, codeBlock:HashedCodeBlock) {
		LOCK.acquire();
		if (!FILE_RINGBUFFER.contains(codeBlock.fileName)) FILE_RINGBUFFER.push(codeBlock.fileName);
		var fileHashes:Null<Array<CodeHashes>> = FILE_HASHES.get(codeBlock.fileName);
		if (fileHashes == null) {
			fileHashes = [];
			FILE_HASHES.set(codeBlock.fileName, fileHashes);
		}
		fileHashes.push(hashes);
		LOCK.release();
	}

	static function cleanupRingBuffer(maxFileCount:Int) {
		LOCK.acquire();
		while (FILE_RINGBUFFER.length > maxFileCount) {
			var fileName:String = FILE_RINGBUFFER.shift();
			var fileHashes:Null<Array<CodeHashes>> = FILE_HASHES.get(fileName);
			if (fileHashes == null) {
				continue;
			}
			for (hash in fileHashes) {
				SIMILAR_HASHES.remove(hash.similarHash);
				IDENTICAL_HASHES.remove(hash.identicalHash);
			}
			FILE_HASHES.remove(fileName);
		}
		LOCK.release();
	}

	static function cleanupFile(fileName:String) {
		LOCK.acquire();
		FILE_RINGBUFFER.remove(fileName);
		var fileHashes:Null<Array<CodeHashes>> = FILE_HASHES.get(fileName);
		if (fileHashes != null) {
			for (hash in fileHashes) {
				SIMILAR_HASHES.remove(hash.similarHash);
				IDENTICAL_HASHES.remove(hash.identicalHash);
			}
			FILE_HASHES.remove(fileName);
		}
		LOCK.release();
	}
	#end

	function makeCodeHashes(token:TokenTree):CodeHashes {
		var similar:StringBuf = new StringBuf();
		var identical:StringBuf = new StringBuf();
		var tokenCount:Int = makeCodeHashesRecursive(token, similar, identical);
		return {
			identicalHash: identical.toString(),
			similarHash: similar.toString(),
			tokenCount: tokenCount
		};
	}

	function makeCodeHashesRecursive(token:TokenTree, similar:StringBuf, identical:StringBuf):Int {
		similar.add(similarTokenText(token));
		var count:Int = 0;
		var identicalText:Null<String> = identicalTokenText(token);
		if (identicalText != null) {
			count++;
			identical.add(identicalText);
		}
		if (token.children != null) {
			for (child in token.children) count += makeCodeHashesRecursive(child, similar, identical);
		}
		return count;
	}

	function similarTokenText(token:TokenTree):String {
		switch (token.tok) {
			case Const(CFloat(_)):
				return "const_float";
			case Const(CString(s)):
				if (StringUtils.isStringInterpolation(s, checker.file.content, token.pos)) return "const_string_interpol";
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
			case Binop(OpAssign):
				return "assign";
			case Binop(OpAssignOp(_)):
				return "opassign";
			case Binop(OpAdd), Binop(OpSub), Binop(OpMult), Binop(OpDiv), Binop(OpMod):
				return "oparithmetic";
			case Binop(OpShl), Binop(OpShr), Binop(OpUShr), Binop(OpAnd), Binop(OpOr), Binop(OpXor):
				return "opbitwise";
			case Binop(OpBoolAnd), Binop(OpBoolOr):
				return "oplogical";
			case Binop(OpEq), Binop(OpNotEq), Binop(OpLt), Binop(OpLte), Binop(OpGt), Binop(OpGte):
				return "opcompare";
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

	function identicalTokenText(token:TokenTree):Null<String> {
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
				return null;
			case CommentLine(_):
				return null;
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

enum abstract CodeSimilarityCode(String) to String {
	var SIMILAR_BLOCK = "SimilarBlock";
	var IDENTICAL_BLOCK = "IdenticalBlock";
}

typedef HashedCodeBlock = {
	var fileName:String;
	var lineStart:LinePos;
	var lineEnd:LinePos;
	var startColumn:Int;
	var endColumn:Int;
}

typedef CodeHashes = {
	var identicalHash:String;
	var similarHash:String;
	var tokenCount:Int;
}