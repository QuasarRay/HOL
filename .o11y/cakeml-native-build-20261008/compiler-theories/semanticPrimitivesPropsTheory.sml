structure semanticPrimitivesPropsTheory :> semanticPrimitivesPropsTheory =
struct
  
  val _ = if !Globals.print_thy_loads
    then TextIO.print "Loading semanticPrimitivesPropsTheory ... "
    else ()
  
  open Type Term Thm
  local open namespacePropsTheory semanticPrimitivesTheory in end;
  
  structure TDB = struct
    val path =
      OS.Path.base (#(FILE)) ^ ".dat"
    val timestamp = HOLFileSys.modTime path
    val thydata = 
      TheoryReader.load_thydata {
        thyname = "semanticPrimitivesProps",
        hash = "7d56eab4a9356a68ec01ddc6b8ef342bafcfe802",
        path = path
      }
    fun find s = #1 (valOf (Symtab.lookup thydata s))
  end
  val () = Theory.record_metadata
    "semanticPrimitivesProps" {timestamp=TDB.timestamp, path=TDB.path}
  
  fun op with_same_v _ = () val op with_same_v = TDB.find "with_same_v"
  fun op with_same_clock _ = ()
  val op with_same_clock = TDB.find "with_same_clock"
  fun op unchanged_env _ = ()
  val op unchanged_env = TDB.find "unchanged_env"
  fun op sv_rel_trans _ = () val op sv_rel_trans = TDB.find "sv_rel_trans"
  fun op sv_rel_refl _ = () val op sv_rel_refl = TDB.find "sv_rel_refl"
  fun op sv_rel_mono _ = () val op sv_rel_mono = TDB.find "sv_rel_mono"
  fun op sv_rel_ind _ = () val op sv_rel_ind = TDB.find "sv_rel_ind"
  fun op sv_rel_def _ = () val op sv_rel_def = TDB.find "sv_rel_def"
  fun op sv_rel_cases _ = () val op sv_rel_cases = TDB.find "sv_rel_cases"
  fun op sv_rel_O _ = () val op sv_rel_O = TDB.find "sv_rel_O"
  fun op sv_every_ind _ = () val op sv_every_ind = TDB.find "sv_every_ind"
  fun op sv_every_def _ = () val op sv_every_def = TDB.find "sv_every_def"
  fun op store_vs_def _ = () val op store_vs_def = TDB.find "store_vs_def"
  fun op store_v_vs_def _ = ()
  val op store_v_vs_def = TDB.find "store_v_vs_def"
  fun op shift_lookup_def _ = ()
  val op shift_lookup_def = TDB.find "shift_lookup_def"
  fun op result_rel_trans _ = ()
  val op result_rel_trans = TDB.find "result_rel_trans"
  fun op result_rel_refl _ = ()
  val op result_rel_refl = TDB.find "result_rel_refl"
  fun op result_rel_ind _ = ()
  val op result_rel_ind = TDB.find "result_rel_ind"
  fun op result_rel_def _ = ()
  val op result_rel_def = TDB.find "result_rel_def"
  fun op result_rel_Rval _ = ()
  val op result_rel_Rval = TDB.find "result_rel_Rval"
  fun op result_rel_Rerr2 _ = ()
  val op result_rel_Rerr2 = TDB.find "result_rel_Rerr2"
  fun op result_rel_Rerr1 _ = ()
  val op result_rel_Rerr1 = TDB.find "result_rel_Rerr1"
  fun op prim_type_cases _ = ()
  val op prim_type_cases = TDB.find "prim_type_cases"
  fun op pmatch_nsAppend_No_match _ = ()
  val op pmatch_nsAppend_No_match = TDB.find "pmatch_nsAppend_No_match"
  fun op pmatch_nsAppend_Match _ = ()
  val op pmatch_nsAppend_Match = TDB.find "pmatch_nsAppend_Match"
  fun op pmatch_nsAppend _ = ()
  val op pmatch_nsAppend = TDB.find "pmatch_nsAppend"
  fun op pmatch_extend _ = ()
  val op pmatch_extend = TDB.find "pmatch_extend"
  fun op pmatch_append _ = ()
  val op pmatch_append = TDB.find "pmatch_append"
  fun op pmatch_acc _ = () val op pmatch_acc = TDB.find "pmatch_acc"
  fun op pat_bindings_accum _ = ()
  val op pat_bindings_accum = TDB.find "pat_bindings_accum"
  fun op nat_to_v_11 _ = () val op nat_to_v_11 = TDB.find "nat_to_v_11"
  fun op map_sv_def _ = () val op map_sv_def = TDB.find "map_sv_def"
  fun op map_sv_compose _ = ()
  val op map_sv_compose = TDB.find "map_sv_compose"
  fun op map_result_def _ = ()
  val op map_result_def = TDB.find "map_result_def"
  fun op map_result_Rval _ = ()
  val op map_result_Rval = TDB.find "map_result_Rval"
  fun op map_result_Rerr _ = ()
  val op map_result_Rerr = TDB.find "map_result_Rerr"
  fun op map_match_ind _ = ()
  val op map_match_ind = TDB.find "map_match_ind"
  fun op map_match_def _ = ()
  val op map_match_def = TDB.find "map_match_def"
  fun op map_error_result_def _ = ()
  val op map_error_result_def = TDB.find "map_error_result_def"
  fun op map_error_result_Rtype_error _ = ()
  val op map_error_result_Rtype_error = TDB.find
    "map_error_result_Rtype_error"
  fun op map_error_result_I _ = ()
  val op map_error_result_I = TDB.find "map_error_result_I"
  fun op lit_same_type_sym _ = ()
  val op lit_same_type_sym = TDB.find "lit_same_type_sym"
  fun op lit_same_type_refl _ = ()
  val op lit_same_type_refl = TDB.find "lit_same_type_refl"
  fun op is_Refv_ind _ = () val op is_Refv_ind = TDB.find "is_Refv_ind"
  fun op is_Refv_def_primitive _ = ()
  val op is_Refv_def_primitive = TDB.find "is_Refv_def_primitive"
  fun op is_Refv_def _ = () val op is_Refv_def = TDB.find "is_Refv_def"
  fun op find_recfun_el _ = ()
  val op find_recfun_el = TDB.find "find_recfun_el"
  fun op find_recfun_ALOOKUP _ = ()
  val op find_recfun_ALOOKUP = TDB.find "find_recfun_ALOOKUP"
  fun op extend_dec_env_assoc _ = ()
  val op extend_dec_env_assoc = TDB.find "extend_dec_env_assoc"
  fun op exc_rel_type_error2 _ = ()
  val op exc_rel_type_error2 = TDB.find "exc_rel_type_error2"
  fun op exc_rel_type_error1 _ = ()
  val op exc_rel_type_error1 = TDB.find "exc_rel_type_error1"
  fun op exc_rel_trans _ = ()
  val op exc_rel_trans = TDB.find "exc_rel_trans"
  fun op exc_rel_refl _ = () val op exc_rel_refl = TDB.find "exc_rel_refl"
  fun op exc_rel_raise2 _ = ()
  val op exc_rel_raise2 = TDB.find "exc_rel_raise2"
  fun op exc_rel_raise1 _ = ()
  val op exc_rel_raise1 = TDB.find "exc_rel_raise1"
  fun op exc_rel_ind _ = () val op exc_rel_ind = TDB.find "exc_rel_ind"
  fun op exc_rel_def _ = () val op exc_rel_def = TDB.find "exc_rel_def"
  fun op every_result_def _ = ()
  val op every_result_def = TDB.find "every_result_def"
  fun op every_error_result_def _ = ()
  val op every_error_result_def = TDB.find "every_error_result_def"
  fun op do_shift_ind _ = () val op do_shift_ind = TDB.find "do_shift_ind"
  fun op do_shift_def _ = () val op do_shift_def = TDB.find "do_shift_def"
  fun op do_opapp_cases _ = ()
  val op do_opapp_cases = TDB.find "do_opapp_cases"
  fun op do_conversion_check_type _ = ()
  val op do_conversion_check_type = TDB.find "do_conversion_check_type"
  fun op do_con_check_build_conv _ = ()
  val op do_con_check_build_conv = TDB.find "do_con_check_build_conv"
  fun op do_arith_check_type _ = ()
  val op do_arith_check_type = TDB.find "do_arith_check_type"
  fun op do_app_type_error _ = ()
  val op do_app_type_error = TDB.find "do_app_type_error"
  fun op do_app_not_timeout _ = ()
  val op do_app_not_timeout = TDB.find "do_app_not_timeout"
  fun op do_app_ffi_unchanged _ = ()
  val op do_app_ffi_unchanged = TDB.find "do_app_ffi_unchanged"
  fun op do_app_ffi_changed _ = ()
  val op do_app_ffi_changed = TDB.find "do_app_ffi_changed"
  fun op do_app_cases _ = () val op do_app_cases = TDB.find "do_app_cases"
  fun op do_app_SOME_ffi_same _ = ()
  val op do_app_SOME_ffi_same = TDB.find "do_app_SOME_ffi_same"
  fun op do_app_NONE_ffi _ = ()
  val op do_app_NONE_ffi = TDB.find "do_app_NONE_ffi"
  fun op dest_Refv_def _ = ()
  val op dest_Refv_def = TDB.find "dest_Refv_def"
  fun op ctors_of_tdef_def _ = ()
  val op ctors_of_tdef_def = TDB.find "ctors_of_tdef_def"
  fun op ctors_of_dec_ind _ = ()
  val op ctors_of_dec_ind = TDB.find "ctors_of_dec_ind"
  fun op ctors_of_dec_def_primitive _ = ()
  val op ctors_of_dec_def_primitive = TDB.find "ctors_of_dec_def_primitive"
  fun op ctors_of_dec_def _ = ()
  val op ctors_of_dec_def = TDB.find "ctors_of_dec_def"
  fun op concrete_v_simps _ = ()
  val op concrete_v_simps = TDB.find "concrete_v_simps"
  fun op concrete_v_list _ = ()
  val op concrete_v_list = TDB.find "concrete_v_list"
  fun op build_rec_env_merge _ = ()
  val op build_rec_env_merge = TDB.find "build_rec_env_merge"
  fun op LIST_REL_store_vs_intro _ = ()
  val op LIST_REL_store_vs_intro = TDB.find "LIST_REL_store_vs_intro"
  fun op FV_pes_MAP _ = () val op FV_pes_MAP = TDB.find "FV_pes_MAP"
  fun op FV_ind _ = () val op FV_ind = TDB.find "FV_ind"
  fun op FV_defs_MAP _ = () val op FV_defs_MAP = TDB.find "FV_defs_MAP"
  fun op FV_def _ = () val op FV_def = TDB.find "FV_def"
  fun op FV_dec_def _ = () val op FV_dec_def = TDB.find "FV_dec_def"
  fun op EVERY_sv_every_MAP_map_sv _ = ()
  val op EVERY_sv_every_MAP_map_sv = TDB.find "EVERY_sv_every_MAP_map_sv"
  fun op EVERY_sv_every_EVERY_store_vs _ = ()
  val op EVERY_sv_every_EVERY_store_vs = TDB.find
    "EVERY_sv_every_EVERY_store_vs"
  fun op EVERY_store_vs_intro _ = ()
  val op EVERY_store_vs_intro = TDB.find "EVERY_store_vs_intro"
  fun op Boolv_11 _ = () val op Boolv_11 = TDB.find "Boolv_11"
  
val _ = if !Globals.print_thy_loads then TextIO.print "done\n" else ()
val _ = Theory.load_complete "semanticPrimitivesProps"

end
