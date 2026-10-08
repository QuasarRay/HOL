structure Hol4SmlOrderTheory :> Hol4SmlOrderTheory =
struct
  
  val _ = if !Globals.print_thy_loads
    then TextIO.print "Loading Hol4SmlOrderTheory ... "
    else ()
  
  open Type Term Thm
  local open Hol4SmlApplicationTheory evaluatePropsTheory in end;
  
  structure TDB = struct
    val path =
      holpathdb.subst_pathvars "/workspace/scratch/7755a98cf62b/release-context/Hol4SmlOrderTheory.dat"
    val timestamp = HOLFileSys.modTime path
    val thydata = 
      TheoryReader.load_thydata {
        thyname = "Hol4SmlOrder",
        hash = "1ced6269d4b92e79ba84eb3eea63de7c1419f629",
        path = path
      }
    fun find s = #1 (valOf (Symtab.lookup thydata s))
  end
  val () = Theory.record_metadata
    "Hol4SmlOrder" {timestamp=TDB.timestamp, path=TDB.path}
  
  fun op source_closure_environment_is_preserved _ = ()
  val op source_closure_environment_is_preserved = TDB.find
    "source_closure_environment_is_preserved"
  fun op sml_sequence_list_reference_def _ = ()
  val op sml_sequence_list_reference_def = TDB.find
    "sml_sequence_list_reference_def"
  fun op sml_sequence_list_derived_def _ = ()
  val op sml_sequence_list_derived_def = TDB.find
    "sml_sequence_list_derived_def"
  fun op sml_con_ltr_reference_def _ = ()
  val op sml_con_ltr_reference_def = TDB.find "sml_con_ltr_reference_def"
  fun op sml_application_ltr_reference_def _ = ()
  val op sml_application_ltr_reference_def = TDB.find
    "sml_application_ltr_reference_def"
  fun op pmatch_capture_variables _ = ()
  val op pmatch_capture_variables = TDB.find "pmatch_capture_variables"
  fun op lowered_tuple_raises_first _ = ()
  val op lowered_tuple_raises_first = TDB.find "lowered_tuple_raises_first"
  fun op lowered_tuple_keeps_value_order _ = ()
  val op lowered_tuple_keeps_value_order = TDB.find
    "lowered_tuple_keeps_value_order"
  fun op lower_sml_sequence_list_def _ = ()
  val op lower_sml_sequence_list_def = TDB.find
    "lower_sml_sequence_list_def"
  fun op lower_sml_sequence_list_correct _ = ()
  val op lower_sml_sequence_list_correct = TDB.find
    "lower_sml_sequence_list_correct"
  fun op lower_sml_con_ltr_def _ = ()
  val op lower_sml_con_ltr_def = TDB.find "lower_sml_con_ltr_def"
  fun op lower_sml_con_ltr_correct _ = ()
  val op lower_sml_con_ltr_correct = TDB.find "lower_sml_con_ltr_correct"
  fun op lower_sml_application_ltr_def _ = ()
  val op lower_sml_application_ltr_def = TDB.find
    "lower_sml_application_ltr_def"
  fun op lower_sml_application_ltr_correct _ = ()
  val op lower_sml_application_ltr_correct = TDB.find
    "lower_sml_application_ltr_correct"
  fun op lower_sequence_matches_derived_form _ = ()
  val op lower_sequence_matches_derived_form = TDB.find
    "lower_sequence_matches_derived_form"
  fun op evaluate_variable_list _ = ()
  val op evaluate_variable_list = TDB.find "evaluate_variable_list"
  fun op derived_sequence_list_correct _ = ()
  val op derived_sequence_list_correct = TDB.find
    "derived_sequence_list_correct"
  fun op construct_from_variable_list _ = ()
  val op construct_from_variable_list = TDB.find
    "construct_from_variable_list"
  fun op captured_variable_lookups _ = ()
  val op captured_variable_lookups = TDB.find "captured_variable_lookups"
  fun op capture_pattern_bindings _ = ()
  val op capture_pattern_bindings = TDB.find "capture_pattern_bindings"
  fun op apply_from_variable_list _ = ()
  val op apply_from_variable_list = TDB.find "apply_from_variable_list"
  fun op application_reference_two _ = ()
  val op application_reference_two = TDB.find "application_reference_two"
  
val _ = if !Globals.print_thy_loads then TextIO.print "done\n" else ()
val _ = Theory.load_complete "Hol4SmlOrder"

end
