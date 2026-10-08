# HOL4 / SML → CakeML machine-readable gap dataset

Pinned sources:
- HOL4 `652d1f0aad5cd537ed1e5d470ba3444e70ba470e`
- CakeML `f8da03aeecd4d58a35bb88286780ff7e7e4ca7d6`
- SML97 Definition source `c4212f434cafd06669171619f7d332341a5b31f3`

Primary files:
- `authoritative-sources.json` — machine-readable source catalog.
- `hol4-sml-vs-cakeml-strict.json` — strict semantic/acceptance gaps only.
- `hol4-sml-vs-cakeml-gaps.json` — strict set plus one surface-only predefined-name spelling incompatibility.
- `hol4-sml-vs-cakeml-gaps.jsonl` — one feature object per line.
- `hol4-sml-vs-cakeml-gaps.schema.json` — JSON Schema.

The strict dataset contains 79 entries. Basis/runtime API incompatibilities are intentionally excluded.

Example filters:

```sh
jq '.features[] | select(.layer=="sml_modules")' hol4-sml-vs-cakeml-strict.json
jq '.features[] | select(.cakeml.compatibility=="semantic_mismatch")' hol4-sml-vs-cakeml-strict.json
jq '.features[] | select(.id=="M04")' hol4-sml-vs-cakeml-strict.json
```
