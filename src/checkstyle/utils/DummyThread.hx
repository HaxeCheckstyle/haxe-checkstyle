package checkstyle.utils;

class DummyThread {
	public static function create(f:Void -> Void) {
		f();
	}
}