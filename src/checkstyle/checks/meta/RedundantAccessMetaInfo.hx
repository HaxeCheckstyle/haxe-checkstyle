package checkstyle.checks.meta;

typedef RedundantAccessMetaInfo = {
	var name:String;
	var ident:String;
	var token:TokenTree;
	var pos:Position;
}