# Checked compiler dependency induction repair

The compiler pin remains `c98da7fc904c5d6d0e9a75a18fac1796a9bfb1f9`.
This follow-up to PR #7 repairs two proof bodies in `basis/pure/mlsexpScript.sml`.
It changes no definitions, theorem statements or compiler code.

The legacy `Induct` tactic selected a single datatype induction instead of the
four mutual expression/list branches expected by `lex_aux_sexp2tree` and
`lex_aux_sexp_to_list`. The proof now selects the generated mutual induction
rules explicitly, splits their premises, and introduces/renames variables for
the existing branch proofs. The materializer verifies hashes of both original
proof bodies before applying this repair. Its complete compatibility receipt
now covers 100 files, retaining the previous 99 adaptations.

A fresh development-HOL4 source build completed in 3.4 seconds. Inspection
accepted all 74 exported `mlsexp` theorems with no hypotheses, axioms or
unexpected oracle tags; only ordinary disk-theorem import tags were allowed.
Eight relevant regression tests passed, including missing-export and open-theorem
rejection against real HOL4. Byte comparison after removing proof bodies confirms
that every definition and statement is unchanged. Evidence and source identities
are retained in `.o11y/compiler-induction-20261008/`.

A subsequent compiler-library attempt was bounded to 120 seconds and passed
12 of 93 dependency builds before timing out during `linear_scan`. No compiler
correctness instance or macro machine-code theorem was returned. A separate
original `trindemossen-2` source-built checker attempt remains blocked: the report
context has a different `mlstring` constructor API, and the pinned compiler's
own `mlstring` proof refers to `CONCAT_WITH_aux` exports absent from that original
release. Neither context was accepted as an original-release reconstruction of
this compiler dependency. The earlier PR #7 macro reconstruction scope remains
unchanged. Vendor prebuilt and CakeML-built HOL4 qualification remain OPEN.

Reproduce the bounded development check after building the pinned compiler
context's prerequisites:

```sh
HOLDIR=/path/to/built/HOL \
CAKEMLDIR=/path/to/derived/cakeml-compat \
HOL4_COMPILER_SOURCE=/path/to/clean/cakeml-compiler \
HOL4_MLSEXP_OUT=/path/to/new/mlsexp-evidence \
  tools/cakeml-hol4/qualify_compiler_mlsexp.sh
```

The command revalidates the pinned compatibility worktree, copies the proof
source into a new build directory, performs a single-job kernel reconstruction
with a 3 GiB heap cap and 120-second process limit, and inspects the fresh
exports. It refuses to reuse an existing evidence directory. The manual compiler
workflow also performs this check after building the in-logic compiler library
and uploads its evidence. The workflow was updated but was not run here.

This repair uses the first permitted automation stage: named HOL4 induction and
rewrites. Egglog, Z3_TAC and TacticToe remain available through the existing
pipeline; later search stages are unnecessary after a checked proof succeeds.
The ZIP reports remain evidence indexes, with the same selected formal witnesses
and open obligations recorded in PR #7.
