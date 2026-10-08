signature Hol4SmlMacroTheory =
sig
  type thm = Thm.thm
  
  (*  Definitions  *)
    val lower_sml_match_def : thm
    val lower_sml_multifn_application_def : thm
    val lower_sml_multifn_def : thm
    val sml_match_reference_def : thm
    val sml_sequence_reference_def : thm
  
  (*  Theorems  *)
    val cakeml_empty_match_raises_bind : thm
    val cakeml_function_equality : thm
    val can_pmatch_all_fallback : thm
    val evaluate_match_fallback : thm
    val lower_sml_match_correct : thm
    val lower_sml_multifn_application_correct : thm
    val lower_sml_multifn_closure : thm
    val lower_sml_sequence_correct : thm
    val matched_body_bind_is_preserved : thm
(*
   [evaluate] Parent theory of "Hol4SmlMacro"
   
   [namespaceProps] Parent theory of "Hol4SmlMacro"
   
   [lower_sml_match_def]  Definition
      
      ⊢ ∀scrut clauses match_id.
          lower_sml_match scrut clauses match_id =
          Mat scrut (clauses ++ [(Pany,Raise (Var match_id))])
   
   [lower_sml_multifn_application_def]  Definition
      
      ⊢ ∀arg clauses match_id value_id.
          lower_sml_multifn_application arg clauses match_id value_id =
          App Opapp [lower_sml_multifn arg clauses match_id; Var value_id]
   
   [lower_sml_multifn_def]  Definition
      
      ⊢ ∀arg clauses match_id.
          lower_sml_multifn arg clauses match_id =
          Fun arg (lower_sml_match (Var (Short arg)) clauses match_id)
   
   [sml_match_reference_def]  Definition
      
      ⊢ ∀st env scrut clauses match_value.
          sml_match_reference st env scrut clauses match_value =
          case fix_clock st (evaluate st env [scrut]) of
            (st',Rval vs) =>
              if
                can_pmatch_all env.c st'.refs (MAP FST clauses) (HD vs)
              then
                evaluate_match st' env (HD vs) clauses match_value
              else (st',Rerr (Rabort Rtype_error))
          | (st',Rerr err) => (st',Rerr err)
   
   [sml_sequence_reference_def]  Definition
      
      ⊢ ∀st env e1 e2.
          sml_sequence_reference st env e1 e2 =
          case fix_clock st (evaluate st env [e1]) of
            (st',Rval vs) => evaluate st' env [e2]
          | (st',Rerr err) => (st',Rerr err)
   
   [cakeml_empty_match_raises_bind]  Theorem
      
      ⊢ evaluate_match st env value [] bind_exn_v =
        (st,Rerr (Rraise bind_exn_v))
   
   [cakeml_function_equality]  Theorem
      
      ⊢ do_eq (Closure env1 arg1 body1) (Closure env2 arg2 body2) =
        Eq_val T
   
   [can_pmatch_all_fallback]  Theorem
      
      ⊢ can_pmatch_all c refs (ps ++ [Pany]) value ⇔
        can_pmatch_all c refs ps value
   
   [evaluate_match_fallback]  Theorem
      
      ⊢ nsLookup env.v match_id = SOME match_value ⇒
        evaluate_match st env value
          (clauses ++ [(Pany,Raise (Var match_id))]) bind_exn_v =
        evaluate_match st env value clauses match_value
   
   [lower_sml_match_correct]  Theorem
      
      ⊢ nsLookup env.v match_id = SOME match_value ⇒
        evaluate st env [lower_sml_match scrut clauses match_id] =
        sml_match_reference st env scrut clauses match_value
   
   [lower_sml_multifn_application_correct]  Theorem
      
      ⊢ nsLookup env.v value_id = SOME value ∧
        nsLookup (nsBind arg value env.v) match_id = SOME match_value ⇒
        evaluate st env
          [lower_sml_multifn_application arg clauses match_id value_id] =
        if st.clock = 0 then (st,Rerr (Rabort Rtimeout_error))
        else
          sml_match_reference (dec_clock st)
            (env with v := nsBind arg value env.v) (Var (Short arg))
            clauses match_value
   
   [lower_sml_multifn_closure]  Theorem
      
      ⊢ evaluate st env [lower_sml_multifn arg clauses match_id] =
        (st,
         Rval
           [Closure env arg
              (lower_sml_match (Var (Short arg)) clauses match_id)])
   
   [lower_sml_sequence_correct]  Theorem
      
      ⊢ evaluate st env [Let NONE e1 e2] =
        sml_sequence_reference st env e1 e2
   
   [matched_body_bind_is_preserved]  Theorem
      
      ⊢ evaluate_match st env value
          [(Pany,Raise (Con (SOME (Short «Bind»)) []));
           (Pany,Raise (Var match_id))] bind_exn_v =
        evaluate_match st env value
          [(Pany,Raise (Con (SOME (Short «Bind»)) []))] match_value
   
   
*)
end
