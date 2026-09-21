import 'dart:io';
import 'token.dart';

class Scanner {
  final String source;
  final List<Token> tokens = [];

  int _start = 0;
  int _current = 0;
  int _line = 1;
  bool _hadError = false;

  static final Map<String, TokenType> _keywords = {
    'object': TokenType.keywordObject,
    'behavior': TokenType.keywordBehavior,
    'sequence': TokenType.keywordSequence,
    'at': TokenType.keywordAt,
    'over': TokenType.keywordOver,
    'dump': TokenType.keywordDump,
    'true': TokenType.boolean,
    'false': TokenType.boolean,
    'nil': TokenType.nil,
  };

  Scanner(this.source);

  bool get hadError => _hadError;

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }

    tokens.add(Token(TokenType.eof, "", null, _line));

    return tokens;
  }

  bool _isAtEnd() => _current >= source.length;

  void _scanToken() {
    String c = _advance();

    switch (c) {
      case '(':
        _addToken(TokenType.leftParen);
        break;

      case ')':
        _addToken(TokenType.rightParen);
        break;

      case '{':
        _addToken(TokenType.leftBrace);
        break;

      case '}':
        _addToken(TokenType.rightBrace);
        break;

      case ',':
        _addToken(TokenType.comma);
        break;

      case ':':
        _addToken(TokenType.colon);
        break;

      case '+':
        _addToken(TokenType.plus);
        break;

      case ';':
        _addToken(TokenType.semicolon);
        break;

      case '*':
        _addToken(TokenType.star);
        break;

      case '#':
        _hexColor();
        break;

      case '-':
        if (_match('>')) {
          _addToken(TokenType.arrow);
        } else {
          _addToken(TokenType.minus);
        }
        break;

      case '@':
        if (_match('+')) {
          _addToken(TokenType.atPlus);
        } else if (_match('-')) {
          _addToken(TokenType.atMinus);
        } else {
          _error(_line, "Expected '+' or '-' after '@'.");
        }
        break;

      case '.':
        if (_match('.')) {
          _addToken(TokenType.dotDot);
        } else {
          _addToken(TokenType.dot);
        }
        break;

      case '/':
        if (_match('/')) {
          while (_peek() != '\n' && !_isAtEnd()) {
            _advance();
          }
        } else {
          _addToken(TokenType.slash);
        }
        break;

      case '=':
        _addToken(
          _match('=') ? TokenType.equalEqual : TokenType.equal,
        );
        break;

      case '!':
        if (_match('=')) {
          _addToken(TokenType.bangEqual);
        } else {
          _error(_line, "Unexpected character '!'.");
        }
        break;

      case '<':
        _addToken(
          _match('=') ? TokenType.lessEqual : TokenType.less,
        );
        break;

      case '>':
        _addToken(
          _match('=') ? TokenType.greaterEqual : TokenType.greater,
        );
        break;

      case ' ':
      case '\r':
      case '\t':
        break;

      case '\n':
        _line++;
        break;

      case '"':
        _string();
        break;

      default:
        if (_isDigit(c)) {
          _numberOrDuration();
        } else if (_isAlpha(c)) {
          _identifier();
        } else {
          _error(_line, "Unexpected character '$c'.");
        }
        break;
    }
  }

  void _identifier() {
    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    String text = source.substring(_start, _current);
    TokenType? type = _keywords[text];

    if (type == null) {
      _addToken(TokenType.identifier);
    } else if (type == TokenType.boolean) {
      _addToken(type, text == 'true');
    } else if (type == TokenType.nil) {
      _addToken(type, null);
    } else {
      _addToken(type);
    }
  }

  void _numberOrDuration() {
    while (_isDigit(_peek())) {
      _advance();
    }

    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance();

      while (_isDigit(_peek())) {
        _advance();
      }
    }

    // Frame duration: 30f
    if (_peek() == 'f' || _peek() == 'F') {
      _advance();

      String text = source.substring(_start, _current - 1);

      if (text.contains('.')) {
        _error(_line, "Frame duration must be an integer.");
        return;
      }

      _addToken(
        TokenType.frameDuration,
        int.parse(text),
      );
      return;
    }

    // Time duration: 2.5s
    if (_peek() == 's' || _peek() == 'S') {
      _advance();

      String text = source.substring(_start, _current - 1);

      _addToken(
        TokenType.timeDuration,
        double.parse(text),
      );
      return;
    }

    // Angle degree: 180deg or 90.5deg
    if (_peek() == 'd' &&
        _peekNext() == 'e' &&
        _peekAfterNext() == 'g') {
      _advance(); // d
      _advance(); // e
      _advance(); // g

      String text = source.substring(_start, _current - 3);

      _addToken(
        TokenType.angleDegree,
        double.parse(text),
      );
      return;
    }

    // Regular number
    String text = source.substring(_start, _current);

    _addToken(
      TokenType.number,
      num.parse(text),
    );
  }

  void _string() {
    while (_peek() != '"' && !_isAtEnd()) {
      if (_peek() == '\n') {
        _line++;
      }

      _advance();
    }

    if (_isAtEnd()) {
      _error(_line, "Unterminated string.");
      return;
    }

    _advance();

    String value = source.substring(
      _start + 1,
      _current - 1,
    );

    _addToken(
      TokenType.string,
      value,
    );
  }

  bool _match(String expected) {
    if (_isAtEnd()) {
      return false;
    }

    if (source[_current] != expected) {
      return false;
    }

    _current++;
    return true;
  }

  String _peek() {
    if (_isAtEnd()) {
      return '\x00';
    }

    return source[_current];
  }

  String _peekNext() {
    if (_current + 1 >= source.length) {
      return '\x00';
    }

    return source[_current + 1];
  }

  String _peekAfterNext() {
    if (_current + 2 >= source.length) {
      return '\x00';
    }

    return source[_current + 2];
  }

  String _advance() {
    return source[_current++];
  }

  bool _isAlpha(String c) {
    return (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
        (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
        c == '_';
  }

  bool _isAlphaNumeric(String c) {
    return _isAlpha(c) || _isDigit(c);
  }

  bool _isDigit(String c) {
    return c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        c.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool _isHexDigit(String c) {
    return _isDigit(c) ||
        (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'f'.codeUnitAt(0)) ||
        (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'F'.codeUnitAt(0));
  }

  void _addToken(
    TokenType type, [
    Object? literal,
  ]) {
    String text = source.substring(
      _start,
      _current,
    );

    tokens.add(
      Token(
        type,
        text,
        literal,
        _line,
      ),
    );
  }

  void _hexColor() {
    // Consume all hexadecimal digits after '#'.
    while (_isHexDigit(_peek())) {
      _advance();
    }

    String text = source.substring(
      _start,
      _current,
    );

    // Smooth33 supports 3-digit and 6-digit hex colors.
    int digitCount = text.length - 1;

    if (digitCount != 3 && digitCount != 6) {
      _error(
        _line,
        "Invalid hex color '$text'. Expected 3 or 6 hexadecimal digits.",
      );
      return;
    }

    _addToken(
      TokenType.colorHex,
      text,
    );
  }

  void _error(
    int line,
    String message,
  ) {
    stderr.writeln(
      "[line $line] Error: $message",
    );

    _hadError = true;
  }
}