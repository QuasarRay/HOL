#!/usr/bin/env python3
"""Compile through an identified native CakeML executable; no HOL4 proof claim."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build(root: Path, inputs: list[str], compiler: Path, ffi: Path, out: Path) -> dict:
    root, compiler, ffi = root.resolve(strict=True), compiler.resolve(strict=True), ffi.resolve(strict=True)
    out.mkdir(parents=True, exist_ok=False)
    receipt = {"schema": 1, "status": "OPEN", "compiler_sha256": sha(compiler),
               "ffi_sha256": sha(ffi), "inputs": [],
               "claim": "native compilation observation; source preservation and machine-code proofs remain OPEN"}
    def save(status: str) -> dict:
        receipt["status"] = status
        (out / "receipt.json").write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
        return receipt
    if not inputs:
        return save("NO_INPUTS_REJECTED")
    expected = json.loads((HERE / "spec.json").read_text())["cakeml_source"]["commit"]
    try:
        version = subprocess.run([str(compiler), "--version"], text=True,
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=30)
    except subprocess.TimeoutExpired:
        return save("VERSION_TIMEOUT")
    (out / "compiler-version.log").write_text(version.stdout)
    if version.returncode or not re.search(rf"^CakeML:\s+{expected}$", version.stdout, re.M):
        return save("COMPILER_PIN_REJECTED")
    receipt["compiler_advertised_commit"] = expected
    sources = []
    for rel in inputs:
        name = Path(rel)
        if name.is_absolute() or '..' in name.parts:
            raise ValueError("input must be repository relative")
        path = (root / name).resolve(strict=True)
        if not path.is_relative_to(root):
            raise ValueError("input escapes source root")
        receipt["inputs"].append({"path": rel, "sha256": sha(path)})
        sources.append(path.read_text())
    source = out / "program.cml"
    source.write_text('\n'.join(sources) + '\n')
    receipt["program_sha256"] = sha(source)
    env = dict(os.environ, CML_HEAP_SIZE="1024", CML_STACK_SIZE="256")
    asm = out / "program.S"
    with source.open() as stdin, asm.open('w') as stdout, (out / "compiler.log").open('w') as stderr:
        try:
            cp = subprocess.run([str(compiler), "--skip_type_inference=false", "--exclude_prelude=false"],
                                stdin=stdin, stdout=stdout, stderr=stderr, env=env, timeout=120)
        except subprocess.TimeoutExpired:
            return save("COMPILATION_TIMEOUT")
    receipt["compiler_exit_code"] = cp.returncode
    if cp.returncode or not asm.stat().st_size:
        return save("SOURCE_REJECTED")
    receipt["assembly_sha256"] = sha(asm)
    binary = out / "program"
    with (out / "link.log").open('w') as log:
        try:
            cp = subprocess.run(["cc", str(asm), str(ffi), "-lm", "-o", str(binary)],
                                stdout=log, stderr=subprocess.STDOUT, timeout=120)
        except subprocess.TimeoutExpired:
            return save("LINK_TIMEOUT")
    receipt["link_exit_code"] = cp.returncode
    if cp.returncode or not binary.is_file():
        return save("LINK_FAILED")
    receipt["binary_sha256"] = sha(binary)
    return save("NATIVE_COMPILED_UNQUALIFIED")


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['root', 'compiler', 'ffi', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    p.add_argument('inputs', nargs='+')
    a = p.parse_args()
    r = build(a.root, a.inputs, a.compiler, a.ffi, a.out)
    print(json.dumps(r, sort_keys=True))
    return 0 if r['status'] == 'NATIVE_COMPILED_UNQUALIFIED' else 2


if __name__ == '__main__':
    raise SystemExit(main())
