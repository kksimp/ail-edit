# edit: an AIL code editor, written in AIL

`tools/edit/edit.ail` is a code editor for AIL programs, written in AIL
([ADR 0180](../../docs/decisions/0180-editor-written-in-ail.md)). Its core
is headless: an `Editor` value, `Command`s that change it, and a pure
`render` to a `Screen` of colored text runs
([ADR 0181](../../docs/decisions/0181-editor-screen-as-text-runs.md)).

```sh
./ail run tools/edit/edit.ail FILE                     # the editor (see Status)
./ail run tools/edit/edit.ail --print FILE             # print one screen as text
./ail run tools/edit/edit.ail --print --check FILE     # ...after Ctrl-K
./ail run tools/edit/edit.ail --print --outline FILE   # ...with the outline
./ail run tools/edit/edit.ail --bench FILE             # time a render and an edit
./ail test tools/edit/edit.ail                         # the headless tests
```

## Keys

| Key | Does |
|---|---|
| Arrows, Home, End, PageUp, PageDown | Move. Home goes to the indentation, then column 1 |
| Ctrl-Left, Ctrl-Right | Move by word |
| Ctrl-Home, Ctrl-End | Start, end of the file |
| Enter | New line, indented like this one, one level deeper after a block opener (`fn`, `if`, `match`, `x => `, `else err`, ...) |
| Tab | Spaces to the next multiple of 4 (AIL has no tabs, lex.block.1) |
| Backspace | In indentation, removes one level |
| Ctrl-Z | Undo |
| Ctrl-S | Save, then check |
| Ctrl-K | Check: `ail check --json`; spans are marked, the pane lists them |
| Ctrl-. | Apply the first fix of the diagnostic under the cursor |
| F1 | Explain the diagnostic under the cursor (`ail explain RULE`) |
| Ctrl-O | Outline (`ail api --text`); Up/Down select, Enter jumps |
| Escape | Close the explanation or the outline |
| Ctrl-Q | Quit; with unsaved changes, press it twice. Closing the window counts as Ctrl-Q |

The `ail` it runs is `$AIL`, else `./ail` when started from the repository
root, else `ail` on `PATH`. A check of unsaved changes writes the buffer to
`FILE.edit-check.ail` beside the file and removes it afterwards, so relative
imports resolve as they will on save.

## Status (2026-10-20)

- Works headless, tested: editing, auto-indent, undo, moves, highlighting,
  scrolling, diagnostics with fixes, explain, outline parsing, quit
  confirmation (14 `@test`s, run by `./ail selftest`).
- Window front end: written against the agreed `std.ui` API (lane 11 of
  the [buildout plan](../../docs/design/ai-first-plan.md)) and kept in
  `window.ail.pending` until `std.ui` is in the bootstrap; until then
  `edit.ail FILE` prints one screen.
- Outline: needs `ail api --text` (lane 2); without it the status line
  says so.
- Speed (Linux x86-64, interpreter): a 100x32 screen of a 1,000-line file
  renders in about 6 ms; an edit takes about 0.1 ms.
- Not yet: selection, copy and paste, search, redo, multi-line `"""` string
  highlighting, mouse.
