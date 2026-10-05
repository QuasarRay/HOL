# Agent instructions — CakeML HOL4 self-host path

This directory follows the reuse-first, fail-closed policy used by
QuasarRay/MetaRocq-rs `.agents` and its HOL4/CakeML proof automation stack.

1. Search is not evidence. Egglog, Z3, TacticToe, MCP, and generators may
   propose proofs or rewrites, but acceptance is a direct HOL4 kernel build.
2. Machine-code claims require the exact theorem returned by CakeML's verified
   compiler-in-HOL path. Never replace this with a successful external compile.
3. The source-to-machine theorem is complete only after the HOL4-SML to CakeML
   macro/lowering relation is proved semantics preserving for every translated
   construct. Unsupported constructs fail closed.
4. Keep exact source/tool identities in the proof manifest. Do not silently
   fetch newer dependencies during a proof run.
5. Preserve progress in stacked branches/PRs. Do not duplicate an existing
   proof or generator if it can be imported or adapted from MetaRocq-rs.
6. No theorem with hypotheses, axioms, or unexpected oracle tags may be
   promoted to a release artifact.
