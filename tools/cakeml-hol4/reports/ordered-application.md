# Checked application order

SML97's `closapp-dyn-rule` evaluates the function before its argument. The state
convention threads effects through the premises in order; the exception
convention propagates the first exception. CakeML's `App` evaluates operands in
reverse order. Reusing the same application AST can therefore change behavior.

`Hol4SmlApplication` adds a reference that evaluates the function, evaluates the
argument in the original environment, then applies the resulting closure. It
uses CakeML's actual states, values, errors and application clock. The lowering
stores the operands in two nested `Let`s before applying their values.

The general equivalence theorem retains two conditions:

- The temporary names differ.
- Adding the function temporary preserves the argument's exact evaluation in
  every state of the same FFI type.

The stability condition is sufficient, rather than a complete freshness or
closure simulation result. A freshly constructed argument closure can capture
the extended environment even when it never uses the temporary. Generalizing
this case needs a relation between closure values and environments. The
normalized reference still needs a source correspondence proof against SML97.

The literal and unshadowed variable certificates discharge these conditions.
Their exported semantic theorems directly name the expanded AST. The library
checks both theorem tags and verifies that the semantic left-hand side contains
exactly the returned expression. Reflexive sequence expansions retain their
existing semantic proof without entering a reflexive rewrite loop.

The target witnesses also prove that the first operand's error is preserved,
that reversed evaluation can change the raised exception, and that a captured
argument can change the result. The capture witness constructs a finite
environment containing a closure of an earlier environment; it does not assume
a cyclic environment exists.

Fresh source reconstruction checked 38 exports: 31 macro/generated/search
theorems and seven report witnesses. Thirteen checked exports were added to the
existing 25. Twenty regression tests passed under the real checker, including
successful startup before rejection of open or missing theorem exports.
`ordered-application-evidence-20261008.zip` retains the theory exports, source
scripts, statements, logs, search receipts and digest bundles. The JSON receipt
records their identities. The development bundle contains 44 identified
artifacts; its sources include the explicit sequence environment self-update
proof needed by the older checker.

Egglog 14.0.0's native Rust bindings proposed both sequence and conditional
application hints. HOL4 independently reconstructed the named theorems; the
application goal retained its conditions. Z3 4.13.0 used `Z3_TAC` reconstruction.
TacticToe loaded 1,759 validated calls from the exact reused MetaRocq archive.
No pinned Egglog CLI or GitHub Actions execution is claimed.

Scoped report builds now disable project-wide scans and pre-execution hooks.
The required parser, semantics and miscellaneous dependencies are included
explicitly. This avoids an unrelated ARM snapshot fetch during qualification.

`--nolmbc` also prevents Holmake from silently delegating to the last checker
registered in a directory. Independent release checks must use separate
dependency builds rather than reuse development-generated theory objects.

The uploaded ZIPs match PR #5 byte for byte. The source audit resolves 80
entries, 79 strict entries and 16 authority files. Integrity and source lookup
do not certify the full reports. Their timestamp predates a cited commit, and
all seven cited CakeML files differ between the report and compiler revisions.
Those revisions cannot be combined into a machine-code claim without a
matching compiler reconstruction or an explicit preservation theorem.

The separate source-built Trindemossen 2 kernel at
`bdc6917eeafd45f1067c08b6061c2243c1b1edb0` reconstructed and inspected all
31 macro/generated/search exports. Its tracked HOL4 sources are unchanged;
the launcher, native runner, runtime image and build flags have separate
identities. This is independent source proof reconstruction. No
vendor-provided prebuilt binary or complete release bundle is qualified.

`materialize_release_context.py` records 67 exact input source identities and
can apply three guarded compatibility adaptations. They specialize the older
MOD_PLUS/MOD_MOD proof lemmas, alias the old `whileTheory` ML structure, and
remove two unavailable cache-tuning calls. No semantic definition or theorem
statement changes. All 67 final staged ML files match the checked release
context byte for byte.

The old TacticToe uses fixed theory filenames rather than the modern manifest.
The staging tool exports 1,759 byte-identical raw calls as untrusted hints.
The release loaded 1,503 calls, and reconstructed the resulting theorem in
its own kernel. This does not claim the newer ancestry validation for the
legacy cache. Both Egglog hints and Z3 reconstruction also passed there.

The seven report witnesses remain development-kernel results. The release
cannot load the newer parser's `temp_enable_pmatch` hook. The old
`ENABLE_PMATCH_CASES` changes ordinary case grammar, whereas the new hook
introduces a separate pmatch keyword. An attempted substitution was removed;
parser definition equivalence is not assumed. The failed attempt and removal
are recorded alongside the successful macro check.

Complete SML97 elaboration, records, modules, equality kinds, source exceptions,
runtime contracts, macro-generator machine code, parser compatibility and
CakeML-built HOL4 remain open. The report/compiler pin divergence also blocks
combining these source results with the existing compiler certificate.
