# Checked scope and remaining obligations

The fresh 2026-10-08 reconstruction first verified the existing 25 theorems,
then checked 47 before discovering PR #6. The combined run checked 61:
54 macro/support/generated/search
theorems and seven target witnesses at the report's exact CakeML revision.
Twenty regression tests passed under real HOL4 without skips, including
successful runtime startup before negative inspection tests. Both complete
proof bundles, every referenced artifact and the new source identities are
retained in `.o11y/sml-proof-reconstruction-20261008/`. PR #6's application
contracts, exact-AST certificate inspection, scoped build controls and release
staging are reused. Its 203 archived artifact identities were verified;
the combined proof sources are reconstructed independently. See
`verification-20261008-reconstruction.json`. The older
`verification-20261008.json` and `observed-checks.json` retain prior outcomes.

The original ZIPs and extracted files are retained in `input/`.
`source-audit.json` checks manifest identities, cross-file agreement, 80
candidate entries (79 strict), 16 source authorities and observed HOL4 paths.
This does not formally certify every report claim. The generation timestamp
predates the cited CakeML commit, and all seven cited CakeML files differ
between the report and compiler pins.

| Report obligation | Reconstructed scope | Still open |
| --- | --- | --- |
| C08 multi-arm function | Typed expansion, closure and application, with clock and post-binding exception lookup conditions | SML97 elaboration, typing, freshness and source correspondence |
| S07/S08 Match and Bind | Normalized match equivalence, preservation of a matched body's Bind, literal failed-case witness | SML97 exception identity and source correspondence |
| S04/S05 equality | Closure and recursive-closure equality return true in the actual report-pinned target model | SML static equality kinds and full reference correspondence |
| S06 evaluation order | General left-to-right constructor/application lowering preserves effects, value order and closure environments; arbitrary sequencing agrees with the normalized derived form | Complete SML97 elaboration and source evaluation/value relation |
| M04 sealing | Inline signature is erased when converting an accepted parse tree | Acceptance, SML opaque sealing and generativity preservation |
| All 79 strict gaps | Source-index and obligation inventory | Complete formal report verification and language coverage |
| Machine implementation | No new compiler binary qualified | Compiler correctness instance, installation/linking and macro generator binary relation |
| Original release and CakeML-built HOL4 | Official Trindemossen 2 source tag independently reconstructs all 54 macro/support/generated/search exports | Vendor prebuilt replay, parser witnesses, complete release bundle and CakeML-built HOL4 |

The release inspection had a real acceptance bug: an interactive top-level
exception could be followed by a success marker and exit zero for an
`ASSUME T` theorem. The guarded inspection now exits one without success.
The preserved negative fixture and before/after logs demonstrate this boundary.

Egglog's native Rust binding checked sequencing, the inherited conditional
application, constructor-order and automatic application-order candidates
that HOL4 replayed, retaining their guards.
Z3_TAC reconstructed its proof. TacticToe loaded 1,759 validated learned calls
from the exact MetaRocq archive; missing or stale ancestry data stayed missing.
Neither search output nor an imported .dat file is proof authority.
The separately pinned Egglog CLI needs a newer Rust toolchain and is still
unqualified locally.

`qualify_gap_report.sh` rejects the compiler pin and tracked source changes,
regenerates dependency files, builds selected prerequisites with explicit
includes, reconstructs in fresh directories, inspects every export and retains
a digest bundle. The current command passed from fresh theory directories and
its complete exports were retained and verified after copying. The manual
workflow defaults to this scoped check; the existing compiler job remains
separately selectable. No GitHub Actions run is claimed.

Scoped builds preserve the selected checker with `--nolmbc`, suppress fetch
hooks and pass explicit dependency includes. Qualification refreshes generated
property-theory loader objects if they omit required parent modules, then
rebuilds the prerequisites; stale loader metadata is not accepted as success.

Ten reused Aegis components were checked against exact MetaRocq source bytes.
`.agents/reuse-lock.json` is preserved; PostgreSQL remains unavailable without
a DSN. Exposed outcome events are retained without private reasoning.

The next source proof must connect authoritative SML97 typing/elaboration,
environments, identifiers and patterns to the normalized contracts. Records,
fixity, functors, signature sealing, evaluation order and runtime contracts each
need preservation rules before complete source-to-machine or release claims.

The reused compiler compatibility recipe now supplies a structural termination
proof for the unchanged pattern-binding accumulator equations; HOL4 checked
`astTheory`. Repeated materialization preserves existing source timestamps.
The compiler dependency build hit the workspace memory limit in
`mlsexpTheory`; a bounded retry is recorded separately. No compiler correctness
instance or macro-generator machine-code theorem is claimed from these builds.
