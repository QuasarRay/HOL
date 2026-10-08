#!/usr/bin/env python3
"""Create or verify an immutable HOL4 self-host proof-bundle manifest.

The manifest binds theorem/proof files and machine artifacts by digest. It does
not prove them. Release acceptance additionally requires replay by both the
ordinary HOL4 executable and the CakeML-built HOL4 executable.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def confined(root: Path, rel: str) -> Path:
    p = (root / rel).resolve(strict=True)
    if p != root and root not in p.parents:
        raise ValueError(f"artifact escapes bundle root: {rel}")
    if p.is_symlink():
        raise ValueError(f"symlink artifact rejected: {rel}")
    return p


def build(root: Path, theorem: str, artifacts: list[str], out: Path) -> None:
    if theorem.count(".") != 1:
        raise ValueError("release theorem must be Theory.theorem")
    entries = []
    for rel in sorted(set(artifacts)):
        p = confined(root, rel)
        if not p.is_file():
            raise ValueError(f"not a regular file: {rel}")
        entries.append({"path": rel, "size": p.stat().st_size, "sha256": sha256(p)})
    payload = {
        "schema": 1,
        "release_theorem": theorem,
        "artifacts": entries,
        "acceptance": [
            "all artifact digests verify",
            "release theorem is closed and has no unexpected HOL4 oracle/axiom tags",
            "ordinary HOL4 binary replays release theorem",
            "CakeML-built HOL4 binary replays the identical release theorem and bundle",
        ],
        "claim": "digest manifest only until both binary replay receipts succeed",
    }
    out.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")


def verify(root: Path, manifest: Path) -> None:
    data = json.loads(manifest.read_text())
    if data.get("schema") != 1:
        raise ValueError("unsupported proof-bundle schema")
    for item in data.get("artifacts", []):
        p = confined(root, item["path"])
        if p.stat().st_size != item["size"] or sha256(p) != item["sha256"]:
            raise ValueError(f"artifact identity mismatch: {item['path']}")


def main() -> int:
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build")
    b.add_argument("--root", type=Path, required=True)
    b.add_argument("--theorem", required=True)
    b.add_argument("--artifact", action="append", default=[])
    b.add_argument("--out", type=Path, required=True)
    v = sub.add_parser("verify")
    v.add_argument("--root", type=Path, required=True)
    v.add_argument("--manifest", type=Path, required=True)
    args = p.parse_args()
    try:
        if args.cmd == "build":
            build(args.root.resolve(strict=True), args.theorem, args.artifact, args.out)
        else:
            verify(args.root.resolve(strict=True), args.manifest.resolve(strict=True))
    except (ValueError, OSError, KeyError, json.JSONDecodeError) as exc:
        print(f"proof-bundle: {exc}")
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
