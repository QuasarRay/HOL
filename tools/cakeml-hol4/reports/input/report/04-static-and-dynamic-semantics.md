# 04 — Static and dynamic semantic mismatches

## 1. Local `let` polymorphism

Standard ML generalizes eligible local value bindings subject to the value restriction.

Example:

```sml
let
  val id = fn x => x
in
  (id 1, id "x")
end
```

**CakeML status: Semantic mismatch — local let-polymorphism is deliberately disabled.**

At the audited revision, `compiler/inference/inferScript.sml` contains commented-out generalization code for non-top-level `Let` and `Letrec`, with comments stating:

```text
Don't do polymorphism for non-top-level lets
Don't do polymorphism for non-top-level let recs
```

The active code binds local inferred types monomorphically.

Top-level declaration generalization/value restriction exists, so the precise gap is **non-top-level let polymorphism**, not “no polymorphism anywhere.”

## 2. SML equality types

SML tracks whether a type admits equality. Its surface/static language includes:

```sml
''a
eqtype t
```

and equality is rejected for function types and other non-equality types.

HOL4 signatures use `eqtype`.

**CakeML status: Semantic mismatch — equality types are absent.**

CakeML's own documentation explicitly states that it has no equality types. The inference rule for polymorphic equality constrains its two operands to have the same type but does not impose an SML equality-kind constraint.

## 3. Equality of closures/functions

SML statically rejects equality on functions.

**CakeML behavior is intentionally different.**

In `semantics/semanticPrimitivesScript.sml`, `do_eq` returns equality success for closure/recursive-closure pairs; CakeML documentation describes all closures as equal under its polymorphic equality.

So simply adding `eqtype` syntax without changing inference and equality semantics would still not reproduce SML.

## 4. Observable evaluation order

CakeML documentation specifies **right-to-left** evaluation order.

Standard ML/HOL4 code is written for SML implementation behavior and CakeML itself documents this as a difference from SML.

This matters for:

- function arguments with side effects;
- tuple/list/constructor fields with side effects;
- exception order;
- mutation through refs/arrays;
- I/O.

A port that wants behavior preservation cannot just reparse the same source. It must either change CakeML evaluation semantics or insert `let` sequencing so side-effectful subexpressions execute in the intended SML order.

## 5. `Match` versus `Bind`

SML distinguishes pattern-match failure:

- failed `val` pattern binding raises `Bind`;
- non-exhaustive `case`/`fn` match raises `Match`.

HOL4 code explicitly catches `Match`.

**CakeML status: Semantic mismatch.**

CakeML has no separate SML `Match` exception and uses its bind exception for match failure.

This is observable by handlers such as:

```sml
... handle Match => ...
```

A compatibility layer must restore the distinction if HOL4 code can observe it.

## 6. Type variables in source type annotations

CakeML's AST can represent a written type variable such as `'a`, but current inference explicitly rejects type variables in expression/pattern type annotations with the diagnostic:

```text
Type variables are not supported in type annotations.
```

HOL4 SML routinely uses source type variables in annotations and signatures.

**CakeML status: Parsed representation exists; static semantics reject the SML use.**

This is easy to miss because `Atvar` exists in the AST.

## 7. Constructor arity and first-class constructor semantics

Standard ML constructors are values and can be passed around (for a unary constructor, as a function). A constructor declared with `of t1 * t2` takes one tuple argument.

CakeML:

- uses a list of constructor arguments;
- requires constructors to be fully applied;
- uses Haskell-style declaration/application syntax.

Therefore constructor lowering must preserve:

- tupled versus multi-argument representation;
- constructor identity;
- evaluation order of constructor arguments;
- the ability to eta-expand constructor values where SML treats them as functions.

## 8. Dynamic fixity environment

In SML, parsing depends on the current fixity environment established by scoped `infix`, `infixr`, and `nonfix` declarations.

CakeML uses a fixed precedence classification derived from operator spelling.

This is a semantic front-end difference. Correct translation must run an SML-aware parser/fixity resolver before emitting CakeML syntax.

## 9. Signature abstraction and type identity

Opaque SML signature ascription and functor application can create or hide type identities.

Current CakeML's parsed inline signature has no effect on its core AST.

Therefore the following SML properties are not presently preserved by CakeML source syntax:

- representation hiding;
- fresh abstract type identities from opaque sealing;
- conformance checking;
- sharing/refinement-induced type equalities;
- export restriction.

## 10. Abstract datatype encapsulation via `abstype`

`abstype` creates a representation type whose constructor visibility is restricted to the body.

CakeML has datatypes but no `abstype` surface/semantics.

This can sometimes be encoded with a real module/signature abstraction mechanism—but CakeML currently also lacks the corresponding SML module semantics, so the usual desugaring target is unavailable.

## 11. Static semantics of grouped declarations

Forms such as simultaneous `val ... and ...`, type bindings, structure bindings, and exception descriptions have specific scope rules.

Replacing all `and` groups with sequential declarations is not automatically semantics-preserving. Any preprocessor must reproduce SML elaboration scope, not just syntax.

## 12. Signature syntax currently cannot be trusted as a compatibility boundary

Because CakeML currently discards signature specifications in parse-tree conversion, using an inline `:> sig ... end` as documentation does **not** make a port safe.

Any HOL4 bootstrap relying on module contracts must perform signature checking elsewhere or extend CakeML's verified static semantics.
