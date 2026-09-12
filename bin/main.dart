import 'dart:io';
import '../lib/scanner.dart';
import '../lib/token.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    runRepl();
  } else if (args.length == 1 && args[0] == '--tokenize') {
    exit(65);
  } else if (args.length == 2 && args[0] == '--tokenize') {
    runFile(args[1]);
  } else {
    stderr.writeln("Usage: run [--tokenize] <file>");
    exit(65);
  }
}

void runFile(String path) {
  File file = File(path);
  if (!file.existsSync()) {
    stderr.writeln("File not found: $path");
    exit(65);
  }

  String source = file.readAsStringSync();
  Scanner scanner = Scanner(source);
  List<Token> tokens = scanner.scanTokens();

  for (Token token in tokens) {
    print(token);
  }
}

void runRepl() {
  while (true) {
    stdout.write("> ");
    String? line = stdin.readLineSync();
    if (line == null) break;

    Scanner scanner = Scanner(line);
    List<Token> tokens = scanner.scanTokens();

    for (Token token in tokens) {
      print(token);
    }
  }
}
