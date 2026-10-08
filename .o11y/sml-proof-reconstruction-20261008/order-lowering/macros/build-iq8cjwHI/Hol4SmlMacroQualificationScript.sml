Theory Hol4SmlMacroQualification
Ancestors
  Hol4SmlMacro Hol4SmlOrder
Libs
  Hol4SmlMacroLib Hol4ProofSearchLib

val cert = Hol4SmlMacroLib.match
  {scrutinee = ``Var (Short «subject») : exp``,
   clauses = ``[(Plit (IntLit 0),Lit (IntLit 10));
                (Plit (IntLit 1),Lit (IntLit 20))]``,
   exception_id = ``Short «sml_match_exception» : (mlstring,mlstring) id``};
val _ = save_thm ("generated_match_expansion", #expansion cert);
val _ = save_thm ("generated_match_semantics", #semantics cert);

val fn_cert = Hol4SmlMacroLib.multi_fn
  {parameter = ``«subject»``,
   clauses = ``[(Plit (IntLit 0),Lit (IntLit 10));
                (Plit (IntLit 1),Lit (IntLit 20))]``,
   exception_id = ``Short «sml_match_exception» : (mlstring,mlstring) id``};
val _ = save_thm ("generated_fn_expansion", #expansion fn_cert);
val _ = save_thm ("generated_fn_closure", #semantics fn_cert);

val app_cert = Hol4SmlMacroLib.multi_fn_application
  {parameter = ``«subject»``,
   clauses = ``[(Plit (IntLit 0),Lit (IntLit 10));
                (Plit (IntLit 1),Lit (IntLit 20))]``,
   exception_id = ``Short «sml_match_exception» : (mlstring,mlstring) id``,
   argument_id = ``Short «argument» : (mlstring,mlstring) id``};
val _ = save_thm ("generated_fn_application_expansion", #expansion app_cert);
val _ = save_thm ("generated_fn_application_semantics", #semantics app_cert);

val seq_cert = Hol4SmlMacroLib.sequence_list
  {prefixes = ``[Lit (IntLit 1);Lit (IntLit 2)]``,
   result_exp = ``Lit (IntLit 3) : exp``};
val _ = save_thm ("generated_sequence_list_expansion",#expansion seq_cert);
val _ = save_thm ("generated_sequence_list_semantics",#semantics seq_cert);

val tuple_cert = Hol4SmlMacroLib.constructor_ltr
  {constructor_id = ``NONE : ((mlstring,mlstring) id) option``,
   operands = ``[Lit (IntLit 1);Lit (IntLit 2);Lit (IntLit 3)]``};
val _ = save_thm ("generated_constructor_ltr_expansion",#expansion tuple_cert);
val _ = save_thm ("generated_constructor_ltr_semantics",#semantics tuple_cert);

val ltr_app_cert = Hol4SmlMacroLib.application_ltr
  {function_exp = ``Fun «ignored» (Var (Short «hol4_sml_capture_0»))``,
   argument_exp = ``Lit (IntLit 7) : exp``};
val _ = save_thm ("generated_application_ltr_expansion",#expansion ltr_app_cert);
val _ = save_thm ("generated_application_ltr_semantics",#semantics ltr_app_cert);

val path = case OS.Process.getEnv "HOL4_MACRO_REWRITES" of
  SOME p => p | NONE => raise Fail "HOL4_MACRO_REWRITES is required";
val (rewrite_engine,seq_th) = Hol4ProofSearchLib.prove_with_search_file
  {name = "sequence-replay",
   goal = ``evaluate st env [Let NONE e1 e2] =
            sml_sequence_reference st env e1 e2``,
   egglog_rewrites_path = path};
val _ = if rewrite_engine = "egglog-replay" then ()
        else raise Fail "Egglog's named macro candidate did not replay";
val _ = save_thm ("egglog_sequence_replay",seq_th);

fun replay_order name goal =
  let val (engine,th) = Hol4ProofSearchLib.prove_with_search_file
        {name = name,goal = goal,egglog_rewrites_path = path}
      val _ = if engine = "egglog-replay" then ()
              else raise Fail ("operand-order candidate did not replay: " ^ name)
  in th end;
val _ = save_thm ("egglog_constructor_ltr_replay",replay_order "constructor-order"
  ``ALL_DISTINCT names /\ LENGTH names = LENGTH es /\
    do_con_check env.c cn (LENGTH es) ==>
    evaluate st env [lower_sml_con_ltr cn es names] =
    sml_con_ltr_reference st env cn es``);
val _ = save_thm ("egglog_application_ltr_replay",replay_order "application-order"
  ``ALL_DISTINCT names /\ LENGTH names = LENGTH es ==>
    evaluate st env [lower_sml_application_ltr es names] =
    sml_application_ltr_reference st env es``);

(* Reconstruction, not the oracle variant of the tactic. *)
val z3_goal = ``!clock:num. 0 < clock ==> clock - 1 < clock``;
val z3_th = prove (z3_goal,HolSmtLib.Z3_TAC);
val _ = Hol4ProofSearchLib.inspect_exact "clock-step" z3_goal z3_th;
val _ = save_thm ("z3_clock_step",z3_th);

val _ = tacticToe.set_timeout 30.0;
val ttt_goal = ``!clauses:(pat # exp) list.
  LENGTH (clauses ++ [(Pany,Raise (Var (Short «sml_match_exception»)))]) =
  LENGTH clauses + 1``;
val ttt_th = prove (ttt_goal,tacticToe.ttt);
val _ = Hol4ProofSearchLib.inspect_exact "fallback-clause-count" ttt_goal ttt_th;
val _ = save_thm ("tactictoe_clause_count",ttt_th);

val _ = print ("HOL4_MACRO_SEARCH_CHECKED " ^ rewrite_engine ^
               " z3-reconstruction tactictoe\n");
val _ = export_theory();
