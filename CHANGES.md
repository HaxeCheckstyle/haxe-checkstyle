## next version (2.2.1)

 - Added CHANGES.md
 - Added a reset function for checks ([#279](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/279))
 - Added unittest for [#78](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/78)
 - Updated formula for number of pre-parsed files [#386](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/386)
 - Removed conditional section for unittest [#181](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/181)

## version 2.2.0

 - Added support for Binop(OpIn) [#352](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/352) ([#359](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/359))
 - Added 1 parser and n checker threads ([#374](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/374))
   use `-checkerthreads n` to change number of checker threads (default: 5)
   use `-nothreads` to turn off threads and use old behaviour
   use `numberOfCheckerThreads` in config file to set number of checker threads (see `resources/default-conmfig.json`)
 - Fixed allow same regex logic for "all" excludes, fixes [#361](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/361) ([#362](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/362))
 - Fixed altering position info in RightCurlyCheck ([#367](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/367))
 - Fixed multiple metadatas infront of statement ([#369](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/369))
 - Fixed C++ compilation ([#376](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/376))
 - Fixed coverage ([#378](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/378))
 - Fixed compilation to JS (used in vscode-checkstyle extension) ([#379](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/379))
 - Fixed support for comments in var and parameter definitions, fixes [#363](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/363) ([#364](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/364))
 - Fixed support for expression metadata in token tree, fixes [#365](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/365) ([#366](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/366))
 - Refactored object decl handling in token tree ([#372](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/372))
 - Refactored unit testing from haxe.unit to munit ([#377](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/377))
 - Removed Patreon link ([#375](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/375))
