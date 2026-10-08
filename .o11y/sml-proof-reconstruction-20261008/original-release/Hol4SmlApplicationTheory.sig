signature Hol4SmlApplicationTheory =
sig
  type thm = Thm.thm
  
  (*  Definitions  *)
    val argument_binding_stable_def : thm
    val lower_sml_left_application_def : thm
    val sml_left_application_reference_def : thm
    val temporary_capture_env_def : thm
  
  (*  Theorems  *)
    val application_order_is_observable : thm
    val literal_argument_binding_stable : thm
    val lower_sml_left_application_correct : thm
    val lowered_application_preserves_first_error : thm
    val temporary_capture_is_observable : thm
    val variable_argument_binding_stable : thm
(*
   [Hol4SmlMacro] Parent theory of "Hol4SmlApplication"
   
   [argument_binding_stable_def]  Definition
      
      ⊢ ∀st env temp e.
          argument_binding_stable st env temp e ⇔
          ∀s value.
            evaluate s (env with v := nsBind temp value env.v) [e] =
            evaluate s env [e]
   
   [lower_sml_left_application_def]  Definition
      
      ⊢ ∀fname aname fexp aexp.
          lower_sml_left_application fname aname fexp aexp =
          Let (SOME fname) fexp
            (Let (SOME aname) aexp
               (App Opapp [Var (Short fname); Var (Short aname)]))
   
   [sml_left_application_reference_def]  Definition
      
      ⊢ ∀st env fexp aexp.
          sml_left_application_reference st env fexp aexp =
          case fix_clock st (evaluate st env [fexp]) of
            (s1,Rval functions) =>
              (case fix_clock s1 (evaluate s1 env [aexp]) of
                 (s2,Rval arguments) =>
                   (case do_opapp [HD functions; HD arguments] of
                      NONE => (s2,Rerr (Rabort Rtype_error))
                    | SOME (body_env,body) =>
                      if s2.clock = 0 then
                        (s2,Rerr (Rabort Rtimeout_error))
                      else evaluate (dec_clock s2) body_env [body])
               | (s2,Rerr err) => (s2,Rerr err))
          | (s1,Rerr err) => (s1,Rerr err)
   
   [temporary_capture_env_def]  Definition
      
      ⊢ ∀closure_env.
          temporary_capture_env closure_env =
          closure_env with
          v :=
            nsBind «function» (Closure closure_env «x» (Var (Short «x»)))
              (nsBind «argument» (Litv (IntLit 7)) closure_env.v)
   
   [application_order_is_observable]  Theorem
      
      ⊢ nsLookup env.v first_id = SOME first_value ∧
        nsLookup env.v second_id = SOME second_value ∧
        first_value ≠ second_value ⇒
        evaluate st env
          [lower_sml_left_application fname aname (Raise (Var first_id))
             (Raise (Var second_id))] ≠
        evaluate st env
          [App Opapp [Raise (Var first_id); Raise (Var second_id)]]
   
   [literal_argument_binding_stable]  Theorem
      
      ⊢ argument_binding_stable st env temp (Lit literal)
   
   [lower_sml_left_application_correct]  Theorem
      
      ⊢ fname ≠ aname ∧ argument_binding_stable st env fname aexp ⇒
        evaluate st env [lower_sml_left_application fname aname fexp aexp] =
        sml_left_application_reference st env fexp aexp
   
   [lowered_application_preserves_first_error]  Theorem
      
      ⊢ evaluate st env [fexp] = (s1,Rerr err) ⇒
        evaluate st env [lower_sml_left_application fname aname fexp aexp] =
        (s1,Rerr err)
   
   [temporary_capture_is_observable]  Theorem
      
      ⊢ 0 < st.clock ⇒
        evaluate st (temporary_capture_env closure_env)
          [lower_sml_left_application «argument» «operand»
             (Var (Short «function»)) (Var (Short «argument»))] ≠
        sml_left_application_reference st
          (temporary_capture_env closure_env) (Var (Short «function»))
          (Var (Short «argument»))
   
   [variable_argument_binding_stable]  Theorem
      
      ⊢ name ≠ temp ⇒
        argument_binding_stable st env temp (Var (Short name))
   
   
*)
end
