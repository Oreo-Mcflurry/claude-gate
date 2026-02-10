<div align="center">

# Claude Gate

**4-Phase Quality Gate System for AI Coding Assistants**

Stop shipping bugs. Enforce structured reviews at every development phase.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](pulls)
[![Hits](https://hits.sh/github.com/Oreo-Mcflurry/claude-gate.svg?label=visitors&color=79C83D)](https://hits.sh/github.com/Oreo-Mcflurry/claude-gate/)

[Installation](#installation) | [Usage](#usage) | [Gates](#gates) | [Multi-CLI](#supported-cli-tools) | [Korean](README.ko.md)

</div>

---

## What is Claude Gate?

Claude Gate enforces **quality gates** at each development phase transition. Catch defects early by requiring structured, checklist-based reviews before moving to the next phase.

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

## Supported CLI Tools

| CLI Tool | Status | Gate Command |
|----------|--------|-------------|
| **Claude Code** | Fully supported | `/gate spec`, `/gate code`, `/gate release` |
| **Codex CLI** | Fully supported | `run gate-spec`, `run gate-code`, `run gate-release` |
| **Gemini CLI** | Fully supported | `/gate:spec`, `/gate:code`, `/gate:release` |

The installer **auto-detects** installed CLIs and lets you choose which to install for.

## Installation

### npm (Recommended)

```bash
npm exec @oreo-mcflurry-majang/claude-gate
```

### Manual

```bash
git clone https://github.com/Oreo-Mcflurry/claude-gate.git
cd claude-gate
./install.sh
```

The interactive installer will:

1. Detect installed CLI tools (Claude Code, Codex, Gemini)
2. Let you select one or more targets
3. Install gate files in each CLI's native format

> To uninstall, run `./uninstall.sh` - it cleanly removes everything (marker-based).

## Usage

### Claude Code

```bash
/gate              # Auto-detect phase and run the right gate
/gate spec         # Review requirements & planning docs
/gate design       # Review architecture & design docs
/gate code         # Code quality review
/gate release      # Final review: code + security (runs in parallel)
/gate status       # See where you are
```

### Codex CLI

```bash
run gate-spec      # Review requirements
run gate-design    # Review architecture
run gate-code      # Code quality review
run gate-release   # Final review: code + security
```

### Gemini CLI

```bash
/gate:spec         # Review requirements
/gate:design       # Review architecture
/gate:code         # Code quality review
/gate:release      # Final review: code + security
/gate:status       # See where you are
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
├── agents/                       # Claude Code agents
│   ├── gate-keeper.md
│   ├── spec-reviewer.md
│   ├── design-reviewer.md
│   ├── code-reviewer.md
│   └── security-reviewer.md
├── commands/
│   └── gate.md                   # Claude Code /gate command
├── codex/                        # Codex CLI support
│   ├── AGENTS.md
│   └── skills/
│       ├── gate-spec/SKILL.md
│       ├── gate-design/SKILL.md
│       ├── gate-code/SKILL.md
│       └── gate-release/SKILL.md
├── gemini/                       # Gemini CLI support
│   ├── commands/gate/
│   │   ├── spec.toml
│   │   ├── design.toml
│   │   ├── code.toml
│   │   ├── release.toml
│   │   └── status.toml
│   └── agents/
│       ├── spec-reviewer.md
│       ├── design-reviewer.md
│       ├── code-reviewer.md
│       └── security-reviewer.md
├── claude-md-snippet.md
├── install.sh                    # Interactive multi-CLI installer
├── uninstall.sh                  # Clean multi-CLI uninstaller
├── README.md
└── README.ko.md
```

## Compatibility

| Environment | Status |
|------------|--------|
| Claude Code (standalone) | Fully supported |
| Codex CLI | Fully supported |
| Gemini CLI | Fully supported |
| Sisyphus Multi-Agent System | Fully compatible |

## Requirements

At least one of:
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- [Codex CLI](https://github.com/openai/codex) installed
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) installed

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

[MIT](LICENSE)
