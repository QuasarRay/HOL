Theory Hol4SmlMacroQualification
Ancestors
  Hol4SmlMacro Hol4SmlApplication
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

val left_cert = Hol4SmlMacroLib.left_application
  {function_name = ``«application_function»``,
   argument_name = ``«application_argument»``,
   function_exp = ``Var (Short «function») : exp``,
   argument_exp = ``Lit (IntLit 7) : exp``};
val _ = save_thm ("generated_left_application_expansion", #expansion left_cert);
val left_semantics = SIMP_RULE (srw_ss())
  [literal_argument_binding_stable] (#semantics left_cert);
val _ = if is_eq (concl left_semantics) then ()
        else raise Fail "literal application side conditions were not discharged";
val _ = save_thm ("generated_left_application_semantics", left_semantics);

val variable_cert = Hol4SmlMacroLib.left_application
  {function_name = ``«application_function»``,
   argument_name = ``«application_argument»``,
   function_exp = ``Var (Short «function») : exp``,
   argument_exp = ``Var (Short «argument») : exp``};
val _ = save_thm ("generated_variable_application_expansion", #expansion variable_cert);
val variable_semantics = SIMP_RULE (srw_ss())
  [variable_argument_binding_stable] (#semantics variable_cert);
val _ = if is_eq (concl variable_semantics) then ()
        else raise Fail "variable application side conditions were not discharged";
val _ = save_thm ("generated_variable_application_semantics", variable_semantics);

val sequence_cert = Hol4SmlMacroLib.sequence
  {first_exp = ``Lit (IntLit 1) : exp``, second_exp = ``Lit (IntLit 2) : exp``};
val _ = save_thm ("generated_sequence_expansion", #expansion sequence_cert);
val _ = save_thm ("generated_sequence_semantics", #semantics sequence_cert);

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

val application_path = case OS.Process.getEnv "HOL4_APPLICATION_REWRITES" of
  SOME p => p | NONE => raise Fail "HOL4_APPLICATION_REWRITES is required";
val application_goal =
  ``fname <> aname /\ argument_binding_stable st env fname aexp ==>
    evaluate st env [lower_sml_left_application fname aname fexp aexp] =
    sml_left_application_reference st env fexp aexp``;
val (application_engine,application_th) = Hol4ProofSearchLib.prove_with_search_file
  {name = "left-application-replay", goal = application_goal,
   egglog_rewrites_path = application_path};
val _ = if application_engine = "egglog-replay" then ()
        else raise Fail "Egglog's application hint did not replay with its conditions";
val _ = save_thm ("egglog_application_replay",application_th);

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
