#!/bin/bash
# ATDD Validation Script: Story 3.8 - Create VALIDATION.md Checklist
# TDD Phase: RED (tests expected to fail initially)
#
# Usage: ./tests/atdd/3-8-create-validation-md-checklist.sh
# Exit: 0 if all tests pass, 1 if any test fails
#
# Test Coverage: 14 tests total
#   - P0 (Core ATDD): 9 tests - Critical acceptance criteria
#   - P1 (Important): 3 tests - Edge cases and important validations
#   - P2 (Quality): 2 tests - Format validation and consistency
#
# Categories:
#   - AC1 (Checklist Structure): 1 test
#   - AC2 (All 23 Tools Listed): 4 tests
#   - AC3 (Checkboxes for Testing): 1 test
#   - AC4 (Ships with Repository): 1 test
#   - AC5 (First-Use Test Section): 1 test
#   - AC6 (Pre-Release Quality Gates): 1 test
#   - EC1-EC2 (Edge Cases): 5 tests covering:
#     * Tier distribution
#     * Cold tester requirement
#     * Actionable quality gates
#     * File title/purpose
#     * Table of contents

VALIDATION_PATH="/Users/ricardocarvalho/CC_Agents_Commands/VALIDATION.md"
PASSED=0
FAILED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "ATDD Tests: Story 3.8 - VALIDATION.md Checklist"
echo "========================================"
echo ""

# Helper function to run a test
run_test() {
    local test_id="$1"
    local test_name="$2"
    local test_command="$3"

    TOTAL=$((TOTAL + 1))

    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC} [$test_id] $test_name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC} [$test_id] $test_name"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

echo "--- P0: Core Acceptance Criteria Tests ---"
echo ""

echo "-- AC4: Ships with Repository --"
echo ""

# AC1.1: VALIDATION.md exists at repository root
run_test "AC1.1" "VALIDATION.md exists at root" \
    "[ -f '$VALIDATION_PATH' ]" || true

# Early exit check - if file doesn't exist, remaining tests will fail
if [ ! -f "$VALIDATION_PATH" ]; then
    echo ""
    echo -e "${YELLOW}WARNING: VALIDATION.md not found. Remaining tests will fail (expected in RED phase).${NC}"
    echo ""
    # Set VALIDATION_CONTENT to empty for remaining tests
    VALIDATION_CONTENT=""
else
    VALIDATION_CONTENT=$(cat "$VALIDATION_PATH")
fi

echo "-- AC1: Checklist Structure --"
echo ""

# AC1.2: Table has required columns (Tool, Type, Tier, Clean Env Test, Graceful Failure, Prerequisites)
run_test "AC1.2" "Table has required columns" \
    "echo \"\$VALIDATION_CONTENT\" | grep -qE '\\| *Tool *\\|.*Type.*\\|.*Tier.*\\|.*Clean Env Test.*\\|.*Graceful Failure.*\\|.*Prerequisites *\\|'" || true

echo ""
echo "-- AC2: All 23 Tools Listed --"
echo ""

# AC2.1: Contains 11 commands
# Count lines that have "command" in the Type column
COMMAND_COUNT=$(echo "$VALIDATION_CONTENT" | grep -iE '\| *command *\|' | wc -l | tr -d ' ')
run_test "AC2.1" "Contains 11 commands" \
    "[ \"\$COMMAND_COUNT\" -eq 11 ]" || true

# AC2.2: Contains 11 agents
AGENT_COUNT=$(echo "$VALIDATION_CONTENT" | grep -iE '\| *agent *\|' | wc -l | tr -d ' ')
run_test "AC2.2" "Contains 11 agents" \
    "[ \"\$AGENT_COUNT\" -eq 11 ]" || true

# AC2.3: Contains 1 skill
SKILL_COUNT=$(echo "$VALIDATION_CONTENT" | grep -iE '\| *skill *\|' | wc -l | tr -d ' ')
run_test "AC2.3" "Contains 1 skill" \
    "[ \"\$SKILL_COUNT\" -eq 1 ]" || true

# AC2.4: Total 23 tools (count tool rows - lines with .md in them within tables)
TOOL_COUNT=$(echo "$VALIDATION_CONTENT" | grep -E '\.md *\|' | wc -l | tr -d ' ')
run_test "AC2.4" "Total 23 tools" \
    "[ \"\$TOOL_COUNT\" -eq 23 ]" || true

echo ""
echo "-- AC3: Checkboxes for Testing --"
echo ""

# AC3.1: Checkboxes exist (unchecked notation [ ])
run_test "AC3.1" "Checkboxes exist (unchecked notation)" \
    "echo \"\$VALIDATION_CONTENT\" | grep -qE '\\[ \\]'" || true

echo ""
echo "-- AC5: First-Use Test Section --"
echo ""

# AC5.1: First-Use Test section exists
run_test "AC5.1" "First-Use Test section exists" \
    "echo \"\$VALIDATION_CONTENT\" | grep -qiE '^#+.*first.?use.*test'" || true

echo ""
echo "-- AC6: Pre-Release Quality Gates --"
echo ""

# AC6.1: Quality Gates section exists
run_test "AC6.1" "Quality Gates section exists" \
    "echo \"\$VALIDATION_CONTENT\" | grep -qiE '^#+.*(quality.*gate|pre.?release.*gate)'" || true

echo ""
echo "--- P1: Important Formatting Tests ---"
echo ""

# EC1.1: Tier distribution correct (6 Standalone, 5 MCP-Enhanced, 3 BMAD-Required, 9 Project-Context)
STANDALONE_COUNT=$(echo "$VALIDATION_CONTENT" | grep -iE '\| *Standalone *\|' | wc -l | tr -d ' ')
MCP_COUNT=$(echo "$VALIDATION_CONTENT" | grep -iE '\| *MCP-Enhanced *\|' | wc -l | tr -d ' ')
BMAD_COUNT=$(echo "$VALIDATION_CONTENT" | grep -iE '\| *BMAD-Required *\|' | wc -l | tr -d ' ')
PROJECT_COUNT=$(echo "$VALIDATION_CONTENT" | grep -iE '\| *Project-Context *\|' | wc -l | tr -d ' ')
run_test "EC1.1" "[P1] Tier distribution correct (6/5/3/9)" \
    "[ \"\$STANDALONE_COUNT\" -eq 6 ] && [ \"\$MCP_COUNT\" -eq 5 ] && [ \"\$BMAD_COUNT\" -eq 3 ] && [ \"\$PROJECT_COUNT\" -eq 9 ]" || true

# EC1.2: Cold tester requirement documented (2-3 testers)
run_test "EC1.2" "[P1] Cold tester requirement documented (2-3)" \
    "echo \"\$VALIDATION_CONTENT\" | grep -qE '2.?3.*(tester|people|person)|cold.*(tester|test)'" || true

# EC1.3: Quality gates are actionable (has checkboxes or clear pass/fail criteria)
run_test "EC1.3" "[P1] Quality gates are actionable" \
    "echo \"\$VALIDATION_CONTENT\" | grep -qiE 'quality.*gate' && (echo \"\$VALIDATION_CONTENT\" | grep -qE '\\[ \\]|pass|fail|complete|verified')" || true

echo ""
echo "--- P2: Quality Checks ---"
echo ""

# EC2.1: File has title/purpose (starts with # heading)
run_test "EC2.1" "[P2] File has title/purpose" \
    "echo \"\$VALIDATION_CONTENT\" | head -5 | grep -qE '^# '" || true

# EC2.2: Table of contents present (has TOC or multiple ## sections with links)
run_test "EC2.2" "[P2] Table of contents present" \
    "echo \"\$VALIDATION_CONTENT\" | grep -qiE 'table of contents|contents|\\[.*\\]\\(#'" || true

echo ""
echo "========================================"
echo "SUMMARY"
echo "========================================"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo "Total:  $TOTAL"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo "TDD Phase: GREEN - Ready for refactoring"
    exit 0
else
    echo -e "${YELLOW}$FAILED test(s) failed${NC}"
    echo "TDD Phase: RED - Implementation needed"
    exit 1
fi
