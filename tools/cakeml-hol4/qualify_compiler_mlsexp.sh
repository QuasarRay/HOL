#!/usr/bin/env bash
# A bounded dependency proof qualification, not compiler/machine correctness.
set -euo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SELF/hol4_scope.sh"
: "${HOLDIR:?identify the built HOL4 checker}"
: "${CAKEMLDIR:?identify the derived pinned compiler context}"
: "${HOL4_COMPILER_SOURCE:?identify the clean pinned compiler checkout}"
: "${HOL4_MLSEXP_OUT:?identify a new evidence directory}"
mkdir "$HOL4_MLSEXP_OUT"
OUT="$(cd "$HOL4_MLSEXP_OUT" && pwd)"
python3 "$SELF/materialize_cakeml_context_compat.py" \
  --source "$HOL4_COMPILER_SOURCE" --output "$CAKEMLDIR" \
  --receipt "$OUT/compatibility-receipt.json" > "$OUT/materialization.log"
WORK="$OUT/build"
mkdir "$WORK"
cp "$CAKEMLDIR/basis/pure/mlsexpScript.sml" "$WORK/"
printf 'INCLUDES = %s/basis/pure %s/misc\nHOLHEAP = %s/misc/cakeml-heap\n' \
  "$CAKEMLDIR" "$CAKEMLDIR" "$CAKEMLDIR" > "$WORK/Holmakefile"
hol4_scope_flags "$HOLDIR/bin/Holmake"
printf '%s\n' "${HOL4_SCOPED_FLAGS[*]}" > "$OUT/holmake-flags.txt"
export HOL4_MLSEXP_BUILD_DIR="$WORK"
if ! (cd "$WORK"; timeout -s INT -k 5 120 "$HOLDIR/bin/Holmake" \
  "${HOL4_SCOPED_FLAGS[@]}" --heap-size=3072 -j1 mlsexpTheory.uo) \
  > "$OUT/build.log" 2>&1; then
  printf '%s\n' BUILD_FAILED > "$OUT/STATUS"
  exit 1
fi
if ! (cd "$WORK"; "$HOLDIR/bin/hol" < "$SELF/formal/Hol4MlsexpInspect.sml") \
  > "$OUT/inspection.log" 2>&1; then
  printf '%s\n' INSPECTION_FAILED > "$OUT/STATUS"
  exit 1
fi
rg -q '^HOL4_MLSEXP_EXPORTS_INSPECTED [1-9][0-9]*$' "$OUT/inspection.log"
printf '%s\n' DEPENDENCY_PROOF_CHECKED > "$OUT/STATUS"
cat "$OUT/STATUS"
