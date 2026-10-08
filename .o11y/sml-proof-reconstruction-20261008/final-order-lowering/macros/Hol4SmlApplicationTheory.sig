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
end
