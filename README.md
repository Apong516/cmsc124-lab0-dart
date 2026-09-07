# Smooth33


## Creators


- Angelique Margaret M. Ardeña (elirvrrii)
- John Romson E. Erazo (Apong516)


## Overview


Smooth33 is a domain-specific programming language for procedural 3D animation. It is designed to let users describe what they want to happen in a 3D scene using simple, human-readable, animation-oriented programming constructs.


Rather than requiring users to manually configure every animation step or directly manipulate Blender's Python API, Smooth33 focuses on describing objects, time, state changes, transitions, reusable behaviors and events.


Smooth33 follows a timeline-first programming model, where time is treated as a fundamental part of animation. Users can express actions such as moving an object over a specified number of frames, defining reusable animation behaviors, and triggering actions when events occur.

The goal of Smooth33 is to make procedural animation code understandable even to users with limited programming experience. Its syntax is intentionally designed around concepts familiar to people who think about animation: what exists, what happens, when it happens, and how long it takes.
Smooth33 is intended to serve as a higher-level abstraction over Blender animation operations rather than as a replacement for Blender itself.
## Host language and build


- Host language: Dart 3.5.0
- Version metadata: `pubspec.yaml`
- Build: `./build.sh`
- A fresh clone requires Dart 3.5.0 or a compatible Dart SDK version.


## Running it


| Command                   | What it does                                      |
| ------------------------- | ------------------------------------------------- |
| `./run <file>`            | [Executes a program. Available from Lab 4.]       |
| `./run --tokenize <file>` | [Prints the token stream.]                        |
| `./run --parse <file>`    | [Prints the parsed tree.]                         |
| `./run --eval <file>`     | [Evaluates each expression and prints its value.] |
| `./run`                   | [Starts the REPL.]                                |


Exit codes: 0 [Successful execution ], 65 [Lexical or syntax error ], 70 [Runtime error].


## File extension
Smooth33 source files use the .s33 extension. The extension must match the ext field used in the test manifests.
## Lexical structure


### Keywords


| Keyword  | Purpose                                                             |
| -------- | ------------------------------------------------------------------- |
| object   | Declares a scene object bound to a Blender datablock.               |
| behavior | Defines a reusable motion (dynamic) or physics behavior.            |
| sequence | Defines an animation block over a specified range.                  |
| at       | Specifies frame or time markers and ranges within a sequence block. |
| over     | Specifies duration for interpolation or sequence execution.         |
| true     | Boolean for true value.                                             |
| false    | Boolean for false value.                                            |
| nil      | Representation of the absence of a value.                           |


### Operators


| Operator | Category      | Operands | Associativity | Precedence |
| -------- | ------------- | -------- | ------------- | ---------- |
| ->       | interpolation | binary   | right         | 1          |
| =        | assignment    | binary   | right         | 2          |
| ==       | equality      | binary   | left          | 3          |
| !=       | equality      | binary   | left          | 3          |
| <        | comparison    | binary   | left          | 4          |
| <=       | comparison    | binary   | left          | 4          |
| >        | comparison    | binary   | left          | 4          |
| >=       | comparison    | binary   | left          | 4          |
| +        | arithmetic    | binary   | left          | 5          |
| -        | arithmetic    | binary   | left          | 5          |
| \*       | arithmetic    | binary   | left          | 6          |
| /        | arithmetic    | binary   | left          | 6          |
| ..       | range         | binary   | left          | 7          |


### Literals


| Kind | Syntax | Meaning |
|---|---|---|
| number | `12`, `3.14` | Numeric value |
| frame duration | `30f` | Duration or position measured in frames |
| time duration | `3.5s` | Duration measured in seconds |
| string | `"Cube"`, `"Sphere"` | String value |
| boolean | `true`, `false` | Boolean value |
| nil | `nil` | Absence of a value |


### Identifiers


- Identifiers begin with a letter or underscore. 
- Subsequent characters may contain letters, digits, or underscores. 
- Identifiers are case-sensitive. 
- Keywords cannot be used as identifiers. 


### Comments


- Line comments: //
- Block comments: [tokens, or "not supported"]
- Nesting: Not supported


## Whitespace and termination


- Whitespace significant: No, whitespace is discarded by the scanner
- Statement terminator: [e.g. semicolon, newline, none]
- Block delimiters: Curly braces
- Grouping delimiters: Parentheses


## Token output format


```
[one line of real --tokenize output]
```


[What each field means. Frozen as of Lab 1; changes are recorded in the
changelog.]


## Grammar


```
[Your complete context-free grammar, current as of the latest activity.
Unambiguous, with precedence and associativity encoded in rule structure.]
```


## Parse output format


```
[one line of real --parse output, e.g. (+ 1.0 (* 2.0 3.0))]
```


- Groupings print as: [form]
- Numbers print as: [form]


## Semantics


### Values and types


[What runtime values exist, and how they are represented in the host
language.]


### Value printing


- Numbers: [e.g. 5 rather than 5.0]
- Nil: [spelling]
- Strings: [with or without quotes]


### Truthiness


[The complete rule. Which values are false in a condition; everything else is
true.]


### Operator semantics


- Arithmetic: [accepted operand types]
- `+` on strings: [concatenation, error, or coercion]
- Mixed types: [what happens]
- Comparison: [accepted operand types]
- Equality across types: [false, or an error]
- Division by zero: [value produced, or runtime error]


### Scope and bindings


- Redeclaration in the same scope: [allowed or an error]
- Uninitialized variable holds: [value]
- Shadowing: [behavior]
- Undefined name: [static error with exit 65, or runtime error with exit 70]


### Control flow and functions


- Logical operators return: [booleans, or the operand]
- Dangling else binds to: [which if]
- Closure capture of a loop variable: [per iteration, or shared]
- Function with no return statement produces: [value]
- Arity mismatch: [message and exit code]


## Native functions


| Name   | Arguments         | Returns | Notes     |
| ------ | ----------------- | ------- | --------- |
| [name] | [count and types] | [type]  | [caveats] |


## Errors and diagnostics


Message format:


```
[one real static error]
[one real runtime error]
```


| Failure         | Exit code |
| --------------- | --------- |
| [lexical error] | 65        |
| [syntax error]  | 65        |
| [runtime error] | 70        |


## Testing conventions


| Folder     | Activity  | Mode    | Flag         |
| ---------- | --------- | ------- | ------------ |
| tests/lab1 | Scanner   | sidecar | `--tokenize` |
| tests/lab2 | Parser    | sidecar | `--parse`    |
| tests/lab3 | Evaluator | inline  | `--eval`     |
| tests/lab4 | Context   | inline  | none         |
| tests/lab5 | Functions | inline  | none         |


```
[specific tests]...
```


Run locally with:


```bash
curl -sSL https://raw.githubusercontent.com/WhiteLicorice/cmsc-124-harness/v1.1/run_tests.py -o run_tests.py
./build.sh
python3 run_tests.py tests/lab1
```


## Sample code


```
[a short program]
```


Output:


```
[its output]
```


## Design rationale


[Why the language is the way it is. Cover the choices that surprised you, the
features you cut, and the decisions you reversed. Specific reasons, not
approval of your own work.]


## Known limitations


- [What doesn't work, what is unimplemented, where behavior is worse than you
  would like.]


## Changelog


| Activity | What changed in the language |
| -------- | ---------------------------- |
| Lab 1    | [entry]                      |





