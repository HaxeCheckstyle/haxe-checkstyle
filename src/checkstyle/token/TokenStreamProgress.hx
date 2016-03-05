package checkstyle.token;

class TokenStreamProgress {
	var stream:TokenStream;
	var pos:Int;

	public function new(stream:TokenStream) {
		this.stream = stream;
		pos = -1;
	}

	public function streamHasChanged():Bool {
		if (pos == -1) {
			pos = stream.getCurrentPos();
			return true;
		}
		var oldPos:Int = pos;
		pos = stream.getCurrentPos();
		return (pos != oldPos);
	}
}