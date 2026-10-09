
import 'dart:io';
import 'ast.dart';
import 'token.dart';

class ParseError implements Exception {}

class Parser {
  final List<Token> tokens;
  int _current = 0;
  bool _hadError = false;

  Parser(this.tokens);

  bool get hadError => _hadError;

  Expr? parse() {
    try {
      return _expression();
    } catch (error) {
      return null;
    }
  }

  List<Expr> parseExpressions() {
    List<Expr> expressions = [];

    while (!_isAtEnd()) {
      // Remember the source line where this expression begins.
      int startingLine = _peek().line;

      // Find the end of this line's token range.
      int end = _current;
      while (end < tokens.length &&
          tokens[end].type != TokenType.eof &&
          tokens[end].line == startingLine) {
        end++;
      }

      // Parse only the tokens belonging to this source line.
      List<Token> lineTokens = tokens.sublist(_current, end);

      // Give this expression its own EOF token with the correct line number.
      int errorLine = end > _current
          ? tokens[end - 1].line
          : startingLine;

      lineTokens.add(
        Token(TokenType.eof, '', null, errorLine),
      );

      Parser lineParser = Parser(lineTokens);
      Expr? expr = lineParser.parse();

      if (expr != null && !lineParser.hadError) {
        expressions.add(expr);
      } else {
        _hadError = true;
      }

      // Move to the first token on the next line.
      _current = end;
    }

    return expressions;
  }

  // Grammar Cascade (Stratified Precedence)
  Expr _expression() => _logicalOr();

  Expr _logicalOr() {
    Expr expr = _logicalAnd();
    while (_match([TokenType.orOr])) {
      Token operator = _previous();
      Expr right = _logicalAnd();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr _logicalAnd() {
    Expr expr = _equality();
    while (_match([TokenType.andAnd])) {
      Token operator = _previous();
      Expr right = _equality();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr _equality() {
    Expr expr = _comparison();
    while (_match([TokenType.bangEqual, TokenType.equalEqual])) {
      Token operator = _previous();
      Expr right = _comparison();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr _comparison() {
    Expr expr = _term();
    while (_match([
      TokenType.greater,
      TokenType.greaterEqual,
      TokenType.less,
      TokenType.lessEqual,
    ])) {
      Token operator = _previous();
      Expr right = _term();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr _term() {
    Expr expr = _factor();
    while (_match([TokenType.minus, TokenType.plus])) {
      Token operator = _previous();
      Expr right = _factor();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr _factor() {
    Expr expr = _unary();
    while (_match([TokenType.slash, TokenType.star, TokenType.percent])) {
      Token operator = _previous();
      Expr right = _unary();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr _unary() {
    if (_match([TokenType.bang, TokenType.minus])) {
      Token operator = _previous();
      Expr right = _unary();
      return Unary(operator, right);
    }
    return _primary();
  }

  Expr _primary() {
    if (_match([TokenType.boolean])) return Literal(_previous().literal);
    if (_match([TokenType.nil])) return Literal(null);

    if (_match([
      TokenType.identifier,
      TokenType.number,
      TokenType.string,
      TokenType.colorHex,
      TokenType.frameDuration,
      TokenType.timeDuration,
      TokenType.angleDegree,
      TokenType.angleRadian,
      TokenType.frameRate,
    ])) {
      return Literal(_previous().literal ?? _previous().lexeme);
    }

    if (_match([TokenType.leftParen])) {
      Expr expr = _expression();
      _consume(TokenType.rightParen, "Expect ')' after expression.");
      return Grouping(expr);
    }

    throw _error(_peek(), "Expect expression.");
  }

  // State Helpers
  bool _match(List<TokenType> types) {
    for (TokenType type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw _error(_peek(), message);
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => _peek().type == TokenType.eof;
  Token _peek() => tokens[_current];
  Token _previous() => tokens[_current - 1];

  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == TokenType.semicolon) return;

      switch (_peek().type) {
        case TokenType.keywordObject:
        case TokenType.keywordBehavior:
        case TokenType.keywordSequence:
        case TokenType.keywordIf:
        case TokenType.keywordFor:
        case TokenType.keywordWhile:
        case TokenType.keywordDef:
        case TokenType.keywordLet:
          return;
        default:
          break;
      }
      _advance();
    }
  }

  ParseError _error(Token token, String message) {
    _hadError = true;
    if (token.type == TokenType.eof) {
      stderr.writeln("[line ${token.line}] Error at end: $message");
    } else {
      stderr.writeln(
        "[line ${token.line}] Error at '${token.lexeme}': $message",
      );
    }
    return ParseError();
  }
}
