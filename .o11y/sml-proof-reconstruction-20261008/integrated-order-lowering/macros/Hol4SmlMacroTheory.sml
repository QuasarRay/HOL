structure Hol4SmlMacroTheory :> Hol4SmlMacroTheory =
struct
  
  val _ = if !Globals.print_thy_loads
    then TextIO.print "Loading Hol4SmlMacroTheory ... "
    else ()
  
  open Type Term Thm
  local open evaluateTheory namespacePropsTheory in end;
  
  structure TDB = struct
    val path =
      OS.Path.base (#(FILE)) ^ ".dat"
    val timestamp = HOLFileSys.modTime path
    val thydata = 
      TheoryReader.load_thydata {
        thyname = "Hol4SmlMacro",
        hash = "1b250419900989f43d1c42f8b6a3e2077a8501bc",
        path = path
      }
    fun find s = #1 (valOf (Symtab.lookup thydata s))
  end
  val () = Theory.record_metadata
    "Hol4SmlMacro" {timestamp=TDB.timestamp, path=TDB.path}
  
  fun op sml_sequence_reference_def _ = ()
  val op sml_sequence_reference_def = TDB.find "sml_sequence_reference_def"
  fun op sml_match_reference_def _ = ()
  val op sml_match_reference_def = TDB.find "sml_match_reference_def"
  fun op matched_body_bind_is_preserved _ = ()
  val op matched_body_bind_is_preserved = TDB.find
    "matched_body_bind_is_preserved"
  fun op lower_sml_sequence_correct _ = ()
  val op lower_sml_sequence_correct = TDB.find "lower_sml_sequence_correct"
  fun op lower_sml_multifn_def _ = ()
  val op lower_sml_multifn_def = TDB.find "lower_sml_multifn_def"
  fun op lower_sml_multifn_closure _ = ()
  val op lower_sml_multifn_closure = TDB.find "lower_sml_multifn_closure"
  fun op lower_sml_multifn_application_def _ = ()
  val op lower_sml_multifn_application_def = TDB.find
    "lower_sml_multifn_application_def"
  fun op lower_sml_multifn_application_correct _ = ()
  val op lower_sml_multifn_application_correct = TDB.find
    "lower_sml_multifn_application_correct"
  fun op lower_sml_match_def _ = ()
  val op lower_sml_match_def = TDB.find "lower_sml_match_def"
  fun op lower_sml_match_correct _ = ()
  val op lower_sml_match_correct = TDB.find "lower_sml_match_correct"
  fun op evaluate_match_fallback _ = ()
  val op evaluate_match_fallback = TDB.find "evaluate_match_fallback"
  fun op can_pmatch_all_fallback _ = ()
  val op can_pmatch_all_fallback = TDB.find "can_pmatch_all_fallback"
  fun op cakeml_function_equality _ = ()
  val op cakeml_function_equality = TDB.find "cakeml_function_equality"
  fun op cakeml_empty_match_raises_bind _ = ()
  val op cakeml_empty_match_raises_bind = TDB.find
    "cakeml_empty_match_raises_bind"
  
val _ = if !Globals.print_thy_loads then TextIO.print "done\n" else ()
val _ = Theory.load_complete "Hol4SmlMacro"

end
