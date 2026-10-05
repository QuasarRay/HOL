#!/usr/bin/env python3
"""Fail-closed HOL4 SML -> CakeML compatibility frontend.

The frontend performs only audited lexical macros. It is not a proof authority.
Each applied macro is recorded so HOL4 theories can prove the corresponding
source semantics rule. Rejection patterns are operation-specific: portable
identifiers such as ThreadLocal and UniversalType must not be rejected merely
because their names contain a backend-specific word.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re

REJECT: list[tuple[str, re.Pattern[str], str]] = [
    ("polyml-runtime", re.compile(r"\bPolyML\s*\."),
     "Poly/ML compiler/runtime reflection has no proved CakeML lowering"),
    ("raw-thread-runtime", re.compile(r"\bThread\s*\."),
     "raw OS threads require an explicit CakeML concurrency contract"),
    ("polyml-universal-runtime", re.compile(r"\bUniversal\s*\."),
     "Poly/ML universal values require a proved representation"),
    ("process-fork", re.compile(r"\bPosix\s*\.\s*Process\s*\.\s*fork\b"),
     "process forking requires a modeled FFI"),
    ("signal-handler", re.compile(r"\bSignal\s*\.\s*signal\b"),
     "signals require a modeled FFI"),
]

MACROS: list[tuple[str, re.Pattern[str], str]] = [
    ("basis-commandline-name",
     re.compile(r"\bCommandLine\.name\s*\(\s*\)"),
     "CommandLine.name ()"),
    ("basis-commandline-arguments",
     re.compile(r"\bCommandLine\.arguments\s*\(\s*\)"),
     "CommandLine.arguments ()"),
]


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def translate(path: Path) -> tuple[str, list[dict]]:
    raw = path.read_text(encoding="utf-8")
    for name, pattern, reason in REJECT:
        match = pattern.search(raw)
        if match:
            raise ValueError(
                f"{path}: unsupported operation {name!r} at byte "
                f"{match.start()}: {reason}")
    out = raw
    applied: list[dict] = []
    for name, pattern, replacement in MACROS:
        out, count = pattern.subn(replacement, out)
        if count:
            applied.append({"rule": name, "count": count})
    return out, applied


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--root", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("files", nargs="+")
    args = p.parse_args()
    root = args.root.resolve(strict=True)
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    manifest = {"schema": 1, "files": [], "status": "accepted"}
    for rel in args.files:
        src = (root / rel).resolve(strict=True)
        if root not in src.parents and src != root:
            raise SystemExit(f"source escapes root: {rel}")
        try:
            rendered, applied = translate(src)
        except ValueError as exc:
            manifest["status"] = "rejected"
            manifest["error"] = str(exc)
            (out / "macro-manifest.json").write_text(
                json.dumps(manifest, indent=2) + "\n")
            print(exc)
            return 2
        target = out / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(rendered, encoding="utf-8")
        manifest["files"].append({
            "path": rel,
            "input_sha256": digest(src.read_bytes()),
            "output_sha256": digest(rendered.encode()),
            "macro_rules": applied,
        })
    payload = json.dumps(manifest, indent=2, sort_keys=True) + "\n"
    (out / "macro-manifest.json").write_text(payload)
    (out / "macro-manifest.sha256").write_text(
        f"{digest(payload.encode())}  macro-manifest.json\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
