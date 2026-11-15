#!/usr/bin/env bash
# Checks this app against the pinned AIL (see .ail-version). Run on a dev machine, never in a container.
# Expects the ail repository at ../ail (or AIL_DIR) checked out at the pinned commit.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ail_dir="${AIL_DIR:-$here/../ail}"
want="$(head -n 1 "$here/.ail-version")"
have="$(git -C "$ail_dir" rev-parse HEAD)"
[ "$have" = "$want" ] || { echo "check: $ail_dir is at $have, pinned $want" >&2; exit 2; }
cd "$here"
# Drift check: the editor's KEYWORDS must equal the lexer's (lex.kw.1).
kw() { awk '/^KEYWORDS := \{/{f=1;next} f&&/^\}/{exit} f{gsub(/[ ",]/,"");print}' "$1" | sort; }
if ! diff <(kw "$ail_dir/compiler/syntax/lex.ail") <(kw edit.ail) >/dev/null; then
    echo "check: KEYWORDS in edit.ail differ from compiler/syntax/lex.ail:" >&2
    diff <(kw "$ail_dir/compiler/syntax/lex.ail") <(kw edit.ail) >&2 || true
    exit 1
fi
"$ail_dir/ail" check .
"$ail_dir/ail" fmt --check .
"$ail_dir/ail" test edit.ail
"$ail_dir/ail" test features/probes/probes.ail
# `ail test` takes a file (test.run.1); a module's tests run from its own file.
"$ail_dir/ail" test features/agent/agent.ail
