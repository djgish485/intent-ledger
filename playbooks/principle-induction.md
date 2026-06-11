# Principle induction: from instances to laws

## When to run this playbook

Run after you have at least 20 entries in `.intent/backlog.jsonl`. Re-run when a new topic area is added, after a significant feature push, or when the same correction keeps surfacing in reviews. Do not run on day one; you need real history.

## Purpose

Cross-cutting principles hide in the backlog as scattered, unrelated-looking instances. Because they appear once per topic area, they fall below every clustering threshold and get overlooked. This playbook finds them and promotes them to law contracts in `.intent/contracts.jsonl` before they get violated.

A **law** is a binding rule that never completes — a constraint every future change must honor. Laws go into `contracts.jsonl` with `status: "law"`. They do not belong in `backlog.jsonl` as events.

## Prerequisites

- `.intent/backlog.jsonl` exists with at least 20 entries spanning multiple topic areas.
- `.intent/contracts.jsonl` exists (may be empty).
- You can read both files in full without truncation.

## Procedure

### Step 1 — Read the full backlog across all areas

Load every line of `.intent/backlog.jsonl`. Do not filter by area first. Do not group by area first. Set aside what each entry is about; focus on its corrective energy — what direction the owner pushed back toward.

### Step 2 — Hunt for the same underlying rule wearing different topical clothes

Use these recognition heuristics:

**Same corrective energy in unrelated contexts.** The owner pushes back in the same direction — simpler, smaller, more explicit, closer to the user — when reviewing a data model, a UI flow, and an API response. The topic changes; the correction does not.

**Structural echoes.** A constraint expressed through structure rather than words: a file naming convention never broken, a template every area follows, a README promise consistently kept. Nobody complains about violations because there have been none — but the principle is active. Look for patterns in how the project is organized, not just what was said.

**Rarely stated but everywhere assumed.** Low frequency of statement is not low importance. The rule is so embedded that people build around it rather than debate it. This is the signature of a core law.

**Fragments plus structure.** Owners believe they repeated something many times when they said it once and embedded it in every template and default. A single strong statement plus consistent structural expression counts as multiple instances.

### Step 3 — For each candidate law, gather evidence and write the contract entry

A candidate needs at least three instances of evidence before promotion. Evidence can be backlog entries from different areas, structural artifacts (file layouts, templates, conventions), or a combination.

Write each law as a new entry in `.intent/contracts.jsonl`:

```json
{
  "area": "cross-cutting",
  "statement": "<present-tense, binding, testable by asking 'does this change honor the rule?'>",
  "evidence": ["<backlog key or artifact>", "<backlog key or artifact>", "<backlog key or artifact>"],
  "verify_hint": "<one question a reviewer can ask to check compliance>",
  "confidence": "high|medium",
  "status": "law"
}
```

Write the statement as a rule, not a goal. "All public interfaces include an example" is a law. "We want to improve documentation" is not. The statement must be short enough to quote in a code review comment.

### Step 4 — Cross-check existing entries for the laws-vs-events trap

Scan both files for entries marked `status: "implemented"` or `status: "fixed"` that actually describe a law. The trap: an agent records "normalize error response shape across all endpoints" as a directive, it gets applied, and the entry is marked implemented. The rule has now aged out of attention. Six months later a new endpoint ships in the wrong shape.

Ask for each implemented/fixed entry: "Is this a permanent constraint every future change must honor?" If yes, create the law contract and add a `status_note` on the original entry noting the promotion. Do not delete the original — it is part of the audit trail.

### Step 5 — Calibrate: a healthy project has 3–8 laws, not 30

After drafting candidates, read them together and prune:

- Does this rule apply to every area, or just one? If just one area, it is a local convention, not a law.
- Is this rule testable? A reviewer must be able to say "this change passes" or "this change fails."
- Would violating this rule break a promise to users or collaborators? Laws protect promises; preferences improve quality.

If you end up with more than 10 candidates, cut the weakest half.

## Worked-shape examples

**Example A — Same corrective energy across three areas.**
Backlog contains: a complaint about a settings screen with too many options (UI area); a directive to reduce required fields in onboarding (UX area); a complaint that an API response returns 40 fields when callers use 3 (API area). All three push toward minimum exposed surface. Candidate law: "Each interface exposes the minimum fields or options needed for its primary task; additional capability requires explicit opt-in." Verify hint: "Does this change add a new field or option without a use case that requires it?"

**Example B — Structural echo, never stated explicitly.**
Every document in the repo opens with a one-sentence purpose statement. No backlog entry ever demanded this; no entry complained about a violation because none occurred. The pattern lives entirely in structure. Candidate law: "Every document begins with a single sentence stating what it is and who it is for." Evidence: README, CONTRIBUTING, three template files. Verify hint: "Does this document have a one-sentence purpose statement as its first line?"

**Example C — The laws-vs-events trap.**
A backlog entry reads: `{kind: "directive", intent: "Normalize error response shape to {error, code, detail} across all endpoints", status: "implemented"}`. Cross-check reveals this is a permanent API contract. A new endpoint added last month returns `{message, status}` — the violation proving the law was never recorded. Promote to law contract; add `status_note: "promoted to law contract"` on the original entry.

## Pitfalls

**Clustering before reading.** Grouping by area before looking for patterns guarantees you miss cross-cutting principles. They appear once per cluster and vanish. Read flat first.

**Confusing silence with absence.** A principle that has never been violated generates no complaints. Absence of complaint may mean the principle is so well understood it has never been challenged. Structural echoes are your signal.

**Over-indexing on verbatim repetition.** "Keep it small," "reduce scope," "cut the field count in half" in four different entries may be one law stated four ways. Read for underlying pressure, not surface phrasing.

**Agent-inferred entries as sole evidence.** If `added_by` indicates agent inference rather than owner statement, treat it as a hypothesis. Do not use it as sole evidence for a law. Flag it and surface for owner spot-check before writing the contract.

**Writing laws as aspirations.** "We aim for consistency" is not a law. A law governs the next pull request today.
