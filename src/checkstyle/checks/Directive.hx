package checkstyle.checks;

import Type.ValueType;
import checkstyle.errors.InvalidDirectiveError;

enum Directive {
	SHOULD;
	SHOULD_NOT;
	ANY;
}

class DirectiveTools {
	static var MAPPING:Map<String, Directive> = [
		"should" => SHOULD,
		"shouldNot" => SHOULD_NOT,
		"any" => ANY
	];

	public static function fromDynamic(value:Dynamic):Directive {
		return switch (Type.typeof(value)) {
			case ValueType.TClass(String): getValidated(value);
			//support for legacy configs when such settings were boolean
			case ValueType.TBool: (value ? SHOULD : ANY);
			case _: ANY;
		}
	}

	static function getValidated(value:String):Directive {
		var directive = MAPPING.get(value);
		if (directive != null) return directive;
		throw new InvalidDirectiveError('Invalid directive: $value');
	}
}