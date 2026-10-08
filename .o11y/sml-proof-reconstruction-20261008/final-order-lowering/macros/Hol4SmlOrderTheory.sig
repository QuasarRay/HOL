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
end
