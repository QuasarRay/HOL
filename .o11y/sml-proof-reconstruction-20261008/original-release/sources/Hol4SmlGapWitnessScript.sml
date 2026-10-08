(* Target-side witnesses for the uploaded audit, at its exact CakeML pin.
   These are not a formalization of the complete SML97 Definition and do not
   certify all report entries or a source-to-machine implementation. *)
Theory Hol4SmlGapWitness
Ancestors
  evaluate semanticPrimitives ast namespace cmlPtreeConversion

Theorem target_closure_equality:
  do_eq (Closure env1 arg1 body1) (Closure env2 arg2 body2) = Eq_val T
Proof
  simp [do_eq_def]
QED

Theorem target_recursive_closure_equality:
  do_eq (Recclosure env1 funs1 name1) (Recclosure env2 funs2 name2) = Eq_val T
Proof
  simp [do_eq_def]
QED

(* Distinct exception values make operand order observable without needing a
   model of external I/O. Constructor fields are evaluated right to left. *)
Theorem target_tuple_raises_second:
  nsLookup env.v first_id = SOME first_value /\
  nsLookup env.v second_id = SOME second_value ==>
  evaluate st env
    [Con NONE [Raise (Var first_id); Raise (Var second_id)]] =
  (st,Rerr (Rraise second_value))
Proof
  simp [evaluate_def,do_con_check_def]
QED

Theorem explicit_sequence_raises_first:
  nsLookup env.v first_id = SOME first_value ==>
  evaluate st env [Let NONE (Raise (Var first_id)) (Raise (Var second_id))] =
  (st,Rerr (Rraise first_value))
Proof
  simp [evaluate_def]
QED

Theorem target_order_is_observable:
  nsLookup env.v first_id = SOME first_value /\
  nsLookup env.v second_id = SOME second_value /\
  first_value <> second_value ==>
  evaluate st env
    [Con NONE [Raise (Var first_id); Raise (Var second_id)]] <>
  evaluate st env [Let NONE (Raise (Var first_id)) (Raise (Var second_id))]
Proof
  strip_tac >> asm_simp_tac (srw_ss()) [evaluate_def,do_con_check_def]
QED

Theorem target_failed_case_raises_bind:
  evaluate st env [Mat (Lit (IntLit 1)) [(Plit (IntLit 0),Lit (IntLit 9))]] =
  (st,Rerr (Rraise bind_exn_v))
Proof
  simp [evaluate_def,can_pmatch_all_def,pmatch_def,pat_bindings_def,lit_same_type_def]
QED

(* Signature acceptance and signature erasure are different facts. This
   theorem only concerns the conversion of already accepted parse trees. *)
Theorem accepted_inline_signature_is_erased:
  tokcheckl [structtok; structuretok; eqtok; endtok]
            [StructT; StructureT; EqualsT; EndT] /\
  tokcheck sealtok SealT /\
  ptree_StructName name_pt = SOME name /\
  ptree_SignatureValue signature_pt = SOME () /\
  ptree_Decls decls_pt = SOME decls ==>
  ptree_Structure
    (Nd (mkNT nStructure,loc)
      [structuretok; name_pt;
       Nd (mkNT nOptionalSignatureAscription,ascription_loc) [sealtok; signature_pt];
       eqtok; structtok; decls_pt; endtok]) = SOME (Dmod name decls)
Proof
  simp [ptree_Decl_def]
QED

val witness_theorems =
  [("target_closure_equality",target_closure_equality),
   ("target_recursive_closure_equality",target_recursive_closure_equality),
   ("target_tuple_raises_second",target_tuple_raises_second),
   ("explicit_sequence_raises_first",explicit_sequence_raises_first),
   ("target_order_is_observable",target_order_is_observable),
   ("target_failed_case_raises_bind",target_failed_case_raises_bind),
   ("accepted_inline_signature_is_erased",accepted_inline_signature_is_erased)];
val _ = List.app (fn (name,th) =>
  let val (oracles,axioms) = Tag.dest_tag (Thm.tag th)
  in if null (Thm.hyp th) andalso null axioms andalso
        List.all (fn x => x = "DISK_THM") oracles then ()
     else raise Fail ("unclean report witness: " ^ name)
  end) witness_theorems;
val _ = export_theory();
