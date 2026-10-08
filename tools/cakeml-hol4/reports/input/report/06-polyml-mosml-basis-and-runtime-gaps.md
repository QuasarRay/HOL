# 06 — Poly/ML, Moscow ML, Basis-library, and runtime gaps

This file intentionally separates **ecosystem compatibility** from **SML language semantics**.

HOL4 can be built with Poly/ML (primary/recommended) and historically with Moscow ML. The source tree contains portability layers, but significant code still relies on implementation/runtime services that the current CakeML basis does not expose with compatible SML APIs.

## Current CakeML basis inventory

The audited CakeML `basis/dependency-order` lists verified/program basis components including:

- Runtime
- Option
- List
- Vector
- String
- Int
- PrettyPrinter
- Rat
- Char
- Word64
- Word8
- Word8Array
- Array
- Map
- Set
- Hashtable
- CommandLine
- Double
- TextIO
- Sexp

CakeML's own basis README describes it as the beginnings of a standard basis similar to SML, not a complete drop-in Standard ML Basis implementation.

## 1. Poly/ML compiler and namespace reflection

HOL4's Poly/ML-specific tooling uses APIs such as:

```text
PolyML.Compiler
PolyML.NameSpace
```

for interactive compilation, namespaces, LSP tooling, and source inspection.

CakeML does not provide a drop-in Poly/ML compiler/namespace reflection API.

This is a major blocker for the current interactive HOL environment even if the theorem kernel itself is compiled.

## 2. Threads and synchronization

HOL4 contains Poly/ML-side uses of:

- threads;
- mutexes;
- condition variables;
- thread-local data;
- synchronized variables;
- futures/task queues in supporting infrastructure.

CakeML's ordinary verified source semantics is single-threaded and its current basis does not expose Poly/ML-compatible `Thread`, `Mutex`, or `ConditionVar` structures.

These facilities can be omitted from a sequential bootstrap only if all dependent code is replaced or serialized.

## 3. Universal / dynamically typed tags

HOL4's Poly/ML portability code uses `Universal.tag`-style facilities and related universal-type abstractions.

CakeML does not provide the same Poly/ML universal-tag runtime API.

A replacement requires either:

- an explicit sum/dynamic representation;
- generative tags encoded in another verified mechanism; or
- moving the affected facilities outside the trusted compiled core.

## 4. POSIX / OS / process facilities

HOL4 tools use substantial Standard Basis / implementation facilities such as:

```text
OS.Process
OS.FileSys
Posix
```

CakeML has its own FFI-backed filesystem/TextIO model but not a drop-in complete Standard ML OS/POSIX API.

A compatibility library is required for tools such as Holmake, process launching, solver invocation, temporary files, and host inspection.

## 5. Binary I/O

HOL4 contains `BinIO` uses.

The current CakeML basis inventory contains `TextIO` but no corresponding complete `BinIO` module.

This matters for binary artifacts, hashes, proof traces, caches, and other tooling.

## 6. Sockets

HOL4 has socket-related example/tooling code and LSP/server infrastructure that depends on networking/runtime APIs.

CakeML does not currently expose a Standard-ML-compatible `Socket` basis module in the audited basis inventory.

## 7. Time and timers

HOL4 uses:

```text
Time
Timer
```

for metering, profiling, timeouts, tactic limits, and build/test infrastructure.

These are not present as Standard-ML-compatible entries in the audited CakeML basis inventory.

## 8. SML `Real` / `StringCvt` APIs

HOL4 code uses `real`, `Real.*`, and `StringCvt.*`.

CakeML has an internal float64 primitive and a `Double` basis module, but that is not source/API compatible with the full SML `Real` + `StringCvt` ecosystem.

This is in addition to the missing SML real-literal source syntax discussed elsewhere.

## 9. Signals, interrupts, and timeout behavior

HOL4 tooling depends on implementation-level interrupt handling and process/signal behavior, especially for interactive proof search, timeouts, external solvers, and editor integrations.

CakeML exceptions exist, but Poly/ML's asynchronous interrupt/runtime behavior is not a drop-in CakeML facility.

## 10. Foreign-function interfaces

CakeML has a verified FFI model, so “FFI” itself is **not absent**.

The compatibility gap is that HOL4/PolyML code expecting Poly/ML or Moscow-ML-specific foreign interfaces and host object conventions cannot use those APIs unchanged. They need adapters to CakeML FFI calls and corresponding logical models.

## 11. TextIO is present but not automatically SML-Basis complete

CakeML has verified `TextIO`, which is a strong starting point. Do not infer from the shared structure name that every SML Basis operation, stream behavior, exception, buffering behavior, and host encoding convention used by HOL4 is already compatible.

A function-by-function API audit is still required.

## 12. External solver/process integration

HOL4 components invoke tools such as SMT/QBF solvers using host process and file APIs.

This is not a new SML syntax feature, but it is essential for the “entire HOL4 ecosystem” target. A CakeML port needs an OS/process compatibility layer or a redesigned RPC/FFI boundary.

## Practical distinction

A minimal verified HOL kernel port can avoid many items in this file.

A full HOL4 developer environment—including Holmake, LSP, TacticToe, SMT integration, parallelism, interactive evaluation, and build tooling—cannot.
