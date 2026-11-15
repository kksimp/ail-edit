# Update to ail v0.1.0 (plan, 2026-11-15)

Goal: ail-edit checks, formats and tests clean against the ail v0.1.0 release
(`64f5caef`, tagged 2026-11-14, released 2026-11-15), and knows the 0.1.0
language and command surface. One pull request from
`claude/project-thread-svoaic`. The orchestrator plans and integrates; lanes
execute.

## 1. What moved between the old pin (`2525ec40`, 2026-11-08) and v0.1.0

Read from source, not run. The Mac lane's first `tools/check.sh` is the
ground truth and this list is its head start.

- **std.app:** `event(kind str)` is now `event(kind EventKind)`; events carry
  an `EventKind` enum (`kind_of`, `kind_name`), errors an `AppKind` enum.
  New ops `Round`, `Poly`, `Line`, `Font`; new events `Down`, `Up`, `Move`,
  `Leave`, `Appearance`, `Paste`, `Picked`, `Measured`. `run_with` programs
  are now attachable (`ail attach`).
- **std.ui, std.ui.widgets, std.screen:** about 800 changed lines; every call
  the editor makes needs a look.
- **Language:** new reserved words `select` and `yield` (the lexer's list is
  now 43 words; the editor has 36 plus the five X0 added). Bit operators
  (`&`, `^`, `~`, `<<`, `>>` and their assignments) are now real syntax.
  Closures, generators, const generics, field defaults, nested patterns and
  number format specs (`{n:08}`, `{n:,}`, `{n:b}`) landed. `multi.ail` has a
  parameter named `select`, which no longer parses.
- **Commands:** new `ail context`, `review`, `try`, `merge`, `infer`,
  `help`, `doctor`, `card`, `check --fix`, `test --mutate`, `test --fuzz`,
  `perf --explain`, `attach mcp`, `new .`. `ail` is expected on `PATH`
  (ADR 1058), with `ail.cmd` on Windows. The 44 invocations the editor makes
  (`check`, `api`, `ask`, `task`, `diff`, `verify`, `test`, `run`, `replay`,
  `sanitize`, `leak`, `fix`, `edit`, `new`, `explain`, `fmt`) must match
  0.1.0's flags and JSON.

## 2. Scope

In: everything needed for `tools/check.sh` to pass at the 0.1.0 pin on macOS,
plus correctness against 0.1.0 (highlighting, auto-indent, command flags and
JSON shapes, the package manifest and agent kit). X0 (pull request #17) is
carried on this branch and superseded by it.

Out, for follow-up threads: new features on 0.1.0 commands (the X1 to X11
lanes) and the look slices E2 to E8, which need ail A1 to A4 after 0.1.0.
A gap in ail itself is reported to the AIL project and never patched here.

## 3. Lanes

Rules for all lanes: work only in kksimp/ail-edit; D2's rule from
`plan-2026-11.md` (features in `features/NAME/`); every changed behaviour has
a `@test`; ASCII only in rendered text; cite rule IDs in comments as the file
already does; no model names in any file; native-subset traps: `par`,
`error`, `select`, `yield` are reserved, no string `+`, no tuple
destructuring, int overflow traps, top-level consts are literals. Static
lanes run no build and no `ail` command; they read
ail at v0.1.0 and at the old pin and edit by reading.

| Lane | Where | Owns | Done when |
|---|---|---|---|
| L1 std port | cloud, static | `window/`, `themes/`, and every `std.*` call in `edit.ail` and `features/` against v0.1.0's `std/` | every call matches a v0.1.0 signature; a list of each change made and each doubt |
| L2 language surface | cloud, static | `KEYWORDS`, `BLOCK_WORDS`, `colors`, auto-indent, completion keywords, identifiers that are now reserved, the keyword drift check | the editor's list equals the lexer's 43; new operators and `select`/`yield` blocks colour and indent, with tests |
| L3 command surface | cloud, static | every `proc.run(ail_command(), ...)` and its JSON parsing, `ail_command()` itself, `testdata/` recordings, `AGENTS.md`, `.mcp.json`, `ail.pkg`, README | each invocation matches v0.1.0's CLI source and JSON; `ail_command()` finds `ail` on `PATH` and on Windows |
| L4 gate | Kaleb's Mac | the merged branch: ail at v0.1.0 beside it, `tools/check.sh`, fix what fails, the README sanity table in the window | `tools/check.sh` exits 0 with no warnings; the window opens, edits, checks and runs a file |

L1 to L3 run in parallel and merge into the branch; L4 runs on the merged
tip and is the gate. Linux and Windows runs follow L4 where reachable; a
failure there that is ail's goes to the AIL project.

## 4. Rejected

- Pinning ail `main` instead of the tag: main is 86 commits past the release
  and moves daily; the tag is what users have.
- One lane on the Mac doing everything: the static work needs no machine and
  can finish while the Mac run waits for approval.
- Doing X1 to X11 in the same change: the update would not be reviewable and
  X1 and X7 reshape `Shell`.
