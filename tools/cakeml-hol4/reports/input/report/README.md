# HOL4 SML vs CakeML: comprehensive language-gap audit

**Snapshot date:** 2026-10-07  
**CakeML revision:** `f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6`  
**HOL4 revision:** `652d1f0aad5cd537ed1e5d470ba3444e70ba470e`

This collection inventories Standard ML language semantics and syntax that are present in the HOL4 ecosystem but are absent, restricted, semantically different, or only superficially parsed by the current CakeML source language.

The central rule used throughout this audit is:

> A CakeML lexer token is **not** evidence that the corresponding SML feature exists. A feature counts as supported only when the current CakeML grammar, parse-tree conversion, type inference/static semantics, and dynamic semantics collectively implement it.

That distinction matters. For example, current CakeML tokenizes several SML keywords that its grammar does not consume. More importantly, it parses a small inline signature form after `:>`, but the parse-tree conversion discards the signature and its specification lines, so the syntax currently has no SML signature semantics.

## Contents

- [00-scope-method-and-snapshots.md](00-scope-method-and-snapshots.md) — scope, evidence model, and source snapshots.
- [01-core-expressions-patterns-and-types.md](01-core-expressions-patterns-and-types.md) — records, `while`, function clauses, real literals, constructor syntax, pattern forms, and `let` declaration gaps.
- [02-declarations-and-fixity.md](02-declarations-and-fixity.md) — `val rec`, simultaneous declarations, `withtype`, `abstype`, replication, fixity declarations, and related declaration syntax.
- [03-module-system-and-signatures.md](03-module-system-and-signatures.md) — signatures, functors, sharing, `where type`, `include`, structure expressions/specifications, and the current parsed-but-inert CakeML signature syntax.
- [04-static-and-dynamic-semantics.md](04-static-and-dynamic-semantics.md) — let-polymorphism, equality types, equality semantics, evaluation order, `Match`, constructor arity, and abstraction/generativity.
- [05-hol4-language-extensions.md](05-hol4-language-extensions.md) — HOL4 quotation/declaration syntax and implementation-specific SML dialect features that are outside ordinary Standard ML.
- [06-polyml-mosml-basis-and-runtime-gaps.md](06-polyml-mosml-basis-and-runtime-gaps.md) — important ecosystem dependencies that are not core SML syntax but block a direct HOL4-on-CakeML port.
- [07-exhaustive-feature-matrix.md](07-exhaustive-feature-matrix.md) — compact master matrix of every identified gap.
- [08-representative-hol4-evidence.md](08-representative-hol4-evidence.md) — concrete checked-in HOL4 examples and paths.
- [09-porting-priority-and-desugaring.md](09-porting-priority-and-desugaring.md) — which gaps can be syntax-lowered and which require genuine CakeML semantic work.
- [SOURCES.md](SOURCES.md) — exact primary-source files and permalinks.

## Bottom line

A direct “compile HOL4 SML with the CakeML compiler” path is blocked by much more than records or functors. The largest semantic blockers are:

1. the SML module system, especially **real signature semantics and functors**;
2. **records**;
3. **local let-polymorphism** and SML **equality types**;
4. Standard-ML constructor semantics, including **`of` syntax and first-class/partial constructor use**;
5. SML declaration forms such as `withtype`, `abstype`, fixity declarations, replication, and richer mutually-recursive bindings;
6. SML **left-to-right** observable evaluation behavior versus CakeML's **right-to-left** evaluation;
7. the SML `Match`/`Bind` distinction;
8. HOL4's own quotation/declaration language and its Poly/ML/Moscow-ML runtime infrastructure.

Many surface forms can be macro-expanded into CakeML. Several of the items above cannot be made source-compatible by macros alone without also preserving static or dynamic semantics.
