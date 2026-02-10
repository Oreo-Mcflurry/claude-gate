# Claude Gate - 4-Phase Quality Gate System

A Claude Code plugin that enforces quality gates at each development phase transition. Catch defects early by requiring structured reviews before moving to the next phase.

## Overview

Claude Gate implements a **4-Phase Gate System** inspired by the SDD (Software Design Document) methodology:

```
Phase 1: Planning    Phase 2: Design      Phase 3: Development   Phase 4: Verification
Requirements   →   Architecture    →     Implementation   →    QA + Security

[Spec Gate]        [Design Gate]        [Task Gate]           [Release Gate]
```

Each gate runs a **checklist-based review** and produces a structured report with a clear verdict.

## Installation

```bash
git clone https://github.com/your-org/claude-gate.git
cd claude-gate
./install.sh
```

This will:
1. Copy agent files to `~/.claude/agents/`
2. Copy the `/gate` command to `~/.claude/commands/`
3. Append Gate System workflow documentation to your `CLAUDE.md`

## Uninstallation

```bash
cd claude-gate
./uninstall.sh
```

Cleanly removes all agents, commands, and CLAUDE.md additions (marker-based removal).

## Usage

### Run a specific gate

```bash
/gate spec       # Spec Gate - review requirements/planning docs
/gate design     # Design Gate - review architecture/design docs
/gate code       # Task Gate - code quality review
/gate release    # Release Gate - code + security review
```

### Auto-detect phase

```bash
/gate            # Analyzes project state and runs the appropriate gate
```

### Check status

```bash
/gate status     # Show all gate statuses
```

## Gates

### Spec Gate (Phase 1 → 2)

Reviews planning and requirements documents for:
- Requirements clarity (EARS format or equivalent)
- Acceptance criteria (Given-When-Then)
- Non-functional requirements (performance, security, scalability)
- Scope boundaries (included/excluded)
- Priority definition (Must/Should/Could)

**Verdict**: Pass / Revise

### Design Gate (Phase 2 → 3)

Reviews architecture and design documents for:
- API contracts (endpoints, schemas)
- Data model definitions
- Component dependency documentation
- Tech stack selection rationale
- Trade-off documentation

**Verdict**: Pass / Revise

### Task Gate (Phase 3 → 4)

Reviews implementation code for:
- **Critical**: Hardcoded secrets, SQL injection, XSS, auth bypass
- **High**: Missing error handling, input validation, unsafe dependencies
- **Medium**: Large functions, duplicate code, missing tests, poor naming
- **Performance**: N+1 queries, unnecessary re-renders, missing memoization

**Verdict**: Approved / Conditional / Changes Required

### Release Gate (Phase 4 → Deploy)

Runs both code review AND security review:
- All Task Gate checks
- Authentication/authorization audit
- Input validation (SQLi, XSS, SSRF, Command Injection)
- Data security (PII, secrets, encryption)
- Dependency security (npm audit, pip audit)
- AI/ML security (prompt injection, token limits)

**Verdict**: Pass / Conditional / Block

## Gate Results

| Result | Meaning | Action |
|--------|---------|--------|
| **Pass** | All checks satisfied | Proceed to next phase |
| **Revise** | Issues found, fixable | Address feedback, re-run gate |
| **Block** | Critical issues (Release Gate only) | Must resolve before release |

## Project Structure

```
claude-gate/
├── README.md                    # This file
├── install.sh                   # Installation script
├── uninstall.sh                 # Uninstallation script
├── agents/
│   ├── gate-keeper.md           # Gate orchestrator (opus, read-only)
│   ├── spec-reviewer.md         # Spec Gate reviewer (sonnet)
│   ├── design-reviewer.md       # Design Gate reviewer (sonnet)
│   ├── code-reviewer.md         # Code quality reviewer (sonnet)
│   └── security-reviewer.md     # Security reviewer (sonnet)
├── commands/
│   └── gate.md                  # /gate slash command
└── claude-md-snippet.md         # CLAUDE.md additions
```

## Compatibility

- **Standalone**: Works with any Claude Code installation
- **Sisyphus**: Fully compatible with the Sisyphus multi-agent system (agents appear in the standard `~/.claude/agents/` directory)

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- `~/.claude/` directory exists

## License

MIT
