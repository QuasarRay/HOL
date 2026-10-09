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
PRIMITIVES_PROPS = "semantics/proofs/semanticPrimitivesPropsScript.sml"
TYPE_SYS_PROPS = "semantics/proofs/typeSysPropsScript.sml"
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


def compatible_pattern_accumulator_proof(original: str) -> str:
    """Generalize accumulator induction without changing its equation theorem."""
    start = original.index("\nProof\n", original.index("Theorem pat_bindings_accum:"))
    end = original.index("\nQED", start)
    expected = '5d73fc22c1ada5f60bb7375f5105bdd9d11fecbe26a6daeb9669a75f14f85757'
    if hashlib.sha256(original[start:end].encode()).hexdigest() != expected:
        raise ValueError("pinned accumulator proof changed; re-audit required")
    proof = r'''
Proof
  match_mp_tac (pat_bindings_ind |> Q.SPECL
    [‘λp ignored. ∀acc. pat_bindings p acc = pat_bindings p [] ++ acc’,
     ‘λps ignored. ∀acc. pats_bindings ps acc = pats_bindings ps [] ++ acc’]
    |> SIMP_RULE std_ss [])
  \\ rpt conj_tac \\ rpt strip_tac
  \\ simp_tac std_ss [pat_bindings_def]
  \\ (fn (asl,w) => once_rewrite_tac (map ASSUME asl) (asl,w))
  \\ (fn (asl,w) => once_rewrite_tac (map ASSUME asl) (asl,w))
  \\ simp_tac std_ss [APPEND, GSYM APPEND_ASSOC]'''
    return original[:start] + proof + original[end:]


def compatible_type_system_induction(original: str) -> str:
    """Restore nested-list induction proof rules; all original contracts remain."""
    expected = '386db51efb9a74274dd9ecc594eb3f6d6219620ed6b6885ee3b5a723735ca7d6'
    if hashlib.sha256(original.encode()).hexdigest() != expected:
        raise ValueError("pinned type-system proof source changed; re-audit required")
    repairs = (
        (r'''
Proof
ho_match_mp_tac t_induction >>
srw_tac[][deBruijn_inc_def] >>
metis_tac []''', r'''
Proof
  ‘∀t sk. deBruijn_inc sk 0 t = t’ by
    (ho_match_mp_tac t_induction >> rw [deBruijn_inc_def] >>
     fs [MAP_EQ_ID]) >>
  rw [MAP_EQ_ID]'''),
        (r'''
Proof
ho_match_mp_tac t_induction >>
srw_tac[][deBruijn_subst_def, deBruijn_inc_def] >>
full_simp_tac(srw_ss())[EL_MAP, MAP_MAP_o, combinTheory.o_DEF] >>
srw_tac[][] >>
full_simp_tac (srw_ss()++ARITH_ss) [deBruijn_subst_def, check_freevars_def] >>
metis_tac []''', r'''
Proof
ho_match_mp_tac t_list_induction >>
srw_tac[][deBruijn_subst_def, deBruijn_inc_def] >>
full_simp_tac(srw_ss())[EL_MAP, MAP_MAP_o, combinTheory.o_DEF] >>
srw_tac[][] >>
full_simp_tac (srw_ss()++ARITH_ss) [deBruijn_subst_def, check_freevars_def] >>
metis_tac []'''),
        (r'''
Proof
Induct >>
srw_tac[][deBruijn_subst_def, LENGTH_COUNT_LIST, EL_MAP, EL_COUNT_LIST,
    check_freevars_def] >>
metis_tac []''', r'''
Proof
ho_match_mp_tac t_list_induction >>
srw_tac[][deBruijn_subst_def, LENGTH_COUNT_LIST, EL_MAP, EL_COUNT_LIST,
    check_freevars_def] >>
metis_tac []'''),
        (r'''
Proof
 Induct >>
 rw [] >>
 ONCE_REWRITE_TAC [type_p_cases] >>
 simp [] >>
 metis_tac []''', r'''
Proof
 ho_match_mp_tac pat_list_induction >>
 rw [] >>
 ONCE_REWRITE_TAC [type_p_cases] >>
 simp [] >>
 metis_tac []'''),
        (r'''
Proof
ho_match_mp_tac t_induction >>
srw_tac[][deBruijn_subst_def, deBruijn_inc_def] >>
full_simp_tac (srw_ss()++ARITH_ss) [] >>
metis_tac []''', r'''
Proof
ho_match_mp_tac t_list_induction >>
srw_tac[][deBruijn_subst_def, deBruijn_inc_def] >>
full_simp_tac (srw_ss()++ARITH_ss) [] >>
metis_tac []'''),
    )
    for before, after in repairs:
        if original.count(before) != 1:
            raise ValueError("type-system proof anchor changed; re-audit required")
        original = original.replace(before, after)
    split = original.index("Theorem deBruijn_subst2:")
    original = original[:split] + original[split:].replace(
        "ho_match_mp_tac t_induction", "ho_match_mp_tac t_list_induction")
    original = original.replace('Theorem deBruijn_subst2:', r'''val t_list_induction = prove (
  “∀P Q.
    (∀v. P (Tvar v)) ∧ (∀n. P (Tvar_db n)) ∧
    (∀ts tn. Q ts ⇒ P (Tapp ts tn)) ∧ Q [] ∧
    (∀t ts. P t ∧ Q ts ⇒ Q (t::ts)) ⇒
    (∀t. P t) ∧ (∀ts. Q ts)”,
  rpt gen_tac >> strip_tac >>
  ‘∀ts. (∀t. MEM t ts ⇒ P t) ⇒ Q ts’ by
    (Induct >> rw [] >> metis_tac []) >>
  ‘∀t. P t’ by
    (ho_match_mp_tac t_induction >> rw [] >> metis_tac []) >>
  metis_tac []);

''' + 'Theorem deBruijn_subst2:', 1)
    original = original.replace('Theorem type_p_tenvV_indep:', r'''val pat_list_induction = pat_bindings_ind |> Q.SPECL
  [‘λp ignored. P p’, ‘λps ignored. Q ps’]
  |> SIMP_RULE std_ss [] |> GEN_ALL;

''' + 'Theorem type_p_tenvV_indep:', 1)
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
    text = result.get(PRIMITIVES_PROPS, (source / PRIMITIVES_PROPS).read_text())
    result[PRIMITIVES_PROPS] = compatible_pattern_accumulator_proof(text)
    text = (source / TYPE_SYS_PROPS).read_text()
    result[TYPE_SYS_PROPS] = compatible_type_system_induction(text)
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
