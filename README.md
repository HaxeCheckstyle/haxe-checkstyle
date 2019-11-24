![logo](resources/logo.png)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)
[![Release](https://img.shields.io/github/release/HaxeCheckstyle/haxe-checkstyle.svg)](http://lib.haxe.org/p/checkstyle/)
[![Build Status](https://travis-ci.org/HaxeCheckstyle/haxe-checkstyle.svg)](https://travis-ci.org/HaxeCheckstyle/haxe-checkstyle)
[![Haxe-Checkstyle Linux](https://github.com/HaxeCheckstyle/haxe-checkstyle/workflows/Haxe-Checkstyle%20Linux/badge.svg)](https://github.com/HaxeCheckstyle/haxe-checkstyle/actions)
[![Codecov](https://img.shields.io/codecov/c/github/HaxeCheckstyle/haxe-checkstyle.svg)](https://codecov.io/github/HaxeCheckstyle/haxe-checkstyle?branch=dev)
<!-- [![Code Climate](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle/badges/gpa.svg)](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle)
[![Code Climate Issues](https://img.shields.io/codeclimate/issues/HaxeCheckstyle/haxe-checkstyle.svg)](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle/issues)
[![Code Climate Issues](https://img.shields.io/codeclimate/tech-debt/HaxeCheckstyle/haxe-checkstyle.svg)](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle/issues) -->
[![Gitter chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/HaxeCheckstyle/haxe-checkstyle)

**Haxe Checkstyle** is a static analysis tool to help developers write Haxe code that adheres to a coding standard.

It automates the process of checking Haxe code to spare developers of this boring (but important) task.

Code conventions improve readability, allowing team members to understand each other's code better.

Ideal for any project that wants to enforce coding conventions.

Static analysis is usually performed as part of a code review.

### Code Climate

Haxe Checkstyle is available on the [Code Climate](https://docs.codeclimate.com/docs/haxe-checkstyle) platform (free for open source projects). It requires a **`.codeclimate.yml`** file and an optional but recommended **`checkstyle.json`** file to be added to the root of your repository - see [here](https://docs.codeclimate.com/docs/haxe-checkstyle) for more details.

When everything is set up, Code Climate automatically runs Haxe Checkstyle for you on each new commit (also on pull requests if configured that way).

The current number of issues can be tracked via a badge:

<!-- [![Code Climate](https://img.shields.io/codeclimate/issues/HaxeCheckstyle/haxe-checkstyle.svg)](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle/issues) -->

Immediate results, right in your pull requests.

![codeclimate-pr](resources/codeclimate_pr.png)

### Installation

```bash
haxelib install checkstyle
```

### Basic Usage

```bash
haxelib run checkstyle -s src
```

### Automatic detection of your coding style (experimental)

```bash
haxelib run checkstyle -s src --detect detectedCheckstyle.json
```

### VSCode integration

There is a VSCode extension for haxe-checkstyle available in the VSCode marketplace. It is currently built with haxe-checkstyle v2.4.1 and tokentree v1.0.1. You can view the development version here: [vscode-checkstyle](https://github.com/vshaxe/vscode-checkstyle)

### Compiling checkstyle

```bash
git clone https://github.com/HaxeCheckstyle/haxe-checkstyle.git
npm install
lix download
haxe buildAll.hxml # for Neko and NodeJS version + run Unittests and create schema
haxe buildCpp.hxml # for C++ version
```

Compiling with Haxe 3

```bash
git clone https://github.com/HaxeCheckstyle/haxe-checkstyle.git
mv haxe_libraries haxe4_libraries
mv haxe3_libraries haxe_libraries
npm install
lix use haxe 3.4.7
lix download
haxe buildAll.hxml # for Neko and NodeJS version + run Unittests and create schema
haxe buildCpp.hxml # for C++ version
```

### Reference

[More information and reference](http://haxecheckstyle.github.io/docs).

### Issues [![Stories in Ready](https://badge.waffle.io/HaxeCheckstyle/haxe-checkstyle.svg?label=ready&title=Ready)](http://waffle.io/HaxeCheckstyle/haxe-checkstyle)

Found any bug? Please create a new [issue](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/new).

### Coverage

![codecov.io](https://codecov.io/github/HaxeCheckstyle/haxe-checkstyle/branch.svg?branch=dev)

### Licensing Information

This content is released under the [MIT](http://opensource.org/licenses/MIT) license.

This project was derived from [haxelint](https://github.com/mcheshkov/haxelint)
created by [@mcheshkov](https://github.com/mcheshkov).

### Contributor Code of Conduct

[Code of Conduct](https://github.com/CoralineAda/contributor_covenant) is adapted from
[Contributor Covenant, version 1.4](http://contributor-covenant.org/version/1/4)
