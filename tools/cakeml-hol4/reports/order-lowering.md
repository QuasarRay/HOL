# Checked operand environments and sequence lists

The automatic constructor and application macros evaluate all operands in
their original environment, then bind their results with a tuple pattern.
CakeML evaluates constructor fields in reverse order, so reversing the
capture tuple's fields produces source order. Reversing the pattern's names
restores each value to its original operand position. The final constructor
or application reads these captured values without repeating operand effects.

This preserves exact closure environments. An earlier generated `Let` binding
would extend the environment in which later operands run; PR #6 correctly
retains an argument-binding stability condition for that lowering. Its API
and proofs are preserved. The new automatic API does not extend operand
environments, and `application_reference_two` proves that its binary contract
is the same reference already established by PR #6.

`sequence_list` expands a finite prefix list to nested `Let NONE` expressions.
Its general theorem preserves state and errors and agrees with nested
wildcard cases, the normalized shape of SML97's derived sequencing form.
The constructor theorem retains the lookup/arity premise. Automatically
chosen capture names have their distinctness and length obligations checked
by HOL4 evaluation. All certificates check both proof tags and attach the
semantic equality to the exact returned expression.

These are contracts over the pinned CakeML evaluator, states and values.
SML97 prescribes the operand order and derived form, but its typing,
elaboration and value/closure correspondence to this target model are not
proved here. No complete source-language or machine-code claim follows.

The final development run reconstructs 61 selected exports; the independent
official Trindemossen 2 source build reconstructs all 54 macro/support/
generated/search exports. Both use identical project ML bytes. Twenty
inherited regression tests pass without skips. The evidence directory is
`.o11y/sml-proof-reconstruction-20261008/`; its receipts separate historical
checkpoints, the final development bundle, original-release evidence and the
incomplete compiler attempt.

Reproduce the development check with `qualify_gap_report.sh` and the explicit
pins and environment documented in the main README. For the original tag,
build its core and required `machine_ieee`, `integer_word` and `mergesort`
prerequisites and link them into its own sigobj. Stage a new context with:

```sh
python3 tools/cakeml-hol4/materialize_release_context.py \
  --source /path/to/clean-report-cakeml --output /path/to/new-context \
  --trindemossen2-proof-adapters \
  --legacy-tactictoe-cache /path/to/restored-metarocq-cache
```

The current stage records 68 inputs. Its three guarded dependency adaptations
change proofs/ML APIs, preserving semantic definitions and theorem statements.
Use the legacy hint installation procedure in the retained PR #6
`ordered-application.md`/evidence recipe; these hints remain untrusted.
Set HOLDIR to the separately built original tag, CAKEMLDIR to the staged
context, HOL_NOCONFIG=1, HOL4_Z3_EXECUTABLE to the identified solver, and both
HOL4_MACRO_REWRITES and HOL4_APPLICATION_REWRITES to the final development
candidate files. From the staged context run:

```sh
"$HOLDIR/bin/Holmake" --nolmbc --qof --no_preexecs --rebuild_deps -j2 \
  Hol4SmlMacroTheory.uo Hol4SmlApplicationTheory.uo \
  Hol4SmlOrderTheory.uo Hol4SmlMacroQualificationTheory.uo
"$HOLDIR/bin/hol" < Hol4SmlMacroInspect.sml
```

Require successful builds and `HOL4_MACRO_EXPORTS_INSPECTED 54`. Reconstruct
proof sources; importing the exports alone is insufficient. The observed
source build completed its core, while help database generation failed;
runtime startup and the selected proofs passed. No vendor prebuilt binary,
original-release parser equivalence or CakeML-built HOL4 is qualified.
