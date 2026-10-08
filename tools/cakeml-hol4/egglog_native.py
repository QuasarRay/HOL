#!/usr/bin/env python3
"""Bounded search using Egglog's native Rust bindings; HOL4 replay is required."""
import argparse
import hashlib
import importlib.metadata
import json
from pathlib import Path
import sys


def candidates(rules, lhs, rhs, rounds):
    import egglog.bindings as bindings
    rows = [line.split("\t") for line in rules.read_text().splitlines() if line and not line.startswith("#")]
    if not rows or any(len(row) != 3 for row in rows):
        raise ValueError("expected nonempty name<TAB>lhs<TAB>rhs rewrite table")
    g = bindings.EGraph()
    program = '(datatype Term (Var String) (Const String) (App Term Term))\n'
    program += ''.join(f'(rewrite {l} {r})\n' for _, l, r in rows)
    # Inputs must exist before saturation, rather than being created by check.
    program += f'(let $lhs {lhs})\n(let $rhs {rhs})\n(run {rounds})\n(check (= $lhs $rhs))\n'
    g.run_program(*g.parse_program(program))
    return [r[0] for r in rows], {"schema": 1, "status": "CANDIDATE",
        "package": "egglog", "version": importlib.metadata.version("egglog"), "engine": "native Rust bindings",
        "native_sha256": hashlib.sha256(Path(bindings.__file__).read_bytes()).hexdigest(),
        "program_sha256": hashlib.sha256(program.encode()).hexdigest(),
        "rules_sha256": hashlib.sha256(rules.read_bytes()).hexdigest(), "round_limit": rounds,
        "claim": "untrusted search hint; not the pinned CLI; HOL4 replay required"}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--rules", type=Path, required=True)
    p.add_argument("--lhs", required=True)
    p.add_argument("--rhs", required=True)
    p.add_argument("--rounds", type=int, default=8)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--receipt", type=Path, required=True)
    a = p.parse_args()
    a.out.unlink(missing_ok=True)
    try:
        if not 1 <= a.rounds <= 100:
            raise ValueError("round bound must be 1..100")
        names, receipt = candidates(a.rules, a.lhs, a.rhs, a.rounds)
        a.out.write_text("\n".join(names) + "\n")
        a.receipt.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    except Exception as exc:
        a.receipt.write_text(json.dumps({"status": "REJECTED", "error": str(exc), "claim": "search only"}, indent=2) + "\n")
        print(f"egglog-native: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
