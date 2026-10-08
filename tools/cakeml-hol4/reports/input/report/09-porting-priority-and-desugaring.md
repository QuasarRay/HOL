# 09 — Porting priority: what can be lowered and what requires real semantics

## Tier 0 — Must be decided before attempting direct HOL4 compilation

These features shape the architecture of the port.

### A. SML module elaboration

Needed for:

- `.sig` files;
- functors;
- `include`;
- `where type`;
- sharing;
- `eqtype`;
- transparent/opaque ascription;
- structure aliases/applications.

A practical route is to build a **verified or proof-producing SML module elaborator** that eliminates modules into a simpler core before CakeML compilation. Extending CakeML's verified core module semantics is the other route.

Do not rely on current CakeML inline signature syntax; it is semantically discarded.

### B. Records

Options:

1. add records to CakeML;
2. elaborate closed records to generated datatypes/tuples;
3. elaborate flexible record patterns only after row information is known.

Because HOL4 uses records heavily, ad hoc manual rewriting is not realistic.

### C. Let-polymorphism and source type variables

HOL4/SML typing expects polymorphic local bindings and rich type annotations.

Either:

- extend CakeML inference; or
- run a complete SML elaborator first and monomorphize/specialize enough information before emitting CakeML.

### D. Equality types

If source compatibility is the goal, implement SML equality-kind constraints and reject function equality.

If only theorem-kernel functional correctness is the goal, an elaborator may erase equality kinds after statically checking them—but CakeML's runtime equality must still not introduce behavior observable by HOL4 code that differs from the checked SML program.

## Tier 1 — Large but largely elaboration-friendly syntax gaps

These can be lowered mechanically once an SML-aware front end has resolved names, types, arities, and fixities:

- multi-clause `fun`;
- multi-arm `fn`;
- `while`;
- `val rec`;
- grouped declarations;
- `withtype`;
- datatype/exception replication;
- SML constructor `of` syntax;
- partial constructor values via eta-expansion;
- multiple `open`s;
- real literal parsing to a chosen float representation;
- concrete record operations once labels/layout are resolved.

## Tier 2 — Observable semantic rewrites

### Evaluation order

Because CakeML evaluates right-to-left, a compatibility pass should A-normalize side-effectful SML expressions into explicit `let`s in the intended order.

Example conceptual transform:

```sml
f (effect1 ()) (effect2 ())
```

becomes an explicitly sequenced form before entering CakeML.

### `Match` vs `Bind`

Introduce distinct compatibility exception constructors and lower each source pattern context to raise the correct one.

### Constructor arity

Normalize SML constructors into explicit CakeML arities and eta-expand them when used as values.

## Tier 3 — HOL syntax layer

Do **not** add `Theorem`, `Definition`, quotations, `Theory`, `Ancestors`, and similar commands to CakeML's core language unless there is a compelling trust argument.

Instead:

```text
HOL4 source
 -> HOL-aware macro/parser layer
 -> ordinary elaborated SML IR
 -> compatibility lowering
 -> CakeML
```

This mirrors how HOL source forms already expand into ML calls.

## Tier 4 — Runtime and developer-environment compatibility

For a full HOL4 environment, separately implement/adapt:

- Poly/ML namespace/compiler services or replace interactive dynamic compilation;
- OS/process APIs;
- Time/Timer;
- BinIO;
- sockets;
- threading/synchronization;
- universal tags;
- interrupts/timeouts;
- external solver launching;
- SML Real/StringCvt API compatibility.

## Suggested implementation boundary

A robust architecture is:

```text
HOL4 concrete source
        |
        v
HOL4-aware lexer/parser
        |
        v
Full SML + HOL AST
        |
        v
SML static elaboration
  - fixity
  - modules/signatures/functors
  - equality kinds
  - records/rows
  - constructor arities
  - type variables
        |
        v
Semantics-preserving lowering
  - records
  - pattern clauses
  - while
  - Match/Bind
  - evaluation order
  - constructor eta-expansion
        |
        v
CakeML-supported source/core AST
        |
        v
Verified CakeML compiler
        |
        v
machine code
```

For a proof-producing bootstrap, the crucial proof boundary is the elaboration/lowering pass: it should produce a theorem or independently checkable certificate that the emitted CakeML program refines the source SML/HOL program semantics.
