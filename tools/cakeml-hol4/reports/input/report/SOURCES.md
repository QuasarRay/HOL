# Sources

## CakeML — audited revision `f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6`

- Grammar: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/gramScript.sml
- Human-readable grammar snapshot: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/grammar.txt
- Token datatype: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/tokensScript.sml
- Functional lexer: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/lexer_funScript.sml
- Parse-tree conversion: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/cmlPtreeConversionScript.sml
- Core AST: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/astScript.sml
- Type system: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/typeSystemScript.sml
- Inference implementation: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/compiler/inference/inferScript.sml
- Dynamic primitives/equality: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/semanticPrimitivesScript.sml
- User “How To” / documented SML differences: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/how-to.md
- Basis README: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/basis/README.md
- Basis dependency order/inventory: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/basis/dependency-order

### Particularly important CakeML evidence

- Current `gramScript.sml` has no record grammar, no functors, no named signatures, no `while` expression, no fixity declarations, and only restricted structure syntax.
- `cmlPtreeConversionScript.sml` parses restricted inline signature syntax but discards its content/ascription before producing `Dmod`.
- `inferScript.sml` has local-let generalization code commented out and explicitly states that non-top-level let polymorphism is not performed.
- `inferScript.sml` constrains polymorphic equality operands to one type without SML equality-kind tracking.
- `semanticPrimitivesScript.sml` defines closure equality behavior that differs from SML.
- `astScript.sml` has no record node and has only a small module declaration core.

## HOL4 — audited revision `652d1f0aad5cd537ed1e5d470ba3444e70ba470e`

- Main SML/HOL source AST: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/parsing/HOLSourceAST.sml
- AST signature: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/parsing/HOLSourceAST.sig
- SML signature/help parser grammar: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/help/src-sml/Parser.grm
- HOL keyword inventory: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/prekernel/HOLkeywords.txt
- Project README / implementation support: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/README.md

### Representative feature evidence

- Signatures: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Term.sig
- `where type`: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Type.sig
- `eqtype`: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/0/Subst.sig
- `include`: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/q/QLib.sig
- Functor: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/floating-point/fp-functor.sml
- `sharing type`: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/mlyacc/src/sigs.sml
- `withtype`: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/Holmake/toml/TOMLvalue_dtype.sml
- `abstype`: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/Rewrite.sml
- `val rec`: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/mlyacc/src/shrink.sml
- Reals/records/timing: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/1/ScaledTests.sml
- Reals/StringCvt: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/metis/mlibMeter.sml
- Partial constructor value: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/datatype/bnfLib.sml
- `while`: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools-poly/poly/quse.sml
- PolyML namespace: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools-poly/lsp/lsp_namespace.ML
- PolyML synchronization: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/src/portableML/poly/Synchronized.sml

## Methodological note

This audit intentionally prefers current executable grammar/AST/type-system source over prose documentation when they disagree. CakeML's `how-to.md`, for example, still describes `open` and signatures in older terms; the current source tree has added `open` support and restricted signature *syntax*. The source implementation shows that signature semantics remain absent in the audited path.
