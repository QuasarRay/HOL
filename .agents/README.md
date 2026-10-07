# Aegis for the HOL4 SML/CakeML compatibility project

This adapter reuses MetaRocq-rs PostgreSQL event sourcing, durable outbox,
logical exports, and filesystem confinement. `reuse-lock.json` records the
exact source commit and bytes. It performs no agent dispatch or model calls.

The authoritative project contract is SML97 plus the pinned HOL4 dialect;
CakeML operational semantics and its verified compiler are the target.
Uploaded reports are untrusted evidence indexes. A source lookup, successful
parser, imported theory file or Egglog result is not a semantic proof.

Use the task-scoped `database.store.Store` to capture exposed commands,
verification outcomes and blockers. Export the entire database after each
event; preserve `data/` in every checkpoint. Private internal reasoning is
not a logging input. Use a separate database for this project.

Progress is sequential and reuse-first. Proof search uses named HOL4 rewrites,
then proof-reconstructing Z3_TAC, then bounded TacticToe; do not execute a
later search after an earlier checked success. Report scope, assumptions,
source pins and artifact digests. Unsupported language features remain OPEN.
Whole-HOL4 claims require the full source-to-machine bridge and qualified
replay by the original release and CakeML-built HOL4 binaries.
