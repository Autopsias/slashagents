# ATDD Checklist: Story 3.7 - Write Troubleshooting Section

**Story:** 3-7-write-troubleshooting-section
**TDD Phase:** RED (tests expected to fail)
**Target File:** README.md

## Test Coverage Summary

| Priority | Tests | Description |
|----------|-------|-------------|
| P0 | 7 | Core acceptance criteria |
| P1 | 4 | Important formatting |
| P2 | 2 | Quality checks |

**Total Tests:** 13

## P0: Core Acceptance Criteria Tests

| ID | Test | AC | Expected | Status |
|----|------|-----|----------|--------|
| AC1.1 | Troubleshooting header exists | AC1 | `## Troubleshooting` present | [ ] |
| AC1.2 | Section after Skills Reference | AC1 | Troubleshooting line > Skills Reference line | [ ] |
| AC2.1 | Contains 3-5 items | AC2 | Count between 3 and 5 | [ ] |
| AC3.1 | MCP configuration guidance present | AC3 | MCP troubleshooting content exists | [ ] |
| AC4.1 | BMAD framework guidance present | AC4 | BMAD troubleshooting content exists | [ ] |
| AC5.1 | Not found guidance present | AC5 | Command/agent not found content exists | [ ] |
| AC6.1 | Items are actionable (has solution steps) | AC6 | Resolution steps present | [ ] |

## P1: Important Formatting Tests

| ID | Test | AC | Expected | Status |
|----|------|-----|----------|--------|
| EC1.1 | Items are scannable (short format) | AC2 | Items use brief format | [ ] |
| EC1.2 | MCP mentions checking prerequisites | AC3 | Prerequisites column reference | [ ] |
| EC1.3 | BMAD lists affected tools | AC4 | epic-dev tools listed | [ ] |
| EC1.4 | Not found mentions file locations | AC5 | ~/.claude/ or .claude/ paths | [ ] |

## P2: Quality Checks

| ID | Test | AC | Expected | Status |
|----|------|-----|----------|--------|
| EC2.1 | No external support as first step | AC6 | No "contact support" first | [ ] |
| EC2.2 | Section before license/contributing | Position | Before ## License or ## Contributing | [ ] |

## Troubleshooting Items Reference (for implementation)

Per architecture (docs/architecture.md lines 629-630), the section should have 3-5 items:

1. **MCP Server Not Configured**
   - Affects: `/pr`, `/ci-orchestrate`, `digdeep`
   - Resolution: Check prerequisites column, configure MCP in Claude settings

2. **BMAD Framework Not Found**
   - Affects: `/epic-dev`, `/epic-dev-full`, `/epic-dev-init`
   - Resolution: Install BMAD framework separately

3. **Command/Agent Not Recognized**
   - Affects: All tools if installation incomplete
   - Resolution: Verify file location, restart Claude Code session

## Expected Section Content

```markdown
## Troubleshooting

**MCP server not working?**
Check the Prerequisites column in reference tables. Tools marked with `MCP` require the corresponding MCP server configured in your Claude settings.

**BMAD commands not found?**
The `/epic-dev`, `/epic-dev-full`, and `/epic-dev-init` commands require the BMAD framework installed separately. These are BMAD-Required tools.

**Command or agent not recognized?**
1. Verify files are in the correct location (`~/.claude/` for global or `.claude/` for project)
2. Ensure you are in an active Claude Code session (not regular terminal)
3. Restart your Claude Code session after installation
```

## Validation Script

Run: `./tests/atdd/3-7-write-troubleshooting-section.sh`

## Pass Criteria

All tests must pass (exit code 0) for story completion.

## Current Status

**Phase:** RED - Tests expected to fail
**Test Count:** 13 tests total
**Coverage:**
- AC1 (Troubleshooting Section Header): 2 tests
- AC2 (Concise Format): 1 test
- AC3 (MCP Configuration Issues): 1 test
- AC4 (BMAD Framework Issues): 1 test
- AC5 (Command/Agent Not Found Issues): 1 test
- AC6 (Self-Service Resolution): 1 test
- EC (Edge Cases): 6 tests

**Priority Distribution:**
- P0: 7 tests (core acceptance criteria)
- P1: 4 tests (important formatting)
- P2: 2 tests (quality checks)
