#!/bin/bash

mkdir -p bin

npx uglify-js-es6 haxecheckstyle.js -o bin/checkstyle.uglify.js

echo '#!/usr/bin/env node' > bin/checkstyle.js
echo "" >> bin/checkstyle.js
cat bin/checkstyle.uglify.js >> bin/checkstyle.js
chmod 755 bin/checkstyle.js

rm bin/checkstyle.uglify.js
