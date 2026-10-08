# HOL4 -> CakeML self-hosting path

This directory implements a fail-closed route for compiling HOL4 SML through
CakeML while preserving kernel-checked source-to-machine evidence.

The build entry point is one command:

```sh
CAKEMLDIR=/path/to/cakeml tools/cakeml-hol4/cakeml-hol4 build \
  src/portableML/foo.sml src/bar/baz.sml
```

The frontend records every macro applied and rejects known Poly/ML/runtime
constructs without a proved lowering. The generated source is parsed and
compiled *inside HOL4* using CakeML's `eval_cake_compile_x64` path; the emitted
assembly is therefore tied to the exact compiler theorem rather than merely to
an external compiler exit status.

## Coverage inventory

Before claiming whole-HOL4 coverage, inventory the source tree:

```sh
python3 tools/cakeml-hol4/inventory.py --root . \
  --out hol4-cakeml-inventory.json \
  src/portableML src/0 src/1 src/thm
```

This inventory is deliberately only a lexical preflight. A file is not counted
as formally supported until its generated CakeML source parses and its lowering
rules have HOL4 semantics-preservation theorems.

## Proof-search acceleration

`egglog-bridge` uses the pinned Rust Egglog engine only to decide which
already-named HOL4 rewrite theorems are worth replaying. `Hol4ProofSearchLib`
then constructs the theorem inside HOL4. If that route fails it can try
`HolSmtLib.Z3_TAC` and `tacticToe.ttt`. Every accepted result is checked for
the exact goal, no hypotheses, no axioms, and no unexpected oracle tags.

## Release gate

`proof_bundle.py` binds the final theorem files and machine artifacts by
SHA-256. `dual_replay.py` feeds `formal/Hol4ProofBundleReplay.sml` to both
the ordinary HOL4 executable and the CakeML-built HOL4 executable and requires
the same bundle digest and closed theorem to be accepted by both.

A `CHECKED` dual-replay receipt is required before a generated executable may
be called the formally verified HOL4 self-host binary.

## Trust boundary

Egglog, Z3, TacticToe, MCP and Python/Bash generators are untrusted helpers.
A release proof must be a closed HOL4 theorem with no unexpected axioms/oracle
tags. The final self-host claim additionally needs a proved semantic bridge
from each accepted HOL4-SML macro rule to CakeML semantics, and replay of the
same release proof bundle by both the ordinary HOL4 binary and the CakeML-built
HOL4 binary.

The infrastructure fails closed while any of those obligations remain open.
