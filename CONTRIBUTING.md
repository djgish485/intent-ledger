
<!-- intent-ledger:begin -->
## The Intent Ledger

This project records the *why* behind every behavior in `.intent/backlog.jsonl`
(append-only intent log) and `.intent/contracts.jsonl` (rules in force; `law`
entries bind every change). For any PR: search them for the territory you touch
before designing, then ship the intent behind your change as a backlog entry in
the same PR (your PR description works as the quote). Run
`git config core.hooksPath .githooks` once after cloning to get a warn-only
reminder when a behavior change is committed without an intent change.
<!-- intent-ledger:end -->
