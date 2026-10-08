# 05 — HOL4 source-language and implementation-specific extensions

These forms are important for “compile HOL4 source directly” but should not all be implemented as CakeML core language features. Many are better handled by a verified/preverified front-end that expands HOL4 source into ordinary ML declarations.

## 1. HOL4 theory headers

HOL4 source has declarations such as:

```text
Theory Foo
Ancestors ...
Libs ...
```

and an implicit/explicit theory end handled by HOL tooling.

CakeML has no corresponding source-language declaration.

## 2. `Definition`

HOL4 theory files use block syntax conceptually shaped like:

```text
Definition name:
  <HOL quotation>
End
```

with attributes and optional termination material.

This is not Standard ML; it expands into calls into HOL's theory/definition infrastructure.

## 3. `Theorem`, `Triviality`, `Proof`, `QED`

HOL4 source supports theorem blocks, theorem attributes, proof bodies, and QED markers.

CakeML has no corresponding syntax.

## 4. `Inductive` and `CoInductive`

HOL4's parser has dedicated constructors for inductive/coinductive declaration blocks.

These require HOL elaboration, not merely ML parsing.

## 5. HOL `Datatype:` declaration blocks

This is distinct from ordinary SML `datatype`.

HOL4's source language can parse a quotation-based HOL datatype command block that is consumed by theorem-prover infrastructure.

## 6. Quotation syntax and antiquotation

HOL4 source relies heavily on quotations for terms/types/theorem statements and antiquotation splices.

The source AST explicitly distinguishes:

- full quotations;
- quotations;
- literal quotation pieces;
- antiquotations such as `^expr`;
- definition labels/attributes inside quoted material.

CakeML has no HOL quotation lexer/parser semantics.

For a direct bootstrap, this layer should generally expand to ordinary calls into a HOL parser API before CakeML compilation.

## 7. `Quote` declarations

HOL4 has source forms for named quote declarations in addition to inline term/type quotations.

CakeML has no equivalent.

## 8. `Type` and `Overload` HOL declarations

HOL4's source parser represents HOL-level type/overload declaration forms separately from ordinary SML `type`.

These manipulate HOL's logical grammar/overloading tables rather than the ML type system.

## 9. `Resume` and `Finalise`

Current HOL4 source tooling contains dedicated declaration nodes for resuming/finalising suspended theorem proofs.

CakeML has no corresponding source syntax.

## 10. HOL declaration attributes

HOL4 block forms can carry bracketed attributes/key-value material.

These attributes affect theorem registration, simplification, proof suspension, and related HOL behavior.

They require HOL-aware expansion.

## 11. `#(LINE)` / `#(FILE)` source pragmas

HOL4's source AST has nodes for line/file pragmas, including variants carrying explicit values.

CakeML has source locations internally but not these HOL source forms.

## 12. Moscow ML primitive declaration forms

HOL4 parser/tooling explicitly knows Moscow ML forms including:

```text
prim_val
prim_type
prim_eqtype
prim_EQtype
```

These are implementation-specific declarations used in compatibility/build/help infrastructure.

CakeML does not implement them as source declarations.

## 13. SuccessorML-style or-pattern node

As noted in the core file, HOL4 tooling's AST explicitly models SuccessorML or-patterns. Treat this as a dialect/tooling feature unless the chosen HOL4 compilation corpus demonstrates runtime use.

## Recommended architecture

Keep these HOL-specific constructs **above** the CakeML core language:

```text
HOL4 source
  -> HOL-aware parser / macro expander
  -> ordinary SML-compatible intermediate representation
  -> SML-to-CakeML compatibility lowering
  -> CakeML core
```

That avoids unnecessarily adding theorem-prover commands to CakeML's verified runtime language.
