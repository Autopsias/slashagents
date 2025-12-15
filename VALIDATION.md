# CC_Agents_Commands - Pre-Release Validation Checklist

**Version:** 1.0
**Last Updated:** 2025-12-15

> This checklist MUST be completed before any public release.

---

## 1. Clean Environment Test (FR26)

### Setup
- [ ] Create fresh user account OR use clean Claude Code installation
- [ ] Verify NO existing `~/.claude/commands/`, `~/.claude/agents/`, `~/.claude/skills/`
- [ ] Document Claude Code version: `claude --version`

### Installation Test
- [ ] Clone repository to test location
- [ ] Execute global installation commands from README
- [ ] Start NEW Claude Code session
- [ ] Run `/help` - verify commands appear

### Result
- **Tester:**
- **Date:**
- **Status:** PASS / FAIL
- **Notes:**

---

## 2. Tool Verification Matrix (FR26)

Test each tool in clean environment. Mark PASS/FAIL/SKIP (if prerequisites not met).

### Commands (11)

| Command | Test Action | Expected Result | Status |
|---------|-------------|-----------------|--------|
| `/pr` | Run `/pr status` | Shows PR status or "No PR" message | |
| `/pr` (default) | Run `/pr` with uncommitted changes | Stages, commits, pushes | |
| `/ci-orchestrate` | Run without CI failures | Reports "no failures" or analyzes | |
| `/test-orchestrate` | Run in project with tests | Analyzes test status | |
| `/commit-orchestrate` | Run with staged changes | Creates formatted commit | |
| `/parallelize` | Run with simple task | Splits and executes | |
| `/parallelize-agents` | Run with multi-domain task | Spawns specialist agents | |
| `/epic-dev` | Run without BMAD | Shows "Not a BMAD project" error | |
| `/epic-dev-full` | Run without BMAD | Shows "Not a BMAD project" error | |
| `/epic-dev-init` | Run without BMAD | Reports BMAD status | |
| `/nextsession` | Run in any project | Generates continuation prompt | |
| `/usertestgates` | Run without BMAD | Shows appropriate error | |

### Agents (11)

| Agent | Spawn Method | Expected Behavior | Status |
|-------|--------------|-------------------|--------|
| `unit-test-fixer` | Via `/test-orchestrate` or direct Task | Analyzes Python test failures | |
| `api-test-fixer` | Via `/test-orchestrate` or direct Task | Analyzes API test failures | |
| `database-test-fixer` | Via `/test-orchestrate` or direct Task | Analyzes DB test failures | |
| `e2e-test-fixer` | Via `/test-orchestrate` or direct Task | Analyzes E2E test failures | |
| `linting-fixer` | Via `/ci-orchestrate` or direct Task | Fixes linting errors | |
| `type-error-fixer` | Via `/ci-orchestrate` or direct Task | Fixes type errors | |
| `import-error-fixer` | Via `/ci-orchestrate` or direct Task | Fixes import errors | |
| `security-scanner` | Direct Task spawn | Scans for vulnerabilities | |
| `pr-workflow-manager` | Via `/pr` command | Manages PR operations | |
| `parallel-executor` | Via `/parallelize` | Executes parallel tasks | |
| `digdeep` | Direct Task spawn | Performs root cause analysis | |

### Skills (1)

| Skill | Trigger | Expected Behavior | Status |
|-------|---------|-------------------|--------|
| `pr-workflow` | Natural language PR requests | Activates PR management | |

---

## 3. First-Use Test Protocol (FR27)

### Tester Requirements
- Person who has NEVER used these tools before
- Has Claude Code installed
- Can follow written instructions only (no verbal help)

### Test Procedure
1. Provide tester with ONLY the README.md
2. Ask them to install the tools
3. Ask them to run 3 commands of their choice
4. Record time taken and any confusion points

### Tester Feedback Form

**Tester Name:**
**Date:**
**Claude Code Experience Level:** Beginner / Intermediate / Advanced

| Question | Response |
|----------|----------|
| Time to complete installation | ___ minutes |
| Did backup warning prevent data loss? | Yes / No / N/A |
| Were installation steps clear? | 1-5 rating |
| Could you identify tool prerequisites? | Yes / No |
| Did first command work as expected? | Yes / No |
| Any confusion points? | (free text) |
| Would you recommend to a colleague? | Yes / No |

### First-Use Test Results

| Tester | Install Time | First Command Success | Issues Found |
|--------|--------------|----------------------|--------------|
| Tester 1 | | | |
| Tester 2 | | | |
| Tester 3 | | | |

**Minimum Requirement:** 2/3 testers complete installation in <5 minutes with first command success.

---

## 4. Prerequisites Audit (FR28)

### Tool Dependency Verification

| Tool | Declared Prerequisites | Verified Working | Notes |
|------|----------------------|------------------|-------|
| `/pr` | None (standalone) | | |
| `/commit-orchestrate` | None (standalone) | | |
| `/nextsession` | None (standalone) | | |
| `/parallelize` | None (standalone) | | |
| `/parallelize-agents` | None (standalone) | | |
| `/ci-orchestrate` | Enhanced: `github` MCP | | |
| `/test-orchestrate` | Enhanced: `ide` MCP | | |
| `/epic-dev` | BMAD framework | | |
| `/epic-dev-full` | BMAD framework | | |
| `/epic-dev-init` | BMAD framework | | |
| `/usertestgates` | BMAD framework | | |
| `digdeep` | Enhanced: `exa`, `perplexity-ask`, etc. | | |
| `unit-test-fixer` | Python project with tests | | |
| `api-test-fixer` | API project with tests | | |
| `database-test-fixer` | Project with DB tests | | |
| `e2e-test-fixer` | Project with E2E tests | | |
| `linting-fixer` | Project with linting config | | |
| `type-error-fixer` | TypeScript/typed project | | |
| `import-error-fixer` | Any codebase | | |
| `security-scanner` | Any codebase | | |
| `pr-workflow-manager` | Git repository | | |
| `parallel-executor` | None (standalone) | | |
| `pr-workflow` | Git repository | | |

---

## 5. Release Checklist

### Pre-Release Gates

- [ ] Clean environment test: PASS
- [ ] All 11 commands verified
- [ ] All 11 agents verified
- [ ] 1 skill verified
- [ ] First-use test: 2/3 testers successful
- [ ] Prerequisites audit complete
- [ ] README.md includes all required sections
- [ ] No hardcoded paths in any tool
- [ ] LICENSE file present

### Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Developer | | | |
| Tester | | | |
| Release Manager | | | |

---

## 6. Known Limitations

Document any known issues that don't block release:

| Issue | Impact | Workaround | Target Fix |
|-------|--------|------------|------------|
| | | | |

---

## Validation History

| Version | Date | Validator | Result | Notes |
|---------|------|-----------|--------|-------|
| 1.0 | 2025-12-15 | | | Initial validation |

---

*This checklist ensures CC_Agents_Commands meets all PRD quality requirements before public release.*
