#!/bin/bash
# Smoke test: init -> append -> query -> status -> laws -> doctor in a throwaway repo.
set -e
INTENT="$(cd "$(dirname "$0")/.." && pwd)/bin/intent"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"
git init -q . && git config user.email t@t && git config user.name t
"$INTENT" init | grep -q "scaffolding ready"
test -f .intent/backlog.jsonl && test -f .githooks/pre-commit
grep -q "intent-ledger:begin" AGENTS.md && grep -q "intent-ledger:begin" CLAUDE.md
"$INTENT" append '{"intent":"Buttons should be blue everywhere.","quote":"make the buttons blue","kind":"directive","area":"ui"}' >/dev/null
KEY=$(python3 -c "import json; print(json.loads(open('.intent/backlog.jsonl').read().splitlines()[0])['key'])")
"$INTENT" query blue | grep -q "Buttons should be blue"
"$INTENT" open | grep -q "(1 open)"
"$INTENT" status "$KEY" implemented "landed" >/dev/null
"$INTENT" open | grep -q "(0 open)"
printf '{"area":"meta","statement":"Explain simply.","status":"law"}\n' >> .intent/contracts.jsonl
"$INTENT" laws | grep -q "Explain simply"
"$INTENT" doctor >/dev/null
echo "x" > app.py && git add app.py
git commit -q -m t 2>hook.out || true
grep -q "intent-ledger" hook.out
echo "ALL SMOKE TESTS PASSED"
