# 01 — Core expressions, patterns, types, and literal syntax

## 1. Records: types, expressions, patterns, selectors, and flexible rows

**HOL4/SML syntax**

```sml
type t = {name : string, count : int}
val r = {name = "x", count = 3}
val {name, count} = r
val n = #count r
fun f {name, ...} = name
```

HOL4's source AST has explicit nodes for record types, record expressions/patterns, field selection, record rows, shorthand row bindings, and `...`.

**CakeML status: Absent.**

Current CakeML `ast_t` has only type variables, functions, tuples, and type constructor applications. Its expression and pattern ASTs have no record node. Braces are tokenized but records are not in the consumed grammar.

This is one of the largest direct-source compatibility gaps because HOL4 uses records extensively in kernel, parser, tactic, build, and runtime code.

## 2. `while ... do ...`

**HOL4/SML syntax**

```sml
while not (eof ()) do
  step ()
```

HOL4's own source AST has a `While` expression node, and Poly/ML-specific HOL tooling uses `while`.

**CakeML status: Absent.**

`WhileT` is present among CakeML tokens, but the current expression grammar has no `while` production. The current verified token set does not even give `do` a dedicated consumed grammar role.

A semantics-preserving source-to-source lowering is straightforward when evaluation order is accounted for:

```sml
let
  fun loop () =
    if p () then (body (); loop ()) else ()
in
  loop ()
end
```

## 3. Multi-arm anonymous functions

**HOL4/SML syntax**

```sml
fn NONE => 0
 | SOME x => x
```

HOL4 code uses this style, and the HOL source AST represents `Fn` as a list of arms.

**CakeML status: Restricted.**

Current CakeML grammar accepts only:

```sml
fn pattern => expression
```

It does not accept additional `| pattern => expression` arms on the same `fn`.

This can generally be desugared to a one-argument function containing `case`.

## 4. Multi-clause `fun` definitions

**HOL4/SML syntax**

```sml
fun length [] = 0
  | length (_ :: xs) = 1 + length xs
```

This is pervasive in HOL4.

**CakeML status: Restricted.**

CakeML supports mutually recursive function names with `and`, but each function declaration is one equation in the source grammar. It does not provide Standard ML's same-function `|` clause family.

A preprocessor can usually combine clauses into one `case`.

## 5. Standard ML datatype constructor declaration syntax: `of`

**HOL4/SML syntax**

```sml
datatype 'a option = NONE | SOME of 'a
datatype t = C of int * string
```

**CakeML status: Syntax and arity model differ.**

CakeML uses Haskell-inspired constructor declarations:

```sml
datatype 'a option = None | Some 'a
datatype t = C int string
```

This is not merely spelling. SML constructors conceptually have zero or one constructor argument, where a tuple can be that argument. CakeML constructors have an explicit list of constructor arguments.

A translator must preserve the original SML constructor's tuple-vs-multiple-argument behavior.

## 6. Constructors as first-class function values / partial constructor use

**HOL4/SML syntax**

```sml
List.map SOME xs
```

HOL4 contains such uses.

**CakeML status: Semantic mismatch / restricted.**

CakeML requires constructors to be fully applied. Its own documentation gives the corresponding style as:

```sml
List.map (fn x => Some x) xs
```

A source translation is usually possible, but it must know each constructor's arity.

## 7. Constructor and variable lexical classification

Standard ML determines whether an identifier denotes a constructor largely from the static environment. CakeML imposes a lexical convention:

- constructors/modules begin uppercase;
- alpha-numeric variables/functions begin lowercase.

This means SML programs using names that violate CakeML's lexical convention cannot be parsed with equivalent meaning without renaming.

HOL4's source AST also permits `op`-qualified constructor identifiers and symbolic constructor forms that CakeML's uppercase-constructor grammar does not generally provide.

## 8. Built-in constructor/name spelling differences

Common SML/HOL4 spellings include:

```sml
true
false
ref
NONE
SOME
```

CakeML source convention uses:

```sml
True
False
Ref
None
Some
```

This is mostly mechanical rewriting, but it affects source compatibility and pattern matching.

## 9. Real-number literals

**HOL4/SML syntax**

```sml
0.0
1.5
~0.25
```

HOL4 uses ML `real` values and decimal real literals in core libraries, metis support, TacticToe, proof search, profiling, and tooling.

**CakeML status: Source syntax absent despite internal float support.**

CakeML has an internal `Float64T` and a `Double` basis module, and `RealT` exists as a token constructor in the token datatype, but the current CakeML expression grammar does **not** include `RealT` as a literal. The current functional lexer path also reads ordinary digit sequences as integers rather than full SML real literals.

Therefore SML real-literal source is not directly accepted.

## 10. Word literals in patterns

HOL4's source AST uses one expression/pattern representation containing `WordConstant`, consistent with SML constant patterns.

**CakeML status: Restricted.**

CakeML expressions admit `<WordT>` literals, but its `Pbase` grammar lists integer, string, and character literal patterns and omits word literal patterns.

This is a smaller compatibility gap than records or modules, but it is a real grammar difference.

## 11. Rich layered patterns

Standard ML layered patterns can carry a type constraint on the binding identifier:

```sml
x : t as pat
```

HOL4's AST represents the `op`, identifier, optional type annotation, `as`, and nested pattern separately.

**CakeML status: Restricted.**

CakeML has `as` patterns and whole-pattern type annotations, but its surface `Pas` production is narrower than the full SML layered-pattern form.

## 12. Full declaration language inside `let`

Standard ML `let` contains declarations, not merely a special subset of value/function declarations.

Examples include local type/datatype/exception declarations:

```sml
let
  datatype t = A | B
  exception E
  val x = A
in
  x
end
```

HOL4's source AST stores a general declaration list in `LetInEnd`.

**CakeML status: Restricted.**

CakeML's `LetDec` grammar only permits:

- `val`
- `fun`
- `open`

The full top-level declaration grammar contains datatype, type, exception, local, and structure declarations, but these are not accepted in expression-level `let`.

## 13. Successor-ML or-pattern representation in HOL4 tooling

HOL4's `HOLSourceAST` explicitly has:

```text
Or of exp separated
```

with the comment that it represents SuccessorML-style `pat | pat | ...` or-patterns.

**CakeML status: Absent.**

This item is placed in the audit because it is explicitly part of HOL4's source-tooling language model. It should not be confused with a guaranteed requirement of every HOL4 runtime build: unlike records/functors/signatures, it is best treated as a tooling/dialect compatibility item unless a target source corpus actually uses it.
