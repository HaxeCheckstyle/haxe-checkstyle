package checkstyle.utils;

#if (!neko && !cpp && !hl)
class Thread {
	public static function create( f : Void -> Void ) {
		f();
	}
}
#end