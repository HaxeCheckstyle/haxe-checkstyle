package ;

class AnonymousCheckTest {

	var _anonymous:{a:Int, b:Int};

	public function new() {
		var b:{a:Int, b:Int};
		_anonymous = {a: 2, b: 5};
	}
}

typedef SettingsBucket = {
	var width:Float;
	var height:Float;
}