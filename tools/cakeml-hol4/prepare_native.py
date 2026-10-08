#!/usr/bin/env python3
"""Link the exact CakeML v3213 vendor image; this is not a proof replay."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ARCHIVE_SHA256 = "e99dc1cdb9e28366f78c7c4ef812dbaab6710eb301ae8c85d1b6ce2a2161b728"
COMMIT = "c98da7fc904c5d6d0e9a75a18fac1796a9bfb1f9"
HOL_COMMIT = "b725f6e8834462a5b4bb2fb67b35e36f368cb8b6"
URL = "https://github.com/CakeML/cakeml/releases/download/v3213/cake-x64-64.tar.gz"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def prepare(archive: Path, out: Path) -> dict:
    if digest(archive) != ARCHIVE_SHA256:
        raise ValueError("CakeML release archive digest mismatch")
    out.mkdir(parents=True, exist_ok=False)
    with tarfile.open(archive, "r:gz") as tar:
        members = tar.getmembers()
        names = [m.name for m in members]
        if len(names) != len(set(names)):
            raise ValueError("duplicate archive member")
        for member in members:
            name = Path(member.name)
            if (name.is_absolute() or ".." in name.parts or
                    not (member.isdir() or member.isfile()) or
                    name.parts[0] != "cake-x64-64"):
                raise ValueError("unsupported release archive member")
        # No symlinks or device files can enter the fresh destination.
        tar.extractall(out, members=members, filter="data")
    root = out / "cake-x64-64"
    with (out / "link.log").open("w") as log:
        subprocess.run(["make", "cake"], cwd=root, stdout=log,
                       stderr=subprocess.STDOUT, check=True, timeout=120)
    binary = root / "cake"
    version = subprocess.run([str(binary), "--version"], text=True,
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                             check=True, timeout=30).stdout
    (out / "compiler-version.log").write_text(version)
    if (not re.search(rf"^CakeML:\s+{COMMIT}$", version, re.M) or
            not re.search(rf"^HOL4:\s+{HOL_COMMIT}$", version, re.M)):
        raise ValueError("release version identity mismatch")
    receipt = {
        "schema": 1, "status": "VENDOR_IMAGE_LINKED_UNQUALIFIED",
        "url": URL, "release_tag": "v3213", "archive_sha256": ARCHIVE_SHA256,
        "advertised_cakeml_commit": COMMIT, "advertised_hol_commit": HOL_COMMIT,
        "files": [{"path": str(p.relative_to(out)), "sha256": digest(p),
                   "bytes": p.stat().st_size}
                  for p in [root / "cake.S", root / "basis_ffi.c", binary]],
        "claim": "exact vendor archive and observed version; independent binary correctness replay remains OPEN",
    }
    (out / "receipt.json").write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    return receipt


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(prepare(args.archive, args.out), sort_keys=True))


if __name__ == "__main__":
    main()
