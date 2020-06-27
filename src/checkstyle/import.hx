package checkstyle;

import checkstyle.Checker.LinePos;
import checkstyle.SeverityLevel;
import checkstyle.detect.DetectableInstances;
import checkstyle.utils.ErrorUtils;
import haxe.io.Bytes;
import haxe.macro.Expr;
import haxeparser.Data;
import tokentree.TokenTree;
import tokentree.TokenTreeAccessHelper;
import tokentree.TokenTreeDef;
import tokentree.utils.TokenTreeCheckUtils;

using StringTools;
using checkstyle.utils.ArrayUtils;
using checkstyle.utils.ExprUtils;
using checkstyle.utils.FieldUtils;
using checkstyle.utils.StringUtils;
using tokentree.TokenTreeAccessHelper;