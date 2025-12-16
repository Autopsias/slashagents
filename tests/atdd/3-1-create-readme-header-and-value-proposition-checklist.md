# ATDD Checklist: Story 3.1 - Create README Header & Value Proposition

**Story:** 3-1-create-readme-header-and-value-proposition
**TDD Phase:** RED (all tests should FAIL initially)
**Created:** 2025-12-16

## Acceptance Criteria Tests

### AC1: Header Format
Per architecture specification, README.md must have:
- H1 heading: `# CC_Agents_Commands`
- Version line: `**Version:** 1.0.0 | **Updated:** [date] | **Author:** Ricardo`

| Test ID | Description | Status |
|---------|-------------|--------|
| TEST-AC-1.1 | README.md file exists at repository root | [ ] |
| TEST-AC-1.2 | First line is exactly `# CC_Agents_Commands` | [ ] |
| TEST-AC-1.3 | Second line contains `**Version:**`, `**Updated:**`, and `**Author:** Ricardo` | [ ] |
| TEST-AC-1.4 | Updated date is in YYYY-MM-DD format | [ ] |

### AC2: Value Proposition
Header section must communicate within 3-4 sentences:
- What: Claude Code extensions
- Core value: "stay in flow"
- Contents: 23 tools (11 commands, 11 agents, 1 skill)

| Test ID | Description | Status |
|---------|-------------|--------|
| TEST-AC-2.1 | Header section mentions "Claude Code" (case insensitive) | [ ] |
| TEST-AC-2.2 | Header section mentions "stay in flow" concept | [ ] |
| TEST-AC-2.3 | Header section mentions "23" (tool count) | [ ] |
| TEST-AC-2.4 | Header section mentions "11 slash commands" or "11 commands" | [ ] |
| TEST-AC-2.5 | Header section mentions "11 subagents" or "11 agents" | [ ] |
| TEST-AC-2.6 | Header section mentions "1 skill" | [ ] |

### AC3: 30-Second Scan
Per NFR1, header section must be readable in under 30 seconds (~150 words max for header section).

| Test ID | Description | Status |
|---------|-------------|--------|
| TEST-AC-3.1 | Header section (first 10 lines) word count is under 150 words | [ ] |

## Additional Quality Tests (P1: Format & Quality)

| Test ID | Description | Status |
|---------|-------------|--------|
| TEST-P1-1 | Version follows semantic versioning (X.Y.Z pattern) | [ ] |
| TEST-P1-2 | No trailing whitespace in header section | [ ] |
| TEST-P1-3 | Line 3 is blank (proper separation after metadata) | [ ] |
| TEST-P1-4 | Value proposition starts on line 4 | [ ] |

## Edge Case Tests (P2: Edge Cases)

| Test ID | Description | Status |
|---------|-------------|--------|
| TEST-P2-1 | No consecutive blank lines in header section | [ ] |
| TEST-P2-2 | No tab characters in header section (spaces only) | [ ] |
| TEST-P2-3 | Header section character count is reasonable (< 800 chars) | [ ] |
| TEST-P2-4 | Version metadata line has exactly 2 pipe separators | [ ] |

## Validation Commands

### AC1 Validation

```bash
# TEST-AC-1.1: README.md file exists at repository root
test -f /Users/ricardocarvalho/CC_Agents_Commands/README.md && echo "PASS: README.md exists" || echo "FAIL: README.md does not exist"

# TEST-AC-1.2: First line is exactly "# CC_Agents_Commands"
head -n 1 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -q "^# CC_Agents_Commands$" && echo "PASS: Header is correct" || echo "FAIL: Header is not '# CC_Agents_Commands'"

# TEST-AC-1.3: Second line contains Version, Updated, Author: Ricardo
sed -n '2p' /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -q "\*\*Version:\*\*.*\*\*Updated:\*\*.*\*\*Author:\*\* Ricardo" && echo "PASS: Version line format correct" || echo "FAIL: Version line format incorrect"

# TEST-AC-1.4: Updated date is in YYYY-MM-DD format
sed -n '2p' /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -qE "\*\*Updated:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}" && echo "PASS: Date format correct" || echo "FAIL: Date not in YYYY-MM-DD format"
```

### AC2 Validation

```bash
# TEST-AC-2.1: Header section mentions "Claude Code"
head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -qi "claude code" && echo "PASS: Claude Code mentioned" || echo "FAIL: Claude Code not mentioned"

# TEST-AC-2.2: Header section mentions "stay in flow"
head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -qi "stay in flow" && echo "PASS: 'stay in flow' mentioned" || echo "FAIL: 'stay in flow' not mentioned"

# TEST-AC-2.3: Header section mentions "23" (tool count)
head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -q "23" && echo "PASS: Tool count '23' mentioned" || echo "FAIL: Tool count '23' not mentioned"

# TEST-AC-2.4: Header section mentions "11 slash commands" or "11 commands"
head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -qiE "11 (slash )?commands" && echo "PASS: '11 commands' mentioned" || echo "FAIL: '11 commands' not mentioned"

# TEST-AC-2.5: Header section mentions "11 subagents" or "11 agents"
head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -qiE "11 (sub)?agents" && echo "PASS: '11 agents' mentioned" || echo "FAIL: '11 agents' not mentioned"

# TEST-AC-2.6: Header section mentions "1 skill"
head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -qi "1 skill" && echo "PASS: '1 skill' mentioned" || echo "FAIL: '1 skill' not mentioned"
```

### AC3 Validation

```bash
# TEST-AC-3.1: Header section word count under 150 words
WORD_COUNT=$(head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | wc -w | tr -d ' ')
if [ "$WORD_COUNT" -lt 150 ]; then
  echo "PASS: Word count ($WORD_COUNT) is under 150"
else
  echo "FAIL: Word count ($WORD_COUNT) exceeds 150 words"
fi
```

### P1 Validation (Format & Quality)

```bash
# TEST-P1-1: Version follows semantic versioning (X.Y.Z)
sed -n '2p' /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -qE '\*\*Version:\*\* [0-9]+\.[0-9]+\.[0-9]+' && echo "PASS: Semantic versioning" || echo "FAIL: Not semantic versioning"

# TEST-P1-2: No trailing whitespace
head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -qE ' +$' && echo "FAIL: Trailing whitespace found" || echo "PASS: No trailing whitespace"

# TEST-P1-3: Line 3 is blank
THIRD_LINE=$(sed -n '3p' /Users/ricardocarvalho/CC_Agents_Commands/README.md)
[ -z "$THIRD_LINE" ] && echo "PASS: Line 3 is blank" || echo "FAIL: Line 3 not blank"

# TEST-P1-4: Value proposition starts on line 4
FOURTH_LINE=$(sed -n '4p' /Users/ricardocarvalho/CC_Agents_Commands/README.md)
[ -n "$FOURTH_LINE" ] && echo "$FOURTH_LINE" | grep -qE '[A-Za-z]{3,}' && echo "PASS: Value prop on line 4" || echo "FAIL: Value prop not on line 4"
```

### P2 Validation (Edge Cases)

```bash
# TEST-P2-1: No consecutive blank lines
head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -Pzo '\n\n\n' > /dev/null 2>&1 && echo "FAIL: Consecutive blank lines" || echo "PASS: No consecutive blank lines"

# TEST-P2-2: No tab characters
head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | grep -q $'\t' && echo "FAIL: Tab characters found" || echo "PASS: No tabs"

# TEST-P2-3: Character count reasonable
CHAR_COUNT=$(head -n 10 /Users/ricardocarvalho/CC_Agents_Commands/README.md | wc -c | tr -d ' ')
[ "$CHAR_COUNT" -lt 800 ] && echo "PASS: Char count ($CHAR_COUNT)" || echo "FAIL: Char count ($CHAR_COUNT) too high"

# TEST-P2-4: Exactly 2 pipe separators
PIPE_COUNT=$(sed -n '2p' /Users/ricardocarvalho/CC_Agents_Commands/README.md | tr -cd '|' | wc -c | tr -d ' ')
[ "$PIPE_COUNT" -eq 2 ] && echo "PASS: 2 pipes" || echo "FAIL: $PIPE_COUNT pipes"
```

## Run All Tests

Execute the validation script:
```bash
/Users/ricardocarvalho/CC_Agents_Commands/tests/atdd/3-1-create-readme-header-and-value-proposition.sh
```

## Expected Results

### RED Phase (Current)
All tests should FAIL because the current README.md:
- Has header "# Claude Code Extensions" instead of "# CC_Agents_Commands"
- Missing Version/Updated/Author line
- Missing explicit "stay in flow" in header section
- Missing explicit "23 tools" count
- Missing breakdown of "11 commands, 11 agents, 1 skill"

### GREEN Phase (After Implementation)
All tests should PASS after implementing Story 3.1 requirements.

## Test Coverage Summary

| Category | Tests | Priority | Coverage Focus |
|----------|-------|----------|----------------|
| AC1: Header Format | 4 | P0 | Critical acceptance criteria |
| AC2: Value Proposition | 6 | P0 | Critical content requirements |
| AC3: 30-Second Scan | 1 | P0 | NFR compliance |
| P1: Format & Quality | 4 | P1 | Markdown & format validation |
| P2: Edge Cases | 4 | P2 | Robustness & consistency |
| **Total** | **19** | - | **73% increase from baseline** |

### Coverage Metrics
- **Before expansion:** 11 tests (P0 only)
- **After expansion:** 19 tests (P0: 11, P1: 4, P2: 4)
- **Coverage increase:** 73% (8 additional tests)
- **Priority distribution:**
  - P0 (Critical): 11 tests (58%)
  - P1 (Important): 4 tests (21%)
  - P2 (Edge cases): 4 tests (21%)

## Notes

- This is a DOCUMENTATION project validation, not code unit tests
- Tests are bash-based validation checks
- Word count limit (150) is based on average reading speed of ~200 WPM for 30-second read target
- P1 tests ensure markdown quality and format consistency
- P2 tests catch edge cases like trailing whitespace, tabs, consecutive blank lines
