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


def code_mask(raw: str) -> str:
    """Keep offsets while excluding SML nested comments and string literals."""
    out = list(raw)
    i, depth, quoted = 0, 0, False
    while i < len(raw):
        if depth:
            if raw.startswith("(*", i):
                out[i:i+2] = "  "; depth += 1; i += 2
            elif raw.startswith("*)", i):
                out[i:i+2] = "  "; depth -= 1; i += 2
            else:
                out[i] = " "; i += 1
        elif quoted:
            out[i] = " "
            if raw[i] == "\\" and i+1 < len(raw):
                if raw[i+1].isspace():
                    end = i+1
                    while end < len(raw) and raw[end].isspace(): end += 1
                    if end == len(raw) or raw[end] != "\\":
                        raise ValueError("unterminated SML string gap")
                    out[i:end+1] = " " * (end+1-i); i = end+1
                else:
                    out[i+1] = " "; i += 2
            else:
                if raw[i] == '"': quoted = False
                i += 1
        elif raw.startswith("(*", i):
            out[i:i+2] = "  "; depth = 1; i += 2
        elif raw[i] == '"':
            out[i] = " "; quoted = True; i += 1
        else:
            i += 1
    if depth or quoted:
        raise ValueError("unterminated SML comment or string literal")
    return "".join(out)


def translate(path: Path) -> tuple[str, list[dict]]:
    raw = path.read_text(encoding="utf-8")
    masked = code_mask(raw)
    for name, pattern, reason in REJECT:
        match = pattern.search(masked)
        if match:
            raise ValueError(
                f"{path}: unsupported operation {name!r} at character "
                f"{match.start()}: {reason}")
    out = raw
    applied: list[dict] = []
    for name, pattern, replacement in MACROS:
        matches = list(pattern.finditer(code_mask(out)))
        count = len(matches)
        for match in reversed(matches):
            out = out[:match.start()] + replacement + out[match.end():]
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
    manifest = {"schema": 1, "files": [], "status": "accepted",
                "claim": "lexical preflight only; semantic source correspondence is OPEN"}
    for rel in args.files:
        if Path(rel).is_absolute() or ".." in Path(rel).parts:
            raise SystemExit(f"source must be a root-relative path: {rel}")
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
        if not target.resolve().is_relative_to(out):
            raise SystemExit(f"lowered output escapes root: {rel}")
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
