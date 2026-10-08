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
end
