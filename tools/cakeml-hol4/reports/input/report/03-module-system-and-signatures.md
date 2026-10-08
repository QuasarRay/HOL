# 03 — SML module system and signature semantics

This is the single largest structural gap between HOL4's SML and current CakeML.

HOL4 is heavily organized around `.sig` files, signatures, structures, functors, sharing constraints, and type refinement. CakeML has structures/modules and `open`, but not the Standard ML module system at comparable expressiveness.

## 1. Named signature declarations

**HOL4/SML syntax**

```sml
signature TERM =
sig
  type term
  val dest : term -> ...
end
```

HOL4 contains many `.sig` files beginning with named signatures.

**CakeML status: Absent.**

The current top-level CakeML declaration grammar has no:

```sml
signature S = ...
```

binding.

## 2. Current CakeML `:> sig ... end` is parsed but semantically inert

CakeML currently accepts a restricted syntax shaped like:

```sml
structure M :> sig
  val x : int
  type t
end = struct
  ...
end
```

But in `https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/cmlPtreeConversionScript.sml`:

- `ptree_SpecLine` returns `SOME ()`;
- `ptree_SignatureValue` returns `unit`;
- `ptree_Structure` parses the optional ascription and then constructs `Dmod sname (*asc*) ds`.

The `(*asc*)` comment is literal evidence that the parsed ascription is intentionally discarded.

**Classification: Parsed but inert.**

It does not currently enforce SML opacity, export filtering, value/type matching, abstract type identity, or signature conformance.

## 3. Transparent ascription `:`

**SML syntax**

```sml
structure M : SIG = ...
```

**CakeML status: Absent.**

The restricted CakeML structure grammar only contains optional `:>` followed by an inline signature value.

## 4. Opaque ascription `:>` semantics

**SML syntax**

```sml
structure M :> SIG = ...
```

In SML, this can hide representation and introduce fresh abstract type identity.

**CakeML status: Missing semantics.**

Although a restricted inline `:>` spelling is parsed, the ascription is discarded before the core AST.

## 5. Named signature expressions

**SML syntax**

```sml
structure M :> SIG = ...
```

where `SIG` is a previously declared signature.

**CakeML status: Absent.**

The grammar's optional signature ascription accepts an inline `sig ... end`, not an arbitrary named signature expression.

## 6. `where type` refinement

**HOL4/SML syntax**

```sml
include FinalTerm
  where type hol_type = Type_dtype.hol_type
  and type term = KernelTypes.term
```

HOL4 uses `where type` in foundational signatures.

**CakeML status: Absent.**

`WhereT` exists as a token, but current CakeML signature grammar has no `where type` signature expression.

## 7. `include` in signatures

**HOL4/SML syntax**

```sml
signature QLib =
sig
  include Abbrev
  ...
end
```

HOL4 uses `include` broadly.

**CakeML status: Absent.**

`IncludeT` is tokenized but not part of current CakeML `SpecLine`.

## 8. `eqtype` specifications

**HOL4/SML syntax**

```sml
signature S =
sig
  eqtype key
end
```

HOL4 contains real `eqtype` signatures.

**CakeML status: Absent and conceptually incompatible with CakeML's lack of equality types.**

Adding only the parser syntax would not be enough; the static type system would need equality-kind tracking.

## 9. Sharing constraints

**HOL4/SML syntax**

```sml
sharing type A.t = B.t
sharing A = B
```

HOL4's mlyacc and example/module code contains `sharing type`.

**CakeML status: Absent.**

`SharingT` is tokenized but not consumed by the current signature grammar.

## 10. Structure specifications inside signatures

**SML syntax**

```sml
signature S =
sig
  structure Table : TABLE
end
```

HOL4's source/signature parsers represent module descriptions.

**CakeML status: Absent.**

Current CakeML signature `SpecLine` only recognizes a very small set: value, type, exception, and datatype lines—and their result is currently discarded anyway.

## 11. Functors

**HOL4/SML syntax**

```sml
functor F (X : SIG) : RESULT =
struct
  ...
end
```

HOL4 uses functors in parsing, floating-point syntax, maps, mlyacc, and other infrastructure.

**CakeML status: Absent.**

There is no functor node in the current CakeML source AST or declaration grammar.

## 12. Functor parameter forms

HOL4's source AST represents both:

```sml
functor F (X : SIG) = ...
```

and inline specification arguments.

**CakeML status: Absent.**

This also means applicative/generative functor behavior and type propagation are absent.

## 13. Functor application structure expressions

**SML syntax**

```sml
structure M = F (Arg)
```

or a declaration-list argument where supported by the implementation.

HOL4's `strexp` AST has explicit functor-application constructors.

**CakeML status: Absent.**

## 14. Structure aliases

**SML syntax**

```sml
structure M = Existing
```

**CakeML status: Absent in source grammar.**

CakeML only parses:

```sml
structure M [optional restricted :> sig ... end] =
struct
  declarations
end
```

There is no general structure expression after `=`.

## 15. Structure-expression constraints

HOL4's source AST represents a structure expression followed by either `:` or `:>` signature constraint.

**CakeML status: Absent.**

Only the special top-level `structure M :> sig ... end = struct ... end` shape is recognized, and even there the constraint semantics are discarded.

## 16. `let ... in ... end` structure expressions

**SML module syntax**

```sml
let
  structure A = ...
in
  A
end
```

HOL4's `strexp` AST explicitly represents a structure-level `let`.

**CakeML status: Absent.**

## 17. Simultaneous structure bindings with `and`

HOL4's `DecStructure` stores a separated group of structure bindings.

**CakeML status: Absent.**

## 18. Richer signature specifications

HOL4's parser/tooling supports signature-level forms including:

- `val` descriptions, including grouped descriptions;
- `type` and `eqtype`;
- datatype specifications;
- datatype replication;
- exception descriptions;
- local specs;
- `open` specs in HOL4's parser;
- `include`;
- structure/module descriptions;
- sharing constraints;
- `where type` on signature expressions.

CakeML's restricted signature surface accepts only a small subset, and currently discards all of it semantically.

## Porting implication

For HOL4, signatures and functors are not cosmetic. They encode abstraction boundaries, type equalities, sharing, and reusable module construction. A source preprocessor can erase some signature syntax **only if** an independent elaboration pass first proves and materializes all type equalities/abstraction boundaries. Otherwise the resulting CakeML program does not have the same static semantics.
