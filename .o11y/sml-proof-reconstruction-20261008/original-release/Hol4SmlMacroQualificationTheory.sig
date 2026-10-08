signature Hol4SmlMacroQualificationTheory =
sig
  type thm = Thm.thm
  
  (*  Theorems  *)
    val egglog_application_ltr_replay : thm
    val egglog_application_replay : thm
    val egglog_constructor_ltr_replay : thm
    val egglog_sequence_replay : thm
    val generated_application_ltr_expansion : thm
    val generated_application_ltr_semantics : thm
    val generated_constructor_ltr_expansion : thm
    val generated_constructor_ltr_semantics : thm
    val generated_fn_application_expansion : thm
    val generated_fn_application_semantics : thm
    val generated_fn_closure : thm
    val generated_fn_expansion : thm
    val generated_left_application_expansion : thm
    val generated_left_application_semantics : thm
    val generated_match_expansion : thm
    val generated_match_semantics : thm
    val generated_sequence_expansion : thm
    val generated_sequence_list_expansion : thm
    val generated_sequence_list_semantics : thm
    val generated_sequence_semantics : thm
    val generated_variable_application_expansion : thm
    val generated_variable_application_semantics : thm
    val tactictoe_clause_count : thm
    val z3_clock_step : thm
(*
   [Hol4SmlOrder] Parent theory of "Hol4SmlMacroQualification"
   
   [HolSmt] Parent theory of "Hol4SmlMacroQualification"
   
   [egglog_application_ltr_replay]  Theorem
      
      ⊢ ALL_DISTINCT names ∧ LENGTH names = LENGTH es ⇒
        evaluate st env [lower_sml_application_ltr es names] =
        sml_application_ltr_reference st env es
   
   [egglog_application_replay]  Theorem
      
      ⊢ fname ≠ aname ∧ argument_binding_stable st env fname aexp ⇒
        evaluate st env [lower_sml_left_application fname aname fexp aexp] =
        sml_left_application_reference st env fexp aexp
   
   [egglog_constructor_ltr_replay]  Theorem
      
      ⊢ ALL_DISTINCT names ∧ LENGTH names = LENGTH es ∧
        do_con_check env.c cn (LENGTH es) ⇒
        evaluate st env [lower_sml_con_ltr cn es names] =
        sml_con_ltr_reference st env cn es
   
   [egglog_sequence_replay]  Theorem
      
      ⊢ evaluate st env [Let NONE e1 e2] =
        sml_sequence_reference st env e1 e2
   
   [generated_application_ltr_expansion]  Theorem
      
      ⊢ lower_sml_application_ltr
          [Fun «ignored» (Var (Short «hol4_sml_capture_0»));
           Lit (IntLit 7)] [«hol4_sml_capture_0»; «hol4_sml_capture_1»] =
        Mat
          (Con NONE
             [Lit (IntLit 7);
              Fun «ignored» (Var (Short «hol4_sml_capture_0»))])
          [(Pcon NONE
              [Pvar «hol4_sml_capture_1»; Pvar «hol4_sml_capture_0»],
            App Opapp
              [(λn. Var (Short n)) «hol4_sml_capture_0»;
               (λn. Var (Short n)) «hol4_sml_capture_1»])]
   
   [generated_application_ltr_semantics]  Theorem
      
      ⊢ evaluate st env
          [Mat
             (Con NONE
                [Lit (IntLit 7);
                 Fun «ignored» (Var (Short «hol4_sml_capture_0»))])
             [(Pcon NONE
                 [Pvar «hol4_sml_capture_1»; Pvar «hol4_sml_capture_0»],
               App Opapp
                 [(λn. Var (Short n)) «hol4_sml_capture_0»;
                  (λn. Var (Short n)) «hol4_sml_capture_1»])]] =
        sml_left_application_reference st env
          (Fun «ignored» (Var (Short «hol4_sml_capture_0»)))
          (Lit (IntLit 7))
   
   [generated_constructor_ltr_expansion]  Theorem
      
      ⊢ lower_sml_con_ltr NONE
          [Lit (IntLit 1); Lit (IntLit 2); Lit (IntLit 3)]
          [«hol4_sml_capture_0»; «hol4_sml_capture_1»;
           «hol4_sml_capture_2»] =
        Mat (Con NONE [Lit (IntLit 3); Lit (IntLit 2); Lit (IntLit 1)])
          [(Pcon NONE
              [Pvar «hol4_sml_capture_2»; Pvar «hol4_sml_capture_1»;
               Pvar «hol4_sml_capture_0»],
            Con NONE
              [(λn. Var (Short n)) «hol4_sml_capture_0»;
               (λn. Var (Short n)) «hol4_sml_capture_1»;
               (λn. Var (Short n)) «hol4_sml_capture_2»])]
   
   [generated_constructor_ltr_semantics]  Theorem
      
      ⊢ evaluate st env
          [Mat (Con NONE [Lit (IntLit 3); Lit (IntLit 2); Lit (IntLit 1)])
             [(Pcon NONE
                 [Pvar «hol4_sml_capture_2»; Pvar «hol4_sml_capture_1»;
                  Pvar «hol4_sml_capture_0»],
               Con NONE
                 [(λn. Var (Short n)) «hol4_sml_capture_0»;
                  (λn. Var (Short n)) «hol4_sml_capture_1»;
                  (λn. Var (Short n)) «hol4_sml_capture_2»])]] =
        sml_con_ltr_reference st env NONE
          [Lit (IntLit 1); Lit (IntLit 2); Lit (IntLit 3)]
   
   [generated_fn_application_expansion]  Theorem
      
      ⊢ lower_sml_multifn_application «subject»
          [(Plit (IntLit 0),Lit (IntLit 10));
           (Plit (IntLit 1),Lit (IntLit 20))] (Short «sml_match_exception»)
          (Short «argument») =
        App Opapp
          [Fun «subject»
             (Mat (Var (Short «subject»))
                ([(Plit (IntLit 0),Lit (IntLit 10));
                  (Plit (IntLit 1),Lit (IntLit 20))] ++
                 [(Pany,Raise (Var (Short «sml_match_exception»)))]));
           Var (Short «argument»)]
   
   [generated_fn_application_semantics]  Theorem
      
      ⊢ nsLookup env.v (Short «argument») = SOME value ∧
        nsLookup (nsBind «subject» value env.v)
          (Short «sml_match_exception») = SOME match_value ⇒
        evaluate st env
          [App Opapp
             [Fun «subject»
                (Mat (Var (Short «subject»))
                   ([(Plit (IntLit 0),Lit (IntLit 10));
                     (Plit (IntLit 1),Lit (IntLit 20))] ++
                    [(Pany,Raise (Var (Short «sml_match_exception»)))]));
              Var (Short «argument»)]] =
        if st.clock = 0 then (st,Rerr (Rabort Rtimeout_error))
        else
          sml_match_reference (dec_clock st)
            (env with v := nsBind «subject» value env.v)
            (Var (Short «subject»))
            [(Plit (IntLit 0),Lit (IntLit 10));
             (Plit (IntLit 1),Lit (IntLit 20))] match_value
   
   [generated_fn_closure]  Theorem
      
      ⊢ evaluate st env
          [Fun «subject»
             (Mat (Var (Short «subject»))
                ([(Plit (IntLit 0),Lit (IntLit 10));
                  (Plit (IntLit 1),Lit (IntLit 20))] ++
                 [(Pany,Raise (Var (Short «sml_match_exception»)))]))] =
        (st,
         Rval
           [Closure env «subject»
              (lower_sml_match (Var (Short «subject»))
                 [(Plit (IntLit 0),Lit (IntLit 10));
                  (Plit (IntLit 1),Lit (IntLit 20))]
                 (Short «sml_match_exception»))])
   
   [generated_fn_expansion]  Theorem
      
      ⊢ lower_sml_multifn «subject»
          [(Plit (IntLit 0),Lit (IntLit 10));
           (Plit (IntLit 1),Lit (IntLit 20))] (Short «sml_match_exception») =
        Fun «subject»
          (Mat (Var (Short «subject»))
             ([(Plit (IntLit 0),Lit (IntLit 10));
               (Plit (IntLit 1),Lit (IntLit 20))] ++
              [(Pany,Raise (Var (Short «sml_match_exception»)))]))
   
   [generated_left_application_expansion]  Theorem
      
      ⊢ lower_sml_left_application «application_function»
          «application_argument» (Var (Short «function»)) (Lit (IntLit 7)) =
        Let (SOME «application_function») (Var (Short «function»))
          (Let (SOME «application_argument») (Lit (IntLit 7))
             (App Opapp
                [Var (Short «application_function»);
                 Var (Short «application_argument»)]))
   
   [generated_left_application_semantics]  Theorem
      
      ⊢ evaluate st env
          [Let (SOME «application_function») (Var (Short «function»))
             (Let (SOME «application_argument») (Lit (IntLit 7))
                (App Opapp
                   [Var (Short «application_function»);
                    Var (Short «application_argument»)]))] =
        sml_left_application_reference st env (Var (Short «function»))
          (Lit (IntLit 7))
   
   [generated_match_expansion]  Theorem
      
      ⊢ lower_sml_match (Var (Short «subject»))
          [(Plit (IntLit 0),Lit (IntLit 10));
           (Plit (IntLit 1),Lit (IntLit 20))] (Short «sml_match_exception») =
        Mat (Var (Short «subject»))
          ([(Plit (IntLit 0),Lit (IntLit 10));
            (Plit (IntLit 1),Lit (IntLit 20))] ++
           [(Pany,Raise (Var (Short «sml_match_exception»)))])
   
   [generated_match_semantics]  Theorem
      
      ⊢ nsLookup env.v (Short «sml_match_exception») = SOME match_value ⇒
        evaluate st env
          [Mat (Var (Short «subject»))
             ([(Plit (IntLit 0),Lit (IntLit 10));
               (Plit (IntLit 1),Lit (IntLit 20))] ++
              [(Pany,Raise (Var (Short «sml_match_exception»)))])] =
        sml_match_reference st env (Var (Short «subject»))
          [(Plit (IntLit 0),Lit (IntLit 10));
           (Plit (IntLit 1),Lit (IntLit 20))] match_value
   
   [generated_sequence_expansion]  Theorem
      
      ⊢ Let NONE (Lit (IntLit 1)) (Lit (IntLit 2)) =
        Let NONE (Lit (IntLit 1)) (Lit (IntLit 2))
   
   [generated_sequence_list_expansion]  Theorem
      
      ⊢ lower_sml_sequence_list [Lit (IntLit 1); Lit (IntLit 2)]
          (Lit (IntLit 3)) =
        (λfirst rest. Let NONE first rest) (Lit (IntLit 1))
          ((λfirst rest. Let NONE first rest) (Lit (IntLit 2))
             (Lit (IntLit 3)))
   
   [generated_sequence_list_semantics]  Theorem
      
      ⊢ evaluate st env
          [(λfirst rest. Let NONE first rest) (Lit (IntLit 1))
             ((λfirst rest. Let NONE first rest) (Lit (IntLit 2))
                (Lit (IntLit 3)))] =
        sml_sequence_list_reference st env [Lit (IntLit 1); Lit (IntLit 2)]
          (Lit (IntLit 3))
   
   [generated_sequence_semantics]  Theorem
      
      ⊢ evaluate st env [Let NONE (Lit (IntLit 1)) (Lit (IntLit 2))] =
        sml_sequence_reference st env (Lit (IntLit 1)) (Lit (IntLit 2))
   
   [generated_variable_application_expansion]  Theorem
      
      ⊢ lower_sml_left_application «application_function»
          «application_argument» (Var (Short «function»))
          (Var (Short «argument»)) =
        Let (SOME «application_function») (Var (Short «function»))
          (Let (SOME «application_argument») (Var (Short «argument»))
             (App Opapp
                [Var (Short «application_function»);
                 Var (Short «application_argument»)]))
   
   [generated_variable_application_semantics]  Theorem
      
      ⊢ evaluate st env
          [Let (SOME «application_function») (Var (Short «function»))
             (Let (SOME «application_argument») (Var (Short «argument»))
                (App Opapp
                   [Var (Short «application_function»);
                    Var (Short «application_argument»)]))] =
        sml_left_application_reference st env (Var (Short «function»))
          (Var (Short «argument»))
   
   [tactictoe_clause_count]  Theorem
      
      ⊢ ∀clauses.
          LENGTH
            (clauses ++ [(Pany,Raise (Var (Short «sml_match_exception»)))]) =
          LENGTH clauses + 1
   
   [z3_clock_step]  Theorem
      
      ⊢ ∀clock. 0 < clock ⇒ clock − 1 < clock
   
   
*)
end
