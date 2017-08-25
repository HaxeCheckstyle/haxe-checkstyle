package checkstyle;

import haxe.macro.Expr;
import haxeparser.Data;

import checkstyle.Checker.LinePos;
import checkstyle.CheckMessage.SeverityLevel;
import checkstyle.token.TokenTree;

using checkstyle.utils.ArrayUtils;
using checkstyle.utils.FieldUtils;
using checkstyle.utils.ExprUtils;
using StringTools;