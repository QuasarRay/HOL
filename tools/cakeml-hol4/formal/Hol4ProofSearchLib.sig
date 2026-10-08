signature Hol4ProofSearchLib =
sig
  val inspect_exact : string -> term -> thm -> unit
  val read_rewrite_names : string -> string list
  val prove_with_search :
    {name : string, goal : term, egglog_rewrites : string list} -> string * thm
  val prove_with_search_file :
    {name : string, goal : term, egglog_rewrites_path : string} -> string * thm
end
