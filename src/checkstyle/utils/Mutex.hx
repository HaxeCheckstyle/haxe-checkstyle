package checkstyle.utils;

#if (!neko && !cpp && !hl)
class Mutex {
	public function new() {}
	public function acquire() {}
	public function release() {}
}
#end