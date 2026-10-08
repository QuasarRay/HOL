structure mlsexpTheory :> mlsexpTheory =
struct
  
  val _ = if !Globals.print_thy_loads
    then TextIO.print "Loading mlsexpTheory ... "
    else ()
  
  open Type Term Thm
  local open mlstringTheory in end;
  
  structure TDB = struct
    val path =
      OS.Path.base (#(FILE)) ^ ".dat"
    val timestamp = HOLFileSys.modTime path
    val thydata = 
      TheoryReader.load_thydata {
        thyname = "mlsexp",
        hash = "2ba909152d36bff5a7a642a7c8b34ff692d939f7",
        path = path
      }
    fun find s = #1 (valOf (Symtab.lookup thydata s))
  end
  val () = Theory.record_metadata
    "mlsexp" {timestamp=TDB.timestamp, path=TDB.path}
  
  fun op v2pretty_ind _ = () val op v2pretty_ind = TDB.find "v2pretty_ind"
  fun op v2pretty_def _ = () val op v2pretty_def = TDB.find "v2pretty_def"
  fun op token_size_def _ = ()
  val op token_size_def = TDB.find "token_size_def"
  fun op token_nchotomy _ = ()
  val op token_nchotomy = TDB.find "token_nchotomy"
  fun op token_induction _ = ()
  val op token_induction = TDB.find "token_induction"
  fun op token_distinct _ = ()
  val op token_distinct = TDB.find "token_distinct"
  fun op token_case_eq _ = ()
  val op token_case_eq = TDB.find "token_case_eq"
  fun op token_case_def _ = ()
  val op token_case_def = TDB.find "token_case_def"
  fun op token_case_cong _ = ()
  val op token_case_cong = TDB.find "token_case_cong"
  fun op token_TY_DEF _ = () val op token_TY_DEF = TDB.find "token_TY_DEF"
  fun op token_Axiom _ = () val op token_Axiom = TDB.find "token_Axiom"
  fun op token_11 _ = () val op token_11 = TDB.find "token_11"
  fun op to_tokens_ind _ = ()
  val op to_tokens_ind = TDB.find "to_tokens_ind"
  fun op to_tokens_def_primitive _ = ()
  val op to_tokens_def_primitive = TDB.find "to_tokens_def_primitive"
  fun op to_tokens_def _ = ()
  val op to_tokens_def = TDB.find "to_tokens_def"
  fun op str_tree_to_strs_def _ = ()
  val op str_tree_to_strs_def = TDB.find "str_tree_to_strs_def"
  fun op str_tree_size_def _ = ()
  val op str_tree_size_def = TDB.find "str_tree_size_def"
  fun op str_tree_nchotomy _ = ()
  val op str_tree_nchotomy = TDB.find "str_tree_nchotomy"
  fun op str_tree_induction _ = ()
  val op str_tree_induction = TDB.find "str_tree_induction"
  fun op str_tree_distinct _ = ()
  val op str_tree_distinct = TDB.find "str_tree_distinct"
  fun op str_tree_case_eq _ = ()
  val op str_tree_case_eq = TDB.find "str_tree_case_eq"
  fun op str_tree_case_def _ = ()
  val op str_tree_case_def = TDB.find "str_tree_case_def"
  fun op str_tree_case_cong _ = ()
  val op str_tree_case_cong = TDB.find "str_tree_case_cong"
  fun op str_tree_Axiom _ = ()
  val op str_tree_Axiom = TDB.find "str_tree_Axiom"
  fun op str_tree_11 _ = () val op str_tree_11 = TDB.find "str_tree_11"
  fun op str_every_thm _ = ()
  val op str_every_thm = TDB.find "str_every_thm"
  fun op str_every_ind _ = ()
  val op str_every_ind = TDB.find "str_every_ind"
  fun op str_every_def _ = ()
  val op str_every_def = TDB.find "str_every_def"
  fun op smart_remove_def _ = ()
  val op smart_remove_def = TDB.find "smart_remove_def"
  fun op sexp_to_string_def _ = ()
  val op sexp_to_string_def = TDB.find "sexp_to_string_def"
  fun op sexp_to_pretty_string_def _ = ()
  val op sexp_to_pretty_string_def = TDB.find "sexp_to_pretty_string_def"
  fun op sexp_to_app_list_ind _ = ()
  val op sexp_to_app_list_ind = TDB.find "sexp_to_app_list_ind"
  fun op sexp_to_app_list_def _ = ()
  val op sexp_to_app_list_def = TDB.find "sexp_to_app_list_def"
  fun op sexp_size_def _ = ()
  val op sexp_size_def = TDB.find "sexp_size_def"
  fun op sexp_nchotomy _ = ()
  val op sexp_nchotomy = TDB.find "sexp_nchotomy"
  fun op sexp_induction _ = ()
  val op sexp_induction = TDB.find "sexp_induction"
  fun op sexp_distinct _ = ()
  val op sexp_distinct = TDB.find "sexp_distinct"
  fun op sexp_case_eq _ = () val op sexp_case_eq = TDB.find "sexp_case_eq"
  fun op sexp_case_def _ = ()
  val op sexp_case_def = TDB.find "sexp_case_def"
  fun op sexp_case_cong _ = ()
  val op sexp_case_cong = TDB.find "sexp_case_cong"
  fun op sexp_Axiom _ = () val op sexp_Axiom = TDB.find "sexp_Axiom"
  fun op sexp_11 _ = () val op sexp_11 = TDB.find "sexp_11"
  fun op sexp2tree_ind _ = ()
  val op sexp2tree_ind = TDB.find "sexp2tree_ind"
  fun op sexp2tree_def _ = ()
  val op sexp2tree_def = TDB.find "sexp2tree_def"
  fun op remove_all_def _ = ()
  val op remove_all_def = TDB.find "remove_all_def"
  fun op read_symbol_thm _ = ()
  val op read_symbol_thm = TDB.find "read_symbol_thm"
  fun op read_symbol_length _ = ()
  val op read_symbol_length = TDB.find "read_symbol_length"
  fun op read_symbol_def _ = ()
  val op read_symbol_def = TDB.find "read_symbol_def"
  fun op read_string_length _ = ()
  val op read_string_length = TDB.find "read_string_length"
  fun op read_string_def _ = ()
  val op read_string_def = TDB.find "read_string_def"
  fun op read_string_aux_thm _ = ()
  val op read_string_aux_thm = TDB.find "read_string_aux_thm"
  fun op read_string_aux_length _ = ()
  val op read_string_aux_length = TDB.find "read_string_aux_length"
  fun op read_string_aux_ind _ = ()
  val op read_string_aux_ind = TDB.find "read_string_aux_ind"
  fun op read_string_aux_def _ = ()
  val op read_string_aux_def = TDB.find "read_string_aux_def"
  fun op pretty_size_def _ = ()
  val op pretty_size_def = TDB.find "pretty_size_def"
  fun op pretty_nchotomy _ = ()
  val op pretty_nchotomy = TDB.find "pretty_nchotomy"
  fun op pretty_induction _ = ()
  val op pretty_induction = TDB.find "pretty_induction"
  fun op pretty_distinct _ = ()
  val op pretty_distinct = TDB.find "pretty_distinct"
  fun op pretty_case_eq _ = ()
  val op pretty_case_eq = TDB.find "pretty_case_eq"
  fun op pretty_case_def _ = ()
  val op pretty_case_def = TDB.find "pretty_case_def"
  fun op pretty_case_cong _ = ()
  val op pretty_case_cong = TDB.find "pretty_case_cong"
  fun op pretty_Axiom _ = () val op pretty_Axiom = TDB.find "pretty_Axiom"
  fun op pretty_11 _ = () val op pretty_11 = TDB.find "pretty_11"
  fun op parse_space _ = () val op parse_space = TDB.find "parse_space"
  fun op parse_sexp_to_string _ = ()
  val op parse_sexp_to_string = TDB.find "parse_sexp_to_string"
  fun op parse_sexp_to_pretty_string _ = ()
  val op parse_sexp_to_pretty_string = TDB.find
    "parse_sexp_to_pretty_string"
  fun op parse_def _ = () val op parse_def = TDB.find "parse_def"
  fun op parse_aux_to_tokens_thm _ = ()
  val op parse_aux_to_tokens_thm = TDB.find "parse_aux_to_tokens_thm"
  fun op parse_aux_ind _ = ()
  val op parse_aux_ind = TDB.find "parse_aux_ind"
  fun op parse_aux_def _ = ()
  val op parse_aux_def = TDB.find "parse_aux_def"
  fun op parse_IMP_LENGTH_LESS _ = ()
  val op parse_IMP_LENGTH_LESS = TDB.find "parse_IMP_LENGTH_LESS"
  fun op newlines_ind _ = () val op newlines_ind = TDB.find "newlines_ind"
  fun op newlines_def_primitive _ = ()
  val op newlines_def_primitive = TDB.find "newlines_def_primitive"
  fun op newlines_def _ = () val op newlines_def = TDB.find "newlines_def"
  fun op make_str_safe_def _ = ()
  val op make_str_safe_def = TDB.find "make_str_safe_def"
  fun op lex_def _ = () val op lex_def = TDB.find "lex_def"
  fun op lex_aux_spaces _ = ()
  val op lex_aux_spaces = TDB.find "lex_aux_spaces"
  fun op lex_aux_sexp_to_list _ = ()
  val op lex_aux_sexp_to_list = TDB.find "lex_aux_sexp_to_list"
  fun op lex_aux_sexp2tree _ = ()
  val op lex_aux_sexp2tree = TDB.find "lex_aux_sexp2tree"
  fun op lex_aux_make_str_safe _ = ()
  val op lex_aux_make_str_safe = TDB.find "lex_aux_make_str_safe"
  fun op lex_aux_length _ = ()
  val op lex_aux_length = TDB.find "lex_aux_length"
  fun op lex_aux_ind _ = () val op lex_aux_ind = TDB.find "lex_aux_ind"
  fun op lex_aux_def _ = () val op lex_aux_def = TDB.find "lex_aux_def"
  fun op lex_IMP_LENGTH_LESS _ = ()
  val op lex_IMP_LENGTH_LESS = TDB.find "lex_IMP_LENGTH_LESS"
  fun op is_safe_char_def _ = ()
  val op is_safe_char_def = TDB.find "is_safe_char_def"
  fun op get_size_ind _ = () val op get_size_ind = TDB.find "get_size_ind"
  fun op get_size_def_primitive _ = ()
  val op get_size_def_primitive = TDB.find "get_size_def_primitive"
  fun op get_size_def _ = () val op get_size_def = TDB.find "get_size_def"
  fun op get_next_size_ind _ = ()
  val op get_next_size_ind = TDB.find "get_next_size_ind"
  fun op get_next_size_def_primitive _ = ()
  val op get_next_size_def_primitive = TDB.find
    "get_next_size_def_primitive"
  fun op get_next_size_def _ = ()
  val op get_next_size_def = TDB.find "get_next_size_def"
  fun op fromString_sexp_to_string _ = ()
  val op fromString_sexp_to_string = TDB.find "fromString_sexp_to_string"
  fun op fromString_sexp_to_pretty_string _ = ()
  val op fromString_sexp_to_pretty_string = TDB.find
    "fromString_sexp_to_pretty_string"
  fun op fromString_def _ = ()
  val op fromString_def = TDB.find "fromString_def"
  fun op flatten_def _ = () val op flatten_def = TDB.find "flatten_def"
  fun op flatten_acc _ = () val op flatten_acc = TDB.find "flatten_acc"
  fun op datatype_token _ = ()
  val op datatype_token = TDB.find "datatype_token"
  fun op datatype_str_tree _ = ()
  val op datatype_str_tree = TDB.find "datatype_str_tree"
  fun op datatype_sexp _ = ()
  val op datatype_sexp = TDB.find "datatype_sexp"
  fun op datatype_pretty _ = ()
  val op datatype_pretty = TDB.find "datatype_pretty"
  fun op annotate_def _ = () val op annotate_def = TDB.find "annotate_def"
  
val _ = if !Globals.print_thy_loads then TextIO.print "done\n" else ()
val _ = Theory.load_complete "mlsexp"

end
