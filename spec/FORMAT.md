# The Intent Ledger format

Two append-only JSONL files, committed in the repo under `.intent/`. They are the
source of truth; any index built from them is derived and disposable.

## `.intent/backlog.jsonl` — the decision log

One JSON object per line. One line per distinct intention. Never delete or rewrite
history — changed minds are recorded as new entries that supersede old ones. The
only in-place mutation allowed is updating `status`/`status_note` as reality changes.

| Field | Required | Meaning |
|---|---|---|
| `key` | yes | stable id: first 16 hex chars of sha1(`ts\|quote-or-intent`) |
| `ts` | yes | ISO timestamp of when the intention was expressed |
| `kind` | yes | `directive` \| `complaint` \| `preference` \| `idea` \| `pivot` \| `approval` |
| `area` | yes | project-defined topic bucket (keep the set small and stable) |
| `intent` | yes | normalized 1–2 sentence statement, present tense, testable where possible |
| `quote` | recommended | the owner's/author's verbatim words — the provenance |
| `status` | yes | `open` \| `implemented` \| `fixed` \| `superseded` \| `rejected` \| `unknown` |
| `status_note` | no | ≤20 words; cite the commit/PR that changed the status |
| `supersedes` | no | `ts` or `key` of the earlier entry this one replaces |
| `author` | no | who expressed the intention (multi-contributor projects) |
| `added_by` | no | who recorded the entry; agent-inferred entries MUST set this |

Status semantics:

- `open` — wanted, not built. The set of open entries is the live project backlog.
- `implemented` — built as asked, still current.
- `fixed` — was violated or regressed, later repaired.
- `superseded` — replaced by a later entry (which points back via `supersedes`).
- `rejected` — the owner or reality killed it.
- `unknown` — honestly unclear. Allowed, and better than guessing.

A complaint implies an intent: record the implied rule, keep the complaint as quote.

## `.intent/contracts.jsonl` — the rules in force

The distilled present tense: what currently binds changes. Derived from the backlog;
each contract should trace to backlog evidence.

| Field | Required | Meaning |
|---|---|---|
| `area` | yes | topic bucket, plus `meta` for cross-cutting rules |
| `statement` | yes | the rule, 1–2 sentences, checkable |
| `evidence` | recommended | quotes/dates/refs the rule derives from |
| `verify_hint` | recommended | how to check it against the live project |
| `confidence` | no | `established-by-owner` \| `inferred-by-agents` |
| `status` | yes | lifecycle status, or `law` |

`status: "law"` marks principles that are **permanently in force and never
complete** — they bind every change, including artifact-placement decisions.
Healthy projects have 3–8 laws, not 30. If a backlog entry describes a law,
do not leave it as an `implemented` event: promote it to a law contract
(see the principle-induction playbook).

## Merge and sync semantics

- Append-only lines merge trivially: conflicts are rare, and resolving by keeping
  both lines is always correct (keys dedupe).
- Sync transport is git: pull before working, commit `.intent/` changes together
  with the code they explain, push.
- Raw evidence (chat transcripts, full history) stays OUT of the repo. Entries
  point back to it via `ts`/`author`; the quote carries what matters.

## What never goes in the ledger

Personal taste/config of an application's *end user* (that is product user-data,
not project intent), secrets, and raw conversation dumps. The ledger is the
distilled why — small, readable, public-safe for whatever audience the repo has.
