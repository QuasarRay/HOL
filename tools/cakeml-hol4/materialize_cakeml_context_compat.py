#!/usr/bin/env python3
"""Materialize the audited CakeML-v3213/HOL4 compatibility worktree.

Ported from QuasarRay/MetaRocq-rs tools/materialize_cakeml_context_compat.py.
The pinned CakeML checkout remains untouched. Only known API/grammar adaptation
points are changed in a detached derived worktree, with a receipt and patch
hash. This recipe is build compatibility, not proof evidence.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

REPO = Path(__file__).resolve().parents[2]
SPEC = REPO / "tools/cakeml-hol4/spec.json"
PREAMBLE = "misc/preamble.sml"
ASM_LIBRARY = "compiler/encoders/asm/asmLib.sml"
EVALUATOR_LIBRARY = "cv_translator/eval_cake_compileLib.sml"
PATTERN_AST = "semantics/astScript.sml"
MLSEXP = "basis/pure/mlsexpScript.sml"
COMPUTE_UPDATES = {
    "compiler/parsing/cmlPEGScript.sml": (
        "val _ = (computeLib.the_compset := computeLib.add_thms distinct_ths (!computeLib.the_compset))",
        "val _ = computeLib.add_funs distinct_ths"),
    "translator/ml_progLib.sml": (
        "val () = (computeLib.the_compset := computeLib.add_thms [nsLookup_eq] (!computeLib.the_compset))",
        "val () = computeLib.add_funs [nsLookup_eq]"),
}
ASM_PROVE_PREFIX = '''(* Preserve legacy load-time proof with a scoped context policy. *)
fun legacy_library_prove ttac =
  if isSome (Context.current_thy (Context.snapshot())) then Tactical.prove ttac
  else Feedback.trace ("TAC_PROOF requires current theory", 0) Tactical.prove ttac;

'''
THEORY_HEADER = re.compile(
    r"(?m)^Theory[^\n]*\n(?:(?:Ancestors|Libs)[^\n]*\n(?:[ \t]+[^\n]*\n)*)*")
MOD_PREFIX = (
    '(* Preserve the pinned CakeML MOD grammar after ancestor loading. *)\n'
    'val _ = Parse.temp_set_fixity "MOD" (Parse.Infixl 650);\n')


def git(directory: Path, *args: str) -> str:
    return subprocess.check_output(
        ["git", "-C", str(directory), *args], text=True).strip()


def compatible_preamble(original: str) -> str:
    substitutions = (
        ("fun clear_cache_prover gtac  =", "fun clear_cache_prover ctxt gtac  ="),
        ("val res = TAC_PROOF gtac", """val res =
     if isSome (Context.current_thy ctxt) then Tactical.TAC_PROOF_in ctxt gtac
     else Feedback.trace ("TAC_PROOF requires current theory", 0)
            (Tactical.TAC_PROOF_in ctxt) gtac"""),
        ("(*Temporary workaround for cache being slow on long files*)",
         """(* Preserve the MOD precedence used by this CakeML revision. *)
val _ = Parse.set_fixity "MOD" (Infixl 650);
(*Temporary workaround for cache being slow on long files*)"""),
    )
    for before, after in substitutions:
        if original.count(before) != 1:
            raise ValueError("pinned preamble changed; re-audit required")
        original = original.replace(before, after)
    return original


def compatible_theory(original: str) -> str:
    if not re.search(r"\bMOD\b", original):
        return original
    header = THEORY_HEADER.search(original)
    if not header:
        raise ValueError("MOD theory header changed; re-audit required")
    return original[:header.end()] + MOD_PREFIX + original[header.end():]


def compatible_asm_library(original: str) -> str:
    anchor = "val asm_rwts =\n"
    proof = "    prove\n      (“!a b x:'a y. a /\\ (a ==> ~b) ==> ((if b then x else y) = y)”, rw [])"
    if original.count(anchor) != 1 or original.count(proof) != 1:
        raise ValueError("pinned asm library changed; re-audit required")
    return original.replace(anchor, ASM_PROVE_PREFIX + anchor).replace(
        proof, proof.replace("prove\n", "legacy_library_prove\n", 1))


def compatible_evaluator_library(original: str) -> str:
    old = 'Feedback.set_trace "TheoryPP.include_docs" 0'
    if original.count(old) != 1:
        raise ValueError("pinned evaluator trace changed; re-audit required")
    return original.replace(old, 'Feedback.set_trace "TheoryPP.include_html_docs" 0')


def compatible_compute_update(name: str, original: str) -> str:
    before, after = COMPUTE_UPDATES[name]
    if original.count(before) != 1:
        raise ValueError(f"pinned compute update changed in {name}; re-audit required")
    return original.replace(before, after)


def compatible_pattern_termination(original: str) -> str:
    """Retain the accumulator equations and prove their structural measure."""
    before = "  pats_bindings ps (pat_bindings p already_bound)\nEnd"
    after = """  pats_bindings ps (pat_bindings p already_bound)
Termination
  WF_REL_TAC
    `inv_image $< (\\x. case x of
       INL (p,already_bound) => pat_size p
     | INR (ps,already_bound) => list_size pat_size ps)` >>
  simp [listTheory.list_size_def]
End"""
    if original.count(before) != 1:
        raise ValueError("pinned pattern accumulator changed; re-audit required")
    return original.replace(before, after)


def compatible_mlsexp_induction(original: str) -> str:
    """Select exact mutual induction rules; hash-guard each original proof body."""
    repairs = (
        ('lex_aux_sexp2tree', '0f88ad5fd6710a863a42ecf0836239a57493b05ee912e88bdbadf8c2791b5b50', (
            ('Proof\n  Induct',
             'Proof\n  ho_match_mp_tac sexp2tree_ind \\\\ rpt conj_tac'),
            ('(simp [sexp2tree_def]',
             '(gen_tac \\\\ rename1 ‘sexp2tree (Atom m)’\n    \\\\ simp [sexp2tree_def]'),
            ('(rpt gen_tac \\\\ strip_tac',
             '(rpt gen_tac \\\\ strip_tac \\\\ rpt gen_tac \\\\ strip_tac'),
            ('  \\\\ Cases_on ‘xs’',
             '  \\\\ rpt gen_tac \\\\ strip_tac\n  \\\\ rename1 ‘sexp2trees (x::xs)’\n  \\\\ Cases_on ‘xs’'),
        )),
        ('lex_aux_sexp_to_list', 'ccb2a0b673d3782b977bd3b2fcf681acb1947e4d9cdd6af809c3872a05e6aaaa', (
            ('Proof\n  Induct',
             'Proof\n  ho_match_mp_tac sexp_to_app_list_ind \\\\ rpt conj_tac'),
            ('(fs [to_tokens_def]',
             '(gen_tac \\\\ rename1 ‘sexp_to_app_list (Atom m)’\n    \\\\ fs [to_tokens_def]'),
        )),
    )
    for name, expected, replacements in repairs:
        start = original.index("\nProof\n", original.index("Theorem " + name + ":"))
        end = original.index("\nQED", start)
        proof = original[start:end]
        if hashlib.sha256(proof.encode()).hexdigest() != expected:
            raise ValueError("pinned mlsexp proof changed; re-audit required")
        for before, after in replacements:
            if before not in proof:
                raise ValueError("pinned mlsexp proof anchor changed; re-audit required")
            proof = proof.replace(before, after, 1)
        original = original[:start] + proof + original[end:]
    return original


def adaptations(source: Path) -> dict[str, str]:
    result = {PREAMBLE: compatible_preamble((source / PREAMBLE).read_text())}
    result[ASM_LIBRARY] = compatible_asm_library((source / ASM_LIBRARY).read_text())
    result[EVALUATOR_LIBRARY] = compatible_evaluator_library(
        (source / EVALUATOR_LIBRARY).read_text())
    for name in git(source, "ls-files", "*Script.sml").splitlines():
        text = (source / name).read_text()
        adapted = compatible_theory(text)
        if adapted != text:
            result[name] = adapted
    for name in COMPUTE_UPDATES:
        text = result.get(name, (source / name).read_text())
        result[name] = compatible_compute_update(name, text)
    text = result.get(PATTERN_AST, (source / PATTERN_AST).read_text())
    result[PATTERN_AST] = compatible_pattern_termination(text)
    text = result.get(MLSEXP, (source / MLSEXP).read_text())
    result[MLSEXP] = compatible_mlsexp_induction(text)
    return result


def materialize(source: Path, target: Path, expected: str) -> dict:
    source, target = source.resolve(), target.resolve()
    if source == target:
        raise ValueError("derived worktree must differ from pinned source")
    if git(source, "rev-parse", "HEAD") != expected:
        raise ValueError("CakeML source pin mismatch")
    if git(source, "status", "--porcelain", "--untracked-files=no"):
        raise ValueError("pinned CakeML source is dirty")
    rendered = adaptations(source)
    originals = {name: (source / name).read_text() for name in rendered}
    if not target.exists():
        target.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            ["git", "-C", str(source), "worktree", "add", "--detach",
             str(target), expected], check=True)
    if git(target, "rev-parse", "HEAD") != expected:
        raise ValueError("derived worktree pin mismatch")
    unexpected = (
        set(git(target, "diff", "HEAD", "--name-only").splitlines()) -
        set(rendered)
    )
    if unexpected:
        raise ValueError(f"unexpected derived changes: {sorted(unexpected)}")
    for name, adapted in rendered.items():
        file = target / name
        if file.is_symlink() or file.stat().st_nlink != 1:
            raise ValueError(f"derived source is not independent: {name}")
        current = file.read_text()
        if current not in (originals[name], adapted):
            raise ValueError(f"refusing to overwrite derived progress: {name}")
        if current != adapted:
            file.write_text(adapted)
    modified = sorted(rendered)
    observed = git(target, "diff", "HEAD", "--name-only").splitlines()
    if observed != modified:
        raise ValueError("compatibility patch changed unaudited files")
    patch = git(target, "diff", "HEAD", "--", *modified) + "\n"
    return {
        "schema": 1,
        "base_commit": expected,
        "modified_files": modified,
        "source_digests": {
            n: {
                "original": hashlib.sha256(originals[n].encode()).hexdigest(),
                "adapted": hashlib.sha256(rendered[n].encode()).hexdigest(),
            } for n in modified
        },
        "patch_sha256": hashlib.sha256(patch.encode()).hexdigest(),
        "claim": "CakeML/HOL4 compatibility recipe; not proof evidence",
    }


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--source", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--receipt", type=Path, required=True)
    args = p.parse_args()
    expected = json.loads(SPEC.read_text())["cakeml_source"]["commit"]
    receipt = materialize(args.source, args.output, expected)
    args.receipt.parent.mkdir(parents=True, exist_ok=True)
    args.receipt.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    print(json.dumps({
        "patch_sha256": receipt["patch_sha256"],
        "modified_files": len(receipt["modified_files"]),
    }))


if __name__ == "__main__":
    main()
