enum TokenType {
  // Single-character tokens
  leftParen,
  rightParen,
  leftBrace,
  rightBrace,
  leftBracket,
  rightBracket,
  comma,
  dot,
  colon, // used for property binding ("Cube:location")
  minus,
  plus,
  semicolon,
  slash,
  star,
  percent, // %
  atSign, // @

  // Logical & Comparison operators
  bang, // !
  bangEqual, // !=
  equal, // =
  equalEqual, // ==
  less, // <
  lessEqual, // <=
  greater, // >
  greaterEqual, // >=
  andAnd, // &&
  orOr, // ||

  // Character operators
  arrow, // ->
  atPlus, // @+
  atMinus, // @-
  dotDot, // ..

  // Literals
  identifier,
  string,
  number,
  angleDegree, // 180deg
  angleRadian, // 1.57rad
  frameRate, // 24fps
  colorHex, // #ffffff or #fff
  frameDuration, // 30f
  timeDuration, // 2.5s
  boolean,
  nil,

  // Fundamental Keywords
  keywordObject,
  keywordBehavior,
  keywordSequence,
  keywordAt,
  keywordOver,
  keywordDump,
  keywordBind,
  keywordSpawn,
  keywordWith,
  keywordAs,
  keywordIf,
  keywordElse,
  keywordFor,
  keywordWhile,
  keywordIn,
  keywordDef,
  keywordVar,

  // Animation & Motion Keywords
  keywordMove,
  keywordRotate,
  keywordScale,
  keywordEase,
  keywordLoop,
  keywordStagger,
  keywordHold,

  // Primitive Keywords
  keywordCube,
  keywordSphere,
  keywordPlane,
  keywordCylinder,
  keywordCamera,
  keywordLight,
  keywordMaterial,
  keywordParent,
  keywordUnparent,

  // End of file
  eof
}

class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;

  Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString() {
    return 'Token(type=${type.name.toUpperCase()}, lexeme="$lexeme", literal=$literal, line=$line)';
  }
}
