signature Hol4SmlMacroLib =
sig
  type term = Term.term
  type thm = Thm.thm
  type certificate = {expanded : term, expansion : thm, semantics : thm}
  val match : {scrutinee : term, clauses : term, exception_id : term} -> certificate
  val multi_fn : {parameter : term, clauses : term, exception_id : term} -> certificate
  val multi_fn_application :
    {parameter : term, clauses : term, exception_id : term, argument_id : term} -> certificate
  val sequence : {first_exp : term, second_exp : term} -> certificate
  val sequence_list : {prefixes : term, result_exp : term} -> certificate
  val constructor_ltr : {constructor_id : term, operands : term} -> certificate
  val application_ltr : {function_exp : term, argument_exp : term} -> certificate
end
