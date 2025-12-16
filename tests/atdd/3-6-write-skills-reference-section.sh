#!/bin/bash
# ATDD Validation Script: Story 3.6 - Write Skills Reference Section
# TDD Phase: RED (tests expected to fail initially)
#
# Usage: ./tests/atdd/3-6-write-skills-reference-section.sh
# Exit: 0 if all tests pass, 1 if any test fails
#
# Test Coverage: 17 tests total
#   - P0 (Core ATDD): 8 tests - Critical acceptance criteria
#   - P1 (Important): 5 tests - Edge cases and important validations
#   - P2 (Quality): 4 tests - Format validation and consistency
#
# Categories:
#   - AC1 (Skills Section Header): 2 tests
#   - AC2 (Table Format): 2 tests
#   - AC3 (Skill Documented): 4 tests
#   - EC1-EC3 (Edge Cases): 9 tests covering:
#     * Section positioning (after Agents Reference, before Troubleshooting)
#     * Description validation (present-tense verb, length)
#     * Prerequisites notation (MCP format)
#     * Quality checks (duplicates, file existence, alignment, kebab-case)

README_PATH="/Users/ricardocarvalho/CC_Agents_Commands/README.md"
SKILLS_DIR="/Users/ricardocarvalho/CC_Agents_Commands/skills"
PASSED=0
FAILED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "ATDD Tests: Story 3.6 - Skills Reference Section"
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

# Extract Skills Reference section content for analysis (macOS compatible)
# Get line numbers for Skills Reference section boundaries
START_LINE=$(grep -n '^## Skills Reference' "$README_PATH" | head -1 | cut -d: -f1)
if [ -n "$START_LINE" ]; then
    # Find next ## header after Skills Reference
    END_LINE=$(tail -n +$((START_LINE + 1)) "$README_PATH" | grep -n '^## ' | head -1 | cut -d: -f1)
    if [ -n "$END_LINE" ]; then
        END_LINE=$((START_LINE + END_LINE - 1))
        SKILLS_SECTION=$(sed -n "${START_LINE},${END_LINE}p" "$README_PATH")
    else
        SKILLS_SECTION=$(tail -n +${START_LINE} "$README_PATH")
    fi
else
    SKILLS_SECTION=""
fi

echo "--- P0: Core Acceptance Criteria Tests ---"
echo ""

echo "-- AC1: Skills Section Header --"
echo ""

# AC1.1: README.md contains ## Skills Reference section
run_test "AC1.1" "Skills Reference header exists" \
    "grep -q '^## Skills Reference' '$README_PATH'" || true

# AC1.2: Skills Reference contains intro sentence explaining skills
run_test "AC1.2" "Intro sentence explaining skills exists" \
    "echo \"\$SKILLS_SECTION\" | head -10 | grep -qiE 'skill|workflow|capabilit'" || true

echo ""
echo "-- AC2: Table Format --"
echo ""

# AC2.1: Skills Reference has correct table header
run_test "AC2.1" "Table header exists (| Skill | What it does | Prerequisites |)" \
    "echo \"\$SKILLS_SECTION\" | grep -q '| Skill | What it does | Prerequisites |'" || true

# AC2.2: Table has separator row
run_test "AC2.2" "Table separator row exists" \
    "echo \"\$SKILLS_SECTION\" | grep -qE '\\|[-]+\\|[-]+\\|[-]+\\|'" || true

echo ""
echo "-- AC3: Skill Documented --"
echo ""

# AC3.1: pr-workflow skill is documented
run_test "AC3.1" "pr-workflow skill is documented" \
    "echo \"\$SKILLS_SECTION\" | grep -q 'pr-workflow'" || true

# AC3.2: Skill name in backticks
run_test "AC3.2" "Skill name in backticks (\`pr-workflow\`)" \
    "echo \"\$SKILLS_SECTION\" | grep -q '\`pr-workflow\`'" || true

# AC3.3: Description present (non-empty second column)
run_test "AC3.3" "Description present for pr-workflow" \
    "echo \"\$SKILLS_SECTION\" | grep 'pr-workflow' | grep -qE '\\| \`pr-workflow\` \\| [A-Za-z]'" || true

# AC3.4: Prerequisites present (non-empty third column)
run_test "AC3.4" "Prerequisites present for pr-workflow" \
    "echo \"\$SKILLS_SECTION\" | grep 'pr-workflow' | grep -qE '\\| [^|]+ \\| [^|]+ \\|'" || true

echo ""
echo "--- P1: Important Formatting Tests ---"
echo ""

# EC1.1: Skills Reference positioned after Agents Reference
AGENTSREF_LINE=$(grep -n '^## Agents Reference' "$README_PATH" | head -1 | cut -d: -f1)
SKILLSREF_LINE=$(grep -n '^## Skills Reference' "$README_PATH" | head -1 | cut -d: -f1)
run_test "EC1.1" "[P1] Skills Reference after Agents Reference" \
    "[ -n \"\$AGENTSREF_LINE\" ] && [ -n \"\$SKILLSREF_LINE\" ] && [ \"\$SKILLSREF_LINE\" -gt \"\$AGENTSREF_LINE\" ]" || true

# EC1.2: Skills Reference positioned before Troubleshooting (if exists)
TROUBLESHOOTING_LINE=$(grep -n '^## Troubleshooting' "$README_PATH" | head -1 | cut -d: -f1)
run_test "EC1.2" "[P1] Skills Reference before Troubleshooting (if exists)" \
    "[ -z \"\$TROUBLESHOOTING_LINE\" ] || ([ -n \"\$SKILLSREF_LINE\" ] && [ \"\$SKILLSREF_LINE\" -lt \"\$TROUBLESHOOTING_LINE\" ])" || true

# EC2.1: Description starts with present-tense verb
run_test "EC2.1" "[P1] Description starts with present-tense verb" \
    "echo \"\$SKILLS_SECTION\" | grep '\`pr-workflow\`' | grep -qE '\\| [A-Z][a-z]+(s|es) '" || true

# EC2.2: Description under 60 characters
run_test "EC2.2" "[P1] Description under 60 characters" \
    "! echo \"\$SKILLS_SECTION\" | grep -oE '^\\| \`pr-workflow\` \\| [^|]{61,} \\|'" || true

# EC2.3: Prerequisites uses MCP notation with via agent reference
run_test "EC2.3" "[P1] Prerequisites uses MCP notation (\`github\` MCP)" \
    "echo \"\$SKILLS_SECTION\" | grep 'pr-workflow' | grep -q '\`github\` MCP'" || true

echo ""
echo "--- P2: Quality Checks ---"
echo ""

# EC3.1: No duplicate skill entries
PRWORKFLOW_COUNT=$(echo "$SKILLS_SECTION" | grep -c '\`pr-workflow\`' | tr -d ' ')
run_test "EC3.1" "[P2] No duplicate skill entries (pr-workflow appears once)" \
    "[ \"\$PRWORKFLOW_COUNT\" -eq 1 ]" || true

# EC3.2: Skill file exists in skills/ directory
run_test "EC3.2" "[P2] Skill file exists (skills/pr-workflow.md)" \
    "[ -f '${SKILLS_DIR}/pr-workflow.md' ]" || true

# EC3.3: Table alignment correct (4 pipes per row)
run_test "EC3.3" "[P2] Table alignment correct (4 pipes per row)" \
    "! echo \"\$SKILLS_SECTION\" | grep -E '^\\| \`' | grep -vE '^\\| [^|]+ \\| [^|]+ \\| [^|]+ \\|'" || true

# EC3.4: Kebab-case skill name (no underscores, lowercase)
run_test "EC3.4" "[P2] Kebab-case skill name (no underscores)" \
    "! echo \"\$SKILLS_SECTION\" | grep -qE '\`[a-z]+_[a-z]+\`'" || true

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
