# Silent Constraints Audit

**Purpose:** Mine what the owner *built*, not what they *said* — converting honored-but-unwritten invariants into explicit contracts before an agent violates one.

## When to Run

- After any large agent-built feature lands in the repo
- Before onboarding a new contributor (human or automated)
- Whenever `.intent/contracts.jsonl` has not been touched in two weeks while commits have continued

Do not skip this because "the owner would have noticed." Agents write many files quickly; owners review summaries. Silent violations survive review.

## Why This Exists

Transcript mining finds complaints. It misses *honored* constraints — conventions nobody broke yet, encoded in structure rather than words. Absence of complaints is not evidence of absence of requirements. A file convention maintained for years without ever being written down is more binding than a feature request mentioned once.

## Prerequisites

- Read access to the full repository
- `.intent/backlog.jsonl` and `.intent/contracts.jsonl` exist and are writable
- You have the diff of the most recent large change (`git diff main...HEAD` or equivalent)

## Procedure

Work through each category in order. Record findings immediately — do not batch at the end.

### 1. README and Documentation Promises

Read every file in the repo root and `docs/` that addresses users directly.

For each promise: what behavior does the text guarantee? Could agent-written code silently break it without a test failing? Is there an automated enforcer?

Write a proposed contract for every unenforced promise. Flag **status: law** if the promise is permanent and load-bearing (a public API guarantee, a security property, a data-format stability promise). Flag **status: active** for in-force but scoped promises.

### 2. Template vs. Instance File Patterns

Identify every file that looks like a template: `*.example`, `*.template`, `*.sample`, `*.defaults`, or files with placeholder values (`YOUR_NAME`, `example.com`, `TODO`). Also examine `.gitignore`.

For each template, find its corresponding instance:
- If the instance is gitignore'd: is the template sufficient for a new contributor to generate a valid instance? If not, record a backlog entry.
- **Landmine check:** For every runtime-read config file (anything `require()`'d, `open()`'d, or `os.getenv()`'d in committed code), confirm a template exists. A runtime-read file with no template is a landmine — an agent may commit local values or commit nothing and leave the app broken.

Record each missing template as a backlog entry with `kind: complaint` and `status: open`.

### 3. Hardcoded Owner-Specific Values

Search committed files for: personal names, usernames, email addresses, hostnames, home-directory paths, timezones, locale strings, and account or organization IDs.

For each occurrence, classify:
- **Legitimate constant:** a domain the project owns, a standard locale the project targets. Write it into contracts if not already obvious.
- **Leakage:** a personal machine's hostname, a developer's home path, a personal email in a field that should be parameterized. Write a backlog entry with `kind: complaint` and note the violation an agent could propagate by copying the file.

Do not assume leakage is harmless. Agents copy patterns. One hardcoded personal hostname becomes many.

### 4. Gitignore Structures

Read `.gitignore` and subdirectory gitignore files. Map the boundary: what ships vs. what stays local.

- For each ignored path: does committed code assume that local resource exists at runtime? If yes, confirm a setup step or template covers it.
- For each committed path: does it contain values that should differ per environment? If yes, confirm it is parameterized — or record a contract that it must never become environment-specific.
- Note any pattern implying a build artifact ships in the repo. Record whether that is intentional policy or drift.

### 5. Permission and Configuration Conventions

Examine committed config files: editor configs, CI pipeline definitions, container configs, service manifests.

For each convention: is it documented, or only expressed in the config? Would an agent adding a new file type, service, or language automatically follow it?

Record unenforced, undocumented conventions as proposed contracts. Mark **confidence: medium** unless structural (e.g., a Makefile target used in CI — omitting it breaks the build automatically).

## Output Format

### Proposed Contracts

One entry per invariant in `.intent/contracts.jsonl`:

```json
{
  "area": "<file path or component>",
  "statement": "<one sentence, present tense, affirmative>",
  "evidence": "<file:line or structural pattern>",
  "verify_hint": "<how to check this in 30 seconds>",
  "confidence": "high|medium|low",
  "status": "law|active"
}
```

Use **law** only for permanent, cross-cutting constraints. Use **active** for scoped or potentially superseded rules.

### Backlog Entries for Violations Found

One entry per actual violation in `.intent/backlog.jsonl`:

```json
{
  "key": "<short-kebab-slug>",
  "ts": "<ISO-8601 timestamp>",
  "kind": "complaint",
  "area": "<file path or component>",
  "intent": "<one sentence describing what should be true>",
  "quote": "<verbatim file content, or 'structural: <description>' if no single line>",
  "status": "open",
  "status_note": "Found during silent-constraints audit.",
  "author": "audit",
  "added_by": "agent:silent-constraints-audit"
}
```

## Quality Bar

Before closing, verify:

- [ ] Every user-facing README promise has a corresponding contract or an explanation of why it is already enforced automatically
- [ ] Every runtime-read config file has a template, or a backlog entry exists
- [ ] Every hardcoded owner-specific value is classified as legitimate or leakage — none left ambiguous
- [ ] No proposed contract is phrased as an event. Contracts are present-tense invariants.
- [ ] At least one dedicated pass looked for cross-cutting principles — rules that apply across all areas. These appear once per topic, below any clustering threshold. They will not be found unless you look for them specifically.

## Pitfalls

**Complaint frequency does not determine importance.** A constraint never violated has zero complaints. Zero complaints means high compliance, not low importance. Weight structural evidence — how consistently is the pattern honored? — over how often the owner mentioned it.

**Do not mark a cross-cutting principle as implemented.** A law that applies to every new file or contributor never completes. Mark it **law**. An "implemented" law disappears from attention and gets violated in the next large agent-built feature.

**Treat `added_by: agent:*` entries as unconfirmed.** All entries written by this playbook carry that tag. Surface them to the owner in the same session when possible. Inferred contracts must not silently become laws without human review.

**Do not skip the landmine check.** Runtime-read files without templates are the most common source of agent-introduced environment leakage. The check takes thirty seconds. Cleanup after leakage does not.

**Filter tool-result noise when cross-referencing transcripts.** In agent session logs, `role: user` turns include tool outputs alongside human speech. Extract only turns that read as natural language from a human. Attributing machine-generated text to the owner produces false provenance.
