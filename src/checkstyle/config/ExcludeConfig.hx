package checkstyle.config;

/**
	defines filters to exclude folders, types or files from all or specific checks
**/
typedef ExcludeConfig = {
	@:optional var path:ExcludePath;

	/**
		exclude matching files from all checks
	**/
	@:optional var all:ExcludeFilterList;

	/**
		version number
	**/
	@:optional var version:Int;
}

/**
	list of path filters, e.g.
	- full type names
	- names of individual folder or subfolders
	- partial folder or type names

	each line can have an additional range specification:
	- ":<linenumber>" = only matches a specific line number - valid line number start at 1
	- ":<start>-<end>" = matches line numbers from <start> to <end> (including both)
	- ":<identifier>" = matches any line or block that has <identifier> name (Haxe keywords currently unsupported)
**/
typedef ExcludeFilterList = Array<String>;