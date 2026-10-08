(* Proof-generating, typed AST macros. In particular, match's lookup
   precondition stays in the theorem; this library never erases it. *)
structure Hol4SmlMacroLib :> Hol4SmlMacroLib =
struct
open HolKernel boolLib bossLib Hol4SmlMacroTheory;
type certificate = {expanded : term, expansion : thm, semantics : thm};

fun instantiate bindings th =
  let val base = SPEC_ALL th
      val vars = free_vars (concl base)
      fun binding (name,tm) =
        case List.find (fn v => #1 (dest_var v) = name) vars of
          NONE => raise Fail ("macro theorem has no parameter: " ^ name)
        | SOME v => v |-> tm
  in INST (List.map binding bindings) base end;

fun certificate expansion semantics =
  let val (oracles,axioms) = Tag.dest_tag (Thm.tag semantics)
      val _ = if null (hyp semantics) andalso null axioms andalso
                 List.all (fn s => s = "DISK_THM") oracles then ()
              else raise Fail "unclean macro theorem"
  in {expanded = rhs (concl expansion), expansion = expansion,
      semantics = semantics} end;

fun match {scrutinee,clauses,exception_id} =
  certificate
    (REWRITE_CONV [lower_sml_match_def]
      ``lower_sml_match ^scrutinee ^clauses ^exception_id``)
    (instantiate [("scrut",scrutinee),("clauses",clauses),("match_id",exception_id)]
      lower_sml_match_correct);

fun multi_fn {parameter,clauses,exception_id} =
  certificate
    (REWRITE_CONV [lower_sml_multifn_def,lower_sml_match_def]
      ``lower_sml_multifn ^parameter ^clauses ^exception_id``)
    (instantiate [("arg",parameter),("clauses",clauses),("match_id",exception_id)]
      lower_sml_multifn_closure);

fun multi_fn_application {parameter,clauses,exception_id,argument_id} =
  certificate
    (REWRITE_CONV [lower_sml_multifn_application_def,
                  lower_sml_multifn_def,lower_sml_match_def]
      ``lower_sml_multifn_application ^parameter ^clauses ^exception_id ^argument_id``)
    (instantiate [("arg",parameter),("clauses",clauses),("match_id",exception_id),
                  ("value_id",argument_id)] lower_sml_multifn_application_correct);

fun sequence {first_exp,second_exp} =
  let val expanded = ``Let NONE ^first_exp ^second_exp``
  in certificate (REFL expanded)
       (instantiate [("e1",first_exp),("e2",second_exp)] lower_sml_sequence_correct)
  end;
end
