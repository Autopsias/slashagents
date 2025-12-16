# ATDD Checklist: Story 3.3 - Write Quick Start Section

**Story:** 3-3-write-quick-start-section
**TDD Phase:** RED (tests expected to fail)
**Target File:** README.md

## Acceptance Criteria Tests

### AC1: Curated Examples (3-5 high-impact examples)

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC1.1 | README.md contains `## Quick Start` section | Present | [ ] |
| AC1.2 | Quick Start section has at least 3 examples | Count >= 3 | [ ] |
| AC1.3 | Quick Start section has at most 5 examples | Count <= 5 | [ ] |
| AC1.4 | Contains at least one standalone command | `/pr` or `/nextsession` or `/commit_orchestrate` | [ ] |
| AC1.5 | Contains at least one orchestration command | `/ci_orchestrate` or `/test_orchestrate` | [ ] |
| AC1.6 | Examples work after installation (no project-specific setup) | No config files required in examples | [ ] |

### AC2: Copy-Paste Commands

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC2.1 | Contains code blocks with slash commands | At least 3 code blocks with `/` commands | [ ] |
| AC2.2 | Commands use proper code block format | Fenced code blocks (```) present | [ ] |
| AC2.3 | No placeholders requiring user modification | No `<placeholder>` or `[YOUR_]` syntax | [ ] |
| AC2.4 | Each example has a description | Text explaining what command does | [ ] |

### AC3: Progressive Complexity

| ID | Test | Expected | Status |
|----|------|----------|--------|
| AC3.1 | First example is simplest command | Simple standalone (e.g., `/pr`, `/nextsession`) | [ ] |
| AC3.2 | Last example is orchestration/complex | Contains orchestration command | [ ] |
| AC3.3 | Examples progress from simple to complex | Word count or complexity increases | [ ] |

### Edge Cases & Quality Checks

| ID | Priority | Test | Expected | Status |
|----|----------|------|----------|--------|
| EC1.1 | P1 | Quick Start positioned after Installation | Section order correct | [ ] |
| EC1.2 | P1 | Quick Start positioned before Commands Reference | Section order correct | [ ] |
| EC2.1 | P2 | No broken markdown in Quick Start | Valid markdown syntax | [ ] |
| EC2.2 | P2 | Examples have descriptive subheaders | `###` headers for each example | [ ] |
| EC3.1 | P1 | Commands use kebab-case (no underscores) | No `/command_name` format | [ ] |
| EC3.2 | P1 | Examples have descriptions between headers and code | Description text present | [ ] |
| EC4.1 | P2 | Consistent code block formatting | All use triple backticks | [ ] |
| EC4.2 | P2 | Consistent MCP notation format | Backtick format: \`github\` MCP | [ ] |

## Validation Script

Run: `./tests/atdd/3-3-write-quick-start-section.sh`

## Pass Criteria

All tests must pass (exit code 0) for story completion.

## Current Status

**Phase:** RED - Tests expected to fail
**Test Count:** 21 tests (13 original ATDD + 8 edge case/quality tests)
**Coverage:**
- Original ATDD coverage: 100% of 3 acceptance criteria
- Extended coverage: +62% with edge cases and quality checks
**Priority Distribution:**
- P0: 13 tests (core acceptance criteria)
- P1: 4 tests (section positioning, kebab-case, descriptions)
- P2: 4 tests (markdown quality, subheaders, formatting, MCP notation)
