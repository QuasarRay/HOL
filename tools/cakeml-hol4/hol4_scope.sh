#!/usr/bin/env bash
# Select sound scoped flags supported by the explicitly chosen HOL4 release.
hol4_scope_flags() {
  local help
  help="$("$1" --nolmbc --help)"
  HOL4_SCOPED_FLAGS=(--nolmbc --qof --no_preexecs --rebuild_deps)
  # Older releases have neither project discovery nor the new build cache.
  if [[ "$help" == *--no-project* ]]; then HOL4_SCOPED_FLAGS+=(--no-project); fi
  if [[ "$help" == *--no-cache* ]]; then HOL4_SCOPED_FLAGS+=(--no-cache); fi
}
