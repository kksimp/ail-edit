# edit: an AIL code editor, written in AIL

`tools/edit/edit.ail` is a code editor for AIL programs, written in AIL
([ADR 0180](../../docs/decisions/0180-editor-written-in-ail.md)). Its core
is headless: an `Editor` value, `Command`s that change it, and a pure
`render` to a `Screen` of colored text runs
([ADR 0181](../../docs/decisions/0181-editor-screen-as-text-runs.md)).

```sh
./ail run tools/edit/edit.ail FILE                     # the editor, in a window
./ail run tools/edit/edit.ail --font 15 FILE           # ...with a smaller font (10 to 40)
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
| Shift with any move | Select; typing, Backspace or Delete replaces the selection |
| Ctrl-A, Ctrl-C, Ctrl-X, Ctrl-V | Select all, copy, cut, paste (in the window, also the system clipboard) |
| Ctrl-Home, Ctrl-End | Start, end of the file |
| Enter | New line, indented like this one, one level deeper after a block opener (`fn`, `if`, `match`, `x => `, `else err`, ...) |
| Tab | Spaces to the next multiple of 4 (AIL has no tabs, lex.block.1) |
| Backspace | In indentation, removes one level |
| Ctrl-Space | Complete the word: after `.`, fields, variants and methods; otherwise the file's declarations (with signatures), keywords and words in the buffer. Up/Down choose, Enter or Tab accepts, Escape closes |
| F12 | Go to the definition of the name under the cursor, locals included (`ail api --refs`, else the `--symbols` index) |
| F2 | Rename the local or declaration under the cursor everywhere in the file (`ail api --refs`) |
| Ctrl-I | Show the type of the expression under the cursor, and the signature and doc comment of what it names (`ail api --type`) |
| Ctrl-Shift-F | Format with `ail fmt` (also on save, when the program has no errors) |
| `(` `[` `{` `"` | Insert the closing pair; typing the closer steps over it; Backspace in an empty pair deletes both |
| Ctrl-/ | Comment or uncomment the line or selected lines |
| Ctrl-D | Duplicate the line or selected lines |
| Alt-Up, Alt-Down | Move the line or selected lines |
| Ctrl-G | Go to a line number |
| Ctrl-Z, Ctrl-Y | Undo, redo |
| Ctrl-F | Find as you type; Enter or F3 finds the next match, Escape stops |
| F3 | Find the next match |
| Ctrl-R | Replace: after Ctrl-F, type the replacement; Enter replaces this match and finds the next, Ctrl-Enter replaces all (one undo step) |
| Ctrl-S | Format, save, then check |
| Ctrl-K | Check: `ail check --json`; spans are marked, the pane lists them |
| Ctrl-. | Apply the first fix of the diagnostic under the cursor |
| F1 | Explain the diagnostic under the cursor (`ail explain RULE`) |
| Ctrl-O | Outline (`ail api --text`); Up/Down select, Enter jumps |
| Escape | Close the explanation or the outline; stop selecting or finding |
| Ctrl-Q | Quit; with unsaved changes in any tab, press it twice. Closing the window counts as Ctrl-Q |
| F5, F6 | Run the buffer (`ail run`), or its tests (`ail test`); the output fills the pane (its end, when long), Esc closes it, and a click on a `FILE:LINE:COL` or `at LINE:COL` jumps there, opening the file in a tab if needed |
| Ctrl-P | Open a file: type part of its path (letters in order), Up/Down, Enter |
| Ctrl-Tab, Ctrl-Shift-Tab | Next, previous tab; a click on a tab selects it |
| Ctrl-W | Close the tab; with unsaved changes, press it twice |
| F2 | Rename the name under the cursor: through `ail api` for declarations, else every whole word; the prompt shows the count, Enter applies (ADR 0244) |
| Ctrl-+ (or Ctrl-=), Ctrl--, Ctrl-0 | Larger, smaller, default font size (ADR 0243) |
| Mouse | Click places the caret, drag or Shift-click selects, the wheel scrolls, a click on a diagnostic jumps to it |

## macOS sanity check

About five minutes, from the repository root. On a Mac, Command works as
Ctrl (ADR 0179), and laptop keyboards may need fn for F1–F12. Don't save
(Ctrl-S): the steps edit `examples/hello.ail` and quit without saving.

```sh
./ail run tools/edit/edit.ail examples/hello.ail
```

| # | Do | Expect |
|---|---|---|
| 1 | Look | A window titled `examples/hello.ail - edit`, a tab bar, `fn` in blue, the string in orange, a caret on line 1 |
| 2 | Click after `print`; type `x` | The caret moves there; `x` appears and the title gains `*` |
| 3 | Ctrl-Z | `x` is gone |
| 4 | Shift-Right three times, then Ctrl-C; End, Ctrl-V | The three characters are highlighted, then pasted at the line end; Ctrl-Z undoes |
| 5 | Drag across a word; Shift-click further right | The selection follows the mouse, then extends to the click |
| 6 | Ctrl-K | Status line: `0 errors, 0 warnings` |
| 7 | F5 | The pane shows `Hello, world!`; Esc closes it |
| 8 | Click on `print`; F2 | A rename prompt on the tab bar names `print` with its count; Esc cancels |
| 9 | End, Enter, type `pr`, Ctrl-Space | A completion list with `print`; Esc closes, Ctrl-Z undoes |
| 10 | Ctrl-+ three times, Ctrl-- twice, Ctrl-0 | The text grows, shrinks, and returns to the default size; the window stays the same size |
| 11 | Ctrl-P, type `ui_hel`, Enter | `examples/ui_hello.ail` opens in a second tab; Ctrl-Tab switches back |
| 12 | Scroll with the trackpad in the second tab | The text scrolls about three lines per notch |
| 13 | Ctrl-Q (twice if it asks about unsaved tabs) | The editor quits without saving |

Also try `./ail run tools/edit/edit.ail --font 13 examples/hello.ail`: the
window opens with small text. Report the step number of anything that
differs.

The `ail` it runs is `$AIL`, else `./ail` when started from the repository
root, else `ail` on `PATH`. A check of unsaved changes writes the buffer to
`FILE.edit-check.ail` beside the file and removes it afterwards, so relative
imports resolve as they will on save.

## Status (2026-10-20)

- Works headless, tested (33 `@test`s, run by `./ail selftest`): editing,
  auto-indent, undo and redo, moves, highlighting, scrolling, selection and
  the clipboard, mouse and wheel, tabs and the file picker, run output,
  find and replace, go to line, bracket matching and pairing, comment
  toggle, duplicate and move lines, diagnostics with fixes, explain,
  outline, completion, go to definition and hover (from a recorded
  `ail api --symbols` output), quit confirmation.
- Window front end on `std.ui` (ADR 0177), tested on Linux under Xvfb:
  typing, Ctrl-K, Ctrl-. fixes, Ctrl-S, Ctrl-Space completion with
  signatures, member completion after `.`, F12, Ctrl-Shift-F, Ctrl-/,
  bracket pairing, drag selection, wheel, Ctrl-C to and from the system
  clipboard, Ctrl-P opening a second tab, F5 running it (ADR 0241), Ctrl-Q.
  Without a display, `edit.ail FILE` prints one screen instead.
- Completion, go to definition and hover use the last `ail api --symbols`
  index taken while the program had no errors (on opening, on Ctrl-K or
  save with no errors, and on demand), so names declared since then come
  from the buffer's words without signatures.
- Speed (Linux x86-64, interpreter): a 100x32 screen of a 1,000-line file
  renders in about 8 ms; an edit takes about 0.1 ms.
- Typing `.` after a name opens member completion; typing `(` after a
  known function shows its signature on the status line. `"""` strings are
  highlighted across lines.
- The word under the cursor is marked wherever else it appears on screen;
  each line with a diagnostic shows the first message after its text;
  typing `else` or `elif` lines it up with its `if`.
- Completion offers the locals in scope with their types (`ail api --locals`)
  and, after `x.`, only the members of `x`'s type (`ail api --type`). The
  position queries need a program that parses; otherwise the editor falls
  back to the outline index and the buffer's words.
