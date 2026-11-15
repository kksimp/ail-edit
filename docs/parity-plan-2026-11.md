# ail-edit: editor parity audit and plan (2026-11-15)

Kaleb's ask: go over the editor's UI and make it fully on par for three
things: using AI tools, building AIL code, and creature comforts. This is the
audit, the gap list and the lane plan. The orchestrator plans and integrates;
lanes execute. It builds on `docs/plan-2026-11.md` (S1 to S10, landed), the
feature lanes X1 to X11 and the look slices E2 to E8, and adds the lanes
P1 to P13 for what none of those cover.

Audited: the tree at the 0.1.0 update branch (`5a752e2`), read from source,
not run. Compared with VS Code, Cursor, Zed, JetBrains and Sublime Text.
Facts about ail are from the v0.1.0 tag (`64f5caef`).

## 1. Where the editor stands

Strong, and ahead of the comparison editors for AIL: `ail check` with fix
previews and fix-all, explain, rename through `--refs`, kind colours, inlay
hints, code lens, probes, watch, trap values, trace tree, sanitize, leak,
coverage, the test tree with replay and shrink, contracts, semantic diff,
verify report, the task panel, impact marks, the ask bar, call hierarchy, the
token meter, Copy for agent, Apply agent edit, the agent file watch, and
`--print --json` for every panel.

Weak: almost every one of those is a blocking call behind a key chord, drawn
in a cell grid. The window (`Shell`) turns pixels back into cell events, so
panes, the palette, completion and hover are character boxes. The mouse does
four things. No agent runs inside the editor. Only `.ail` files are first
class.

## 2. Gap list

Priority: **P0** blocks daily use, **P1** expected of any modern editor,
**P2** polish. "ail" marks a gap that needs a change in kksimp/ail (section 5).

### A. AI tools

| # | Gap | Comparison | Pri | Lane |
|---|---|---|---|---|
| A1 | No agent runs in the editor: no chat, no streamed answer, no permission prompt, no tool-call view | Zed agent panel, Cursor, VS Code agent mode | P0 | P1 |
| A2 | No terminal, so a terminal agent (Claude Code, Codex, aider) needs a second window. `proc.start` gives line pipes, not a pty | every editor | P0 | P2, ail |
| A3 | An outside agent can't see or drive the editor: active file, selection, diagnostics, open a file, show a diff. The editor is not attachable and not an MCP server | Claude Code and Codex IDE integrations | P0 | X7 + P3 |
| A4 | Agent changes show as `+` marks and a list. No per-hunk keep or revert, no diff view, no checkpoint to return to, no multi-file change set | Cursor review, Zed review, Copilot edits | P0 | P4 |
| A5 | No inline edit (select, say what to change, preview the diff) | Cursor Cmd-K, Zed inline assist | P1 | P5 |
| A6 | Copy for agent assembles context locally; `ail context` exists at 0.1.0. No mention of a file, symbol, diagnostic or test failure when asking | all | P1 | X3, P5 |
| A7 | 0.1.0 commands the editor never calls: `context`, `review`, `try`, `merge`, `infer`, `prove`, `card`, `check --fix`, `test --mutate`, `test --fuzz`, `perf --explain`, `doctor`, `help` | only AIL has these | P1 | X3 to X6, X11 |
| A8 | Calls are cold: each one starts `ail` | LSP servers stay warm | P1 | X2 |
| A9 | No ghost-text completion from a model | Copilot, Cursor Tab | P2 | deferred (section 6) |
| A10 | No command to give an opened project the agent kit (`AGENTS.md`, `.mcp.json`) | `ail new` does it for new projects | P2 | P13 |

### B. Building AIL code

| # | Gap | Pri | Lane |
|---|---|---|---|
| B1 | Every `ail` and `git` call blocks the window (18 `proc.run` sites, no timeout, no cancel). A program that loops freezes the editor | P0 | X1 |
| B2 | Run output arrives when the program ends; no standard input, no stop, no rerun | P0 | X1, X8 |
| B3 | Checking happens on Ctrl-K, on save, or while the problems list is open. Not as you type by default | P0 | P6 (after X1) |
| B4 | Completion opens on Ctrl-Space and after `.` only; no popup while typing a name, no snippets (`fn`, `match`, `@test`), no `use` added on accept | P1 | P6 |
| B5 | No docs in the editor: `ail card TOPIC`, `ail ask std WORDS`, `ail help`; hover has no std documentation | P1 | X3, P6 |
| B6 | No run configuration: arguments, environment, `ail build` options, the package's entry, run last | P1 | X8 |
| B7 | Diagnostics and hover need a key; the pointer resting on a mark shows nothing | P1 | P7 |
| B8 | Tests run from keys and a tree; no gutter mark to click per `@test`, no rerun failed | P1 | P7, X11 |
| B9 | No refactors beyond rename (extract, inline, move), though `ail try` can prove a patch safe | P1 | X5 |
| B10 | The toolchain is assumed: no `ail doctor` at start, no version in the status bar, no warning when `.ail-version` and `ail --version` differ | P1 | P13 |
| B11 | A running `std.app` program can't be observed from the editor (`ail attach`) | P2 | X7 |
| B12 | Windows and Linux paths, keys and `ail.cmd` | P1 | X9 |

### C. Creature comforts

| # | Gap | Pri | Lane |
|---|---|---|---|
| C1 | Mouse: no double-click word or triple-click line (`clicks` is ignored), no scrollbar drag, no splitter drag, no Cmd-click to definition, no hover, the status bar is not clickable, the context menu is six fixed items, tabs have no menu | P0 | P7 |
| C2 | Files: the tree can't create, rename, delete or move; no open folder, Save As, Save All, revert; a file changed outside while dirty has no prompt; unsaved buffers are lost on a crash | P0 | P8 |
| C3 | Only AIL is highlighted. `README.md`, `ail.pkg`, JSON recordings, TOML, YAML and shell scripts get AIL colours | P0 | P8 |
| C4 | Find: no case or whole-word toggle, no "3 of 17", no find in selection, no history; project search reads `.ail` files only, with no include or exclude | P1 | P9 |
| C5 | Navigation: no back and forward, no matching-bracket jump, no reopen closed tab, tabs cycle in strip order not last-used, no bookmarks | P1 | P9 |
| C6 | Editing: no box selection, select line, expand selection, join, sort, case change, delete line, surround a selection, trim trailing spaces on save; no word wrap; no visible whitespace or ruler; CRLF files are not handled | P1 | P10 |
| C7 | Keys differ from every other editor: Ctrl-D duplicates (elsewhere: next occurrence), Ctrl-Shift-T is the theme (elsewhere: reopen tab), Ctrl-R replaces (elsewhere Ctrl-H). No keymap presets; rebinding is one palette prompt | P1 | P12 |
| C8 | Settings: five. No font family, autosave, format on save, check as you type, wrap, keymap, agent commands, per-project settings | P1 | P12 |
| C9 | Git: marks in the tree only. No branch in the status bar, no live change gutter, no hunk peek or revert, no stage and commit, no blame | P1 | P11 |
| C10 | Feedback: one message line. No notifications with actions, no progress for a running job | P1 | P13 (after X1) |
| C11 | Look: cell-grid panes and popups, line-step scrolling, no horizontal scroll, no icons, one cursor shape, appearance not followed (0.1.0 sends `Appearance`), no font family (0.1.0 has `Op.Font`) | P1 | E2 to E8, ail |
| C12 | No native menu bar; on macOS the menus are where people look for commands | P1 | ail |
| C13 | Text outside ASCII: glyph fallback, wide characters, input method composition are unverified | P1 | Mac lane checks, then ail if needed |
| C14 | Window: size and place are not remembered, one window only, the tab strip does not scroll | P2 | P13 |

## 3. Decisions

**D5. Agents connect through the Agent Client Protocol (ACP).** One client in
the editor (`features/acp/`), JSON-RPC over the agent's standard input and
output through `proc.start`, serves every agent that speaks it: Claude Code,
Codex and Gemini CLI today, through their own commands or adapters. The agent
command is a setting (`agent.NAME COMMAND`); nothing is bundled and no key is
stored. The editor answers the agent's file reads and writes from its
buffers, so an agent sees unsaved text and its edits land as reviewable hunks
(P4), not as writes behind the editor's back. Permission requests are a
prompt with the choices the agent offers. Rejected: a client per agent
(three wire formats, each moving); calling a model API from the editor
(needs a key and a paid service, AGENTS.md forbids it unless Kaleb opts in,
and it would repeat what the agents do); terminal only (needs a pty that ail
lacks, and gives no structured edits or permissions).

**D6. The terminal is its own lane and does not block D5.** A terminal
emulator (`features/vt/`) is pure and is written now. It shows command output
with colour from line pipes at once, and becomes a real terminal when ail
gains a pty (section 5). Rejected: waiting for the pty before writing the
emulator; skipping the terminal (terminal agents and `git` need it).

**D7. The editor shows itself to agents through `ail attach`, not a second
server.** 0.1.0 makes `run_with` programs attachable. `Shell` implements
`Observe` (active file, selection, visible range, diagnostics, open tabs,
task state) and tools (`open`, `goto`, `show_diff`, `selection`,
`diagnostics`, `run_command`). `ail attach mcp` turns that into MCP for any
agent, and `.mcp.json` lists it beside `ail mcp`. This answers the open
question in `plan-2026-11.md` section 3. Rejected: an MCP server written in
the editor (repeats std.attach and its token and input rules).

**D8. One diff model for agents and git.** `features/hunks/` holds a line
diff, hunks, keep or revert of one hunk, and a checkpoint (the buffers and
files before an agent turn). The review panel (P4), the git gutter and hunk
revert (P11), fix previews and Apply agent edit all draw from it. Rejected:
shelling to `git diff` for agent changes (needs a repository and a clean
index, and can't see unsaved buffers).

**D9. Jobs before comfort.** X1 (background jobs on `proc.start` and the
inbox) lands first after the 0.1.0 update. Live checking, streamed output,
the agent panel and notifications all sit on it. Rejected: per-feature
threads (eighteen call sites, eighteen patterns).

**D10. Pure modules first.** Every new feature is split into a pure module
(lines in, rows or lines out, `@test`s, no `edit.ail` change) and a wiring
step (the three touches of D2). The pure halves need no machine and don't
collide with the 0.1.0 update, so they start now. The wiring waits for the
update to merge and for X1.

**D11. A keymap setting with presets; the current keys stay as `classic`.**
`keymap vscode` (the proposed default) follows the keys people and agents
already know; `classic` is today's table. The README table is generated per
preset. This changes defaults, so Kaleb confirms before P12 flips it.

## 4. Lanes

Rules for every lane: work only in kksimp/ail-edit; D2 (a feature is
`features/NAME/NAME.ail`, with at most one `use`, one key row per key and one
dispatch line in `edit.ail`); every behaviour has a `@test`; ASCII only in
rendered text; no model names in any file; native-subset traps (`par`,
`error`, `select`, `yield` reserved; no string `+`; no tuple destructuring;
int overflow traps; top-level consts are literals; no lambdas). Builds and
tests run only on Kaleb's machines; a cloud lane reads ail at v0.1.0 and
writes by reading. A gap in ail goes to the AIL project and is never patched
here.

### Wave 0: pure modules (now, cloud, static; no `edit.ail` change)

| Lane | Module | Holds |
|---|---|---|
| W1 | `features/acp/` | ACP messages: initialize, new session, prompt, cancel; parsing of session updates (message and thought chunks, tool calls and their updates, plans, diffs); permission requests; file read and write requests; a `Session` that takes lines and gives rows and lines to send |
| W2 | `features/vt/` | terminal emulator: bytes to a cell grid (cursor moves, colours, erase, scroll regions, alternate screen, wrap, resize), scrollback |
| W3 | `features/syntax/` | highlighters for Markdown, JSON, TOML, YAML and shell; the language from a path; per-line colour kinds with carried state |
| W4 | `features/textops/` and `features/wrap/` | join, sort, case, trim, delete line, surround, box selection, indent and outdent; visual rows for word wrap and the mapping both ways |
| W5 | `features/find/` and `features/nav/` | match options (case, whole word, regex, in a range), counts and the current index, history; back and forward stack, last-used tab order, closed-tab stack, bookmarks, matching bracket |
| W6 | `features/hunks/` | line diff, hunks, keep or revert one hunk, checkpoints over several files, rows for inline and side-by-side views |

### Wave 1: the base (after the 0.1.0 update merges; Mac gate)

X1 jobs, X7 attach with P3's values and tools, X9 three OSes. They reshape
`Shell`, so they land one after another, then wave 0 is wired in.

### Wave 2: daily use

| Lane | Scope | Needs |
|---|---|---|
| P1 Agent panel | side panel over W1: pick an agent, prompt box with mentions, streamed answer, tool calls as rows, permission prompt, stop, new session; the agent's file writes go to buffers as hunks | X1, W1, W6 |
| P4 Review | change set since the checkpoint, inline and side-by-side diff, keep or revert per hunk and per file, restore the checkpoint; `ail review` and `ail verify --diff` on the set | W6 |
| P6 Live AIL | check as you type in a job, completion popup while typing, snippets, `use` on accept, std docs in hover, `ail card` and `ail ask std` lookup | X1, X3 |
| P7 Pointer | double and triple click, Cmd-click, scrollbar and splitter drag, hover cards, clickable status segments, context menus by place, tab menu, test marks in the gutter | wave 1 |
| P8 Files | tree create, rename, delete, move; open folder (native chooser), Save As, Save All, revert, outside-change prompt, unsaved buffers kept across a crash; W3 wired; CRLF kept | W3 |
| P9 Find and go | W5 wired: toggles, counts, find in selection, history, search scope; back, forward, bracket jump, reopen tab, last-used order, bookmarks | W5 |
| P10 Editing | W4 wired: the commands, word wrap, visible whitespace, ruler, trim on save | W4 |
| X3, X8 | context, review, card, ask std; run and build options, fix chooser | X1 |

### Wave 3: depth and look

P2 terminal panel (W2 wired; a real terminal when ail has a pty), P5 inline
edit and mentions, P11 git (branch, live gutter, hunk peek and revert, stage,
commit, blame, on W6), P12 keymap presets and the settings file, P13
notifications, progress, toolchain check at start, agent kit command, window
memory; X2, X4, X5, X6, X10, X11; the look slices E2 to E8 as ail A1 to A4
land.

Merge order inside a wave is free except where "Needs" says otherwise;
batches of up to 8.

## 5. Needs in kksimp/ail (for the AIL project)

1. **A pty for child processes** (`proc.start_pty(cmd, args, cols, rows)`
   with raw bytes in and out and a resize): the terminal (A2). P0.
2. **A native menu bar in std.app** (C12): menus with key equivalents, the
   host answers with an event as `popup` does. P1.
3. **A1 to A4 of the look plan** (`Op.Text`, `Op.Shadow` and `Grad`,
   `App.cursor`, std.app.kit): E2 to E8 and the cursor shapes of C11.
4. **File drop and a file-changed event in std.app or std.fs**: drop a file
   on the window; replace the 50 ms mtime poll of the agent watch. P2.
5. `ail api --tokens --count` (from the earlier plan) if not yet there.
6. Check on the Mac, then file if broken: non-ASCII glyph fallback, wide
   characters and input method composition in the std.app host (C13).

## 6. Deferred, with the reason

- Ghost-text completion from a model (A9): needs a low-latency model
  endpoint, so a key and a paid service; an opt-in setting once Kaleb wants it.
- Multiple windows, remote editing, extensions, a debugger with breakpoints:
  not needed for parity on the three goals; probes and attach cover debugging.
- Notebook, collaboration, spell check: out of scope.
