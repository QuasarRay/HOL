#!/usr/bin/env python3
"""Inspect the same bound theorem under two identified HOL4 executables."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
from proof_bundle import verify


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(binary: Path, script: Path, env: dict[str, str], marker: str) -> dict:
    if not binary.is_file() or not os.access(binary, os.X_OK):
        raise ValueError(f"not executable: {binary}")
    cp = subprocess.run(
        [str(binary)], input=script.read_text(), text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env, timeout=300)
    if cp.returncode != 0 or marker not in cp.stdout:
        raise ValueError(f"proof replay failed under {binary}:\n{cp.stdout[-4000:]}")
    return {
        "binary": str(binary.resolve()),
        "binary_sha256": digest(binary),
        "returncode": cp.returncode,
        "marker": marker,
    }


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--bundle-root", type=Path, required=True)
    p.add_argument("--manifest", type=Path, required=True)
    p.add_argument("--replay-script", type=Path, required=True)
    p.add_argument("--original-hol", type=Path, required=True)
    p.add_argument("--cakeml-hol", type=Path, required=True)
    p.add_argument("--receipt", type=Path, required=True)
    args = p.parse_args()
    args.receipt.unlink(missing_ok=True)
    try:
        root = args.bundle_root.resolve(strict=True)
        manifest = args.manifest.resolve(strict=True)
        verify(root, manifest)
        if digest(args.original_hol) == digest(args.cakeml_hol):
            raise ValueError("both roles use the same executable bytes")
        data = json.loads(manifest.read_text())
        theorem = data["release_theorem"]
        md = digest(manifest)
        marker = "HOL4_PROOF_BUNDLE_OK " + md
        env = dict(os.environ)
        env.update({
            "HOL4_RELEASE_BUNDLE_DIR": str(root),
            "HOL4_RELEASE_BUNDLE_SHA256": md,
            "HOL4_RELEASE_THEOREM": theorem,
        })
        first = run(args.original_hol.resolve(strict=True), args.replay_script, env, marker)
        second = run(args.cakeml_hol.resolve(strict=True), args.replay_script, env, marker)
        receipt = {
            "schema": 1,
            "status": "DUAL_THEORY_IMPORT_OBSERVED",
            "manifest_sha256": md,
            "release_theorem": theorem,
            "replay_script_sha256": digest(args.replay_script),
            "ordinary_hol4": first,
            "cakeml_hol4": second,
            "claim": "same theorem imported by two executable identities; independent proof reconstruction and CakeML binary provenance remain OPEN",
        }
        args.receipt.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
        print(json.dumps(receipt, sort_keys=True))
        return 0
    except (ValueError, OSError, KeyError, json.JSONDecodeError,
            subprocess.SubprocessError) as exc:
        print(f"dual-replay: {exc}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
