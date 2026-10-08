#!/usr/bin/env python3
"""Restore exact MetaRocq search data; HOL4 still validates theory identities."""
import argparse
import base64
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import tarfile
import tempfile

HERE = Path(__file__).resolve().parent


def unpack(raw, output):
    """Confine regular archive entries to a new cache directory."""
    if output.exists() or output.is_symlink():
        raise ValueError("refusing to overwrite existing cache progress")
    with tarfile.open(fileobj=io.BytesIO(raw), mode="r:gz") as archive:
        entries = archive.getmembers()
        names = set()
        for item in entries:
            path = PurePosixPath(item.name)
            if (path.is_absolute() or ".." in path.parts or not path.parts or
                    path.parts[0] != "tactictoe-cache" or
                    not (item.isdir() or item.isfile()) or item.name in names):
                raise ValueError("unsafe or duplicate cache archive entry")
            names.add(item.name)
        if sum(item.size for item in entries) > 32 * 1024 * 1024:
            raise ValueError("unexpected cache archive size")
        output.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=output.parent) as stage:
            stage = Path(stage)
            for item in entries:
                target = stage.joinpath(*PurePosixPath(item.name).parts)
                if item.isdir():
                    target.mkdir(parents=True, exist_ok=True)
                else:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    with archive.extractfile(item) as src, target.open("xb") as dst:
                        shutil.copyfileobj(src, dst)
            cache = stage / "tactictoe-cache"
            manifest = cache / "ttt_tacdata/MANIFEST"
            lines = manifest.read_text().splitlines()
            if not all(line in lines for line in ["format 5", "tacdata 3", "tactictoe 1"]):
                raise ValueError("incompatible TacticToe manifest format")
            manifest_sha = hashlib.sha256(manifest.read_bytes()).hexdigest()
            cache.rename(output)
    return {"entries": len(entries), "manifest_sha256": manifest_sha}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--metarocq-source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    lock = json.loads((HERE / "reports/tactictoe-cache-reuse.json").read_text())
    encoded = subprocess.check_output([
        "git", "-C", str(args.metarocq_source), "show", "--end-of-options",
        lock["source_commit"] + ":" + lock["source_path"]])
    if hashlib.sha256(encoded).hexdigest() != lock["source_sha256"]:
        raise ValueError("MetaRocq cache source identity mismatch")
    raw = base64.b64decode(b"".join(encoded.split()), validate=True)
    if hashlib.sha256(raw).hexdigest() != lock["archive_sha256"]:
        raise ValueError("MetaRocq cache archive identity mismatch")
    receipt = dict(lock, **unpack(raw, args.output))
    receipt["status"] = "EXACT_SEARCH_DATA_RESTORED"
    (args.output / "reuse-receipt.json").write_text(
        json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    print(json.dumps(receipt, sort_keys=True))


if __name__ == "__main__":
    main()
