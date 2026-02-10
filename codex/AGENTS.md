# Claude Gate Quality Gate System for Codex CLI

This directory contains Codex CLI skill definitions for the Claude Gate 4-phase quality gate system. These skills enable systematic quality reviews at each phase of software development.

## What is Claude Gate?

Claude Gate is a structured quality assurance system that enforces quality gates between development phases:

1. **Spec Gate** - Requirements review before design
2. **Design Gate** - Architecture review before coding
3. **Code Gate** - Code quality review before release
4. **Release Gate** - Final security audit before production

Each gate must be passed before proceeding to the next phase.

## Available Skills

### gate-spec
**Purpose**: Review requirements specification documents
**Usage**: `run gate-spec`

Reviews:
- Requirements Clarity (EARS syntax)
- Acceptance Criteria (Given-When-Then)
- Non-Functional Requirements
- Scope Boundaries
- Priority (MoSCoW)

**Output**: Pass/Revise verdict with specific feedback

---

### gate-design
**Purpose**: Review technical design documents
**Usage**: `run gate-design`

Reviews:
- API Contracts
- Data Model
- Component Dependencies
- Tech Stack Rationale
- Trade-offs

**Output**: Pass/Revise verdict with specific feedback

---

### gate-code
**Purpose**: Review code implementation quality
**Usage**: `run gate-code`

Reviews:
- Critical Security Issues (secrets, SQLi, XSS, auth)
- High Priority Issues (error handling, validation)
- Medium Priority Issues (code quality, tests)
- Performance Issues (N+1 queries, inefficient algorithms)
- Design Adherence
- Testing Coverage

**Output**: Approved/Conditional/Changes Required verdict

---

### gate-release
**Purpose**: Comprehensive pre-release review
**Usage**: `run gate-release`

Performs BOTH:
1. **Code Review** (same as gate-code)
2. **Security Audit** covering:
   - Authentication & Authorization
   - Input Validation & Injection
   - Data Security
   - Dependency Security
   - Infrastructure Security
   - Error Handling & Logging
   - AI/ML Security (if applicable)

**Output**: Pass/Conditional/Block verdict

---

## Workflow

### 4-Phase Development Process

```
┌─────────────┐
│  1. SPEC    │  Define requirements
└──────┬──────┘
       │
       ▼
   ┌──────────┐
   │gate-spec │  ◄─── Review requirements
   └─────┬────┘
         │ Pass
         ▼
┌─────────────┐
│  2. DESIGN  │  Create architecture
└──────┬──────┘
       │
       ▼
  ┌───────────┐
  │gate-design│  ◄─── Review design
  └─────┬─────┘
        │ Pass
        ▼
┌─────────────┐
│  3. CODE    │  Implement features
└──────┬──────┘
       │
       ▼
   ┌──────────┐
   │gate-code │  ◄─── Review code
   └─────┬────┘
         │ Approved
         ▼
┌─────────────┐
│  4. RELEASE │  Final verification
└──────┬──────┘
       │
       ▼
  ┌────────────┐
  │gate-release│  ◄─── Security audit
  └─────┬──────┘
        │ Pass
        ▼
   ┌─────────┐
   │ DEPLOY  │
   └─────────┘
```

### Example Usage

```bash
# 1. After writing requirements document
cd project-docs
run gate-spec
# ✓ Pass - Proceed to design

# 2. After creating design document
run gate-design
# ✗ Revise - Address feedback and re-run

# 3. After implementing code
cd src
run gate-code
# ✓ Approved - Proceed to release

# 4. Before deploying to production
run gate-release
# ✓ Pass - Ready for deployment
```

## Gate Verdicts

### Spec Gate & Design Gate
- **Pass**: Proceed to next phase
- **Revise**: Address feedback and re-run review

### Code Gate
- **Approved**: Code is production-ready
- **Conditional**: Minor issues acceptable with tracking
- **Changes Required**: Blocking issues must be fixed

### Release Gate
- **Pass**: Ready for production deployment
- **Conditional**: Deploy with mitigation plan
- **Block**: Critical security issues prevent release

## Best Practices

### When to Run Gates

1. **Run gate-spec** when:
   - Requirements document is drafted
   - Before starting design work
   - After major requirement changes

2. **Run gate-design** when:
   - Design document is complete
   - Before starting implementation
   - After significant architecture changes

3. **Run gate-code** when:
   - Feature implementation is complete
   - Before merging to main branch
   - After significant refactoring

4. **Run gate-release** when:
   - Code is ready for production
   - Before deploying to production
   - After security-sensitive changes

### Handling Revisions

If a gate returns **Revise** or **Changes Required**:

1. **Read the feedback carefully** - Specific issues are listed with file:line references
2. **Address blocking issues first** - Focus on critical/high priority items
3. **Make changes** - Fix issues and update documentation
4. **Re-run the gate** - Verify all issues are resolved
5. **Iterate until pass** - Don't skip gates or rush through

### Document Review Results

Keep a log of gate reviews:

```markdown
# project-docs/gate-reviews.md

## 2026-02-10 - Spec Gate
**Verdict**: Revise
**Issues**: Missing NFRs for performance, acceptance criteria incomplete
**Status**: Fixed, re-review scheduled

## 2026-02-11 - Spec Gate (Re-run)
**Verdict**: Pass
**Next**: Begin design phase

## 2026-02-15 - Design Gate
**Verdict**: Pass
**Next**: Begin implementation
```

## Integration with Development Workflow

### Git Workflow Integration

```bash
# Feature branch workflow
git checkout -b feature/user-auth

# 1. Write spec → gate-spec → commit spec
run gate-spec
git add docs/auth-spec.md
git commit -m "feat(spec): add user authentication requirements"

# 2. Create design → gate-design → commit design
run gate-design
git add docs/auth-design.md
git commit -m "feat(design): add authentication system design"

# 3. Implement → gate-code → commit code
run gate-code
git add src/auth/
git commit -m "feat(auth): implement JWT authentication"

# 4. Pre-merge → gate-release → merge to main
run gate-release
git push origin feature/user-auth
# Create PR, gate-release results in PR description
```

### CI/CD Integration

Gates can be automated in CI pipelines:

```yaml
# .github/workflows/gates.yml
name: Quality Gates

on: [pull_request]

jobs:
  code-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Code Gate
        run: codex run gate-code
      - name: Block if not approved
        run: |
          if ! grep -q "Verdict: Approved" gate-results.md; then
            exit 1
          fi

  release-gate:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Release Gate
        run: codex run gate-release
      - name: Block if not passed
        run: |
          if ! grep -q "Final Verdict: Pass" gate-results.md; then
            exit 1
          fi
```

## Customization

Each SKILL.md can be customized for your team's needs:

1. **Adjust criteria** - Add/remove checklist items
2. **Change thresholds** - Define what constitutes Pass vs Revise
3. **Add team standards** - Include coding style, naming conventions
4. **Integrate tools** - Add linters, scanners, test coverage tools

Edit the SKILL.md files in `codex/skills/gate-*/SKILL.md`.

## Troubleshooting

### "Skill not found" Error

Make sure skills are in the correct location:
```
codex/
└── skills/
    ├── gate-spec/SKILL.md
    ├── gate-design/SKILL.md
    ├── gate-code/SKILL.md
    └── gate-release/SKILL.md
```

### Gates are too strict

Adjust the criteria in individual SKILL.md files. For example, in `gate-code/SKILL.md`, you can:
- Move items from "High Priority" to "Medium Priority"
- Reduce the number of required checks
- Change verdict criteria

### Gates take too long

- Run gates incrementally during development
- Use automated tools for routine checks
- Focus manual review on critical sections
- Run full gate-release only before production

## For AI Agents

When working in this codebase:

1. **Respect gate phases**: Don't skip ahead without passing gates
2. **Run appropriate gate**: Use gate-spec for specs, gate-design for design docs, etc.
3. **Address feedback**: If a gate fails, fix issues before proceeding
4. **Document results**: Save gate review outputs in project docs
5. **Automate when possible**: Integrate gates into CI/CD pipelines

## Additional Resources

- **EARS Requirements**: Easy Approach to Requirements Syntax
- **Given-When-Then**: Behavior-driven development acceptance criteria format
- **MoSCoW**: Must/Should/Could/Won't prioritization method
- **OWASP Top 10**: Common web security vulnerabilities
- **CVE Database**: Known security vulnerabilities in dependencies

## Maintenance

- **Update skills regularly** to reflect new security threats, best practices
- **Collect feedback** from team on gate effectiveness
- **Adjust criteria** based on project needs and team maturity
- **Version control** skill definitions alongside code

---

**Last Updated**: 2026-02-10
**Version**: 1.0.0
**Maintainer**: Claude Gate System
