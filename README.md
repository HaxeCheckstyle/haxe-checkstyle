![logo](resources/logo.png)

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/HaxeCheckstyle/haxe-checkstyle.svg?branch=master)](https://travis-ci.org/HaxeCheckstyle/haxe-checkstyle)
[![codecov.io](https://codecov.io/github/HaxeCheckstyle/haxe-checkstyle/coverage.svg?branch=dev)](https://codecov.io/github/HaxeCheckstyle/haxe-checkstyle?branch=dev)
[![Code Climate](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle/badges/gpa.svg)](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle)
[![Issue Count](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle/badges/issue_count.svg)](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle)
[![Version](https://img.shields.io/badge/haxelib-v2.1.1-EA8220.svg)](http://lib.haxe.org/p/checkstyle/)
[![Gitter chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/HaxeCheckstyle/haxe-checkstyle)

**Haxe Checkstyle** is a static analysis tool to help developers write Haxe code that adheres to a coding standard.

It automates the process of checking Haxe code to spare developers of this boring (but important) task.

Code conventions improve readability, allowing team members to understand each other's code better.

Ideal for any project that wants to enforce coding conventions.

Static analysis is usually performed as part of a code review.

### Code Climate

Haxe Checkstyle is available on the [Code Climate](https://docs.codeclimate.com/docs/haxe-checkstyle) platform (free for open source projects). It requires a `.codeclimate.yml` file and an optional but recommended `checkstyle.json` file to be added to the root of your repository - see [here](https://docs.codeclimate.com/docs/haxe-checkstyle) for more details.

When everything is set up, Code Climate automatically runs Haxe Checkstyle for you on each new commit (also on pull requests if configured that way).

The current number of issues can be tracked via a badge:

[![Issue Count](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle/badges/issue_count.svg)](https://codeclimate.com/github/HaxeCheckstyle/haxe-checkstyle)

For pull requests, the summary is displayed in the "checks" section:

<img src="http://blog.codeclimate.com/images/integrations_red.png" width="600">

### Installation

```
haxelib install checkstyle
```

### Basic Usage

```
haxelib run checkstyle -s src
```

### Reference

[More information and reference](http://haxecheckstyle.github.io/docs).

### Issues [![Stories in Ready](https://badge.waffle.io/HaxeCheckstyle/haxe-checkstyle.svg?label=ready&title=Ready)](http://waffle.io/HaxeCheckstyle/haxe-checkstyle)

Found any bug? Please create a new [issue](https://github.com/HaxeCheckstyle/haxe-checkstyle/issues/new).

### Coverage

![codecov.io](https://codecov.io/github/HaxeCheckstyle/haxe-checkstyle/branch.svg?branch=dev)

### Licensing Information

[![MIT](https://upload.wikimedia.org/wikipedia/commons/8/83/License_icon-mit.png)](http://opensource.org/licenses/MIT)

This content is released under the [MIT](http://opensource.org/licenses/MIT) License.

This project was derived from [haxelint](https://github.com/mcheshkov/haxelint)
created by [@mcheshkov](https://github.com/mcheshkov).

### Contributor Code of Conduct

[Code of Conduct](https://github.com/CoralineAda/contributor_covenant) is adapted from
[Contributor Covenant, version 1.4](http://contributor-covenant.org/version/1/4)
