(* The SML97 application premises in dyncor.tex (closapp-dyn-rule), together
   with its state/exception conventions, evaluate function before argument.
   This reference instantiates that order with CakeML values and clocks.
   It is not a formalization of SML97 elaboration or its complete value model. *)
Theory Hol4SmlApplication
Ancestors
  Hol4SmlMacro evaluate semanticPrimitives ast namespace namespaceProps

Definition sml_left_application_reference_def:
  sml_left_application_reference st env fexp aexp =
    case fix_clock st (evaluate st env [fexp]) of
      (s1,Rval functions) =>
        (case fix_clock s1 (evaluate s1 env [aexp]) of
           (s2,Rval arguments) =>
             (case do_opapp [HD functions; HD arguments] of
                NONE => (s2,Rerr (Rabort Rtype_error))
              | SOME (body_env,body) =>
                  if s2.clock = 0 then (s2,Rerr (Rabort Rtimeout_error))
                  else evaluate (dec_clock s2) body_env [body])
         | (s2,Rerr err) => (s2,Rerr err))
    | (s1,Rerr err) => (s1,Rerr err)
End

Definition lower_sml_left_application_def:
  lower_sml_left_application fname aname fexp aexp =
    Let (SOME fname) fexp
      (Let (SOME aname) aexp
        (App Opapp [Var (Short fname); Var (Short aname)]))
End

(* Syntactic freshness alone does not imply equality of captured closure
   environments. Keep this sufficient semantic condition explicit until a
   source/value simulation supplies the more general relation. *)
Definition argument_binding_stable_def:
  argument_binding_stable (st:'ffi state) env temp e <=>
    !s:'ffi state value.
      evaluate s (env with v := nsBind temp value env.v) [e] =
      evaluate s env [e]
End

Theorem literal_argument_binding_stable:
  argument_binding_stable st env temp (Lit literal)
Proof
  simp [argument_binding_stable_def,evaluate_def]
QED

Theorem variable_argument_binding_stable:
  name <> temp ==> argument_binding_stable st env temp (Var (Short name))
Proof
  simp [argument_binding_stable_def,evaluate_def]
QED

Theorem lower_sml_left_application_correct:
  fname <> aname /\ argument_binding_stable st env fname aexp ==>
  evaluate st env [lower_sml_left_application fname aname fexp aexp] =
  sml_left_application_reference st env fexp aexp
Proof
  rpt strip_tac >> fs [argument_binding_stable_def] >>
  simp [lower_sml_left_application_def,sml_left_application_reference_def,
        evaluate_def,nsOptBind_def,fix_clock_evaluate] >>
  rpt (CASE_TAC >> fs [evaluate_def,nsOptBind_def,fix_clock_evaluate])
QED

Theorem lowered_application_preserves_first_error:
  evaluate st env [fexp] = (s1,Rerr err) ==>
  evaluate st env [lower_sml_left_application fname aname fexp aexp] =
  (s1,Rerr err)
Proof
  simp [lower_sml_left_application_def,evaluate_def,fix_clock_evaluate]
QED

Theorem application_order_is_observable:
  nsLookup env.v first_id = SOME first_value /\
  nsLookup env.v second_id = SOME second_value /\
  first_value <> second_value ==>
  evaluate st env
    [lower_sml_left_application fname aname
       (Raise (Var first_id)) (Raise (Var second_id))] <>
  evaluate st env
    [App Opapp [Raise (Var first_id); Raise (Var second_id)]]
Proof
  strip_tac >>
  asm_simp_tac (srw_ss()) [lower_sml_left_application_def,evaluate_def]
QED

(* Omitting stability would allow the first temporary to capture an original
   argument variable. The identity function then returns the wrong value. *)
Definition temporary_capture_env_def:
  temporary_capture_env closure_env =
    closure_env with v :=
      nsBind «function» (Closure closure_env «x» (Var (Short «x»)))
        (nsBind «argument» (Litv (IntLit 7)) closure_env.v)
End

Theorem temporary_capture_is_observable:
  0 < st.clock ==>
  evaluate st (temporary_capture_env closure_env)
    [lower_sml_left_application «argument» «operand»
       (Var (Short «function»)) (Var (Short «argument»))] <>
  sml_left_application_reference st (temporary_capture_env closure_env)
       (Var (Short «function»)) (Var (Short «argument»))
Proof
  strip_tac >> `st.clock <> 0` by decide_tac >>
  asm_simp_tac (srw_ss())
    [temporary_capture_env_def,lower_sml_left_application_def,sml_left_application_reference_def,
     evaluate_def,nsOptBind_def,do_opapp_def,fix_clock_def]
QED

val _ = List.app (fn (name,th) =>
  let val (oracles,axioms) = Tag.dest_tag (Thm.tag th)
  in if null (Thm.hyp th) andalso null axioms andalso
        List.all (fn x => x = "DISK_THM") oracles then ()
     else raise Fail ("unclean application theorem: " ^ name)
  end)
  [("literal_argument_binding_stable",literal_argument_binding_stable),
   ("variable_argument_binding_stable",variable_argument_binding_stable),
   ("lower_sml_left_application_correct",lower_sml_left_application_correct),
   ("lowered_application_preserves_first_error",lowered_application_preserves_first_error),
   ("application_order_is_observable",application_order_is_observable),
   ("temporary_capture_is_observable",temporary_capture_is_observable)];
val _ = export_theory();
