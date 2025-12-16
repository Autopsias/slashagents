#!/bin/bash
# ATDD Validation Script: Story 3.2 - Write Installation Section
# TDD Phase: RED (tests expected to fail initially)
#
# Usage: ./tests/atdd/3-2-write-installation-section.sh
# Exit: 0 if all tests pass, 1 if any test fails

README_PATH="/Users/ricardocarvalho/CC_Agents_Commands/README.md"
PASSED=0
FAILED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "ATDD Tests: Story 3.2 - Installation Section"
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

# Extract Installation section content for analysis (macOS compatible)
# Get line numbers for Installation section boundaries
START_LINE=$(grep -n '^## Installation' "$README_PATH" | head -1 | cut -d: -f1)
if [ -n "$START_LINE" ]; then
    # Find next ## header after Installation
    END_LINE=$(tail -n +$((START_LINE + 1)) "$README_PATH" | grep -n '^## ' | head -1 | cut -d: -f1)
    if [ -n "$END_LINE" ]; then
        END_LINE=$((START_LINE + END_LINE - 1))
        INSTALL_SECTION=$(sed -n "${START_LINE},${END_LINE}p" "$README_PATH")
    else
        INSTALL_SECTION=$(tail -n +${START_LINE} "$README_PATH")
    fi
else
    INSTALL_SECTION=""
fi

echo "--- AC1: Installation Steps (5 steps maximum) ---"
echo ""

# AC1.1: README.md contains ## Installation section
run_test "AC1.1" "README contains Installation section" \
    "grep -q '^## Installation' '$README_PATH'" || true

# AC1.2: Installation section contains numbered steps (check for 1-5 steps)
run_test "AC1.2" "Installation has numbered steps (1-5)" \
    "echo \"\$INSTALL_SECTION\" | grep -qE '^[0-9]+\\.' && [ \$(echo \"\$INSTALL_SECTION\" | grep -cE '^[0-9]+\\.') -le 5 ] && [ \$(echo \"\$INSTALL_SECTION\" | grep -cE '^[0-9]+\\.') -ge 1 ]" || true

# AC1.3: Step includes clone/download instruction
run_test "AC1.3" "Contains clone instruction" \
    "echo \"\$INSTALL_SECTION\" | grep -qi 'git clone'" || true

# AC1.4: Step includes backup instruction
run_test "AC1.4" "Contains backup instruction" \
    "echo \"\$INSTALL_SECTION\" | grep -qi 'backup'" || true

# AC1.5: Step includes copy instruction
run_test "AC1.5" "Contains copy instruction" \
    "echo \"\$INSTALL_SECTION\" | grep -q 'cp -r'" || true

# AC1.6: Step includes session start instruction
run_test "AC1.6" "Contains session start instruction" \
    "echo \"\$INSTALL_SECTION\" | grep -qiE 'new.*session|start.*session|session'" || true

# AC1.7: Step includes verification instruction with /help
run_test "AC1.7" "Contains /help verification" \
    "echo \"\$INSTALL_SECTION\" | grep -q '/help'" || true

echo ""
echo "--- AC2: Two Installation Paths ---"
echo ""

# AC2.1: Mentions global installation path
run_test "AC2.1" "Mentions global path (~/.claude/)" \
    "echo \"\$INSTALL_SECTION\" | grep -q '~/.claude/'" || true

# AC2.2: Mentions project installation path (without ~)
run_test "AC2.2" "Mentions project path (.claude/)" \
    "echo \"\$INSTALL_SECTION\" | grep -qE '(^|[^~])\\.claude/'" || true

# AC2.3: Explains when to use global installation
run_test "AC2.3" "Explains when to use global installation" \
    "echo \"\$INSTALL_SECTION\" | grep -qiE 'global.*(all|every)|available.*all|personal'" || true

# AC2.4: Explains when to use project installation
run_test "AC2.4" "Explains when to use project installation" \
    "echo \"\$INSTALL_SECTION\" | grep -qiE 'project.*specific|version.*control|team'" || true

echo ""
echo "--- AC3: Backup Warning ---"
echo ""

# AC3.1: Contains backup warning
run_test "AC3.1" "Contains backup warning text" \
    "echo \"\$INSTALL_SECTION\" | grep -qiE 'warning|caution|important.*backup'" || true

# AC3.2: Warning is visually prominent (bold, blockquote, or emoji)
run_test "AC3.2" "Warning is visually prominent" \
    "echo \"\$INSTALL_SECTION\" | grep -qE '(\\*\\*.*[Ww]arning|\\*\\*.*[Bb]ackup|^>.*[Ww]arning|^>.*[Bb]ackup)'" || true

# AC3.3: Warning mentions overwrite risk
run_test "AC3.3" "Warning mentions overwrite risk" \
    "echo \"\$INSTALL_SECTION\" | grep -qiE 'overwrite|replace|conflict|lose|existing'" || true

echo ""
echo "--- AC4: Copy-Paste Ready ---"
echo ""

# AC4.1: Contains code blocks
run_test "AC4.1" "Contains bash code blocks" \
    "echo \"\$INSTALL_SECTION\" | grep -q '\`\`\`bash'" || true

# AC4.2: Clone command is complete (has URL)
run_test "AC4.2" "Clone command has complete URL" \
    "echo \"\$INSTALL_SECTION\" | grep -qE 'git clone.*(https://|git@)'" || true

# AC4.3: Copy commands are complete
run_test "AC4.3" "Copy commands are valid" \
    "echo \"\$INSTALL_SECTION\" | grep -qE 'cp -r.*(commands|agents|skills)'" || true

# AC4.4: No placeholders requiring modification
run_test "AC4.4" "No unresolved placeholders" \
    "! echo \"\$INSTALL_SECTION\" | grep -qE '<[A-Z_]+>|\\[YOUR|\\{your'" || true

echo ""
echo "--- Edge Cases & Quality Checks ---"
echo ""

# EC1.1: GitHub URL format is valid (P1)
run_test "EC1.1" "[P1] GitHub URL format is valid" \
    "echo \"\$INSTALL_SECTION\" | grep -qE 'github\\.com'" || true

# EC1.2: All three folders mentioned (P1)
run_test "EC1.2" "[P1] All three folders mentioned" \
    "echo \"\$INSTALL_SECTION\" | grep -q 'commands' && echo \"\$INSTALL_SECTION\" | grep -q 'agents' && echo \"\$INSTALL_SECTION\" | grep -q 'skills'" || true

# EC2.1: No broken markdown links (P2)
# Check that all markdown links have valid format [text](url) and no empty URLs
run_test "EC2.1" "[P2] No broken markdown links" \
    "! echo \"\$INSTALL_SECTION\" | grep -qE '\\[([^\\]]+)\\]\\(\\s*\\)'" || true

# EC2.2: Step numbers are sequential (P2)
# Extract step numbers and verify they're sequential if they exist
run_test "EC2.2" "[P2] Step numbers sequential" \
    "STEPS=\$(echo \"\$INSTALL_SECTION\" | grep -oE '^[0-9]+\\.' | tr -d '.' | tr '\n' ' '); [ -z \"\$STEPS\" ] || (echo \"\$STEPS\" | grep -qE '^1 2 3 4 5' || echo \"\$STEPS\" | grep -qE '^1 2 3 4' || echo \"\$STEPS\" | grep -qE '^1 2 3')" || true

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
