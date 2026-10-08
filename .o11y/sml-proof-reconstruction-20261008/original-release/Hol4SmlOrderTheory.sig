signature Hol4SmlOrderTheory =
sig
  type thm = Thm.thm
  
  (*  Definitions  *)
    val lower_sml_application_ltr_def : thm
    val lower_sml_con_ltr_def : thm
    val lower_sml_sequence_list_def : thm
    val sml_application_ltr_reference_def : thm
    val sml_con_ltr_reference_def : thm
    val sml_sequence_list_derived_def : thm
    val sml_sequence_list_reference_def : thm
  
  (*  Theorems  *)
    val application_reference_two : thm
    val apply_from_variable_list : thm
    val capture_pattern_bindings : thm
    val captured_variable_lookups : thm
    val construct_from_variable_list : thm
    val derived_sequence_list_correct : thm
    val evaluate_variable_list : thm
    val lower_sequence_matches_derived_form : thm
    val lower_sml_application_ltr_correct : thm
    val lower_sml_con_ltr_correct : thm
    val lower_sml_sequence_list_correct : thm
    val lowered_tuple_keeps_value_order : thm
    val lowered_tuple_raises_first : thm
    val pmatch_capture_variables : thm
    val source_closure_environment_is_preserved : thm
(*
   [Hol4SmlApplication] Parent theory of "Hol4SmlOrder"
   
   [evaluateProps] Parent theory of "Hol4SmlOrder"
   
   [lower_sml_application_ltr_def]  Definition
      
      ⊢ ∀es names.
          lower_sml_application_ltr es names =
          Mat (Con NONE (REVERSE es))
            [(Pcon NONE (MAP Pvar (REVERSE names)),
              App Opapp (MAP (λn. Var (Short n)) names))]
   
   [lower_sml_con_ltr_def]  Definition
      
      ⊢ ∀cn es names.
          lower_sml_con_ltr cn es names =
          Mat (Con NONE (REVERSE es))
            [(Pcon NONE (MAP Pvar (REVERSE names)),
              Con cn (MAP (λn. Var (Short n)) names))]
   
   [lower_sml_sequence_list_def]  Definition
      
      ⊢ ∀es result_exp.
          lower_sml_sequence_list es result_exp =
          FOLDR (λfirst rest. Let NONE first rest) result_exp es
   
   [sml_application_ltr_reference_def]  Definition
      
      ⊢ ∀st env es.
          sml_application_ltr_reference st env es =
          case fix_clock st (evaluate st env es) of
            (st',Rval vs) =>
              (case do_opapp vs of
                 NONE => (st',Rerr (Rabort Rtype_error))
               | SOME (call_env,body) =>
                 if st'.clock = 0 then (st',Rerr (Rabort Rtimeout_error))
                 else evaluate (dec_clock st') call_env [body])
          | (st',Rerr err) => (st',Rerr err)
   
   [sml_con_ltr_reference_def]  Definition
      
      ⊢ ∀st env cn es.
          sml_con_ltr_reference st env cn es =
          case evaluate st env es of
            (st',Rval vs) =>
              (case build_conv env.c cn vs of
                 NONE => (st',Rerr (Rabort Rtype_error))
               | SOME value => (st',Rval [value]))
          | (st',Rerr err) => (st',Rerr err)
   
   [sml_sequence_list_derived_def]  Definition
      
      ⊢ ∀es result_exp.
          sml_sequence_list_derived es result_exp =
          FOLDR (λfirst rest. Mat first [(Pany,rest)]) result_exp es
   
   [sml_sequence_list_reference_def]  Definition
      
      ⊢ (∀st env result_exp.
           sml_sequence_list_reference st env [] result_exp =
           evaluate st env [result_exp]) ∧
        ∀st env first rest result_exp.
          sml_sequence_list_reference st env (first::rest) result_exp =
          case fix_clock st (evaluate st env [first]) of
            (st',Rval vs) =>
              sml_sequence_list_reference st' env rest result_exp
          | (st',Rerr err) => (st',Rerr err)
   
   [application_reference_two]  Theorem
      
      ⊢ sml_application_ltr_reference st env [fexp; aexp] =
        sml_left_application_reference st env fexp aexp
   
   [apply_from_variable_list]  Theorem
      
      ⊢ LIST_REL (λname value. nsLookup env.v (Short name) = SOME value)
          names values ⇒
        evaluate st env [App Opapp (MAP (λname. Var (Short name)) names)] =
        case do_opapp values of
          NONE => (st,Rerr (Rabort Rtype_error))
        | SOME (call_env,body) =>
          if st.clock = 0 then (st,Rerr (Rabort Rtimeout_error))
          else evaluate (dec_clock st) call_env [body]
   
   [capture_pattern_bindings]  Theorem
      
      ⊢ ∀names. pats_bindings (MAP Pvar names) = REVERSE names
   
   [captured_variable_lookups]  Theorem
      
      ⊢ ALL_DISTINCT names ∧ LENGTH names = LENGTH values ⇒
        LIST_REL
          (λname value.
               nsLookup (nsAppend (alist_to_ns (ZIP (names,values))) base)
                 (Short name) = SOME value) names values
   
   [construct_from_variable_list]  Theorem
      
      ⊢ LIST_REL (λname value. nsLookup env.v (Short name) = SOME value)
          names values ∧ do_con_check env.c cn (LENGTH names) ⇒
        evaluate st env [Con cn (MAP (λname. Var (Short name)) names)] =
        case build_conv env.c cn values of
          NONE => (st,Rerr (Rabort Rtype_error))
        | SOME value => (st,Rval [value])
   
   [derived_sequence_list_correct]  Theorem
      
      ⊢ ∀es st env result_exp.
          evaluate st env [sml_sequence_list_derived es result_exp] =
          sml_sequence_list_reference st env es result_exp
   
   [evaluate_variable_list]  Theorem
      
      ⊢ ∀names values st env.
          LIST_REL (λname value. nsLookup env.v (Short name) = SOME value)
            names values ⇒
          evaluate st env (MAP (λname. Var (Short name)) names) =
          (st,Rval values)
   
   [lower_sequence_matches_derived_form]  Theorem
      
      ⊢ evaluate st env [lower_sml_sequence_list es result_exp] =
        evaluate st env [sml_sequence_list_derived es result_exp]
   
   [lower_sml_application_ltr_correct]  Theorem
      
      ⊢ ALL_DISTINCT names ∧ LENGTH names = LENGTH es ⇒
        evaluate st env [lower_sml_application_ltr es names] =
        sml_application_ltr_reference st env es
   
   [lower_sml_con_ltr_correct]  Theorem
      
      ⊢ ALL_DISTINCT names ∧ LENGTH names = LENGTH es ∧
        do_con_check env.c cn (LENGTH es) ⇒
        evaluate st env [lower_sml_con_ltr cn es names] =
        sml_con_ltr_reference st env cn es
   
   [lower_sml_sequence_list_correct]  Theorem
      
      ⊢ ∀es st env result_exp.
          evaluate st env [lower_sml_sequence_list es result_exp] =
          sml_sequence_list_reference st env es result_exp
   
   [lowered_tuple_keeps_value_order]  Theorem
      
      ⊢ evaluate st env
          [lower_sml_con_ltr NONE
             [Lit (IntLit 1); Lit (IntLit 2); Lit (IntLit 3)]
             [«left»; «middle»; «right»]] =
        (st,
         Rval
           [Conv NONE [Litv (IntLit 1); Litv (IntLit 2); Litv (IntLit 3)]])
   
   [lowered_tuple_raises_first]  Theorem
      
      ⊢ nsLookup env.v first_id = SOME first_value ⇒
        evaluate st env
          [lower_sml_con_ltr NONE
             [Raise (Var first_id); Raise (Var second_id)]
             [«left»; «right»]] = (st,Rerr (Rraise first_value))
   
   [pmatch_capture_variables]  Theorem
      
      ⊢ ∀names values acc.
          LENGTH names = LENGTH values ⇒
          pmatch_list c refs (MAP Pvar names) values acc =
          Match (REVERSE (ZIP (names,values)) ++ acc)
   
   [source_closure_environment_is_preserved]  Theorem
      
      ⊢ nsLookup env.v (Short «hol4_sml_capture_0») =
        SOME (Litv (IntLit 41)) ∧ 0 < st.clock ⇒
        evaluate st env
          [lower_sml_application_ltr
             [Fun «ignored» (Var (Short «hol4_sml_capture_0»));
              Lit (IntLit 7)] [«hol4_sml_capture_0»; «hol4_sml_capture_1»]] =
        (dec_clock st,Rval [Litv (IntLit 41)])
   
   
*)
end
