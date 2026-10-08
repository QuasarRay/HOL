(* Load exports after source reconstruction; imports alone are not replay. *)
fun inspect () = let
  val _ = load "Hol4SmlGapWitnessTheory"
  val _ = Globals.max_print_depth := 100
  val names =
    ["target_closure_equality", "target_recursive_closure_equality",
     "target_tuple_raises_second", "explicit_sequence_raises_first",
     "target_order_is_observable", "target_failed_case_raises_bind",
     "accepted_inline_signature_is_erased"]
  val _ = List.app (fn name =>
    let val th = DB.fetch "Hol4SmlGapWitness" name
        val (oracles,axioms) = Tag.dest_tag (Thm.tag th)
        val _ = if null (Thm.hyp th) andalso null axioms andalso
                   List.all (fn x => x = "DISK_THM") oracles then ()
                else raise Fail ("unclean gap witness: " ^ name)
    in print ("KERNEL_THEOREM Hol4SmlGapWitness." ^ name ^ "\n" ^
              thm_to_string th ^ "\n") end) names
in print ("HOL4_GAP_WITNESSES_INSPECTED " ^ Int.toString (length names) ^ "\n") end;
val _ = ((inspect (); OS.Process.exit OS.Process.success)
  handle e => (print ("HOL4_GAP_INSPECTION_FAILED " ^ General.exnMessage e ^ "\n");
               OS.Process.exit OS.Process.failure));
