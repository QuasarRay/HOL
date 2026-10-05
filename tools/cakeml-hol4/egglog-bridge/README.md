# Egglog candidate bridge

This executable is an **untrusted search accelerator**. It asks a pinned Egglog
binary whether a goal equality is in the e-graph generated from a selected set
of already named HOL4 rewrite theorems. When Egglog succeeds, the bridge writes
only those HOL4 theorem names. `Hol4ProofSearchLib` then fetches those theorem
objects from the HOL4 database and replays the rewrite inside HOL4.

The accepted theorem is therefore created by the HOL4 kernel. Egglog output is
never imported as a theorem, proof certificate, axiom, or oracle.

Rule file format:

```
Theory.theorem<TAB><egglog Term lhs><TAB><egglog Term rhs>
```

The Egglog pin is recorded in `../proof-search.json`. The caller is responsible
for verifying that the executable came from that exact source revision.
