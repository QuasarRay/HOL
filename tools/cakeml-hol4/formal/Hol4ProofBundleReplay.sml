(* Theory import inspection only. Loading .dat files does not replay the
   original proof derivation. A release requires separate source reconstruction. *)
open HolKernel boolLib bossLib;

fun require_env name =
  case OS.Process.getEnv name of
    SOME s => s
  | NONE => raise Fail ("missing required environment variable: " ^ name);

fun split_qname qname =
  case String.fields (fn c => c = #".") qname of
    [thy, name] => (thy, name)
  | _ => raise Fail "HOL4_RELEASE_THEOREM must be Theory.theorem";

val bundle_dir = require_env "HOL4_RELEASE_BUNDLE_DIR";
val bundle_digest = require_env "HOL4_RELEASE_BUNDLE_SHA256";
val qname = require_env "HOL4_RELEASE_THEOREM";
val (thy, name) = split_qname qname;

val _ = loadPath := bundle_dir :: !loadPath;
val _ = load (thy ^ "Theory");
val th = DB.fetch thy name;
val (oracles, axioms) = Tag.dest_tag (Thm.tag th);
val acceptable =
  null (Thm.hyp th) andalso
  List.all (fn tag => tag = "DISK_THM") oracles andalso
  null axioms;

val _ = if acceptable then ()
        else raise Fail ("release theorem is open or contaminated: " ^ qname);
val _ = print ("HOL4_PROOF_BUNDLE_OK " ^ bundle_digest ^ "\n");
val _ = OS.Process.exit OS.Process.success;
