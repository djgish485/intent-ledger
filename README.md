# intent-ledger

Keep the *why* of your project as data, in your repo.

Code encodes your methods and tests encode your goals, but neither captures why
anything exists. On agent-built projects this bites hard: every new session — a
coding agent, a contributor, you in three months — rediscovers intent from scratch,
or worse, quietly violates it. The Intent Ledger is two append-only JSONL files,
committed next to your code:

- **`.intent/backlog.jsonl`** — every intention ever expressed behind the project:
  dated, in the author's verbatim words, with a lifecycle status
  (open / implemented / fixed / superseded / rejected). Open entries *are* your
  backlog. Changed minds form readable supersedes-chains.
- **`.intent/contracts.jsonl`** — the rules currently in force, distilled from the
  backlog. Contracts with status **`law`** never expire and bind every change.

Agents and contributors read these before changing behavior, append after, and
sync through plain git — append-only lines merge cleanly by construction. Any
agent that has the repo has the whole system.

## Lineage

Directly inspired by Drew Breunig's spec-driven development writing and his
[Plumb](https://github.com/dbreunig/plumb) decision log ("tests detail our goals
while code encodes our methods, but neither captures the why"). intent-ledger
extends the idea with:

- **Retroactive builds** — reconstruct the ledger from months of existing chat
  logs and git history, as if it had been kept from day one.
- **Lifecycle statuses and supersedes-chains** — intent *evolution* is first-class.
- **Laws** — cross-cutting principles that never complete and bind every change.
- **Provenance instead of approval gates** — verbatim quotes make entries
  self-approving; agent-inferred entries are tagged for spot-checking.
- **Agent playbooks as the product** — the heavy lifting (retroactive mining,
  principle induction, structural audits) ships as procedures for your coding
  agent, not as algorithms. The deterministic code here is just bookkeeping.

## Quickstart

```sh
git clone https://github.com/djgish485/intent-ledger
# put bin/intent on your PATH, or call it directly
cd your-project
intent init
```

`init` scaffolds `.intent/`, installs a **warn-only** pre-commit reminder (fires
when a behavior change is committed without an intent change — it never blocks),
and injects the agent mandate into `AGENTS.md`, `CLAUDE.md`, and `CONTRIBUTING.md`
so Codex, Claude Code, and human PR authors all discover the system automatically.

**Existing project?** Run `intent playbook retro` and hand the output to your
coding agent along with access to your chat history. It rebuilds the backlog
retroactively. A 3–4 month project yielded ~800 entries from ~80k transcript
turns on first deployment.

## Daily use

```sh
intent query carry forward ordering   # search before changing behavior
intent laws                           # the rules that bind every change
intent open                           # the live backlog
intent append '{"intent":"...","quote":"...","kind":"directive","area":"ui"}'
intent status 3f9a12bc77d04e21 implemented "landed in #42"
intent doctor                         # check the wiring
intent index                          # optional FTS index (derived, don't commit)
```

## The playbooks

The judgment-heavy procedures are markdown playbooks your agent executes:

| Playbook | Purpose |
|---|---|
| [`retro`](playbooks/retroactive-build.md) | build the ledger from existing history |
| [`induce`](playbooks/principle-induction.md) | find laws hiding as scattered instances |
| [`audit`](playbooks/silent-constraints-audit.md) | mine what the owner *built*, not just said — catch honored-but-unwritten constraints before an agent violates one |
| [`loop`](playbooks/maintenance-loop.md) | the standing read-before / append-after practice |

`intent playbook <name>` prints any of them.

## Design rules

- The ledger is the source of truth; any index is derived and disposable.
- Append-only: history is never rewritten, minds change via supersedes.
- Raw conversations stay out of git; the ledger is the distilled, repo-audience-safe why.
- No gates: the reminder hook warns and always exits 0. Enforcement is judgment
  against the record. (If your project ever needs a hard gate, that's a one-line
  change in `.githooks/pre-commit` — make it deliberately.)

## Format

See [spec/FORMAT.md](spec/FORMAT.md).

## License

MIT
