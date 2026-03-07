package checkstyle.checks.comments;

class DocCommentStyleCheckTest extends CheckTestCase<DocCommentStyleCheckTests> {
	static inline var MSG_SHOULD_START_WITH_ONE_STAR:String = "Comment should start with '/*…'";
	static inline var MSG_SHOULD_START_WITH_TWO_STARS:String = "Comment should start with '/**…'";
	static inline var MSG_SHOULD_END_WITH_ONE_STAR:String = "Comment should end with '…*/'";
	static inline var MSG_SHOULD_END_WITH_TWO_STARS:String = "Comment should end with '…**/'";
	static inline var MSG_SHOULD_LINE_START_WITH_NO_STAR:String = "Comment lines should not start with '*'";
	static inline var MSG_SHOULD_LINE_START_WITH_ONE_STAR:String = "Comment lines should start with '*'";
	static inline var MSG_SHOULD_LINE_START_WITH_TWO_STAR:String = "Comment lines should start with '**'";

	@Test
	public function testDefault() {
		var check = new DocCommentStyleCheck();

		assertNoMsg(check, TWO_STAR_NO_STAR_TWO_STAR);
		assertNoMsg(check, MANY_STARS_NO_STAR_MANY_STARS);
		assertMsg(check, ONE_STAR_NO_STAR_ONE_STAR, MSG_SHOULD_START_WITH_TWO_STARS);
		assertMessages(check, ONE_STAR_ONE_STAR_ONE_STAR, [
			MSG_SHOULD_START_WITH_TWO_STARS,
			MSG_SHOULD_LINE_START_WITH_NO_STAR
		]);
		assertMsg(check, TWO_STAR_ONE_STAR_ONE_STAR, MSG_SHOULD_LINE_START_WITH_NO_STAR);
		assertMsg(check, TWO_STAR_ONE_STAR_TWO_STAR, MSG_SHOULD_LINE_START_WITH_NO_STAR);
		assertMsg(check, TWO_STAR_TWO_STARS_TWO_STAR, MSG_SHOULD_LINE_START_WITH_NO_STAR);

		assertMsg(check, TWO_STAR_ONE_STAR_ONE_STAR_ANNOTATED, MSG_SHOULD_LINE_START_WITH_NO_STAR);
	}

	@Test
	public function testOneStarStart() {
		var check = new DocCommentStyleCheck();
		check.startStyle = ONE_STAR;
		check.lineStyle = IGNORE;
		check.endStyle = IGNORE;

		assertNoMsg(check, ONE_STAR_NO_STAR_ONE_STAR);
		assertNoMsg(check, ONE_STAR_ONE_STAR_ONE_STAR);

		assertMsg(check, TWO_STAR_NO_STAR_TWO_STAR, MSG_SHOULD_START_WITH_ONE_STAR);
		assertMsg(check, MANY_STARS_NO_STAR_MANY_STARS, MSG_SHOULD_START_WITH_ONE_STAR);
		assertMsg(check, TWO_STAR_ONE_STAR_TWO_STAR, MSG_SHOULD_START_WITH_ONE_STAR);
		assertMsg(check, TWO_STAR_ONE_STAR_ONE_STAR, MSG_SHOULD_START_WITH_ONE_STAR);
		assertMsg(check, TWO_STAR_TWO_STARS_TWO_STAR, MSG_SHOULD_START_WITH_ONE_STAR);

		assertMsg(check, TWO_STAR_ONE_STAR_ONE_STAR_ANNOTATED, MSG_SHOULD_START_WITH_ONE_STAR);
	}

	@Test
	public function testTwoStarStart() {
		var check = new DocCommentStyleCheck();
		check.startStyle = TWO_STARS;
		check.lineStyle = IGNORE;
		check.endStyle = TWO_STARS;

		assertMessages(check, ONE_STAR_NO_STAR_ONE_STAR, [
			MSG_SHOULD_START_WITH_TWO_STARS,
			MSG_SHOULD_END_WITH_TWO_STARS
		]);
		assertMessages(check, ONE_STAR_ONE_STAR_ONE_STAR, [
			MSG_SHOULD_START_WITH_TWO_STARS,
			MSG_SHOULD_END_WITH_TWO_STARS
		]);
		assertNoMsg(check, TWO_STAR_NO_STAR_TWO_STAR);
		assertNoMsg(check, MANY_STARS_NO_STAR_MANY_STARS);
		assertNoMsg(check, TWO_STAR_ONE_STAR_TWO_STAR);
		assertMsg(check, TWO_STAR_ONE_STAR_ONE_STAR, MSG_SHOULD_END_WITH_TWO_STARS);
		assertNoMsg(check, TWO_STAR_TWO_STARS_TWO_STAR);

		assertMsg(check, TWO_STAR_ONE_STAR_ONE_STAR_ANNOTATED, MSG_SHOULD_END_WITH_TWO_STARS);
	}

	@Test
	public function testTwoStarStartOneStarEnd() {
		// This configuration is common because it matches the JavaDoc style.

		var check = new DocCommentStyleCheck();
		check.startStyle = TWO_STARS;
		check.lineStyle = ONE_STAR;
		check.endStyle = ONE_STAR;

		assertMessages(check, ONE_STAR_NO_STAR_ONE_STAR, [
			MSG_SHOULD_START_WITH_TWO_STARS,
			MSG_SHOULD_LINE_START_WITH_ONE_STAR
		]);
		assertMsg(check, ONE_STAR_ONE_STAR_ONE_STAR, MSG_SHOULD_START_WITH_TWO_STARS);
		assertMessages(check, TWO_STAR_NO_STAR_TWO_STAR, [
			MSG_SHOULD_LINE_START_WITH_ONE_STAR,
			MSG_SHOULD_END_WITH_ONE_STAR
		]);
		assertMessages(check, MANY_STARS_NO_STAR_MANY_STARS, [
			MSG_SHOULD_LINE_START_WITH_ONE_STAR,
			MSG_SHOULD_END_WITH_ONE_STAR
		]);
		assertMessages(check, TWO_STAR_ONE_STAR_TWO_STAR, [
			MSG_SHOULD_END_WITH_ONE_STAR
		]);
		assertMessages(check, TWO_STAR_TWO_STARS_TWO_STAR, [
			MSG_SHOULD_LINE_START_WITH_ONE_STAR,
			MSG_SHOULD_END_WITH_ONE_STAR
		]);

		assertNoMsg(check, TWO_STAR_ONE_STAR_ONE_STAR);
		assertNoMsg(check, TWO_STAR_ONE_STAR_ONE_STAR_ANNOTATED);
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
	var TWO_STAR_ONE_STAR_ONE_STAR = "
	/**
	 * comment
	 */
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

	var TWO_STAR_ONE_STAR_ONE_STAR_ANNOTATED = "
  /**
   * Line one
   *
   * @param foo Biz baz buz
   * @return The bar
   */
  function test(foo:String) {
	return foo;
  }
";

}