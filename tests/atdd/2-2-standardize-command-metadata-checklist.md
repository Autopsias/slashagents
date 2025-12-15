# ATDD Checklist: Story 2.2 - Standardize Command Metadata

**Story:** 2-2-standardize-command-metadata
**Generated:** 2025-12-15
**TDD Phase:** RED (tests failing - metadata not yet standardized)

## Test Script

- **Location:** `/Users/ricardocarvalho/CC_Agents_Commands/tests/atdd/2-2-standardize-command-metadata.sh`
- **Execution:** `./tests/atdd/2-2-standardize-command-metadata.sh`

---

## Story Summary

As a developer browsing available commands,
I want every command to have a clear, consistent description,
so that I can quickly understand what each command does from `/help` output.

---

## Acceptance Criteria

### AC1: Description Format

**Given** each of the 11 command files
**When** metadata is standardized
**Then** each file has a `description` field that:
- Starts with a present-tense verb (e.g., "Manages", "Fixes", "Executes")
- Is under 60 characters
- Answers WHAT it does (not HOW)

### AC2: Prerequisites Field

**Given** each of the 11 command files
**When** metadata is standardized
**Then** each file has a `prerequisites` field that:
- Uses "none" for standalone commands
- Uses exact MCP server name in backticks for MCP-enhanced (e.g., `github` MCP)
- Uses "BMAD framework" for BMAD-required commands

### AC3: Frontmatter Structure

**Given** each command file
**When** metadata is complete
**Then** the frontmatter follows this exact structure:
```yaml
---
description: "[verb-first description under 60 chars]"
prerequisites: "[none | `server` MCP | BMAD framework]"
---
```

---

## Failing Tests Created (RED Phase)

### Validation Script (110 tests)

**File:** `tests/atdd/2-2-standardize-command-metadata.sh`

#### AC1: Description Field Tests (44 tests)

##### TEST-AC-2.2.1a: Description Field Exists (11 tests)

| Test ID | Command | Status | Notes |
|---------|---------|--------|-------|
| TEST-AC-2.2.1a-pr | pr.md | PASS | Description field exists |
| TEST-AC-2.2.1a-ci-orchestrate | ci-orchestrate.md | PASS | Description field exists |
| TEST-AC-2.2.1a-test-orchestrate | test-orchestrate.md | PASS | Description field exists |
| TEST-AC-2.2.1a-commit-orchestrate | commit-orchestrate.md | PASS | Description field exists |
| TEST-AC-2.2.1a-parallelize | parallelize.md | PASS | Description field exists |
| TEST-AC-2.2.1a-parallelize-agents | parallelize-agents.md | PASS | Description field exists |
| TEST-AC-2.2.1a-epic-dev | epic-dev.md | PASS | Description field exists |
| TEST-AC-2.2.1a-epic-dev-full | epic-dev-full.md | PASS | Description field exists |
| TEST-AC-2.2.1a-epic-dev-init | epic-dev-init.md | PASS | Description field exists |
| TEST-AC-2.2.1a-nextsession | nextsession.md | PASS | Description field exists |
| TEST-AC-2.2.1a-usertestgates | usertestgates.md | PASS | Description field exists |

##### TEST-AC-2.2.1b: Description Starts With Verb (11 tests)

| Test ID | Command | Status | Current Value | Expected |
|---------|---------|--------|---------------|----------|
| TEST-AC-2.2.1b-pr | pr.md | RED | "Simple PR workflow..." | Verb-first |
| TEST-AC-2.2.1b-ci-orchestrate | ci-orchestrate.md | RED | "Orchestrate CI/CD..." | "Orchestrates..." |
| TEST-AC-2.2.1b-test-orchestrate | test-orchestrate.md | RED | "Orchestrate test..." | "Orchestrates..." |
| TEST-AC-2.2.1b-commit-orchestrate | commit-orchestrate.md | RED | "Orchestrate git..." | "Orchestrates..." |
| TEST-AC-2.2.1b-parallelize | parallelize.md | RED | "Parallelize tasks..." | "Parallelizes..." |
| TEST-AC-2.2.1b-parallelize-agents | parallelize-agents.md | RED | "Parallelize tasks..." | "Parallelizes..." |
| TEST-AC-2.2.1b-epic-dev | epic-dev.md | RED | "Automate BMAD..." | "Automates..." |
| TEST-AC-2.2.1b-epic-dev-full | epic-dev-full.md | RED | "Full TDD/ATDD..." | Verb-first |
| TEST-AC-2.2.1b-epic-dev-init | epic-dev-init.md | RED | "Verify BMAD..." | "Verifies..." |
| TEST-AC-2.2.1b-nextsession | nextsession.md | RED | "Generates a continuation..." | "Generates..." |
| TEST-AC-2.2.1b-usertestgates | usertestgates.md | RED | "Find and run..." | "Finds..." |

##### TEST-AC-2.2.1c: Description Under 60 Characters (11 tests)

| Test ID | Command | Status | Current Chars | Max |
|---------|---------|--------|---------------|-----|
| TEST-AC-2.2.1c-pr | pr.md | RED | 66 | 59 |
| TEST-AC-2.2.1c-ci-orchestrate | ci-orchestrate.md | RED | 77 | 59 |
| TEST-AC-2.2.1c-test-orchestrate | test-orchestrate.md | RED | 80 | 59 |
| TEST-AC-2.2.1c-commit-orchestrate | commit-orchestrate.md | RED | 83 | 59 |
| TEST-AC-2.2.1c-parallelize | parallelize.md | RED | 79 | 59 |
| TEST-AC-2.2.1c-parallelize-agents | parallelize-agents.md | RED | 89 | 59 |
| TEST-AC-2.2.1c-epic-dev | epic-dev.md | PASS | 54 | 59 |
| TEST-AC-2.2.1c-epic-dev-full | epic-dev-full.md | RED | 92 | 59 |
| TEST-AC-2.2.1c-epic-dev-init | epic-dev-init.md | PASS | 38 | 59 |
| TEST-AC-2.2.1c-nextsession | nextsession.md | RED | 96 | 59 |
| TEST-AC-2.2.1c-usertestgates | usertestgates.md | PASS | 53 | 59 |

##### TEST-AC-2.2.1d: Description Matches Expected (11 tests)

| Test ID | Command | Expected Description | Status |
|---------|---------|---------------------|--------|
| TEST-AC-2.2.1d-pr | pr.md | "Manages pull request workflows" | RED |
| TEST-AC-2.2.1d-ci-orchestrate | ci-orchestrate.md | "Orchestrates CI/CD pipeline fixes" | RED |
| TEST-AC-2.2.1d-test-orchestrate | test-orchestrate.md | "Orchestrates test failure analysis" | RED |
| TEST-AC-2.2.1d-commit-orchestrate | commit-orchestrate.md | "Orchestrates git commit workflows" | RED |
| TEST-AC-2.2.1d-parallelize | parallelize.md | "Parallelizes tasks across sub-agents" | RED |
| TEST-AC-2.2.1d-parallelize-agents | parallelize-agents.md | "Parallelizes tasks with specialized agents" | RED |
| TEST-AC-2.2.1d-epic-dev | epic-dev.md | "Automates BMAD development cycle" | RED |
| TEST-AC-2.2.1d-epic-dev-full | epic-dev-full.md | "Executes full TDD/ATDD BMAD cycle" | RED |
| TEST-AC-2.2.1d-epic-dev-init | epic-dev-init.md | "Verifies BMAD project setup" | RED |
| TEST-AC-2.2.1d-nextsession | nextsession.md | "Generates continuation prompt for next session" | RED |
| TEST-AC-2.2.1d-usertestgates | usertestgates.md | "Finds and runs next test gate" | RED |

---

#### AC2: Prerequisites Field Tests (33 tests)

##### TEST-AC-2.2.2a: Prerequisites Field Exists (11 tests)

| Test ID | Command | Status | Notes |
|---------|---------|--------|-------|
| TEST-AC-2.2.2a-pr | pr.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-ci-orchestrate | ci-orchestrate.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-test-orchestrate | test-orchestrate.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-commit-orchestrate | commit-orchestrate.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-parallelize | parallelize.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-parallelize-agents | parallelize-agents.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-epic-dev | epic-dev.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-epic-dev-full | epic-dev-full.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-epic-dev-init | epic-dev-init.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-nextsession | nextsession.md | RED | Missing prerequisites field |
| TEST-AC-2.2.2a-usertestgates | usertestgates.md | RED | Missing prerequisites field |

##### TEST-AC-2.2.2b: Prerequisites Valid Format (11 tests)

| Test ID | Command | Status | Notes |
|---------|---------|--------|-------|
| TEST-AC-2.2.2b-pr | pr.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-ci-orchestrate | ci-orchestrate.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-test-orchestrate | test-orchestrate.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-commit-orchestrate | commit-orchestrate.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-parallelize | parallelize.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-parallelize-agents | parallelize-agents.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-epic-dev | epic-dev.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-epic-dev-full | epic-dev-full.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-epic-dev-init | epic-dev-init.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-nextsession | nextsession.md | RED | No prerequisites field to validate |
| TEST-AC-2.2.2b-usertestgates | usertestgates.md | RED | No prerequisites field to validate |

##### TEST-AC-2.2.2c: Prerequisites Matches Expected (11 tests)

| Test ID | Command | Expected Prerequisites | Status |
|---------|---------|----------------------|--------|
| TEST-AC-2.2.2c-pr | pr.md | `github` MCP | RED |
| TEST-AC-2.2.2c-ci-orchestrate | ci-orchestrate.md | `github` MCP | RED |
| TEST-AC-2.2.2c-test-orchestrate | test-orchestrate.md | none | RED |
| TEST-AC-2.2.2c-commit-orchestrate | commit-orchestrate.md | none | RED |
| TEST-AC-2.2.2c-parallelize | parallelize.md | none | RED |
| TEST-AC-2.2.2c-parallelize-agents | parallelize-agents.md | none | RED |
| TEST-AC-2.2.2c-epic-dev | epic-dev.md | BMAD framework | RED |
| TEST-AC-2.2.2c-epic-dev-full | epic-dev-full.md | BMAD framework | RED |
| TEST-AC-2.2.2c-epic-dev-init | epic-dev-init.md | BMAD framework | RED |
| TEST-AC-2.2.2c-nextsession | nextsession.md | none | RED |
| TEST-AC-2.2.2c-usertestgates | usertestgates.md | test gates in project | RED |

---

#### AC3: Frontmatter Structure Tests (33 tests)

##### TEST-AC-2.2.3a: Valid YAML Frontmatter (11 tests)

| Test ID | Command | Status | Notes |
|---------|---------|--------|-------|
| TEST-AC-2.2.3a-pr | pr.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-ci-orchestrate | ci-orchestrate.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-test-orchestrate | test-orchestrate.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-commit-orchestrate | commit-orchestrate.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-parallelize | parallelize.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-parallelize-agents | parallelize-agents.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-epic-dev | epic-dev.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-epic-dev-full | epic-dev-full.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-epic-dev-init | epic-dev-init.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-nextsession | nextsession.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.2.3a-usertestgates | usertestgates.md | PASS | Has valid frontmatter structure |

##### TEST-AC-2.2.3b: Has Required Fields (11 tests)

| Test ID | Command | Status | Has Description | Has Prerequisites |
|---------|---------|--------|-----------------|-------------------|
| TEST-AC-2.2.3b-pr | pr.md | RED | true | false |
| TEST-AC-2.2.3b-ci-orchestrate | ci-orchestrate.md | RED | true | false |
| TEST-AC-2.2.3b-test-orchestrate | test-orchestrate.md | RED | true | false |
| TEST-AC-2.2.3b-commit-orchestrate | commit-orchestrate.md | RED | true | false |
| TEST-AC-2.2.3b-parallelize | parallelize.md | RED | true | false |
| TEST-AC-2.2.3b-parallelize-agents | parallelize-agents.md | RED | true | false |
| TEST-AC-2.2.3b-epic-dev | epic-dev.md | RED | true | false |
| TEST-AC-2.2.3b-epic-dev-full | epic-dev-full.md | RED | true | false |
| TEST-AC-2.2.3b-epic-dev-init | epic-dev-init.md | RED | true | false |
| TEST-AC-2.2.3b-nextsession | nextsession.md | RED | true | false |
| TEST-AC-2.2.3b-usertestgates | usertestgates.md | RED | true | false |

##### TEST-AC-2.2.3c: Fields Properly Quoted (11 tests)

| Test ID | Command | Status | Notes |
|---------|---------|--------|-------|
| TEST-AC-2.2.3c-pr | pr.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-ci-orchestrate | ci-orchestrate.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-test-orchestrate | test-orchestrate.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-commit-orchestrate | commit-orchestrate.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-parallelize | parallelize.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-parallelize-agents | parallelize-agents.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-epic-dev | epic-dev.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-epic-dev-full | epic-dev-full.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-epic-dev-init | epic-dev-init.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-nextsession | nextsession.md | RED | Prerequisites not quoted |
| TEST-AC-2.2.3c-usertestgates | usertestgates.md | RED | Prerequisites not quoted |

---

## Test Summary

| Category | Total Tests | Passing | Failing |
|----------|-------------|---------|---------|
| AC1: Description Format | 44 | 14 | 30 |
| AC2: Prerequisites Field | 33 | 0 | 33 |
| AC3: Frontmatter Structure | 33 | 11 | 22 |
| **Total** | **110** | **25** | **85** |

---

## Implementation Checklist

To move from RED to GREEN phase, update each command file:

### Target Frontmatter Format
```yaml
---
description: "[verb-first description under 60 chars]"
prerequisites: "[none | `server` MCP | BMAD framework | descriptive text]"
---
```

### Files to Update

- [ ] `commands/pr.md`
  - [ ] Description: "Manages pull request workflows"
  - [ ] Prerequisites: "`github` MCP"

- [ ] `commands/ci-orchestrate.md`
  - [ ] Description: "Orchestrates CI/CD pipeline fixes"
  - [ ] Prerequisites: "`github` MCP"

- [ ] `commands/test-orchestrate.md`
  - [ ] Description: "Orchestrates test failure analysis"
  - [ ] Prerequisites: "none"

- [ ] `commands/commit-orchestrate.md`
  - [ ] Description: "Orchestrates git commit workflows"
  - [ ] Prerequisites: "none"

- [ ] `commands/parallelize.md`
  - [ ] Description: "Parallelizes tasks across sub-agents"
  - [ ] Prerequisites: "none"

- [ ] `commands/parallelize-agents.md`
  - [ ] Description: "Parallelizes tasks with specialized agents"
  - [ ] Prerequisites: "none"

- [ ] `commands/epic-dev.md`
  - [ ] Description: "Automates BMAD development cycle"
  - [ ] Prerequisites: "BMAD framework"

- [ ] `commands/epic-dev-full.md`
  - [ ] Description: "Executes full TDD/ATDD BMAD cycle"
  - [ ] Prerequisites: "BMAD framework"

- [ ] `commands/epic-dev-init.md`
  - [ ] Description: "Verifies BMAD project setup"
  - [ ] Prerequisites: "BMAD framework"

- [ ] `commands/nextsession.md`
  - [ ] Description: "Generates continuation prompt for next session"
  - [ ] Prerequisites: "none"

- [ ] `commands/usertestgates.md`
  - [ ] Description: "Finds and runs next test gate"
  - [ ] Prerequisites: "test gates in project"

---

## Validation Commands

```bash
# Run all ATDD tests for Story 2.2
./tests/atdd/2-2-standardize-command-metadata.sh

# Quick check - count failing tests
./tests/atdd/2-2-standardize-command-metadata.sh 2>&1 | grep -c "FAIL:"

# Check specific file frontmatter
head -5 commands/pr.md
```

---

## References

- Story file: `docs/sprint-artifacts/stories/2-2-standardize-command-metadata.md`
- Architecture: `docs/architecture.md` (Pattern 1: Description Voice, Pattern 2: Prerequisite Notation)
- Metadata audit: `docs/sprint-artifacts/metadata-audit.md`
