# ail-edit: an AIL code editor, written in AIL

License: AGPL-3.0 (see `LICENSE`). Moved from kksimp/ail (`tools/edit`) with its history.

Needs the AIL toolchain: clone [kksimp/ail](https://github.com/kksimp/ail) next to this repo at the commit in `.ail-version`. Commands below use `../ail/ail`; `tools/check.sh` runs check, fmt and the tests against that pin. Builds and tests run on a dev machine, not in a container.

`edit.ail` is a code editor for AIL programs, written in AIL
([ADR 0180](https://github.com/kksimp/ail/blob/main/docs/decisions/0180-editor-written-in-ail.md)). Its core
is headless: an `Editor` value, `Command`s that change it, and a pure
`render` to a `Screen` of colored text runs
([ADR 0181](https://github.com/kksimp/ail/blob/main/docs/decisions/0181-editor-screen-as-text-runs.md)).

```sh
../ail/ail run edit.ail FILE                     # the editor, in a window
../ail/ail run edit.ail --font 15 FILE           # ...with a smaller font (10 to 40)
../ail/ail run edit.ail --theme light FILE       # ...in a theme (see Themes)
../ail/ail run edit.ail --print FILE             # print one screen as text
../ail/ail run edit.ail --print --check FILE     # ...after Ctrl-K
../ail/ail run edit.ail --print --outline FILE   # ...with the outline
../ail/ail run edit.ail --print --at=11:15 --key=ctrl+i FILE  # move, press keys, type (--type=TEXT)
../ail/ail run edit.ail --bench FILE             # time a render and an edit
../ail/ail run edit.ail --keys                   # the key table below
../ail/ail test edit.ail                         # the headless tests
```

The window remembers its open tabs and cursors per working directory in
`~/.ail-edit` and reopens them on the next start there
([ADR 0339](https://github.com/kksimp/ail/blob/main/docs/decisions/0339-editor-problems-and-sessions.md)).

## Keys

The table is the output of `--keys`, and a test checks that they match.
The same list is the command palette (Ctrl-Shift-P, ADR 0291).

| Key | Does |
|---|---|
| Arrows, Home, End, PageUp, PageDown | Move. Home goes to the indentation, then column 1 |
| Ctrl-Left, Ctrl-Right | Move by word |
| Shift with any move | Select; typing, Backspace or Delete replaces the selection |
| Ctrl-Home | Start of the file |
| Ctrl-End | End of the file |
| Ctrl-A | Select all |
| Ctrl-C | Copy (in the window, also to the system clipboard) |
| Ctrl-X | Cut (in the window, also to the system clipboard) |
| Ctrl-V | Paste (in the window, from the system clipboard) |
| Enter | New line, indented like this one, one level deeper after a block opener (`fn`, `if`, `match`, `x => `, `else err`, ...) |
| Tab | Spaces to the next multiple of 4 (AIL has no tabs, lex.block.1) |
| Backspace | In indentation, removes one level |
| `(` `[` `{` `"` | Insert the closing pair; typing the closer steps over it; Backspace in an empty pair deletes both |
| Ctrl-Space | Complete the word: after `.`, fields, variants and methods; otherwise locals, the file's declarations (with signatures), keywords and words in the buffer. Up/Down choose, Enter or Tab accepts, Escape closes |
| F12 | Go to the definition of the name under the cursor, locals included (`ail api --refs`, else the `--symbols` index) |
| Shift-F12 | Every place `ail api --refs` finds for the name under the cursor, its declaration included, in this file and others; Up/Down, Enter jumps, Esc closes (ADR 0489) |
| Ctrl-I | Info on the name under the cursor: its type (`ail api --type`), signature, contracts, effects, error set, doc comment and number of uses (`--refs`) (ADR 0312) |
| F2 | Rename the name under the cursor: through `ail api --refs` (declarations and locals), else every whole word; the prompt shows the count and how they were found, Enter applies, Ctrl-Z undoes (ADR 0244) |
| Alt-Shift-F | Format with `ail fmt` (also on save, when the program has no errors) |
| Ctrl-/ | Comment or uncomment the line or selected lines |
| Ctrl-D | Duplicate the line or selected lines |
| Alt-Up | Move the line or selected lines up |
| Alt-Down | Move the line or selected lines down |
| Ctrl-G | Go to a line number |
| Ctrl-Z | Undo |
| Ctrl-Y | Redo |
| Ctrl-F | Find as you type; Enter or F3 finds the next match, Escape stops |
| Alt-R | Toggles regex search for the find bar (std.regex syntax: `\d{4}`, `(a|b)+`); while finding, the query is re-searched (ADR 0490) |
| F3 | Find the next match |
| Ctrl-R | Replace: after Ctrl-F, type the replacement; Enter replaces this match and finds the next, Ctrl-Enter replaces all (one undo step) |
| Ctrl-S | Format, save, then check |
| Ctrl-K | Check: `ail check --json`; spans are marked, the pane lists them |
| Ctrl-. | Apply the first fix of the diagnostic under the cursor |
| F1 | Explain the diagnostic under the cursor (`ail explain RULE`) |
| Ctrl-O | Outline (`ail api --text`); Up/Down select, Enter jumps |
| Escape | Close the pane; stop selecting or finding |
| F5 | Run the buffer (`ail run`); the output fills the pane (its end, when long), Esc closes it, and a click on a `FILE:LINE:COL` or `at LINE:COL` jumps there, opening the file in a tab if needed |
| F6 | Run the buffer's tests (`ail test`), shown like F5 |
| Shift-F5 | Run with every trace event (`ail run --trace=all`): calls with arguments, returns, contracts, and a trap with each frame's locals; Up/Down, Enter jumps to an event (ADR 0312) |
| Ctrl-Shift-R | Probe the cursor line (`ail run --at FILE:LINE --show NAMES`): the selection, else the line's variables; each hit is a row, the last hit's values follow the line |
| Ctrl-Shift-W | Watch the selected or word-at-cursor variable (`ail run --watch NAME`): each write is a row, its value follows the line |
| Shift-F7 | Run (`ail run --values`); a trap lists its frames with their values, the innermost frame's follow the trap line |
| F9 | Jump to the next row of the probe, watch, trace, sanitize or leak list, wrapping |
| palette | Run with every trace event as a tree: Left folds a call, Right opens it, `f` cycles the filter (all, calls, effects, contracts, traps) |
| palette | `ail sanitize --json`: runs that differ under random schedules, with the replay command |
| palette | `ail sanitize --race`: unsynchronised unsafe accesses; Enter jumps to an access |
| palette | `ail leak --json`: live memory growth by kind and the roots that hold it |
| Ctrl-Shift-E | Each function's error set and every return, `?` and `else` that fails or handles, from `ail check --errors`; Up/Down, Enter jumps (ADR 0312) |
| Ctrl-Shift-M | Every diagnostic of the open tabs' programs (`ail check --json`, modules included, buffers as edited), errors first; Up/Down, Enter jumps, opening the file (ADR 0339); while shown it refreshes on save and 500 ms after typing stops (ADR 0353) |
| Ctrl-Shift-I | The program card (`ail api --card`) of the file's program, its modules included: entry point, tests, and every declaration with effects, contracts and error sets; Up/Down, Enter jumps to a declaration; refreshed on save (ADR 0331) |
| Ctrl-Shift-C | Run the tests with line coverage (`ail test --coverage=lines`) and mark the lines they never ran in the gutter, until the next edit (ADR 0313) |
| Ctrl-Shift-P | Command palette: every command here with its key; type part of its name, Up/Down, Enter runs it |
| Ctrl-B | Show the file tree (`.ail` files first) and focus it; again hides it. Up/Down select, Enter or Right opens a file or expands a directory, Left collapses, Esc returns to the editor; a click opens (ADR 0293) |
| Ctrl-Shift-U | Toggle running the tab's tests (`ail test --json`) after each save; the status line shows the pass and fail counts (ADR 0354) |
| Ctrl-Shift-H | Type what to find, Enter, the replacement, Enter: every changed line of the project's `.ail` files is previewed old -> new; Space skips or accepts a row, A accepts all; Ctrl-Enter applies the accepted rows to the buffers (files open as tabs, nothing saved, Ctrl-Z undoes per tab), Esc cancels (ADRs 0339, 0353) |
| Ctrl-Shift-F | Search every `.ail` file under the directory (open tabs as edited); the matches fill the pane, Up/Down select, Enter jumps, Esc closes (ADR 0292) |
| F4 | Jump to the next match of the last project search |
| Ctrl-P | Open a file: type part of its path (letters in order), Up/Down, Enter |
| Ctrl-Tab | Next tab; a click on a tab selects it |
| Ctrl-Shift-Tab | Previous tab |
| Ctrl-W | Close the tab; with unsaved changes, press it twice |
| Ctrl-+ (or Ctrl-=) | Larger font (ADR 0243) |
| Ctrl-- | Smaller font |
| Ctrl-0 | Default font size |
| Ctrl-Shift-T | Next theme: dark, light, solarized, high-contrast; remembered for the next start |
| Ctrl-Q | Quit; with unsaved changes in any tab, press it twice. Closing the window counts as Ctrl-Q |
| Mouse | Click places the caret, drag or Shift-click selects, the wheel scrolls, a click on a diagnostic or an output location jumps to it |

## macOS sanity check

About five minutes, from the repository root. On a Mac, Command works as
Ctrl (ADR 0179), and laptop keyboards may need fn for F1–F12. Don't save
(Ctrl-S): the steps edit `examples/hello.ail` and quit without saving.

```sh
../ail/ail run edit.ail examples/hello.ail
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

Also try `../ail/ail run edit.ail --font 13 examples/hello.ail`: the
window opens with small text. Report the step number of anything that
differs.

The `ail` it runs is `$AIL`, else `./ail` when started from the repository
root, else `ail` on `PATH`. A check of unsaved changes writes the buffer to
`FILE.edit-check.ail` beside the file and removes it afterwards, so relative
imports resolve as they will on save.

## Status (2026-10-20)

- Works headless, tested (33 `@test`s, run by `../ail/ail selftest`): editing,
  auto-indent, undo and redo, moves, highlighting, scrolling, selection and
  the clipboard, mouse and wheel, tabs and the file picker, run output,
  find and replace, go to line, bracket matching and pairing, comment
  toggle, duplicate and move lines, diagnostics with fixes, explain,
  outline, completion, go to definition and hover (from a recorded
  `ail api --symbols` output), quit confirmation.
- Window front end on `std.ui` (ADR 0177), tested on Linux under Xvfb:
  typing, Ctrl-K, Ctrl-. fixes, Ctrl-S, Ctrl-Space completion with
  signatures, member completion after `.`, F12, Alt-Shift-F, Ctrl-/,
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
