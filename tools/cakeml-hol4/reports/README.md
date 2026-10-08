# Checked scope and remaining obligations

The 2026-10-08 run reconstructed and inspected 25 HOL4 theorems: 18
normalized macro/generated/search theorems and seven target witnesses at the
report's exact CakeML revision. Twenty regression tests passed under real HOL4,
including a successful runtime startup before negative inspection tests.
These are observed outcomes. The workspace transport closed during evidence
packaging; complete new theory exports and logs remain unavailable for
publication. See `verification-20261008.json`. The older
`observed-checks.json` retains the previous session's outcomes.

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
| S06 evaluation order | Tuple operands raise the second exception; explicit sequencing raises the first; distinct outcomes are proved | Complete source evaluation relation and general argument-order lowering |
| M04 sealing | Inline signature is erased when converting an accepted parse tree | Acceptance, SML opaque sealing and generativity preservation |
| All 79 strict gaps | Source-index and obligation inventory | Complete formal report verification and language coverage |
| Machine implementation | No new compiler binary qualified | Compiler correctness instance, installation/linking and macro generator binary relation |
| Original release and CakeML-built HOL4 | No original prebuilt or self-hosted binary qualified | Independent compatible source proof reconstruction and provenance |

The release inspection had a real acceptance bug: an interactive top-level
exception could be followed by a success marker and exit zero for an
`ASSUME T` theorem. The guarded inspection now exits one without success.
The preserved negative fixture and before/after logs demonstrate this boundary.

Egglog's native Rust binding selected a named rewrite that HOL4 replayed.
Z3_TAC reconstructed its proof. TacticToe loaded 1,759 validated learned calls
from the exact MetaRocq archive; missing or stale ancestry data stayed missing.
Neither search output nor an imported .dat file is proof authority.
The separately pinned Egglog CLI needs a newer Rust toolchain and is still
unqualified locally.

`qualify_gap_report.sh` rejects the compiler pin and tracked source changes,
regenerates dependency files, builds selected prerequisites with explicit
includes, reconstructs in fresh directories, inspects every export and retains
a digest bundle. Its final metadata additions and the published checkpoint need
a fresh run after execution recovery. The manual workflow now defaults to this
scoped check; the existing compiler job remains separately selectable. No
GitHub Actions run is claimed.

Ten reused Aegis components were checked against exact MetaRocq source bytes.
`.agents/reuse-lock.json` is preserved; PostgreSQL remains unavailable without
a DSN. Exposed outcome events are retained without private reasoning.

The next source proof must connect authoritative SML97 typing/elaboration,
environments, identifiers and patterns to the normalized contracts. Records,
fixity, functors, signature sealing, evaluation order and runtime contracts each
need preservation rules before complete source-to-machine or release claims.
