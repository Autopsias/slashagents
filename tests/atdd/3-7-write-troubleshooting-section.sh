#!/bin/bash
# ATDD Validation Script: Story 3.7 - Write Troubleshooting Section
# TDD Phase: RED (tests expected to fail initially)
#
# Usage: ./tests/atdd/3-7-write-troubleshooting-section.sh
# Exit: 0 if all tests pass, 1 if any test fails
#
# Test Coverage: 13 tests total
#   - P0 (Core ATDD): 7 tests - Critical acceptance criteria
#   - P1 (Important): 4 tests - Edge cases and important validations
#   - P2 (Quality): 2 tests - Format validation and consistency
#
# Categories:
#   - AC1 (Troubleshooting Section Header): 2 tests
#   - AC2 (Concise Format): 1 test
#   - AC3 (MCP Configuration Issues): 1 test
#   - AC4 (BMAD Framework Issues): 1 test
#   - AC5 (Command/Agent Not Found Issues): 1 test
#   - AC6 (Self-Service Resolution): 1 test
#   - EC1-EC2 (Edge Cases): 6 tests covering:
#     * Scannable format (short items)
#     * MCP prerequisites reference
#     * BMAD tools listed
#     * File location paths
#     * No external support first
#     * Section positioning

# Project root (dynamically resolved - works from anywhere)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
README_PATH="${PROJECT_ROOT}/README.md"
PASSED=0
FAILED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "ATDD Tests: Story 3.7 - Troubleshooting Section"
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

# Check if README exists
if [ ! -f "$README_PATH" ]; then
    echo -e "${RED}ERROR: README.md not found at $README_PATH${NC}"
    echo "TDD Phase: RED - README.md must exist"
    exit 1
fi

# Extract Troubleshooting section content for analysis (macOS compatible)
# Get line numbers for Troubleshooting section boundaries
START_LINE=$(grep -n '^## Troubleshooting' "$README_PATH" | head -1 | cut -d: -f1)
if [ -n "$START_LINE" ]; then
    # Find next ## header after Troubleshooting
    END_LINE=$(tail -n +$((START_LINE + 1)) "$README_PATH" | grep -n '^## ' | head -1 | cut -d: -f1)
    if [ -n "$END_LINE" ]; then
        END_LINE=$((START_LINE + END_LINE - 1))
        TROUBLESHOOTING_SECTION=$(sed -n "${START_LINE},${END_LINE}p" "$README_PATH")
    else
        TROUBLESHOOTING_SECTION=$(tail -n +${START_LINE} "$README_PATH")
    fi
else
    TROUBLESHOOTING_SECTION=""
fi

echo "--- P0: Core Acceptance Criteria Tests ---"
echo ""

echo "-- AC1: Troubleshooting Section Header --"
echo ""

# AC1.1: README.md contains ## Troubleshooting section
run_test "AC1.1" "Troubleshooting header exists" \
    "grep -q '^## Troubleshooting' '$README_PATH'" || true

# AC1.2: Troubleshooting section is after Skills Reference
SKILLSREF_LINE=$(grep -n '^## Skills Reference' "$README_PATH" | head -1 | cut -d: -f1)
TROUBLESHOOTING_LINE=$(grep -n '^## Troubleshooting' "$README_PATH" | head -1 | cut -d: -f1)
run_test "AC1.2" "Section after Skills Reference" \
    "[ -n \"\$SKILLSREF_LINE\" ] && [ -n \"\$TROUBLESHOOTING_LINE\" ] && [ \"\$TROUBLESHOOTING_LINE\" -gt \"\$SKILLSREF_LINE\" ]" || true

echo ""
echo "-- AC2: Concise Format --"
echo ""

# AC2.1: Section contains 3-5 items (count bold headers or numbered items)
# Count items by looking for bold text patterns (**text**) or ### headers or numbered lists
ITEM_COUNT=$(echo "$TROUBLESHOOTING_SECTION" | grep -cE '^\*\*[^*]+\?\*\*|^### |^[0-9]+\.' | tr -d ' ')
run_test "AC2.1" "Contains 3-5 items" \
    "[ -n \"\$ITEM_COUNT\" ] && [ \"\$ITEM_COUNT\" -ge 3 ] && [ \"\$ITEM_COUNT\" -le 5 ]" || true

echo ""
echo "-- AC3: MCP Configuration Issues Covered --"
echo ""

# AC3.1: MCP configuration guidance present
run_test "AC3.1" "MCP configuration guidance present" \
    "echo \"\$TROUBLESHOOTING_SECTION\" | grep -qiE 'mcp.*(server|config|setting)|mcp.*(not|working)'" || true

echo ""
echo "-- AC4: BMAD Framework Issues Covered --"
echo ""

# AC4.1: BMAD framework guidance present
run_test "AC4.1" "BMAD framework guidance present" \
    "echo \"\$TROUBLESHOOTING_SECTION\" | grep -qiE 'bmad.*(framework|install|required)|bmad.*(not|found)'" || true

echo ""
echo "-- AC5: Command/Agent Not Found Issues Covered --"
echo ""

# AC5.1: Not found guidance present
run_test "AC5.1" "Not found guidance present" \
    "echo \"\$TROUBLESHOOTING_SECTION\" | grep -qiE '(command|agent).*(not|found|recognized)|(not found|not recognized)'" || true

echo ""
echo "-- AC6: Self-Service Resolution --"
echo ""

# AC6.1: Items are actionable (has solution steps - look for numbered lists, bullets, or action verbs)
run_test "AC6.1" "Items are actionable (has solution steps)" \
    "echo \"\$TROUBLESHOOTING_SECTION\" | grep -qE '^[0-9]+\\.|^- |[Cc]heck|[Vv]erify|[Ee]nsure|[Rr]estart'" || true

echo ""
echo "--- P1: Important Formatting Tests ---"
echo ""

# EC1.1: Items are scannable (short format - no single item over 200 chars per paragraph)
# Check that items aren't massive walls of text
run_test "EC1.1" "[P1] Items are scannable (short format)" \
    "! echo \"\$TROUBLESHOOTING_SECTION\" | grep -E '.{300,}'" || true

# EC1.2: MCP mentions checking prerequisites
run_test "EC1.2" "[P1] MCP mentions checking prerequisites" \
    "echo \"\$TROUBLESHOOTING_SECTION\" | grep -qiE 'prerequisit'" || true

# EC1.3: BMAD lists affected tools (epic-dev commands)
run_test "EC1.3" "[P1] BMAD lists affected tools (epic-dev)" \
    "echo \"\$TROUBLESHOOTING_SECTION\" | grep -qE 'epic-dev'" || true

# EC1.4: Not found mentions file locations
run_test "EC1.4" "[P1] Not found mentions file locations" \
    "echo \"\$TROUBLESHOOTING_SECTION\" | grep -qE '~/.claude/|\\.claude/|claude/' || echo \"\$TROUBLESHOOTING_SECTION\" | grep -qi 'location'" || true

echo ""
echo "--- P2: Quality Checks ---"
echo ""

# EC2.1: No external support as first step (no "contact support" or "open issue" as primary resolution)
run_test "EC2.1" "[P2] No external support as first step" \
    "! echo \"\$TROUBLESHOOTING_SECTION\" | head -20 | grep -qiE 'contact support|open.*(issue|ticket)|reach out'" || true

# EC2.2: Section before License or Contributing (if they exist)
LICENSE_LINE=$(grep -n '^## License' "$README_PATH" | head -1 | cut -d: -f1)
CONTRIBUTING_LINE=$(grep -n '^## Contributing' "$README_PATH" | head -1 | cut -d: -f1)
# Test passes if: no license/contributing OR troubleshooting comes before them
run_test "EC2.2" "[P2] Section before License/Contributing" \
    "([ -z \"\$LICENSE_LINE\" ] && [ -z \"\$CONTRIBUTING_LINE\" ]) || ([ -n \"\$TROUBLESHOOTING_LINE\" ] && ([ -z \"\$LICENSE_LINE\" ] || [ \"\$TROUBLESHOOTING_LINE\" -lt \"\$LICENSE_LINE\" ]) && ([ -z \"\$CONTRIBUTING_LINE\" ] || [ \"\$TROUBLESHOOTING_LINE\" -lt \"\$CONTRIBUTING_LINE\" ]))" || true

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
