#!/usr/bin/env bash
# Offline source reconstruction at the report pin. Does not certify all gaps.
set -euo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SELF/hol4_artifacts.sh"
source "$SELF/hol4_scope.sh"
: "${HOLDIR:?identify a built HOL4 checkout}"
: "${CAKEMLDIR:?identify the clean CakeML report checkout}"
: "${SML97DIR:?identify the pinned SML97 Definition checkout}"
: "${HOL4_Z3_EXECUTABLE:?identify the proof-reconstructing Z3 executable}"
: "${HOL4_TACTICTOE_CACHE:?identify a manifest-validated reused TacticToe cache}"
INPUTS="${HOL4_GAP_INPUTS:-$SELF/reports/input}"

# No HOL4 executable runs before report bytes and source identities are checked.
python3 - "$SELF" "$INPUTS" "$CAKEMLDIR" <<'PY'
import pathlib, sys
sys.path.insert(0, sys.argv[1])
from audit_reports import require_report_checkout
print("REPORT_CAKEML_PIN " + require_report_checkout(
    pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])))
PY
OUT_BASE="${HOL4_GAP_OUT_BASE:-$SELF/../../.hol4-cakeml/gap-report}"
mkdir -p "$OUT_BASE"
OUT="$(mktemp -d "$OUT_BASE/run-XXXXXXXX")"
hol4_scope_flags "$HOLDIR/bin/Holmake"
printf '%s\n' "${HOL4_SCOPED_FLAGS[*]}" > "$OUT/holmake-flags.txt"
python3 "$SELF/audit_reports.py" --inputs "$INPUTS" \
  --hol4-source "$HOLDIR" --cakeml-source "$CAKEMLDIR" \
  --sml97-source "$SML97DIR" --out "$OUT/source-audit.json"
cp "$HOL4_TACTICTOE_CACHE/ttt_tacdata/MANIFEST" "$OUT/tactictoe-manifest.txt"
if [[ -f "$HOL4_TACTICTOE_CACHE/reuse-receipt.json" ]]; then
  cp "$HOL4_TACTICTOE_CACHE/reuse-receipt.json" "$OUT/tactictoe-reuse.json"
fi

# Explicit includes are required by the dependency's own Holmake invocation.
# Keep the report tree unchanged and retain the prerequisite build outcome.
(
  cd "$CAKEMLDIR/semantics"
  "$HOLDIR/bin/Holmake" "${HOL4_SCOPED_FLAGS[@]}" -j2 \
    -I ../basis/pure -I ../misc -I ffi -I proofs \
    -I "$HOLDIR/examples/formal-languages/context-free" \
    evaluateTheory.uo namespacePropsTheory.uo cmlPtreeConversionTheory.uo \
    > "$OUT/dependencies.log" 2>&1
)

mkdir "$OUT/witnesses"
cp "$SELF/formal/Hol4SmlGapWitnessScript.sml" \
   "$SELF/formal/Hol4SmlGapInspect.sml" "$SELF/formal/Holmakefile" "$OUT/witnesses/"
(
  cd "$OUT/witnesses"
  "$HOLDIR/bin/Holmake" "${HOL4_SCOPED_FLAGS[@]}" \
    Hol4SmlGapWitnessTheory.uo > build.log 2>&1
  "$HOLDIR/bin/hol" < Hol4SmlGapInspect.sml > theorems.log 2>&1
  rg -q '^HOL4_GAP_WITNESSES_INSPECTED 7$' theorems.log
  for ext in dat sig sml; do
    cp "$(hol4_artifact_path "Hol4SmlGapWitnessTheory.$ext")" ./
  done
  cp .hol/logs/Hol4SmlGapWitnessTheory witness-proof.log
)
HOL4_MACRO_OUT="$OUT/macros" "$SELF/qualify_macros.sh"

python3 - "$SELF" "$OUT" "$HOLDIR" "$CAKEMLDIR" <<'PY'
import hashlib, json, os, pathlib, re, subprocess, sys
sys.path.insert(0, sys.argv[1])
from proof_bundle import build
root = pathlib.Path(sys.argv[2]).resolve()
def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()
artifacts = [str(p.relative_to(root)) for p in root.rglob("*")
             if p.is_file() and ".hol" not in p.relative_to(root).parts and
             (p.suffix in {".sml", ".sig", ".dat", ".log", ".json", ".tsv", ".rewrites", ".txt"}
              or p.name in {"SHA256SUMS", "STATUS"})]
build(root, "Hol4SmlGapWitness.target_order_is_observable", artifacts, root / "bundle.json")
receipt = {
    "schema": 1, "status": "SCOPED_REPORT_WITNESSES_RECONSTRUCTED",
    "hol4_commit": subprocess.check_output(["git", "-C", sys.argv[3], "rev-parse", "HEAD"], text=True).strip(),
    "hol4_executable_sha256": digest(pathlib.Path(sys.argv[3]) / "bin/hol"),
    "holmake_executable_sha256": digest(pathlib.Path(sys.argv[3]) / "bin/Holmake"),
    "holmake_flags": (root / "holmake-flags.txt").read_text().strip().split(),
    "hol4_runtime_image_sha256": digest(pathlib.Path(sys.argv[3]) / "bin/hol.state"),
    "cakeml_runtime_image_sha256": digest(pathlib.Path(sys.argv[4]) / "misc/cakeml-heap"),
    "z3_executable_sha256": digest(pathlib.Path(os.environ["HOL4_Z3_EXECUTABLE"])),
    "tactictoe_manifest_sha256": digest(root / "tactictoe-manifest.txt"),
    "tactictoe_loaded_calls": [int(n) for n in re.findall(
        r"Loading (\d+) tactic calls", (root / "macros/Hol4SmlMacroQualification.log").read_text())],
    "cakeml_commit": subprocess.check_output(["git", "-C", sys.argv[4], "rev-parse", "HEAD"], text=True).strip(),
    "source_audit_sha256": digest(root / "source-audit.json"),
    "bundle_sha256": digest(root / "bundle.json"),
    "macro_theorems": 31, "target_witness_theorems": 7,
    "report_witnesses": {
        "S04": ["Hol4SmlGapWitness.target_closure_equality"],
        "S05": ["Hol4SmlGapWitness.target_closure_equality",
                "Hol4SmlGapWitness.target_recursive_closure_equality"],
        "S06": ["Hol4SmlGapWitness.target_tuple_raises_second",
                "Hol4SmlGapWitness.explicit_sequence_raises_first",
                "Hol4SmlGapWitness.target_order_is_observable",
                "Hol4SmlApplication.lower_sml_left_application_correct",
                "Hol4SmlApplication.temporary_capture_is_observable"],
        "S07": ["Hol4SmlGapWitness.target_failed_case_raises_bind",
                "Hol4SmlMacro.lower_sml_match_correct"],
        "S08": ["Hol4SmlMacro.matched_body_bind_is_preserved"],
        "C08": ["Hol4SmlMacro.lower_sml_multifn_application_correct"],
        "M04": ["Hol4SmlGapWitness.accepted_inline_signature_is_erased"],
    },
    "formal_report_verification": "OPEN",
    "full_sml97_source_bridge": "OPEN", "macro_implementation_machine_code": "OPEN",
    "original_release_binary_replay": "OPEN", "cakeml_hol4_binary_replay": "OPEN",
    "claim": "scoped target semantics and normalized macro proofs only; not all report claims or a verified HOL4 binary",
}
(root / "receipt.json").write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
print(json.dumps(receipt, sort_keys=True))
PY
printf '%s\n' "$OUT"
