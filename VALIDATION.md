# CC_Agents_Commands - Pre-Release Validation Checklist

**Version:** 1.0
**Last Updated:** 2025-12-16

> This checklist MUST be completed before any public release.

---

## Table of Contents

1. [Tool Validation Matrix](#1-tool-validation-matrix)
2. [Clean Environment Test](#2-clean-environment-test)
3. [First-Use Test Protocol](#3-first-use-test-protocol)
4. [Pre-Release Quality Gates](#4-pre-release-quality-gates)
5. [Known Limitations](#5-known-limitations)
6. [Validation History](#6-validation-history)

---

## 1. Tool Validation Matrix

Test each tool in clean environment. For "Clean Env Test" and "Graceful Failure" columns, mark:
- **PASS** - Tool works correctly
- **FAIL** - Tool crashes or shows confusing errors
- **SKIP** - Prerequisites not available for testing

Use checkboxes `[ ]` to track completion, then replace with PASS/FAIL/SKIP when tested.

| Tool | Type | Tier | Clean Env Test | Graceful Failure | Prerequisites |
|------|------|------|----------------|------------------|---------------|
| test-orchestrate.md | command | Standalone | [ ] | [ ] | — |
| commit-orchestrate.md | command | Standalone | [ ] | [ ] | — |
| parallelize.md | command | Standalone | [ ] | [ ] | — |
| parallelize-agents.md | command | Standalone | [ ] | [ ] | — |
| nextsession.md | command | Standalone | [ ] | [ ] | — |
| pr.md | command | MCP-Enhanced | [ ] | [ ] | `github` MCP |
| ci-orchestrate.md | command | MCP-Enhanced | [ ] | [ ] | `github` MCP |
| epic-dev.md | command | BMAD-Required | [ ] | [ ] | BMAD framework |
| epic-dev-full.md | command | BMAD-Required | [ ] | [ ] | BMAD framework |
| epic-dev-init.md | command | BMAD-Required | [ ] | [ ] | BMAD framework |
| usertestgates.md | command | Project-Context | [ ] | [ ] | test gates infrastructure |
| parallel-executor.md | agent | Standalone | [ ] | [ ] | — |
| pr-workflow-manager.md | agent | MCP-Enhanced | [ ] | [ ] | `github` MCP |
| digdeep.md | agent | MCP-Enhanced | [ ] | [ ] | `perplexity-ask` MCP |
| unit-test-fixer.md | agent | Project-Context | [ ] | [ ] | test files in project |
| api-test-fixer.md | agent | Project-Context | [ ] | [ ] | API test files in project |
| database-test-fixer.md | agent | Project-Context | [ ] | [ ] | database test files in project |
| e2e-test-fixer.md | agent | Project-Context | [ ] | [ ] | E2E test files in project |
| linting-fixer.md | agent | Project-Context | [ ] | [ ] | linting config in project |
| type-error-fixer.md | agent | Project-Context | [ ] | [ ] | Python/TypeScript project |
| import-error-fixer.md | agent | Project-Context | [ ] | [ ] | code files in project |
| security-scanner.md | agent | Project-Context | [ ] | [ ] | code files in project |
| pr-workflow.md | skill | MCP-Enhanced | [ ] | [ ] | `github` MCP |

**Tier Distribution:**
- Standalone: 6 tools (5 commands, 1 agent)
- MCP-Enhanced: 5 tools (2 commands, 2 agents, 1 skill)
- BMAD-Required: 3 tools (3 commands)
- Project-Context: 9 tools (1 command, 8 agents)

**Total: 23 tools (11 commands, 11 agents, 1 skill)**

---

## 2. Clean Environment Test

### Setup
- [ ] Create fresh user account OR use clean Claude Code installation
- [ ] Verify NO existing `~/.claude/commands/`, `~/.claude/agents/`, `~/.claude/skills/`
- [ ] Document Claude Code version: `claude --version`

### Installation Test
- [ ] Clone repository to test location
- [ ] Execute global installation commands from README
- [ ] Start NEW Claude Code session
- [ ] Run `/help` - verify commands appear

### Expected Behavior by Tier

**Standalone Tools (6):**
- Should work immediately with zero configuration
- No graceful failure testing needed (no prerequisites)

**MCP-Enhanced Tools (5):**
- Should detect missing MCP servers
- Should provide clear guidance on required MCP configuration
- Must not crash or produce confusing errors

**BMAD-Required Tools (3):**
- Should detect absence of `.bmad/` directory
- Should show clear "Not a BMAD project" error message
- Should explain what BMAD framework is and where to get it

**Project-Context Tools (9):**
- Should detect missing required files (tests, linting config, etc.)
- Should provide actionable error messages
- Should not crash on empty or incompatible projects

### Result
- **Tester:**
- **Date:**
- **Status:** PASS / FAIL
- **Notes:**

---

## 3. First-Use Test Protocol

### Tester Requirements
- Person who has NEVER used these tools before
- Has Claude Code installed
- Can follow written instructions only (no verbal help)

### Cold Tester Requirement
**Minimum: 2-3 cold testers** (per architecture.md Phase 4)

### Test Procedure
1. Provide tester with ONLY the README.md
2. Ask them to install the tools
3. Ask them to test tools from each tier:
   - **Standalone:** Try `/nextsession` (should work immediately)
   - **MCP-Enhanced:** Try `/pr` without MCP (should show graceful error)
   - **BMAD-Required:** Try `/epic-dev` without BMAD (should show clear error)
   - **Project-Context:** Try `@unit-test-fixer` without test files (should show actionable error)
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

## 4. Pre-Release Quality Gates

All gates below MUST be PASS before release.

### Gate 1: Tool Matrix Complete
- [ ] All 23 tools listed in validation matrix
- [ ] Type column populated for all tools (11 commands, 11 agents, 1 skill)
- [ ] Tier column populated for all tools (6 Standalone, 5 MCP-Enhanced, 3 BMAD-Required, 9 Project-Context)
- [ ] Prerequisites column populated for all tools
- **Status:** PASS / FAIL
- **Verified by:**
- **Date:**

### Gate 2: Clean Environment Tests
- [ ] Clean Environment Test performed per Section 2
- [ ] All Standalone tools (6) verified working immediately
- [ ] All MCP-Enhanced tools (5) show graceful degradation
- [ ] All BMAD-Required tools (3) show clear error messages
- [ ] All Project-Context tools (9) show actionable errors
- **Status:** PASS / FAIL
- **Verified by:**
- **Date:**

### Gate 3: Graceful Failure Verification
- [ ] MCP-Enhanced tools (5) tested without required MCP servers
- [ ] BMAD-Required tools (3) tested in non-BMAD projects
- [ ] Project-Context tools (9) tested in incompatible projects
- [ ] All tools provide clear, actionable error messages
- [ ] No tools crash or produce confusing stack traces
- **Status:** PASS / FAIL
- **Verified by:**
- **Date:**

### Gate 4: First-Use Test Completed
- [ ] Minimum 2 cold testers recruited
- [ ] All testers provided ONLY README.md (no verbal help)
- [ ] At least 2/3 testers completed installation in <5 minutes
- [ ] At least 2/3 testers successfully ran first command
- [ ] All usability issues documented
- [ ] All usability issues resolved
- **Status:** PASS / FAIL
- **Verified by:**
- **Date:**

### Gate 5: Documentation Quality
- [ ] README.md includes all required sections
- [ ] Installation instructions tested and verified
- [ ] Prerequisites clearly documented for each tool
- [ ] No hardcoded paths in any tool
- [ ] LICENSE file present
- **Status:** PASS / FAIL
- **Verified by:**
- **Date:**

### Final Release Sign-Off

All quality gates above must be PASS before proceeding.

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Developer | | | |
| Tester | | | |
| Release Manager | | | |

---

## 5. Known Limitations

Document any known issues that don't block release:

| Issue | Impact | Workaround | Target Fix |
|-------|--------|------------|------------|
| | | | |

---

## 6. Validation History

| Version | Date | Validator | Result | Notes |
|---------|------|-----------|--------|-------|
| 1.0 | 2025-12-16 | | | Initial validation |

---

*This checklist ensures CC_Agents_Commands meets all PRD quality requirements before public release.*
