Theory Hol4CakeCompile
Ancestors
  ast cmlParse lexer_fun
Libs
  preamble eval_cake_compile_x64Lib

fun require_env name =
  case OS.Process.getEnv name of
    SOME s => s
  | NONE => raise Fail ("missing required environment variable: " ^ name);

val source_path = require_env "HOL4_CAKEML_PROGRAM_CML";
val output_asm = require_env "HOL4_CAKEML_OUTPUT_ASM";

val ins = TextIO.openIn source_path;
val source = TextIO.inputAll ins;
val _ = TextIO.closeIn ins;
val source_tm = stringSyntax.fromMLstring source;

val hol4_cakeml_source_def = Define `hol4_cakeml_source = ^source_tm`;
(* Reuse the verified lexer/parser directly. The compiler's command-line
   wrapper additionally imports the entire basis/bootstrap translator. *)
(* Reuse CakeML's parser-test evaluation policy. Eager evaluation of dead
   parser branches consumes unbounded time and memory on even small inputs. *)
val _ = computeLib.del_consts [``list_CASE``];
val _ = computeLib.add_funs [listTheory.list_case_def];
(* The lexer intentionally marks this keyword table nocompute; direct parser
   evaluation must explicitly install its defining theorem. *)
val _ = computeLib.add_funs [lexer_funTheory.get_token_def];
val _ = List.app (fn tm => computeLib.temp_set_EVAL_skip tm (SOME 1))
  [``OPTION_CHOICE``, ``OPTION_BIND``, ``OPTION_IGNORE_BIND``,
   ``option_CASE``, ``list_CASE``, ``pair_CASE``, ``COND``];
val parse_eval = (REWRITE_CONV [hol4_cakeml_source_def] THENC EVAL)
                  ``parse_prog (lexer_fun hol4_cakeml_source)``;
val parse_rhs = rhs (concl parse_eval);
val (ctor, args) = strip_comb parse_rhs;
val _ = if #Name (dest_thy_const ctor) = "Success" andalso length args = 3 then ()
        else raise Fail "macro output failed verified CakeML parsing or evaluation";
val prog_tm = List.nth (args,1);

val hol4_cakeml_prog_def = Define `hol4_cakeml_prog = ^prog_tm`;

val hol4_cakeml_parses = save_thm ("hol4_cakeml_parses",parse_eval);

val hol4_cakeml_compiled =
  eval_cake_compile_x64 "hol4_cakeml_" hol4_cakeml_prog_def output_asm
  |> check_thm;
val _ = if aconv (Thm.concl hol4_cakeml_compiled) boolSyntax.T
        then raise Fail "compiler returned only TRUTH, not a machine-code theorem"
        else ();

fun require_clean_closed name th =
  let val tag = Thm.tag th
  in
    if null (Thm.hyp th) andalso (Tag.isEmpty tag orelse Tag.isDisk tag)
    then ()
    else raise Fail ("open or contaminated theorem: " ^ name)
  end;

val _ = require_clean_closed "hol4_cakeml_parses" hol4_cakeml_parses;
val _ = require_clean_closed "hol4_cakeml_compiled" hol4_cakeml_compiled;
val _ = save_thm ("hol4_cakeml_compiled", hol4_cakeml_compiled);
val _ = export_theory();
