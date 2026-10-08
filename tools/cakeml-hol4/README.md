# HOL4 SML through checked CakeML macros

The full HOL4 SML frontend and self-hosting theorem remain OPEN.
See `reports/README.md` and `reports/verification-20261008-reconstruction.json`
for current scope, pins, retained proof artifacts and blockers. The older
`verification-20261008.json` records the previous source checkpoint.

`Hol4SmlMacroLib` expands typed AST terms and returns an expansion theorem and
a normalized semantic theorem. Matching retains the exception lookup condition
and preserves an explicit Bind from a matched body. Multi-arm function
certificates cover closure construction and application, including clock and
post-binding exception lookup conditions. SML97 typing, elaboration, freshness
and source correspondence remain open.

PR #6's `left_application` API and its argument-binding stability condition
are preserved. Certificates check both proofs, rewrite the semantics to the
returned AST and require that exact AST on the evaluator's left-hand side.

The library also generates arbitrary finite sequencing, left-to-right
constructor operands and left-to-right function application. `Hol4SmlOrder`
proves these expansions against normalized reference evaluators, preserving
state, errors, clock behavior and operand value order. Sequencing also agrees
with SML97's nested wildcard-case derived form in the target evaluator.
Operands run in their original environment before a tuple pattern captures
their values; generated names therefore cannot capture source closures.
The constructor theorem retains the constructor lookup/arity check. These
contracts still need the SML97 elaboration and source-value correspondence.
The automatic application API reuses `Hol4SmlApplication`'s reference through
the checked `application_reference_two` theorem.

`Hol4ProofSearchLib` tries named rewrite hints, proof-reconstructing Z3_TAC,
then bounded learned TacticToe. It checks the exact goal, hypotheses, axioms and
oracle tags before accepting a result, and stops after the first checked success.
The Egglog bridge seeds inputs before saturation. The native Rust binding
alternative records its own version/digest and never impersonates the pinned CLI.

With explicit, prebuilt dependencies and an audited reused TacticToe cache:

```sh
export HOLDIR=/path/to/built/hol4 CAKEMLDIR=/path/to/built/cakeml
export HOL4_Z3_EXECUTABLE=/path/to/z3 HOL4_TACTICTOE_CACHE=/path/to/cache
export HOL4_EGGLOG_PYTHON=/path/to/python-with-egglog
tools/cakeml-hol4/qualify_macros.sh
```

Every qualification uses a fresh theory directory because environment-selected
candidates/search configuration are not Holmake dependencies. The command
retains theorem exports, statements, logs and checksums. The observed local
native binding version was egglog 14.0.0. No dependency is fetched by this command.

A clean report-pinned CakeML checkout and the pinned SML97 source allow scoped
report reconstruction:

```sh
python3 tools/cakeml-hol4/restore_tactictoe_cache.py \
  --metarocq-source /path/to/metarocq --output /path/to/new-cache
export SML97DIR=/path/to/sml97 HOL4_TACTICTOE_CACHE=/path/to/new-cache
tools/cakeml-hol4/qualify_gap_report.sh
```

The integrated local qualification reconstructed and inspected 61 theorems:
54 macro/support/generated/search theorems and seven target report witnesses.
All 20 regression tests passed without skips under the real HOL4 runtime.
Complete theory exports, proof-source copies, logs and digest manifests are
retained in `.o11y/sml-proof-reconstruction-20261008/`. The manual workflow has
a scoped report job and a separate compiler job; it does not run on every
source checkpoint.

An independent source build of the official Trindemossen 2 tag reconstructed
and inspected all 54 macro/support/generated/search theorems using identical
project ML sources. Its three recorded CakeML dependency adaptations change
proofs/ML APIs only. The seven report witnesses remain development-kernel
results because their shared theory needs an incompatible parser hook. Vendor
prebuilt replay remains open. See the reconstruction report for both checkers'
binary identities and the original-release reproduction commands.

The uploaded reports can be re-audited after restoring their extracted files
as sibling `machine/` and `report/` directories:

```sh
python3 tools/cakeml-hol4/audit_reports.py --inputs /path/to/extracted-reports \
  --hol4-source . --cakeml-source /path/to/report-cakeml \
  --sml97-source /path/to/sml97 --out /tmp/source-audit.json
```

This checks integrity, references and selected source observations; it is not a
formal proof of the reports. Keep the report and compiler revisions separate.

`macro_frontend.py` performs lexical preflight and whitespace normalization.
It masks strings/nested comments, rejects specific unsupported runtime operations,
confines paths and records changes. It is not a complete parser or verified
translator. `inventory.py` likewise reports lexical coverage.

```sh
CAKEMLDIR=/path/to/built/cakeml HOLDIR=/path/to/built/hol4 \
  tools/cakeml-hol4/cakeml-hol4 build tools/cakeml-hol4/fixtures/match.cml
```

The compiler path evaluates CakeML's lexer/parser and compiler inside HOL4.
Fresh directories prevent stale theorem reuse; failed parsing, TRUTH-only
results, missing theory exports and empty assembly are rejected. Compiler
evaluation alone does not supply the SML bridge, machine installation/linking
relation, or macro implementation binary correctness. The current compiler
attempt remains unqualified; its compatibility and resource-limit outcomes
are recorded in the reconstruction report.

`proof_bundle.py` checks confined, regular artifact identities before either
executable runs. `dual_replay.py` rejects identical executable bytes and records
DUAL_THEORY_IMPORT_OBSERVED, not a verified release. Importing .dat theories
does not reconstruct proofs or establish binary provenance. A release needs
complete source preservation and independently reconstructed proofs under
identified original-release and CakeML-built HOL4 environments.

```sh
python3 -m unittest discover -s tools/cakeml-hol4 -p 'test_*.py' -v
```

The adapted MetaRocq Aegis event store, confinement and durable outbox are
source-locked in `.agents`. PostgreSQL unavailability remains explicit.
The expensive qualification workflow is manual-only and checks normalized
constructs, not complete HOL4 self-hosting.
