# ATDD Checklist for Story 2.4: Standardize Skill Metadata

**Story:** 2-4-standardize-skill-metadata
**Test Phase:** RED (tests failing - implementation not started)
**Test File:** `/tests/atdd/2-4-standardize-skill-metadata.sh`
**Target File:** `skills/pr-workflow.md`

## Test Coverage Summary

| Test ID | Acceptance Criteria | Description | Status |
|---------|---------------------|-------------|--------|
| TEST-AC-2.4.1.1 | AC1 | Description field exists | PASS |
| TEST-AC-2.4.1.2 | AC1 | Description starts with present-tense verb | FAIL |
| TEST-AC-2.4.1.3 | AC1 | Description is under 60 characters | FAIL |
| TEST-AC-2.4.1.4 | AC1 | Description matches expected value | FAIL |
| TEST-AC-2.4.1.5 | AC1 | Description focuses on WHAT (not HOW) | FAIL |
| TEST-AC-2.4.2.1 | AC2 | Prerequisites field exists | FAIL |
| TEST-AC-2.4.2.2 | AC2 | Prerequisites uses em dash for standalone | FAIL |
| TEST-AC-2.4.2.3 | AC2 | Prerequisites follows valid tier notation | FAIL |
| TEST-AC-2.4.3.1 | AC3 | Valid YAML frontmatter structure | PASS |
| TEST-AC-2.4.3.2 | AC3 | Has required fields (description, prerequisites) | FAIL |
| TEST-AC-2.4.3.3 | AC3 | No extra fields (like name:) | FAIL |
| TEST-AC-2.4.3.4 | AC3 | Description field is properly quoted | FAIL |
| TEST-AC-2.4.3.5 | AC3 | Prerequisites field is properly quoted | FAIL |
| TEST-AC-2.4.3.6 | AC3 | Frontmatter matches exact target structure | FAIL |

## Current Results

- **Tests Run:** 14
- **Tests Passed:** 2
- **Tests Failed:** 12
- **Phase:** RED (expected)

## Acceptance Criteria Mapping

### AC1: Description Format
Tests verify that `pr-workflow.md` has a description field that:
- [x] TEST-AC-2.4.1.1: Field exists (PASS - field exists but wrong format)
- [ ] TEST-AC-2.4.1.2: Starts with present-tense verb (expects: Manages, Handles, Provides)
- [ ] TEST-AC-2.4.1.3: Under 60 characters (current: 211 chars)
- [ ] TEST-AC-2.4.1.4: Matches expected value: "Manages PR workflows - create, status, merge, sync"
- [ ] TEST-AC-2.4.1.5: Focuses on WHAT (not HOW - remove trigger word instructions)

### AC2: Prerequisites Field
Tests verify that `pr-workflow.md` has a prerequisites field that:
- [ ] TEST-AC-2.4.2.1: Field exists (currently missing)
- [ ] TEST-AC-2.4.2.2: Uses "---" (em dash) for standalone skill
- [ ] TEST-AC-2.4.2.3: Follows valid tier notation format

### AC3: Frontmatter Structure
Tests verify that `pr-workflow.md` frontmatter:
- [x] TEST-AC-2.4.3.1: Has valid YAML structure with --- delimiters (PASS)
- [ ] TEST-AC-2.4.3.2: Contains both required fields (description + prerequisites)
- [ ] TEST-AC-2.4.3.3: Has no extra fields (remove `name:` field)
- [ ] TEST-AC-2.4.3.4: Description field is double-quoted
- [ ] TEST-AC-2.4.3.5: Prerequisites field is double-quoted
- [ ] TEST-AC-2.4.3.6: Matches exact target structure

## Current vs Expected Frontmatter

### Current State
```yaml
---
name: pr-workflow
description: Handle pull request operations - create, status, update, validate, merge, sync. Use when user mentions "PR", "pull request", "merge", "create branch", "check PR status", or any Git workflow terms related to pull requests.
---
```

### Expected State
```yaml
---
description: "Manages PR workflows - create, status, merge, sync"
prerequisites: "---"
---
```

## Issues to Fix

1. **Description too long:** 211 chars -> needs to be under 60 chars
2. **Description wrong verb:** "Handle" -> "Manages" (third-person singular)
3. **Description has HOW details:** Remove trigger word instructions
4. **Prerequisites missing:** Add `prerequisites: "---"` field
5. **Extra field:** Remove `name: pr-workflow` field
6. **Quoting:** Add double quotes around field values

## TDD Workflow

### Phase 1: RED (Current)
- [x] All tests written
- [x] Tests are failing (12 of 14)
- [x] Failures match expected gaps in current implementation

### Phase 2: GREEN (Next)
- [ ] Update `skills/pr-workflow.md` frontmatter
- [ ] Run tests to verify all pass
- [ ] Update metadata-audit.md compliance status

### Phase 3: REFACTOR (Final)
- [ ] Verify no duplicate code in tests
- [ ] Ensure test messages are clear
- [ ] Document any edge cases discovered

## How to Run Tests

```bash
# Run all ATDD tests for story 2.4
./tests/atdd/2-4-standardize-skill-metadata.sh

# Expected output in GREEN phase: "All tests passing!"
```

## References

- Story file: `docs/sprint-artifacts/stories/2-4-standardize-skill-metadata.md`
- Architecture patterns: `docs/architecture.md`
- Metadata audit: `docs/sprint-artifacts/metadata-audit.md`
