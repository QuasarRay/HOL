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


if __name__ == "__main__":
    unittest.main()
