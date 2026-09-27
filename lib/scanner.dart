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

    // New Keywords as of 09/27
    'bind': TokenType.keywordBind,
    'spawn': TokenType.keywordSpawn,
    'with': TokenType.keywordWith,
    'as': TokenType.keywordAs,
    'if': TokenType.keywordIf,
    'else': TokenType.keywordElse,
    'for': TokenType.keywordFor,
    'while': TokenType.keywordWhile,
    'in': TokenType.keywordIn,
    'def': TokenType.keywordDef,
    'var': TokenType.keywordVar,
    'let': TokenType.keywordVar,

    // Animation & Motion Keywords
    'move': TokenType.keywordMove,
    'rotate': TokenType.keywordRotate,
    'scale': TokenType.keywordScale,
    'ease': TokenType.keywordEase,
    'loop': TokenType.keywordLoop,
    'stagger': TokenType.keywordStagger,
    'hold': TokenType.keywordHold,

    // Primitive Keywords
    'cube': TokenType.keywordCube,
    'sphere': TokenType.keywordSphere,
    'plane': TokenType.keywordPlane,
    'cylinder': TokenType.keywordCylinder,
    'camera': TokenType.keywordCamera,
    'light': TokenType.keywordLight,
    'material': TokenType.keywordMaterial,
    'parent': TokenType.keywordParent,
    'unparent': TokenType.keywordUnparent,
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
      case '[':
        _addToken(TokenType.leftBracket);
        break;
      case ']':
        _addToken(TokenType.rightBracket);
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
      case '%':
        _addToken(TokenType.percent);
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
          _addToken(TokenType.atSign);
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
          // Single-line comment
          while (_peek() != '\n' && !_isAtEnd()) {
            _advance();
          }
        } else if (_match('*')) {
          // Multi-line block comment
          _blockComment();
        } else {
          _addToken(TokenType.slash);
        }
        break;

      case '&':
        if (_match('&')) {
          _addToken(TokenType.andAnd);
        } else {
          _error(_line, "Expected '&' after '&'.");
        }
        break;

      case '|':
        if (_match('|')) {
          _addToken(TokenType.orOr);
        } else {
          _error(_line, "Expected '|' after '|'.");
        }
        break;

      case '=':
        _addToken(_match('=') ? TokenType.equalEqual : TokenType.equal);
        break;
      case '!':
        _addToken(_match('=') ? TokenType.bangEqual : TokenType.bang);
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

  void _blockComment() {
    while (!_isAtEnd()) {
      if (_peek() == '\n') {
        _line++;
      }
      if (_peek() == '*' && _peekNext() == '/') {
        _advance(); // Consume '*'
        _advance(); // Consume '/'
        return;
      }
      _advance();
    }
    _error(_line, "Unterminated block comment.");
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

    // Check for frame durations (e.g. 30f)
    if (_peek() == 'f' || _peek() == 'F') {
      if (_peekNext() == 'p' || _peekNext() == 'P') {
        // Frame rate (e.g. 24fps)
        _advance(); // consume 'f'
        _advance(); // consume 'p'
        if (_peek() == 's' || _peek() == 'S') {
          _advance(); // consume 's'
          String text = source.substring(_start, _current - 3);
          _addToken(TokenType.frameRate, int.parse(text));
          return;
        }
      }
      _advance();
      String text = source.substring(_start, _current - 1);
      _addToken(TokenType.frameDuration, int.parse(text));
    }
    // Check for time durations (e.g. 2.5s)
    else if (_peek() == 's' || _peek() == 'S') {
      _advance();
      String text = source.substring(_start, _current - 1);
      _addToken(TokenType.timeDuration, double.parse(text));
    }
    // Check for degrees (e.g. 180deg)
    else if (_peek() == 'd' && _peekNext() == 'e') {
      _advance(); // consume 'd'
      if (_peek() == 'e' && _peekNext() == 'g') {
        _advance(); // consume 'e'
        _advance(); // consume 'g'
        String text = source.substring(_start, _current - 3);
        _addToken(TokenType.angleDegree, double.parse(text));
      }
    }
    // Check for radians (e.g. 3.14rad)
    else if (_peek() == 'r' && _peekNext() == 'a') {
      _advance(); // consume 'r'
      if (_peek() == 'a' && _peekNext() == 'd') {
        _advance(); // consume 'a'
        _advance(); // consume 'd'
        String text = source.substring(_start, _current - 3);
        _addToken(TokenType.angleRadian, double.parse(text));
      }
    }
    // Default numeric literal
    else {
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

  void _hexColor() {
    while (_isHexDigit(_peek())) {
      _advance();
    }
    String text = source.substring(_start, _current);
    _addToken(TokenType.colorHex, text);
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

  bool _isHexDigit(String c) {
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
