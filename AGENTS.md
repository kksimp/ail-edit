# AGENTS.md

AIL project: the code editor `ail-edit`. Source is `.ail`, the CLI is `ail` (on `PATH`; `ail doctor --path` prints the line to add). Use a tool when its line applies, not as a ritual.

- Read `ail card` once, all of it, before writing code. It names the spellings agents guess wrong (Habits from other languages) and the code that compiles but does not do what you meant ("Compiles, but is not what you meant"); no diagnostic reaches the second, so check it yourself.
- `ail check`, `build`, `run` and `test` rewrite some wrong spellings in your files and print `fixed ...`. Read the file again before you edit it.
- Then look up, never guess: `ail card TOPIC`, `ail ask std WORDS` (std and methods), `ail ask how WORDS`.
- A diagnostic `error[RULE]`: `ail check --fix FILE` applies the fixes it carries; `ail explain RULE` gives the meaning and a fix.
- Before editing a function you did not write: `ail context edit.ail FN --budget 800` (callees, callers, types, tests), not the whole file.
- Before changing a signature or a type: `ail ask edit.ail what calls FN` (also: who uses T, who writes field F). Never grep.
- Two candidate fixes: `ail try FILE` checks and tests each on a copy.
- A change across several functions: `ail task start edit.ail GOAL`, `ail task verify` (check, tests, what no test covers), `ail task finish` (writes `.ail/cert.json`).
- `ail task verify` runs only the check and the `@test` functions: run `tools/check.sh` as well, on a dev machine, never in a container.
- `ail fmt FILE` formats; `ail test FILE` runs the `@test` functions (a feature module's too: `ail test features/agent/agent.ail`).
- New features live in `features/NAME/NAME.ail`; new commands are palette-only (docs/plan-2026-11.md).
- `.mcp.json` registers `ail mcp`: the same tools as MCP calls (`ail_ask`, `ail_check`, `ail_context`, `task_start`, ...), kept warm between calls.
