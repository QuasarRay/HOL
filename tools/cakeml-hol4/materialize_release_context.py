#!/usr/bin/env python3
"""Stage pinned report sources under build controls understood by old HOL4.

The pinned source tree is untouched. Optional release proof/API adaptations
are guarded and recorded separately; no semantic definition is rewritten.
Staging is source identity evidence, not a proof or release qualification.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

from audit_reports import HERE, require_report_checkout


def adapt_trindemossen2(output):
    arithmetic_old = """  \\\\ once_rewrite_tac[GSYM MOD_PLUS]
  \\\\ fs[]
QED

Theorem FLAT_REPLICATE_NIL:"""
    arithmetic_new = """  \\\\ qpat_x_assum `0 < k` (fn h =>
       ONCE_REWRITE_TAC [GSYM (MATCH_MP (Q.SPEC `k` MOD_PLUS) h)]
       THEN ASM_SIMP_TAC (srw_ss()) [MATCH_MP (Q.SPEC `k` MOD_MOD) h])
QED

Theorem FLAT_REPLICATE_NIL:"""
    edits = {
        "miscScript.sml": [
            (arithmetic_old, arithmetic_new,
             "specialize old MOD_PLUS and MOD_MOD after their positivity premise"),
            ("val _ = ParseExtras.tight_equality()",
             "structure WhileTheory = whileTheory;\n\nval _ = ParseExtras.tight_equality()",
             "ML structure spelling in release")],
        "preamble.sml": [
            ("val () = Cache.set_capacity numSimps.arith_cache 200000;", "",
             "cache tuning API absent in release"),
            ("val () = Cache.set_per_key_cap numSimps.arith_cache 5000;", "",
             "cache tuning API absent in release")],
        "mlstringScript.sml": [
            ("val cpn_distinct = TypeBase.distinct_of ``:ordering``",
             "structure WhileTheory = whileTheory;\n\nval cpn_distinct = TypeBase.distinct_of ``:ordering``",
             "ML structure spelling in release")],
    }
    prepared = []
    for name, replacements in edits.items():
        path = output / name
        raw = path.read_bytes()
        text = raw.decode()
        changes = []
        for old, new, reason in replacements:
            if text.count(old) != 1:
                raise ValueError("release adaptation does not match exact pinned input: " + name)
            text = text.replace(old, new)
            changes.append({"original": old, "replacement": new, "reason": reason})
        modified = text.encode()
        prepared.append((path, modified, {
            "file": name, "before_sha256": hashlib.sha256(raw).hexdigest(),
            "after_sha256": hashlib.sha256(modified).hexdigest(),
            "statement_changed": False, "changes": changes}))
    for path, modified, _ in prepared:
        path.write_bytes(modified)
    receipt = {"schema": 1, "status": "PROOF_AND_ML_API_ADAPTATIONS",
               "files": [entry for _, _, entry in prepared],
               "claim": "source-staging hashes describe pre-adaptation inputs; kernel reconstruction required; no semantic definition or theory statement changed"}
    (output / "proof-adaptations.json").write_text(
        json.dumps(receipt, indent=2, sort_keys=True) + "\n")


def export_legacy_hints(cache, output):
    lock = json.loads((HERE / "reports/tactictoe-cache-reuse.json").read_text())
    reuse = json.loads((cache / "reuse-receipt.json").read_text())
    if any(reuse.get(key) != lock[key] for key in
           ("source_commit", "source_sha256", "archive_sha256")):
        raise ValueError("cache receipt does not identify the pinned MetaRocq search archive")
    manifest = cache / "ttt_tacdata/MANIFEST"
    if hashlib.sha256(manifest.read_bytes()).hexdigest() != reuse["manifest_sha256"]:
        raise ValueError("cache manifest identity mismatch")
    paths = sorted((cache / "ttt_tacdata/data").iterdir())
    if sum(p.stat().st_size for p in paths) > 32 * 1024 * 1024:
        raise ValueError("unexpected raw hint size")
    prepared = []
    for path in paths:
        match = re.fullmatch(r"([A-Za-z][A-Za-z0-9_']*)-[0-9a-f]{40}", path.name)
        if path.is_symlink() or not path.is_file() or match is None:
            raise ValueError("unexpected raw hint path")
        name = match.group(1)
        raw = path.read_bytes()
        lines = raw.decode().splitlines()
        if len(lines) % 4 or any(not line.split() or line.split()[0] != name
                               for line in lines[::4]):
            raise ValueError("incompatible raw call data")
        prepared.append((name, raw, {"source_name": path.name, "legacy_name": name,
                                    "sha256": hashlib.sha256(raw).hexdigest(),
                                    "calls": len(lines) // 4}))
    if len({name for name, _, _ in prepared}) != len(prepared):
        raise ValueError("duplicate legacy theory hint name")
    target = output / "legacy-tactictoe-hints"
    target.mkdir()
    for name, raw, _ in prepared:
        (target / name).write_bytes(raw)
    receipt = {"schema": 1, "status": "BYTE_IDENTICAL_RAW_CALL_HINTS_EXPORTED",
               "archive_sha256": lock["archive_sha256"],
               "files": [entry for _, _, entry in prepared],
               "claim": "untrusted hints only; legacy HOL lacks modern manifest ancestry validation; every accepted proof requires independent kernel reconstruction"}
    (output / "legacy-cache-hints.json").write_text(
        json.dumps(receipt, indent=2, sort_keys=True) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--trindemossen2-proof-adapters", action="store_true",
                        help="record the three guarded proof/ML API adaptations; parser compatibility remains open")
    parser.add_argument("--legacy-tactictoe-cache", type=Path,
                        help="export raw untrusted hints under legacy theory filenames; does not install them")
    args = parser.parse_args()
    source = args.source.resolve()
    output = args.output.resolve()
    pin = require_report_checkout(HERE / "reports/input", source)
    if output.exists() or output.is_symlink():
        raise ValueError("refusing to overwrite existing reconstruction progress")
    parents = {"misc", "basis/pure", "semantics", "semantics/proofs", "semantics/ffi"}
    tracked = subprocess.check_output(["git", "-C", str(source), "ls-files"], text=True).splitlines()
    inputs = [(source / name, "CakeML/cakeml", name) for name in tracked
              if str(Path(name).parent) in parents and Path(name).suffix in {".sml", ".sig"}]
    formal = ["Hol4SmlMacroScript.sml", "Hol4SmlApplicationScript.sml",
              "Hol4SmlOrderScript.sml",
              "Hol4SmlMacroLib.sml", "Hol4SmlMacroLib.sig",
              "Hol4SmlMacroQualificationScript.sml", "Hol4ProofSearchLib.sml",
              "Hol4ProofSearchLib.sig", "Hol4SmlGapWitnessScript.sml",
              "Hol4SmlMacroInspect.sml", "Hol4SmlGapInspect.sml"]
    inputs += [(HERE / "formal" / name, "QuasarRay/HOL", "tools/cakeml-hol4/formal/" + name)
               for name in formal]
    names = [p.name for p, _, _ in inputs]
    if len(names) != len(set(names)):
        raise ValueError("flattened source names collide")
    output.mkdir(parents=True)
    files = []
    for path, repository, relative in inputs:
        raw = path.read_bytes()
        target = output / path.name
        target.write_bytes(raw)
        if target.read_bytes() != raw:
            raise ValueError("staging changed source bytes")
        files.append({"repository": repository, "source_path": relative,
                      "staged_name": target.name, "sha256": hashlib.sha256(raw).hexdigest()})
    # Do not parse the new sinclude/readme.mk controls with an older Holmake.
    # The library and theorem sources above are retained byte for byte.
    control = """INCLUDES = $(HOLDIR)/src/HolSmt $(HOLDIR)/src/tactictoe/src \\
 $(HOLDIR)/src/finite_maps $(HOLDIR)/src/coalgebras $(HOLDIR)/src/n-bit \\
 $(HOLDIR)/src/bag $(HOLDIR)/src/res_quan/src $(HOLDIR)/src/string \\
 $(HOLDIR)/examples/fun-op-sem/lprefix_lub \\
 $(HOLDIR)/examples/machine-code/hoare-triple \\
 $(HOLDIR)/examples/formal-languages/context-free

all: Hol4SmlMacroQualificationTheory.uo

report: Hol4SmlGapWitnessTheory.uo
"""
    (output / "Holmakefile").write_text(control)
    receipt = {"schema": 1, "status": "EXACT_ML_INPUT_IDENTITIES_RECORDED",
               "cakeml_commit": pin, "files": files,
               "holmakefile_sha256": hashlib.sha256(control.encode()).hexdigest(),
               "has_proof_adaptations": bool(args.trindemossen2_proof_adapters),
               "hash_scope": "pre-adaptation input bytes",
               "claim": "build controls replaced; optional final ML hashes are in proof-adaptations.json; kernel reconstruction required"}
    (output / "source-staging.json").write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    if args.trindemossen2_proof_adapters:
        adapt_trindemossen2(output)
    if args.legacy_tactictoe_cache:
        export_legacy_hints(args.legacy_tactictoe_cache.resolve(), output)
    status = ("ML_SOURCES_STAGED_WITH_PROOF_ADAPTATIONS" if args.trindemossen2_proof_adapters
              else "EXACT_ML_SOURCES_STAGED")
    print(json.dumps({"status": status, "files": len(files), "output": str(output),
                      "proof_adaptations": bool(args.trindemossen2_proof_adapters)}))


if __name__ == "__main__":
    main()
