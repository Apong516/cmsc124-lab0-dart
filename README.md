# smooth33

## Creators

- Angelique Margaret M. Ardeña (elirvrrii)
- John Romson E. Erazo (Apong516)

## Overview

Smooth33 is a programming language designed specifically for the 3D Animation procedural setups, keyframing, and and scenes used in Blender. It prioritizes a domain-specific and timeline-first approach when it comes to scripting.

## Host language and build

- Host language: Dart 3.5.0
- Version metadata: `pubspec.yaml`
- Build: `./build.sh`
- [Anything a fresh clone needs to know.]

## Running it

| Command                   | What it does                                      |
| ------------------------- | ------------------------------------------------- |
| `./run <file>`            | [Executes a program. Available from Lab 4.]       |
| `./run --tokenize <file>` | [Prints the token stream.]                        |
| `./run --parse <file>`    | [Prints the parsed tree.]                         |
| `./run --eval <file>`     | [Evaluates each expression and prints its value.] |
| `./run`                   | [Starts the REPL.]                                |

Exit codes: 0 [when], 65 [when], 70 [when].

## File extension

`[.ext]` [Must match the `ext` field in every tests/lab*/manifest.json.]

## Lexical structure

### Keywords

| Keyword  | Purpose                                                             |
| -------- | ------------------------------------------------------------------- |
| object   | Declares a scene object bound to a Blender datablock.               |
| behavior | Defines a resuable motion (dynamic) or physics behavior.            |
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
| =>       | comparison    | binary   | left          | 4          |
| +        | arithmetic    | binary   | left          | 5          |
| -        | arithmetic    | binary   | left          | 5          |
| \*       | arithmetic    | binary   | left          | 6          |
| /        | arithmetic    | binary   | left          | 6          |
| ..       | range         | binary   | left          | 7          |

### Literals

| Kind    | Syntax                    | Produces                                                              |
| ------- | ------------------------- | --------------------------------------------------------------------- |
| number  | 12, 3.14, 12f, 3.5s, 0.5t | Floating-point numbers that represent scalar or time frame durations. |
| string  | "Cube", "Sphere"          | String runtime values. Does not span across multiple lines.           |
| boolean | "true", "false"           | Boolean runtime values.                                               |
| nil     | nil                       | Absence of value.                                                     |

### Identifiers

- Start characters: Letters, underscore
- Continue characters: Letters, underscore
- Case-sensitive: yes
- [Reserved patterns, length limits, or other restrictions.]

### Comments

- Line comments: //
- Block comments: [tokens, or "not supported"]
- Nesting: Not supported
- [Harness note: comment_prefix in tests/lab*/manifest.json is set to the
  token above.]

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
