# HOL4 -> CakeML self-hosting path

This directory starts a fail-closed route for compiling HOL4 SML through
CakeML while preserving kernel-checked source-to-machine evidence.

The initial command is:

```sh
CAKEMLDIR=/path/to/cakeml tools/cakeml-hol4/cakeml-hol4 build \
  src/portableML/foo.sml src/bar/baz.sml
```

The frontend records every macro applied and rejects known Poly/ML/runtime
constructs without a proved lowering. The generated source is parsed and
compiled *inside HOL4* using CakeML's `eval_cake_compile_x64` path; the emitted
assembly is therefore tied to the exact compiler theorem rather than merely to
an external compiler exit status.

## Trust boundary

Egglog, Z3, TacticToe, MCP and Python/Bash generators are untrusted helpers.
A release proof must be a closed HOL4 theorem with no unexpected axioms/oracle
tags. The final self-host claim additionally needs a proved semantic bridge
from each accepted HOL4-SML macro rule to CakeML semantics, and replay of the
same release proof bundle by both the ordinary HOL4 binary and the CakeML-built
HOL4 binary.

This checkpoint intentionally does **not** claim those final obligations are
complete yet.
