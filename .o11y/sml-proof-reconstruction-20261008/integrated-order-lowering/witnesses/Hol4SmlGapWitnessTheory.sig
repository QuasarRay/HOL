signature Hol4SmlGapWitnessTheory =
sig
  type thm = Thm.thm
  
  (*  Theorems  *)
    val accepted_inline_signature_is_erased : thm
    val explicit_sequence_raises_first : thm
    val target_closure_equality : thm
    val target_failed_case_raises_bind : thm
    val target_order_is_observable : thm
    val target_recursive_closure_equality : thm
    val target_tuple_raises_second : thm
end
