package checkstyle.config;

class ExcludeManager {
	public static var INSTANCE:ExcludeManager = new ExcludeManager();

	var globalExclude:Array<ExcludeDefinition>;
	var excludeMap:Map<String, Array<ExcludeDefinition>>;

	function new() {
		clear();
	}

	public function clear() {
		globalExclude = [];
		excludeMap = new Map<String, Array<ExcludeDefinition>>();
	}

	public static function addGlobalExclude(filter:String, range:String) {
		INSTANCE.globalExclude.push(createExcludeDefinition(filter, range));
	}

	public static function addConfigExclude(checkName:String, filter:String, range:String) {
		var list:Array<ExcludeDefinition> = INSTANCE.excludeMap.get(checkName);
		if (list == null) list = [];
		list.push(createExcludeDefinition(filter, range));
		INSTANCE.excludeMap.set(checkName, list);
	}

	static function createExcludeDefinition(filter:String, range:String):ExcludeDefinition {
		if ((range == null) || (range == "")) return ExcludeDefinition.FULL(filter);
		if (~/^[1-9][0-9]*$/.match(range)) return ExcludeDefinition.LINE(filter, Std.parseInt(range));
		if (~/^[1-9][0-9]*-[1-9][0-9]*$/.match(range)) {
			var parts = range.split("-");
			return ExcludeDefinition.RANGE(filter, Std.parseInt(parts[0]), Std.parseInt(parts[1]));
		}
		return ExcludeDefinition.IDENTIFIER(filter, range);
	}

	public static function isExcludedFromAll(fileName:String):Bool {
		return INSTANCE.checkFileExcluded(fileName, INSTANCE.globalExclude);
	}

	public static function isExcludedFromCheck(fileName:String, checkName:String):Bool {
		return INSTANCE.checkFileExcluded(fileName, INSTANCE.excludeMap.get(checkName));
	}

	function checkFileExcluded(fileName:String, list:Array<ExcludeDefinition>):Bool {
		if (list == null) return false;
		for (exclude in list) {
			if (matchFullExlude(fileName, exclude)) {
				return true;
			}
		}
		return false;
	}

	function matchFullExlude(fileName:String, exclude:ExcludeDefinition):Bool {
		switch (exclude) {
			case FULL(filter):
				return filterFileName(fileName, filter);
			case LINE(filter, line):
				return false;
			case RANGE(filter, lineStart, lineEnd):
				return false;
			case IDENTIFIER(filter, name):
				return false;
		}
	}

	function filterFileName(fileName:String, filter:String):Bool {
		var cls = fileName.substring(0, fileName.indexOf(".hx"));
		if (filter == cls) return true;

		var slashes:EReg = ~/[\/\\]/g;
		cls = slashes.replace(cls, ":");
		var r = new EReg(filter, "i");
		return r.match(cls);
	}

	public function getPosExcludes(checker:Checker):Map<String, Array<ExcludeRange>> {
		var posExcludes:Array<ExcludeRange> = getGlobalPosExcludes(checker);

		for (checkName in excludeMap.keys()) {
			var list:Array<ExcludeDefinition> = excludeMap.get(checkName);
			if (list != null) {
				for (exclude in list) {
					switch (exclude) {
						case FULL(filter):
							continue;
						case LINE(filter, line):
							if (!filterFileName(checker.file.name, filter)) continue;
							posExcludes.push(makeLinesExcludeRange(checker, checkName, line - 1, line));
						case RANGE(filter, lineStart, lineEnd):
							if (!filterFileName(checker.file.name, filter)) continue;
							posExcludes.push(makeLinesExcludeRange(checker, checkName, lineStart - 1, lineEnd - 1));
						case IDENTIFIER(filter, name):
							if (!filterFileName(checker.file.name, filter)) continue;
							posExcludes = posExcludes.concat(makeIdentifierRange(checker, checkName, name));
					}
				}
			}
		}
		return makeExcludeRangMap(posExcludes.concat(getInlineExcludes(checker)));
	}

	function getGlobalPosExcludes(checker:Checker):Array<ExcludeRange> {
		var posExcludes:Array<ExcludeRange> = [];

		for (exclude in globalExclude) {
			switch (exclude) {
				case FULL(filter):
					continue;
				case LINE(filter, line):
					if (!filterFileName(checker.file.name, filter)) continue;
					for (check in checker.checks) {
						posExcludes.push(makeLinesExcludeRange(checker, check.getModuleName(), line - 1, line));
					}
				case RANGE(filter, lineStart, lineEnd):
					if (!filterFileName(checker.file.name, filter)) continue;
					for (check in checker.checks) {
						posExcludes.push(makeLinesExcludeRange(checker, check.getModuleName(), lineStart - 1, lineEnd - 1));
					}
				case IDENTIFIER(filter, name):
					if (!filterFileName(checker.file.name, filter)) continue;
					for (check in checker.checks) {
						posExcludes = posExcludes.concat(makeIdentifierRange(checker, check.getModuleName(), name));
					}
			}
		}
		return posExcludes;
	}

	function getInlineExcludes(checker:Checker):Array<ExcludeRange> {
		var inlineExcludes:Array<ExcludeRange> = [];
		var root:TokenTree = checker.getTokenTree();
		var allAtTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case At:
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
		for (atToken in allAtTokens) {
			var child:TokenTree = atToken.getFirstChild();
			if (child == null) continue;
			if (!child.matches(Const(CIdent("SuppressWarnings")))) continue;
			var pOpen:TokenTree = child.getFirstChild();
			if (pOpen == null) continue;
			if (!pOpen.matches(POpen)) continue;

			var checkNames:Array<String> = [];
			pOpen.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
				switch (token.tok) {
					case Const(CString(name)):
						if (!StringTools.startsWith(name, "checkstyle:")) return SkipSubtree;
						checkNames.push(name.substr(11));
						return SkipSubtree;
					default:
						return GoDeeper;
				}
			});
			for (name in checkNames) {
				inlineExcludes.push(makeTokenExcludeRange(checker, name, atToken.parent));
			}
		}
		return inlineExcludes;
	}

	function makeExcludeRangMap(list:Array<ExcludeRange>):Map<String, Array<ExcludeRange>> {
		var map:Map<String, Array<ExcludeRange>> = new Map<String, Array<ExcludeRange>>();
		for (range in list) {
			var rangeList:Array<ExcludeRange> = map.get(range.checkName);
			if (rangeList == null) {
				rangeList = [];
			}
			rangeList.push(range);
			map.set(range.checkName, rangeList);
		}
		return map;
	}

	@:access(tokentree.TokenTree)
	function makeIdentifierRange(checker:Checker, checkName:String, name:String):Array<ExcludeRange> {
		var identifierExcludes:Array<ExcludeRange> = [];
		var root:TokenTree = checker.getTokenTree();
		var filterTokens:Array<TokenTreeDef> = [Const(CIdent(name))];
		if (name == "new") {
			filterTokens.push(Kwd(KwdNew));
		}
		var allTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (token.matchesAny(filterTokens)) {
				return FoundGoDeeper;
			}
			return GoDeeper;
		});
		for (token in allTokens) {
			identifierExcludes.push(makeTokenExcludeRange(checker, checkName, token));
		}
		return identifierExcludes;
	}

	function makeLinesExcludeRange(checker:Checker, checkName:String, lineStart:Int, lineEnd:Int):ExcludeRange {
		if (lineStart < 0) lineStart = 0;
		if (lineEnd < 0) lineEnd = lineStart;
		if (lineStart > checker.lines.length) lineStart = checker.lines.length - 1;
		if (lineEnd > checker.lines.length) lineEnd = checker.lines.length - 1;

		return {
			checkName: checkName,
			linePosStart: {line: lineStart, ofs: 0},
			linePosEnd: {line: lineEnd, ofs: 0},
			charPosStart: checker.linesIdx[lineStart].l,
			charPosEnd: checker.linesIdx[lineEnd].r
		};
	}

	function makeTokenExcludeRange(checker:Checker, checkName:String, token:TokenTree):ExcludeRange {
		var pos:Position = token.getPos();
		return {
			checkName: checkName,
			linePosStart: checker.getLinePos(pos.min),
			linePosEnd: checker.getLinePos(pos.max),
			charPosStart: pos.min,
			charPosEnd: pos.max
		};
	}
}