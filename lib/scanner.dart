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

    // Error handling is done by the caller.

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
        _addToken(_match('=') ? TokenType.equalEqual : TokenType.equal);
        break;
      case '!':
        if (_match('=')) {
          _addToken(TokenType.bangEqual);
        } else {
          _error(_line, "Unexpected character '!'.");
        }
        break;
      case '<':
        _addToken(_match('=') ? TokenType.lessEqual : TokenType.less);
        break;
      case '>':
        _addToken(_match('=') ? TokenType.greaterEqual : TokenType.greater);
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

    if (_peek() == 'f' || _peek() == 'F') {
      _advance();
      String text = source.substring(_start, _current - 1);
      _addToken(TokenType.frameDuration, int.parse(text));
    } else if (_peek() == 's' || _peek() == 'S') {
      _advance();
      String text = source.substring(_start, _current - 1);
      _addToken(TokenType.timeDuration, double.parse(text));
    } else if (_peek() == 'd' && _peekNext() == 'e') {
      _advance(); // consume 'd'
      if (_peek() == 'e' && _peekNext() == 'g') {
        _advance(); // consume 'e'
        _advance(); // consume 'g'
        String text = source.substring(_start, _current - 3);
        _addToken(TokenType.angleDegree, double.parse(text));
      }
    } else {
      String text = source.substring(_start, _current);
      _addToken(TokenType.number, num.parse(text));
    }
  }

  void _string() {
    while (_peek() != '"' && !_isAtEnd()) {
      if (_peek() == '\n') _line++;
      _advance();
    }

    if (_isAtEnd()) {
      _error(_line, "Unterminated string.");
      return;
    }

    _advance();
    String value = source.substring(_start + 1, _current - 1);
    _addToken(TokenType.string, value);
  }

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (source[_current] != expected) return false;
    _current++;
    return true;
  }

  String _peek() {
    if (_isAtEnd()) return '\x00';
    return source[_current];
  }

  String _peekNext() {
    if (_current + 1 >= source.length) return '\x00';
    return source[_current + 1];
  }

  String _advance() => source[_current++];

  bool _isAlpha(String c) {
    return (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
        (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
        c == '_';
  }

  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);

  bool _isDigit(String c) {
    return c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        c.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  void _addToken(TokenType type, [Object? literal]) {
    String text = source.substring(_start, _current);
    tokens.add(Token(type, text, literal, _line));
  }

  void _hexColor() {
    while (_isHexDigit(_peek())) {
      String text = source.substring(_start, _current);
      _addToken(TokenType.colorHex, text);
    }
  }

  bool _isHexDigit(String c) {
    //checks if character is a valid hexadecimal digit
    return _isDigit(c) ||
        (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'f'.codeUnitAt(0)) ||
        (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'F'.codeUnitAt(0));
  }

  void _error(int line, String message) {
    stderr.writeln("[line $line] Error: $message");
    _hadError = true;
  }
}
