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
# Reads only the KEYWORDS set (lex.ail has more sets after it); POSIX awk, so it runs on macOS too.
kw() {
    awk '/^KEYWORDS := [{]/ { f = 1; next }
        f && /^[}]/ { exit }
        f { gsub(/[ \t\r",]/, ""); if ($0 != "" && $0 !~ /^#/) print }' "$1" | LC_ALL=C sort
}
if [ "$(kw "$ail_dir/compiler/syntax/lex.ail" | wc -l)" -lt 1 ]; then
    echo "check: no KEYWORDS set found in $ail_dir/compiler/syntax/lex.ail" >&2
    exit 1
fi
if ! diff <(kw "$ail_dir/compiler/syntax/lex.ail") <(kw edit.ail) >/dev/null; then
    echo "check: KEYWORDS in edit.ail differ from compiler/syntax/lex.ail:" >&2
    diff <(kw "$ail_dir/compiler/syntax/lex.ail") <(kw edit.ail) >&2 || true
    exit 1
fi
"$ail_dir/ail" check .
"$ail_dir/ail" fmt --check .
# `ail test` takes a file (test.run.1); a module's tests run from its own file.
# Every file with @test functions is listed (testdata/ holds fixtures, not tests).
tested=(
    edit.ail
    features/acp/acp.ail
    features/agent/agent.ail
    features/ask/ask.ail
    features/diff/diff.ail
    features/files/files.ail
    features/find/find.ail
    features/hunks/hunks.ail
    features/jobs/jobs.ail
    features/nav/nav.ail
    features/pointer/pointer.ail
    features/probes/probes.ail
    features/review/review.ail
    features/semantic/semantic.ail
    features/syntax/syntax.ail
    features/taskpanel/taskpanel.ail
    features/tests/tests.ail
    features/textops/textops.ail
    features/vt/vt.ail
    features/workspace/git.ail
    features/workspace/settings.ail
    features/workspace/welcome.ail
    features/wrap/wrap.ail
    window/window.ail
)
have_tests="$(git ls-files '*.ail' | grep -v '^testdata/' | xargs grep -l '@test' | sort)"
if [ "$have_tests" != "$(printf '%s\n' "${tested[@]}" | sort)" ]; then
    echo "check: the files with @test functions differ from the list in tools/check.sh:" >&2
    diff <(printf '%s\n' "${tested[@]}" | sort) <(echo "$have_tests") >&2 || true
    exit 1
fi
for f in "${tested[@]}"; do
    "$ail_dir/ail" test "$f"
done
