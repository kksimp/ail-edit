# AGENTS.md

AIL project: the code editor `ail-edit`. Source is `.ail`, the CLI is `ail` (on `PATH`; `ail doctor --path` prints the line to add).

- Load the core card once: `ail card`. More: `ail card TOPIC`, `ail ask std WORDS` (std and methods), `ail ask how WORDS`.
- Every change is one loop:
  1. `ail task start edit.ail GOAL`
  2. `ail context edit.ail FN --budget 800` before you edit FN
  3. edit with `ail edit` or your editor
  4. `ail check --fix edit.ail`
  5. `ail task verify`
  6. `ail task finish` (writes the certificate `.ail/cert.json`)
- Two candidate fixes: `ail try edit.ail` gives one verdict per set.
- For any diagnostic, run `ail explain RULE` with the rule ID from the message.
- Never grep to find code. Use `ail ask edit.ail what calls FN` (also: who uses T, who writes field F).
- `ail fmt FILE.ail` formats; `ail test FILE.ail` runs the `@test` functions (a feature module's too: `ail test features/agent/agent.ail`).
- Run `tools/check.sh` on a dev machine, never in a container. New features live in `features/NAME/NAME.ail`; new commands are palette-only (docs/plan-2026-11.md).
- `.mcp.json` registers `ail mcp` on stdio; the same tools are MCP calls.
