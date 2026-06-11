
<!-- intent-ledger:begin -->
## Intent Ledger (read this before changing behavior)

This project keeps its requirements as data, in the repo:

- `.intent/backlog.jsonl` — every intention ever expressed behind this project: dated,
  with the author's verbatim quote, a normalized statement, and a lifecycle status
  (open/implemented/fixed/superseded/rejected). Append-only; `status:"open"` entries
  are the live project backlog.
- `.intent/contracts.jsonl` — the rules currently in force. Entries with
  `status:"law"` are permanently binding on every change.

Workflow: BEFORE changing behavior or deciding where an artifact belongs, search both
files for the territory you touch (`intent query <terms>`, or grep) and check every
law (`intent laws`). AFTER work, append new intentions expressed by the user/owner
(verbatim quote = provenance) and update statuses of entries your change implements,
fixes, or supersedes — committed together with the code.
<!-- intent-ledger:end -->
