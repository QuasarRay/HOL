(* S06: preserve left-to-right operand effects without extending the operand
   environments. Source expressions are evaluated before capture variables
   are bound. This avoids capturing a temporary inside a returned closure.
   SML97 source elaboration and the source/value relation remain separate. *)
Theory Hol4SmlOrder
Ancestors
  evaluate semanticPrimitives ast namespace evaluateProps namespaceProps
  list rich_list alist

Definition lower_sml_sequence_list_def:
  lower_sml_sequence_list es result_exp =
    FOLDR (\first rest. Let NONE first rest) result_exp es
End

Definition sml_sequence_list_reference_def:
  (sml_sequence_list_reference st env [] result_exp = evaluate st env [result_exp]) /\
  (sml_sequence_list_reference st env (first::rest) result_exp =
    case fix_clock st (evaluate st env [first]) of
      (st',Rval vs) => sml_sequence_list_reference st' env rest result_exp
    | (st',Rerr err) => (st',Rerr err))
End

(* SML97 app1.tex, Derived forms of Expressions, expands a sequence to
   nested cases with wildcard patterns. This theorem checks that normalized
   shape in the actual target evaluator, including propagation of exceptions. *)
Definition sml_sequence_list_derived_def:
  sml_sequence_list_derived es result_exp =
    FOLDR (\first rest. Mat first [(Pany,rest)]) result_exp es
End

Theorem lower_sml_sequence_list_correct:
  !es st env result_exp.
  evaluate st env [lower_sml_sequence_list es result_exp] =
  sml_sequence_list_reference st env es result_exp
Proof
  Induct >> simp [lower_sml_sequence_list_def,sml_sequence_list_reference_def,
                 evaluate_def,nsOptBind_def,fix_clock_evaluate] >>
  rpt gen_tac >> rpt (CASE_TAC >> fs [lower_sml_sequence_list_def])
QED

Theorem derived_sequence_list_correct:
  !es st env result_exp.
  evaluate st env [sml_sequence_list_derived es result_exp] =
  sml_sequence_list_reference st env es result_exp
Proof
  Induct >> simp [sml_sequence_list_derived_def,sml_sequence_list_reference_def,
                 evaluate_def,can_pmatch_all_def,pmatch_def,pat_bindings_def,
                 fix_clock_evaluate] >>
  rpt gen_tac >> rpt (CASE_TAC >> fs [sml_sequence_list_derived_def])
QED

Theorem lower_sequence_matches_derived_form:
  evaluate st env [lower_sml_sequence_list es result_exp] =
  evaluate st env [sml_sequence_list_derived es result_exp]
Proof
  simp [lower_sml_sequence_list_correct,derived_sequence_list_correct]
QED

Definition lower_sml_con_ltr_def:
  lower_sml_con_ltr cn es names =
    Mat (Con NONE (REVERSE es))
      [(Pcon NONE (MAP Pvar (REVERSE names)),
        Con cn (MAP (\n. Var (Short n)) names))]
End

Definition lower_sml_application_ltr_def:
  lower_sml_application_ltr es names =
    Mat (Con NONE (REVERSE es))
      [(Pcon NONE (MAP Pvar (REVERSE names)),
        App Opapp (MAP (\n. Var (Short n)) names))]
End

Definition sml_application_ltr_reference_def:
  sml_application_ltr_reference st env es =
    case fix_clock st (evaluate st env es) of
      (st',Rval vs) =>
        (case do_opapp vs of
           NONE => (st',Rerr (Rabort Rtype_error))
         | SOME (call_env,body) =>
             if st'.clock = 0 then (st',Rerr (Rabort Rtimeout_error))
             else evaluate (dec_clock st') call_env [body])
    | (st',Rerr err) => (st',Rerr err)
End

(* The state and exception conventions in SML97 dyncor.tex and its expression
   rows require operand evaluation in source order. The reference uses the
   target representations of already elaborated operands and constructors. *)
Definition sml_con_ltr_reference_def:
  sml_con_ltr_reference st env cn es =
    case evaluate st env es of
      (st',Rval vs) =>
        (case build_conv env.c cn vs of
           NONE => (st',Rerr (Rabort Rtype_error))
         | SOME value => (st',Rval [value]))
    | (st',Rerr err) => (st',Rerr err)
End

Theorem pmatch_capture_variables:
  !names values acc.
  LENGTH names = LENGTH values ==>
  pmatch_list c refs (MAP Pvar names) values acc =
  Match (REVERSE (ZIP (names,values)) ++ acc)
Proof
  Induct >> Cases_on `values` >>
  simp [pmatch_def,ZIP,REVERSE_DEF,APPEND_ASSOC]
QED

Theorem capture_pattern_bindings:
  !names. pats_bindings (MAP Pvar names) = REVERSE names
Proof
  Induct >> simp [pat_bindings_def]
QED

Theorem evaluate_variable_list:
  !names values st env.
  LIST_REL (\name value. nsLookup env.v (Short name) = SOME value)
    names values ==>
  evaluate st env (MAP (\name. Var (Short name)) names) = (st,Rval values)
Proof
  Induct >> Cases_on `values` >>
  simp [evaluate_cons,evaluate_def] >> rpt strip_tac >> res_tac >> fs []
QED

Theorem captured_variable_lookups:
  ALL_DISTINCT names /\ LENGTH names = LENGTH values ==>
  LIST_REL (\name value.
    nsLookup (nsAppend (alist_to_ns (ZIP (names,values))) base)
      (Short name) = SOME value) names values
Proof
  rw [LIST_REL_EL_EQN] >>
  `ALOOKUP (ZIP (names,values)) (EL n names) = SOME (EL n values)`
    by (mp_tac (Q.SPECL [`ZIP (names,values)`,`n`] ALOOKUP_ALL_DISTINCT_EL) >>
        simp [MAP_ZIP,EL_ZIP]) >>
  metis_tac [nsLookup_nsAppend_some,nsLookup_alist_to_ns_some]
QED

Theorem construct_from_variable_list:
  LIST_REL (\name value. nsLookup env.v (Short name) = SOME value)
    names values /\ do_con_check env.c cn (LENGTH names) ==>
  evaluate st env [Con cn (MAP (\name. Var (Short name)) names)] =
  case build_conv env.c cn values of
    NONE => (st,Rerr (Rabort Rtype_error))
  | SOME value => (st,Rval [value])
Proof
  rpt strip_tac >>
  `LIST_REL (\name value. nsLookup env.v (Short name) = SOME value)
     (REVERSE names) (REVERSE values)` by simp [] >>
  imp_res_tac evaluate_variable_list >>
  simp [evaluate_def,GSYM MAP_REVERSE,evaluate_variable_list]
QED

Theorem lower_sml_con_ltr_correct:
  ALL_DISTINCT names /\ LENGTH names = LENGTH es /\
  do_con_check env.c cn (LENGTH es) ==>
  evaluate st env [lower_sml_con_ltr cn es names] =
  sml_con_ltr_reference st env cn es
Proof
  rpt strip_tac >>
  simp [lower_sml_con_ltr_def,sml_con_ltr_reference_def,evaluate_def,
        do_con_check_def,build_conv_def,fix_clock_evaluate] >>
  Cases_on `evaluate st env es` >> Cases_on `r` >> fs [] >>
  rename1 `evaluate st env es = (operand_state,Rval operand_values)` >>
  imp_res_tac evaluate_length >>
  simp [can_pmatch_all_def,pmatch_def,pmatch_capture_variables,
        pat_bindings_def,capture_pattern_bindings,REVERSE_ZIP] >>
  `LIST_REL (\name value.
     nsLookup (nsAppend (alist_to_ns (ZIP (names,operand_values))) env.v)
       (Short name) = SOME value) names operand_values`
    by metis_tac [captured_variable_lookups] >>
  mp_tac (Q.INST
    [`env` |-> `env with v := nsAppend (alist_to_ns (ZIP (names,operand_values))) env.v`,
     `values` |-> `operand_values`, `st` |-> `operand_state`]
    (SPEC_ALL construct_from_variable_list)) >>
  simp [build_conv_def,do_con_check_def,evaluate_def,GSYM MAP_REVERSE] >>
  fs [do_con_check_def]
QED

Theorem apply_from_variable_list:
  LIST_REL (\name value. nsLookup env.v (Short name) = SOME value)
    names values ==>
  evaluate st env [App Opapp (MAP (\name. Var (Short name)) names)] =
  case do_opapp values of
    NONE => (st,Rerr (Rabort Rtype_error))
  | SOME (call_env,body) =>
      if st.clock = 0 then (st,Rerr (Rabort Rtimeout_error))
      else evaluate (dec_clock st) call_env [body]
Proof
  rpt strip_tac >>
  `LIST_REL (\name value. nsLookup env.v (Short name) = SOME value)
     (REVERSE names) (REVERSE values)` by simp [] >>
  imp_res_tac evaluate_variable_list >>
  simp [evaluate_def,GSYM MAP_REVERSE,evaluate_variable_list,fix_clock_def,
        getOpClass_def]
QED

Theorem lower_sml_application_ltr_correct:
  ALL_DISTINCT names /\ LENGTH names = LENGTH es ==>
  evaluate st env [lower_sml_application_ltr es names] =
  sml_application_ltr_reference st env es
Proof
  rpt strip_tac >>
  simp [lower_sml_application_ltr_def,sml_application_ltr_reference_def,
        evaluate_def,do_con_check_def,build_conv_def,fix_clock_evaluate] >>
  Cases_on `evaluate st env es` >> Cases_on `r` >> fs [] >>
  rename1 `evaluate st env es = (operand_state,Rval operand_values)` >>
  imp_res_tac evaluate_length >>
  simp [can_pmatch_all_def,pmatch_def,pmatch_capture_variables,
        pat_bindings_def,capture_pattern_bindings,REVERSE_ZIP] >>
  `LIST_REL (\name value.
     nsLookup (nsAppend (alist_to_ns (ZIP (names,operand_values))) env.v)
       (Short name) = SOME value) names operand_values`
    by metis_tac [captured_variable_lookups] >>
  mp_tac (Q.INST
    [`env` |-> `env with v := nsAppend (alist_to_ns (ZIP (names,operand_values))) env.v`,
     `values` |-> `operand_values`, `st` |-> `operand_state`]
    (SPEC_ALL apply_from_variable_list)) >>
  simp [evaluate_def,GSYM MAP_REVERSE,fix_clock_def,getOpClass_def]
QED

Theorem lowered_tuple_raises_first:
  nsLookup env.v first_id = SOME first_value ==>
  evaluate st env
    [lower_sml_con_ltr NONE [Raise (Var first_id);Raise (Var second_id)]
       [«left»;«right»]] = (st,Rerr (Rraise first_value))
Proof
  simp [lower_sml_con_ltr_def,evaluate_def,do_con_check_def]
QED

Theorem lowered_tuple_keeps_value_order:
  evaluate st env
    [lower_sml_con_ltr NONE [Lit (IntLit 1);Lit (IntLit 2);Lit (IntLit 3)]
       [«left»;«middle»;«right»]] =
  (st,Rval [Conv NONE [Litv (IntLit 1);Litv (IntLit 2);Litv (IntLit 3)]])
Proof
  simp [lower_sml_con_ltr_correct,sml_con_ltr_reference_def,evaluate_def,
        do_con_check_def,build_conv_def]
QED

Theorem source_closure_environment_is_preserved:
  nsLookup env.v (Short «hol4_sml_capture_0») = SOME (Litv (IntLit 41)) /\
  0 < st.clock ==>
  evaluate st env
    [lower_sml_application_ltr
       [Fun «ignored» (Var (Short «hol4_sml_capture_0»));Lit (IntLit 7)]
       [«hol4_sml_capture_0»;«hol4_sml_capture_1»]] =
  (dec_clock st,Rval [Litv (IntLit 41)])
Proof
  rpt strip_tac >>
  simp [lower_sml_application_ltr_correct,sml_application_ltr_reference_def,
        evaluate_def,do_opapp_def,do_con_check_def,build_conv_def,
        fix_clock_def,nsLookup_nsBind] >>
  Cases_on `st.clock = 0` >> fs []
QED

val _ = List.app (fn th =>
  let val (oracles,axioms) = Tag.dest_tag (Thm.tag th)
  in if null (Thm.hyp th) andalso null axioms andalso
        List.all (fn tag => tag = "DISK_THM") oracles then ()
     else raise Fail "unclean operand-order theorem"
  end)
  [lower_sml_sequence_list_correct,derived_sequence_list_correct,
   lower_sequence_matches_derived_form,pmatch_capture_variables,
   capture_pattern_bindings,evaluate_variable_list,captured_variable_lookups,
   construct_from_variable_list,lower_sml_con_ltr_correct,
   apply_from_variable_list,lower_sml_application_ltr_correct,
   lowered_tuple_raises_first,lowered_tuple_keeps_value_order,
   source_closure_environment_is_preserved];
val _ = export_theory ();
