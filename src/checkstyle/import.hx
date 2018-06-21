package checkstyle;

import haxe.io.Bytes;

import haxe.macro.Expr;
import haxeparser.Data;

import checkstyle.Checker.LinePos;
import checkstyle.SeverityLevel;
import checkstyle.detect.DetectableInstances;

import checkstyle.utils.ErrorUtils;

import tokentree.TokenTree;
import tokentree.TokenTreeAccessHelper;

using checkstyle.utils.ArrayUtils;
using checkstyle.utils.FieldUtils;
using checkstyle.utils.ExprUtils;
using checkstyle.utils.StringUtils;
using StringTools;