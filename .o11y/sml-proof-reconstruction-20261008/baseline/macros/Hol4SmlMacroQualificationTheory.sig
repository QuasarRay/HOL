signature Hol4SmlMacroQualificationTheory =
sig
  type thm = Thm.thm
  
  (*  Theorems  *)
    val egglog_sequence_replay : thm
    val generated_fn_application_expansion : thm
    val generated_fn_application_semantics : thm
    val generated_fn_closure : thm
    val generated_fn_expansion : thm
    val generated_match_expansion : thm
    val generated_match_semantics : thm
    val tactictoe_clause_count : thm
    val z3_clock_step : thm
end
