#!/bin/bash
# ATDD Validation Script: Story 3.1 - Create README Header & Value Proposition
# TDD Phase: RED - All tests should initially FAIL
# Created: 2025-12-16

# Note: Not using set -e because counter increments can return non-zero

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS_COUNT=0
FAIL_COUNT=0

# Project root
PROJECT_ROOT="/Users/ricardocarvalho/CC_Agents_Commands"
README_FILE="${PROJECT_ROOT}/README.md"

echo "=============================================="
echo "ATDD Validation: Story 3.1"
echo "Create README Header & Value Proposition"
echo "=============================================="
echo ""

# Function to record test result
test_result() {
    local test_id="$1"
    local description="$2"
    local result="$3"

    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}[PASS]${NC} ${test_id}: ${description}"
        ((PASS_COUNT++))
    else
        echo -e "${RED}[FAIL]${NC} ${test_id}: ${description}"
        ((FAIL_COUNT++))
    fi
}

echo "--- AC1: Header Format ---"
echo ""

# TEST-AC-1.1: README.md file exists at repository root
if [ -f "$README_FILE" ]; then
    test_result "TEST-AC-1.1" "README.md file exists at repository root" "PASS"
else
    test_result "TEST-AC-1.1" "README.md file exists at repository root" "FAIL"
    echo -e "${YELLOW}  Note: README.md not found, subsequent tests may fail${NC}"
fi

# TEST-AC-1.2: First line is exactly "# CC_Agents_Commands"
if [ -f "$README_FILE" ]; then
    FIRST_LINE=$(head -n 1 "$README_FILE")
    if [ "$FIRST_LINE" = "# CC_Agents_Commands" ]; then
        test_result "TEST-AC-1.2" "First line is exactly '# CC_Agents_Commands'" "PASS"
    else
        test_result "TEST-AC-1.2" "First line is exactly '# CC_Agents_Commands'" "FAIL"
        echo -e "${YELLOW}  Actual: '${FIRST_LINE}'${NC}"
    fi
else
    test_result "TEST-AC-1.2" "First line is exactly '# CC_Agents_Commands'" "FAIL"
fi

# TEST-AC-1.3: Second line contains Version, Updated, Author: Ricardo
if [ -f "$README_FILE" ]; then
    SECOND_LINE=$(sed -n '2p' "$README_FILE")
    if echo "$SECOND_LINE" | grep -q '\*\*Version:\*\*.*\*\*Updated:\*\*.*\*\*Author:\*\* Ricardo'; then
        test_result "TEST-AC-1.3" "Second line contains Version, Updated, Author: Ricardo" "PASS"
    else
        test_result "TEST-AC-1.3" "Second line contains Version, Updated, Author: Ricardo" "FAIL"
        echo -e "${YELLOW}  Actual line 2: '${SECOND_LINE}'${NC}"
    fi
else
    test_result "TEST-AC-1.3" "Second line contains Version, Updated, Author: Ricardo" "FAIL"
fi

# TEST-AC-1.4: Updated date is in YYYY-MM-DD format
if [ -f "$README_FILE" ]; then
    SECOND_LINE=$(sed -n '2p' "$README_FILE")
    if echo "$SECOND_LINE" | grep -qE '\*\*Updated:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}'; then
        test_result "TEST-AC-1.4" "Updated date is in YYYY-MM-DD format" "PASS"
    else
        test_result "TEST-AC-1.4" "Updated date is in YYYY-MM-DD format" "FAIL"
    fi
else
    test_result "TEST-AC-1.4" "Updated date is in YYYY-MM-DD format" "FAIL"
fi

echo ""
echo "--- AC2: Value Proposition ---"
echo ""

# Get header section (first 10 lines) for AC2 tests
if [ -f "$README_FILE" ]; then
    HEADER_SECTION=$(head -n 10 "$README_FILE")
fi

# TEST-AC-2.1: Header section mentions "Claude Code"
if [ -f "$README_FILE" ]; then
    if echo "$HEADER_SECTION" | grep -qi "claude code"; then
        test_result "TEST-AC-2.1" "Header section mentions 'Claude Code'" "PASS"
    else
        test_result "TEST-AC-2.1" "Header section mentions 'Claude Code'" "FAIL"
    fi
else
    test_result "TEST-AC-2.1" "Header section mentions 'Claude Code'" "FAIL"
fi

# TEST-AC-2.2: Header section mentions "stay in flow"
if [ -f "$README_FILE" ]; then
    if echo "$HEADER_SECTION" | grep -qi "stay in flow"; then
        test_result "TEST-AC-2.2" "Header section mentions 'stay in flow'" "PASS"
    else
        test_result "TEST-AC-2.2" "Header section mentions 'stay in flow'" "FAIL"
    fi
else
    test_result "TEST-AC-2.2" "Header section mentions 'stay in flow'" "FAIL"
fi

# TEST-AC-2.3: Header section mentions "23" (tool count)
if [ -f "$README_FILE" ]; then
    if echo "$HEADER_SECTION" | grep -q "23"; then
        test_result "TEST-AC-2.3" "Header section mentions '23' (tool count)" "PASS"
    else
        test_result "TEST-AC-2.3" "Header section mentions '23' (tool count)" "FAIL"
    fi
else
    test_result "TEST-AC-2.3" "Header section mentions '23' (tool count)" "FAIL"
fi

# TEST-AC-2.4: Header section mentions "11 commands" or "11 slash commands"
if [ -f "$README_FILE" ]; then
    if echo "$HEADER_SECTION" | grep -qiE "11 (slash )?commands"; then
        test_result "TEST-AC-2.4" "Header section mentions '11 commands'" "PASS"
    else
        test_result "TEST-AC-2.4" "Header section mentions '11 commands'" "FAIL"
    fi
else
    test_result "TEST-AC-2.4" "Header section mentions '11 commands'" "FAIL"
fi

# TEST-AC-2.5: Header section mentions "11 agents" or "11 subagents"
if [ -f "$README_FILE" ]; then
    if echo "$HEADER_SECTION" | grep -qiE "11 (sub)?agents"; then
        test_result "TEST-AC-2.5" "Header section mentions '11 agents'" "PASS"
    else
        test_result "TEST-AC-2.5" "Header section mentions '11 agents'" "FAIL"
    fi
else
    test_result "TEST-AC-2.5" "Header section mentions '11 agents'" "FAIL"
fi

# TEST-AC-2.6: Header section mentions "1 skill"
if [ -f "$README_FILE" ]; then
    if echo "$HEADER_SECTION" | grep -qi "1 skill"; then
        test_result "TEST-AC-2.6" "Header section mentions '1 skill'" "PASS"
    else
        test_result "TEST-AC-2.6" "Header section mentions '1 skill'" "FAIL"
    fi
else
    test_result "TEST-AC-2.6" "Header section mentions '1 skill'" "FAIL"
fi

echo ""
echo "--- AC3: 30-Second Scan ---"
echo ""

# TEST-AC-3.1: Header section word count under 150 words
if [ -f "$README_FILE" ]; then
    WORD_COUNT=$(head -n 10 "$README_FILE" | wc -w | tr -d ' ')
    if [ "$WORD_COUNT" -lt 150 ]; then
        test_result "TEST-AC-3.1" "Header section word count under 150 (actual: ${WORD_COUNT})" "PASS"
    else
        test_result "TEST-AC-3.1" "Header section word count under 150 (actual: ${WORD_COUNT})" "FAIL"
    fi
else
    test_result "TEST-AC-3.1" "Header section word count under 150" "FAIL"
fi

echo ""
echo "--- P1: Format & Quality ---"
echo ""

# TEST-P1-1: Version follows semantic versioning (X.Y.Z)
if [ -f "$README_FILE" ]; then
    SECOND_LINE=$(sed -n '2p' "$README_FILE")
    if echo "$SECOND_LINE" | grep -qE '\*\*Version:\*\* [0-9]+\.[0-9]+\.[0-9]+'; then
        test_result "TEST-P1-1" "Version follows semantic versioning (X.Y.Z)" "PASS"
    else
        test_result "TEST-P1-1" "Version follows semantic versioning (X.Y.Z)" "FAIL"
    fi
else
    test_result "TEST-P1-1" "Version follows semantic versioning (X.Y.Z)" "FAIL"
fi

# TEST-P1-2: No trailing whitespace in header section
if [ -f "$README_FILE" ]; then
    if head -n 10 "$README_FILE" | grep -qE ' +$'; then
        test_result "TEST-P1-2" "No trailing whitespace in header section" "FAIL"
    else
        test_result "TEST-P1-2" "No trailing whitespace in header section" "PASS"
    fi
else
    test_result "TEST-P1-2" "No trailing whitespace in header section" "FAIL"
fi

# TEST-P1-3: Line 3 is blank (proper separation after metadata)
if [ -f "$README_FILE" ]; then
    THIRD_LINE=$(sed -n '3p' "$README_FILE")
    if [ -z "$THIRD_LINE" ]; then
        test_result "TEST-P1-3" "Line 3 is blank (proper separation)" "PASS"
    else
        test_result "TEST-P1-3" "Line 3 is blank (proper separation)" "FAIL"
        echo -e "${YELLOW}  Actual line 3: '${THIRD_LINE}'${NC}"
    fi
else
    test_result "TEST-P1-3" "Line 3 is blank (proper separation)" "FAIL"
fi

# TEST-P1-4: Value proposition starts on line 4
if [ -f "$README_FILE" ]; then
    FOURTH_LINE=$(sed -n '4p' "$README_FILE")
    # Should not be empty and should contain text
    if [ -n "$FOURTH_LINE" ] && echo "$FOURTH_LINE" | grep -qE '[A-Za-z]{3,}'; then
        test_result "TEST-P1-4" "Value proposition starts on line 4" "PASS"
    else
        test_result "TEST-P1-4" "Value proposition starts on line 4" "FAIL"
    fi
else
    test_result "TEST-P1-4" "Value proposition starts on line 4" "FAIL"
fi

echo ""
echo "--- P2: Edge Cases ---"
echo ""

# TEST-P2-1: No consecutive blank lines in header section
if [ -f "$README_FILE" ]; then
    # Check for two or more consecutive blank lines
    if head -n 10 "$README_FILE" | grep -Pzo '\n\n\n' > /dev/null 2>&1; then
        test_result "TEST-P2-1" "No consecutive blank lines in header section" "FAIL"
    else
        test_result "TEST-P2-1" "No consecutive blank lines in header section" "PASS"
    fi
else
    test_result "TEST-P2-1" "No consecutive blank lines in header section" "FAIL"
fi

# TEST-P2-2: No tab characters in header section (spaces only)
if [ -f "$README_FILE" ]; then
    if head -n 10 "$README_FILE" | grep -q $'\t'; then
        test_result "TEST-P2-2" "No tab characters in header section" "FAIL"
    else
        test_result "TEST-P2-2" "No tab characters in header section" "PASS"
    fi
else
    test_result "TEST-P2-2" "No tab characters in header section" "FAIL"
fi

# TEST-P2-3: Header section character count is reasonable (< 800 chars)
if [ -f "$README_FILE" ]; then
    CHAR_COUNT=$(head -n 10 "$README_FILE" | wc -c | tr -d ' ')
    if [ "$CHAR_COUNT" -lt 800 ]; then
        test_result "TEST-P2-3" "Header section character count reasonable (actual: ${CHAR_COUNT})" "PASS"
    else
        test_result "TEST-P2-3" "Header section character count reasonable (actual: ${CHAR_COUNT})" "FAIL"
    fi
else
    test_result "TEST-P2-3" "Header section character count reasonable" "FAIL"
fi

# TEST-P2-4: Version metadata line has pipe separators
if [ -f "$README_FILE" ]; then
    SECOND_LINE=$(sed -n '2p' "$README_FILE")
    PIPE_COUNT=$(echo "$SECOND_LINE" | tr -cd '|' | wc -c | tr -d ' ')
    if [ "$PIPE_COUNT" -eq 2 ]; then
        test_result "TEST-P2-4" "Version line has exactly 2 pipe separators" "PASS"
    else
        test_result "TEST-P2-4" "Version line has exactly 2 pipe separators" "FAIL"
        echo -e "${YELLOW}  Actual pipe count: ${PIPE_COUNT}${NC}"
    fi
else
    test_result "TEST-P2-4" "Version line has exactly 2 pipe separators" "FAIL"
fi

echo ""
echo "=============================================="
echo "SUMMARY"
echo "=============================================="
echo -e "Passed: ${GREEN}${PASS_COUNT}${NC}"
echo -e "Failed: ${RED}${FAIL_COUNT}${NC}"
echo "Total:  $((PASS_COUNT + FAIL_COUNT))"
echo ""

if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${RED}TDD Phase: RED (tests failing as expected)${NC}"
    exit 1
else
    echo -e "${GREEN}TDD Phase: GREEN (all tests passing)${NC}"
    exit 0
fi
