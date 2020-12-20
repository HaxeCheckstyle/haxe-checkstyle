package checkstyle.checks.comments;

class DocCommentStyleCheckTest extends CheckTestCase<DocCommentStyleCheckTests> {
	static inline var MSG_SHOULD_USE_ONE_STAR:String = "Comment should use '/*…*/'";
	static inline var MSG_SHOULD_USE_TWO_STARS:String = "Comment should use '/**…**/'";
	static inline var MSG_SHOULD_NOT_START_WITH_STAR:String = "Comment lines should not start with '*'";

	@Test
	public function testDefault() {
		var check = new DocCommentStyleCheck();

		assertNoMsg(check, TWO_STAR_NO_STAR_TWO_STAR);
		assertNoMsg(check, MANY_STARS_NO_STAR_MANY_STARS);
		assertMsg(check, ONE_STAR_NO_STAR_ONE_STAR, MSG_SHOULD_USE_TWO_STARS);
		assertMessages(check, ONE_STAR_ONE_STAR_ONE_STAR, [MSG_SHOULD_USE_TWO_STARS, MSG_SHOULD_NOT_START_WITH_STAR]);
		assertMsg(check, TWO_STAR_ONE_STAR_TWO_STAR, MSG_SHOULD_NOT_START_WITH_STAR);
		assertMsg(check, TWO_STAR_TWO_STARS_TWO_STAR, MSG_SHOULD_NOT_START_WITH_STAR);
	}

	@Test
	public function testOneStarStart() {
		var check = new DocCommentStyleCheck();
		check.startStyle = ONE_STAR;
		check.lineStyle = IGNORE;

		assertNoMsg(check, ONE_STAR_NO_STAR_ONE_STAR);
		assertNoMsg(check, ONE_STAR_ONE_STAR_ONE_STAR);
		assertMsg(check, TWO_STAR_NO_STAR_TWO_STAR, MSG_SHOULD_USE_ONE_STAR);
		assertMsg(check, MANY_STARS_NO_STAR_MANY_STARS, MSG_SHOULD_USE_ONE_STAR);
		assertMsg(check, TWO_STAR_ONE_STAR_TWO_STAR, MSG_SHOULD_USE_ONE_STAR);
		assertMsg(check, TWO_STAR_TWO_STARS_TWO_STAR, MSG_SHOULD_USE_ONE_STAR);
	}

	@Test
	public function testTwoStarStart() {
		var check = new DocCommentStyleCheck();
		check.startStyle = TWO_STARS;
		check.lineStyle = IGNORE;

		assertMsg(check, ONE_STAR_NO_STAR_ONE_STAR, MSG_SHOULD_USE_TWO_STARS);
		assertMsg(check, ONE_STAR_ONE_STAR_ONE_STAR, MSG_SHOULD_USE_TWO_STARS);
		assertNoMsg(check, TWO_STAR_NO_STAR_TWO_STAR);
		assertNoMsg(check, MANY_STARS_NO_STAR_MANY_STARS);
		assertNoMsg(check, TWO_STAR_ONE_STAR_TWO_STAR);
		assertNoMsg(check, TWO_STAR_TWO_STARS_TWO_STAR);
	}
}

enum abstract DocCommentStyleCheckTests(String) to String {
	var TWO_STAR_NO_STAR_TWO_STAR = "
	/**
		comment
	 **/
	class Test {}
	";
	var ONE_STAR_NO_STAR_ONE_STAR = "
	/*
		comment
	 */
	class Test {}
	";
	var ONE_STAR_ONE_STAR_ONE_STAR = "
	/*
	 * comment
	 */
	class Test {}
	";
	var TWO_STAR_ONE_STAR_TWO_STAR = "
	/**
	 * comment
	 **/
	class Test {}
	";
	var TWO_STAR_TWO_STARS_TWO_STAR = "
	/**
	 ** comment
	 **/
	class Test {}
	";
	var MANY_STARS_NO_STAR_MANY_STARS = "
	/******************
		comment
	 ******************/
	class Test {}
	";
}