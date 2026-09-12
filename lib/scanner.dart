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

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }

    tokens.add(Token(TokenType.eof, "", null, _line));

    if (_hadError) {
      exit(65);
    }

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
      case '+':
        _addToken(TokenType.plus);
        break;
      case ';':
        _addToken(TokenType.semicolon);
        break;
      case '*':
        _addToken(TokenType.star);
        break;

      case '-':
        if (_match('>')) {
          _addToken(TokenType.arrow);
        } else {
          _addToken(TokenType.minus);
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

      default:
        _error(_line, "Unexpected character '$c'.");
        break;
    }
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

  String _advance() => source[_current++];

  void _addToken(TokenType type, [Object? literal]) {
    String text = source.substring(_start, _current);
    tokens.add(Token(type, text, literal, _line));
  }

  void _error(int line, String message) {
    stderr.writeln("[line $line] Error: $message");
    _hadError = true;
  }
}
