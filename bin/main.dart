import 'dart:io';
import 'package:cmsc124_lab0_dart/scanner.dart';
import 'package:cmsc124_lab0_dart/token.dart';
import 'package:cmsc124_lab0_dart/parser.dart';
import 'package:cmsc124_lab0_dart/ast.dart';
import 'package:cmsc124_lab0_dart/ast_printer.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    runRepl();
  } else if (args.length == 2 &&
      (args[0] == '--tokenize' || args[0] == '--parse')) {
    runFile(args[0], args[1]);
  } else {
    stderr.writeln("Usage: run [--tokenize|--parse] <file>");
    exit(65);
  }
}

void runFile(String flag, String path) {
  File file = File(path);
  if (!file.existsSync()) {
    stderr.writeln("File not found: $path");
    exit(65);
  }

  String source = file.readAsStringSync();
  Scanner scanner = Scanner(source);
  List<Token> tokens = scanner.scanTokens();

  if (scanner.hadError) {
    exit(65);
  }

  if (flag == '--tokenize') {
    for (Token token in tokens) {
      print(token);
    }
    exit(0);
  } else if (flag == '--parse') {
    Parser parser = Parser(tokens);
    Expr? expression = parser.parse();

    if (parser.hadError || expression == null) {
      exit(65);
    }

    print(AstPrinter().print(expression));
    exit(0);
  }
}

void runRepl() {
  while (true) {
    stdout.write("> ");
    String? line = stdin.readLineSync();
    if (line == null) break;
    if (line.trim().isEmpty) continue;

    Scanner scanner = Scanner(line);
    List<Token> tokens = scanner.scanTokens();

    if (scanner.hadError) continue;

    // Parse the tokens into an AST expression
    Parser parser = Parser(tokens);
    Expr? expression = parser.parse();

    // Print the parenthesized AST output if parsing succeeded
    if (!parser.hadError && expression != null) {
      print(AstPrinter().print(expression));
    }
  }
}
