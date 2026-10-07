# HOL4 SML through checked CakeML macros

The full HOL4 SML frontend and self-hosting theorem remain OPEN.
See `reports/README.md` and `reports/observed-checks.json` for checked scope,
pins, observed results and blockers.

`Hol4SmlMacroLib` expands typed AST terms and returns an expansion theorem and
a normalized semantic theorem. Matching retains the exception lookup condition
and preserves an explicit Bind from a matched body. Multi-arm function
certificates prove closure construction; SML97 typing, elaboration, freshness
and application correspondence need further proofs.

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
relation, or macro implementation binary correctness. Final artifact export
verification is pending after the execution outage.

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
