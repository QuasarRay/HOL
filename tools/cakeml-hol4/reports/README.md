# Checked scope and remaining obligations

The latest slice reconstructs 38 development-kernel exports: 31 normalized
macro/generated/search theorems and seven target witnesses at the report's
exact CakeML revision. Thirteen exports extend the earlier 25. Twenty
regression tests passed under real HOL4, including startup before rejection
of open or missing theorem exports. All selected exports have no hypotheses,
no axiom tags and only ordinary DISK_THM dependency tags.

A separate source-built Trindemossen 2 kernel reconstructed all 31 macro and
search exports with recorded proof/ML API adaptations. Its tracked HOL4
sources are unchanged. Its parser-dependent report build remains blocked.
Neither a vendor-provided prebuilt binary nor a full release bundle is
qualified.

See `ordered-application.md`,
`verification-ordered-application-20261008.json` and
`ordered-application-evidence-20261008.zip` for source, binary and cache
identities, raw scripts, theory exports, statements, logs and digest bundles.
The earlier `verification-20261008.json` preserves the 25-export checkpoint
whose exports were lost during publication; those lost exports are not used
as proof evidence.

The uploaded ZIPs match the copies already retained by PR #5. `input/`
preserves both original archives and their extracted files. The current
source audit resolves 80 candidate entries (79 strict) and 16 authorities.
Source identity and lookup do not formally certify every report claim.
The report timestamp predates a cited commit; all seven cited CakeML files
differ between its report and compiler pins.

| Report obligation | Reconstructed scope | Still open |
| --- | --- | --- |
| C08 multi-arm function | Typed expansion, closure and application, with clock and exception lookup conditions | SML97 elaboration, typing, freshness and source correspondence |
| S07/S08 Match and Bind | Normalized match equivalence, preservation of a matched body's Bind, failed-case witness | SML97 exception identity and source correspondence |
| S04/S05 equality | Closure and recursive-closure equality return true in the report-pinned target model | SML static equality kinds and full reference correspondence |
| S06 evaluation order | Exception-order witnesses and nested-binding application equivalence under distinct-name and argument stability conditions | General closure-value simulation and source correspondence |
| M04 sealing | Inline signature erasure for an accepted parse tree, checked by the development kernel | Original-release parser compatibility, SML opaque sealing and generativity |
| All 79 strict gaps | Source index, obligation inventory and selected target witnesses | Complete formal report verification and language coverage |
| Machine implementation | No macro implementation binary qualified | Matching compiler correctness instance, linking and macro generator binary relation |
| Original release and CakeML-built HOL4 | Independent source reconstruction of 31 macro/search exports under a source-built original release | Vendor prebuilt replay, parser equivalence and complete release bundle |

Egglog's native Rust binding proposed two named hints; HOL4 reconstructed
the exact goals and retained the application premises. Z3_TAC reconstructed
its proof. The development TacticToe loaded 1,759 validated reused calls.
The legacy release loaded 1,503 raw hints without the newer ancestry
validation and checked its result independently. Search hints and imported
.dat files are not proof authority. The separately pinned Egglog CLI and
GitHub Actions workflow were not qualified or executed locally.

Scoped qualification disables project-wide discovery, pre-execution fetch
hooks and last-checker delegation. It rebuilds selected prerequisites with
explicit includes and reconstructs the selected proofs in fresh directories.
`materialize_release_context.py` records source identities and guarded
release adapters; its staging receipt is not a proof certificate.

Ten reused Aegis components match exact MetaRocq git objects and local bytes.
The reuse lock is preserved. PostgreSQL has no configured DSN; exposed
outcome events remain in the durable outbox, without private reasoning.

The next source proof must relate authoritative SML97 typing/elaboration,
environments, identifiers, patterns and closure values to these normalized
contracts. Complete language lowering and matching compiler evidence are
required before source-to-machine or full release claims.
