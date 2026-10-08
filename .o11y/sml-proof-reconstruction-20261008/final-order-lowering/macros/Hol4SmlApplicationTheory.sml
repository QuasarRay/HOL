structure Hol4SmlApplicationTheory :> Hol4SmlApplicationTheory =
struct
  
  val _ = if !Globals.print_thy_loads
    then TextIO.print "Loading Hol4SmlApplicationTheory ... "
    else ()
  
  open Type Term Thm
  local open Hol4SmlMacroTheory in end;
  
  structure TDB = struct
    val path =
      OS.Path.base (#(FILE)) ^ ".dat"
    val timestamp = HOLFileSys.modTime path
    val thydata = 
      TheoryReader.load_thydata {
        thyname = "Hol4SmlApplication",
        hash = "23e95915f721158e8f80529db9819db3d1e2240e",
        path = path
      }
    fun find s = #1 (valOf (Symtab.lookup thydata s))
  end
  val () = Theory.record_metadata
    "Hol4SmlApplication" {timestamp=TDB.timestamp, path=TDB.path}
  
  fun op variable_argument_binding_stable _ = ()
  val op variable_argument_binding_stable = TDB.find
    "variable_argument_binding_stable"
  fun op temporary_capture_is_observable _ = ()
  val op temporary_capture_is_observable = TDB.find
    "temporary_capture_is_observable"
  fun op temporary_capture_env_def _ = ()
  val op temporary_capture_env_def = TDB.find "temporary_capture_env_def"
  fun op sml_left_application_reference_def _ = ()
  val op sml_left_application_reference_def = TDB.find
    "sml_left_application_reference_def"
  fun op lowered_application_preserves_first_error _ = ()
  val op lowered_application_preserves_first_error = TDB.find
    "lowered_application_preserves_first_error"
  fun op lower_sml_left_application_def _ = ()
  val op lower_sml_left_application_def = TDB.find
    "lower_sml_left_application_def"
  fun op lower_sml_left_application_correct _ = ()
  val op lower_sml_left_application_correct = TDB.find
    "lower_sml_left_application_correct"
  fun op literal_argument_binding_stable _ = ()
  val op literal_argument_binding_stable = TDB.find
    "literal_argument_binding_stable"
  fun op argument_binding_stable_def _ = ()
  val op argument_binding_stable_def = TDB.find
    "argument_binding_stable_def"
  fun op application_order_is_observable _ = ()
  val op application_order_is_observable = TDB.find
    "application_order_is_observable"
  
val _ = if !Globals.print_thy_loads then TextIO.print "done\n" else ()
val _ = Theory.load_complete "Hol4SmlApplication"

end
