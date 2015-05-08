# Checkstyle for Haxe

[![Haxelib Version](https://img.shields.io/github/tag/adireddy/haxe-checkstyle.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/checkstyle) [![Built with Grunt](https://cdn.gruntjs.com/builtwith.png)](http://gruntjs.com/) ![Build Status](https://travis-ci.org/adireddy/haxe-checkstyle.svg?branch=master)

![logo](https://raw.githubusercontent.com/adireddy/haxe-checkstyle/master/logo.png)

Automated code analysis tool ideal for projects that want to enforce coding conventions.

Code conventions improve readability, allowing team members to understand each others code better.

Please note that this project was derived from [haxelint](https://github.com/mcheshkov/haxelint) created by [@mcheshkov](https://github.com/mcheshkov).

###Installation

```haxe
haxelib install checkstyle
```

###Configuration

More information in [wiki page](https://github.com/adireddy/haxe-checkstyle/wiki/Haxe-Checkstyle).

```json
{
	"checks": [
		{
			"type": "Anonymous",
			"props": {
				"severity": "ERROR"
			}
		},
		{
			"type": "ArrayInstantiation",
			"props": {
				"severity": "ERROR"
			}
		},
		{
			"type": "BlockFormat",
			"props": {
				"severity": "ERROR"
			}
		},
		{
			"type": "EmptyLines",
			"props": {
				"severity": "INFO",
				"maxConsecutiveEmptyLines": 1
			}
		},
		{
			"type": "ERegInstantiation",
			"props": {
				"severity": "ERROR"
			}
		},
		{
			"type": "HexadecimalLiterals",
			"props": {
				"severity": "INFO"
			}
		},
		{
			"type": "IndentationCharacter",
			"props": {
				"severity": "INFO",
				"character": "tab"
			}
		},
		{
			"type": "LineLength",
			"props": {
				"severity": "ERROR",
				"maxCharacters": 80
			}
		},
		{
			"type": "ListenerName",
			"props": {
				"severity": "ERROR",
				"listeners": ["addEventListener", "addListener", "on", "once"]
			}
		},
		{
			"type": "MethodLength",
			"props": {
				"severity": "ERROR",
				"maxFunctionLines": 50
			}
		},
		{
			"type": "Naming",
			"props": {
				"severity": "ERROR",
				"privateUnderscorePrefix": false
			}
		},
		{
			"type": "Override",
			"props": {
				"severity": "ERROR"
			}
		},
		{
			"type": "PublicPrivate",
			"props": {
				"severity": "INFO"
			}
		},
		{
			"type": "Return",
			"props": {
				"severity": "INFO"
			}
		},
		{
			"type": "Spacing",
			"props": {
				"severity": "INFO",
				"spaceIfCondition": true,
				"spaceAroundBinop": true,
				"spaceAroundBinop": true,
				"ignoreRangeOperator": true
				
			}
		},
		{
			"type": "TabForAligning",
			"props": {
				"severity": "INFO"
			}
		},
		{
			"type": "TODOComment",
			"props": {
				"severity": "INFO"
			}
		},
		{
			"type": "TrailingWhitespace",
			"props": {
				"severity": "INFO"
			}
		},
		{
			"type": "Type",
			"props": {
				"severity": "ERROR"
			}
		},
		{
			"type": "VariableInitialisation",
			"props": {
				"severity": "ERROR"
			}
		}
	]
}
```

###Options

To see all the options available run the following command.

`haxelib run checkstyle`

```
[-p | --path] <loc>              : Set reporter path
[-x | --xslt] <x>                : Set reporter style (XSLT)
[-r | --reporter] <reporterName> : Set reporter
[--list-reporters]               : List all reporters
[-c | --config] <configPath>     : Set config file
[--list-checks]                  : List all checks
[-s | --source] <sourcePath>     : Set sources to process
```

###Hudson and Bamboo Integration

You can generate the report in checkstyle XML format that can be integrated with Hudson and Bamboo easily.

You can also set XSLT style for the XML generated. See the sample below.

`haxelib run checkstyle -s src -c config.json -r xml -p report.xml -x report.xsl`

Sample Hudson Checkstyle Trend Chart:

![hudson](https://raw.githubusercontent.com/adireddy/haxe-checkstyle/master/hudson.png)

###Reference

http://haxe.org/manual/class-field-visibility.html

http://adireddy.github.io/haxe/haxe-access-modifiers-return-types/

###Issues

Found any bug? Please create a new [issue](https://github.com/adireddy/haxe-checkstyle/issues/new).
