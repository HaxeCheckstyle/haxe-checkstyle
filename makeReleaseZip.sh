#!/bin/bash -e

npm install
npx lix download
npx lix use haxe 4.0.5

npx haxe buildAll.hxml

rm -f haxe-checkstyle.zip
zip -9 -r -q haxe-checkstyle.zip src run.n haxecheckstyle.js resources/sample-config.json resources/logo.png resources/codeclimate_pr.png haxelib.json hxformat.json package.json README.md CHANGELOG.md LICENSE.md
