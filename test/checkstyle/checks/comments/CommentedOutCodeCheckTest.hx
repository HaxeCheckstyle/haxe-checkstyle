package checkstyle.checks.comments;

class CommentedOutCodeCheckTest extends CheckTestCase<CommentedOutCodeCheckTests> {
	static inline var MSG_REMOVE_COMMENTED_CODE:String = "This block of commented-out lines of code should be removed";

	@Test
	public function testComments() {
		var check = new CommentedOutCodeCheck();
		assertMsg(check, BLOCK_COMMENT_VAR, MSG_REMOVE_COMMENTED_CODE);
		assertMsg(check, BLOCK_COMMENT_STAR_VAR, MSG_REMOVE_COMMENTED_CODE);
		assertMsg(check, BLOCK_COMMENT_MULTI_STAR_VAR, MSG_REMOVE_COMMENTED_CODE);
		assertMsg(check, LINE_COMMENT_VAR, MSG_REMOVE_COMMENTED_CODE);
		assertMsg(check, LINE_COMMENT_VAR2, MSG_REMOVE_COMMENTED_CODE);
		assertMsg(check, LINE_COMMENT_SWITCH, MSG_REMOVE_COMMENTED_CODE);
		assertMsg(check, LINE_COMMENT_SWITCH2, MSG_REMOVE_COMMENTED_CODE);
		assertNoMsg(check, LINE_COMMENT_EMPTY);
		assertNoMsg(check, LINE_COMMENT_SUPRESSED);
		// xx assertMessages(check, ONE_STAR_ONE_STAR_ONE_STAR, [MSG_SHOULD_USE_TWO_STARS, MSG_SHOULD_NOT_START_WITH_STAR]);
	}
}

enum abstract CommentedOutCodeCheckTests(String) to String {
	var BLOCK_COMMENT_VAR = "
	/*
		var test:String = '';
	 */
	class Test {}
	";
	var BLOCK_COMMENT_STAR_VAR = "
	/**
		var test:String = '';
	 **/
	class Test {}
	";
	var BLOCK_COMMENT_MULTI_STAR_VAR = "
	/**********************************************
		var test:String = '';
	 **********************************************/
	class Test {}
	";
	var LINE_COMMENT_VAR = "
	// var test:String = '';
	class Test {}
	";
	var LINE_COMMENT_VAR2 = "
	// var test:String = '';
	// var test2:String = '';
	// var test3:String = '';
	class Test {}
	";
	var LINE_COMMENT_SWITCH = "
	// switch(test) {
	// 	case ValueA:
	// 		var a = '';
	// 		call(a);
	// 	case ValueB:
	// 	case ValueC:
	// 	default:
	// }
	class Test {}
	";
	var LINE_COMMENT_SWITCH2 = "
	// text comment
	// switch(test) {
	// 	case ValueA:
	// 		var a = '';
	// 		call(a);
	// 	case ValueB:
	// 	case ValueC:
	// 	default:
	// }
	class Test {}
	";
	var LINE_COMMENT_EMPTY = "
	// text comment
	//
	/* */
	class Test {}
	";
	var LINE_COMMENT_SUPRESSED = "
	@SuppressWarnings('checkstyle:CommentedOutCode')
	class Test {
		// var test:String = '';
	}
	";
}