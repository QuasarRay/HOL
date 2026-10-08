"""Proof-only compatibility changes must reject altered input proofs."""
import re
import unittest
from pathlib import Path
from materialize_cakeml_context_compat import compatible_mlsexp_induction

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

if __name__ == '__main__':
    unittest.main()
