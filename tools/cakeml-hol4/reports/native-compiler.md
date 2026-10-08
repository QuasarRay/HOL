# Native CakeML compiler and checked dependency progress

The pull request stack's merge conflicts are repaired. Full HOL4 has not compiled
with CakeML. This checkpoint supplies a working native compiler, reproducible
native build commands, checked dependency repairs, and exact rejection evidence.

PRs #5–#8 now contain their updated bases through ordinary merge commits;
the upstream kernel, parser and editor changes were retained. The audited
downstream implementations were retained in the 13 conflicting paths. The
conflict repair passed 20 regression tests. It did not rebuild the new upstream
kernel or replace the identities of earlier proof checkers.

CakeML v3213's vendor archive has SHA-256
`e99dc1cdb9e28366f78c7c4ef812dbaab6710eb301ae8c85d1b6ce2a2161b728`.
Its native compiler advertises CakeML commit
`c98da7fc904c5d6d0e9a75a18fac1796a9bfb1f9` and bootstrap HOL commit
`b725f6e8834462a5b4bb2fb67b35e36f368cb8b6`. The bootstrap version string also
records Poly/ML 5.9; Poly/ML is not invoked by the native preparation or compile
adapter. Observed ELF dependencies contain libc, libm and the system loader.
Archive identity, version output and successful execution do not independently
replay the vendor compiler's source-to-binary proof.

The native compiler compiled and linked the normalized matching fixture. The
observable fixture printed `20` and exited successfully. Its assembly and
executable bytes are retained in the evidence ZIP, together with source, logs
and digests. The adapter rejects foreign advertised pins, successful exit with
empty assembly, reused output directories, and build timeouts. These results
have status `NATIVE_COMPILED_UNQUALIFIED` and contain no semantic proof claim.
All 31 regression tests passed without skips, including the real native compile,
execution, kernel-source rejection and failed-host-build gate.

Compiling unchanged `src/0/KernelTypes.sml` failed with a parser error. Separate
minimal source probes accepted a structure and CakeML's constructor syntax,
and rejected SML `of` constructors, records, signatures, `open` and functors.
The kernel error therefore must not be interpreted as absence of all structure
support. A masked lexical inventory of 171 core SML files found record syntax
in 76 files, `open` in 72, opaque signature annotations in 109, and functors in
two. Counts identify candidate source occurrences; they are not typing,
parsing or semantic-preservation theorems. The existing lexical frontend and
normalized AST macros do not yet implement these source elaboration rules.

The development-checker compatibility recipe now includes two further
proof-only repairs. Pattern accumulator induction generalizes its accumulator
before induction and uses bounded rewrite passes. Type-system proofs use
derived expression/list induction rules. Hash guards reject altered source,
and regression checks confirm that original definition text and theorem
contracts remain unchanged after removing proof bodies and the two added
derived helper rules. Rebuilding accepted 77 `semanticPrimitivesProps` and
96 `typeSysProps` theorem exports with no hypotheses, axioms or unexpected
oracle tags. Ordinary disk-theorem import tags were allowed. This scope is
the development checker and its generated datatype definitions.

The development compiler build subsequently stopped in `closLang`: its legacy
`exp1_size` auxiliary constant is absent under the new datatype package. A
direct constant-identity inspection confirmed the missing declaration. No
replacement definition or altered compiler theorem was accepted. A separate
clean checker was built from the release-recorded HOL source pin to reconstruct
the unchanged compiler context. That checker is a source-built bootstrap
environment; it is not an original vendor HOL executable or CakeML-built HOL4.
The aggregate optional host build was interrupted after the core was available;
the pinned build adapter reconstructs only its explicit compiler prerequisites.

The official Trindemossen 2 archive was also downloaded and checked against its
published SHA-256 `0a2cba21a07b2eac0a9593a7130d47d48715a122ff6df6d0c6858f7190f71f7c`.
Inspection of its 11,065 entries found three bundled Windows solver/library
executables and no HOL checker executable. That archive cannot supply the
original checker binary required by the release gate. Earlier independent
source-built original-tag replay remains the narrower accepted scope.

Evidence lives in `.o11y/cakeml-native-build-20261008/`. The manifest records
retained bytes, sources, proof exports, native observations and failures.
The compatibility receipt covers 102 adapted files with patch SHA-256
`7d528ca0aa8ed63d0a37b756c7a3dc85a5235b3a2674500e1f781a5b9dc59c8b`.
Named HOL induction and rewrites succeeded, so the existing proof-search policy
did not invoke later Z3_TAC or TacticToe stages for these repairs. Earlier
Egglog, Z3_TAC, TacticToe reuse and original-tag macro replay remain intact.

To reproduce the native path without invoking Poly/ML:

```sh
curl --fail --location \
  https://github.com/CakeML/cakeml/releases/download/v3213/cake-x64-64.tar.gz \
  --output /tmp/cake-x64-64.tar.gz
python3 tools/cakeml-hol4/prepare_native.py \
  --archive /tmp/cake-x64-64.tar.gz --out /tmp/new-native-release
python3 tools/cakeml-hol4/build_native.py --root . \
  --compiler /tmp/new-native-release/cake-x64-64/cake \
  --ffi /tmp/new-native-release/cake-x64-64/basis_ffi.c \
  --out /tmp/new-native-program tools/cakeml-hol4/fixtures/native-result.cml
CML_HEAP_SIZE=256 CML_STACK_SIZE=32 /tmp/new-native-program/program
```

The manual workflow's `native-compiler` target repeats these native observations
and retains the expected HOL4 kernel rejection. It was not dispatched here.
For checked compiler reconstruction, build a clean bootstrap HOL checker at
the recorded HOL pin, then run:

```sh
HOLDIR=/path/to/built/release-matched-HOL \
CAKEMLDIR=/path/to/clean/c98da7fc-cakeml \
HOL4_PINNED_COMPILER_OUT=/path/to/new/compiler-evidence \
  bash tools/cakeml-hol4/build_pinned_compiler.sh
```

The requested final source-to-machine bridge, macro-generator implementation
binary proof, original vendor HOL replay and CakeML-built HOL4 replay remain
OPEN. Missing source elaboration, portable basis/runtime implementations and a
CakeML build/loading backend must be supplied before claiming full HOL4 success.
