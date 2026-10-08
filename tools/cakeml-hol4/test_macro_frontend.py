#!/usr/bin/env python3
from pathlib import Path
import tempfile
import unittest

from macro_frontend import translate


class MacroFrontendTests(unittest.TestCase):
    def render(self, text: str):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "input.sml"
            p.write_text(text)
            return translate(p)

    def test_portable_identifiers_are_not_false_positives(self):
        out, _ = self.render(
            "structure ThreadLocal = struct end\n"
            "structure UniversalType = struct end\n")
        self.assertIn("ThreadLocal", out)
        self.assertIn("UniversalType", out)

    def test_raw_polyml_runtime_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "polyml-runtime"):
            self.render("val x = PolyML.pointerEq (a,b)\n")

    def test_raw_thread_runtime_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "raw-thread-runtime"):
            self.render("val x = Thread.fork f []\n")

    def test_polyml_universal_runtime_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "polyml-universal-runtime"):
            self.render("val t = Universal.tag ()\n")

    def test_commandline_macros_are_audited(self):
        out, rules = self.render(
            "val a = CommandLine.name()\n"
            "val b = CommandLine.arguments ()\n")
        self.assertEqual(
            [x["rule"] for x in rules],
            ["basis-commandline-name", "basis-commandline-arguments"])
        self.assertIn("CommandLine.name ()", out)
        self.assertIn("CommandLine.arguments ()", out)


    def test_literals_and_nested_comments_keep_their_meaning(self):
        source = ('val text = "CommandLine.name() PolyML.pointerEq"\n'
                  '(* Thread.fork (* Universal.tag () *) *)\n'
                  'val char = #"\\\\"\n')
        out, rules = self.render(source)
        self.assertEqual(out, source)
        self.assertEqual(rules, [])

    def test_string_gap_keeps_literal_and_next_operation_separate(self):
        source = 'val s = "PolyML.\\\n  \\pointerEq"\nval x = CommandLine.name()\n'
        out, rules = self.render(source)
        self.assertEqual(out, source.replace('name()', 'name ()'))
        self.assertEqual(rules, [{"rule": "basis-commandline-name", "count": 1}])

    def test_unterminated_comment_and_string_fail_closed(self):
        for source in ['val s = "open', '(* open (* nested *)']:
            with self.subTest(source=source), self.assertRaisesRegex(ValueError, "unterminated"):
                self.render(source)


if __name__ == "__main__":
    unittest.main()
