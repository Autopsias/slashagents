# ATDD Checklist: Story 2.5 - Document Tier Classifications

**Story:** 2-5-document-tier-classifications
**Generated:** 2025-12-15
**TDD Phase:** RED (tests failing - documentation not yet created)

## Test Script

- **Location:** `/Users/ricardocarvalho/CC_Agents_Commands/tests/atdd/2-5-document-tier-classifications.sh`
- **Execution:** `./tests/atdd/2-5-document-tier-classifications.sh`

---

## Story Summary

As a user choosing which tools to use,
I want to know which tools work standalone vs require prerequisites,
so that I can set up the right dependencies before using them.

---

## Acceptance Criteria

### AC1: Standalone Tools Identified

**Given** the tier classification from Story 2.1
**When** finalized
**Then** exactly 6 tools are confirmed as Standalone (prerequisites: none):
- test-orchestrate.md (command)
- commit-orchestrate.md (command)
- parallelize.md (command)
- parallelize-agents.md (command)
- nextsession.md (command)
- parallel-executor.md (agent)

### AC2: MCP-Enhanced Tools Identified

**Given** the tier classification
**When** finalized
**Then** each MCP-enhanced tool is documented with:
- Tool name
- Exact MCP server name required
- What functionality is enhanced (vs degraded without MCP)
- Degraded behavior documented where applicable

### AC3: BMAD-Required Tools Identified

**Given** the tier classification
**When** finalized
**Then** BMAD-required tools are clearly identified:
- epic-dev.md
- epic-dev-full.md
- epic-dev-init.md

### AC4: Project-Context Tools Identified

**Given** the tier classification
**When** finalized
**Then** project-context tools are documented with:
- Tool name
- What project files/structure they require

---

## Failing Tests Created (RED Phase)

### Validation Script (23 tests)

**File:** `tests/atdd/2-5-document-tier-classifications.sh`

#### AC1: Standalone Tools Tests (4 tests)

| Test ID | Description | Status | Notes |
|---------|-------------|--------|-------|
| TEST-AC-2.5.1.1 | tier-classifications.md file exists | RED | File not created yet |
| TEST-AC-2.5.1.2 | Standalone section exists in document | RED | File not created yet |
| TEST-AC-2.5.1.3 | All 7 Standalone tools are listed | RED | File not created yet |
| TEST-AC-2.5.1.4 | Each Standalone tool verified with correct tier | RED | File not created yet |

#### AC2: MCP-Enhanced Tools Tests (5 tests)

| Test ID | Description | Status | Notes |
|---------|-------------|--------|-------|
| TEST-AC-2.5.2.1 | MCP-Enhanced section exists | RED | File not created yet |
| TEST-AC-2.5.2.2 | All 4 MCP-Enhanced tools are listed | RED | File not created yet |
| TEST-AC-2.5.2.3 | Each MCP tool has server name documented | RED | File not created yet |
| TEST-AC-2.5.2.4 | Enhanced functionality documented | RED | File not created yet |
| TEST-AC-2.5.2.5 | Degraded behavior documented | RED | File not created yet |

#### AC3: BMAD-Required Tools Tests (4 tests)

| Test ID | Description | Status | Notes |
|---------|-------------|--------|-------|
| TEST-AC-2.5.3.1 | BMAD-Required section exists | RED | File not created yet |
| TEST-AC-2.5.3.2 | All 3 BMAD-Required tools are listed | RED | File not created yet |
| TEST-AC-2.5.3.3 | BMAD framework requirement documented | RED | File not created yet |
| TEST-AC-2.5.3.4 | Only 3 tools marked as BMAD-Required | RED | File not created yet |

#### AC4: Project-Context Tools Tests (4 tests)

| Test ID | Description | Status | Notes |
|---------|-------------|--------|-------|
| TEST-AC-2.5.4.1 | Project-Context section exists | RED | File not created yet |
| TEST-AC-2.5.4.2 | All 9 Project-Context tools are listed | RED | File not created yet |
| TEST-AC-2.5.4.3 | Project requirements documented | RED | File not created yet |
| TEST-AC-2.5.4.4 | Project requirements reference table exists | RED | File not created yet |

#### Document Structure Tests (4 tests)

| Test ID | Description | Status | Notes |
|---------|-------------|--------|-------|
| TEST-AC-2.5.5.1 | Summary table includes all 23 tools | RED | File not created yet |
| TEST-AC-2.5.5.2 | MCP server reference table exists | RED | File not created yet |
| TEST-AC-2.5.5.3 | Document has proper markdown structure | RED | File not created yet |
| TEST-AC-2.5.5.4 | Total tool count (23) is documented | RED | File not created yet |

#### Metadata Audit Consistency Tests (2 tests)

| Test ID | Description | Status | Notes |
|---------|-------------|--------|-------|
| TEST-AC-2.5.6.1 | Tier classifications marked as finalized | RED | Still shows draft |
| TEST-AC-2.5.6.2 | Consistency between tier-classifications.md and metadata-audit.md | RED | File not created yet |

---

## Test Summary

| Category | Total Tests | Passing | Failing |
|----------|-------------|---------|---------|
| AC1: Standalone Tools | 4 | 0 | 4 |
| AC2: MCP-Enhanced Tools | 5 | 0 | 5 |
| AC3: BMAD-Required Tools | 4 | 0 | 4 |
| AC4: Project-Context Tools | 4 | 0 | 4 |
| Document Structure | 4 | 0 | 4 |
| Metadata Audit Consistency | 2 | 0 | 2 |
| **Total** | **23** | **0** | **23** |

---

## Implementation Checklist

To move from RED to GREEN phase:

### 1. Create tier-classifications.md

Create `docs/sprint-artifacts/tier-classifications.md` with the following structure:

```markdown
# Tier Classifications

## Overview
Total: 23 tools across 4 tiers

## Summary Table
| Tool | Type | Tier | Prerequisites |
|------|------|------|---------------|
[All 23 tools listed with tier assignments]

## Tier Details

### Standalone (7 tools)
Tools that work immediately after installation with no configuration.
- test-orchestrate.md (command)
- commit-orchestrate.md (command)
- parallelize.md (command)
- parallelize-agents.md (command)
- nextsession.md (command)
- parallel-executor.md (agent)
- pr-workflow.md (skill)

### MCP-Enhanced (4 tools)
Tools that require specific MCP servers for full functionality.

| Tool | MCP Server | Enhanced Functionality | Degraded Behavior |
|------|------------|----------------------|-------------------|
| pr.md | github | [describe] | [describe] |
| ci-orchestrate.md | github | [describe] | [describe] |
| pr-workflow-manager.md | github | [describe] | [describe] |
| digdeep.md | perplexity-ask | [describe] | [describe] |

### BMAD-Required (3 tools)
Tools that require the BMAD framework to be installed.
- epic-dev.md
- epic-dev-full.md
- epic-dev-init.md

### Project-Context (9 tools)
Tools that require specific project files or structure.

| Tool | Required Files/Structure |
|------|-------------------------|
| usertestgates.md | test gates infrastructure |
| unit-test-fixer.md | test files in project |
| api-test-fixer.md | API test files in project |
| database-test-fixer.md | database test files in project |
| e2e-test-fixer.md | E2E test files in project |
| linting-fixer.md | linting config in project |
| type-error-fixer.md | Python/TypeScript project |
| import-error-fixer.md | code files in project |
| security-scanner.md | code files in project |

## MCP Server Reference
| MCP Server | Tools Using It |
|------------|----------------|
| github | pr.md, ci-orchestrate.md, pr-workflow-manager.md |
| perplexity-ask | digdeep.md |
| exa | digdeep.md |
| ref | digdeep.md |
| grep | digdeep.md |
| semgrep-hosted | digdeep.md |
| ide | digdeep.md |
| browsermcp | digdeep.md |
| bmad-method | digdeep.md |

## Project Requirements Reference
| Requirement | Tools Needing It |
|-------------|-----------------|
| test files in project | unit-test-fixer.md |
| API test files in project | api-test-fixer.md |
| database test files in project | database-test-fixer.md |
| E2E test files in project | e2e-test-fixer.md |
| linting config in project | linting-fixer.md |
| Python/TypeScript project | type-error-fixer.md |
| code files in project | import-error-fixer.md, security-scanner.md |
| test gates infrastructure | usertestgates.md |
```

### 2. Update metadata-audit.md

Update `docs/sprint-artifacts/metadata-audit.md` to:
- Change tier classification status from "draft" to "finalized"
- Ensure consistency with tier-classifications.md

---

## Validation Commands

```bash
# Run all ATDD tests for Story 2.5
./tests/atdd/2-5-document-tier-classifications.sh

# Quick check - count failing tests
./tests/atdd/2-5-document-tier-classifications.sh 2>&1 | grep -c "FAIL:"

# Verify tier-classifications.md exists
ls -la docs/sprint-artifacts/tier-classifications.md

# Count tools in tier document
grep -E "\.md" docs/sprint-artifacts/tier-classifications.md | wc -l

# Verify all 23 tools are documented
echo "Expected: 23 tools"
```

---

## Expected Test Outcomes After Implementation

**Pass Criteria:**
- tier-classifications.md exists in docs/sprint-artifacts/
- All 23 tools appear in the document
- Each tool has exactly one tier classification
- MCP server names match metadata-audit.md
- Project requirements are specific and actionable
- Document is well-structured and readable
- metadata-audit.md shows "finalized" status

---

## References

- Story file: `docs/sprint-artifacts/stories/2-5-document-tier-classifications.md`
- Architecture: `docs/architecture.md` (Tool Dependency Tiers)
- Metadata audit: `docs/sprint-artifacts/metadata-audit.md`
- CLAUDE.md: Tool Dependency Tiers section
