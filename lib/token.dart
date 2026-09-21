enum TokenType {
  // Single-character tokens
  leftParen,
  rightParen,
  leftBrace,
  rightBrace,
  comma,
  dot,
  colon, // used for property binding ("Cube:location")
  minus,
  plus,
  semicolon,
  slash,
  star,

  // Character operators
  arrow,
  atPlus, // @+
  atMinus, // @-
  equal,
  equalEqual,
  bangEqual,
  less,
  lessEqual,
  greater,
  greaterEqual,
  dotDot,

  // Literals
  identifier,
  string,
  number,
  angleDegree, // 180deg
  colorHex, // #ffffff
  frameDuration,
  timeDuration,
  boolean,
  nil,

  // Keywords
  keywordObject,
  keywordBehavior,
  keywordSequence,
  keywordAt,
  keywordOver,
  keywordDump,

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
