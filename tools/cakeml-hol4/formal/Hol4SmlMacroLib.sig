signature Hol4SmlMacroLib =
sig
  type term = Term.term
  type thm = Thm.thm
  type certificate = {expanded : term, expansion : thm, semantics : thm}
  val match : {scrutinee : term, clauses : term, exception_id : term} -> certificate
  val multi_fn : {parameter : term, clauses : term, exception_id : term} -> certificate
  val sequence : {first_exp : term, second_exp : term} -> certificate
end
