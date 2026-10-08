structure Hol4SmlGapWitnessTheory :> Hol4SmlGapWitnessTheory =
struct
  
  val _ = if !Globals.print_thy_loads
    then TextIO.print "Loading Hol4SmlGapWitnessTheory ... "
    else ()
  
  open Type Term Thm
  local open cmlPtreeConversionTheory evaluateTheory in end;
  
  structure TDB = struct
    val path =
      OS.Path.base (#(FILE)) ^ ".dat"
    val timestamp = HOLFileSys.modTime path
    val thydata = 
      TheoryReader.load_thydata {
        thyname = "Hol4SmlGapWitness",
        hash = "dbe60d5106c16a8f2d72d52ac156f1150ff72917",
        path = path
      }
    fun find s = #1 (valOf (Symtab.lookup thydata s))
  end
  val () = Theory.record_metadata
    "Hol4SmlGapWitness" {timestamp=TDB.timestamp, path=TDB.path}
  
  fun op target_tuple_raises_second _ = ()
  val op target_tuple_raises_second = TDB.find "target_tuple_raises_second"
  fun op target_recursive_closure_equality _ = ()
  val op target_recursive_closure_equality = TDB.find
    "target_recursive_closure_equality"
  fun op target_order_is_observable _ = ()
  val op target_order_is_observable = TDB.find "target_order_is_observable"
  fun op target_failed_case_raises_bind _ = ()
  val op target_failed_case_raises_bind = TDB.find
    "target_failed_case_raises_bind"
  fun op target_closure_equality _ = ()
  val op target_closure_equality = TDB.find "target_closure_equality"
  fun op explicit_sequence_raises_first _ = ()
  val op explicit_sequence_raises_first = TDB.find
    "explicit_sequence_raises_first"
  fun op accepted_inline_signature_is_erased _ = ()
  val op accepted_inline_signature_is_erased = TDB.find
    "accepted_inline_signature_is_erased"
  
val _ = if !Globals.print_thy_loads then TextIO.print "done\n" else ()
val _ = Theory.load_complete "Hol4SmlGapWitness"

end
