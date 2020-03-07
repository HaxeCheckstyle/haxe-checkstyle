#!/bin/bash

git clone --depth 1 -b fix_-x https://github.com/AlexHaxe/haxeshim.git

(cd haxeshim; npm i lix; npx lix download; npx haxe all.hxml)

cp haxeshim/bin/*.js node_modules/lix/bin

rm -rf haxeshim
