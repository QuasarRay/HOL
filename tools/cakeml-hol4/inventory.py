#!/usr/bin/env python3
"""Inventory HOL4 SML against the fail-closed CakeML compatibility frontend.

This is a lexical/source preflight only. Acceptance here does not imply CakeML
parsing, type checking, semantics preservation, or successful compilation.
Those are separate HOL4-kernel-checked gates.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from macro_frontend import translate


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--root", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--strict", action="store_true")
    p.add_argument("roots", nargs="+", help="repo-relative files/directories")
    args = p.parse_args()
    root = args.root.resolve(strict=True)

    files: set[Path] = set()
    for rel in args.roots:
        item = (root / rel).resolve(strict=True)
        if root not in item.parents and item != root:
            raise SystemExit(f"inventory root escapes repository: {rel}")
        if item.is_file() and item.suffix == ".sml":
            files.add(item)
        elif item.is_dir():
            files.update(x for x in item.rglob("*.sml") if x.is_file())

    accepted, rejected = [], []
    for path in sorted(files):
        rel = str(path.relative_to(root))
        try:
            rendered, macros = translate(path)
            accepted.append({
                "path": rel,
                "input_sha256": sha256(path.read_bytes()),
                "translated_sha256": sha256(rendered.encode()),
                "macro_rules": macros,
            })
        except ValueError as exc:
            rejected.append({"path": rel, "reason": str(exc)})

    result = {
        "schema": 1,
        "claim": "lexical compatibility preflight only; not proof evidence",
        "total": len(files),
        "accepted": len(accepted),
        "rejected": len(rejected),
        "accepted_files": accepted,
        "rejected_files": rejected,
    }
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({k: result[k] for k in ("total", "accepted", "rejected")}))
    return 2 if args.strict and rejected else 0


if __name__ == "__main__":
    raise SystemExit(main())
