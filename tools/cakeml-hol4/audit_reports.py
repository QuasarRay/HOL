#!/usr/bin/env python3
"""Audit pinned report bytes and source references offline. This is not a proof."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def source(root, commit, path):
    return subprocess.check_output(["git", "-C", str(root), "show", f"{commit}:{path}"])


def audit(inputs, roots):
    base = inputs / "machine"
    def read(name):
        return json.loads((base / name).read_text())
    for item in read("MANIFEST.json")["files"]:
        name = item["name"]
        if Path(name).name != name:
            raise ValueError("unsafe manifest path")
        raw = (base / name).read_bytes()
        if len(raw) != item["bytes"] or digest(raw) != item["sha256"]:
            raise ValueError(f"report identity mismatch: {name}")
    data = read("hol4-sml-vs-cakeml-gaps.json")
    strict = read("hol4-sml-vs-cakeml-strict.json")
    catalog = read("authoritative-sources.json")
    rows = data["features"]
    if rows != [json.loads(s) for s in (base / "hol4-sml-vs-cakeml-gaps.jsonl").read_text().splitlines()]:
        raise ValueError("JSON/JSONL disagreement")
    if strict["features"] != [r for r in rows if r["id"] != "C14"]:
        raise ValueError("strict dataset disagrees with full dataset")
    if len({r["id"] for r in rows}) != len(rows):
        raise ValueError("duplicate feature identifier")
    for d in [data, strict]:
        f = d["features"]
        counts = {"total_entries": len(f),
                  "strict_semantic_or_acceptance_entries": sum(r["id"] != "C14" for r in f),
                  "surface_only_entries": sum(r["id"] == "C14" for r in f),
                  "by_layer": dict(Counter(r["layer"] for r in f)),
                  "by_cakeml_compatibility": dict(Counter(r["cakeml"]["compatibility"] for r in f))}
        if counts != d["counts"] or d["sources"] != catalog["sources"] or d["snapshots"] != catalog["snapshots"]:
            raise ValueError("count, catalog or snapshot disagreement")
    prose = json.loads((inputs / "report/MANIFEST.json").read_text())
    if prose["cake_commit"] != data["snapshots"]["cakeml"]["commit"] or prose["hol_commit"] != data["snapshots"]["hol4"]["commit"]:
        raise ValueError("prose and machine report pins differ")
    for name in prose["files"]:
        if Path(name).name != name or not (inputs / "report" / name).is_file():
            raise ValueError("incomplete prose report")
    sources, raw_sources = {}, {}
    for key, entry in catalog["sources"].items():
        raw = source(roots[entry["repository"]], entry["commit"], entry["path"])
        raw_sources[key] = raw
        sources[key] = {k: entry[k] for k in ["repository", "commit", "path"]}
        sources[key].update(bytes=len(raw), sha256=digest(raw))
    observed, features = {}, []
    hol_pin = data["snapshots"]["hol4"]["commit"]
    for row in rows:
        refs = set(row["hol4"]["authority_refs"] + row["cakeml"]["authority_refs"])
        if refs - sources.keys():
            raise ValueError(f"unknown source reference in {row['id']}")
        for item in row["hol4"].get("observed_source_paths", []):
            path = item["path"]
            if path not in observed:
                raw = source(roots["HOL-Theorem-Prover/HOL"], hol_pin, path)
                observed[path] = {"bytes": len(raw), "sha256": digest(raw)}
        features.append({"id": row["id"], "name": row["name"],
                         "reported_compatibility": row["cakeml"]["compatibility"],
                         "references_resolved": sorted(refs), "formal_report_verification": "OPEN",
                         "full_source_lowering": "UNSUPPORTED"})
    anchors = {"M04": ("cakeml_conversion", "SOME(Dmod sname (*asc*) ds)"),
               "S01": ("cakeml_infer", "Don't do polymorphism for non-top-level lets"),
               "S04/S05": ("cakeml_semprim", "do_eq (Closure v0 v3 v4) (Closure v5 v6 v7) = Eq_val T"),
               "S06": ("cakeml_howto", "CakeML has right-to-left evaluation order"),
               "S09": ("cakeml_infer", "Type variables are not supported in type annotations.")}
    observations = []
    for feature, (key, anchor) in anchors.items():
        text = raw_sources[key].decode()
        if anchor not in text:
            raise ValueError(f"re-audit required for {feature}")
        observations.append({"feature": feature, "source": key,
                             "line": text[:text.index(anchor)].count("\n") + 1,
                             "status": "SOURCE_OBSERVATION_ONLY"})
    compiler_pin = json.loads((HERE / "spec.json").read_text())["cakeml_source"]["commit"]
    differences = []
    for key, item in catalog["sources"].items():
        if item["repository"] == "CakeML/cakeml":
            h = digest(source(roots[item["repository"]], compiler_pin, item["path"]))
            if h != sources[key]["sha256"]:
                differences.append({"source": key, "compiler_sha256": h, "report_sha256": sources[key]["sha256"]})
    warnings = []
    if data["generated_utc"] < data["snapshots"]["cakeml"]["commit_date"]:
        warnings.append("generated_utc predates the cited CakeML commit; it is not reliable generation provenance")
    return {"schema": 1, "status": "INTEGRITY_AND_SOURCE_REFERENCES_CHECKED",
            "claim": "Python source inspection does not formally verify report claims",
            "inputs": {str(p.relative_to(inputs)): digest(p.read_bytes()) for p in sorted(inputs.rglob('*')) if p.is_file()},
            "feature_count": len(rows), "strict_feature_count": len(strict["features"]),
            "snapshots": data["snapshots"], "sources": sources, "observed_paths": observed,
            "source_observations": observations, "compiler_pin": compiler_pin,
            "compiler_revision_differences": differences, "warnings": warnings, "features": features}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--inputs", type=Path, default=HERE / "reports/input")
    p.add_argument("--hol4-source", type=Path, required=True)
    p.add_argument("--cakeml-source", type=Path, required=True)
    p.add_argument("--sml97-source", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    a = p.parse_args()
    roots = dict(zip(["HOL-Theorem-Prover/HOL", "CakeML/cakeml", "SMLFamily/The-Definition-of-Standard-ML-Revised"],
                     [a.hol4_source, a.cakeml_source, a.sml97_source]))
    result = audit(a.inputs, roots)
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({k: result[k] for k in ["status", "feature_count", "strict_feature_count", "warnings"]}))


if __name__ == "__main__":
    main()
