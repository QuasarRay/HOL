Theory Hol4CakeCompile
Ancestors
  compiler
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
val parse_eval = EVAL `parse_cml_input hol4_cakeml_source`;
val parse_rhs = rhs (concl parse_eval);
val (ctor, prog_tm) = dest_comb parse_rhs
  handle HOL_ERR _ => raise Fail "CakeML parser did not return a sum";
val _ = if same_const ctor `INR` then ()
        else raise Fail "macro output failed verified CakeML parsing";

val hol4_cakeml_prog_def = Define `hol4_cakeml_prog = ^prog_tm`;

Theorem hol4_cakeml_parses:
  parse_cml_input hol4_cakeml_source = INR hol4_cakeml_prog
Proof
  rw [parse_eval, hol4_cakeml_prog_def]
QED

val hol4_cakeml_compiled =
  eval_cake_compile_x64 "hol4_cakeml_" hol4_cakeml_prog_def output_asm
  |> check_thm;

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
