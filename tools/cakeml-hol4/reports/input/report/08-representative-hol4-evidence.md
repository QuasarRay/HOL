# 08 — Representative checked-in HOL4 evidence

This is not a frequency count. It records representative files showing that the most important items are not hypothetical grammar trivia.

## Records and selectors

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/ScaledTests.sml` — uses `#usr` selector from a timer record and real arithmetic.
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/metis/mlibMeter.sml` — record types such as `{time : real, infs : int}`.
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/DefnBaseCore.sml` and many parser/kernel files use record patterns/expressions.

## Named signatures

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Net.sig`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Term.sig`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Type.sig`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Subst.sig`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/Abbrev.sig`

## `include` and `where type`

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Term.sig` contains an `include ... where type ... and type ...` refinement.
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Type.sig` includes a signature refined with `where type`.
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/q/QLib.sig` includes `Abbrev`.

## `eqtype`

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Subst.sig` contains `eqtype`.
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/prekernel/Nonce.sig` and Metis signatures also use equality-type specifications.

## Functors

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/floating-point/fp-functor.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/parse/LVTermNetFunctor.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/examples/l3-machine-code/lib/MutableMapFunctor.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/Holmake/toml/parseTOMLFunctor.sml`

## Sharing constraints

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/mlyacc/src/sigs.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/mlyacc/src/parse.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/examples/dev/sw/Temp.sml`

These contain `sharing type` constraints.

## `withtype`

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/Holmake/toml/TOMLvalue_dtype.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/help/src-sml/Asynt.sml`

## `abstype`

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/Rewrite.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/Thread_Data.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/Synchronized.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/Single_Assignment.sml`

## User fixity

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/tactictoe/src/tttInfix.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/metis/mlibParser.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/thm/Overlay.sml`
- multiple examples contain `infixr`.
- multiple Miller-context files contain `nonfix`.

## `val rec`

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/mlyacc/src/shrink.sml` contains bindings such as `val rec eqlist = ...`.

## SML `Match`

Representative `handle Match` uses occur in:

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/match_goal.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/Pmatch.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/Rewrite.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/Mutual.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/q/Q.sml`
- pattern-matching libraries under `src/pattern_matches/`.

## Real literals and `real`

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/ScaledTests.sml` uses `0.0`, `real`, `Real.toString`, and `Time.toReal`.
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/metis/mlibMeter.sml` uses `real`, `0.0`, `Real.fmt`, and `StringCvt`.
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/tactictoe/src/tttLearn.sml` uses real-valued timing refs such as `0.0`.

## Constructor values

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/datatype/bnfLib.sml` contains `List.map SOME ...`, demonstrating SML constructor-as-function use that CakeML's fully-applied constructor rule rejects.

## `while`

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools-poly/poly/quse.sml` uses `while ... do ...`.

## Poly/ML compiler and namespace APIs

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools-poly/holrepl.ML`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools-poly/lsp/lsp_namespace.ML`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/AI/sml_inspection/smlExecute.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/AI/sml_inspection/smlOpen.sml`

## Threads / synchronization

Representative paths include:

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/Standard_Thread.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/Synchronized.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/Multithreading.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/concurrent/Task_Queue.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/concurrent/RWLock.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools-poly/lsp/server.ML`

## Universal tags

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/Thread_Data.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/concurrent/ThreadLocal.sml`
- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools-poly/lsp/lsp_namespace.ML`

## HOL4's own exhaustive SML/HOL source AST

The strongest single inventory source is:

- `https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/parsing/HOLSourceAST.sml`

Its standard-ML side explicitly represents:

- record types, expressions, patterns, selectors, and rows;
- real literals;
- `while`;
- multi-arm `fn`;
- `val rec`;
- `withtype`;
- `abstype`;
- datatype replication;
- exception replication;
- `infix`, `infixr`, `nonfix`;
- structures, signatures, functors, sharing, `where type`;
- general signature and structure expressions.

It then adds HOL-specific quote/theory/theorem forms on top.
