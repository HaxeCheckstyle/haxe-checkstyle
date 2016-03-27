## Limitations of checkstyle checks

checkstyle has three types of checks:

- Line based
- Token based
- AST based

Which check uses what type is not instantly clear to the user.

### Line based checks

* scan files line by line
* usually applies a regex to each line
* tries to detect line separator by finding first occurrence of \r, \n or \r\n
* supports all features of Haxe
* can work with files that won't compile

### Token based checks

* relies on HaxeLexer from haxeparser library
* uses work in progress version of token tree builder
  - might build incomplete / incorrect tree structure resulting in false positives / negatives
  - might result in endless loops or stacktraces
  - can be turned off, by not using token tree based checks (excluding them via config.json)
* has position information for all nodes
* access to parent and child nodes
* should support all features of Haxe
* easy search and filter for specific node types
* can work with files that won't compile (limited)

### AST based checks

* relies on HaxeParser from haxeparser library
* partial support for #if, #else, #elseif (only active conditionals)
* macro support unclear (needs to be confirmed / checked)
* no parent info for a given Expr or ComplexType
* position info available only for a subset of all AST nodes
* files must compile