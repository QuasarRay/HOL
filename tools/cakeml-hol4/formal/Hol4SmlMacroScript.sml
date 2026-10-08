(* Normalized-core contracts. The SML97 correspondence for elaboration,
   typing, identifiers and patterns is a separate, still open obligation.
   These rules reuse CakeML's actual operational semantics, not a toy evaluator. *)
Theory Hol4SmlMacro
Ancestors
  evaluate semanticPrimitives ast namespace namespaceProps

Definition sml_match_reference_def:
  sml_match_reference st env scrut clauses match_value =
    case fix_clock st (evaluate st env [scrut]) of
      (st',Rval vs) =>
        if can_pmatch_all env.c st'.refs (MAP FST clauses) (HD vs) then
          evaluate_match st' env (HD vs) clauses match_value
        else (st',Rerr (Rabort Rtype_error))
    | (st',Rerr err) => (st',Rerr err)
End

Definition lower_sml_match_def:
  lower_sml_match scrut clauses match_id =
    Mat scrut (clauses ++ [(Pany,Raise (Var match_id))])
End

Definition lower_sml_multifn_def:
  lower_sml_multifn arg clauses match_id =
    Fun arg (lower_sml_match (Var (Short arg)) clauses match_id)
End

Definition sml_sequence_reference_def:
  sml_sequence_reference st env e1 e2 =
    case fix_clock st (evaluate st env [e1]) of
      (st',Rval vs) => evaluate st' env [e2]
    | (st',Rerr err) => (st',Rerr err)
End

Theorem can_pmatch_all_fallback:
  can_pmatch_all c refs (ps ++ [Pany]) value =
  can_pmatch_all c refs ps value
Proof
  Induct_on `ps` >> simp [can_pmatch_all_def,pmatch_def]
QED

Theorem evaluate_match_fallback:
  nsLookup env.v match_id = SOME match_value ==>
  evaluate_match st env value
    (clauses ++ [(Pany,Raise (Var match_id))]) bind_exn_v =
  evaluate_match st env value clauses match_value
Proof
  Induct_on `clauses` >>
  simp [evaluate_def,pat_bindings_def,pmatch_def] >>
  rpt gen_tac >> Cases_on `h` >> simp [evaluate_def] >>
  rpt strip_tac >> rpt (CASE_TAC >> fs [])
QED

Theorem lower_sml_match_correct:
  nsLookup env.v match_id = SOME match_value ==>
  evaluate st env [lower_sml_match scrut clauses match_id] =
  sml_match_reference st env scrut clauses match_value
Proof
  rpt strip_tac >>
  simp [lower_sml_match_def,sml_match_reference_def,evaluate_def,fix_clock_evaluate,
        can_pmatch_all_fallback] >>
  Cases_on `evaluate st env [scrut]` >> Cases_on `r` >>
  fs [] >> IF_CASES_TAC >> fs [] >> metis_tac [evaluate_match_fallback]
QED

Theorem lower_sml_multifn_closure:
  evaluate st env [lower_sml_multifn arg clauses match_id] =
  (st,Rval [Closure env arg
    (lower_sml_match (Var (Short arg)) clauses match_id)])
Proof
  simp [lower_sml_multifn_def,evaluate_def]
QED

Definition lower_sml_multifn_application_def:
  lower_sml_multifn_application arg clauses match_id value_id =
    App Opapp [lower_sml_multifn arg clauses match_id; Var value_id]
End

(* Application, rather than closure construction alone. The exception lookup
   is checked after parameter binding: a parameter must not silently shadow
   the chosen Match exception. Full SML97 elaboration/freshness is separate. *)
Theorem lower_sml_multifn_application_correct:
  nsLookup env.v value_id = SOME value /\
  nsLookup (nsBind arg value env.v) match_id = SOME match_value ==>
  evaluate st env
    [lower_sml_multifn_application arg clauses match_id value_id] =
  if st.clock = 0 then (st,Rerr (Rabort Rtimeout_error))
  else sml_match_reference (dec_clock st)
         (env with v := nsBind arg value env.v)
         (Var (Short arg)) clauses match_value
Proof
  rpt strip_tac >>
  simp [lower_sml_multifn_application_def,lower_sml_multifn_def,
        evaluate_def,do_opapp_def] >>
  IF_CASES_TAC >> simp [lower_sml_match_correct]
QED

Theorem lower_sml_sequence_correct:
  evaluate st env [Let NONE e1 e2] =
  sml_sequence_reference st env e1 e2
Proof
  `env with v := env.v = env` by simp [sem_env_component_equality] >>
  simp [evaluate_def,sml_sequence_reference_def,nsOptBind_def,fix_clock_evaluate]
QED

(* This is the actual semantic discrepancy identified by S04/S05; equality
   kinds and SML static rejection are not implemented by this theorem. *)
Theorem cakeml_function_equality:
  do_eq (Closure env1 arg1 body1) (Closure env2 arg2 body2) = Eq_val T
Proof
  simp [do_eq_def]
QED

Theorem cakeml_empty_match_raises_bind:
  evaluate_match st env value [] bind_exn_v =
  (st,Rerr (Rraise bind_exn_v))
Proof
  simp [evaluate_def]
QED

(* A matched body's Bind is deliberately preserved by the appended wildcard.
   A global handler rewriting Bind to Match would be unsound. *)
Theorem matched_body_bind_is_preserved:
  evaluate_match st env value
    [(Pany,Raise (Con (SOME (Short «Bind»)) []));
     (Pany,Raise (Var match_id))] bind_exn_v =
  evaluate_match st env value
    [(Pany,Raise (Con (SOME (Short «Bind»)) []))] match_value
Proof
  simp [evaluate_def,pat_bindings_def,pmatch_def]
QED

val _ = List.app
  (fn (name,th) =>
    let val (oracles,axioms) = Tag.dest_tag (Thm.tag th)
    in if null (Thm.hyp th) andalso null axioms andalso
          List.all (fn x => x = "DISK_THM") oracles then ()
       else raise Fail ("unacceptable macro theorem: " ^ name)
    end)
  [("lower_sml_match_correct",lower_sml_match_correct),
   ("lower_sml_sequence_correct",lower_sml_sequence_correct),
   ("evaluate_match_fallback",evaluate_match_fallback),
   ("matched_body_bind_is_preserved",matched_body_bind_is_preserved),
   ("can_pmatch_all_fallback",can_pmatch_all_fallback),
   ("lower_sml_multifn_closure",lower_sml_multifn_closure),
   ("lower_sml_multifn_application_correct",lower_sml_multifn_application_correct),
   ("cakeml_function_equality",cakeml_function_equality),
   ("cakeml_empty_match_raises_bind",cakeml_empty_match_raises_bind)];
val _ = export_theory();
