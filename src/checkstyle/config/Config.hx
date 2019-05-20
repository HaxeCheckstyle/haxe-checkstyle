package checkstyle.config;

import checkstyle.SeverityLevel;

typedef Config = {
	/**
		Extend configuration from a master configuration file.
		Checks and excludes from both master and current configuration file form the final runtime configuration.
		There is no shadowing or overwriting checks or excludes, Checkstyle runs every check regardless where it comes from.
		A master configuration file can have its own "extendsConfigPath" entry. Checkstyle will walk up the chain as long as it does not cycle.
	**/
	@:optional var extendsConfigPath:String;

	/**
		Each check has a builtin severity level.
		Setting "defaultSeverity" applies its value to all checks that have no explicity "severity" field in their configuration

		@see checkstyle.SeverityLevel
	**/
	@:optional var defaultSeverity:SeverityLevel;

	/**
		defines that are always added
	**/
	@:optional var baseDefines:Array<String>;

	/**
		different define combinations to use (on top of "baseDefines")
	**/
	@:optional var defineCombinations:Array<Array<String>>;

	/**
		Sets the number of checker threads, valid range is 1-15
	**/
	@:optional var numberOfCheckerThreads:Int;

	@:optional var checks:Array<CheckConfig>;
	@:optional var exclude:ExcludeConfig;

	/**
		version number
	**/
	@:optional var version:Int;
}