# Checked scope and remaining obligations

The uploaded archives were integrity/source audited locally. There are 80
candidate features, including 79 strict semantic or acceptance gaps. Manifest
hashes, cross-file agreement, counts and 16 exact source references passed.
This does not formally verify every report assertion.

The generation timestamp predates the cited CakeML commit. All seven cited
CakeML files differ between the report pin and the reused compiler pin.
Proofs checked at the compiler pin must not be presented as verification of
the newer report snapshot.

Eight model theorems and seven generated/automation theorems were reconstructed
by real HOL4 builds. A fresh qualification run inspected all fifteen exports
for no hypotheses, no axioms and only normal DISK_THM dependency tags. The
match contract retains exception lookup and preserves a matched body's Bind.

| Candidate obligation | Checked scope | Still open |
| --- | --- | --- |
| S07/S08 match fallback | Normalized operational equivalence; matched-body Bind preserved | SML97 source elaboration and exception identity |
| C08 multi-arm function | Typed expansion and closure construction | Freshness, application, typing and source correspondence |
| S04/S05 equality | Closure equality is true in the target model at the compiler pin | SML equality kinds and static rejection |
| Sequencing | Let NONE equals a normalized sequencing reference | SML source correspondence |
| All 79 strict gaps | Candidate obligation inventory | Complete formal report verification and language coverage |
| Machine implementation | Compiler evaluation reached assembly emission | Completed compiler artifact export and semantic composition |
| Original release | Official-source core environment built | Compatible target-theory rebuild and proof reconstruction |
| CakeML-built HOL4 | No release binary qualified | Full self-host construction and provenance |

The original-release check failed on an incompatible imported theory parent
(BoolconvContext / marker). This is not original-release acceptance. The
environment was built from the official source tag, not downloaded as an
official prebuilt binary. Loading a .dat file is also not source proof replay.

Egglog's native Rust binding selected a named sequence rewrite that HOL4
replayed. Z3_TAC reconstructed a clock lemma; learned TacticToe proved the
fallback clause count. The pinned Rust CLI bridge itself was not compiled
locally. These are search checks, not broad automation coverage of all gaps.

Twelve local regression tests passed before the execution service disconnected.
They cover literals, nested comments, string gaps, tampering and rejection
before either replay binary runs. The published report-tamper test was made
self-contained after that outage and still needs a rerun. The lexical inventory
was 210 files: 196 accepted and 14 rejected; none of those counts is formal
language coverage.

The compiler parsed the exact normalized fixture and evaluated code generation,
then failed its export guard on an obsolete API. That guard was corrected,
but the final export could not be verified after the workspace disconnected.
No completed compiler bundle or machine/reference guarantee is claimed.

The source checkpoint was preserved through GitHub after the execution
workspace became offline. The original archives, complete source-audit JSON,
exported theory .dat files, full logs and emitted assembly still need recovery.
`observed-checks.json` is an exposed outcome record, not a substitute for them.

Reuse identities are in `.agents/reuse-lock.json`. Aegis uses a durable exposed
event outbox and reports PostgreSQL as blocked when unavailable. The expensive
qualification workflow is manual-only.

The next formal work is SML97 typing/elaboration and environment correspondence;
then records, fixity, functors/signature sealing, evaluation order and runtime
contracts. Each admitted source rule needs its own preservation theorem.
Finish the compiler correctness instance and installation relation, rebuild
against the original release, and qualify the CakeML-built HOL4 binary before
closing the complete source-to-machine obligation.
