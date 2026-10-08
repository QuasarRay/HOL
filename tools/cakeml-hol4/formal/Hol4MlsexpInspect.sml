(* Inspect every exported theorem after a fresh source reconstruction. *)
fun inspect () = let
  val root = case OS.Process.getEnv "HOL4_MLSEXP_BUILD_DIR" of
      SOME value => value | NONE => raise Fail "missing build directory"
  val _ = loadPath := (root ^ "/.hol/objs") :: root :: !loadPath
  val _ = load "mlsexpTheory"
  val theorems = DB.theorems "mlsexp"
  val required = ["lex_aux_sexp2tree", "lex_aux_sexp_to_list",
    "parse_sexp_to_string", "parse_sexp_to_pretty_string",
    "fromString_sexp_to_string", "fromString_sexp_to_pretty_string"]
  val _ = List.app (fn name => ignore (DB.fetch "mlsexp" name)) required
  val _ = if null theorems then raise Fail "no mlsexp theorems" else ()
  val _ = List.app (fn (name,th) => let
      val (oracles,axioms) = Tag.dest_tag (Thm.tag th)
      val _ = if null (Thm.hyp th) andalso null axioms andalso
          List.all (fn tag => tag = "DISK_THM") oracles then ()
        else raise Fail ("unclean mlsexp theorem: " ^ name)
    in print ("KERNEL_THEOREM mlsexp." ^ name ^ "\n" ^
              thm_to_string th ^ "\n") end) theorems
in print ("HOL4_MLSEXP_EXPORTS_INSPECTED " ^
          Int.toString (length theorems) ^ "\n") end;
val _ = ((inspect (); OS.Process.exit OS.Process.success)
  handle e => (print ("HOL4_MLSEXP_INSPECTION_FAILED " ^ General.exnMessage e ^ "\n");
               OS.Process.exit OS.Process.failure));
