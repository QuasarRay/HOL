#!/usr/bin/env bash
# Reconstruct normalized macro proofs with explicit, prebuilt dependencies.
set -euo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SELF/hol4_artifacts.sh"
source "$SELF/hol4_scope.sh"
: "${HOLDIR:?identify the built HOL4 checkout}"
: "${CAKEMLDIR:?identify the built CakeML checkout}"
: "${HOL4_Z3_EXECUTABLE:?identify the proof-reconstructing Z3 executable}"
: "${HOL4_TACTICTOE_CACHE:?identify the reused TacticToe cache}"
OUT="${HOL4_MACRO_OUT:-$SELF/../../.hol4-cakeml/macros}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
hol4_scope_flags "$HOLDIR/bin/Holmake"
printf '%s\n' "${HOL4_SCOPED_FLAGS[*]}" > "$OUT/holmake-flags.txt"
rm -f "$OUT/STATUS"
SEARCH_PYTHON="${HOL4_EGGLOG_PYTHON:-python3}"
"$SEARCH_PYTHON" "$SELF/egglog_native.py" \
  --rules "$SELF/formal/macro-rewrites.tsv" \
  --lhs '(App (App (Const "LetNone") (Var "e1")) (Var "e2"))' \
  --rhs '(App (App (Const "SmlSeq") (Var "e1")) (Var "e2"))' \
  --out "$OUT/macro.rewrites" --receipt "$OUT/egglog-receipt.json"
export HOL4_MACRO_REWRITES="$OUT/macro.rewrites"
cp "$SELF/formal/macro-rewrites.tsv" "$OUT/macro-rewrites.tsv"
"$SEARCH_PYTHON" "$SELF/egglog_native.py" \
  --rules "$SELF/formal/application-rewrites.tsv" \
  --lhs '(App (App (App (App (Const "LowerLeftApplication") (Var "f")) (Var "a")) (Var "x")) (Var "y"))' \
  --rhs '(App (App (Const "LeftApplicationReference") (Var "x")) (Var "y"))' \
  --out "$OUT/application.rewrites" --receipt "$OUT/application-egglog-receipt.json"
export HOL4_APPLICATION_REWRITES="$OUT/application.rewrites"
cp "$SELF/formal/application-rewrites.tsv" "$OUT/application-rewrites.tsv"
# The candidate file and search configuration are environment inputs, not
# Holmake dependencies. Rebuild from source in a fresh directory every time.
WORK="$(mktemp -d "$OUT/build-XXXXXXXX")"
cp "$SELF/formal/"Hol4SmlMacro* "$SELF/formal/"Hol4ProofSearchLib.* \
   "$SELF/formal/Hol4SmlApplicationScript.sml" \
   "$SELF/formal/Holmakefile" "$WORK/"
(
  cd "$WORK"
  "$HOLDIR/bin/Holmake" "${HOL4_SCOPED_FLAGS[@]}" \
    Hol4SmlMacroQualificationTheory.uo \
    > "$OUT/build.log" 2>&1
  "$HOLDIR/bin/hol" < Hol4SmlMacroInspect.sml > "$OUT/theorems.log" 2>&1
)
rg -q '^HOL4_MACRO_EXPORTS_INSPECTED 31$' "$OUT/theorems.log"
for theory in Hol4SmlMacro Hol4SmlApplication Hol4SmlMacroQualification; do
  for ext in dat sig sml; do
    cp "$(hol4_artifact_path "$WORK/${theory}Theory.$ext")" "$OUT/"
  done
  cp "$WORK/.hol/logs/${theory}Theory" "$OUT/${theory}.log"
done
(
  cd "$OUT"
  sha256sum *.dat *.sig *.sml *.log *.rewrites *.tsv *egglog-receipt.json holmake-flags.txt > SHA256SUMS
)
printf '%s\n' 'NORMALIZED_MACRO_PROOFS_CHECKED; full SML97/source/machine/release bridge OPEN' > "$OUT/STATUS"
