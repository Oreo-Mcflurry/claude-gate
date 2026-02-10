<div align="center">

# Claude Gate

**4-Phase Quality Gate System for Claude Code**

Stop shipping bugs. Enforce structured reviews at every development phase.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](pulls)
[![Hits](https://hits.sh/github.com/Oreo-Mcflurry/claude-gate.svg?label=visitors&color=79C83D)](https://hits.sh/github.com/Oreo-Mcflurry/claude-gate/)

[Installation](#installation) | [Usage](#usage) | [Gates](#gates) | [Korean](README.ko.md)

</div>

---

## What is Claude Gate?

Claude Gate is a Claude Code plugin that enforces **quality gates** at each development phase transition. Catch defects early by requiring structured, checklist-based reviews before moving to the next phase.

```
  Planning          Design           Development        Verification
 +-----------+    +-----------+    +-----------+      +-----------+
 |           |    |           |    |           |      |           |
 |  Require- |    |  Archi-   |    |  Implemen-|      |  QA +     |
 |  ments    |--->|  tecture  |--->|  tation   |----->|  Security |
 |           |    |           |    |           |      |           |
 +-----------+    +-----------+    +-----------+      +-----------+
       |                |                |                  |
   Spec Gate       Design Gate      Task Gate         Release Gate
```

Each gate produces a **structured report** with a clear verdict: move forward, revise, or block.

## Installation

```bash
git clone https://github.com/Oreo-Mcflurry/claude-gate.git
cd claude-gate
./install.sh
```

The installer will:

| Step | What it does |
|------|-------------|
| 1 | Copy 5 specialized reviewer agents to `~/.claude/agents/` |
| 2 | Install the `/gate` slash command to `~/.claude/commands/` |
| 3 | Append Gate System workflow docs to your `CLAUDE.md` |

> To uninstall, run `./uninstall.sh` - it cleanly removes everything (marker-based).

## Usage

### Quick Start

```bash
/gate              # Auto-detect phase and run the right gate
/gate status       # See where you are
```

### Run a Specific Gate

```bash
/gate spec         # Review requirements & planning docs
/gate design       # Review architecture & design docs
/gate code         # Code quality review
/gate release      # Final review: code + security (runs in parallel)
```

## Gates

### Spec Gate `Planning -> Design`

Reviews planning and requirements documents.

| Checklist Item | What it checks |
|---------------|---------------|
| Requirements clarity | EARS format or equivalent structured requirements |
| Acceptance criteria | Given-When-Then scenarios defined |
| Non-functional requirements | Performance, security, scalability targets |
| Scope boundaries | Explicitly included and excluded items |
| Priority definition | Must / Should / Could (MoSCoW) |

**Verdict**: `Pass` | `Revise`

---

### Design Gate `Design -> Development`

Reviews architecture and design documents.

| Checklist Item | What it checks |
|---------------|---------------|
| API contracts | Endpoints, request/response schemas |
| Data models | Entity definitions, relationships |
| Component dependencies | Service interaction documentation |
| Tech stack rationale | Why each technology was chosen |
| Trade-off documentation | Alternatives considered and reasons |

**Verdict**: `Pass` | `Revise`

---

### Task Gate `Development -> Verification`

Reviews implementation code with severity levels.

| Severity | Examples |
|----------|---------|
| **Critical** | Hardcoded secrets, SQL injection, XSS, auth bypass |
| **High** | Missing error handling, input validation gaps, unsafe deps |
| **Medium** | Large functions, duplicate code, missing tests, poor naming |
| **Performance** | N+1 queries, unnecessary re-renders, missing memoization |

**Verdict**: `Approved` | `Conditional` | `Changes Required`

---

### Release Gate `Verification -> Deploy`

The final gate. Runs **code review + security audit in parallel**.

| Review Type | What it covers |
|------------|---------------|
| Code Review | All Task Gate checks with release-level thoroughness |
| Security Audit | Auth, input validation (SQLi/XSS/SSRF), data security, dependency audit, AI/ML security |

**Verdict**: `Pass` | `Conditional` | `Block`

## Verdicts at a Glance

| Verdict | Meaning | What to do |
|---------|---------|-----------|
| **Pass** | All checks satisfied | Proceed to next phase |
| **Revise** | Issues found, all fixable | Address feedback, re-run the gate |
| **Block** | Critical issues found | Must resolve before release (Release Gate only) |

## Architecture

```
claude-gate/
├── agents/
│   ├── gate-keeper.md         # Orchestrator - detects phase, routes to reviewer
│   ├── spec-reviewer.md       # Spec Gate reviewer
│   ├── design-reviewer.md     # Design Gate reviewer
│   ├── code-reviewer.md       # Code quality reviewer
│   └── security-reviewer.md   # Security auditor
├── commands/
│   └── gate.md                # /gate slash command definition
├── claude-md-snippet.md       # Auto-appended to your CLAUDE.md
├── install.sh                 # One-command installer
├── uninstall.sh               # Clean uninstaller
├── README.md
└── README.ko.md               # Korean documentation
```

## Compatibility

| Environment | Status |
|------------|--------|
| Claude Code (standalone) | Fully supported |
| Sisyphus Multi-Agent System | Fully compatible |

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- `~/.claude/` directory exists

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

[MIT](LICENSE)
