// lib/ast_printer.dart
import 'ast.dart';

class AstPrinter implements ExprVisitor<String> {
  String print(Expr expr) {
    return expr.accept(this);
  }

  @override
  String visitBinaryExpr(Binary expr) {
    return _parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(Grouping expr) {
    return _parenthesize("group", [expr.expression]);
  }

  @override
  String visitLiteralExpr(Literal expr) {
    if (expr.value == null) return "nil";
    if (expr.value is double) {
      double d = expr.value as double;
      if (d == d.toInt()) return "${d.toInt()}.0";
      return "$d";
    }
    if (expr.value is int) return "${expr.value}.0";
    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(Unary expr) {
    return _parenthesize(expr.operator.lexeme, [expr.right]);
  }

  String _parenthesize(String name, List<Expr> exprs) {
    StringBuffer buffer = StringBuffer();
    buffer.write("($name");
    for (Expr expr in exprs) {
      buffer.write(" ");
      buffer.write(expr.accept(this));
    }
    buffer.write(")");
    return buffer.toString();
  }
}
