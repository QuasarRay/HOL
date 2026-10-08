structure Hol4SmlMacroQualificationTheory :> Hol4SmlMacroQualificationTheory =
struct
  
  val _ = if !Globals.print_thy_loads
    then TextIO.print "Loading Hol4SmlMacroQualificationTheory ... "
    else ()
  
  open Type Term Thm
  local open Hol4SmlOrderTheory HolSmtTheory in end;
  
  structure TDB = struct
    val path =
      OS.Path.base (#(FILE)) ^ ".dat"
    val timestamp = HOLFileSys.modTime path
    val thydata = 
      TheoryReader.load_thydata {
        thyname = "Hol4SmlMacroQualification",
        hash = "b5f15db81cd9b058cf7cc7662e5a359c55d75cc8",
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
  fun op generated_variable_application_semantics _ = ()
  val op generated_variable_application_semantics = TDB.find
    "generated_variable_application_semantics"
  fun op generated_variable_application_expansion _ = ()
  val op generated_variable_application_expansion = TDB.find
    "generated_variable_application_expansion"
  fun op generated_sequence_semantics _ = ()
  val op generated_sequence_semantics = TDB.find
    "generated_sequence_semantics"
  fun op generated_sequence_list_semantics _ = ()
  val op generated_sequence_list_semantics = TDB.find
    "generated_sequence_list_semantics"
  fun op generated_sequence_list_expansion _ = ()
  val op generated_sequence_list_expansion = TDB.find
    "generated_sequence_list_expansion"
  fun op generated_sequence_expansion _ = ()
  val op generated_sequence_expansion = TDB.find
    "generated_sequence_expansion"
  fun op generated_match_semantics _ = ()
  val op generated_match_semantics = TDB.find "generated_match_semantics"
  fun op generated_match_expansion _ = ()
  val op generated_match_expansion = TDB.find "generated_match_expansion"
  fun op generated_left_application_semantics _ = ()
  val op generated_left_application_semantics = TDB.find
    "generated_left_application_semantics"
  fun op generated_left_application_expansion _ = ()
  val op generated_left_application_expansion = TDB.find
    "generated_left_application_expansion"
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
  fun op generated_constructor_ltr_semantics _ = ()
  val op generated_constructor_ltr_semantics = TDB.find
    "generated_constructor_ltr_semantics"
  fun op generated_constructor_ltr_expansion _ = ()
  val op generated_constructor_ltr_expansion = TDB.find
    "generated_constructor_ltr_expansion"
  fun op generated_application_ltr_semantics _ = ()
  val op generated_application_ltr_semantics = TDB.find
    "generated_application_ltr_semantics"
  fun op generated_application_ltr_expansion _ = ()
  val op generated_application_ltr_expansion = TDB.find
    "generated_application_ltr_expansion"
  fun op egglog_sequence_replay _ = ()
  val op egglog_sequence_replay = TDB.find "egglog_sequence_replay"
  fun op egglog_constructor_ltr_replay _ = ()
  val op egglog_constructor_ltr_replay = TDB.find
    "egglog_constructor_ltr_replay"
  fun op egglog_application_replay _ = ()
  val op egglog_application_replay = TDB.find "egglog_application_replay"
  fun op egglog_application_ltr_replay _ = ()
  val op egglog_application_ltr_replay = TDB.find
    "egglog_application_ltr_replay"
  
val _ = if !Globals.print_thy_loads then TextIO.print "done\n" else ()
val _ = Theory.load_complete "Hol4SmlMacroQualification"

end
