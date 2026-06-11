# The Maintenance Loop

**Purpose:** Keep the intent ledger alive and authoritative after the retroactive build. The retroactive build populates the ledger once; the maintenance loop keeps it synchronized with every decision, session, and contributor from that point forward.

**When to run:** This is a standing practice, not a one-time procedure. Apply the BEFORE/DURING/AFTER steps on every working session. Apply the PERIODIC steps whenever the project grows significantly — new areas, new contributors, or after a quarter of steady work.

---

## Prerequisites

- `.intent/backlog.jsonl` and `.intent/contracts.jsonl` exist and are committed.
- You understand the data shapes: `backlog.jsonl` entries carry `key`, `ts`, `kind`, `area`, `intent`, `quote`, `status`, `status_note`, `supersedes`, `author`, and `added_by`. Contract entries carry `area`, `statement`, `evidence`, `verify_hint`, `confidence`, and `status` (where `status: "law"` means permanently binding).
- You can query both files with `grep`, `jq`, or equivalent.

---

## BEFORE Any Behavior Change or Artifact-Placement Decision

Artifact-placement decisions — where to create a file, where to commit it, what directory structure to use — feel routine and are where misses concentrate. Treat them with the same rigor as behavior changes.

1. Identify the area or areas your change touches.
2. Query `backlog.jsonl` for every non-superseded entry in those areas. Follow every supersedes-chain to its latest link; the latest entry is the one in force.
3. Read every contract in `contracts.jsonl` with `status: "law"` regardless of area. Laws are cross-cutting by definition; restricting your check to the matching area will miss them.
4. Verify that your proposed change satisfies every law's `verify_hint` explicitly, not by assumption.
5. Hold all relevant open entries and active laws in context while you work.

---

## DURING Implementation

When a proposed change contradicts a non-superseded backlog entry or a law, stop.

1. **Prefer the recorded words over your plausible improvement.** The owner said it; the ledger holds it; implement it as stated. If you believe the recorded intent is genuinely wrong given new context, surface that to the owner — do not silently override it.
2. **When two recorded intents collide:** search the backlog and session history for the resolution the owner already made. If one exists, implement it. If not, build the smallest labeled boundary that keeps both intents intact, record it as a new `kind: directive` entry with a `status_note` explaining the collision, and flag it for the owner to review.
3. Do not invent resolutions on behalf of the owner. A collision without an owner-made resolution is an open question; record it as such.

---

## AFTER Any Session Where the Owner Expressed Intentions

### Session-end checklist

1. Collect every intention the owner expressed — directives, complaints, preferences, ideas, pivots, and approvals — verbatim where possible.
2. For each verbatim owner statement: append an entry to `backlog.jsonl` with `added_by` set to the owner's identifier. Verbatim entries are self-approving.
3. For each inferred intention (implicit in a question, a structural decision, or a pattern): append an entry with `added_by` set to your agent identifier (e.g., `agent:claude`). Flag inferred entries in `status_note` for owner spot-check; they are not self-approving.
4. For any entry you implemented during the session: update its `status` to `implemented` and add the commit reference to `status_note`.
5. For any entry a new decision renders obsolete: set the new entry's `supersedes` to the old entry's key or `ts`. Do not delete the old entry.
6. Commit `.intent/` in the same commit as the code it describes. If the code lands without the intent entries, provenance is broken permanently.

---

## PERIODIC: Keeping the Ledger Honest as the Project Grows

Repeat these passes quarterly for active projects, or after any significant expansion of scope or contributors.

**Silent-constraints audit:** Scan the project's current structure — file conventions, directory layout, README promises, templates, naming patterns — for constraints that are honored through structure rather than stated in words. Nobody has complained about them because nobody has violated them yet. That silence is a signal of importance, not absence. Elevate structural constraints to `contracts.jsonl` as laws before they are violated for the first time.

**Principle induction:** Do not rely on clustering. Cross-cutting principles appear once per topic area, below every frequency threshold. Run principle induction as a deliberate separate step: read every law-candidate in `backlog.jsonl`, ask whether it applies across multiple areas, and promote qualifying entries to `contracts.jsonl` with `status: "law"`.

**Agent-inferred entry spot-check:** Filter `backlog.jsonl` for entries where `added_by` contains `agent:`. Present a sample to the owner. Confirm, correct, or reject each one and update `status` accordingly.

---

## Multi-Contributor Flow

**PR authors ship intent entries in the same PR. The PR is the provenance.**

1. Every pull request that changes behavior or places artifacts must include updates to `.intent/backlog.jsonl` with the entries that motivated the change.
2. The author's verbatim statements (in issue comments, PR descriptions, or commit messages) become `quote` values; set `author` and `added_by` to the contributor's identifier.
3. Reviewers who catch a contradiction with an existing entry comment on the intent file, not only on the code. Resolve the contradiction before merge.
4. After merge, add the merge commit reference to the `status_note` of every entry whose implementation landed in that PR.

---

## Pitfalls

**Complaint-frequency bias.** Counting how often something was mentioned will systematically under-count honored background constraints. A principle that nobody has violated shows up rarely because it has never been challenged, not because it is unimportant. Rare-but-structural is the signature of a core law. Supplement frequency-based mining with a structural scan.

**Laws recorded as events.** A law has no completion state. If you record a cross-cutting principle as a `kind: directive` with `status: implemented`, it ages out of attention and eventually gets violated. Laws belong in `contracts.jsonl` with `status: "law"`, not in `backlog.jsonl` as completable events.

**Filtering tool output carelessly.** In agent transcript logs, `role: user` includes tool results alongside owner statements. Tool output is not owner intent. Filter aggressively before extracting quotes; otherwise entries will be diluted with search results, file contents, and command output.

**Skipping the supersedes-chain.** An entry that looks active may have been superseded two decisions ago. Always walk the chain to its end; earlier entries are historical record only.

**Committing code without the intent entries.** Once code lands without its corresponding ledger update, the provenance gap is permanent. Treat a code commit without a matching `.intent/` commit as a broken build.

**Resolving collisions silently.** When two recorded intents conflict, the temptation is to pick the more plausible resolution and move on. Resist this. Surface the collision; record the boundary; let the owner confirm.
