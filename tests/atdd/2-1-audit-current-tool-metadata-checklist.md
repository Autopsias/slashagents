# ATDD Checklist: Story 2.1 - Audit Current Tool Metadata

**Story:** 2-1-audit-current-tool-metadata
**Generated:** 2025-12-15
**TDD Phase:** RED (tests failing - audit not yet performed)

## Test Script

- **Location:** `/Users/ricardocarvalho/CC_Agents_Commands/tests/atdd/2-1-audit-current-tool-metadata.sh`
- **Execution:** `./tests/atdd/2-1-audit-current-tool-metadata.sh`

---

## Story Summary

As a maintainer preparing CC_Agents_Commands for release,
I want a complete audit of current metadata in all 23 tools,
so that I know exactly what needs to be standardized.

---

## Acceptance Criteria

### AC1: Metadata Inventory

**Given** all 23 tool files
**When** audited for metadata
**Then** a checklist is produced showing for each file:
- Current description (or "missing")
- Current prerequisites field (or "missing")
- Description character count
- Whether description starts with verb

### AC2: MCP Server Names Identified

**Given** all tool files that reference MCP servers
**When** audited
**Then** the exact MCP server names are documented:
- Which tools reference which MCP servers
- Exact server identifiers (e.g., `github`, `perplexity-ask`)

### AC3: Tier Classification Draft

**Given** the audit results
**When** analyzed
**Then** each tool is classified into exactly one tier:
- Standalone (works with zero config)
- MCP-Enhanced (requires specific MCP server)
- BMAD-Required (requires BMAD framework)
- Project-Context (requires specific project files)

---

## Failing Tests Created (RED Phase)

### Validation Script (48 tests)

**File:** `tests/atdd/2-1-audit-current-tool-metadata.sh`

#### AC1: File Existence Tests (2 tests)

- **Test:** TEST-AC1-1.1 - metadata-audit.md file exists
  - **Status:** RED - File does not exist yet
  - **Verifies:** Audit report file is created

- **Test:** TEST-AC1-1.2 - metadata-audit.md is not empty
  - **Status:** RED - File does not exist yet
  - **Verifies:** Audit report has content

#### AC1: Structure Validation Tests (4 tests)

- **Test:** TEST-AC1-2.1 - Audit has Summary section
  - **Status:** RED - No audit file
  - **Verifies:** Summary section with totals exists

- **Test:** TEST-AC1-2.2 - Audit has Inventory Table section
  - **Status:** RED - No audit file
  - **Verifies:** Inventory table section exists

- **Test:** TEST-AC1-2.3 - Inventory table has all required columns
  - **Status:** RED - No audit file
  - **Verifies:** Columns: Tool, Type, Description, Char Count, Verb-First, Prerequisites, Tier

- **Test:** TEST-AC1-2.4 - Summary shows 'Total tools: 23'
  - **Status:** RED - No audit file
  - **Verifies:** Summary accurately reports 23 total tools

#### AC1: Command Files Tests (11 tests)

| Test ID | Tool File | Status |
|---------|-----------|--------|
| TEST-AC1-CMD-pr | pr.md | RED |
| TEST-AC1-CMD-ci-orchestrate | ci-orchestrate.md | RED |
| TEST-AC1-CMD-test-orchestrate | test-orchestrate.md | RED |
| TEST-AC1-CMD-commit-orchestrate | commit-orchestrate.md | RED |
| TEST-AC1-CMD-parallelize | parallelize.md | RED |
| TEST-AC1-CMD-parallelize-agents | parallelize-agents.md | RED |
| TEST-AC1-CMD-epic-dev | epic-dev.md | RED |
| TEST-AC1-CMD-epic-dev-full | epic-dev-full.md | RED |
| TEST-AC1-CMD-epic-dev-init | epic-dev-init.md | RED |
| TEST-AC1-CMD-nextsession | nextsession.md | RED |
| TEST-AC1-CMD-usertestgates | usertestgates.md | RED |

#### AC1: Agent Files Tests (11 tests)

| Test ID | Tool File | Status |
|---------|-----------|--------|
| TEST-AC1-AGT-unit-test-fixer | unit-test-fixer.md | RED |
| TEST-AC1-AGT-api-test-fixer | api-test-fixer.md | RED |
| TEST-AC1-AGT-database-test-fixer | database-test-fixer.md | RED |
| TEST-AC1-AGT-e2e-test-fixer | e2e-test-fixer.md | RED |
| TEST-AC1-AGT-linting-fixer | linting-fixer.md | RED |
| TEST-AC1-AGT-type-error-fixer | type-error-fixer.md | RED |
| TEST-AC1-AGT-import-error-fixer | import-error-fixer.md | RED |
| TEST-AC1-AGT-security-scanner | security-scanner.md | RED |
| TEST-AC1-AGT-pr-workflow-manager | pr-workflow-manager.md | RED |
| TEST-AC1-AGT-parallel-executor | parallel-executor.md | RED |
| TEST-AC1-AGT-digdeep | digdeep.md | RED |

#### AC1: Skill Files Tests (1 test)

| Test ID | Tool File | Status |
|---------|-----------|--------|
| TEST-AC1-SKL-pr-workflow | pr-workflow.md | RED |

#### AC2: MCP Server Mapping Tests (5 tests)

- **Test:** TEST-AC2-1.1 - MCP Server Mapping section exists
  - **Status:** RED - No audit file
  - **Verifies:** Section documenting MCP dependencies exists

- **Test:** TEST-AC2-1.2 - MCP mapping references 'github' server
  - **Status:** RED - No audit file
  - **Verifies:** GitHub MCP server is documented

- **Test:** TEST-AC2-1.3 - MCP mapping includes pr.md
  - **Status:** RED - No audit file
  - **Verifies:** PR command MCP dependencies documented

- **Test:** TEST-AC2-1.4 - MCP mapping includes ci-orchestrate.md
  - **Status:** RED - No audit file
  - **Verifies:** CI orchestrate MCP dependencies documented

- **Test:** TEST-AC2-1.5 - MCP mapping has at least 2 tool entries
  - **Status:** RED - No audit file
  - **Verifies:** Multiple MCP-dependent tools documented

#### AC3: Tier Classification Structure Tests (5 tests)

- **Test:** TEST-AC3-1.1 - Tier Classification section exists
  - **Status:** RED - No audit file
  - **Verifies:** Tier classification section exists

- **Test:** TEST-AC3-1.2 - Standalone tier subsection exists
  - **Status:** RED - No audit file
  - **Verifies:** Standalone tier documented

- **Test:** TEST-AC3-1.3 - MCP-Enhanced tier subsection exists
  - **Status:** RED - No audit file
  - **Verifies:** MCP-Enhanced tier documented

- **Test:** TEST-AC3-1.4 - BMAD-Required tier subsection exists
  - **Status:** RED - No audit file
  - **Verifies:** BMAD-Required tier documented

- **Test:** TEST-AC3-1.5 - Project-Context tier subsection exists
  - **Status:** RED - No audit file
  - **Verifies:** Project-Context tier documented

#### AC3: Tier Assignment Tests (5 tests)

- **Test:** TEST-AC3-2.1 - nextsession.md classified in a tier
  - **Status:** RED - No audit file
  - **Verifies:** Tool assigned to a tier

- **Test:** TEST-AC3-2.2 - pr.md classified in a tier
  - **Status:** RED - No audit file
  - **Verifies:** Tool assigned to a tier

- **Test:** TEST-AC3-2.3 - epic-dev.md classified in a tier
  - **Status:** RED - No audit file
  - **Verifies:** Tool assigned to a tier

- **Test:** TEST-AC3-2.4 - unit-test-fixer.md classified in a tier
  - **Status:** RED - No audit file
  - **Verifies:** Tool assigned to a tier

- **Test:** TEST-AC3-2.5 - digdeep.md classified in a tier
  - **Status:** RED - No audit file
  - **Verifies:** Tool assigned to a tier

#### AC3: Single Tier Validation Tests (3 tests)

- **Test:** TEST-AC3-3.1 - pr.md has exactly one tier
  - **Status:** RED - No audit file
  - **Verifies:** Tool not duplicated across tiers

- **Test:** TEST-AC3-3.2 - epic-dev.md has exactly one tier
  - **Status:** RED - No audit file
  - **Verifies:** Tool not duplicated across tiers

- **Test:** TEST-AC3-3.3 - unit-test-fixer.md has exactly one tier
  - **Status:** RED - No audit file
  - **Verifies:** Tool not duplicated across tiers

#### Completeness Tests (2 tests)

- **Test:** TEST-COMP-1.1 - Audit has Issues Found section
  - **Status:** RED - No audit file
  - **Verifies:** Issues/non-compliant metadata documented

- **Test:** TEST-COMP-1.2 - Audit references all 23 tools
  - **Status:** RED - No audit file
  - **Verifies:** No tools omitted from audit

---

## Implementation Checklist

### Task 1: Create Audit File Structure

**File:** `docs/sprint-artifacts/metadata-audit.md`

**Tasks to make structure tests pass:**

- [ ] Create metadata-audit.md file
- [ ] Add `## Summary` section with totals
- [ ] Add `## Inventory Table` section with column headers
- [ ] Add `## MCP Server Mapping` section
- [ ] Add `## Tier Classification` section with 4 subsections
- [ ] Add `## Issues Found` section
- [ ] Run test: `./tests/atdd/2-1-audit-current-tool-metadata.sh`

---

### Task 2: Audit Command Files (11 files)

**Files:** `commands/*.md`

**Tasks to make command tests pass:**

- [ ] Read pr.md - extract description, prerequisites, count chars, check verb
- [ ] Read ci-orchestrate.md - extract description, prerequisites, count chars, check verb
- [ ] Read test-orchestrate.md - extract description, prerequisites, count chars, check verb
- [ ] Read commit-orchestrate.md - extract description, prerequisites, count chars, check verb
- [ ] Read parallelize.md - extract description, prerequisites, count chars, check verb
- [ ] Read parallelize-agents.md - extract description, prerequisites, count chars, check verb
- [ ] Read epic-dev.md - extract description, prerequisites, count chars, check verb
- [ ] Read epic-dev-full.md - extract description, prerequisites, count chars, check verb
- [ ] Read epic-dev-init.md - extract description, prerequisites, count chars, check verb
- [ ] Read nextsession.md - extract description, prerequisites, count chars, check verb
- [ ] Read usertestgates.md - extract description, prerequisites, count chars, check verb
- [ ] Add all commands to inventory table
- [ ] Run test: `./tests/atdd/2-1-audit-current-tool-metadata.sh`

---

### Task 3: Audit Agent Files (11 files)

**Files:** `agents/*.md`

**Tasks to make agent tests pass:**

- [ ] Read unit-test-fixer.md - extract description, prerequisites, count chars, check verb
- [ ] Read api-test-fixer.md - extract description, prerequisites, count chars, check verb
- [ ] Read database-test-fixer.md - extract description, prerequisites, count chars, check verb
- [ ] Read e2e-test-fixer.md - extract description, prerequisites, count chars, check verb
- [ ] Read linting-fixer.md - extract description, prerequisites, count chars, check verb
- [ ] Read type-error-fixer.md - extract description, prerequisites, count chars, check verb
- [ ] Read import-error-fixer.md - extract description, prerequisites, count chars, check verb
- [ ] Read security-scanner.md - extract description, prerequisites, count chars, check verb
- [ ] Read pr-workflow-manager.md - extract description, prerequisites, count chars, check verb
- [ ] Read parallel-executor.md - extract description, prerequisites, count chars, check verb
- [ ] Read digdeep.md - extract description, prerequisites, count chars, check verb
- [ ] Add all agents to inventory table
- [ ] Run test: `./tests/atdd/2-1-audit-current-tool-metadata.sh`

---

### Task 4: Audit Skill Files (1 file)

**Files:** `skills/*.md`

**Tasks to make skill tests pass:**

- [ ] Read pr-workflow.md - extract description, prerequisites, count chars, check verb
- [ ] Add skill to inventory table
- [ ] Run test: `./tests/atdd/2-1-audit-current-tool-metadata.sh`

---

### Task 5: Document MCP Server Mappings

**Tasks to make MCP tests pass:**

- [ ] Identify all tools that reference MCP servers
- [ ] Extract exact MCP server identifiers (e.g., `github`, `perplexity-ask`)
- [ ] Create MCP Server Mapping table/list
- [ ] Verify pr.md MCP dependencies documented
- [ ] Verify ci-orchestrate.md MCP dependencies documented
- [ ] Run test: `./tests/atdd/2-1-audit-current-tool-metadata.sh`

---

### Task 6: Draft Tier Classifications

**Tasks to make tier tests pass:**

- [ ] Classify each tool into exactly ONE tier
- [ ] Populate ### Standalone subsection
- [ ] Populate ### MCP-Enhanced subsection
- [ ] Populate ### BMAD-Required subsection
- [ ] Populate ### Project-Context subsection
- [ ] Verify no tool appears in multiple tiers
- [ ] Run test: `./tests/atdd/2-1-audit-current-tool-metadata.sh`

---

### Task 7: Document Issues Found

**Tasks to make completeness tests pass:**

- [ ] List tools with missing descriptions
- [ ] List tools with missing prerequisites
- [ ] List tools with descriptions over 60 chars
- [ ] List tools with non-verb-first descriptions
- [ ] Verify all 23 tools are referenced in audit
- [ ] Run test: `./tests/atdd/2-1-audit-current-tool-metadata.sh`
- [ ] All tests pass (green phase)

---

## Running Tests

```bash
# Make script executable
chmod +x ./tests/atdd/2-1-audit-current-tool-metadata.sh

# Run all failing tests for this story
./tests/atdd/2-1-audit-current-tool-metadata.sh

# Run with verbose output (shows all results)
bash -x ./tests/atdd/2-1-audit-current-tool-metadata.sh
```

---

## Red-Green-Refactor Workflow

### RED Phase (Current)

**Status:** All tests failing - metadata-audit.md does not exist

**Verification:**
- All tests fail because audit file is missing
- Failure messages are clear and actionable
- Tests fail due to missing audit, not test bugs

### GREEN Phase (Next Steps)

1. Create `docs/sprint-artifacts/metadata-audit.md`
2. Add required sections and structure
3. Audit all 23 tool files for metadata
4. Document MCP server mappings
5. Classify tools into tiers
6. Document issues found
7. Run tests until all pass

### REFACTOR Phase (After All Tests Pass)

- Review audit report for completeness
- Ensure consistent formatting
- Verify all metadata fields are accurate
- Ready for story completion

---

## Expected Output Structure

The audit file `docs/sprint-artifacts/metadata-audit.md` should follow this structure:

```markdown
# Metadata Audit Report

## Summary
- Total tools: 23
- Tools with valid description: X/23
- Tools with prerequisites field: X/23
- Tools requiring metadata updates: X/23

## Inventory Table
| Tool | Type | Description | Char Count | Verb-First | Prerequisites | Tier |
|------|------|-------------|------------|------------|---------------|------|
| pr.md | command | ... | ... | ... | ... | ... |
...

## MCP Server Mapping
| Tool | MCP Server(s) |
|------|---------------|
| pr.md | github |
...

## Tier Classification
### Standalone
- nextsession.md
- commit-orchestrate.md
...

### MCP-Enhanced
- pr.md
- ci-orchestrate.md
...

### BMAD-Required
- epic-dev.md
...

### Project-Context
- unit-test-fixer.md
...

## Issues Found
- List of tools requiring attention
```

---

## Test Execution Evidence

### Initial Test Run (RED Phase Verification)

**Command:** `./tests/atdd/2-1-audit-current-tool-metadata.sh`

**Expected Results:**
- Total tests: 48
- Passing: 0 (expected)
- Failing: 48 (expected)
- Status: RED phase verified

**Primary Failure Reason:**
File `/Users/ricardocarvalho/CC_Agents_Commands/docs/sprint-artifacts/metadata-audit.md` does not exist

---

## Notes

- **Project Context:** This is a documentation/audit project, not software development
- **No Code Changes:** Only auditing existing tool metadata, not modifying tool files
- **Output:** A single markdown file documenting the audit findings
- **Next Story:** Results feed into Story 2.2 (Standardize Description Format)

---

**Generated by ATDD Test Generator Agent** - 2025-12-15
