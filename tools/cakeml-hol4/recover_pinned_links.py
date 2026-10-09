#!/usr/bin/env python3
"""Restore generated HOL library links from a confined, retained build index.

This reuses HOL's own linkToSigobj program. It neither reconstructs proofs nor
turns a retained theory into a new proof claim.
"""
from __future__ import annotations

import argparse
from collections import OrderedDict
import hashlib
import json
from pathlib import Path
import subprocess

HOL_PIN = "b725f6e8834462a5b4bb2fb67b35e36f368cb8b6"


def indexed_directories(host: Path, raw: bytes) -> list[Path]:
    host = host.resolve(strict=True)
    directories: OrderedDict[Path, None] = OrderedDict()
    for line in raw.decode("utf-8").splitlines():
        source = Path(line)
        if not source.is_absolute() or not source.resolve().is_relative_to(host):
            raise ValueError("build-index source escapes the pinned HOL checkout")
        directory = source.parent
        if directory.parts[-2:] == (".hol", "objs"):
            directory = directory.parent.parent
        directory = directory.resolve(strict=True)
        if not directory.is_relative_to(host):
            raise ValueError("build-index directory escapes the pinned HOL checkout")
        # SRCFILES includes both signatures and implementation-only modules.
        # An interrupted theory export must not become a usable library.
        candidates = [Path(str(source) + ext) for ext in (".sig", ".sml", "-sig.sml")]
        candidates += [directory / ".hol/objs" / (source.name + ext)
                       for ext in (".sig", ".sml")]
        # Configure keeps Systeml's generated signature directly in sigobj;
        # its tools-poly entry is a generated link that can itself be lost.
        if source == host / "tools-poly/Holmake/Systeml":
            candidates.append(host / "sigobj/Systeml.sig")
        sources = [p for p in candidates if p.is_file()]
        if not sources or any(p.stat().st_size == 0 for p in sources):
            raise ValueError(f"missing or incomplete indexed source: {source}")
        if source.name.endswith("Theory") and not all(
                any(p.suffix == ext for p in sources) for ext in (".sig", ".sml")):
            raise ValueError(f"incomplete indexed theory export: {source}")
        if any(not p.resolve().is_relative_to(host) for p in sources):
            raise ValueError("indexed source escapes the pinned HOL checkout")
        directories.pop(directory, None)
        directories[directory] = None
    if not directories:
        raise ValueError("empty HOL build index")
    return list(directories)


def restore(host: Path, receipt: Path) -> dict:
    host = host.resolve(strict=True)
    if receipt.exists() or receipt.is_symlink():
        raise ValueError("link-recovery receipt must be new")
    pin = subprocess.check_output(["git", "-C", str(host), "rev-parse", "HEAD"],
                                  text=True).strip()
    if pin != HOL_PIN:
        raise ValueError("unexpected HOL source pin")
    if subprocess.check_output(["git", "-C", str(host), "status", "--porcelain",
                                "--untracked-files=no"], text=True).strip():
        raise ValueError("pinned HOL tracked sources have changes")
    index = host / "sigobj/SRCFILES"
    if not index.resolve(strict=True).is_relative_to(host):
        raise ValueError("HOL build index escapes checkout")
    raw = index.read_bytes()
    # Validate the complete index before executing any link operation.
    directories = indexed_directories(host, raw)
    linker = host / "bin/linkToSigobj"
    if not linker.resolve(strict=True).is_relative_to(host):
        raise ValueError("HOL linker escapes checkout")
    observations = {
        "schema": 1, "status": "LINK_RECOVERY_INCOMPLETE", "hol_pin": pin,
        "source_index_sha256": hashlib.sha256(raw).hexdigest(),
        "directories": [str(p.relative_to(host)) for p in directories],
        "completed_directories": [],
        "claim": "generated link recovery only; no new proof claim",
    }
    def retain() -> None:
        receipt.write_text(json.dumps(observations, indent=2) + "\n")
    retain()
    for directory in directories:
        result = subprocess.run([str(linker)], cwd=directory, check=False,
                                timeout=60)
        if result.returncode:
            observations["failed_directory"] = str(directory.relative_to(host))
            observations["exit_code"] = result.returncode
            retain()
            raise RuntimeError("HOL's generated link restoration failed")
        observations["completed_directories"].append(str(directory.relative_to(host)))
        retain()
    observations["status"] = "GENERATED_LINKS_RESTORED"
    retain()
    return observations


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", type=Path, required=True)
    parser.add_argument("--receipt", type=Path, required=True)
    args = parser.parse_args()
    result = restore(args.host, args.receipt)
    print(result["status"], len(result["completed_directories"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
