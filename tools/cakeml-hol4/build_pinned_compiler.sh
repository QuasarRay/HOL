#!/usr/bin/env bash
# Reconstruct the compiler library with the HOL source pin recorded by v3213.
# A source-built bootstrap checker is not an original vendor-binary replay.
set -euo pipefail
: "${HOLDIR:?identify the built release-matched bootstrap checker}"
: "${CAKEMLDIR:?identify the clean pinned CakeML worktree}"
: "${HOL4_PINNED_COMPILER_OUT:?identify a new evidence directory}"
test "$(git -C "$HOLDIR" rev-parse HEAD)" = b725f6e8834462a5b4bb2fb67b35e36f368cb8b6
test "$(git -C "$CAKEMLDIR" rev-parse HEAD)" = c98da7fc904c5d6d0e9a75a18fac1796a9bfb1f9
test -z "$(git -C "$HOLDIR" status --porcelain --untracked-files=no)"
test -z "$(git -C "$CAKEMLDIR" status --porcelain --untracked-files=no)"
mkdir "$HOL4_PINNED_COMPILER_OUT"
OUT="$(cd "$HOL4_PINNED_COMPILER_OUT" && pwd)"
printf '%s\n' COMPILER_INSTANCE_OPEN > "$OUT/STATUS"
printf '%s\n' '--nolmbc --no_preexecs --heap-size=4096 -j1; 900 seconds per stage' > "$OUT/build-flags.txt"
for dependency in 'floating-point machine_ieeeTheory.uo' 'integer integer_wordTheory.uo' \
                  'sort mergesortTheory.uo' 'monad/more_monads state_monadLib.uo' \
                  'num/theories/cv_compute/automation cv_typeLib.uo' \
                  'num/theories/cv_compute/automation cv_transLib.uo' \
                  'num/theories/cv_compute/automation cv_memLib.uo'; do
  read -r directory target <<< "$dependency"
  if (cd "$HOLDIR/src/$directory"; timeout -s INT -k 5 900 "$HOLDIR/bin/Holmake" \
    --nolmbc --no_preexecs --heap-size=4096 -j1 "$target" && "$HOLDIR/bin/linkToSigobj") \
    > "$OUT/${target}.log" 2>&1; then
    printf '%s\n' 0 > "$OUT/${target}.exit-code"
  else
    printf '%s\n' "$?" > "$OUT/${target}.exit-code"
    printf '%s\n' HOST_PREREQUISITE_BUILD_FAILED > "$OUT/STATUS"
    exit 1
  fi
done
if (cd "$CAKEMLDIR/misc"; timeout -s INT -k 5 900 "$HOLDIR/bin/Holmake" \
  --nolmbc --no_preexecs --heap-size=4096 -j1 cakeml-heap) > "$OUT/heap-build.log" 2>&1; then
  printf '%s\n' 0 > "$OUT/heap-build.exit-code"
else
  printf '%s\n' "$?" > "$OUT/heap-build.exit-code"
  printf '%s\n' PREREQUISITE_BUILD_FAILED > "$OUT/STATUS"
  exit 1
fi
if (cd "$CAKEMLDIR/cv_translator"; timeout -s INT -k 5 900 "$HOLDIR/bin/Holmake" \
  --nolmbc --no_preexecs --heap-size=4096 -j1 eval_cake_compile_x64Lib.uo) > "$OUT/compiler-build.log" 2>&1; then
  printf '%s\n' 0 > "$OUT/compiler-build.exit-code"
else
  printf '%s\n' "$?" > "$OUT/compiler-build.exit-code"
  printf '%s\n' COMPILER_LIBRARY_BUILD_FAILED > "$OUT/STATUS"
  exit 1
fi
printf '%s\n' PINNED_COMPILER_LIBRARY_BUILT_INSTANCE_OPEN > "$OUT/STATUS"
cat "$OUT/STATUS"
