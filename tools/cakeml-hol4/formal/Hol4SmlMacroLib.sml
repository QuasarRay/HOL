(* Proof-generating, typed AST macros. In particular, match's lookup
   precondition stays in the theorem; this library never erases it. *)
structure Hol4SmlMacroLib :> Hol4SmlMacroLib =
struct
open HolKernel boolLib bossLib Hol4SmlMacroTheory Hol4SmlApplicationTheory;
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
  let fun inspect th =
        let val (oracles,axioms) = Tag.dest_tag (Thm.tag th)
        in if null (hyp th) andalso null axioms andalso
              List.all (fn s => s = "DISK_THM") oracles then ()
           else raise Fail "unclean macro theorem" end
      val _ = inspect expansion
      val _ = inspect semantics
      (* Attach the checked semantic theorem to the exact expanded AST. *)
      val semantics =
        if aconv (lhs (concl expansion)) (rhs (concl expansion)) then semantics
        else REWRITE_RULE [expansion] semantics
      val _ = inspect semantics
      val expanded = rhs (concl expansion)
      val (_,body) = strip_imp (concl semantics)
      val (head,args) = strip_comb (lhs body)
      val {Thy,Name,...} = dest_thy_const head
      val (expressions,_) = listSyntax.dest_list (List.last args)
      val _ = if Thy = "evaluate" andalso Name = "evaluate" andalso
                 length expressions = 1 andalso aconv (hd expressions) expanded
              then () else raise Fail "semantic certificate does not describe the expanded AST"
  in {expanded = expanded, expansion = expansion,
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

fun left_application {function_name,argument_name,function_exp,argument_exp} =
  certificate
    (REWRITE_CONV [lower_sml_left_application_def]
      ``lower_sml_left_application ^function_name ^argument_name
                                  ^function_exp ^argument_exp``)
    (instantiate [("fname",function_name),("aname",argument_name),
                  ("fexp",function_exp),("aexp",argument_exp)]
      lower_sml_left_application_correct);
end
