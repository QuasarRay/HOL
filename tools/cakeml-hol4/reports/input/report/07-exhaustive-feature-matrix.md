# 07 — Exhaustive feature matrix

The table below is the compact master inventory.

| ID | HOL4 / SML feature | Representative syntax | CakeML status | Category | Typical treatment |
|---|---|---|---|---|---|
| C01 | Record types | `{a:int,b:string}` | Absent | Core | Add records or encode |
| C02 | Record expressions | `{a=1,b=2}` | Absent | Core | Add records or encode |
| C03 | Record patterns | `{a=x,b=y}` | Absent | Core | Add records or lower |
| C04 | Flexible record patterns | `{a=x,...}` | Absent | Core | Needs row/record analysis |
| C05 | Record shorthand rows | `{a,b}` / layered row forms | Absent | Core | Lower |
| C06 | Record selectors | `#a r` | Absent | Core | Lower/add records |
| C07 | `while` | `while p do e` | Absent | Core | Desugar with recursion |
| C08 | Multi-arm `fn` | `fn A=>x | B=>y` | Restricted | Core | Lower to `case` |
| C09 | Multi-clause same-name `fun` | `fun f A=... | f B=...` | Restricted | Core | Lower to `case` |
| C10 | SML constructor declaration syntax | `C of t` | Different | Core | Syntax/arity lowering |
| C11 | Constructor values / partial use | `map SOME xs` | Semantic restriction | Core | Eta-expand |
| C12 | Environment-based constructor naming | constructor status not fixed by capitalization | Restricted | Core | Rename/elaborate first |
| C13 | Symbolic / `op` constructor forms | `op ++` constructor | Restricted/absent | Core | Elaborate/rename |
| C14 | SML built-in constructor names | `true false ref NONE SOME` | Different spelling | Core | Mechanical rewrite |
| C15 | Real literals | `0.0` | Absent in source grammar | Core | Parse/lower to Double |
| C16 | Word literal patterns | `0w1` in a pattern | Restricted | Core | Lower/check use |
| C17 | Full layered pattern binder annotation | `x:t as p` | Restricted | Core | Normalize pattern |
| C18 | Full declarations inside expression `let` | `let datatype ... in ... end` | Restricted | Core/declarations | Hoist/lower carefully |
| C19 | SuccessorML or-pattern AST support | `p1 | p2` as one pattern | Absent | HOL dialect | Lower if used |
| D01 | `val rec` | `val rec f = fn ...` | Absent | Declaration | Rewrite to `fun`/rec AST |
| D02 | Simultaneous `val ... and ...` | `val a=e and b=f` | Absent | Declaration | Preserve simultaneous scope |
| D03 | Explicit declaration tyvar sequence | `val 'a ...`, `fun 'a ...` | Absent | Declaration/static | Elaborate/remove |
| D04 | `type ... and ...` | simultaneous type aliases | Restricted | Declaration | Split if scope-safe |
| D05 | `datatype ... withtype ...` | `withtype t = ...` | Absent | Declaration | Elaborate SCC |
| D06 | `abstype` | `abstype ... with ... end` | Absent | Declaration/module | Needs abstraction encoding |
| D07 | Datatype replication | `datatype t = datatype A.t` | Absent | Declaration | Alias constructors/types |
| D08 | Exception replication | `exception E = A.E` | Absent | Declaration | Preserve exception identity |
| D09 | Grouped exception declarations | `exception E ... and F ...` | Absent | Declaration | Preserve scope/identity |
| D10 | `infix` | `infix 5 ++` | Absent | Parsing semantics | SML fixity prepass |
| D11 | `infixr` | `infixr 6 **>` | Absent | Parsing semantics | SML fixity prepass |
| D12 | `nonfix` | `nonfix +` | Absent | Parsing semantics | SML fixity prepass |
| D13 | Multiple paths in one `open` | `open A B C` | Restricted | Declaration/module | Split in order |
| M01 | Named signatures | `signature S = sig ... end` | Absent | Module | Implement/elaborate |
| M02 | Signature conformance checking | `: SIG` / `:> SIG` | Missing | Module/static | Real module elaborator |
| M03 | Transparent ascription | `structure M : S = ...` | Absent | Module | Implement |
| M04 | Opaque ascription semantics | `structure M :> S = ...` | Parsed but inert in restricted form | Module/static | Implement sealing |
| M05 | Named signature expressions | `:> S` | Absent | Module | Implement |
| M06 | `where type` | `S where type t = T` | Absent | Module/static | Type refinement |
| M07 | `include` specs | `include S` | Absent | Module | Signature expansion |
| M08 | `eqtype` specs | `eqtype t` | Absent | Module/type system | Equality kinds |
| M09 | `sharing type` | `sharing type A.t = B.t` | Absent | Module/static | Unification constraint |
| M10 | Structure sharing | `sharing A = B` | Absent | Module/static | Module equality constraint |
| M11 | Nested structure specs | `structure X : S` inside `sig` | Absent | Module | Implement |
| M12 | Functor declarations | `functor F(X:S)=...` | Absent | Module | Implement/elaborate |
| M13 | Functor application | `structure M = F(X)` | Absent | Module | Elaborate |
| M14 | Functor inline-spec args | `functor F(type t ...)=...` | Absent | Module | Elaborate |
| M15 | Structure aliases | `structure A = B` | Absent | Module | Add structure expressions |
| M16 | General structure constraints | `(strexp : S)` / `(strexp :> S)` | Absent | Module | Implement |
| M17 | Structure `let` expressions | `let strdec in strexp end` | Absent | Module | Elaborate |
| M18 | Simultaneous structure bindings | `structure A=... and B=...` | Absent | Module | Preserve scope |
| M19 | Rich local/open/include/spec combinations in signatures | various | Absent | Module | Full SML module elaborator |
| S01 | Non-top-level let-polymorphism | polymorphic local `val` | Missing | Static semantics | Extend inference |
| S02 | Equality type variables | `''a` | Missing semantics | Static semantics | Add equality kinds |
| S03 | Equality type specs | `eqtype t` | Missing | Static semantics | Add equality kinds |
| S04 | SML function-equality rejection | `f = g` rejected | Different | Static/dynamic | Change equality typing |
| S05 | SML equality runtime semantics | no closure equality | Different | Dynamic | Change `do_eq` contract |
| S06 | SML observable evaluation order | side-effectful args left-to-right | Different | Dynamic | Change semantics or sequence |
| S07 | `Match` exception | failed `case`/`fn` => `Match` | Missing/distinctness lost | Dynamic | Add `Match` |
| S08 | `Bind`/`Match` distinction | val failure vs match failure | Different | Dynamic | Restore distinction |
| S09 | Type variables in expression/pattern annotations | `(x : 'a)` | Represented but inference rejects | Static | Extend annotation typing |
| S10 | Dynamic fixity environment | declarations affect parse | Missing | Front-end semantics | SML parser pass |
| S11 | Opaque type identity/sealing | `:>` fresh abstraction | Missing | Static/module | Implement |
| S12 | `abstype` representation hiding | constructor hidden outside body | Missing | Static/module | Implement/encode |
| H01 | Theory header language | `Theory`, `Ancestors`, `Libs` | Absent | HOL extension | HOL preprocessor |
| H02 | Definition blocks | `Definition ... End` | Absent | HOL extension | HOL preprocessor |
| H03 | Theorem blocks | `Theorem`, `Proof`, `QED` | Absent | HOL extension | HOL preprocessor |
| H04 | `Triviality` | theorem block variant | Absent | HOL extension | HOL preprocessor |
| H05 | `Inductive` / `CoInductive` | block syntax | Absent | HOL extension | HOL preprocessor |
| H06 | HOL `Datatype:` command | quotation-based datatype command | Absent | HOL extension | HOL preprocessor |
| H07 | HOL quotations | backtick/full-quote forms | Absent | HOL extension | HOL parser |
| H08 | Antiquotation | `^expr` in quotation | Absent | HOL extension | HOL parser |
| H09 | `Quote` declarations | named quote blocks | Absent | HOL extension | HOL preprocessor |
| H10 | HOL `Type` / `Overload` declarations | logical grammar/type commands | Absent | HOL extension | HOL preprocessor |
| H11 | `Resume` / `Finalise` | suspended proof workflow | Absent | HOL extension | HOL preprocessor |
| H12 | HOL attributes | `[attrs]` | Absent | HOL extension | HOL preprocessor |
| H13 | `#(LINE)` / `#(FILE)` pragmas | source mapping | Absent | HOL extension | Preprocess |
| X01 | Moscow ML `prim_val` | primitive binding declaration | Absent | Implementation extension | Replace with FFI/builtin |
| X02 | Moscow ML `prim_type` | primitive type declaration | Absent | Implementation extension | Replace |
| X03 | Moscow ML `prim_eqtype` | primitive equality type | Absent | Implementation extension | Replace |
| X04 | Moscow ML `prim_EQtype` | primitive ref/equality type form | Absent | Implementation extension | Replace |
| R01 | PolyML compiler reflection | `PolyML.Compiler` | Basis/runtime gap | Runtime | Re-architect/adapt |
| R02 | PolyML namespace reflection | `PolyML.NameSpace` | Basis/runtime gap | Runtime | Re-architect/adapt |
| R03 | Threads | `Thread.*` | Basis/runtime gap | Runtime | Serialize/add runtime |
| R04 | Mutexes | `Mutex.*` | Basis/runtime gap | Runtime | Add runtime |
| R05 | Condition variables | `ConditionVar.*` | Basis/runtime gap | Runtime | Add runtime |
| R06 | Universal tags | `Universal.tag` | Basis/runtime gap | Runtime | Dynamic value/tag encoding |
| R07 | POSIX/OS process APIs | `Posix.*`, `OS.Process.*` | Non-drop-in | Basis/runtime | Compatibility layer |
| R08 | Binary I/O | `BinIO.*` | Missing from audited basis inventory | Basis | Add library |
| R09 | Time/timers | `Time.*`, `Timer.*` | Missing SML-compatible basis | Basis | Add library |
| R10 | Sockets | `Socket.*` | Missing SML-compatible basis | Basis | Add library |
| R11 | SML `Real` API | `Real.*` | Not drop-in; CakeML has `Double` | Basis | Compatibility layer |
| R12 | `StringCvt` API | `StringCvt.*` | Not drop-in | Basis | Compatibility layer |
| R13 | Signals/async interrupts | implementation/runtime facilities | Non-drop-in | Runtime | Runtime redesign |
| R14 | Poly/MosML foreign APIs | implementation-specific FFI | Non-drop-in | Runtime | Adapt to CakeML FFI |
| R15 | Full SML TextIO behavior/API | `TextIO.*` | Partial compatibility only | Basis | Function-by-function audit |

## Notes on exclusions

The following are **not** gaps in current CakeML and are therefore intentionally not listed as missing:

- `case`
- `if`
- `raise`
- `handle`
- `andalso`
- `orelse`
- `before`
- tuples
- lists
- pattern aliases (`as`)
- ordinary type annotations with concrete types
- exceptions in general
- mutually recursive datatypes via `and`
- mutually recursive function names via `and`
- `local ... in ... end` declarations
- structures in the restricted `structure M = struct ... end` form
- qualified module paths
- `open` of one module path
- references/arrays in CakeML's own spelling/runtime model
