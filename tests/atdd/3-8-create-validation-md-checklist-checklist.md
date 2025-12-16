# ATDD Checklist: Story 3.8 - Create VALIDATION.md Checklist

## Story Reference
- **Story ID:** 3.8
- **Title:** Create VALIDATION.md Checklist
- **Status:** RED (7/14 tests failing - VALIDATION.md exists but lacks required table structure)

## Acceptance Criteria Summary

| AC | Description | Test Status |
|----|-------------|-------------|
| AC1 | Checklist Structure (table with required columns) | [ ] |
| AC2 | All 23 Tools Listed (11 commands, 11 agents, 1 skill) | [ ] |
| AC3 | Checkboxes for Testing (unchecked notation) | [ ] |
| AC4 | Ships with Repository (file exists at root) | [ ] |
| AC5 | First-Use Test Section (cold tester requirement) | [ ] |
| AC6 | Pre-Release Quality Gates Section | [ ] |

## Test Inventory

### P0: Core ATDD Tests (9 tests)

| Test ID | AC | Description | Expected | Status |
|---------|-----|-------------|----------|--------|
| AC1.1 | AC4 | VALIDATION.md exists at root | File present | [ ] |
| AC1.2 | AC1 | Table has required columns | Tool, Type, Tier, Clean Env Test, Graceful Failure, Prerequisites | [ ] |
| AC2.1 | AC2 | Contains 11 commands | 11 command entries | [ ] |
| AC2.2 | AC2 | Contains 11 agents | 11 agent entries | [ ] |
| AC2.3 | AC2 | Contains 1 skill | 1 skill entry | [ ] |
| AC2.4 | AC2 | Total 23 tools | Sum equals 23 | [ ] |
| AC3.1 | AC3 | Checkboxes exist (unchecked notation) | [ ] pattern present | [ ] |
| AC5.1 | AC5 | First-Use Test section exists | Section header present | [ ] |
| AC6.1 | AC6 | Quality Gates section exists | Section header present | [ ] |

### P1: Important Validation Tests (3 tests)

| Test ID | EC | Description | Expected | Status |
|---------|-----|-------------|----------|--------|
| EC1.1 | EC1 | Tier distribution correct | 6 Standalone, 5 MCP-Enhanced, 3 BMAD-Required, 9 Project-Context | [ ] |
| EC1.2 | EC1 | Cold tester requirement documented | 2-3 testers mentioned | [ ] |
| EC1.3 | EC1 | Quality gates are actionable | Checkboxes or clear criteria | [ ] |

### P2: Quality Checks (2 tests)

| Test ID | EC | Description | Expected | Status |
|---------|-----|-------------|----------|--------|
| EC2.1 | EC2 | File has title/purpose | Title at top of file | [ ] |
| EC2.2 | EC2 | Table of contents present | TOC section exists | [ ] |

## Total Test Count: 14 tests

- P0 (Core): 9 tests
- P1 (Important): 3 tests
- P2 (Quality): 2 tests

## Execution Instructions

```bash
# Run the test script
./tests/atdd/3-8-create-validation-md-checklist.sh

# Expected result in RED phase: All tests fail (VALIDATION.md does not exist)
# Expected result in GREEN phase: All tests pass
```

## Pass Criteria

**RED Phase (current):**
- 7/14 tests FAIL
- VALIDATION.md exists but lacks required table structure per AC1
- Missing: Tool | Type | Tier | Clean Env Test | Graceful Failure | Prerequisites columns
- Missing: Tier distribution in unified table
- Missing: Table of contents

**GREEN Phase (after implementation):**
- All 14 tests PASS
- VALIDATION.md exists at repository root with unified tool matrix table
- Tool matrix contains exactly 23 tools with Type and Tier columns
- First-Use Test section present
- Quality Gates section present
- Table of contents present

## Notes

- VALIDATION.md exists but needs restructuring to match story requirements
- Existing file has separate tables per tool type; story requires unified table
- Story specifies exact columns: Tool | Type | Tier | Clean Env Test | Graceful Failure | Prerequisites
- This is the final story in Epic 3
- File will be used in Epic 4 for actual validation
- Tool inventory from docs/sprint-artifacts/tier-classifications.md
