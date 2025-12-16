# ATDD Checklist: Story 3.6 - Write Skills Reference Section

**Story:** 3-6-write-skills-reference-section
**TDD Phase:** RED (tests expected to fail)
**Target File:** README.md

## Test Coverage Summary

| Priority | Tests | Description |
|----------|-------|-------------|
| P0 | 8 | Core acceptance criteria |
| P1 | 5 | Important formatting |
| P2 | 4 | Quality checks |

**Total Tests:** 17

## P0: Core Acceptance Criteria Tests

| ID | Test | AC | Expected | Status |
|----|------|-----|----------|--------|
| AC1.1 | Skills Reference header exists | AC1 | `## Skills Reference` present | [ ] |
| AC1.2 | Intro sentence explaining skills | AC1 | Sentence after header | [ ] |
| AC2.1 | Table header exists | AC2 | `| Skill | What it does | Prerequisites |` | [ ] |
| AC2.2 | Table separator row exists | AC2 | `|---|---|---|` format | [ ] |
| AC3.1 | pr-workflow skill is documented | AC3 | Present in table | [ ] |
| AC3.2 | Skill name in backticks | AC3 | `` `pr-workflow` `` format | [ ] |
| AC3.3 | Description present | AC3 | Non-empty second column | [ ] |
| AC3.4 | Prerequisites present | AC3 | Non-empty third column | [ ] |

## P1: Important Formatting Tests

| ID | Test | AC | Expected | Status |
|----|------|-----|----------|--------|
| EC1.1 | Section after Agents Reference | Position | Skills after Agents | [ ] |
| EC1.2 | Section before Troubleshooting (if exists) | Position | Skills before Troubleshooting | [ ] |
| EC2.1 | Description starts with present-tense verb | Format | "Manages", "Creates", etc. | [ ] |
| EC2.2 | Description under 60 characters | Format | < 60 chars | [ ] |
| EC2.3 | Prerequisites uses MCP notation | Format | `` `github` MCP (via pr-workflow-manager) `` | [ ] |

## P2: Quality Checks

| ID | Test | AC | Expected | Status |
|----|------|-----|----------|--------|
| EC3.1 | No duplicate skill entries | Quality | Count = 1 for pr-workflow | [ ] |
| EC3.2 | Skill file exists in skills/ | Quality | skills/pr-workflow.md exists | [ ] |
| EC3.3 | Table alignment correct | Quality | 4 pipes per row | [ ] |
| EC3.4 | Kebab-case skill name | Quality | No underscores, lowercase | [ ] |

## Skill Reference (for implementation)

| Skill | What it does | Prerequisites |
|-------|--------------|---------------|
| `pr-workflow` | Manages PR workflows - create, status, merge, sync | `github` MCP (via pr-workflow-manager) |

**Source:** skills/pr-workflow.md metadata

## Expected Section Content

```markdown
## Skills Reference

Skills are higher-level capabilities that combine multiple operations into coherent workflows. Unlike commands (user-invoked actions) and agents (specialized fixers), skills provide natural language interfaces to complex multi-step workflows.

| Skill | What it does | Prerequisites |
|-------|--------------|---------------|
| `pr-workflow` | Manages PR workflows - create, status, merge, sync | `github` MCP (via pr-workflow-manager) |
```

## Validation Script

Run: `./tests/atdd/3-6-write-skills-reference-section.sh`

## Pass Criteria

All tests must pass (exit code 0) for story completion.

## Current Status

**Phase:** RED - Tests expected to fail
**Test Count:** 17 tests total
**Coverage:**
- AC1 (Skills Section Header): 2 tests
- AC2 (Table Format): 2 tests
- AC3 (Skill Documented): 4 tests
- EC (Edge Cases): 9 tests

**Priority Distribution:**
- P0: 8 tests (core acceptance criteria)
- P1: 5 tests (section positioning, format validation)
- P2: 4 tests (quality checks)
