package checkstyle.utils;

#if (!neko && !cpp && !hl && !java)
class Mutex {
	public function new() {}

	public function acquire() {}

	public function release() {}
}
#end