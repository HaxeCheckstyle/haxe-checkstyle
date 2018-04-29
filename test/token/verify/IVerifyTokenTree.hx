package token.verify;

import haxe.PosInfos;

import haxeparser.Data;

interface IVerifyTokenTree {

	function filter(tok:TokenDef, ?pos:PosInfos):IVerifyTokenTree;
	function childs(?pos:PosInfos):IVerifyTokenTree;
	function first(?pos:PosInfos):IVerifyTokenTree;
	function last(?pos:PosInfos):IVerifyTokenTree;
	function at(index:Int, ?pos:PosInfos):IVerifyTokenTree;
	function count(count:Int, ?pos:PosInfos):IVerifyTokenTree;
	function noChilds(?pos:PosInfos):IVerifyTokenTree;
	function oneChild(?pos:PosInfos):IVerifyTokenTree;
	function childFirst(?pos:PosInfos):IVerifyTokenTree;
	function childLast(?pos:PosInfos):IVerifyTokenTree;
	function childAt(index:Int, ?pos:PosInfos):IVerifyTokenTree;
	function childCount(num:Int, ?pos:PosInfos):IVerifyTokenTree;
	function childCountAtLeast(count:Int, ?pos:PosInfos):IVerifyTokenTree;
	function is(tok:TokenDef, ?pos:PosInfos):IVerifyTokenTree;
	function isComment(?pos:PosInfos):IVerifyTokenTree;
	function isEmpty(?pos:PosInfos):Bool;
}