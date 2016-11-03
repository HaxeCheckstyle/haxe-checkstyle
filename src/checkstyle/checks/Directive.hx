package checkstyle.checks;

import Type.ValueType;
import checkstyle.errors.InvalidDirectiveError;

@:enum
abstract Directive(String) to String {
	var SHOULD = "should";
	var SHOULD_NOT = "shouldNot";
	var ANY = "any";

	@:from
	public static function fromAny(value:Any):Directive {
		return switch (Type.typeof(value)) {
			case ValueType.TClass(String): getValidated(value);
			//support for legacy configs when such settings were boolean
			case ValueType.TBool: (value ? SHOULD : ANY);
			case _: ANY;
		}
	}

	@:from
	static inline function fromString(value:String):Directive {
		return getValidated(value);
	}

	static function getValidated(value:String):Directive {
		switch (value:Directive) {
			case SHOULD, SHOULD_NOT, ANY:
				return value;
		}
		throw new InvalidDirectiveError('Invalid directive: $value');
	}
}