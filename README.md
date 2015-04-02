# Checkstyle for Haxe

Please note that this project was originally created by [@mcheshkov](https://github.com/mcheshkov) called [haxelint](https://github.com/mcheshkov/haxelint). Full credit to @mcheshkov

I have customized and added additional checks based on my needs as listed below.

### Installation ###

```haxe
haxelib install checkstyle
```

**Naming Convention:**

private variables and functions - camelCase starting with underscore	
```haxe
var _playerCount:Int;
function _getPlayerCount():Int {}
```
public variables and functions- camelCase
```haxe
public var playerCount:Int;
public function getPlayerCount():Int {}
```
constants (static and inline)	- UPPERCASE separated with underscore
```haxe
static inline var REEL_COUNT:Int = 3;
```

**Variables & Functions:**
- Barring constants, variables should not be instantiated at class level.
- No anonymous functions. Using anonymous functions, types, etc will cause issues with static analysis. Use Typedef where possible.
- No private keyword for private variables and functions in normal classes.
- No public keyword in interfaces and externs.
- No Void.

http://haxe.org/manual/class-field-visibility.html

http://adireddy.github.io/haxe/haxe-access-modifiers-return-types/

### Issues ###

Found any bug? Please create a new [issue](https://github.com/adireddy/haxe-checkstyle/issues/new).
