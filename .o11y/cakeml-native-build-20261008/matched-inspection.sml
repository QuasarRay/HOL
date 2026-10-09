(* Inspect reconstructed exports in a fresh release-matched checker process. *)
fun inspect_all () = let
  val root = case OS.Process.getEnv "CAKEMLDIR" of
      SOME s => s | NONE => raise Fail "CAKEMLDIR unset"
  val backend = root ^ "/compiler/backend"
  val _ = loadPath := (backend ^ "/.hol/objs") :: backend :: !loadPath
  val theories = ["semanticPrimitivesProps", "typeSysProps", "evaluateProps", "closLang"]
  val _ = List.app (fn thy => load (thy ^ "Theory")) theories
  val _ = ignore (prim_mk_const {Thy="closLang",Name="exp1_size"})
  val _ = ignore (DB.fetch "closLang" "exp1_size_lemma")
  fun inspect thy = let
    val ts = DB.theorems thy
    val _ = if null ts then raise Fail ("no theorems: " ^ thy) else ()
    val _ = List.app (fn (name,th) => let
      val (oracles,axioms) = Tag.dest_tag (Thm.tag th)
      val _ = if null (Thm.hyp th) andalso null axioms andalso
          List.all (fn s => s = "DISK_THM") oracles then ()
        else raise Fail ("unclean: " ^ thy ^ "." ^ name)
      in print ("KERNEL_THEOREM " ^ thy ^ "." ^ name ^ "\n" ^ thm_to_string th ^ "\n") end) ts
    in print ("MATCHED_EXPORTS_INSPECTED " ^ thy ^ " " ^ Int.toString (length ts) ^ "\n") end
  val _ = List.app inspect theories
in print "MATCHED_COMPILER_EXPORT_INSPECTION_PASSED\n" end;
val _ = ((inspect_all (); OS.Process.exit OS.Process.success)
  handle e => (print ("MATCHED_INSPECTION_FAILED " ^ General.exnMessage e ^ "\n");
               OS.Process.exit OS.Process.failure));
