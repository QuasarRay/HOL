structure typeSysPropsTheory :> typeSysPropsTheory =
struct
  
  val _ = if !Globals.print_thy_loads
    then TextIO.print "Loading typeSysPropsTheory ... "
    else ()
  
  open Type Term Thm
  local open semanticPrimitivesPropsTheory typeSoundInvariantsTheory
  in end;
  
  structure TDB = struct
    val path =
      OS.Path.base (#(FILE)) ^ ".dat"
    val timestamp = HOLFileSys.modTime path
    val thydata = 
      TheoryReader.load_thydata {
        thyname = "typeSysProps",
        hash = "51203c28834e7151bf2752bd98965dbd4be81349",
        path = path
      }
    fun find s = #1 (valOf (Symtab.lookup thydata s))
  end
  val () = Theory.record_metadata
    "typeSysProps" {timestamp=TDB.timestamp, path=TDB.path}
  
  fun op unchanged_tenv _ = ()
  val op unchanged_tenv = TDB.find "unchanged_tenv"
  fun op type_v_freevars _ = ()
  val op type_v_freevars = TDB.find "type_v_freevars"
  fun op type_subst_deBruijn_subst_list _ = ()
  val op type_subst_deBruijn_subst_list = TDB.find
    "type_subst_deBruijn_subst_list"
  fun op type_subst_deBruijn_inc_list _ = ()
  val op type_subst_deBruijn_inc_list = TDB.find
    "type_subst_deBruijn_inc_list"
  fun op type_subst _ = () val op type_subst = TDB.find "type_subst"
  fun op type_recfun_lookup _ = ()
  val op type_recfun_lookup = TDB.find "type_recfun_lookup"
  fun op type_ps_length _ = ()
  val op type_ps_length = TDB.find "type_ps_length"
  fun op type_pes_def _ = () val op type_pes_def = TDB.find "type_pes_def"
  fun op type_pes_cons _ = ()
  val op type_pes_cons = TDB.find "type_pes_cons"
  fun op type_p_tenvV_indep _ = ()
  val op type_p_tenvV_indep = TDB.find "type_p_tenvV_indep"
  fun op type_p_subst _ = () val op type_p_subst = TDB.find "type_p_subst"
  fun op type_p_freevars _ = ()
  val op type_p_freevars = TDB.find "type_p_freevars"
  fun op type_p_bvl _ = () val op type_p_bvl = TDB.find "type_p_bvl"
  fun op type_op_cases _ = ()
  val op type_op_cases = TDB.find "type_op_cases"
  fun op type_funs_tenv_exp_ok _ = ()
  val op type_funs_tenv_exp_ok = TDB.find "type_funs_tenv_exp_ok"
  fun op type_funs_lookup _ = ()
  val op type_funs_lookup = TDB.find "type_funs_lookup"
  fun op type_funs_find_recfun _ = ()
  val op type_funs_find_recfun = TDB.find "type_funs_find_recfun"
  fun op type_funs_distinct _ = ()
  val op type_funs_distinct = TDB.find "type_funs_distinct"
  fun op type_funs_Tfn _ = ()
  val op type_funs_Tfn = TDB.find "type_funs_Tfn"
  fun op type_funs_MAP_FST _ = ()
  val op type_funs_MAP_FST = TDB.find "type_funs_MAP_FST"
  fun op type_es_list_rel _ = ()
  val op type_es_list_rel = TDB.find "type_es_list_rel"
  fun op type_es_length _ = ()
  val op type_es_length = TDB.find "type_es_length"
  fun op type_e_subst_lem3 _ = ()
  val op type_e_subst_lem3 = TDB.find "type_e_subst_lem3"
  fun op type_e_subst _ = () val op type_e_subst = TDB.find "type_e_subst"
  fun op type_e_freevars _ = ()
  val op type_e_freevars = TDB.find "type_e_freevars"
  fun op type_ds_sing _ = () val op type_ds_sing = TDB.find "type_ds_sing"
  fun op type_ds_empty _ = ()
  val op type_ds_empty = TDB.find "type_ds_empty"
  fun op type_def_to_ctMap_mem _ = ()
  val op type_def_to_ctMap_mem = TDB.find "type_def_to_ctMap_mem"
  fun op type_def_to_ctMap_ind _ = ()
  val op type_def_to_ctMap_ind = TDB.find "type_def_to_ctMap_ind"
  fun op type_def_to_ctMap_def _ = ()
  val op type_def_to_ctMap_def = TDB.find "type_def_to_ctMap_def"
  fun op type_d_tenv_ok_helper _ = ()
  val op type_d_tenv_ok_helper = TDB.find "type_d_tenv_ok_helper"
  fun op type_d_tenv_ok _ = ()
  val op type_d_tenv_ok = TDB.find "type_d_tenv_ok"
  fun op type_d_check_uniq _ = ()
  val op type_d_check_uniq = TDB.find "type_d_check_uniq"
  fun op type_ctor_long _ = ()
  val op type_ctor_long = TDB.find "type_ctor_long"
  fun op tveLookup_subst_some _ = ()
  val op tveLookup_subst_some = TDB.find "tveLookup_subst_some"
  fun op tveLookup_subst_none _ = ()
  val op tveLookup_subst_none = TDB.find "tveLookup_subst_none"
  fun op tveLookup_no_tvs _ = ()
  val op tveLookup_no_tvs = TDB.find "tveLookup_no_tvs"
  fun op tveLookup_inc_some _ = ()
  val op tveLookup_inc_some = TDB.find "tveLookup_inc_some"
  fun op tveLookup_inc_none _ = ()
  val op tveLookup_inc_none = TDB.find "tveLookup_inc_none"
  fun op tveLookup_freevars_subst _ = ()
  val op tveLookup_freevars_subst = TDB.find "tveLookup_freevars_subst"
  fun op tveLookup_freevars _ = ()
  val op tveLookup_freevars = TDB.find "tveLookup_freevars"
  fun op tveLookup_db_merge_some _ = ()
  val op tveLookup_db_merge_some = TDB.find "tveLookup_db_merge_some"
  fun op tveLookup_db_merge_none _ = ()
  val op tveLookup_db_merge_none = TDB.find "tveLookup_db_merge_none"
  fun op tveLookup_bvl _ = ()
  val op tveLookup_bvl = TDB.find "tveLookup_bvl"
  fun op tveLookup_add_inc _ = ()
  val op tveLookup_add_inc = TDB.find "tveLookup_add_inc"
  fun op tenv_val_ok_nsEmpty _ = ()
  val op tenv_val_ok_nsEmpty = TDB.find "tenv_val_ok_nsEmpty"
  fun op tenv_val_ok_add_tenvE _ = ()
  val op tenv_val_ok_add_tenvE = TDB.find "tenv_val_ok_add_tenvE"
  fun op tenv_val_exp_ok_db_merge _ = ()
  val op tenv_val_exp_ok_db_merge = TDB.find "tenv_val_exp_ok_db_merge"
  fun op tenv_val_exp_ok_bvl_tvs _ = ()
  val op tenv_val_exp_ok_bvl_tvs = TDB.find "tenv_val_exp_ok_bvl_tvs"
  fun op tenv_val_exp_ok_bvl_funs _ = ()
  val op tenv_val_exp_ok_bvl_funs = TDB.find "tenv_val_exp_ok_bvl_funs"
  fun op tenv_val_exp_ok_bvl _ = ()
  val op tenv_val_exp_ok_bvl = TDB.find "tenv_val_exp_ok_bvl"
  fun op tenv_ok_empty _ = ()
  val op tenv_ok_empty = TDB.find "tenv_ok_empty"
  fun op tenv_ctor_ok_nsEmpty _ = ()
  val op tenv_ctor_ok_nsEmpty = TDB.find "tenv_ctor_ok_nsEmpty"
  fun op tenv_ctor_ok_merge _ = ()
  val op tenv_ctor_ok_merge = TDB.find "tenv_ctor_ok_merge"
  fun op tenv_ctor_ok_lookup _ = ()
  val op tenv_ctor_ok_lookup = TDB.find "tenv_ctor_ok_lookup"
  fun op tenv_abbrev_ok_nsEmpty _ = ()
  val op tenv_abbrev_ok_nsEmpty = TDB.find "tenv_abbrev_ok_nsEmpty"
  fun op tenv_abbrev_ok_merge _ = ()
  val op tenv_abbrev_ok_merge = TDB.find "tenv_abbrev_ok_merge"
  fun op tenv_abbrev_ok_lookup _ = ()
  val op tenv_abbrev_ok_lookup = TDB.find "tenv_abbrev_ok_lookup"
  fun op subst_inc_cancel _ = ()
  val op subst_inc_cancel = TDB.find "subst_inc_cancel"
  fun op num_tvs_deBruijn_subst_tenvE _ = ()
  val op num_tvs_deBruijn_subst_tenvE = TDB.find
    "num_tvs_deBruijn_subst_tenvE"
  fun op num_tvs_db_merge _ = ()
  val op num_tvs_db_merge = TDB.find "num_tvs_db_merge"
  fun op num_tvs_bind_var_list _ = ()
  val op num_tvs_bind_var_list = TDB.find "num_tvs_bind_var_list"
  fun op nsMap_build_ctor_tenv _ = ()
  val op nsMap_build_ctor_tenv = TDB.find "nsMap_build_ctor_tenv"
  fun op nsLookup_add_tenvE3 _ = ()
  val op nsLookup_add_tenvE3 = TDB.find "nsLookup_add_tenvE3"
  fun op nsLookup_add_tenvE2 _ = ()
  val op nsLookup_add_tenvE2 = TDB.find "nsLookup_add_tenvE2"
  fun op nsLookup_add_tenvE1 _ = ()
  val op nsLookup_add_tenvE1 = TDB.find "nsLookup_add_tenvE1"
  fun op nil_deBruijn_subst _ = ()
  val op nil_deBruijn_subst = TDB.find "nil_deBruijn_subst"
  fun op nil_deBruijn_inc _ = ()
  val op nil_deBruijn_inc = TDB.find "nil_deBruijn_inc"
  fun op mem_type_def_to_ctMap _ = ()
  val op mem_type_def_to_ctMap = TDB.find "mem_type_def_to_ctMap"
  fun op extend_dec_tenv_ok _ = ()
  val op extend_dec_tenv_ok = TDB.find "extend_dec_tenv_ok"
  fun op extend_dec_tenv_assoc _ = ()
  val op extend_dec_tenv_assoc = TDB.find "extend_dec_tenv_assoc"
  fun op deBruijn_subst_tenvE_def _ = ()
  val op deBruijn_subst_tenvE_def = TDB.find "deBruijn_subst_tenvE_def"
  fun op deBruijn_subst_id _ = ()
  val op deBruijn_subst_id = TDB.find "deBruijn_subst_id"
  fun op deBruijn_subst_freevars _ = ()
  val op deBruijn_subst_freevars = TDB.find "deBruijn_subst_freevars"
  fun op deBruijn_subst_check_freevars2 _ = ()
  val op deBruijn_subst_check_freevars2 = TDB.find
    "deBruijn_subst_check_freevars2"
  fun op deBruijn_subst_check_freevars _ = ()
  val op deBruijn_subst_check_freevars = TDB.find
    "deBruijn_subst_check_freevars"
  fun op deBruijn_subst_E_bvl _ = ()
  val op deBruijn_subst_E_bvl = TDB.find "deBruijn_subst_E_bvl"
  fun op deBruijn_subst2 _ = ()
  val op deBruijn_subst2 = TDB.find "deBruijn_subst2"
  fun op deBruijn_inc_deBruijn_inc _ = ()
  val op deBruijn_inc_deBruijn_inc = TDB.find "deBruijn_inc_deBruijn_inc"
  fun op deBruijn_inc0 _ = ()
  val op deBruijn_inc0 = TDB.find "deBruijn_inc0"
  fun op db_merge_def _ = () val op db_merge_def = TDB.find "db_merge_def"
  fun op db_merge_bvl _ = () val op db_merge_bvl = TDB.find "db_merge_bvl"
  fun op ctMap_ok_type_defs _ = ()
  val op ctMap_ok_type_defs = TDB.find "ctMap_ok_type_defs"
  fun op ctMap_ok_merge_imp _ = ()
  val op ctMap_ok_merge_imp = TDB.find "ctMap_ok_merge_imp"
  fun op ctMap_ok_lookup _ = ()
  val op ctMap_ok_lookup = TDB.find "ctMap_ok_lookup"
  fun op check_freevars_type_name_subst _ = ()
  val op check_freevars_type_name_subst = TDB.find
    "check_freevars_type_name_subst"
  fun op check_freevars_subst_single _ = ()
  val op check_freevars_subst_single = TDB.find
    "check_freevars_subst_single"
  fun op check_freevars_subst_list _ = ()
  val op check_freevars_subst_list = TDB.find "check_freevars_subst_list"
  fun op check_freevars_subst_inc _ = ()
  val op check_freevars_subst_inc = TDB.find "check_freevars_subst_inc"
  fun op check_freevars_subst _ = ()
  val op check_freevars_subst = TDB.find "check_freevars_subst"
  fun op check_freevars_add _ = ()
  val op check_freevars_add = TDB.find "check_freevars_add"
  fun op check_ctor_tenv_ok _ = ()
  val op check_ctor_tenv_ok = TDB.find "check_ctor_tenv_ok"
  fun op check_ctor_tenv_change_tenvT _ = ()
  val op check_ctor_tenv_change_tenvT = TDB.find
    "check_ctor_tenv_change_tenvT"
  fun op check_ctor_tenv_EVERY _ = ()
  val op check_ctor_tenv_EVERY = TDB.find "check_ctor_tenv_EVERY"
  fun op bind_var_list_append _ = ()
  val op bind_var_list_append = TDB.find "bind_var_list_append"
  fun op bind_tvar_rewrites _ = ()
  val op bind_tvar_rewrites = TDB.find "bind_tvar_rewrites"
  fun op bind_tvar0 _ = () val op bind_tvar0 = TDB.find "bind_tvar0"
  fun op add_tenvE_nsAppend _ = ()
  val op add_tenvE_nsAppend = TDB.find "add_tenvE_nsAppend"
  fun op add_tenvE_bvl _ = ()
  val op add_tenvE_bvl = TDB.find "add_tenvE_bvl"
  
val _ = if !Globals.print_thy_loads then TextIO.print "done\n" else ()
val _ = Theory.load_complete "typeSysProps"

end
