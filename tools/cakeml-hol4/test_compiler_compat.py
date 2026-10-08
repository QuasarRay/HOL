"""Proof-only compatibility changes must reject altered input proofs."""
import re
import unittest
from pathlib import Path
from materialize_cakeml_context_compat import (compatible_mlsexp_induction,
    compatible_pattern_accumulator_proof, compatible_type_system_induction)

class CompilerCompatTests(unittest.TestCase):
    def test_proof_statements_and_definitions_are_preserved(self):
        # Read the retained immutable source, without an external checkout.
        source = (Path(__file__).parents[2] / '.o11y/compiler-induction-20261008'
                  / 'mlsexp-original.sml').read_text()
        adapted = compatible_mlsexp_induction(source)
        strip = lambda s: re.sub(r'\nProof\n.*?\nQED', '\nProof\nQED', s, flags=re.S)
        self.assertEqual(strip(source), strip(adapted))
        self.assertIn('ho_match_mp_tac sexp2tree_ind', adapted)

    def test_changed_proof_and_already_adapted_input_fail_closed(self):
        source = (Path(__file__).parents[2] / '.o11y/compiler-induction-20261008'
                  / 'mlsexp-original.sml').read_text()
        changed = source.replace('    \\\\ drule_all lex_aux_make_str_safe',
                                 '    \\\\ cheat', 1)
        for text in (changed, compatible_mlsexp_induction(source)):
            with self.subTest(text=text[:20]):
                with self.assertRaisesRegex(ValueError, 're-audit required'):
                    compatible_mlsexp_induction(text)
    def test_accumulator_repair_preserves_original_contract(self):
        source = (Path(__file__).parents[2] / '.o11y/cakeml-native-build-20261008'
                  / 'semanticPrimitivesProps-original.sml').read_text()
        adapted = compatible_pattern_accumulator_proof(source)
        strip = lambda s: re.sub(r'\nProof\n.*?\nQED', '\nProof\nQED', s, flags=re.S)
        self.assertEqual(strip(source), strip(adapted))
        for text in (source.replace('Induct\n  >- srw_tac', 'cheat\n  >- srw_tac', 1), adapted):
            with self.assertRaisesRegex(ValueError, 're-audit required'):
                compatible_pattern_accumulator_proof(text)

    def test_type_system_original_contracts_and_pin_guard(self):
        source = (Path(__file__).parents[2] / '.o11y/cakeml-native-build-20261008'
                  / 'typeSysProps-original.sml').read_text()
        adapted = compatible_type_system_induction(source)
        without_helpers = re.sub(
            r'val t_list_induction = prove \(.*?\n\n(?=Theorem deBruijn_subst2:)',
            '', adapted, flags=re.S)
        without_helpers = re.sub(
            r'val pat_list_induction = pat_bindings_ind.*?\n\n(?=Theorem type_p_tenvV_indep:)',
            '', without_helpers, flags=re.S)
        strip = lambda s: re.sub(r'\nProof\n.*?\nQED', '\nProof\nQED', s, flags=re.S)
        self.assertEqual(strip(source), strip(without_helpers))
        for text in (source + '\n', adapted):
            with self.assertRaisesRegex(ValueError, 're-audit required'):
                compatible_type_system_induction(text)


if __name__ == '__main__':
    unittest.main()
