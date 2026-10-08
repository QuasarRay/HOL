# 00 — Scope, method, and source snapshots

## What “exists in HOL4” means here

This audit uses three confidence classes.

### A. Observed in checked-in HOL4 code

The feature appears in executable `.sml`, `.ML`, `.sig`, parser/tooling source, or the build/runtime layer of the checked-in HOL4 tree. Representative paths are recorded in the evidence file.

### B. Explicitly represented by HOL4's own SML source parser

HOL4's `tools/parsing/HOLSourceAST.sml` is unusually valuable for completeness because it enumerates the SML/HOL surface forms that HOL4 tooling understands. This includes forms that are uncommon in the main kernel but still belong to the accepted source ecosystem.

### C. Implementation/runtime facility

Poly/ML- or Moscow-ML-specific APIs used by HOL4 are listed separately. These are **not** claimed to be missing SML language constructs; they are ecosystem compatibility gaps.

## CakeML support test

For every feature, the audit checks as applicable:

1. `semantics/tokensScript.sml`
2. `semantics/lexer_funScript.sml`
3. `semantics/gramScript.sml`
4. `semantics/cmlPtreeConversionScript.sml`
5. `semantics/astScript.sml`
6. `compiler/inference/inferScript.sml`
7. `semantics/typeSystemScript.sml`
8. `semantics/semanticPrimitivesScript.sml`
9. the current basis-library inventory.

A keyword appearing in `tokensScript.sml` but nowhere in the grammar is classified as **not supported**.

## Important freshness correction

Older CakeML documentation says that CakeML lacks `open` and signatures. That is no longer an accurate description of the **parser** at the audited revision.

Current CakeML does support a restricted `open ModPath` declaration and carries it to `Dopen`; it also has expression-local `Open`.

Current CakeML also recognizes this restricted structure syntax:

```sml
structure M :> sig
  ...
end = struct
  ...
end
```

However, the current parse-tree conversion:

- converts every signature specification to `unit`,
- converts the signature value itself to `unit`, and
- explicitly drops the parsed ascription when producing `Dmod`.

Therefore this is classified as **parsed but semantically inert**, not as implemented SML signature sealing.

## Primary snapshot links

- CakeML grammar: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/gramScript.sml
- CakeML parse-tree conversion: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/cmlPtreeConversionScript.sml
- CakeML AST: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/astScript.sml
- CakeML inference: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/compiler/inference/inferScript.sml
- CakeML semantics: https://github.com/CakeML/cakeml/blob/f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6/semantics/semanticPrimitivesScript.sml
- HOL4 SML/HOL AST: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/tools/parsing/HOLSourceAST.sml
- HOL4 SML signature parser: https://github.com/HOL-Theorem-Prover/HOL/blob/652d1f0aad5cd537ed1e5d470ba3444e70ba470e/help/src-sml/Parser.grm

## Status vocabulary

| Status | Meaning |
|---|---|
| **Absent** | Current CakeML source grammar/semantics has no corresponding construct. |
| **Restricted** | CakeML has a related construct but accepts a materially smaller language. |
| **Parsed but inert** | Surface syntax is accepted but the SML meaning is discarded/not enforced. |
| **Semantic mismatch** | Similar syntax exists, but observable static/dynamic behavior differs. |
| **Basis/runtime gap** | Not a core language construct; an ecosystem API/runtime capability is absent or non-compatible. |
