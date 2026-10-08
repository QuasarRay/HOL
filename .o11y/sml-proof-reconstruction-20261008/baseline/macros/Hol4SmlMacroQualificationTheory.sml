structure Hol4SmlMacroQualificationTheory :> Hol4SmlMacroQualificationTheory =
struct
  
  val _ = if !Globals.print_thy_loads
    then TextIO.print "Loading Hol4SmlMacroQualificationTheory ... "
    else ()
  
  open Type Term Thm
  local open Hol4SmlMacroTheory HolSmtTheory in end;
  
  structure TDB = struct
    val path =
      OS.Path.base (#(FILE)) ^ ".dat"
    val timestamp = HOLFileSys.modTime path
    val thydata = 
      TheoryReader.load_thydata {
        thyname = "Hol4SmlMacroQualification",
        hash = "94d5a46855123490cffa79e1822651abbef6936b",
        path = path
      }
    fun find s = #1 (valOf (Symtab.lookup thydata s))
  end
  val () = Theory.record_metadata
    "Hol4SmlMacroQualification" {timestamp=TDB.timestamp, path=TDB.path}
  
  fun op z3_clock_step _ = ()
  val op z3_clock_step = TDB.find "z3_clock_step"
  fun op tactictoe_clause_count _ = ()
  val op tactictoe_clause_count = TDB.find "tactictoe_clause_count"
  fun op generated_match_semantics _ = ()
  val op generated_match_semantics = TDB.find "generated_match_semantics"
  fun op generated_match_expansion _ = ()
  val op generated_match_expansion = TDB.find "generated_match_expansion"
  fun op generated_fn_expansion _ = ()
  val op generated_fn_expansion = TDB.find "generated_fn_expansion"
  fun op generated_fn_closure _ = ()
  val op generated_fn_closure = TDB.find "generated_fn_closure"
  fun op generated_fn_application_semantics _ = ()
  val op generated_fn_application_semantics = TDB.find
    "generated_fn_application_semantics"
  fun op generated_fn_application_expansion _ = ()
  val op generated_fn_application_expansion = TDB.find
    "generated_fn_application_expansion"
  fun op egglog_sequence_replay _ = ()
  val op egglog_sequence_replay = TDB.find "egglog_sequence_replay"
  
val _ = if !Globals.print_thy_loads then TextIO.print "done\n" else ()
val _ = Theory.load_complete "Hol4SmlMacroQualification"

end
