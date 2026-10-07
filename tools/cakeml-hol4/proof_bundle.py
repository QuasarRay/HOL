#!/usr/bin/env python3
"""Bind proof artifact identities. This manifest does not prove them."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def confined(root: Path, rel: str) -> Path:
    relative = Path(rel)
    if relative.is_absolute() or ".." in relative.parts or not relative.parts:
        raise ValueError(f"artifact must have a relative path: {rel}")
    lexical = root / relative
    if lexical.is_symlink() or any(p.is_symlink() for p in lexical.parents if p != root):
        raise ValueError(f"symlink artifact rejected: {rel}")
    p = lexical.resolve(strict=True)
    if p != root and root not in p.parents:
        raise ValueError(f"artifact escapes bundle root: {rel}")
    if p.is_symlink():
        raise ValueError(f"symlink artifact rejected: {rel}")
    return p


def build(root: Path, theorem: str, artifacts: list[str], out: Path) -> None:
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_']*\.[A-Za-z][A-Za-z0-9_']*", theorem):
        raise ValueError("release theorem must be Theory.theorem")
    if not artifacts:
        raise ValueError("proof bundle must contain artifacts")
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
            "original release HOL4 reconstructs the release proof sources",
            "identified CakeML-built HOL4 reconstructs the identical release proof sources and bundle",
        ],
        "claim": "digest manifest only; theory imports do not reconstruct proofs or establish binary provenance",
    }
    out.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")


def verify(root: Path, manifest: Path) -> None:
    data = json.loads(manifest.read_text())
    if data.get("schema") != 1 or not data.get("artifacts"):
        raise ValueError("unsupported proof-bundle schema")
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_']*\.[A-Za-z][A-Za-z0-9_']*", data["release_theorem"]):
        raise ValueError("release theorem must be Theory.theorem")
    if len({item['path'] for item in data['artifacts']}) != len(data['artifacts']):
        raise ValueError("duplicate artifact path")
    for item in data["artifacts"]:
        p = confined(root, item["path"])
        if not p.is_file():
            raise ValueError(f"not a regular file: {item['path']}")
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
