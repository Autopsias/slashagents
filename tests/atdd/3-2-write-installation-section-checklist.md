# ATDD Checklist: Story 3.2 - Write Installation Section

**Story:** 3-2-write-installation-section
**TDD Phase:** RED (tests expected to fail)
**Target File:** README.md

## Acceptance Criteria Tests

### AC1: Installation Steps (5 steps maximum)

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC1.1 | README.md contains `## Installation` section | Present | [ ] |
| AC1.2 | Installation section contains numbered steps (1-5) | 5 steps max | [ ] |
| AC1.3 | Step includes clone/download instruction | Contains `git clone` | [ ] |
| AC1.4 | Step includes backup instruction | Contains backup command | [ ] |
| AC1.5 | Step includes copy instruction | Contains `cp -r` commands | [ ] |
| AC1.6 | Step includes session start instruction | Mentions "new session" or "start" | [ ] |
| AC1.7 | Step includes verification instruction | Contains `/help` | [ ] |

### AC2: Two Installation Paths

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC2.1 | Mentions global installation path | Contains `~/.claude/` | [ ] |
| AC2.2 | Mentions project installation path | Contains `.claude/` (without ~) | [ ] |
| AC2.3 | Explains when to use global | Contains guidance text | [ ] |
| AC2.4 | Explains when to use project | Contains guidance text | [ ] |

### AC3: Backup Warning

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC3.1 | Contains backup warning | Warning text present | [ ] |
| AC3.2 | Warning is visually prominent | Bold, blockquote, or emoji | [ ] |
| AC3.3 | Warning mentions overwrite risk | Contains "overwrite" or similar | [ ] |

### AC4: Copy-Paste Ready

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC4.1 | Contains code blocks | At least one ```bash block | [ ] |
| AC4.2 | Clone command is complete | Full `git clone` URL | [ ] |
| AC4.3 | Copy commands are complete | Valid `cp -r` syntax | [ ] |
| AC4.4 | No placeholders requiring modification | No `<placeholder>` syntax | [ ] |

### Edge Cases & Quality Checks

| ID | Priority | Test | Expected | Status |
|----|----------|------|----------|--------|
| EC1.1 | P1 | GitHub URL format is valid | Contains `github.com` | [ ] |
| EC1.2 | P1 | All three folders mentioned | Contains `commands`, `agents`, `skills` | [ ] |
| EC2.1 | P2 | No broken markdown links | All `[text](url)` links valid | [ ] |
| EC2.2 | P2 | Step numbers sequential | Steps numbered 1, 2, 3, 4, 5 (if present) | [ ] |

## Validation Script

Run: `./tests/atdd/3-2-write-installation-section.sh`

## Pass Criteria

All tests must pass (exit code 0) for story completion.

## Current Status

**Phase:** GREEN - All tests PASS
**Test Count:** 22 tests (18 original ATDD + 4 edge case/quality tests)
**Coverage:**
- Original ATDD coverage: 100% of 4 acceptance criteria
- Extended coverage: +22% with edge cases and quality checks
**Priority Distribution:**
- P0: 18 tests (core acceptance criteria)
- P1: 2 tests (GitHub URL validation, folder completeness)
- P2: 2 tests (markdown link validation, step sequencing)
