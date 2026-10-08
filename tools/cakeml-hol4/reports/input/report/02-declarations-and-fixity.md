# 02 — Declarations, recursion forms, datatypes, exceptions, and fixity

## 1. `val rec`

**HOL4/SML syntax**

```sml
val rec f =
  fn x => ...
```

HOL4's mlyacc sources contain `val rec` bindings.

**CakeML status: Absent.**

CakeML has recursive `fun`/`Dletrec`, but no `val rec` surface declaration.

## 2. Simultaneous `val ... and ...` bindings

**SML syntax**

```sml
val p1 = e1
and p2 = e2
```

HOL4's source AST represents `DecVal` as a separated set of value bindings and tracks `rec` per binding.

**CakeML status: Absent.**

CakeML's `val` declaration grammar is a single pattern/expression binding.

The semantic detail matters: simultaneous value bindings do not have the same scope behavior as simply writing sequential `val`s.

## 3. Explicit type-variable sequences on `val` and `fun`

HOL4's source AST stores an explicit `tyvars` sequence on both value and function declarations.

Representative SML-family syntax is of the form:

```sml
val 'a ...
fun 'a ...
```

**CakeML status: Absent in the declaration grammar.**

CakeML infers type variables; it does not expose the same explicit declaration-level tyvar binder syntax.

## 4. Same-function `fun` clauses and SML function-head forms

Beyond the expression-level issue discussed in the previous file, Standard ML function bindings can contain:

- several `|` clauses for the same function;
- pattern-rich heads;
- `op` forms for infix identifiers.

HOL4's `fvalarm` representation captures a sequence of function-value arms.

**CakeML status: Restricted.**

Its `FDecl` grammar is `V PbaseList1 ... = E`, with mutually recursive declarations connected by `and`.

## 5. Simultaneous type abbreviations with `and`

**SML syntax**

```sml
type a = ...
and b = ...
```

HOL4's source AST represents type bindings as a separated collection.

**CakeML status: Restricted.**

Mutually recursive `datatype ... and ...` is supported, but CakeML's ordinary `type` abbreviation grammar is one `TypeName = Type`.

## 6. `datatype ... withtype ...`

**HOL4/SML syntax**

```sml
datatype value =
    INT of int
  | TABLE of table
withtype table = (string * value) list
```

HOL4 contains actual `withtype` uses.

**CakeML status: Absent.**

`WithtypeT` exists among CakeML tokens, but the current datatype grammar does not consume it.

## 7. `abstype ... with ... end`

**HOL4/SML syntax**

```sml
abstype t = C of rep
with
  fun make x = C x
  fun view (C x) = x
end
```

HOL4 uses `abstype`, including in the rewrite engine and Poly/ML portability layer.

**CakeML status: Absent.**

The current CakeML core has no `abstype` declaration or equivalent source-level abstraction form.

## 8. Datatype replication

**SML syntax**

```sml
datatype t = datatype A.t
```

HOL4's source AST explicitly represents datatype replication (`DatvalDatatype`).

**CakeML status: Absent.**

The CakeML datatype grammar only accepts constructor lists for a newly declared datatype.

## 9. Exception replication

**SML syntax**

```sml
exception E = A.E
```

HOL4's source AST explicitly represents a new exception versus replicated exception (`ExnReplicate`).

**CakeML status: Absent.**

CakeML `exception` declarations create a new constructor; the grammar has no exception-replication branch.

## 10. Simultaneous exception declarations with `and`

HOL4's SML signature parser and source AST represent exception-description lists.

Representative syntax:

```sml
exception E of int
and F of string
```

**CakeML status: Absent.**

CakeML source `exception` handles one constructor declaration at a time.

## 11. User-defined fixity declarations

**HOL4/SML syntax**

```sml
infix 5 ++
infixr 6 **>
nonfix +
```

HOL4 contains `infix`, `infixr`, and `nonfix` declarations, including generated TacticToe fixity support and Metis/library code.

**CakeML status: Absent as SML fixity declarations.**

CakeML instead hard-codes lexical operator classes and precedence levels in its grammar:

- multiplication-like
- addition-like
- list-like
- relational
- composition/assignment
- `before`
- type annotation
- `andalso`
- `orelse`

This is a semantic parser difference, not just missing declaration sugar. In SML, fixity is part of the lexical/static parsing environment and is scoped.

A compatibility preprocessor must therefore parse HOL4 source using the **SML fixity environment first**, then emit a fully parenthesized/fixity-free CakeML form.

## 12. Multiple structures in one `open`

**SML syntax**

```sml
open A B C
```

HOL4's source AST stores a list of opened structure identifiers.

**CakeML status: Restricted.**

Current CakeML supports `open ModPath` and qualified module paths, but only one module path per `open` declaration.

This is easy to rewrite to multiple `open` declarations where the intended shadowing order is preserved.

## 13. Declaration forms that are tokenized but not implemented

At the audited CakeML revision, the token datatype includes several SML keywords whose semantics are not present in the grammar, including such names as:

- `eqtype`
- `include`
- `sharing`
- `signature`
- `where`
- `while`
- `with`
- `withtype`

Do not treat those tokens as evidence of source-language support.
