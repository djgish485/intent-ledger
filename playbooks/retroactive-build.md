# Playbook: The Retroactive Build

**Purpose:** Construct the intent ledger as if it had existed since day one. Use this when adopting intent-ledger mid-project or when onboarding an existing codebase. The goal is a complete `backlog.jsonl` and `contracts.jsonl` that accurately reflects every decision, constraint, and pivot the project has accumulated.

---

## When to Run This

- You are adopting intent-ledger on a project that is already underway or complete.
- Important requirements are forgotten or held only in someone's head.
- A new contributor needs a navigable record of why the project is the way it is.

## Prerequisites

- Read access to all evidence sources listed in Step 1.
- Ability to run `git log` and inspect the current working tree.
- The principle-induction playbook available to run after this one completes.

---

## Procedure

### Step 1: Inventory Every Evidence Source

Before touching any content, list every source. Do not begin extraction until the inventory is complete. The most common failure in a retroactive build is silently skipping an entire source class.

Check each of the following:

- **Agent transcript directories.** Every AI coding tool leaves transcripts. Look for Claude Code project directories, Codex session logs, Cursor exports, and any other assistant with conversation history. Check for multiple project directories if the project was worked on across machines or under different names.
- **In-app or product chat stores.** If the project has a chat UI, extract the owner's messages directly.
- **Issue trackers and PR threads.** GitHub issues, Linear tickets, Notion pages, Slack threads — anywhere the owner wrote about the project outside of code.
- **Git history across all branches.** Run `git log --all --oneline`. Branch names and merge messages often contain intent. Do not limit to the main branch.
- **Predecessor or sibling projects.** If this project replaced or extended something else, include those transcripts and issue histories. Constraints often originate in a predecessor and are inherited silently.
- **README, design docs, and templates.** These encode honored constraints in structure rather than words. A file-naming convention in a README is a law whether or not anyone ever argued about it.

For each source, record: type, location, date range, and approximate record count. Audit this table before continuing. If a source type shows zero records, verify it does not exist before moving on.

### Step 2: Slice the Timeline and Extract in Chunks

Divide the project timeline into chunks of roughly two weeks each. For each chunk, extract every distinct intention expressed in the **owner's own words** across all sources.

Apply these rules:

- **One intent per entry.** Never merge two intentions into one record even if they appear in the same message. "Make the header sticky and change the font" is two entries.
- **Quote verbatim.** The `quote` field must contain the owner's exact words, not a paraphrase. If you are inferring intent from code or commit messages rather than words, mark it in `added_by` (e.g., `"agent-inferred from commit abc1234"`). Inferred entries must be flagged for spot-checking in Step 5.
- **Skip machine noise aggressively.** In agent transcript logs, `role: user` includes tool outputs. Filter these before judging intent. If a message contains a JSON blob, stack trace, or raw file contents without surrounding human prose, skip it.
- **Be fine-grained.** A 3–4 month solo project at roughly 80,000 conversation turns yielded approximately 800 backlog entries. If your extraction is producing far fewer, you are merging entries or missing sources.

### Step 3: Synthesis Pass Per Area

Group the raw entries by `area`. For each area:

1. **Assign lifecycle statuses.** Check the current codebase — read relevant files, run the app, inspect commits. Set `status` to: `implemented`, `open`, `superseded`, `rejected`, `fixed`, or `unknown`. Use `unknown` when you cannot determine status with confidence. **Unknown is allowed and is better than guessing.**

2. **Build supersedes-chains.** When a pivot or later directive reverses an earlier one, set the later entry's `supersedes` field to the key or timestamp of the earlier entry, and set the earlier entry's `status` to `superseded`.

3. **Do not promote structural constraints to events.** If a constraint lives in file layout, naming conventions, or templates — and has never been explicitly completed — do not mark it `implemented`. That causes it to age out of attention. Flag it for the principle-induction step instead.

### Step 4: Run the Principle-Induction Playbook

After per-area synthesis is complete, run the principle-induction playbook on the full backlog. Do not fold this into Step 3.

Cross-cutting principles do not cluster. A constraint that applies across every area appears once per area in the data — below every frequency threshold. Standard distillation per topic misses it. Principle induction is a deliberate separate pass looking for patterns that recur across areas rather than within them.

Pay close attention to constraints you found encoded in README files, templates, or directory structure in Step 1. Rare in explicit words precisely because they were never violated, but structural throughout — that is the signature of a core law.

### Step 5: Load, Validate, and Commit

Before committing `.intent/`:

1. **Parse every line.** Confirm every line in both files is valid JSON. A single malformed line breaks sequential readers.
2. **Check key uniqueness.** Every `key` in `backlog.jsonl` must be unique. Duplicates indicate a merge error.
3. **Spot-check 20 quotes.** Pick 20 entries at random, locate each `quote` in the raw source, and confirm the text matches. If more than one or two do not match, your extraction pass has a paraphrase problem — re-run it with stricter verbatim instructions.
4. **Review all agent-inferred entries.** Filter for `added_by` values containing `agent-inferred`. Confirm or reject each before committing.
5. **Commit `.intent/` atomically.** Include in the commit message: the date range covered and the source types processed.

---

## Output Format Requirements

- `backlog.jsonl`: one JSON object per line, newline-delimited, UTF-8.
- `contracts.jsonl`: same format. Every entry where `status` is `"law"` must have a non-empty `verify_hint` — a concrete check a future agent can run to detect a violation.
- No entry should have a null `quote` unless `added_by` marks it as agent-inferred.

---

## Quality Bar

The retroactive build is complete when: every source from Step 1 has been processed; no area of the current codebase lacks at least one backlog entry; all agent-inferred entries have been reviewed; and the principle-induction playbook has produced at least one law, or you have documented why none were found.

---

## Large evidence corpora: build a reading room, not a feature

If the project's raw history is large (tens of thousands of transcript turns), ad-hoc
grepping gets slow and unreliable. Build yourself a disposable local index — a per-machine
SQLite with one table of normalized turns (source, role, timestamp, content) and an FTS
index over it; add embeddings only if lexical search demonstrably misses paraphrases.
Three rules: it lives outside the repo (raw conversations never enter git), it is derived
(rebuildable from the sources at any time), and it is yours, not the tool's — intent-ledger
deliberately stays small, managing only the distilled layers. Keep a small bookkeeping
table of which sources/files you have ingested; coverage gaps in the evidence are the most
common cause of a wrong retroactive build, and you cannot audit coverage you did not record.
The index keeps earning its disk space after the build: it is how you fact-check the ledger
itself when someone asks "did I really say that?"

## Pitfalls

**Silently missing a whole source.** The most common failure. Produce the inventory table before extracting anything and treat a missing source as a blocker, not a skip.

**Complaint-frequency bias.** Mining transcripts for complaints under-weights honored background constraints — principles expressed through structure rather than words, precisely because nobody violated them. Actively look for what is built into the structure, not only what was argued about.

**Treating laws as events.** A cross-cutting principle is not an event that completes. Recording it as `implemented` causes it to age out of attention and get violated later. Cross-cutting principles belong in `contracts.jsonl` with `status: law`.

**Merging entries to reduce volume.** High entry counts are correct. 800 entries for four months of solo work is expected. Merging loses provenance and breaks supersedes-chains.

**Paraphrasing quotes.** The quote field is provenance. Only the owner's actual words are self-approving. If you cannot find the verbatim text, mark the entry as agent-inferred.

**Guessing status.** Use `unknown` freely. A record of honest unknowns is more useful than confident wrong answers.

**Owner memory compression.** Owners believe they stated a constraint many times when they said it in fragments and built it into structure. Low explicit frequency combined with structural presence is the signature of a core law, not noise to discard.
