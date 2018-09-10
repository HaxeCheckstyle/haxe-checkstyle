package checkstyle.errors;

class Error {
	public var message(default, null):String;

	public function new(message:String) {
		this.message = message;
	}

	public function toString():String {
		return message;
	}
}