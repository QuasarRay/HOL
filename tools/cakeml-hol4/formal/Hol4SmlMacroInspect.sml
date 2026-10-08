(* Inspect exported theorems after source proof construction. This import
   check is additional evidence; it is not independent source reconstruction. *)
fun inspect () = let
val _ = load "Hol4SmlMacroQualificationTheory";
val _ = Globals.max_print_depth := 100;
val checked_theorems =
  [("Hol4SmlMacro", "can_pmatch_all_fallback"),
   ("Hol4SmlMacro", "evaluate_match_fallback"),
   ("Hol4SmlMacro", "lower_sml_match_correct"),
   ("Hol4SmlMacro", "lower_sml_multifn_closure"),
   ("Hol4SmlMacro", "lower_sml_multifn_application_correct"),
   ("Hol4SmlMacro", "lower_sml_sequence_correct"),
   ("Hol4SmlMacro", "cakeml_function_equality"),
   ("Hol4SmlMacro", "cakeml_empty_match_raises_bind"),
   ("Hol4SmlMacro", "matched_body_bind_is_preserved"),
   ("Hol4SmlApplication", "literal_argument_binding_stable"),
   ("Hol4SmlApplication", "variable_argument_binding_stable"),
   ("Hol4SmlApplication", "lower_sml_left_application_correct"),
   ("Hol4SmlApplication", "lowered_application_preserves_first_error"),
   ("Hol4SmlApplication", "application_order_is_observable"),
   ("Hol4SmlApplication", "temporary_capture_is_observable"),
   ("Hol4SmlMacroQualification", "generated_match_expansion"),
   ("Hol4SmlMacroQualification", "generated_match_semantics"),
   ("Hol4SmlMacroQualification", "generated_fn_expansion"),
   ("Hol4SmlMacroQualification", "generated_fn_closure"),
   ("Hol4SmlMacroQualification", "generated_fn_application_expansion"),
   ("Hol4SmlMacroQualification", "generated_fn_application_semantics"),
   ("Hol4SmlMacroQualification", "generated_left_application_expansion"),
   ("Hol4SmlMacroQualification", "generated_left_application_semantics"),
   ("Hol4SmlMacroQualification", "generated_variable_application_expansion"),
   ("Hol4SmlMacroQualification", "generated_variable_application_semantics"),
   ("Hol4SmlMacroQualification", "generated_sequence_expansion"),
   ("Hol4SmlMacroQualification", "generated_sequence_semantics"),
   ("Hol4SmlMacroQualification", "egglog_sequence_replay"),
   ("Hol4SmlMacroQualification", "egglog_application_replay"),
   ("Hol4SmlMacroQualification", "z3_clock_step"),
   ("Hol4SmlMacroQualification", "tactictoe_clause_count")];
val _ = List.app (fn (thy,name) =>
  let val th = DB.fetch thy name
      val (oracles,axioms) = Tag.dest_tag (Thm.tag th)
      val _ = if null (Thm.hyp th) andalso null axioms andalso
                 List.all (fn x => x = "DISK_THM") oracles then ()
              else raise Fail ("unclean theorem: " ^ thy ^ "." ^ name)
  in print ("KERNEL_THEOREM " ^ thy ^ "." ^ name ^ "\n" ^
            thm_to_string th ^ "\n") end) checked_theorems;
in print ("HOL4_MACRO_EXPORTS_INSPECTED " ^
          Int.toString (length checked_theorems) ^ "\n") end;
val _ = ((inspect (); OS.Process.exit OS.Process.success)
  handle e => (print ("HOL4_MACRO_INSPECTION_FAILED " ^ General.exnMessage e ^ "\n");
               OS.Process.exit OS.Process.failure));
