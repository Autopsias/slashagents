# ATDD Checklist: Story 2.3 - Standardize Agent Metadata

**Story:** 2-3-standardize-agent-metadata
**Generated:** 2025-12-15
**TDD Phase:** RED (tests failing - metadata not yet standardized)

## Test Script

- **Location:** `/Users/ricardocarvalho/CC_Agents_Commands/tests/atdd/2-3-standardize-agent-metadata.sh`
- **Execution:** `./tests/atdd/2-3-standardize-agent-metadata.sh`

---

## Story Summary

As a developer browsing available agents,
I want every agent to have a clear, consistent description,
so that I can quickly understand what each agent does.

---

## Acceptance Criteria

### AC1: Description Format

**Given** each of the 11 agent files
**When** metadata is standardized
**Then** each file has a `description` field that:
- Starts with a present-tense verb (e.g., "Fixes", "Scans", "Executes")
- Is under 60 characters
- Answers WHAT it does (not HOW)

### AC2: Prerequisites Field

**Given** each of the 11 agent files
**When** metadata is standardized
**Then** each file has a `prerequisites` field that:
- Uses "---" (em dash) for standalone agents
- Uses descriptive text for project-context (e.g., "test files in project")
- Uses exact MCP server name in backticks for MCP-enhanced agents (e.g., `github` MCP)

### AC3: Frontmatter Structure

**Given** each agent file
**When** metadata is complete
**Then** the frontmatter follows this exact structure:
```yaml
---
description: "[verb-first description under 60 chars]"
prerequisites: "[--- | descriptive text | `server` MCP]"
---
```

---

## Failing Tests Created (RED Phase)

### Validation Script (110 tests)

**File:** `tests/atdd/2-3-standardize-agent-metadata.sh`

#### AC1: Description Field Tests (44 tests)

##### TEST-AC-2.3.1a: Description Field Exists (11 tests)

| Test ID | Agent | Status | Notes |
|---------|-------|--------|-------|
| TEST-AC-2.3.1a-unit-test-fixer | unit-test-fixer.md | PASS | Description field exists |
| TEST-AC-2.3.1a-api-test-fixer | api-test-fixer.md | PASS | Description field exists |
| TEST-AC-2.3.1a-database-test-fixer | database-test-fixer.md | PASS | Description field exists |
| TEST-AC-2.3.1a-e2e-test-fixer | e2e-test-fixer.md | PASS | Description field exists |
| TEST-AC-2.3.1a-linting-fixer | linting-fixer.md | PASS | Description field exists |
| TEST-AC-2.3.1a-type-error-fixer | type-error-fixer.md | PASS | Description field exists |
| TEST-AC-2.3.1a-import-error-fixer | import-error-fixer.md | PASS | Description field exists |
| TEST-AC-2.3.1a-security-scanner | security-scanner.md | PASS | Description field exists |
| TEST-AC-2.3.1a-pr-workflow-manager | pr-workflow-manager.md | PASS | Description field exists |
| TEST-AC-2.3.1a-parallel-executor | parallel-executor.md | PASS | Description field exists |
| TEST-AC-2.3.1a-digdeep | digdeep.md | PASS | Description field exists |

##### TEST-AC-2.3.1b: Description Starts With Verb (11 tests)

| Test ID | Agent | Status | Current Value | Expected |
|---------|-------|--------|---------------|----------|
| TEST-AC-2.3.1b-unit-test-fixer | unit-test-fixer.md | RED | Multi-line YAML | Verb-first single line |
| TEST-AC-2.3.1b-api-test-fixer | api-test-fixer.md | PASS | "Fixes API endpoint..." | Verb-first |
| TEST-AC-2.3.1b-database-test-fixer | database-test-fixer.md | PASS | "Fixes database mock..." | Verb-first |
| TEST-AC-2.3.1b-e2e-test-fixer | e2e-test-fixer.md | RED | Multi-line YAML | Verb-first single line |
| TEST-AC-2.3.1b-linting-fixer | linting-fixer.md | RED | Multi-line YAML | Verb-first single line |
| TEST-AC-2.3.1b-type-error-fixer | type-error-fixer.md | RED | Multi-line YAML | Verb-first single line |
| TEST-AC-2.3.1b-import-error-fixer | import-error-fixer.md | RED | Multi-line YAML | Verb-first single line |
| TEST-AC-2.3.1b-security-scanner | security-scanner.md | RED | Multi-line YAML | Verb-first single line |
| TEST-AC-2.3.1b-pr-workflow-manager | pr-workflow-manager.md | RED | Multi-line YAML | Verb-first single line |
| TEST-AC-2.3.1b-parallel-executor | parallel-executor.md | RED | "Independent parallel..." | "Executes..." |
| TEST-AC-2.3.1b-digdeep | digdeep.md | RED | "Advanced analysis..." | "Investigates..." |

##### TEST-AC-2.3.1c: Description Under 60 Characters (11 tests)

| Test ID | Agent | Status | Current Chars | Max |
|---------|-------|--------|---------------|-----|
| TEST-AC-2.3.1c-unit-test-fixer | unit-test-fixer.md | RED | Multi-line (62+) | 59 |
| TEST-AC-2.3.1c-api-test-fixer | api-test-fixer.md | RED | 189 | 59 |
| TEST-AC-2.3.1c-database-test-fixer | database-test-fixer.md | RED | 256 | 59 |
| TEST-AC-2.3.1c-e2e-test-fixer | e2e-test-fixer.md | RED | Multi-line (119+) | 59 |
| TEST-AC-2.3.1c-linting-fixer | linting-fixer.md | RED | Multi-line (124+) | 59 |
| TEST-AC-2.3.1c-type-error-fixer | type-error-fixer.md | RED | Multi-line (77+) | 59 |
| TEST-AC-2.3.1c-import-error-fixer | import-error-fixer.md | RED | Multi-line (92+) | 59 |
| TEST-AC-2.3.1c-security-scanner | security-scanner.md | RED | Multi-line (83+) | 59 |
| TEST-AC-2.3.1c-pr-workflow-manager | pr-workflow-manager.md | RED | Multi-line (78+) | 59 |
| TEST-AC-2.3.1c-parallel-executor | parallel-executor.md | RED | 137 | 59 |
| TEST-AC-2.3.1c-digdeep | digdeep.md | RED | 153 | 59 |

##### TEST-AC-2.3.1d: Description Matches Expected (11 tests)

| Test ID | Agent | Expected Description | Status |
|---------|-------|---------------------|--------|
| TEST-AC-2.3.1d-unit-test-fixer | unit-test-fixer.md | "Fixes Python test failures for pytest and unittest" | RED |
| TEST-AC-2.3.1d-api-test-fixer | api-test-fixer.md | "Fixes API endpoint test failures" | RED |
| TEST-AC-2.3.1d-database-test-fixer | database-test-fixer.md | "Fixes database mock and integration test failures" | RED |
| TEST-AC-2.3.1d-e2e-test-fixer | e2e-test-fixer.md | "Fixes Playwright E2E test failures" | RED |
| TEST-AC-2.3.1d-linting-fixer | linting-fixer.md | "Fixes Python linting and formatting issues" | RED |
| TEST-AC-2.3.1d-type-error-fixer | type-error-fixer.md | "Fixes Python type errors and annotations" | RED |
| TEST-AC-2.3.1d-import-error-fixer | import-error-fixer.md | "Fixes Python import and dependency errors" | RED |
| TEST-AC-2.3.1d-security-scanner | security-scanner.md | "Scans code for security vulnerabilities" | RED |
| TEST-AC-2.3.1d-pr-workflow-manager | pr-workflow-manager.md | "Manages pull request workflows for any Git project" | RED |
| TEST-AC-2.3.1d-parallel-executor | parallel-executor.md | "Executes tasks independently without delegation" | RED |
| TEST-AC-2.3.1d-digdeep | digdeep.md | "Investigates root causes using Five Whys analysis" | RED |

---

#### AC2: Prerequisites Field Tests (33 tests)

##### TEST-AC-2.3.2a: Prerequisites Field Exists (11 tests)

| Test ID | Agent | Status | Notes |
|---------|-------|--------|-------|
| TEST-AC-2.3.2a-unit-test-fixer | unit-test-fixer.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-api-test-fixer | api-test-fixer.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-database-test-fixer | database-test-fixer.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-e2e-test-fixer | e2e-test-fixer.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-linting-fixer | linting-fixer.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-type-error-fixer | type-error-fixer.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-import-error-fixer | import-error-fixer.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-security-scanner | security-scanner.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-pr-workflow-manager | pr-workflow-manager.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-parallel-executor | parallel-executor.md | RED | Missing prerequisites field |
| TEST-AC-2.3.2a-digdeep | digdeep.md | RED | Missing prerequisites field |

##### TEST-AC-2.3.2b: Prerequisites Valid Format (11 tests)

| Test ID | Agent | Status | Notes |
|---------|-------|--------|-------|
| TEST-AC-2.3.2b-unit-test-fixer | unit-test-fixer.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-api-test-fixer | api-test-fixer.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-database-test-fixer | database-test-fixer.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-e2e-test-fixer | e2e-test-fixer.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-linting-fixer | linting-fixer.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-type-error-fixer | type-error-fixer.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-import-error-fixer | import-error-fixer.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-security-scanner | security-scanner.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-pr-workflow-manager | pr-workflow-manager.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-parallel-executor | parallel-executor.md | RED | No prerequisites field to validate |
| TEST-AC-2.3.2b-digdeep | digdeep.md | RED | No prerequisites field to validate |

##### TEST-AC-2.3.2c: Prerequisites Matches Expected (11 tests)

| Test ID | Agent | Expected Prerequisites | Status |
|---------|-------|----------------------|--------|
| TEST-AC-2.3.2c-unit-test-fixer | unit-test-fixer.md | test files in project | RED |
| TEST-AC-2.3.2c-api-test-fixer | api-test-fixer.md | API test files in project | RED |
| TEST-AC-2.3.2c-database-test-fixer | database-test-fixer.md | database test files in project | RED |
| TEST-AC-2.3.2c-e2e-test-fixer | e2e-test-fixer.md | E2E test files in project | RED |
| TEST-AC-2.3.2c-linting-fixer | linting-fixer.md | linting config in project | RED |
| TEST-AC-2.3.2c-type-error-fixer | type-error-fixer.md | Python/TypeScript project | RED |
| TEST-AC-2.3.2c-import-error-fixer | import-error-fixer.md | code files in project | RED |
| TEST-AC-2.3.2c-security-scanner | security-scanner.md | code files in project | RED |
| TEST-AC-2.3.2c-pr-workflow-manager | pr-workflow-manager.md | `github` MCP | RED |
| TEST-AC-2.3.2c-parallel-executor | parallel-executor.md | --- | RED |
| TEST-AC-2.3.2c-digdeep | digdeep.md | `perplexity-ask` MCP | RED |

---

#### AC3: Frontmatter Structure Tests (33 tests)

##### TEST-AC-2.3.3a: Valid YAML Frontmatter (11 tests)

| Test ID | Agent | Status | Notes |
|---------|-------|--------|-------|
| TEST-AC-2.3.3a-unit-test-fixer | unit-test-fixer.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-api-test-fixer | api-test-fixer.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-database-test-fixer | database-test-fixer.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-e2e-test-fixer | e2e-test-fixer.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-linting-fixer | linting-fixer.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-type-error-fixer | type-error-fixer.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-import-error-fixer | import-error-fixer.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-security-scanner | security-scanner.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-pr-workflow-manager | pr-workflow-manager.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-parallel-executor | parallel-executor.md | PASS | Has valid frontmatter structure |
| TEST-AC-2.3.3a-digdeep | digdeep.md | PASS | Has valid frontmatter structure |

##### TEST-AC-2.3.3b: Has Required Fields (11 tests)

| Test ID | Agent | Status | Has Description | Has Prerequisites |
|---------|-------|--------|-----------------|-------------------|
| TEST-AC-2.3.3b-unit-test-fixer | unit-test-fixer.md | RED | true | false |
| TEST-AC-2.3.3b-api-test-fixer | api-test-fixer.md | RED | true | false |
| TEST-AC-2.3.3b-database-test-fixer | database-test-fixer.md | RED | true | false |
| TEST-AC-2.3.3b-e2e-test-fixer | e2e-test-fixer.md | RED | true | false |
| TEST-AC-2.3.3b-linting-fixer | linting-fixer.md | RED | true | false |
| TEST-AC-2.3.3b-type-error-fixer | type-error-fixer.md | RED | true | false |
| TEST-AC-2.3.3b-import-error-fixer | import-error-fixer.md | RED | true | false |
| TEST-AC-2.3.3b-security-scanner | security-scanner.md | RED | true | false |
| TEST-AC-2.3.3b-pr-workflow-manager | pr-workflow-manager.md | RED | true | false |
| TEST-AC-2.3.3b-parallel-executor | parallel-executor.md | RED | true | false |
| TEST-AC-2.3.3b-digdeep | digdeep.md | RED | true | false |

##### TEST-AC-2.3.3c: Fields Properly Quoted (11 tests)

| Test ID | Agent | Status | Notes |
|---------|-------|--------|-------|
| TEST-AC-2.3.3c-unit-test-fixer | unit-test-fixer.md | RED | Uses multi-line YAML, not quoted |
| TEST-AC-2.3.3c-api-test-fixer | api-test-fixer.md | RED | Description not quoted |
| TEST-AC-2.3.3c-database-test-fixer | database-test-fixer.md | RED | Description not quoted |
| TEST-AC-2.3.3c-e2e-test-fixer | e2e-test-fixer.md | RED | Uses multi-line YAML |
| TEST-AC-2.3.3c-linting-fixer | linting-fixer.md | RED | Uses multi-line YAML |
| TEST-AC-2.3.3c-type-error-fixer | type-error-fixer.md | RED | Uses multi-line YAML |
| TEST-AC-2.3.3c-import-error-fixer | import-error-fixer.md | RED | Uses multi-line YAML |
| TEST-AC-2.3.3c-security-scanner | security-scanner.md | RED | Uses multi-line YAML |
| TEST-AC-2.3.3c-pr-workflow-manager | pr-workflow-manager.md | RED | Uses multi-line YAML |
| TEST-AC-2.3.3c-parallel-executor | parallel-executor.md | RED | Description not quoted |
| TEST-AC-2.3.3c-digdeep | digdeep.md | RED | Description not quoted |

---

## Test Summary

| Category | Total Tests | Passing | Failing |
|----------|-------------|---------|---------|
| AC1: Description Format | 44 | 13 | 31 |
| AC2: Prerequisites Field | 33 | 0 | 33 |
| AC3: Frontmatter Structure | 33 | 11 | 22 |
| **Total** | **110** | **24** | **86** |

---

## Implementation Checklist

To move from RED to GREEN phase, update each agent file:

### Target Frontmatter Format
```yaml
---
description: "[verb-first description under 60 chars]"
prerequisites: "[--- | `server` MCP | descriptive text]"
---
```

### Files to Update

- [ ] `agents/unit-test-fixer.md`
  - [ ] Description: "Fixes Python test failures for pytest and unittest"
  - [ ] Prerequisites: "test files in project"

- [ ] `agents/api-test-fixer.md`
  - [ ] Description: "Fixes API endpoint test failures"
  - [ ] Prerequisites: "API test files in project"

- [ ] `agents/database-test-fixer.md`
  - [ ] Description: "Fixes database mock and integration test failures"
  - [ ] Prerequisites: "database test files in project"

- [ ] `agents/e2e-test-fixer.md`
  - [ ] Description: "Fixes Playwright E2E test failures"
  - [ ] Prerequisites: "E2E test files in project"

- [ ] `agents/linting-fixer.md`
  - [ ] Description: "Fixes Python linting and formatting issues"
  - [ ] Prerequisites: "linting config in project"

- [ ] `agents/type-error-fixer.md`
  - [ ] Description: "Fixes Python type errors and annotations"
  - [ ] Prerequisites: "Python/TypeScript project"

- [ ] `agents/import-error-fixer.md`
  - [ ] Description: "Fixes Python import and dependency errors"
  - [ ] Prerequisites: "code files in project"

- [ ] `agents/security-scanner.md`
  - [ ] Description: "Scans code for security vulnerabilities"
  - [ ] Prerequisites: "code files in project"

- [ ] `agents/pr-workflow-manager.md`
  - [ ] Description: "Manages pull request workflows for any Git project"
  - [ ] Prerequisites: "`github` MCP"

- [ ] `agents/parallel-executor.md`
  - [ ] Description: "Executes tasks independently without delegation"
  - [ ] Prerequisites: "---"

- [ ] `agents/digdeep.md`
  - [ ] Description: "Investigates root causes using Five Whys analysis"
  - [ ] Prerequisites: "`perplexity-ask` MCP"

---

## Validation Commands

```bash
# Run all ATDD tests for Story 2.3
./tests/atdd/2-3-standardize-agent-metadata.sh

# Quick check - count failing tests
./tests/atdd/2-3-standardize-agent-metadata.sh 2>&1 | grep -c "FAIL:"

# Check specific file frontmatter
head -5 agents/unit-test-fixer.md
```

---

## References

- Story file: `docs/sprint-artifacts/stories/2-3-standardize-agent-metadata.md`
- Architecture: `docs/architecture.md` (Pattern 1: Description Voice, Pattern 2: Prerequisite Notation)
- Metadata audit: `docs/sprint-artifacts/metadata-audit.md`
