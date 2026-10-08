structure Hol4ProofSearchLib :> Hol4ProofSearchLib =
struct
open HolKernel boolLib bossLib;

fun inspect_exact name expected th =
  let val (oracles, axioms) = Tag.dest_tag (Thm.tag th)
  in
    if null (Thm.hyp th) andalso aconv (Thm.concl th) expected andalso
       List.all (fn tag => tag = "DISK_THM") oracles andalso null axioms
    then ()
    else raise Fail ("open, contaminated, or wrong theorem: " ^ name)
  end;

fun fetch_named qname =
  case String.fields (fn c => c = #".") qname of
    [thy, name] => DB.fetch thy name
  | _ => raise Fail ("expected Theory.theorem rewrite name: " ^ qname);

fun attempt name label tac goal =
  let val th = prove (goal, tac)
      val _ = inspect_exact name goal th
  in SOME (label, th) end
  handle HOL_ERR _ => NONE
       | Fail _ => NONE;

(* Thunks are essential: an eager list runs every search even after success. *)
fun first_success [] = raise Fail "all proof-search strategies failed"
  | first_success (next :: rest) =
      (case next () of NONE => first_success rest | SOME x => x);

fun read_rewrite_names path =
  let
    val ins = TextIO.openIn path
    val text = TextIO.inputAll ins before TextIO.closeIn ins
    fun nonempty s = String.size s > 0
  in
    List.filter nonempty
      (String.tokens (fn c => c = #"\n" orelse c = #"\r") text)
  end;

fun prove_with_search {name, goal, egglog_rewrites} =
  let
    val rewrites = List.map fetch_named egglog_rewrites
    (* Egglog decides only whether a named HOL4 rewrite set is worth trying.
       The accepted result is reconstructed by the HOL4 kernel. *)
    val (engine, th) = first_success
      [fn () => attempt name "egglog-replay" (bossLib.simp rewrites) goal,
       fn () => attempt name "z3-replay" HolSmtLib.Z3_TAC goal,
       fn () => (tacticToe.set_timeout 30.0;
                 attempt name "tactictoe-replay" tacticToe.ttt goal)]
  in
    (engine, th)
  end;

fun prove_with_search_file {name, goal, egglog_rewrites_path} =
  prove_with_search
    {name = name, goal = goal,
     egglog_rewrites = read_rewrite_names egglog_rewrites_path};
end
