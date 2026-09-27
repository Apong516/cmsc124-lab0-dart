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

| Command | What it does |
| --- | --- |
| `./run <file>` | Executes a program. Available from Lab 4. |
| `./run --tokenize <file>` | Prints the token stream. |
| `./run --parse <file>` | Prints the parsed tree. Available in a later lab. |
| `./run --eval <file>` | Evaluates each expression and prints its value. Available in a later lab. |
| `./run` | Starts the REPL. |

For Lab 1, the primary command is:

```text
./run --tokenize <file>
```

### Exit codes

- `0` — Successful execution
- `65` — Lexical or syntax error
- `70` — Runtime error

## File extension

Smooth33 source files use the `.s33` extension. The extension must match the `ext` field used in the test manifests.

## Lexical structure

The Smooth33 scanner reads source code from left to right and groups characters into tokens.

Each token contains:

- token type
- lexeme
- literal value, when applicable
- source line number

The scanner processes the input character by character and uses lookahead when necessary to distinguish multi-character operators and literals.

### Keywords

| Keyword | Purpose |
| --- | --- |
| `object` | Declares a scene object bound to a Blender datablock. |
| `behavior` | Defines a reusable motion or physics behavior. |
| `sequence` | Defines an animation block over a specified range. |
| `at` | Specifies frame or time markers and ranges within a sequence block. |
| `over` | Specifies duration for interpolation or sequence execution. |
| `dump` | Requests state inspection of an object. |
| `true` | Boolean value representing true. |
| `false` | Boolean value representing false. |
| `nil` | Representation of the absence of a value. |

Keywords are recognized separately from identifiers.

For example:

```text
object Cube dump
```

`object` and `dump` are recognized as keywords, while `Cube` is recognized as an identifier.

### Operators

| Operator | Category | Operands | Associativity | Precedence |
| --- | --- | --- | --- | --- |
| `->` | interpolation | binary | right | 1 |
| `=` | assignment | binary | right | 2 |
| `==` | equality | binary | left | 3 |
| `!=` | equality | binary | left | 3 |
| `<` | comparison | binary | left | 4 |
| `<=` | comparison | binary | left | 4 |
| `>` | comparison | binary | left | 4 |
| `>=` | comparison | binary | left | 4 |
| `+` | arithmetic | binary | left | 5 |
| `-` | arithmetic | binary | left | 5 |
| `*` | arithmetic | binary | left | 6 |
| `/` | arithmetic | binary | left | 6 |
| `..` | range | binary | left | 7 |

### Additional punctuation and Week 3 operators

| Symbol | Token | Purpose |
| --- | --- | --- |
| `:` | `COLON` | Property target binding |
| `@+` | `ATPLUS` | Relative frame offset forward |
| `@-` | `ATMINUS` | Relative frame offset backward |
| `(` | `LEFTPAREN` | Grouping delimiter |
| `)` | `RIGHTPAREN` | Grouping delimiter |
| `{` | `LEFTBRACE` | Block delimiter |
| `}` | `RIGHTBRACE` | Block delimiter |
| `,` | `COMMA` | Separator |
| `.` | `DOT` | Property/member access |
| `;` | `SEMICOLON` | Statement delimiter |

## Literals

| Kind | Syntax | Meaning |
| --- | --- | --- |
| number | `12`, `3.14` | Numeric value |
| frame duration | `30f` | Duration or position measured in frames |
| time duration | `3.5s` | Duration measured in seconds |
| angle degree | `180deg`, `90.5deg` | Angle measured in degrees |
| color hex | `#FF5733`, `#00F` | Hexadecimal color value |
| string | `"Cube"`, `"Sphere"` | String value |
| boolean | `true`, `false` | Boolean value |
| nil | `nil` | Absence of a value |

### Frame durations

Frame durations use the `f` suffix.

Examples:

```text
30f
10f
5f
```

The numeric portion represents an integer frame count.

### Time durations

Time durations use the `s` suffix.

Examples:

```text
2.5s
3s
```

### Angle degrees

Angles use the `deg` suffix.

Examples:

```text
180deg
90.5deg
```

These are recognized as `ANGLEDEGREE` tokens.

### Hexadecimal colors

Smooth33 supports 3-digit and 6-digit hexadecimal color literals.

Examples:

```text
#00F
#FF5733
```

These are recognized as `COLORHEX` tokens.

Only 3-digit and 6-digit hexadecimal forms are accepted.

## Identifiers

Identifiers begin with a letter or underscore.

Subsequent characters may contain letters, digits, or underscores.

Identifiers are case-sensitive.

Keywords cannot be used as identifiers.

Examples:

```text
Cube
location
position1
_myObject
```

### Property target binding

A colon (`:`) is used for property target binding.

Example:

```text
Cube:location.x
```

The scanner recognizes the components as:

```text
IDENTIFIER   Cube
COLON        :
IDENTIFIER   location
DOT          .
IDENTIFIER   x
```

The scanner handles the lexical recognition of these components in Lab 1. Their complete semantic behavior belongs to later stages of the language.

### Relative frame offsets

Smooth33 supports relative frame offsets using:

```text
@+
@-
```

Examples:

```text
@+ 10f
@- 5f
```

`@+` represents a forward relative frame offset, while `@-` represents a backward relative frame offset.

The offset operator and its frame duration are emitted as separate tokens.

## Comments

Line comments begin with `//`.

Example:

```text
// Move the cube
30f
```

The scanner ignores the contents of a line comment and continues scanning the following source.

Block comments are not currently supported.

Nesting is not supported.

## Whitespace and termination

- Whitespace is not significant.
- Spaces and tabs are discarded by the scanner.
- Newline characters are tracked for line numbering but are not emitted as tokens.
- Semicolons are recognized as `SEMICOLON` tokens.
- Curly braces are recognized as block delimiters.
- Parentheses are recognized as grouping delimiters.

## Token output format

The `--tokenize` command prints one token per line.

The format is:

```text
Token(type=TOKEN_TYPE, lexeme="LEXEME", literal=LITERAL, line=LINE)
```

For tokens without a literal value, `literal=null` is printed.

Example:

```text
Token(type=KEYWORDOBJECT, lexeme="object", literal=null, line=1)
Token(type=IDENTIFIER, lexeme="Cube", literal=null, line=1)
Token(type=FRAMEDURATION, lexeme="30f", literal=30, line=2)
```

### Week 3 tokenization example

Given:

```text
// Durations & State Inspection
30f 2.5s dump Cube

// Angles and Colors
180deg 90.5deg #FF5733 #00F

// Property Binding & Frame Offsets
Cube:location.x @+ 10f @- 5f
```

The scanner produces:

```text
Token(type=FRAMEDURATION, lexeme="30f", literal=30, line=2)
Token(type=TIMEDURATION, lexeme="2.5s", literal=2.5, line=2)
Token(type=KEYWORDDUMP, lexeme="dump", literal=null, line=2)
Token(type=IDENTIFIER, lexeme="Cube", literal=null, line=2)
Token(type=ANGLEDEGREE, lexeme="180deg", literal=180.0, line=5)
Token(type=ANGLEDEGREE, lexeme="90.5deg", literal=90.5, line=5)
Token(type=COLORHEX, lexeme="#FF5733", literal=#FF5733, line=5)
Token(type=COLORHEX, lexeme="#00F", literal=#00F, line=5)
Token(type=IDENTIFIER, lexeme="Cube", literal=null, line=8)
Token(type=COLON, lexeme=":", literal=null, line=8)
Token(type=IDENTIFIER, lexeme="location", literal=null, line=8)
Token(type=DOT, lexeme=".", literal=null, line=8)
Token(type=IDENTIFIER, lexeme="x", literal=null, line=8)
Token(type=ATPLUS, lexeme="@+", literal=null, line=8)
Token(type=FRAMEDURATION, lexeme="10f", literal=10, line=8)
Token(type=ATMINUS, lexeme="@-", literal=null, line=8)
Token(type=FRAMEDURATION, lexeme="5f", literal=5, line=8)
Token(type=EOF, lexeme="", literal=null, line=8)
```

## Grammar

[Your complete context-free grammar, current as of the latest activity.]

## Parse output format

[One line of real `--parse` output.]

- Groupings print as: `[form]`
- Numbers print as: `[form]`

## Semantics

### Values and types

[What runtime values exist, and how they are represented in the host language.]

### Value printing

- Numbers: [e.g. 5 rather than 5.0]
- Nil: [spelling]
- Strings: [with or without quotes]

### Truthiness

[The complete rule. Which values are false in a condition; everything else is true.]

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

| Name | Arguments | Returns | Notes |
| --- | --- | --- | --- |
| [name] | [count and types] | [type] | [caveats] |

## Errors and diagnostics

The scanner reports lexical errors to standard error and includes the corresponding source line number.

The scanner continues processing the source after a lexical error in file mode so that additional errors can be detected.

After scanning is complete, the program exits with code `65` if any lexical error occurred.

In REPL mode, the error is reported and the scanner returns to the prompt.

Examples of lexical errors include:

- invalid characters
- invalid operators
- unterminated strings
- invalid hexadecimal color lengths

Example:

```text
object @
```

An invalid character is reported as a lexical error on the corresponding source line.

| Failure | Exit code |
| --- | --- |
| Lexical error | 65 |
| Syntax error | 65 |
| Runtime error | 70 |

## Testing conventions

| Folder | Activity | Mode | Flag |
| --- | --- | --- | --- |
| `tests/lab1` | Scanner | sidecar | `--tokenize` |
| `tests/lab2` | Parser | sidecar | `--parse` |
| `tests/lab3` | Evaluator | inline | `--eval` |
| `tests/lab4` | Context | inline | none |
| `tests/lab5` | Functions | inline | none |

### Lab 1 tests

The Lab 1 scanner test suite currently contains 11 test cases covering:

- keywords
- identifiers
- operators
- numbers
- frame durations
- time durations
- angles
- hexadecimal colors
- property target binding
- relative frame offsets
- comments
- multiline input
- empty input
- invalid characters
- invalid operators
- lexical errors

The Week 3 test case includes:

- frame durations
- time durations
- `dump`
- angle literals
- hexadecimal colors
- property target binding
- relative frame offsets

Run locally with:

```bash
./build.sh
python3 run_tests.py tests/lab1
```

The Lab 1 tests are also executed by the project's CI workflow.

## Sample code

A sample Smooth33 source using the current lexical features:

```text
object Cube

sequence Cube {
    at 1
    Cube:location.x = 0

    at @+ 30f
    Cube:location.x = 10
}
```

Additional lexical examples:

```text
30f
2.5s
180deg
90.5deg
#FF5733
#00F
dump Cube
Cube:location.x
@+ 10f
@- 5f
```

The parser and evaluator stages are developed in later activities. Lab 1 focuses on recognizing the lexical components of the source.

## Design rationale

Smooth33 uses a timeline-first programming model because animation depends heavily on time, frames, durations, and state changes.

Animation-oriented literals such as frame durations (`30f`), time durations (`2.5s`), angles (`90deg`), and hexadecimal colors (`#FF5733`) allow common animation-related values to be represented directly in source code.

The scanner uses character-by-character processing and lookahead rather than regular expressions. This makes multi-character operators and suffix-based literals explicit in the scanner implementation.

The scanner also continues scanning after lexical errors in file mode so that multiple lexical errors can be detected in a single source file rather than stopping at the first error.

## Known limitations

- The parser is not yet implemented.
- The evaluator is not yet implemented.
- Complete semantic behavior for property target binding is not yet implemented.
- Complete semantic behavior for `dump` is not yet implemented.
- Block comments are not supported.
- Runtime behavior is not yet implemented.
- Native functions are not yet defined.
- The current implementation focuses on the lexical requirements for Lab 1.

## Changelog

| Activity | What changed in the language |
| --- | --- |
| Lab 1 | Implemented the character-by-character lexical scanner with keywords, identifiers, numbers, strings, durations, operators, comments, line tracking, and lexical error handling. |
